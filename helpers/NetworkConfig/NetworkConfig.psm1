<#TODO: Add check or installation of required modules
    - IovEnabled in xVMSwitch - xVMSwitch doesn't support SR-IOV
#> 

Configuration NetworkConfig {
    Import-DscResource -ModuleName PSDesiredStateConfiguration, xHyper-V, NetworkingDSC, DataCenterBridging, VMNetworkAdapter

    $configData.AllNodes.Role | Select-Object -Unique | Foreach-Object {
        $thisRole = $_
        $firstNode = ($AllNodes.Where{$_.Role -eq $thisRole} | Select-Object -First 1).NodeName

        Node "$thisRole" {
            WindowsFeature 'Data-Center-Bridging' {
                Name = 'Data-Center-Bridging'
                Ensure = 'Present'
            }
    
            0..7 | Foreach-Object {
                $thisPriority = $_
    
                If ($thisPriority -in $configData.NonNodeData.NetQos.PriorityValue8021Action -and 
                    $thisPriority -ne $configData.NonNodeData.NetQoS.Where({$_.Template -eq 'Cluster'}).PriorityValue8021Action -and
                    $thisPriority -ne 0 ) {
                    DCBNetQosFlowControl "Priority$thisPriority" {
                        Ensure = 'Present'
                        Priority = $thisPriority
                    }
                }
                Else {
                    DCBNetQosFlowControl "Priority$thisPriority" {
                        Ensure = 'Absent'
                        Priority = $thisPriority
                    }
                }
            }

            DCBNetQosDCBXSetting WillingBit { Ensure = 'Absent' }

            $configData.NonNodeData.NetQos | Foreach-Object {
                $thisPolicy = $_

                if ($thisPolicy.ContainsKey('template')) {
                    DCBNetQosPolicy $thisPolicy.Name {
                        Ensure   = 'Present'
                        Name     = $thisPolicy.Name
                        Template = $thisPolicy.template
                        PriorityValue8021Action = $thisPolicy.PriorityValue8021Action
                    }
                }
                elseif ($thisPolicy.ContainsKey('NetDirectPortMatchCondition')) {
                    DCBNetQosPolicy $thisPolicy.Name {
                        Ensure = 'Present'
                        Name   = $thisPolicy.Name
                        NetDirectPortMatchCondition = $thisPolicy.NetDirectPortMatchCondition
                        PriorityValue8021Action     = $thisPolicy.PriorityValue8021Action
                    }
                }

                if ($thisPolicy.Name -ne 'Default') {
                    DCBNetQosTrafficClass $thisPolicy.Name {
                        Ensure = 'Present'
                        Name   = $thisPolicy.Name
                        Priority = $thisPolicy.PriorityValue8021Action
                        BandwidthPercentage = $thisPolicy.BandwidthPercentage
                        Algorithm = $thisPolicy.Algorithm
                    }
                }
            }

            $RDMAEnabledAdapters = ($AllNodes.Where{$_.Role -eq $thisRole} | Select-Object -Unique).RDMAEnabledAdapters

            # Native Config
            foreach ($thisRDMAEnabledAdapter in $RDMAEnabledAdapters) {
                ###Configure VLAN on pNIC
                NetAdapterAdvancedProperty "$($thisRDMAEnabledAdapter.Name)-VLANID" {
                    NetworkAdapterName = $thisRDMAEnabledAdapter.Name
                    RegistryKeyword = 'VLANID'
                    RegistryValue = $thisRDMAEnabledAdapter.VLANID
                }

                ###Configure - JumboPacket Size
                NetAdapterAdvancedProperty "$($thisRDMAEnabledAdapter.Name)-JumboPacket" {
                    NetworkAdapterName = $thisRDMAEnabledAdapter.Name
                    RegistryKeyword = '*JumboPacket'
                    RegistryValue = $thisRDMAEnabledAdapter.JumboPacket
                }

                ###Configure - EncapOverhead
                NetAdapterAdvancedProperty "$($thisRDMAEnabledAdapter.Name)-EncapOverhead" {
                    NetworkAdapterName = $thisRDMAEnabledAdapter.Name
                    RegistryKeyword = '*EncapOverhead'
                    RegistryValue = $thisRDMAEnabledAdapter.EncapOverhead
                }

                ###Configure - Disable PacketDirect
                NetAdapterAdvancedProperty "$($thisRDMAEnabledAdapter.Name)-PacketDirect" {
                    NetworkAdapterName = $thisRDMAEnabledAdapter.Name
                    RegistryKeyword = '*PacketDirect'
                    RegistryValue = '0'   
                }

                ###Configure - Enable NetAdapterQos on thisRDMAEnabledAdapter
                DCBNetAdapterQos $thisRDMAEnabledAdapter.Name {
                    Ensure = 'Present'
                    InterfaceName = $thisRDMAEnabledAdapter.Name
                }

                ###Configure - Enable RDMA on thisRDMAEnabledAdapter
                NetAdapterRDMA $thisRDMAEnabledAdapter.Name {
                    Name = $thisRDMAEnabledAdapter.Name
                    Enabled = $true
                }
            }

            $RDMADisabledAdapters = ($AllNodes.Where{$_.Role -eq $thisRole} | Select-Object -Unique).RDMADisabledAdapters

            # Native Disabled Config
            foreach ($thisRDMADisabledAdapter in $RDMADisabledAdapters) {
                ###Configure - Disable RDMA on thisRDMAEnabledAdapter
                NetAdapterRDMA $thisRDMADisabledAdapter.Name {
                    Name = $thisRDMADisabledAdapter.Name
                    Enabled = $false
                }
            }

            $VMSwitch = ($AllNodes.Where{$_.Role -eq $thisRole} | Select-Object -Unique).VMSwitch

            # Virtual Switch Config
            foreach ($thisVMSwitch in $VMSwitch) {
                #region Resolving values for optional params
                if ($thisVMSwitch.LoadBalancingAlgorithm) { $loadBalancingAlgorithm = $thisVMSwitch.LoadBalancingAlgorithm}
                else {$loadBalancingAlgorithm = 'HyperVPort'}

                if ($thisVMSwitch.IovEnabled) { $IovEnabled = $thisVMSwitch.IovEnabled}
                else {$IovEnabled = $true}
                #endregion

                ###Configure - Create the vSwitch - 
                #TODO: Push for IovEnabled feature in resource Does not support IovEnabled currently
                xVMSwitch $thisVMSwitch.Name {
                    Ensure = 'Present'
                    Name   = $thisVMSwitch.Name
                    Type   = 'External'
                    NetAdapterName         = $thisVMSwitch.RDMAEnabledAdapters.Name
                    AllowManagementOS      = $true #Must be true; otherwise this becomes a destructive operation
                    EnableEmbeddedTeaming  = $thisVMSwitch.EmbeddedTeamingEnabled
                    LoadBalancingAlgorithm = $loadBalancingAlgorithm
                }

                ###Configure - Delete the default vNIC
                xVMNetworkAdapter $thisVMSwitch.Name {
                    Ensure = 'Absent'
                    Name = $thisVMSwitch.Name
                    ID   = $thisVMSwitch.Name
                    SwitchName = $thisVMSwitch.Name
                    VMName     = 'ManagementOS'
                    DependsOn  = "[xVMSwitch]$($thisVMSwitch.Name)"
                }

                foreach ($thisRDMAEnabledAdapter in $thisVMSwitch.RDMAEnabledAdapters) {
                    ###Configure - Create Host vNICs
                    xVMNetworkAdapter $thisRDMAEnabledAdapter.VMNetworkAdapter {
                        Ensure = 'Present'
                        Name = $thisRDMAEnabledAdapter.VMNetworkAdapter
                        ID   = $thisRDMAEnabledAdapter.VMNetworkAdapter
                        SwitchName = $thisVMSwitch.Name
                        VMName     = 'ManagementOS'
                        DependsOn  = "[xVMswitch]$($thisVMSwitch.Name)"
                    }

                    VMNetworkAdapterIsolation $thisRDMAEnabledAdapter.VMNetworkAdapter {
                        Ensure        = 'Present'
                        IsolationMode = 'Vlan'
                        AllowUntaggedTraffic = $true
                        DefaultIsolationID   = $thisRDMAEnabledAdapter.VLANID
                        VMNetworkAdapterName = $thisRDMAEnabledAdapter.VMNetworkAdapter
                        DependsOn = "[xVMNetworkAdapter]$($thisRDMAEnabledAdapter.VMNetworkAdapter)"
                    }

                    VMNetworkAdapterSettings $thisRDMAEnabledAdapter.VMNetworkAdapter {
                        VMName = 'ManagementOS'
                        VMNetworkAdapterName = $thisRDMAEnabledAdapter.VMNetworkAdapter
                        IeeePriorityTag = 'On'
                        DependsOn = "[xVMNetworkAdapter]$($thisRDMAEnabledAdapter.VMNetworkAdapter)"
                    }

                    ###Configure - Enable NetAdapterQos on thisRDMAEnabledAdapter
                    DCBNetAdapterQos $thisRDMAEnabledAdapter.Name {
                        Ensure = 'Present'
                        InterfaceName = $thisRDMAEnabledAdapter.Name
                    }

                    ###Configure - Rename NetAdapter to match vmNetworkAdapter
                    NetAdapterName $thisRDMAEnabledAdapter.VMNetworkAdapter {
                        Name = "vEthernet ($($thisRDMAEnabledAdapter.VMNetworkAdapter))"
                        NewName = "$($thisRDMAEnabledAdapter.VMNetworkAdapter)"
                        DependsOn = "[xVMNetworkAdapter]$($thisRDMAEnabledAdapter.VMNetworkAdapter)"
                    }

                    if ($IovEnabled) {
                        NetAdapterAdvancedProperty "$($thisRDMAEnabledAdapter.Name)-SRIOV" {
                            NetworkAdapterName = $thisRDMAEnabledAdapter.Name
                            RegistryKeyword = '*Sriov'
                            RegistryValue = '1'
                        }
                    }

                    ###Configure VLAN on pNIC
                    NetAdapterAdvancedProperty "$($thisRDMAEnabledAdapter.Name)-VLANID" {
                        NetworkAdapterName = $thisRDMAEnabledAdapter.Name
                        RegistryKeyword = 'VLANID'
                        RegistryValue = '0'
                    }

                    ###Configure - JumboPacket Size
                    NetAdapterAdvancedProperty "$($thisRDMAEnabledAdapter.Name)-JumboPacket" {
                        NetworkAdapterName = $thisRDMAEnabledAdapter.Name
                        RegistryKeyword = '*JumboPacket'
                        RegistryValue = $thisRDMAEnabledAdapter.JumboPacket
                    }

                    ###Configure - EncapOverhead
                    NetAdapterAdvancedProperty "$($thisRDMAEnabledAdapter.Name)-EncapOverhead" {
                        NetworkAdapterName = $thisRDMAEnabledAdapter.Name
                        RegistryKeyword = '*EncapOverhead'
                        RegistryValue = $thisRDMAEnabledAdapter.EncapOverhead
                    }

                    ###Configure - JumboPacket Size for vNIC
                    NetAdapterAdvancedProperty "$($thisRDMAEnabledAdapter.VMNetworkAdapter)-JumboPacket" {
                        NetworkAdapterName = $thisRDMAEnabledAdapter.VMNetworkAdapter
                        RegistryKeyword = '*JumboPacket'
                        RegistryValue = $thisRDMAEnabledAdapter.JumboPacket
                    }

                    ###Configure - Disable PacketDirect
                    NetAdapterAdvancedProperty "$($thisRDMAEnabledAdapter.Name)-PacketDirect" {
                        NetworkAdapterName = $thisRDMAEnabledAdapter.Name
                        RegistryKeyword = '*PacketDirect'
                        RegistryValue = '0'   
                    }

                    ###Configure - Enable RDMA on pNIC
                    NetAdapterRDMA $thisRDMAEnabledAdapter.Name {
                        Name = $thisRDMAEnabledAdapter.Name
                        Enabled = $true
                    }

                    ###Configure - Enable RDMA on vNIC
                    NetAdapterRDMA $thisRDMAEnabledAdapter.VMNetworkAdapter {
                        Name = $thisRDMAEnabledAdapter.VMNetworkAdapter
                        Enabled = $true
                    }

                    Switch (Get-NetworkIHV -NetAdapterName $thisRDMAEnabledAdapter.Name -NodeName $firstNode) {
                        'Chelsio ' { }
                        'Cavium'   { }
                        'Intel'    { }
                        'Mellanox' {
                            ###Configure - Disable miniport RSC
                            NetAdapterRsc "$($thisRDMAEnabledAdapter.Name)-RSC"{
                                Name     = $thisRDMAEnabledAdapter.Name
                                State    = $false
                                Protocol = 'All'
                            }
                        }                
                        'Broadcom' { }
                    }

                    VMNetworkAdapterTeamMapping $thisRDMAEnabledAdapter.VMNetworkAdapter {
                        Ensure = 'Present'
                        VMNetworkAdapterName = "$($thisRDMAEnabledAdapter.VMNetworkAdapter)"
                        PhysicalNetAdapterName = "$($thisRDMAEnabledAdapter.Name)"
                        DependsOn = "[xVMNetworkAdapter]$($thisRDMAEnabledAdapter.VMNetworkAdapter)", 
                                    "[VMNetworkAdapterSettings]$($thisRDMAEnabledAdapter.VMNetworkAdapter)"
                    }
                }

                ###Configure - Disabled RDMA on v or pNIC
                foreach ($thisRDMADisabledAdapter in $thisVMSwitch.RDMADisabledAdapters) {
                    if ($thisRDMADisabledAdapter.VMNetworkAdapter) {
                        ###Configure - Create RDMA Disabled Host vNICs
                        xVMNetworkAdapter $thisRDMADisabledAdapter.VMNetworkAdapter {
                            Ensure = 'Present'
                            Name = $thisRDMADisabledAdapter.VMNetworkAdapter
                            ID   = $thisRDMADisabledAdapter.VMNetworkAdapter
                            
                            SwitchName = $thisVMSwitch.Name
                            VMName     = 'ManagementOS'
                            DependsOn  = "[xVMswitch]$($thisVMSwitch.Name)"
                        }

                        ###Configure - Rename NetAdapter to match vmNetworkAdapter
                        NetAdapterName $thisRDMADisabledAdapter.VMNetworkAdapter {
                            Name = "vEthernet ($($thisRDMADisabledAdapter.VMNetworkAdapter))"
                            NewName = "$($thisRDMADisabledAdapter.VMNetworkAdapter)"
                            DependsOn = "[xVMNetworkAdapter]$($thisRDMADisabledAdapter.VMNetworkAdapter)"
                        }

                        NetAdapterRDMA $thisRDMADisabledAdapter.VMNetworkAdapter {
                            Name = $thisRDMADisabledAdapter.VMNetworkAdapter
                            Enabled = $false
                        }
                    }

                    if ($thisRDMADisabledAdapter.Name) {
                        NetAdapterRDMA $thisRDMADisabledAdapter.Name {
                            Name = $thisRDMADisabledAdapter.Name
                            Enabled = $false
                        }
                    }
                }
            }
        }
    }
}
