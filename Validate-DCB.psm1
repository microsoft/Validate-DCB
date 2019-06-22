New-Alias -Name 'Validate-DCB' -Value 'Assert-DCBValidation'

function Assert-DCBValidation {
    <#
    .SYNOPSIS
        Validate-DCB validates RDMA and DCB best practice configuration to assist in troubleshooting or verifying configuration

    .DESCRIPTION
        Validate-DCB allows you to:
        - Validate the expected configuration on one to N number of systems or clusters
        - Validate the configuration meets best practices

        Additional benefits include:
        - The configuration doubles as DCB documentation for the expected configuration of your systems.
        - Answer the question "What Changed?" when faced with an operational issue
        
        This tool does not modify your system. As such, you can re-validate the configuration as many times as desired.

    .PARAMETER LaunchUI
    Use to launch a user interface to help create a configuration file.  Use the following values to specify one of the example files.
    Optionally allows you to deploy the configuration using Azure Automation at the end.

    .PARAMETER ExampleConfig
        Use to specify one of the example configuration files.  Use the following values to specify one of the example files
        |  Value  |                  Location                | 
        | ------- |------------------------------------------|
        |  NDKm1  | .\Examples\NDKm1-examples.DCB.config.ps1 |
        |  NDKm2  | .\Examples\NDKm2-examples.DCB.config.ps1 |

        Possible options include NDKm1 or NDKm2.  This option cannot be used with the $ConfigFilePath parameter
        
    .PARAMETER ConfigFilePath
        Specifies the literal or relative paths to a custom configuration file.
        This option cannot be used with the $ExampleConfig parameter

    .PARAMETER ContinueOnFailure
        By default, Validate-DCB will exit at the end of a describe block if at least one test has failed.
        The intent is to give you an opportunity to correct the issue prior to moving on.  This could have an impact 
        on the ability of future tests to run successfully.
        
        Use this to attempt all tests even if a test failure is detected.

    .PARAMETER Deploy
        Deploy the configuration specified in the config file to the nodes.
        By default, Validate-DCB validates the configuration.  With this option, it will modify your system.

        Please note: Due to the nature of declarative PowerShell (DSC) this could be destructive.  For example,
        if your config file specify's that a vSwitch's IovEnabled property is $true and it is not actually 
        configured properly on the system DSC will attempt to destroy the vSwitch and recreate it with
        the correct settings.  Since this option can only be configured at vSwitch creation time, there is only one option. 

    .PARAMETER TestScope
        Determines the describe block to be run. You can use this to only run certain describe blocks.
        By default, Global and Modal (currently all) describe blocks are run.

    .EXAMPLE
        Validate-DCB

    .EXAMPLE
        Validate-DCB -ExampleConfig NDKm2

    .EXAMPLE
        Validate-DCB -ConfigFilePath c:\temp\ClusterA.ps1

    .EXAMPLE
        Validate-DCB -ExampleConfig NDKm1 -TestScope Modal
    
    .NOTES
        Author: Windows Core Networking team @ Microsoft

        Please file issues on GitHub @ GitHub.com/Microsoft/Validate-DCB

    .LINK
        More projects               : https://github.com/microsoft/sdn
        Windows Networking Blog     : https://blogs.technet.microsoft.com/networking/
        RDMA Configuration Guidance : https://aka.ms/ConvergedNIC
    #> 

    [CmdletBinding(DefaultParameterSetName = 'Create Config')]

    param (
        [Parameter(ParameterSetName='DefaultConfig')]
        [ValidateSet('NDKm1', 'NDKm2')]
        [string] $ExampleConfig,

        [Parameter(ParameterSetName='CustomConfig')]
        [string] $ConfigFilePath,

        [Parameter(ParameterSetName='Create Config')]
        [switch] $LaunchUI = $true, 

        [Parameter(Mandatory=$false)]
        [switch] $ContinueOnFailure = $false,

        [Parameter(Mandatory=$false)]
        [ValidateSet('All','Global', 'Modal')]
        [string] $TestScope = 'All' ,

        [Parameter(ParameterSetName='DefaultConfig')]
        [Parameter(ParameterSetName='CustomConfig')]
        [switch] $Deploy = $false
    )

    Clear-Host

    If ($PSCmdlet.ParameterSetName -ne 'Create Config') { $LaunchUI = $false }

    If (-not (Get-Module -Name Pester -ListAvailable)) { 
        Write-Output 'Pester is an inbox PowerShell Module included in Windows 10, Windows Server 2016, and later'
        Throw 'Catastrophic Failure :: PowerShell Module Pester was not found'
    }

    $here      = Split-Path -Parent (Get-Module -Name Validate-DCB).Path
    $startTime = Get-Date -format:'yyyyMMdd-HHmmss'
    New-Item -Name 'Results' -Path $here -ItemType Directory -Force

    $modCounter = 0
    If ($global:deploy -eq $true -or $LaunchUI -eq $true) {
        $deployReqModules = Import-PowerShellDataFile -Path "$here\helpers\NetworkConfig\NetworkConfig.psd1"

        ($deployReqModules).RequiredModules.GetEnumerator() | ForEach-Object {
            $module = Get-Module $_.ModuleName -ListAvailable -ErrorAction SilentlyContinue

            If (!($module)) {
                Write-Output "The test host requires the module $($_.ModuleName) to continue.  Please use Install-Module $($_.ModuleName) or move the module to this system."
                $modCounter ++
            }        
            
            if ($_.ContainsKey('ModuleVersion')) {
                if (!($module.version -ge $_.ModuleVersion)) {
                    Write-Output "The test host requires the module $($_.ModuleName) be at least version $($_.ModuleVersion) to continue`n"
                    $modCounter ++
                }
            }
        }
        
        If ($modCounter -eq 0) {
            Import-Module "$here\helpers\NetworkConfig\NetworkConfig.psd1" -Force
            Import-Module "$here\helpers\UI\vDCBUI.psm1" -Force
        }
        Else {
            Write-Error -Message "One or more of the required modules was not available on the system."
            Break
        }
    }

    #region Getting helpers & data...
    If ($LaunchUI) {
        $CheckModule = Get-Module -Name NetworkConfig, vDCBUI
        
        If ($CheckModule.Count -ne 2) { 'NetworkConfig or vDCBUI Module was not available for import'; break }

        Write-Output 'Launching Configuration and Deployment UI'
        vDCBUI

        $ConfigFile = $global:ConfigPath

        Write-Output "Configuration from the UI will be used"
        Write-Output "The configuration is located at $ConfigFile"
    }
    ElseIf ($PSBoundParameters.ContainsKey('ExampleConfig')) {
        $ConfigFile = $(Join-Path $Here -ChildPath "Examples\$ExampleConfig-examples.DCB.config.ps1")
        $fullPath   = (Get-ChildItem -Path $configFile).FullName

        Write-Output "Example Configuration Mode ($ExampleConfig) was specified"
        Write-Output "The default configuration located at $fullPath will be used"
    } 
    ElseIf ($PSBoundParameters.ContainsKey('ConfigFilePath')) {
        $fullPath   = (Get-ChildItem -Path $ConfigFilePath).FullName
        Write-Output "The Config File at $fullPath will be used"
        $ConfigFile = $ConfigFilePath
    }

    If (Test-Path $ConfigFile) { & $ConfigFile }
    Else {
        Throw "Catastrophic Failure :: Configuration File was not found at $ConfigFile"
    }

    Remove-Variable -Name configData -ErrorAction SilentlyContinue
    Import-Module "$here\helpers\helpers.psd1" -Force
    $configData += Import-PowerShellDataFile -Path .\helpers\drivers\drivers.psd1
    #endregion

    Switch ($TestScope) {
        'Global' {
            $testFile = Join-Path -Path $here -ChildPath "tests\unit\global.unit.tests.ps1"
            $GlobalResults = Invoke-Pester -Script $testFile -Tag 'Global' -OutputFile "$here\Results\$startTime-Global-unit.xml" -OutputFormat NUnitXml -PassThru
            $GlobalResults | Select-Object -Property TagFilter, Time, TotalCount, PassedCount, FailedCount, SkippedCount, PendingCount | Format-Table -AutoSize
        }

        'Modal' {
            If ($global:deploy) { Publish-Automation }

            $testFile = Join-Path -Path $here -ChildPath "tests\unit\modal.unit.tests.ps1"
            $ModalResults = Invoke-Pester -Script $testFile -Tag 'Modal' -OutputFile "$here\Results\$startTime-Modal-unit.xml" -OutputFormat NUnitXml -PassThru
            $ModalResults | Select-Object -Property TagFilter, Time, TotalCount, PassedCount, FailedCount, SkippedCount, PendingCount | Format-Table -AutoSize
        }

        Default {
            $testFile = Join-Path -Path $here -ChildPath "tests\unit\global.unit.tests.ps1"
            $GlobalResults = Invoke-Pester -Script $testFile -Tag 'Global' -OutputFile "$here\Results\$startTime-Global-unit.xml" -OutputFormat NUnitXml -PassThru
            $GlobalResults | Select-Object -Property TagFilter, Time, TotalCount, PassedCount, FailedCount, SkippedCount, PendingCount | Format-Table -AutoSize
            
            If ($global:deploy) { Publish-Automation }

            If ($GlobalResults.FailedCount -ne 0) {
                Write-Host 'Failures in Global exist.  Please resolve failures prior to moving on'
                Break
            }

            $testFile = Join-Path -Path $here -ChildPath "tests\unit\modal.unit.tests.ps1"
            $ModalResults = Invoke-Pester -Script $testFile -Tag 'Modal' -OutputFile "$here\Results\$startTime-Modal-unit.xml" -OutputFormat NUnitXml -PassThru
            $ModalResults | Select-Object -Property TagFilter, Time, TotalCount, PassedCount, FailedCount, SkippedCount, PendingCount | Format-Table -AutoSize
        }
    }
}
