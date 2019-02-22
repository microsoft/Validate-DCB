Function Get-NetworkIHV {
    param (
        [string] $NetAdapterName,
        [string] $nodeName
    )

    if ($PSBoundParameters.ContainsKey('nodeName')) { 
        $driverName = Get-NetAdapter -Name $NetAdapterName -CimSession $nodeName | Select-Object DriverFileName
    }
    else {
        $driverName = Get-NetAdapter -Name $NetAdapterName | Select-Object DriverFileName
    }

    $thisIHV = $drivers.Where{$_.DriverFileName -eq $driverName[$driverName.Count - 1]}.IHV

    Return $thisIHV
}

Function Get-DCBClusterNodes {
    <#
    .Synopsis
        Gets a list of cluster nodes
    .DESCRIPTION
        Accepts input to retrieve the list of nodes in an existing cluster. Can accept multiple
    .EXAMPLE
        Get-DCBClusterNodes -Cluster 'S2DCluster01', 'S2DCluster02'
       
    #>      
    Param ( 
        [String[]] $Clusters
    )

    $NodeList = foreach ( $Cluster in $Clusters ) {
        ( Get-ClusterNode -Cluster $Cluster ).Name
    }
    
    Return $NodeList
}

[DscLocalConfigurationManager()]
Configuration DscMetaConfigs
{
    param (
        [Parameter(Mandatory=$True)]
        [String]$RegistrationUrl,

        [Parameter(Mandatory=$True)]
        [String]$RegistrationKey,

        [Parameter(Mandatory=$True)]
        [String[]] $ComputerName,

        [Int] $RefreshFrequencyMins = 30,

        [Int] $ConfigurationModeFrequencyMins = 15,

        [String] $ConfigurationMode = 'ApplyAndMonitor',

        [String] $NodeConfigurationName,

        [Boolean] $RebootNodeIfNeeded= $False,

        [String] $ActionAfterReboot = 'ContinueConfiguration',

        [Boolean] $AllowModuleOverwrite = $False,

        [Boolean] $ReportOnly
    )

    # https://docs.microsoft.com/en-us/azure/automation/automation-dsc-onboarding#physicalvirtual-windows-machines-on-premises-or-in-a-cloud-other-than-azureaws

    if (!$NodeConfigurationName -or $NodeConfigurationName -eq '') { $ConfigurationNames = $null }
    else { $ConfigurationNames = @($NodeConfigurationName)}

    if ($ReportOnly){ $RefreshMode = 'PUSH' }
    else { $RefreshMode = 'PULL' }

    Node $ComputerName {
        Settings {
            RefreshFrequencyMins           = $RefreshFrequencyMins
            RefreshMode                    = $RefreshMode
            ConfigurationMode              = $ConfigurationMode
            AllowModuleOverwrite           = $AllowModuleOverwrite
            RebootNodeIfNeeded             = $RebootNodeIfNeeded
            ActionAfterReboot              = $ActionAfterReboot
            ConfigurationModeFrequencyMins = $ConfigurationModeFrequencyMins
        }

        if (!$ReportOnly) {
            ConfigurationRepositoryWeb AzureAutomationStateConfiguration {
                ServerUrl          = $RegistrationUrl
                RegistrationKey    = $RegistrationKey
                ConfigurationNames = $ConfigurationNames
            }

            ResourceRepositoryWeb AzureAutomationStateConfiguration {
                ServerUrl       = $RegistrationUrl
                RegistrationKey = $RegistrationKey
            }
        }

        ReportServerWeb AzureAutomationStateConfiguration {
            ServerUrl       = $RegistrationUrl
            RegistrationKey = $RegistrationKey
        }
    }
}

