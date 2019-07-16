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

    Context ExportedContent {
        $testCommand = Get-Command Validate-DCB

        It 'Should have an alias named Validate-DCB' {
            (Get-Alias Validate-DCB).CommandType | Should Be 'Alias'
        }

        It 'Should reference Assert-DCBValidation' {
            $testCommand.ReferencedCommand.Name | Should be 'Assert-DCBValidation'
        }

        It 'Should default the TestScope param to All' {
            Get-Command Assert-DCBValidation | Should -HaveParameter TestScope -DefaultValue 'All'
        }

        It 'Should default the ContinueOnFailure param to $false' {
            Get-Command Assert-DCBValidation | Should -HaveParameter ContinueOnFailure -DefaultValue $false
        }

        It 'Should default the LaunchUI param to $true' {
            Get-Command Assert-DCBValidation | Should -HaveParameter LaunchUI -DefaultValue $true
        }
    }
}
