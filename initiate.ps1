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

.PARAMETER TestScope
    Determines the describe block to be run. You can use this to only run certain describe blocks.
    By default, Global and Modal (currently all) describe blocks are run.

.EXAMPLE
    .\Initiate.ps1 -ExampleConfig NDKm2

.EXAMPLE
    .\Initiate.ps1 -ConfigFilePath c:\temp\ClusterA.ps1

.EXAMPLE
    .\Initiate.ps1 -TestScope Global

.EXAMPLE
    .\Initiate.ps1 -TestScope Modal
   
.NOTES
    Author: Windows Core Networking team @ Microsoft

.LINK
    More projects               : https://github.com/microsoft/sdn
    Windows Networking Blog     : https://blogs.technet.microsoft.com/networking/
    RDMA Configuration Guidance : https://aka.ms/ConvergedNIC
#> 

param (
    [Parameter(ParameterSetName='DefaultConfig')]
    [ValidateSet('NDKm1', 'NDKm2')]
    [string] $ExampleConfig,

    [Parameter(ParameterSetName='CustomConfig')]
    [string] $ConfigFilePath,

    [Parameter(Mandatory=$false)]
    [switch] $ContinueOnFailure = $false,

    [Parameter(Mandatory=$false)]
    [ValidateSet('All','Global', 'Modal')]
    [string] $TestScope = 'All'
)

Clear-Host

If (-not (Get-Module -Name Pester -ListAvailable)) { 
    Write-Output 'Pester is an inbox PowerShell Module included in Windows 10, Windows Server 2016, and later'
    Throw 'Catastrophic Failure :: PowerShell Module Pester was not found'
}

$here      = Split-Path -Parent $MyInvocation.MyCommand.Path
$startTime = Get-Date -format:'yyyyMMdd-HHmmss'

Remove-Variable configData -ErrorAction SilentlyContinue
Import-Module "$here\helpers\helpers.psm1"
New-Item -Name 'Results' -Path $here -ItemType Directory -Force

If ($PSBoundParameters.ContainsKey('ExampleConfig')) {
    Write-Output "Example Configuration Mode ($ExampleConfig) was specified"
    Write-Output "The default configuration located $(Join-Path $Here -ChildPath "Examples\$ExampleConfig-examples.DCB.config.ps1") will be used"
    $ConfigFile = $(Join-Path $Here -ChildPath "Examples\$ExampleConfig-examples.DCB.config.ps1")
} 
ElseIf ($PSBoundParameters.ContainsKey('ConfigFilePath')) {
    Write-Output "The Config File at $ConfigFilePath will be used"
    $ConfigFile = $ConfigFilePath
}

If (Test-Path $ConfigFile) { & $ConfigFile }
Else {
    Throw "Catastrophic Failure :: Configuration File was not found at $ConfigFile"
}

$testType = 'unit'
$testFile = Join-Path -Path $here -ChildPath "tests\dcb.tests.$testType.ps1"

Switch ($TestScope) {
    'Global' {
        $PesterResults = Invoke-Pester -Script $testFile -Tag 'Global' -OutputFile "$here\Results\$startTime-global-$testType.xml" -OutputFormat NUnitXml -PassThru
    }

    'Modal' {
        $PesterResults = Invoke-Pester -Script $testFile -Tag 'Modal' -OutputFile "$here\Results\$startTime-modal-$testType.xml" -OutputFormat NUnitXml -PassThru
    }

    Default {
        $PesterResults = Invoke-Pester -Script $testFile -Tag 'Global' -OutputFile "$here\Results\$startTime-Global-$testType.xml" -OutputFormat NUnitXml -PassThru

        If (( -not( $ContinueOnFailure )) -and $PesterResults.FailedCount) {
            Invoke-TestFailure -TestType $TestType -PesterResults $PesterResults
        }

        $PesterResults = Invoke-Pester -Script $testFile -Tag 'Modal' -OutputFile "$here\Results\$startTime-Modal-$testType.xml" -OutputFormat NUnitXml -PassThru
    }
}
