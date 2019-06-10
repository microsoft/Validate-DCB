$NetAdapter = Get-NetAdapter
Write-Output "NetAdapter Count: $($NetAdapter.Count)"
foreach ($Adapter in $NetAdapter) {
    Write-Output "NetAdapter Name: $($NetAdapter.Name)"
}

Write-Output 'Tester - Tester - Tester'
Write-Output 'Tester - Tester - Tester'
Write-Output 'Tester - Tester - Tester'

Get-NetAdapter

Describe "$($env:repoName)-Manifest" {
    $DataFile   = Import-PowerShellDataFile .\$($env:repoName).psd1 -ErrorAction SilentlyContinue
    $TestModule = Test-ModuleManifest       .\$($env:repoName).psd1 -ErrorAction SilentlyContinue

    Context Manifest-Validation {
        It "[Import-PowerShellDataFile] - $($env:repoName).psd1 is a valid PowerShell Data File" {
            $DataFile | Should Not BeNullOrEmpty
        }

        It "[Test-ModuleManifest] - $($env:repoName).psd1 should pass the basic test" {
            $TestModule | Should Not BeNullOrEmpty
        }

        Import-Module .\$($env:repoName).psd1 -Force -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
        $command = Get-Command $($env:repoName) -ErrorAction SilentlyContinue

        It "Should have the $($env:repoName) function available" {
            $command | Should not BeNullOrEmpty
        }
    }

    <#
    Context Validate-GlobalExamples {
        Validate-DCB -ExampleConfig NDKm1 -TestScope Global
    }
    #>
}
