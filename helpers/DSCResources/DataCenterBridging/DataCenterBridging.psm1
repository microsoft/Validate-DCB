enum Ensure {
    Absent
    Present
}

[DscResource()]
Class DCBNetQosFlowControl {
    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    [DscProperty(Key)]
    [ValidateRange(0,7)]
    [int] $Priority

    [DscProperty(NotConfigurable)]
    [Boolean] $Enabled

    [DCBNetQosFlowControl] Get() {
        $FlowControlPriority = Get-NetQosFlowControl -Priority $this.Priority

        $this.Enabled = $FlowControlPriority.Enabled
        $this.Priority = $FlowControlPriority.Priority

        return $this
    }

    [bool] Test() {
        $FlowControlPriority = Get-NetQosFlowControl -Priority $this.Priority

        $testState = $false
        if ($this.Ensure -eq [Ensure]::Present) {
            Switch ($FlowControlPriority.Enabled) {
                $true {$testState = $true}
                $false {$testState =  $false}
            }
        }
        elseif ($this.Ensure -eq [Ensure]::Absent) {
            Switch ($FlowControlPriority.Enabled) {
                $true {$testState =  $false}
                $false {$testState =  $true}
            } 
        }

        Return $testState
    }

    [Void] Set() {
        if ($this.Ensure -eq [Ensure]::Present) {
            Write-Verbose "Enabling priority $($this.Priority)"
            Set-NetQosFlowControl -Priority $this.Priority -Enabled $true
            Write-Verbose "Priority $($this.Priority) is now Enabled"
        }
        elseif ($this.Ensure -eq [Ensure]::Absent) {
            Write-Verbose "Enabling priority $($this.Priority)"
            Set-NetQosFlowControl -Priority $this.Priority -Enabled $false
            Write-Verbose "Priority $($this.Priority) is now disabled"
        }
    }
}

[DscResource()]
Class DCBNetAdapterQos {
    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    [DscProperty(Key)]
    [string] $InterfaceName

    [DscProperty(NotConfigurable)]
    [Boolean] $Enabled

    [DCBNetAdapterQos] Get() {
        $NetAdapterQosState = Get-NetAdapterQos -Name $this.InterfaceName

        $this.InterfaceName = $NetAdapterQosState.Name
        $this.Enabled = $NetAdapterQosState.Enabled

        return $this
    }

    [bool]Test() {
        $NetAdapterQosState = Get-NetAdapterQos -Name $this.InterfaceName

        $testState = $false

        if ($this.Ensure -eq [Ensure]::Present) {
            Switch ($NetAdapterQosState.Enabled) {
                $true {$testState = $true}
                $false {$testState =  $false}
            }
        }
        elseif ($this.Ensure -eq [Ensure]::Absent) {
            Switch ($NetAdapterQosState.Enabled) {
                $true {$testState =  $false}
                $false {$testState =  $true}
            } 
        }

        Return $testState
    }

    [Void] Set() {
        if ($this.Ensure -eq [Ensure]::Present) {
            Write-Verbose "Enabling QoS on $($this.InterfaceName)"
            Set-NetAdapterQos -Name $this.InterfaceName -Enabled $true
            Write-Verbose "QoS is now enabled on $($this.InterfaceName)"
        }
        elseif ($this.Ensure -eq [Ensure]::Absent) {
            Write-Verbose "Disabling QoS on $($this.InterfaceName)"
            Set-NetAdapterQos -Name $this.InterfaceName -Enabled $false
            Write-Verbose "QoS is now disabled on $($this.InterfaceName)"
        }
    }
}

[DscResource()]
Class DCBNetQosDcbxSetting {
    [DscProperty(Key)]
    [Ensure] $Ensure

    [DCBNetQosDcbxSetting] Get() {
        $NetQosDcbx = Get-NetQosDcbxSetting

        if ($this.Ensure) {
            $this.Willing = $NetQosDcbx.Willing
        }

        return $this
    }

    [bool]Test() {
        $NetQosDcbx = Get-NetQosDcbxSetting

        $testState = $false

        if ($this.Ensure -eq [Ensure]::Present) {
            Switch ($NetQosDcbx.Willing) {
                $true {$testState = $true}
                $false {$testState =  $false}
            }
        }
        elseif ($this.Ensure -eq [Ensure]::Absent) {
            Switch ($NetQosDcbx.Willing) {
                $true {$testState =  $false}
                $false {$testState =  $true}
            } 
        }

        Return $testState
    }

    [Void] Set() {
        if ($this.Ensure -eq [Ensure]::Present) {
            Write-Verbose "Enabling DCBX Willing bit"
            Write-Verbose "Note: DCBX is not supported on Windows Server 2016 or Windows Server 2019"
            Set-NetQosDcbxSetting -Willing $true
            Write-Verbose "DCBX Willing bit is now enabled"
            Write-Verbose "Note: DCBX is not supported on Windows Server 2016 or Windows Server 2019"
        }
        elseif ($this.Ensure -eq [Ensure]::Absent) {
            Write-Verbose "Disabling DCBX Willing bit"
            Set-NetQosDcbxSetting -Willing $false
            Write-Verbose "DCBX Willing bit is now disabled"
        }
    }
}

