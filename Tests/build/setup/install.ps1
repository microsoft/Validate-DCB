git clone -q https://github.com/PowerShell/DscResource.Tests

Import-Module -Name "$env:APPVEYOR_BUILD_FOLDER\DscResource.Tests\AppVeyor.psm1"
Invoke-AppveyorInstallTask

[string[]]$PowerShellModules = @("Pester", 'posh-git', 'psake', 'poshspec', 'PSScriptAnalyzer')

$ModuleManifest = Test-ModuleManifest .\$($env:RepoName).psd1 -ErrorAction SilentlyContinue
$repoRequiredModules = $ModuleManifest.RequiredModules.Name

if ($repoRequiredModules) { $PowerShellModules += $repoRequiredModules }

# This section is taken care of by Invoke-AppVeyorInstallTask
<#[string[]]$PackageProviders = @('NuGet', 'PowerShellGet')

# Install package providers for PowerShell Modules
ForEach ($Provider in $PackageProviders) {
    If (!(Get-PackageProvider $Provider -ErrorAction SilentlyContinue)) {
        Install-PackageProvider $Provider -Force -ForceBootstrap -Scope CurrentUser
    }
}#>

# Install the PowerShell Modules
ForEach ($Module in $PowerShellModules) {
    If (!(Get-Module -ListAvailable $Module -ErrorAction SilentlyContinue)) {
        Install-Module $Module -Scope CurrentUser -Force -Repository PSGallery
    }
    
    Import-Module $Module
}

$BuildSystem = Get-CimInstance -ClassName 'Win32_OperatingSystem'

Switch -Wildcard ($BuildSystem.Caption) {
    '*Windows 10*' {
        # Get FailoverCluster Capability Name
        $capabilityName = (Get-WindowsCapability -Online | Where-Object Name -like *RSAT*FailoverCluster.Management*).Name
        Add-WindowsCapability -Name $capabilityName -Online
    }

    'Default' {
        Install-WindowsFeature -Name RSAT-Clustering-Powershell
    }
}