Function Publish-Automation {
    Write-Output 'Beginning Deployment---'
    $AutomationAcctParams = @{
        ResourceGroupName = $configData.NonNodeData.AzureAutomation.ResourceGroupName
        AutomationAccountName = $configData.NonNodeData.AzureAutomation.AutomationAccountName
    }

    $requiredModules = 'xHyper-V', 'NetworkingDSC', 'DataCenterBridging', 'VMNetworkAdapter'

    Write-Output "Verifying the required modules exist in Azure Automation"

    foreach ($module in $requiredModules) {
        $moduleAAAvailability = Get-AzureRmAutomationModule -Name $module @AutomationAcctParams -ErrorAction SilentlyContinue
        
        If (!($moduleAAAvailability)) {
            Write-Output "- $Module did not exist in the Azure Automation account"
            Write-Output "---Locating Repository Source Location for $Module"

            $moduleURI = Find-Module -Name $module -ErrorAction SilentlyContinue

            if ($moduleURI) {
                Write-Output "-----Importing $Module into the Azure Automation account"
                $moduleImport = Import-AzureRmAutomationModule -Name $module -ContentLinkUri "$($moduleURI.RepositorySourceLocation)/Package/$module" @AutomationAcctParams
    
                while(($moduleImport.ProvisioningState -ne 'Succeeded') -and ($module.ProvisioningState -ne 'Failed')) {
                    Write-Output "-------Waiting for $Module to complete the import"
                    Start-Sleep -Seconds 5
                    $moduleImport = Get-AzureRmAutomationModule -Name $module @AutomationAcctParams
                }
    
                If ($moduleImport.ProvisioningState -ne 'Succeeded') {
                    throw {
                        Write-Output "!!!Import of Module $module failed!!!  Please review the Azure Automation portal for more information."
                        Write-Output "Account Details:"
                        Write-Output -InputObject $AutomationAcctParams
                    }
                }
                Else { Write-Output "---------Import of $module Succeeded" }
            }
            else {
                Write-Error "Catastrophic Failure: $Module could not be found in one of the available repositories. Deployment cannot continue!"
                $failedImport = $true
            }
        }
        Else {
            Write-Output "Module: $module exists in the Azure Automation account"
        }
    }

    if ($failedImport) { break }

    Write-Output "Generating MOF for Azure Automation"
    NetworkConfig -OutputPath "$here\Results\MOFs" -ConfigurationData $configData | Out-Null

    Write-Output "Importing the DSC Node Configuration to Azure Automation"
    (Get-ChildItem -Path "$here\Results\MOFs").FullName | Foreach-Object {
        Import-AzureRmAutomationDscNodeConfiguration -Path $_ -ConfigurationName NetworkConfig -Force @AutomationAcctParams | Out-Null
    }

    $AARegistrationInfo = Get-AzureRmAutomationRegistrationInfo @AutomationAcctParams

    $configData.AllNodes.Role | Select-Object -Unique | ForEach-Object {
        $thisRole = $_

        $Params = @{
            RegistrationUrl = "$($AARegistrationInfo.Endpoint)"
            RegistrationKey = "$($AARegistrationInfo.PrimaryKey)"
            NodeConfigurationName = "NetworkConfig.$thisRole"
            ComputerName = $configData.AllNodes.Where{ $_.Role -eq $thisRole }.NodeName
            RefreshFrequencyMins = 30
            ConfigurationModeFrequencyMins = 15
            RebootNodeIfNeeded = $False
            AllowModuleOverwrite = $true
            ConfigurationMode = 'ApplyAndAutoCorrect'
            ActionAfterReboot = 'ContinueConfiguration'
            ReportOnly = $False
        }

        Write-Output "Configuring LCM to look at Azure Automation"

        DscMetaConfigs @Params -OutputPath $here\Results\Meta | Out-Null
        Set-DscLocalConfigurationManager -Path $here\Results\Meta -Verbose -Force

        $allNodesWithRole = $configData.AllNodes.Where{$_.Role -eq $thisRole}.NodeName

        'Previous', 'Pending', 'Current' | ForEach-Object {
            Remove-DscConfigurationDocument -Stage $_ -Force -CimSession $allNodesWithRole
        }
        
        Update-DscConfiguration -Verbose -Wait -CimSession $allNodesWithRole
    }
}
