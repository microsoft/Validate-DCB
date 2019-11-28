git.exe clone -q https://github.com/PowerShell/DscResource.Tests

Import-Module -Name "$env:APPVEYOR_BUILD_FOLDER\DscResource.Tests\AppVeyor.psm1"
Invoke-AppveyorInstallTask

[string[]]$PowerShellModules = @("Pester", 'posh-git', 'psake', 'poshspec', 'PSScriptAnalyzer')

$ModuleManifest = Test-ModuleManifest .\$($env:RepoName).psd1 -ErrorAction SilentlyContinue
$repoRequiredModules = $ModuleManifest.RequiredModules.Name
$repoRequiredModules += $ModuleManifest.PrivateData.PSData.ExternalModuleDependencies

If ($repoRequiredModules) { $PowerShellModules += $repoRequiredModules }

# This section is taken care of by Invoke-AppVeyorInstallTask
<#[string[]]$PackageProviders = @('NuGet', 'PowerShellGet')

# Install package providers for PowerShell Modules
ForEach ($Provider in $PackageProviders) {
    If (!(Get-PackageProvider $Provider -ErrorAction SilentlyContinue)) {
        Install-PackageProvider $Provider -Force -ForceBootstrap -Scope CurrentUser
    }
}#>

# Feature Installation

$serverFeatureList = @('Hyper-V')

If ($PowerShellModules -contains 'FailoverClusters') {
    $serverFeatureList += 'RSAT-Clustering-Mgmt', 'RSAT-Clustering-PowerShell'
}

$BuildSystem = Get-CimInstance -ClassName 'Win32_OperatingSystem'

ForEach ($Module in $PowerShellModules) {
    If ($Module -eq 'FailoverClusters') {
        Switch -Wildcard ($BuildSystem.Caption) {
            '*Windows 10*' {
                Write-Output 'Build System is Windows 10'
                Write-Output "Not Implemented"

                # Get FailoverCluster Capability Name and Install on W10 Builds
                $capabilityName = (Get-WindowsCapability -Online | Where-Object Name -like *RSAT*FailoverCluster.Management*).Name
                Add-WindowsCapability -Name $capabilityName -Online
            }

            Default {
                Write-Output "Build System is $($BuildSystem.Caption)"
                Install-WindowsFeature -Name $serverFeatureList -IncludeManagementTools | Out-Null
            }
        }
    }
    ElseIf ($Module -eq 'Pester') {
        Install-Module $Module -Scope AllUsers -Force -Repository PSGallery -AllowClobber -SkipPublisherCheck
    }
    else {
        Install-Module $Module -Scope AllUsers -Force -Repository PSGallery -AllowClobber
    }

    Import-Module $Module
}