[DscResource()]
Class DCBNetQosPolicy {
    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    [DscProperty(Key)]
    [string] $Name

    [DscProperty(Mandatory)]
    [string] $PriorityValue8021Action

    [DscProperty()]
    [ValidateSet('Default', 'SMB', 'Cluster', 'LiveMigration')]
    [string] $Template

    [DscProperty()]
    [string] $NetDirectPortMatchCondition = 0

    [DCBNetQosPolicy] Get() {
        $NetQosPolicy = Get-NetQosPolicy -Name $this.Name -ErrorAction SilentlyContinue

        $this.Name = $NetQosPolicy.Name
        $this.PriorityValue8021Action = $NetQosPolicy.PriorityValue8021Action
        
        if ($NetQosPolicy.Template -ne 'None') { $this.Template = $NetQosPolicy.Template }
        
        if ($NetQosPolicy.NetDirectPortMatchCondition -ne '0') { 
            $this.NetDirectPortMatchCondition = $NetQosPolicy.NetDirectPortMatchCondition
        }

        return $this
    }

    [bool] Test() {
        $NetQosPolicy = Get-NetQosPolicy -Name $this.Name -ErrorAction SilentlyContinue

        $testState = $false

        If ($NetQosPolicy) {
            Switch ($this.Ensure) {
                'Present' {
                    $teststate = $true

                    If ($NetQosPolicy.PriorityValue8021Action -ne $this.PriorityValue8021Action) { $teststate = $false }

                    If ($this.Template) {
                        If ($NetQosPolicy.Template -ne $this.Template) { $teststate = $false }
                    }
                    
                    If ($this.NetDirectPortMatchCondition) {
                        If ($NetQosPolicy.NetDirectPortMatchCondition -ne $this.NetDirectPortMatchCondition) { $teststate = $false }
                    }
                }

                'Absent' { $teststate = $false }
            }
        } else {
            Switch ($this.Ensure) {
                'Present' { $teststate = $false }
                'Absent' { $teststate = $true }
            }
        }

        Return $testState
    }

    [Void] Set() {
        $NetQosPolicy = Get-NetQosPolicy -Name $this.Name -ErrorAction SilentlyContinue

        If ($NetQosPolicy) {
            Switch ($this.Ensure) {
                'Present' {
                    If ($this.PriorityValue8021Action) {
                        If ($NetQosPolicy.PriorityValue8021Action -ne $this.PriorityValue8021Action) {
                            Write-Verbose "Correcting the priority value of NetQosPolicy $($this.Name) to $($this.PriorityValue8021Action)"
                            Set-NetQosPolicy -Name $this.Name -PriorityValue8021Action $this.PriorityValue8021Action
                            Write-Verbose "Corrected the priority value of NetQosPolicy $($this.Name) to $($this.PriorityValue8021Action)"
                        }
                    }
                    
                    if ($this.NetDirectPortMatchCondition) {
                        If ($NetQosPolicy.NetDirectPortMatchCondition -ne $this.NetDirectPortMatchCondition) {
                            Write-Verbose "Correcting the NetDirectPortMatchCondition value of NetQosPolicy $($this.Name) to $($this.NetDirectPortMatchCondition)"
                            Set-NetQosPolicy -Name $this.Name -NetDirectPortMatchCondition $this.NetDirectPortMatchCondition
                            Write-Verbose "Corrected the NetDirectPortMatchCondition value of NetQosPolicy $($this.Name) to $($this.NetDirectPortMatchCondition)"
                        }
                    }

                    If ($this.Template) {
                        If ($NetQosPolicy.Template -ne $this.Template) {
                            Write-Verbose "Correcting the Template value of NetQosPolicy $($this.Name) to $($this.Template)"
                            $templateParam = @{ $this.Template = $true }
                            Set-NetQosPolicy -Name $this.Name @templateParam
                            Write-Verbose "Corrected the Template value of NetQosPolicy $($this.Name) to $($this.Template)"
                        }
                    }
                }

                'Absent' { 
                    Write-Verbose "Removing NetQosPolicy $($this.Name)"
                    Remove-NetQosPolicy -Name $this.Name
                    Write-Verbose "NetQosPolicy $($this.Name) has been removed"
                }
            }
        } else {
            if ($this.Ensure -eq [Ensure]::Present) {
                if ($this.NetDirectPortMatchCondition -ne 0) {
                    Write-Verbose "Creating NetQosPolicy $($this.Name)"
                    New-NetQosPolicy -Name $this.Name -PriorityValue8021Action $this.PriorityValue8021Action -NetDirectPortMatchCondition $this.NetDirectPortMatchCondition
                    Write-Verbose "NetQosPolicy $($this.Name) has been created"
                }
                elseif ($this.Template -ne 'None') {
                    Write-Verbose "Creating NetQosPolicy $($this.Name)"
                    $templateParam = @{ $this.Template = $true }
                    New-NetQosPolicy -Name $this.Name -PriorityValue8021Action $this.PriorityValue8021Action @templateParam
                    Write-Verbose "NetQosPolicy $($this.Name) has been created"
                }
                else { Write-Verbose 'Catastrophic Failure' }
            } 
        }
    }
}

[DscResource()]
Class DCBNetQosTrafficClass {
    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    [DscProperty(Key)]
    [string] $Name

    [DscProperty(Mandatory)]
    [string] $Priority

    [DscProperty(Mandatory)]
    [ValidateRange(1,99)]
    [string] $BandwidthPercentage

    [DscProperty(Mandatory)]
    [ValidateSet('ETS','Strict')]
    [string] $Algorithm = 'ETS'

    [DCBNetQosTrafficClass] Get() {
        $NetQosTrafficClass = Get-NetQosTrafficClass -Name $this.Name -ErrorAction SilentlyContinue

        $this.Name = $NetQosTrafficClass.Name
        $this.Priority = $NetQosTrafficClass.Priority
        $this.BandwidthPercentage = $NetQosTrafficClass.BandwidthPercentage
        $this.Algorithm = $NetQosTrafficClass.Algorithm

        return $this
    }

    [bool] Test() {
        $NetQosTrafficClass = Get-NetQosTrafficClass -Name $this.Name -ErrorAction SilentlyContinue

        $testState = $false

        If ($NetQosTrafficClass) {
            Switch ($this.Ensure.ToString()) {
                'Present' {
                    $teststate = $true
                    If ($NetQosTrafficClass.Priority -ne $this.Priority) { $teststate = $false }
                    If ($NetQosTrafficClass.BandwidthPercentage -ne $this.BandwidthPercentage) { $teststate = $false }
                    If ($NetQosTrafficClass.Algorithm -ne $this.Algorithm) { $teststate = $false }
                }

                'Absent' { $teststate = $false }
            }
        } else {
            Switch ($this.Ensure) {
                'Present' { $teststate = $false }
                'Absent' { $teststate = $true }
            }
        }

        Return $testState
    }

    [Void] Set() {
        $NetQosTrafficClass = Get-NetQosTrafficClass -Name $this.Name -ErrorAction SilentlyContinue

        If ($NetQosTrafficClass) {
            Switch ($this.Ensure) {
                'Present' {
                    If ($NetQosTrafficClass.Priority -ne $this.Priority) {
                        Write-Verbose "Correcting the priority value of NetQosTrafficClass $($this.Name) to $($this.Priority)"
                        Set-NetQosTrafficClass -Name $this.Name -Priority $this.Priority
                        Write-Verbose "Corrected the priority value of NetQosTrafficClass $($this.Name) to $($this.Priority)"
                    }

                    If ($NetQosTrafficClass.BandwidthPercentage -ne $this.BandwidthPercentage) {
                        Write-Verbose "Correcting the BandwidthPercentage value of NetQosTrafficClass $($this.Name) to $($this.BandwidthPercentage)"
                        Set-NetQosTrafficClass -Name $this.Name -BandwidthPercentage $this.BandwidthPercentage
                        Write-Verbose "Corrected the BandwidthPercentage value of NetQosTrafficClass $($this.Name) to $($this.BandwidthPercentage)"
                    }

                    If ($NetQosTrafficClass.Algorithm -ne $this.Algorithm) {
                        Write-Verbose "Correcting the Algorithm value of NetQosTrafficClass $($this.Name) to $($this.Algorithm)"
                        Set-NetQosTrafficClass -Name $this.Name -Algorithm $this.Algorithm
                        Write-Verbose "Corrected the Template value of NetQosTrafficClass $($this.Name) to $($this.Algorithm)"
                    }
                }

                'Absent' { 
                    Write-Verbose "Removing NetQosTrafficClass $($this.Name)"
                    Remove-NetQosTrafficClass -Name $this.Name
                    Write-Verbose "NetQosTrafficClass $($this.Name) has been removed"
                }
            }
        } else {
            if ($this.Ensure -eq [Ensure]::Present) {
                Write-Verbose "Creating NetQosTrafficClass $($this.Name)"
                New-NetQosTrafficClass -Name $this.Name -Priority $this.Priority -BandwidthPercentage $this.BandwidthPercentage -Algorithm $this.Algorithm
                Write-Verbose "NetQosTrafficClass $($this.Name) has been created"
            } 
        }
    }
}
