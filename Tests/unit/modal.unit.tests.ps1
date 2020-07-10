Describe "[Modal Unit]" -Tag Modal {
    $configData.AllNodes | ForEach-Object {
        $thisNode = $_
        $nodeName = $thisNode.NodeName

        $cfgVMSwitch = $_.VMSwitch
        $cfgRDMAEnabledAdapters  = $_.RDMAEnabledAdapters
        $cfgRDMADisabledAdapters = $_.RDMADisabledAdapters

        $AllRDMAEnabledAdapters = @()
        If ($cfgRDMAEnabledAdapters) { $AllRDMAEnabledAdapters = $cfgRDMAEnabledAdapters}
        If ($cfgVMSwitch.RDMAEnabledAdapters) { $AllRDMAEnabledAdapters += $cfgVMSwitch.RDMAEnabledAdapters}

        $NetAdapter = @()
        $NetAdapter += Get-NetAdapter -CimSession $nodeName -Name $AllRDMAEnabledAdapters.Name -ErrorAction SilentlyContinue

        $NetAdapterBinding = @()
        $NetAdapterBinding += Get-NetAdapterBinding -CimSession $nodeName -Name $AllRDMAEnabledAdapters.Name -ErrorAction SilentlyContinue

        $actNetAdapterState = @{}
        $actNetAdapterState.NetAdapter        += $netAdapter
        $actNetAdapterState.netAdapterBinding += $netAdapterBinding

        Remove-Variable -Name NetAdapter, NetAdapterBinding

        foreach ($thisRDMAEnabledAdapter in $cfgRDMAEnabledAdapters) {
            Context "[Modal Unit]-[RDMAEnabledAdapters]-[SUT: $nodeName]-Physical NetAdapter Basic Checks" {
                ### Verify the interface is enabled
                It "[SUT: $nodeName]-[RDMAEnabledAdapter: $($thisRDMAEnabledAdapter.Name)]-[Noun: NetAdapter] Interface operation status must be `"Up`"" {
                    ($actNetAdapterState.NetAdapter | Where-Object Name -eq $thisRDMAEnabledAdapter.Name).Status | Should be 'Up'
                }

                ### Verify the interface has media link
                It "[SUT: $nodeName]-[RDMAEnabledAdapter: $($thisRDMAEnabledAdapter.Name)]-[Noun: NetAdapter] Interface media state must be `"Connected`"" {
                    ($actNetAdapterState.NetAdapter | Where-Object Name -eq $thisRDMAEnabledAdapter.Name).MediaConnectionState | Should Be 'Connected'
                }

                ### Verify interface is capable of 10+ Gbps
                It "[SUT: $nodeName]-[RDMAEnabledAdapter: $($thisRDMAEnabledAdapter.Name)]-[Noun: NetAdapter] Interface must be at least 10 Gbps" {
                    # Using 9000000000 (9 Gbps) since there is no -ge for Pester 3.x
                    ($actNetAdapterState.NetAdapter | Where-Object Name -eq $thisRDMAEnabledAdapter.Name).ReceiveLinkSpeed | Should BeGreaterThan 9000000000
                }

                ### Verify interface is physical hardware
                It "[SUT: $nodeName]-[RDMAEnabledAdapter: $($thisRDMAEnabledAdapter.Name)]-[Noun: NetAdapter] Interface must be physical hardware" {
                    ($actNetAdapterState.NetAdapter | Where-Object Name -eq $thisRDMAEnabledAdapter.Name).ConnectorPresent | Should Be $true
                }

                ### Verify interface IS NOT attached to virtual switch
                It "[SUT: $nodeName]-[RDMAEnabledAdapter: $($thisRDMAEnabledAdapter.Name)]-[Noun: NetAdapterBinding] Interface must not be attached to the virtual switch" {
                    $testedBinding = ($actNetAdapterState.NetAdapterBinding | Where-Object{ $_.Name -eq $thisRDMAEnabledAdapter.Name -and $_.ComponentID -eq 'vms_pp'}).Enabled
                    $testedBinding -eq $Null -or $testedBinding -eq $false | Should be $true
                }

                ### Verify interface is NOT bound to LBFO
                It "[SUT: $nodeName]-[RDMAEnabledAdapter: $($thisRDMAEnabledAdapter.Name)]-[Noun: NetAdapterBinding] Interface should NOT be bound to the LBFO multiplexor" {
                    ($actNetAdapterState.netAdapterBinding | Where-Object{$_.Name -eq $thisRDMAEnabledAdapter.Name -and $_.ComponentID -eq 'ms_implat'}).Enabled | Should be $false
                }

                #Note: $thisDriver will be empty if using a driver that is not recognized
                $driverName = ($actNetAdapterState.NetAdapter | Where-Object Name -eq $thisRDMAEnabledAdapter.Name).DriverName.Split('\')
                $thisDriver = $configData.drivers.Where{$_.DriverFileName -eq $driverName[$driverName.Count - 1]}

                ### Verify interface is using a known adapter
                    #TODO: Update once certifications are complete
                It "[SUT: $nodeName]-[RDMAEnabledAdapter: $($thisRDMAEnabledAdapter.Name)]-[Noun: NetAdapter] Must use a certified device [e.g. Broadcom, Chelsio, Intel, Marvell (Qlogic/Cavium), Mellanox]" {
                    $thisDriver | Should not BeNullOrEmpty
                }

                ### Verify interface is using at least the recommended driver version
                It "[SUT: $nodeName]-[RDMAEnabledAdapter: $($thisRDMAEnabledAdapter.Name)]-[Noun: NetAdapter] Driver must use the recommended version ($($thisDriver.MinimumDriverVersion) or later" {
                    ($actNetAdapterState.NetAdapter | Where-Object Name -eq $thisRDMAEnabledAdapter.Name).DriverVersionString -ge $thisDriver.MinimumDriverVersion | Should be $true
                }
            }
        }

        foreach ($thisCfgVMSwitch in $cfgVMSwitch) {
            foreach ($thisRDMAEnabledAdapter in $thisCfgVMSwitch.RDMAEnabledAdapters) {
                Context "[Modal Unit]-[VMSwitch.RDMAEnabledAdapters]-[SUT: $nodeName]-Physical NetAdapter Basic Checks" {
                    ### Verify the interface is enabled
                    It "[SUT: $nodeName]-[VMSwitch: $($thisCfgVMSwitch.Name)]-[RDMAEnabledAdapter: $($thisRDMAEnabledAdapter.Name)]-[Noun: NetAdapter] Interface operation status must be `"Up`"" {
                        ($actNetAdapterState.NetAdapter | Where-Object Name -eq $thisRDMAEnabledAdapter.Name).Status | Should Be 'Up'
                    }

                    ### Verify the interface has media link
                    It "[SUT: $nodeName]-[VMSwitch: $($thisCfgVMSwitch.Name)]-[RDMAEnabledAdapter: $($thisRDMAEnabledAdapter.Name)]-[Noun: NetAdapter] Interface media state must be `"Connected`"" {
                        ($actNetAdapterState.NetAdapter | Where-Object Name -eq $thisRDMAEnabledAdapter.Name).MediaConnectionState | Should Be 'Connected'
                    }

                    ### Verify interface is capable of 10+ Gbps
                    It "[SUT: $nodeName]-[VMSwitch: $($thisCfgVMSwitch.Name)]-[RDMAEnabledAdapter: $($thisRDMAEnabledAdapter.Name)]-[Noun: NetAdapter] Interface must be at least 10 Gbps" {
                        # Using 9000000000 (9 Gbps) since there is no -ge for Pester 3.x
                        ($actNetAdapterState.NetAdapter | Where-Object Name -eq $thisRDMAEnabledAdapter.Name).ReceiveLinkSpeed | Should BeGreaterThan 9000000000
                    }

                    ### Verify interface is physical hardware
                    It "[SUT: $nodeName]-[VMSwitch: $($thisCfgVMSwitch.Name)]-[RDMAEnabledAdapter: $($thisRDMAEnabledAdapter.Name)]-[Noun: NetAdapter] Interface must be physical hardware" {
                        ($actNetAdapterState.NetAdapter | Where-Object Name -eq $thisRDMAEnabledAdapter.Name).ConnectorPresent | Should Be $true
                    }

                    ### Verify interface IS attached to virtual switch
                    It "[SUT: $nodeName]-[VMSwitch: $($thisCfgVMSwitch.Name)]-[RDMAEnabledAdapter: $($thisRDMAEnabledAdapter.Name)]-[Noun: NetAdapterBinding] Interface MUST be attached to the virtual switch" {
                        ($actNetAdapterState.NetAdapterBinding | Where-Object{ $_.Name -eq $thisRDMAEnabledAdapter.Name -and $_.ComponentID -eq 'vms_pp'}).Enabled | Should Be $true
                    }

                    ### Verify interface is NOT bound to LBFO
                    It "[SUT: $nodeName]-[VMSwitch: $($thisCfgVMSwitch.Name)]-[RDMAEnabledAdapter: $($thisRDMAEnabledAdapter.Name)]-[Noun: NetAdapterBinding] Interface must NOT be bound to the LBFO multiplexor" {
                        ($actNetAdapterState.netAdapterBinding | Where-Object{$_.Name -eq $thisRDMAEnabledAdapter.Name -and $_.ComponentID -eq 'ms_implat'}).Enabled | Should be $false
                    }

                    ### Verify interface is NOT bound to TCP/IP v4
                    It "[SUT: $nodeName]-[VMSwitch: $($thisCfgVMSwitch.Name)]-[RDMAEnabledAdapter: $($thisRDMAEnabledAdapter.Name)]-[Noun: NetAdapterBinding] Interface must NOT be bound to TCP/IP v4" {
                        ($actNetAdapterState.netAdapterBinding | Where-Object{$_.Name -eq $thisRDMAEnabledAdapter.Name -and $_.ComponentID -eq 'ms_tcpip'}).Enabled | Should be $false
                    }

                    ### Verify interface is NOT bound to TCP/IP v6
                    It "[SUT: $nodeName]-[VMSwitch: $($thisCfgVMSwitch.Name)]-[RDMAEnabledAdapter: $($thisRDMAEnabledAdapter.Name)]-[Noun: NetAdapterBinding] Interface must NOT be bound to TCP/IP v6" {
                        ($actNetAdapterState.netAdapterBinding | Where-Object{$_.Name -eq $thisRDMAEnabledAdapter.Name -and $_.ComponentID -eq 'ms_tcpip6'}).Enabled | Should be $false
                    }

                    ### Verify interface is NOT bound to Client for Microsoft Networks
                    It "[SUT: $nodeName]-[VMSwitch: $($thisCfgVMSwitch.Name)]-[RDMAEnabledAdapter: $($thisRDMAEnabledAdapter.Name)]-[Noun: NetAdapterBinding] Interface must NOT be bound to Client for MS Networks" {
                        ($actNetAdapterState.netAdapterBinding | Where-Object{$_.Name -eq $thisRDMAEnabledAdapter.Name -and $_.ComponentID -eq 'ms_msclient'}).Enabled | Should be $false
                    }

                    #Note: $thisDriver will be empty if using a driver that is not recognized
                    $driverName = ($actNetAdapterState.NetAdapter | Where-Object Name -eq $thisRDMAEnabledAdapter.Name).DriverName.Split('\')
                    $thisDriver = $configData.drivers.Where{$_.DriverFileName -eq $driverName[$driverName.Count - 1]}

                    ### Verify interface is using a known adapter
                        #TODO: Update once certifications are complete
                    It "[SUT: $nodeName]-[VMSwitch: $($thisCfgVMSwitch.Name)]-[RDMAEnabledAdapter: $($thisRDMAEnabledAdapter.Name)]-[Noun: NetAdapter] Must use a known device [e.g. Broadcom, Chelsio, Intel, Marvell (Qlogic/Cavium), Mellanox]" {
                        $thisDriver | Should not BeNullOrEmpty
                    }

                    ### Verify interface is using at least the recommended driver version
                    It "[SUT: $nodeName]-[VMSwitch: $($thisCfgVMSwitch.Name)]-[RDMAEnabledAdapter: $($thisRDMAEnabledAdapter.Name)]-[Noun: NetAdapter] Driver must use the recommended version ($($thisDriver.MinimumDriverVersion)) or later" {
                        ($actNetAdapterState.NetAdapter | Where-Object Name -eq $thisRDMAEnabledAdapter.Name).DriverVersionString -ge $thisDriver.MinimumDriverVersion | Should be $true
                    }
                }
            }
        }

        $netAdapterAdvancedProperty = @()
        $netAdapterAdvancedProperty += Get-NetAdapterAdvancedProperty -CimSession $nodeName -Name $AllRDMAEnabledAdapters.Name -ErrorAction SilentlyContinue

        $actNetAdapterState.netAdapterAdvancedProperty = $netAdapterAdvancedProperty

        Remove-Variable -Name netAdapterAdvancedProperty

        #Note: $thisDriver will be empty if using a driver that is not recognized
        $driverName = ($actNetAdapterState.NetAdapter | Where-Object Name -eq $thisRDMAEnabledAdapter.Name).DriverName.Split('\')
        $thisIHV = $configData.drivers.Where{$_.DriverFileName -eq $driverName[$driverName.Count - 1]}.IHV

        foreach ($thisRDMAEnabledAdapter in $cfgRDMAEnabledAdapters) {
            Context "[Modal Unit]-[RDMAEnabledAdapters]-[SUT: $nodeName]-Physical NetAdapter Advanced Property Settings" {
                ### Verify Interface is RDMA Capable (includes the *NetworkDirect Keyword)
                It "[SUT: $nodeName]-[RDMAEnabledAdapter: $($thisRDMAEnabledAdapter.Name)]-[Noun: NetAdapterAdvancedProperty] should be NetworkDirect (RDMA) capable" {
                    $actNetAdapterState.netAdapterAdvancedProperty | Where-Object{$_.Name -eq $thisRDMAEnabledAdapter.Name -and $_.RegistryKeyword -eq '*NetworkDirect'} | Should Not BeNullOrEmpty
                }

                ### Verify Interface is RDMA Enabled
                It "[SUT: $nodeName]-[RDMAEnabledAdapter: $($thisRDMAEnabledAdapter.Name)]-[Noun: NetAdapterAdvancedProperty] should have NetworkDirect (RDMA) Enabled" {
                    ($actNetAdapterState.netAdapterAdvancedProperty | Where-Object{$_.Name -eq $thisRDMAEnabledAdapter.Name -and $_.RegistryKeyword -eq '*NetworkDirect'}).DisplayValue | Should Be 'Enabled'
                }

                ### Verify Interface has a VLAN assigned - These NICs are native adapters (no VMSwitch attached)
                It "[SUT: $nodeName]-[RDMAEnabledAdapter: $($thisRDMAEnabledAdapter.Name)]-[Noun: NetAdapterAdvancedProperty] should have VLAN $($thisRDMAEnabledAdapter.VLANID) assigned" {
                    ($actNetAdapterState.netAdapterAdvancedProperty | Where-Object{$_.Name -eq $thisRDMAEnabledAdapter.Name -and $_.RegistryKeyword -eq 'VLANID'}).RegistryValue | Should Be $thisRDMAEnabledAdapter.VLANID
                }

                ### Verify if JumboPackets are specified in the config file that they are set properly on the interfaces
                If ($thisRDMAEnabledAdapter.JumboPacket) {
                    It "[SUT: $nodeName]-[RDMAEnabledAdapter: $($thisRDMAEnabledAdapter.Name)]-[Noun: NetAdapterAdvancedProperty] should have Jumbo Packet set to [$($thisRDMAEnabledAdapter.JumboPacket)]" {
                        ($actNetAdapterState.netAdapterAdvancedProperty | Where-Object{$_.Name -eq $thisRDMAEnabledAdapter.Name -and $_.RegistryKeyword -eq '*JumboPacket'}).RegistryValue | Should Be $thisRDMAEnabledAdapter.JumboPacket
                    }
                }
                ### Verify if EncapOverhead is specified in the config file that they are set properly on the interfaces
                If ($thisRDMAEnabledAdapter.EncapOverhead) {
                    It "[SUT: $nodeName]-[RDMAEnabledAdapter: $($thisRDMAEnabledAdapter.Name)]-[Noun: NetAdapterAdvancedProperty] should have EncapOverhead set to [$($thisRDMAEnabledAdapter.EncapOverhead)]" {
                        ($actNetAdapterState.netAdapterAdvancedProperty | Where-Object{$_.Name -eq $thisRDMAEnabledAdapter.Name -and $_.RegistryKeyword -eq '*EncapOverhead'}).RegistryValue | Should Be $thisRDMAEnabledAdapter.EncapOverhead
                    }
                }

                Switch -wildCard ($thisIHV) {
                    'Chelsio ' {
                        #Test for NetworkDirectTechnology - Adapter must specify iWARP
                        It "[SUT: $nodeName]-[Adapter: $($thisRDMAEnabledAdapter.Name)]-(Noun: NetAdapterAdvancedProperty) Network Direct Technology must be '1' (iWARP) on Chelsio adapters" {
                            (($actNetAdapterState.netAdapterAdvancedProperty | Where-Object Name -eq $thisRDMAEnabledAdapter.Name) | Where-Object RegistryKeyword -eq '*NetworkDirectTechnology').RegistryValue | Should Be 1
                        }
                    }

                    'Marvell'   {
                        #Test for NetworkDirectTechnology - As they support multiple options, we test that the system specifies iWARP or RoCEv2
                        It "[SUT: $nodeName]-[Adapter: $($thisRDMAEnabledAdapter.Name)]-(Noun: NetAdapterAdvancedProperty) Network Direct Technology must be '1'(iWARP) or '4' (RoCEv2) on Marvell/Cavium adapters" {
                            $NetworkDirectTechnologyValue = (($actNetAdapterState.netAdapterAdvancedProperty | Where-Object Name -eq $thisRDMAEnabledAdapter.Name) | Where-Object RegistryKeyword -eq '*NetworkDirectTechnology').RegistryValue
                            $NetworkDirectTechnologyValue -eq 1 -or $NetworkDirectTechnologyValue -eq 4 | Should be $true
                        }
                    }

                    'Intel'    {
                        #Test for NetworkDirectTechnology - Adapter must specify iWARP
                        It "[SUT: $nodeName]-[Adapter: $($thisRDMAEnabledAdapter.Name)]-(Noun: NetAdapterAdvancedProperty) Network Direct Technology must be '1' (iWARP) on Intel adapters" {
                            (($actNetAdapterState.netAdapterAdvancedProperty | Where-Object Name -eq $thisRDMAEnabledAdapter.Name) | Where-Object RegistryKeyword -eq '*NetworkDirectTechnology').RegistryValue | Should Be 1
                        }
                    }

                    'Mellanox' {
                        If ($driverName[$driverName.Count - 1] -like 'mlx4*') {
                            It "[SUT: $nodeName]-[Adapter: $($thisRDMAEnabledAdapter.Name)]-(Noun: NetAdapterAdvancedProperty) Miniport IPv4 RSC should be disabled" {
                                (($actNetAdapterState.netAdapterAdvancedProperty | Where-Object Name -eq $thisRDMAEnabledAdapter.Name) | Where-Object RegistryKeyword -eq '*RscIPv4').RegistryValue | Should Be 0
                            }

                            It "[SUT: $nodeName]-[Adapter: $($thisRDMAEnabledAdapter.Name)]-(Noun: NetAdapterAdvancedProperty) Miniport IPv6 RSC should be disabled" {
                                (($actNetAdapterState.netAdapterAdvancedProperty | Where-Object Name -eq $thisRDMAEnabledAdapter.Name) | Where-Object RegistryKeyword -eq '*RscIPv6').RegistryValue | Should Be 0
                            }
                        }
                        Else {
                            #Test for NetworkDirectTechnology - Adapter must specify RoCEv2
                            It "[SUT: $nodeName]-[Adapter: $($thisRDMAEnabledAdapter.Name)]-(Noun: NetAdapterAdvancedProperty) Network Direct Technology must be '4' (RoCEv2) on Mellanox adapters" {
                                (($actNetAdapterState.netAdapterAdvancedProperty | Where-Object Name -eq $thisRDMAEnabledAdapter.Name) | Where-Object RegistryKeyword -eq '*NetworkDirectTechnology').RegistryValue | Should Be 4
                            }
                        }

                        $thisInterfaceDescription = ($actNetAdapterState.netAdapter | Where-Object Name -eq $thisRDMAEnabledAdapter.Name).InterfaceDescription
                        $lastBoot = Get-WinEvent -ComputerName $nodeName -LogName System -MaxEvents 1 -FilterXPath "*[System[Provider[@Name='eventlog'] and (Level=4 or Level=0) and (EventID=6005)]]"

                        Try {
                            # To get all events for testing (not just last boot) remove the TimeCreated in the FilterHashtable
                            $FWEvent = Get-WinEvent -ComputerName $nodeName -FilterHashTable @{LogName="System"; TimeCreated=$lastboot.TimeCreated; ID = 263; ProviderName = 'mlx5'} -ErrorAction SilentlyContinue
                            $thisFWEvent = $FWEvent | Where-Object Message -like "$thisInterfaceDescription Firmware version*"
                            $XMLFWEvent = [xml]$thisFWEvent[0].ToXml()

                            $FWIndexStart = (0..($XMLFWEvent.Event.EventData.Data.Count - 1) | Where-Object { $XMLFWEvent.Event.EventData.Data[$_] -eq $thisInterfaceDescription }) + 1
                            $FWIndexEnd   = $XMLFWEvent.Event.EventData.Data.Count - 2
                            $FWIndexMid   = ($FWIndexStart..($FWIndexEnd)).Count / 2

                            $actFWVersion = $null
                            $recFWVersion = $null

                            $XMLFWEvent.Event.EventData.Data[$FWIndexStart..($FWIndexStart + $FWIndexMid - 1)] | ForEach-Object {
                                $actFWVersion += $_ + "."
                            }

                            $XMLFWEvent.Event.EventData.Data[($FWIndexStart + $FWIndexMid)..$FWIndexEnd] | ForEach-Object {
                                $recFWVersion += $_ + "."
                            }

                            # Regex replace for last character (extra period)
                            $actualFWVersion = [string]::Concat($actFWVersion) -replace ".$"
                            $recommendedFWVersion = [string]::Concat($recFWVersion) -replace ".$"

                            Remove-Variable -Name actFWVersion, recFWVersion

                            $interfaceIndex = (0..($XMLFWEvent.Event.EventData.Data.Count - 1) | Where-Object { $XMLFWEvent.Event.EventData.Data[$_] -eq $thisInterfaceDescription })

                            If ($XMLFWEvent.Event.EventData.Data[$interfaceIndex]) {
                                It "[SUT: $nodeName]-[Adapter: $($thisRDMAEnabledAdapter.Name)]-[Log: System; EventID: 263] Should have the recommended firmware version for this driver" {
                                    $actualFWVersion | Should be $recommendedFWVersion
                                }
                            }
                        }
                        Catch {
                            # If you entered here, then there are no events within the last boot time
                            It "[SUT: $nodeName]-[Adapter: $($thisRDMAEnabledAdapter.Name)]-[Log: System; EventID: 263] Should not report a driver/firmware mismatch warning (MLX5 Event: 263)" {
                                $true | Should be $true
                            }
                        }
                    }

                    'Broadcom' {
                        #Test for NetworkDirectTechnology - Adapter must specify RoCEv2
                        It "[SUT: $nodeName]-[Adapter: $($thisRDMAEnabledAdapter.Name)]-(Noun: NetAdapterAdvancedProperty) Network Direct Technology must be '4' (RoCEv2) on Broadcom adapters" {
                            (($actNetAdapterState.netAdapterAdvancedProperty | Where-Object Name -eq $thisRDMAEnabledAdapter.Name) | Where-Object RegistryKeyword -eq '*NetworkDirectTechnology').RegistryValue | Should Be 4
                        }
                    }

                    '*' {
                        # Tests for all IHVs
                    }

                    'Default' {
                        It 'Hardware Vendor for Adapter not Identified' { $false | Should be $true }
                    }
                }
            }
        }

        foreach ($thisCfgVMSwitch in $cfgVMSwitch) {
            foreach ($thisRDMAEnabledAdapter in $cfgVMSwitch.RDMAEnabledAdapters) {
                Context "[Modal Unit]-[VMSwitch.RDMAEnabledAdapters]-[SUT: $nodeName]-Physical NetAdapter Advanced Property Settings" {
                    ### Verify Interface is RDMA Capable (includes the *NetworkDirect Keyword)
                    It "[SUT: $nodeName]-[VMSwitch: $($thisCfgVMSwitch.Name)]-[RDMAEnabledAdapter: $($thisRDMAEnabledAdapter.Name)]-[Noun: NetAdapterAdvancedProperty] should be NetworkDirect (RDMA) capable" {
                        $actNetAdapterState.netAdapterAdvancedProperty | Where-Object{$_.Name -eq $thisRDMAEnabledAdapter.Name -and $_.RegistryKeyword -eq '*NetworkDirect'} | Should Not BeNullOrEmpty
                    }

                    ### Verify Interface is RDMA Enabled
                    It "[SUT: $nodeName]-[VMSwitch: $($thisCfgVMSwitch.Name)]-[RDMAEnabledAdapter: $($thisRDMAEnabledAdapter.Name)]-[Noun: NetAdapterAdvancedProperty] should have NetworkDirect (RDMA) Enabled" {
                        ($actNetAdapterState.netAdapterAdvancedProperty | Where-Object{$_.Name -eq $thisRDMAEnabledAdapter.Name -and $_.RegistryKeyword -eq '*NetworkDirect'}).DisplayValue | Should Be 'Enabled'
                    }

                    ### Verify Interface has a VLAN of 0 - These NICs are attached to a VMSwitch attached, so vNICs will have the VLANID
                    It "[SUT: $nodeName]-[VMSwitch: $($thisCfgVMSwitch.Name)]-[RDMAEnabledAdapter: $($thisRDMAEnabledAdapter.Name)]-[Noun: NetAdapterAdvancedProperty] should have VLAN '0' assigned" {
                        ($actNetAdapterState.netAdapterAdvancedProperty | Where-Object{$_.Name -eq $thisRDMAEnabledAdapter.Name -and $_.RegistryKeyword -eq 'VLANID'}).RegistryValue | Should Be 0
                    }

                    ### Verify if JumboPackets are specified in the config file that they are set properly on the interfaces
                    If ($thisRDMAEnabledAdapter.JumboPacket) {
                        It "[SUT: $nodeName]-[VMSwitch: $($thisCfgVMSwitch.Name)]-[RDMAEnabledAdapter: $($thisRDMAEnabledAdapter.Name)]-[Noun: NetAdapterAdvancedProperty] should have Jumbo Packet set to [$($thisRDMAEnabledAdapter.JumboPacket)]" {
                            ($actNetAdapterState.netAdapterAdvancedProperty | Where-Object{$_.Name -eq $thisRDMAEnabledAdapter.Name -and $_.RegistryKeyword -eq '*JumboPacket'}).RegistryValue | Should Be $thisRDMAEnabledAdapter.JumboPacket
                        }
                    }
                    ### Verify if EncapOverhead is specified in the config file that they are set properly on the interfaces
                    If ($thisRDMAEnabledAdapter.EncapOverhead) {
                        It "[SUT: $nodeName]-[VMSwitch: $($thisCfgVMSwitch.Name)]-[RDMAEnabledAdapter: $($thisRDMAEnabledAdapter.Name)]-[Noun: NetAdapterAdvancedProperty] should have EncapOverhead set to [$($thisRDMAEnabledAdapter.EncapOverhead)]" {
                            ($actNetAdapterState.netAdapterAdvancedProperty | Where-Object{$_.Name -eq $thisRDMAEnabledAdapter.Name -and $_.RegistryKeyword -eq '*EncapOverhead'}).RegistryValue | Should Be $thisRDMAEnabledAdapter.EncapOverhead
                        }
                    }

                    Switch -wildCard ($thisIHV) {
                        'Chelsio ' {
                            #Test for NetworkDirectTechnology - Adapter must specify iWARP
                            It "[SUT: $nodeName]-[Adapter: $($thisRDMAEnabledAdapter.Name)]-(Noun: NetAdapterAdvancedProperty) Network Direct Technology must be '1' (iWARP) on Chelsio adapters" {
                                (($actNetAdapterState.netAdapterAdvancedProperty | Where-Object Name -eq $thisRDMAEnabledAdapter.Name) | Where-Object RegistryKeyword -eq '*NetworkDirectTechnology').RegistryValue | Should Be 1
                            }
                        }

                        'Marvell'   {
                            #Test for NetworkDirectTechnology - As they support multiple options, we test that the system specifies iWARP or RoCEv2
                            It "[SUT: $nodeName]-[Adapter: $($thisRDMAEnabledAdapter.Name)]-(Noun: NetAdapterAdvancedProperty) Network Direct Technology must be '1'(iWARP) or '4' (RoCEv2) on Marvell/Cavium adapters" {
                                $NetworkDirectTechnologyValue = (($actNetAdapterState.netAdapterAdvancedProperty | Where-Object Name -eq $thisRDMAEnabledAdapter.Name) | Where-Object RegistryKeyword -eq '*NetworkDirectTechnology').RegistryValue
                                $NetworkDirectTechnologyValue -eq 1 -or $NetworkDirectTechnologyValue -eq 4 | Should be $true
                            }
                        }

                        'Intel'    {
                            #Test for NetworkDirectTechnology - Adapter must specify iWARP
                            It "[SUT: $nodeName]-[Adapter: $($thisRDMAEnabledAdapter.Name)]-(Noun: NetAdapterAdvancedProperty) Network Direct Technology must be '1' (iWARP) on Intel adapters" {
                                (($actNetAdapterState.netAdapterAdvancedProperty | Where-Object Name -eq $thisRDMAEnabledAdapter.Name) | Where-Object RegistryKeyword -eq '*NetworkDirectTechnology').RegistryValue | Should Be 1
                            }
                        }

                        'Mellanox' {
                            If ($driverName[$driverName.Count - 1] -like 'mlx4*') {
                                It "[SUT: $nodeName]-[Adapter: $($thisRDMAEnabledAdapter.Name)]-(Noun: NetAdapterAdvancedProperty) Miniport IPv4 RSC should be disabled" {
                                    (($actNetAdapterState.netAdapterAdvancedProperty | Where-Object Name -eq $thisRDMAEnabledAdapter.Name) | Where-Object RegistryKeyword -eq '*RscIPv4').RegistryValue | Should Be 0
                                }

                                It "[SUT: $nodeName]-[Adapter: $($thisRDMAEnabledAdapter.Name)]-(Noun: NetAdapterAdvancedProperty) Miniport IPv6 RSC should be disabled" {
                                    (($actNetAdapterState.netAdapterAdvancedProperty | Where-Object Name -eq $thisRDMAEnabledAdapter.Name) | Where-Object RegistryKeyword -eq '*RscIPv6').RegistryValue | Should Be 0
                                }
                            }
                            Else {
                                #Test for NetworkDirectTechnology - Adapter must specify RoCEv2
                                It "[SUT: $nodeName]-[Adapter: $($thisRDMAEnabledAdapter.Name)]-(Noun: NetAdapterAdvancedProperty) Network Direct Technology must be '4' (RoCEv2) on Mellanox adapters" {
                                    (($actNetAdapterState.netAdapterAdvancedProperty | Where-Object Name -eq $thisRDMAEnabledAdapter.Name) | Where-Object RegistryKeyword -eq '*NetworkDirectTechnology').RegistryValue | Should Be 4
                                }
                            }

                            $thisInterfaceDescription = ($actNetAdapterState.netAdapter | Where-Object Name -eq $thisRDMAEnabledAdapter.Name).InterfaceDescription
                            $lastBoot = Get-WinEvent -ComputerName $nodeName -LogName System -MaxEvents 1 -FilterXPath "*[System[Provider[@Name='eventlog'] and (Level=4 or Level=0) and (EventID=6005)]]"

                            Try {
                                # To get all events for testing (not just last boot) remove the TimeCreated in the FilterHashtable
                                $FWEvent = Get-WinEvent -ComputerName $nodeName -FilterHashTable @{LogName="System"; TimeCreated=$lastboot.TimeCreated; ID = 263; ProviderName = 'mlx5'} -ErrorAction SilentlyContinue
                                $thisFWEvent = $FWEvent | Where-Object Message -like "$thisInterfaceDescription Firmware version*"
                                $XMLFWEvent = [xml]$thisFWEvent[0].ToXml()

                                $FWIndexStart = (0..($XMLFWEvent.Event.EventData.Data.Count - 1) | Where-Object { $XMLFWEvent.Event.EventData.Data[$_] -eq $thisInterfaceDescription }) + 1
                                $FWIndexEnd   = $XMLFWEvent.Event.EventData.Data.Count - 2
                                $FWIndexMid   = ($FWIndexStart..($FWIndexEnd)).Count / 2

                                $actFWVersion = $null
                                $recFWVersion = $null

                                $XMLFWEvent.Event.EventData.Data[$FWIndexStart..($FWIndexStart + $FWIndexMid - 1)] | ForEach-Object {
                                    $actFWVersion += $_ + "."
                                }

                                $XMLFWEvent.Event.EventData.Data[($FWIndexStart + $FWIndexMid)..$FWIndexEnd] | ForEach-Object {
                                    $recFWVersion += $_ + "."
                                }

                                # Regex replace for last character (extra period)
                                $actualFWVersion = [string]::Concat($actFWVersion) -replace ".$"
                                $recommendedFWVersion = [string]::Concat($recFWVersion) -replace ".$"

                                Remove-Variable -Name actFWVersion, recFWVersion

                                $interfaceIndex = (0..($XMLFWEvent.Event.EventData.Data.Count - 1) | Where-Object { $XMLFWEvent.Event.EventData.Data[$_] -eq $thisInterfaceDescription })

                                If ($XMLFWEvent.Event.EventData.Data[$interfaceIndex]) {
                                    It "[SUT: $nodeName]-[Adapter: $($thisRDMAEnabledAdapter.Name)]-[Log: System; EventID: 263] Should have the recommended firmware version for this driver" {
                                        $actualFWVersion | Should be $recommendedFWVersion
                                    }
                                }
                            }
                            Catch {
                                # If you entered here, then there are no events within the last boot time
                                It "[SUT: $nodeName]-[Adapter: $($thisRDMAEnabledAdapter.Name)]-[Log: System; EventID: 263] Should not report a driver/firmware mismatch warning (MLX5 Event: 263)" {
                                    $true | Should be $true
                                }
                            }
                        }

                        'Broadcom' {
                            #Test for NetworkDirectTechnology - Adapter must specify RoCEv2
                            It "[SUT: $nodeName]-[Adapter: $($thisRDMAEnabledAdapter.Name)]-(Noun: NetAdapterAdvancedProperty) Network Direct Technology must be '4' (RoCEv2) on Broadcom adapters" {
                                (($actNetAdapterState.netAdapterAdvancedProperty | Where-Object Name -eq $thisRDMAEnabledAdapter.Name) | Where-Object RegistryKeyword -eq '*NetworkDirectTechnology').RegistryValue | Should Be 4
                            }
                        }

                        '*' {
                            # Tests for all IHVs
                        }

                        'Default' {
                            It 'Hardware Vendor for Adapter not Identified' { $false | Should be $true }
                        }
                    }
                }
            }
        }

        # No Disabled Adapters need to be specified, so only run this if there are disabled adapters
        If ($cfgRDMADisabledAdapters.Name -or $cfgVMSwitch.RDMADisabledAdapters.Name) {
            $DisabledNetAdapterAdvancedProperty = @()
            $DisabledNetAdapterAdvancedProperty += Get-NetAdapterAdvancedProperty -CimSession $nodeName -Name $cfgRDMADisabledAdapters.Name, $cfgVMSwitch.RDMADisabledAdapters.Name -ErrorAction SilentlyContinue

            $actNetAdapterState.DisabledNetAdapterAdvancedProperty = $DisabledNetAdapterAdvancedProperty

            Remove-Variable DisabledNetAdapterAdvancedProperty

            #TODO: Make sure this works with multiple vmswitch.adapters
            Context "[Modal Unit]-[DisabledAdapters]-[SUT: $nodeName]-RDMA Disabled Physical NetAdapter" {
                foreach ($thisRDMADisabledAdapter in $cfgRDMADisabledAdapters.Name) {
                    ### Verify RDMA is disabled or not capable on this adapter
                    It "[SUT: $nodeName]-[RDMADisabledAdapter: $($thisRDMAEnabledAdapter.Name)]-[Noun: NetAdapterAdvancedProperty] should have NetworkDirect (RDMA) Disabled" {
                        ($actNetAdapterState.DisabledNetAdapterAdvancedProperty | Where-Object{$_.Name -eq $thisRDMADisabledAdapter.Name -and $_.RegistryKeyword -eq '*NetworkDirect'}).DisplayValue | Should Not Be 'Enabled'
                    }
                }

                foreach ($thisRDMADisabledAdapter in $cfgVMSwitch.RDMADisabledAdapters.Name) {
                    ### Verify RDMA is disabled or not capable on this adapter
                    It "[SUT: $nodeName]-[VMSwitch.RDMADisabledAdapter: $($thisRDMAEnabledAdapter)]-[Noun: NetAdapterAdvancedProperty] should have NetworkDirect (RDMA) Disabled" {
                        ($actNetAdapterState.DisabledNetAdapterAdvancedProperty | Where-Object{$_.Name -eq $thisRDMADisabledAdapter -and $_.RegistryKeyword -eq '*NetworkDirect'}).DisplayValue | Should Not Be 'Enabled'
                    }
                }

                foreach ($thisRDMADisabledAdapter in $cfgVMSwitch.RDMADisabledAdapters.VMNetworkAdapter) {
                    ### Verify RDMA is disabled on this VMNetworkAdapter adapter
                    It "[SUT: $nodeName]-[VMSwitch.RDMADisabledAdapter: $($thisRDMAEnabledAdapter)]-[Noun: NetAdapterAdvancedProperty] should have NetworkDirect (RDMA) Disabled" {
                        ($actNetAdapterState.DisabledNetAdapterAdvancedProperty | Where-Object{$_.Name -eq $thisRDMADisabledAdapter -and $_.RegistryKeyword -eq '*NetworkDirect'}).DisplayValue | Should Not Be 'Enabled'
                    }
                }
            }
        }

        Context "[Modal Unit]-[NetQos]-[SUT: $nodeName]-NetQos Settings" {
            $NetQosPolicy       = Get-NetQosPolicy       -CimSession $nodeName -ErrorAction SilentlyContinue
            $NetAdapterQos      = Get-NetAdapterQos      -CimSession $nodeName -ErrorAction SilentlyContinue
            $NetQosFlowControl  = Get-NetQosFlowControl  -CimSession $nodeName -ErrorAction SilentlyContinue
            $NetQosTrafficClass = Get-NetQosTrafficClass -CimSession $nodeName -ErrorAction SilentlyContinue

            $NetQosDcbxSettingInterfaces = @()
            $AllRDMAEnabledAdapters.Name | ForEach-Object {
                $NetQosDcbxSettingInterfaces  += Get-NetQosDcbxSetting -InterfaceAlias $_ -CimSession $nodeName -ErrorAction SilentlyContinue
            }

            $actNetQoSState = @{}
            $actNetQoSState.NetQoSPolicy       = $NetQosPolicy
            $actNetQoSState.NetAdapterQos      = $NetAdapterQos
            $actNetQoSState.NetQoSFlowControl  = $NetQosFlowControl
            $actNetQoSState.NetQosTrafficClass = $NetQosTrafficClass
            $actNetQoSState.NetQosDcbxSettingInterfaces = $NetQosDcbxSettingInterfaces

            Remove-Variable -Name NetQosPolicy, NetAdapterQos, NetQosFlowControl, NetQosTrafficClass, NetQosDcbxSettingInterfaces

            foreach ($thisPolicy in $configData.NonNodeData.NetQoS) {
                ### Verify this NetQos Policy exists
                It "[SUT: $nodeName]-[NetQos: $($thisPolicy.Name)]-[Noun: NetQosPolicy] should have a NetQos policy named ($($thisPolicy.Name)) assigned" {
                    $actNetQoSState.NetQoSPolicy.Name -contains $($thisPolicy.Name) | Should Be $true
                }

                If ($thisPolicy.Template) {
                    ### Verify this NetQos policy uses the specified template
                    It "[SUT: $nodeName]-[NetQos: $($thisPolicy.Name)]-[Noun: NetQosPolicy] The NetQos policy named ($($thisPolicy.Name)) should be the ($($thisPolicy.Name)) template" {
                        ($actNetQoSState.NetQoSPolicy | Where-Object Name -eq $thisPolicy.Name).Template | Should Be $thisPolicy.Template
                    }
                }
                elseif ($thisPolicy.NetDirectPortMatchCondition) {
                    ### Verify this NetQos policy uses the specified NetDirectPortMatchCondition
                    It "[SUT: $nodeName]-[NetQos: $($thisPolicy.Name)]-[Noun: NetQosPolicy] The NetQos policy named ($($thisPolicy.Name)) should be assigned port ($($thisPolicy.NetDirectPortMatchCondition))" {
                        ($actNetQoSState.NetQoSPolicy | Where-Object Name -eq $thisPolicy.Name).NetDirectPortMatchCondition | Should Be $thisPolicy.NetDirectPortMatchCondition
                    }
                }

                ### Verify this NetQos policy is the specified priority
                It "[SUT: $nodeName]-[NetQos: $($thisPolicy.Name)]-[Noun: NetQosPolicy] The NetQos policy named ($($thisPolicy.Name)) should be priority ($($thisPolicy.PriorityValue8021Action))" {
                    ($actNetQoSState.NetQoSPolicy | Where-Object Name -eq $thisPolicy.Name).PriorityValue8021Action | Should Be $thisPolicy.PriorityValue8021Action
                }

                #TODO: Check that Default and Cluster FlowControl is disabled
                If ( $($thisPolicy.template) -notlike 'Default' -and $($thisPolicy.template) -notlike 'Cluster' ) {
                    ### Verify the NetQos Priority is Enabled for lossless TCs
                    It "[SUT: $nodeName]-[NetQos: $($thisPolicy.Name)]-[Noun: NetQoSFlowControl] The NetQoS priority ($($thisPolicy.PriorityValue8021Action)) for policy ($($thisPolicy.Name)) should be enabled" {
                        ($actNetQoSState.NetQoSFlowControl | Where-Object Priority -eq $thisPolicy.PriorityValue8021Action).Enabled | Should Be $true
                    }
                }

                If (( $($thisPolicy.Name) -like '*default*' )) {
                    ### Verify Should have the specified traffic class
                    It "[SUT: $nodeName]-[NetQos: $($thisPolicy.Name)]-[Noun: NetQosTrafficClass] Should have a traffic class named '[$($thisPolicy.Name)]'" {
                        $actNetQoSState.NetQosTrafficClass.Name -contains "[$($thisPolicy.Name)]" | Should Be $true
                    }

                    ### Verify this traffic class is the expected BandwidthPercentage
                    It "[SUT: $nodeName]-[NetQos: $($thisPolicy.Name)]-[Noun: NetQosTrafficClass] The traffic class named '[$($thisPolicy.Name)]' should have a bandwidth percentage of ($($thisPolicy.BandwidthPercentage))" {
                        ($actNetQoSState.NetQosTrafficClass | Where-Object Name -Like '*default*').BandwidthPercentage | Should Be $thisPolicy.BandwidthPercentage
                    }

                    ### Verify this traffic class is the expected Algorithm
                    It "[SUT: $nodeName]-[NetQos: $($thisPolicy.Name)]-[Noun: NetQosTrafficClass] The traffic class named '[$($thisPolicy.Name)]' should have an algorithm of ($($thisPolicy.Algorithm))" {
                        ($actNetQoSState.NetQosTrafficClass | Where-Object Name -Like '*default*').Algorithm | Should Be $thisPolicy.Algorithm
                    }
                }
                Else {
                    ### Verify Should have the specified traffic class
                    It "[SUT: $nodeName]-[NetQos: $($thisPolicy.Name)]-[Noun: NetQosTrafficClass] Should have a traffic class named ($($thisPolicy.Name))" {
                        $actNetQoSState.NetQosTrafficClass.Name -contains "$($thisPolicy.Name)" | Should Be $true
                    }

                    ### Verify This traffic class is the expected priority
                    It "[SUT: $nodeName]-[NetQos: $($thisPolicy.Name)]-[Noun: NetQosTrafficClass] The traffic class named ($($thisPolicy.Name)) should be priority ($($thisPolicy.PriorityValue8021Action))" {
                        ($actNetQoSState.NetQosTrafficClass | Where-Object Name -eq "$($thisPolicy.Name)").Priority | Should Be $thisPolicy.PriorityValue8021Action
                    }

                    ### Verify this traffic class is the expected BandwidthPercentage
                    It "[SUT: $nodeName]-[NetQos: $($thisPolicy.Name)]-[Noun: NetQosTrafficClass] The traffic class named ($($thisPolicy.Name)) should have a bandwidth percentage of ($($thisPolicy.BandwidthPercentage))" {
                        ($actNetQoSState.NetQosTrafficClass | Where-Object Name -eq $thisPolicy.Name).BandwidthPercentage | Should Be $thisPolicy.BandwidthPercentage
                    }

                    ### Verify this traffic class is the expected Algorithm
                    It "[SUT: $nodeName]-[NetQos: $($thisPolicy.Name)]-[Noun: NetQosTrafficClass] The traffic class named ($($thisPolicy.Name)) should have a algorithm of ($($thisPolicy.Algorithm))" {
                        ($actNetQoSState.NetQosTrafficClass | Where-Object Name -eq $thisPolicy.Name).Algorithm | Should Be $thisPolicy.Algorithm
                    }
                }
            }

            foreach ($thisRDMAEnabledAdapter in $AllRDMAEnabledAdapters) {
                ### Verify this adapter has an enabled NetAdapterQos policy
                It "[SUT: $nodeName]-[RDMAEnabledAdapters: $($thisRDMAEnabledAdapter.Name)]-[Noun: NetAdapterQos] should be enabled" {
                    ($actNetQoSState.NetAdapterQos | Where-Object Name -eq $thisRDMAEnabledAdapter.Name).Enabled | Should Be $true
                }

                ### Verify this adapter's DCBX setting is not Willing
                It "[SUT: $nodeName]-[RDMAEnabledAdapters: $($thisRDMAEnabledAdapter.Name)]-[Noun: NetQosDcbxSetting] interfaces DCBX 'Willing' option should be false" {
                    ($actNetQoSState.NetQosDcbxSettingInterfaces | Where-Object InterfaceAlias -like $thisRDMAEnabledAdapter.Name).Willing | Should -BeFalse
                }
            }
        }

        foreach ($thisCfgVMSwitch in $cfgVMSwitch) {
            $vmSwitch     = Get-VMSwitch     -Name $thisCfgVMSwitch.Name -CimSession $nodeName -ErrorAction SilentlyContinue
            $vmSwitchTeam = Get-VMSwitchTeam -Name $thisCfgVMSwitch.Name -CimSession $nodeName -ErrorAction SilentlyContinue

            $actvmSwitch = @{}
            $actvmSwitch.vmSwitch     = $vmSwitch
            $actvmSwitch.vmSwitchTeam = $vmSwitchTeam

            If ($thisCfgVMSwitch.IovEnabled) {
                $NetAdapterSRIOV = @()

                foreach ($thisRDMAEnabledAdapter in $thisCfgVMSwitch.RDMAEnabledAdapters) {
                    $NetAdapterSRIOV += Get-NetAdapterSRIOV -Name $thisRDMAEnabledAdapter.Name -CimSession $nodeName -ErrorAction SilentlyContinue
                }

                $actvmSwitch.NetAdapterSRIOV = $NetAdapterSRIOV
            }

            Remove-Variable -Name VMSwitch, VMSwitchTeam, NetAdapterSRIOV -ErrorAction SilentlyContinue

            Context "[Modal Unit]-[VMSwitch: $($thisCfgVMSwitch.Name)]-[SUT: $nodeName]-VMSwitch Settings" {
                ### Verify the expected VMSwitch exists
                It "[SUT: $nodeName]-[VMSwitch: $($thisCfgVMSwitch.Name)]-[Noun: VMSwitch] vSwitch should exist" {
                    ($actvmSwitch.vmSwitch | Where-Object Name -eq $thisCfgVMSwitch.Name).Name | Should Be $thisCfgVMSwitch.Name
                }

                Switch ($thisCfgVMSwitch.EmbeddedTeamingEnabled) {
                    $false {
                        ### Verify Non-teamed interfaces contain only 1 adapter specified
                        It "[SUT: $nodeName]-[VMSwitch: $($thisCfgVMSwitch.Name)]-[Noun: VMSwitch] vSwitch should contain only 1 adapter" {
                            ($actvmSwitch.vmSwitch | Where-Object Name -eq $thisCfgVMSwitch.Name).NetAdapterInterfaceDescriptions.Count | Should Be 1
                        }

                        ### Verify LBFO Multiplexor is not used
                        It "[SUT: $nodeName]-[VMSwitch: $($thisCfgVMSwitch.Name)]-[Noun: VMSwitch] vSwitch should not use LBFO Teaming" {
                            ($actvmSwitch.vmSwitch | Where-Object Name -eq $thisCfgVMSwitch.Name).NetAdapterInterfaceDescription | Should Not Be 'Microsoft Network Adapter Multiplexor Driver'
                        }

                        ### Verify Non-teamed interfaces are actually non-teamed
                        It "[SUT: $nodeName]-[VMSwitch: $($thisCfgVMSwitch.Name)]-[Noun: VMSwitch] vSwitch should not be a teamed interface" {
                            ($actvmSwitch.vmSwitch | Where-Object Name -eq $thisCfgVMSwitch.Name).NetAdapterInterfaceDescription | Should Not Be 'Teamed-Interface'
                        }

                        ### Verify the expected adapter is attached to the vSwitch
                        It "[SUT: $nodeName]-[VMSwitch: $($thisCfgVMSwitch.Name)]-[Noun: VMSwitch] vSwitch interface should be [$($thisCfgVMSwitch.RDMAEnabledAdapters.Name)]" {
                            $thisInterfaceDescription = ($actvmSwitch.vmSwitch | Where-Object Name -eq $thisCfgVMSwitch.Name).NetAdapterInterfaceDescription
                            ($actNetAdapterState.NetAdapter | Where-Object InterfaceDescription -eq $thisInterfaceDescription).Name | Should Be $thisCfgVMSwitch.RDMAEnabledAdapters.Name
                        }
                    }

                    $true {
                        ### Verify SET contains the expected number of adapters
                        It "[SUT: $nodeName]-[VMSwitch: $($thisCfgVMSwitch.Name)]-[Noun: VMSwitch] vSwitch contains ($($thisCfgVMSwitch.RDMAEnabledAdapters.Count)) adapters" {
                            ($actvmSwitch.vmSwitch | Where-Object Name -eq $thisCfgVMSwitch.Name).NetAdapterInterfaceDescriptions.Count | Should Be $thisCfgVMSwitch.RDMAEnabledAdapters.Count
                        }

                        ### Verify LBFO Multiplexor is not used
                        It "[SUT: $nodeName]-[VMSwitch: $($thisCfgVMSwitch.Name)]-[Noun: VMSwitch] vSwitch should not use LBFO Teaming" {
                            ($actvmSwitch.vmSwitch | Where-Object Name -eq $thisCfgVMSwitch.Name).NetAdapterInterfaceDescription | Should Not Be 'Microsoft Network Adapter Multiplexor Driver'
                        }

                        ### Verify the vSwitch is a teamed interface (implies SET based on the previous test)
                        It "[SUT: $nodeName]-[VMSwitch: $($thisCfgVMSwitch.Name)]-[Noun: VMSwitch] vSwitch should be a teamed interface" {
                            ($actvmSwitch.vmSwitch | Where-Object Name -eq $thisCfgVMSwitch.Name).NetAdapterInterfaceDescription | Should Be 'Teamed-Interface'
                        }

                        foreach ($thisRDMAEnabledAdapter in $thisCfgVMSwitch.RDMAEnabledAdapters) {
                            ### Verify the expected phyiscal adapters are part of the team
                            It "[SUT: $nodeName]-[VMSwitch: $($thisCfgVMSwitch.Name)]-[RDMAEnabledAdapter: $($thisRDMAEnabledAdapter.Name)]-[Noun: VMSwitchTeam] Interface should be a member of the SET team" {
                                ($actvmSwitch.vmSwitchTeam | Where-Object Name -eq $thisCfgVMSwitch.Name).NetAdapterInterfaceDescription -contains
                                ($actNetAdapterState.NetAdapter | Where-Object Name -eq $thisRDMAEnabledAdapter.Name).InterfaceDescription | Should be $true
                            }
                        }

                        ### Verify adapters in the team are symmetric: DriverFileName
                        It "[SUT: $nodeName]-[VMSwitch: $($thisCfgVMSwitch.Name)]-[Noun: NetAdapter] Adapters in the team are symmetric [same DriverFileName]" {
                            (($actNetAdapterState.NetAdapter).DriverName | Select-Object -Unique).Count | Should be 1
                        }

                        ### Verify adapters in the team are symmetric: DriverVersion
                        It "[SUT: $nodeName]-[VMSwitch: $($thisCfgVMSwitch.Name)]-[Noun: NetAdapter] Adapters in the team are symmetric [same DriverVersion]" {
                            (($actNetAdapterState.NetAdapter).DriverVersion | Select-Object -Unique).Count | Should be 1
                        }

                        ### Verify the team is SwitchIndependent (Currently the only option but -- Future Proofing)
                        It "[SUT: $nodeName]-[VMSwitch: $($thisCfgVMSwitch.Name)]-[Noun: VMSwitchTeam] TeamingMode must be SwitchIndependent" {
                            ($actvmSwitch.vmSwitchTeam | Where-Object Name -eq $thisCfgVMSwitch.Name).TeamingMode | Should Be 'SwitchIndependent'
                        }

                        ### Verify the load balancing algorithm is the expected.  Either setting is acceptable; testing for consistency
                        If ($thisCfgVMSwitch.LoadBalancingAlgorithm) {
                            It "[SUT: $nodeName]-[VMSwitch: $($thisCfgVMSwitch.Name)]-[Noun: VMSwitchTeam] LoadBalancingAlgorithm must be $($thisCfgVMSwitch.LoadBalancingAlgorithm)" {
                                ($actvmSwitch.vmSwitchTeam | Where-Object Name -eq $thisCfgVMSwitch.Name).LoadBalancingAlgorithm | Should Be $thisCfgVMSwitch.LoadBalancingAlgorithm
                            }
                        }
                        Else {
                            It "[SUT: $nodeName]-[VMSwitch: $($thisCfgVMSwitch.Name)]-[Noun: VMSwitchTeam] LoadBalancingAlgorithm should be 'Hyper-V Port' if not specified in the config file" {
                                ($actvmSwitch.vmSwitchTeam | Where-Object Name -eq $thisCfgVMSwitch.Name).LoadBalancingAlgorithm | Should Be 'HyperVPort'
                            }
                        }

                        ### Verify PacketDirect is disabled (not required for RDMA; best practice for VMSwitch)
                        It "[SUT: $nodeName]-[VMSwitch: $($thisCfgVMSwitch.Name)]-[Noun: VMSwitch] PacketDirect must be Disabled" {
                            ($actvmSwitch.vmSwitch | Where-Object Name -eq $thisCfgVMSwitch.Name).PacketDirectEnabled | Should Be $false
                        }
                    }

                    ### Verify no catastrophic failures in the VMSwitch testing...
                    default { It "Could not determine the EmbeddedTeamingEnabled configuration" { $false | Should be $true }}
                }

                Switch ($thisCfgVMSwitch.IovEnabled) {
                    $false {
                        ### Verify the VMSwitch has disabled SR-IOV (e.g. No Guest RDMA possible)
                        It "[SUT: $nodeName]-[VMSwitch: $($thisCfgVMSwitch.Name)]-[Noun: VMSwitch] The VMSwitch should have SR-IOV disabled" {
                            ($actvmSwitch.vmSwitch | Where-Object Name -eq $thisCfgVMSwitch.Name).IovEnabled | Should Be $false
                        }
                    }

                    $true {
                        foreach ($thisRDMAEnabledAdapter in $thisCfgVMSwitch.RDMAEnabledAdapters) {
                            ### Verify the expected phyiscal adapters have SR-IOV enabled
                            It "[SUT: $nodeName]-[VMSwitch: $($thisCfgVMSwitch.Name)]-[RDMAEnabledAdapter: $($thisRDMAEnabledAdapter.Name)]-[Noun: NetAdapterSRIOV] Interface should report SR-IOV is supported" {
                                ($actvmSwitch.NetAdapterSRIOV | Where-Object Name -eq $thisRDMAEnabledAdapter.Name).Enabled | Should be $true

                                # If support is disabled, review for potential reasons https://docs.microsoft.com/en-us/powershell/module/netadapter/get-netadaptersriov?view=win10-ps
                            }

                            It "[SUT: $nodeName]-[VMSwitch: $($thisCfgVMSwitch.Name)]-[RDMAEnabledAdapter: $($thisRDMAEnabledAdapter.Name)]-[Noun: NetAdapterSRIOV] Interface should have at least 1 VF" {
                                ($actvmSwitch.NetAdapterSRIOV | Where-Object Name -eq $thisRDMAEnabledAdapter.Name).NumVFs | Should BeGreaterThan 0
                            }
                        }

                        ### Verify IOV is supported by the VMSwitch (Summary of the Adapters)
                        It "[SUT: $nodeName]-[VMSwitch: $($thisCfgVMSwitch.Name)]-[Noun: VMSwitch] The VMSwitch should support SR-IOV" {
                            ($actvmSwitch.vmSwitch | Where-Object Name -eq $thisCfgVMSwitch.Name).IovSupport | Should Be $true
                        }

                        ### Verify the VMSwitch has SR-IOV Enabled
                        It "[SUT: $nodeName]-[VMSwitch: $($thisCfgVMSwitch.Name)]-[Noun: VMSwitch] The VMSwitch should have SR-IOV enabled" {
                            ($actvmSwitch.vmSwitch | Where-Object Name -eq $thisCfgVMSwitch.Name).IovEnabled | Should Be $true
                        }

                        ### Verify the VMSwitch has at least one Iov Queue Pair
                        It "[SUT: $nodeName]-[VMSwitch: $($thisCfgVMSwitch.Name)]-[Noun: VMSwitch] The VMSwitch's IovQueuePairCount must be at least 1" {
                            ($actvmSwitch.vmSwitch | Where-Object Name -eq $thisCfgVMSwitch.Name).IovQueuePairCount | Should BeGreaterThan 0
                        }

                        ### Verify the VMSwitch has at least 1 Virtual Function to hand out
                        It "[SUT: $nodeName]-[VMSwitch: $($thisCfgVMSwitch.Name)]-[Noun: VMSwitch] The VMSwitch's IovVirtualFunctionCount must be at least 1" {
                            ($actvmSwitch.vmSwitch | Where-Object Name -eq $thisCfgVMSwitch.Name).IovVirtualFunctionCount | Should BeGreaterThan 0
                        }
                    }
                }
            }

            foreach ($thisRDMAEnabledAdapter in $thisCfgVMSwitch.RDMAEnabledAdapters) {
                $VMNetworkAdapter = @()
                $VMNetworkAdapterTeamMapping = @()

                $VMNetworkAdapter            = Get-VMNetworkAdapter            -Name $thisRDMAEnabledAdapter.VMNetworkAdapter -ManagementOS -CimSession $nodeName -ErrorAction SilentlyContinue
                $VMNetworkAdapterTeamMapping = Get-VMNetworkAdapterTeamMapping -Name $thisRDMAEnabledAdapter.VMNetworkAdapter -ManagementOS -CimSession $nodeName -ErrorAction SilentlyContinue

                $NetAdapter = @()
                $NetAdapterRDMA = @()
                $netAdapterAdvancedProperty = @()

                If ($VMNetworkAdapter.Name -eq $thisRDMAEnabledAdapter.VMNetworkAdapter) {
                    $NetAdapter     = Get-NetAdapter -CimSession $nodeName -ErrorAction SilentlyContinue | Where-Object DeviceID -eq $VMNetworkAdapter.DeviceID
                    $NetAdapterRDMA = Get-NetAdapterRDMA -Name $NetAdapter.Name -CimSession $nodeName -ErrorAction SilentlyContinue
                    $NetAdapterAdvancedProperty = Get-NetAdapterAdvancedProperty -Name $NetAdapter.Name -CimSession $nodeName -ErrorAction SilentlyContinue
                }

                $actvmSwitch.NetAdapter                  = $NetAdapter
                $actvmSwitch.NetAdapterRDMA              = $NetAdapterRDMA
                $actvmSwitch.NetAdapterAdvancedProperty  = $NetAdapterAdvancedProperty
                $actvmSwitch.VMNetworkAdapter            = $VMNetworkAdapter
                $actvmSwitch.VMNetworkAdapterTeamMapping = $VMNetworkAdapterTeamMapping

                Remove-Variable -Name NetAdapter, NetAdapterRDMA, NetAdapterAdvancedProperty, VMNetworkAdapter, VMNetworkAdapterTeamMapping -ErrorAction SilentlyContinue

                Context "[Modal Unit]-[VMSwitch: $($thisCfgVMSwitch.Name)]-[VMNetworkAdapter: $($thisRDMAEnabledAdapter.VMNetworkAdapter)]-[SUT: $nodeName]-Virtual NICs NetAdapter and NetAdapterAdvancedProperty Settings" {
                    ### Verify the virtual NIC's NetAdapter Name is the same as the VMNetworkAdapter name
                    It "[SUT: $nodeName]-[VMSwitch: $($thisCfgVMSwitch.Name)]-[RDMAEnabledAdapter: $($thisRDMAEnabledAdapter.Name)]-[VMNetworkAdapter: $($thisRDMAEnabledAdapter.VMNetworkAdapter)]-[Noun: NetAdapter, VMNetworkAdapter] NetAdapter Name for the virtual NIC is named the same as the VMNetworkAdapter name" {
                        ($actvmSwitch.NetAdapter | Where-Object Name -eq $thisRDMAEnabledAdapter.VMNetworkAdapter).Name | Should be $thisRDMAEnabledAdapter.VMNetworkAdapter
                    }

                    ### Verify the interface is a virtual interface
                    It "[SUT: $nodeName]-[VMSwitch: $($thisCfgVMSwitch.Name)]-[RDMAEnabledAdapter: $($thisRDMAEnabledAdapter.Name)]-[VMNetworkAdapter: $($thisRDMAEnabledAdapter.VMNetworkAdapter)]-[Noun: NetAdapter] The interface must be virtual" {
                        ($actvmSwitch.NetAdapter | Where-Object Name -eq $thisRDMAEnabledAdapter.VMNetworkAdapter).ConnectorPresent | Should Be $false
                    }

                    ### Verify the interface is enabled
                    It "[SUT: $nodeName]-[VMSwitch: $($thisCfgVMSwitch.Name)]-[RDMAEnabledAdapter: $($thisRDMAEnabledAdapter.Name)]-[VMNetworkAdapter: $($thisRDMAEnabledAdapter.VMNetworkAdapter)]-[Noun: NetAdapter] The virtual interface status must be `"Up`"" {
                        ($actvmSwitch.NetAdapter | Where-Object Name -eq $thisRDMAEnabledAdapter.VMNetworkAdapter).Status | Should Be 'Up'
                    }

                    ### Verify the interface has media link
                    It "[SUT: $nodeName]-[VMSwitch: $($thisCfgVMSwitch.Name)]-[RDMAEnabledAdapter: $($thisRDMAEnabledAdapter.Name)]-[VMNetworkAdapter: $($thisRDMAEnabledAdapter.VMNetworkAdapter)]-[Noun: NetAdapter] The virtual interface media state must be `"Connected`"" {
                        ($actvmSwitch.NetAdapter | Where-Object Name -eq $thisRDMAEnabledAdapter.VMNetworkAdapter).MediaConnectionState | Should Be 'Connected'
                    }

                    If ($thisRDMAEnabledAdapter.JumboPacket) {
                        ### Verify if the JumboPacket param is specified in the cfg file, that the vNIC also has the jumbo packet setting
                        It "[SUT: $nodeName]-[VMSwitch: $($thisCfgVMSwitch.Name)]-[RDMAEnabledAdapter: $($thisRDMAEnabledAdapter.Name)]-[VMNetworkAdapter: $($thisRDMAEnabledAdapter.VMNetworkAdapter)]-[Noun: NetAdapterAdvancedProperty] should have Jumbo Packet set to [$($thisRDMAEnabledAdapter.JumboPacket)]" {
                            ($actvmSwitch.NetAdapterAdvancedProperty | Where-Object{$_.Name -eq $thisRDMAEnabledAdapter.VMNetworkAdapter -and $_.RegistryKeyword -eq '*JumboPacket'}).RegistryValue | Should Be $thisRDMAEnabledAdapter.JumboPacket
                        }
                    }

                    ### Verify Interface is RDMA Capable (includes the *NetworkDirect Keyword)
                    It "[SUT: $nodeName]-[VMSwitch: $($thisCfgVMSwitch.Name)]-[RDMAEnabledAdapter: $($thisRDMAEnabledAdapter.Name)]-[VMNetworkAdapter: $($thisRDMAEnabledAdapter.VMNetworkAdapter)]-[Noun: NetAdapterAdvancedProperty] should be NetworkDirect (RDMA) capable" {
                        $actvmSwitch.netAdapterAdvancedProperty | Where-Object{$_.Name -eq $thisRDMAEnabledAdapter.VMNetworkAdapter -and $_.RegistryKeyword -eq '*NetworkDirect'} | Should Not BeNullOrEmpty
                    }

                    ### Verify the NetAdapter is Enabled for RDMA
                    It "[SUT: $nodeName]-[VMSwitch: $($thisCfgVMSwitch.Name)]-[RDMAEnabledAdapter: $($thisRDMAEnabledAdapter.Name)]-[VMNetworkAdapter: $($thisRDMAEnabledAdapter.VMNetworkAdapter)]-[Noun: NetAdapterRDMA] VMNetworkAdapter should be enabled for RDMA" {
                        ($actvmSwitch.NetAdapterRDMA | Where-Object Name -eq $thisRDMAEnabledAdapter.VMNetworkAdapter).Enabled | Should be $true
                    }
                }

                Context "[Modal Unit]-[VMSwitch: $($thisCfgVMSwitch.Name)]-[SUT: $nodeName]-VMNetworkAdapter Settings" {
                    ### Verify the VMNetworkAdapter specified in the config file exists
                    It "[SUT: $nodeName]-[VMSwitch: $($thisCfgVMSwitch.Name)]-[RDMAEnabledAdapter: $($thisRDMAEnabledAdapter.Name)]-[VMNetworkAdapter: $($thisRDMAEnabledAdapter.VMNetworkAdapter)]-[Noun: VMNetworkAdapter] VMNetworkAdapter should exist" {
                        (($actvmSwitch.VMNetworkAdapter).Name -contains $thisRDMAEnabledAdapter.VMNetworkAdapter) | Should be $true
                    }

                    ### Verify the VMNetworkAdapter Status is OK
                    It "[SUT: $nodeName]-[VMSwitch: $($thisCfgVMSwitch.Name)]-[RDMAEnabledAdapter: $($thisRDMAEnabledAdapter.Name)]-[VMNetworkAdapter: $($thisRDMAEnabledAdapter.VMNetworkAdapter)]-[Noun: VMNetworkAdapter] VMNetworkAdapter Status should be 'OK'" {
                        ($actvmSwitch.VMNetworkAdapter | Where-Object Name -eq $thisRDMAEnabledAdapter.VMNetworkAdapter).Status | Should be 'Ok'
                    }

                    ### Verify the VMNetworkAdapter is attached to the VMSwitch
                    It "[SUT: $nodeName]-[VMSwitch: $($thisCfgVMSwitch.Name)]-[RDMAEnabledAdapter: $($thisRDMAEnabledAdapter.Name)]-[VMNetworkAdapter: $($thisRDMAEnabledAdapter.VMNetworkAdapter)]-[Noun: VMNetworkAdapter] VMNetworkAdapter should be connected to the VMSwitch" {
                        ($actvmSwitch.VMNetworkAdapter | Where-Object Name -eq $thisRDMAEnabledAdapter.VMNetworkAdapter).SwitchName | Should be $thisCfgVMSwitch.Name
                    }

                    ### Verify the VMNetworkAdapter maintains IEEEPriority Tag for vNIC traffic
                    It "[SUT: $nodeName]-[VMSwitch: $($thisCfgVMSwitch.Name)]-[RDMAEnabledAdapter: $($thisRDMAEnabledAdapter.Name)]-[VMNetworkAdapter: $($thisRDMAEnabledAdapter.VMNetworkAdapter)]-[Noun: VMNetworkAdapter] VMNetworkAdapter should maintain IEEEPriority tags" {
                        ($actvmSwitch.VMNetworkAdapter | Where-Object Name -eq $thisRDMAEnabledAdapter.VMNetworkAdapter).IeeePriorityTag | Should be 'On'
                    }

                    ### Verify the VMNetwork adapter is mapped to the specified pNIC
                    If ($thisCfgVMSwitch.EmbeddedTeamingEnabled -eq $true) {
                        It "[SUT: $nodeName]-[VMSwitch: $($thisCfgVMSwitch.Name)]-[RDMAEnabledAdapter: $($thisRDMAEnabledAdapter.Name)]-[VMNetworkAdapterTeamMapping: $($thisRDMAEnabledAdapter.VMNetworkAdapter)]-[Noun: VMNetworkAdapterTeamMapping] VMNetworkAdapter should be mapped to the physical adapter" {
                            ($actvmSwitch.VMNetworkAdapterTeamMapping | Where-Object NetAdapterName -eq $thisRDMAEnabledAdapter.Name).ParentAdapter.Name | Should be $thisRDMAEnabledAdapter.VMNetworkAdapter
                        }
                    }
                }
            }
        }

        Context "[Modal Unit]-[SMB Direct]-[SUT: $nodeName]-SMB Client Settings" {
            $SMBClient                 = Get-SmbClientConfiguration    -CimSession $nodeName -ErrorAction SilentlyContinue
            $SMBClientNetworkInterface = Get-SmbClientNetworkInterface -CimSession $nodeName -ErrorAction SilentlyContinue

            It "[SUT: $nodeName]-[Noun: SmbClientConfiguration] SMB Multichannel must be enabled on the SMB client" {
                ($SMBClient).EnableMultichannel | Should Be 'True'
            }

            It "[SUT: $nodeName]-[Noun: SMBClientConfiguration] SMB Signing must not be required" {
                ($SMBClient).RequireSecuritySignature | Should Be 'false'
            }

            foreach ($thisRDMAEnabledAdapter in $cfgRDMAEnabledAdapters) {
                $NetAdapter = @()
                $NetAdapter = Get-NetAdapter -Name $thisRDMAEnabledAdapter.Name -CimSession $nodeName -ErrorAction SilentlyContinue

                It "[SUT: $nodeName]-[SMB Adapter: $($thisRDMAEnabledAdapter.Name)]-[Noun: SMBClientNetworkInterface] SMB Client must report RDMA Capable" {
                    ($SMBClientNetworkInterface | Where-Object InterfaceIndex -eq $NetAdapter.IfIndex).RdmaCapable | Should be $true
                }
            }

            foreach ($thisRDMAEnabledAdapter in $thisCfgVMSwitch.RDMAEnabledAdapters) {
                $NetAdapter = @()
                $NetAdapter = Get-NetAdapter -Name $thisRDMAEnabledAdapter.VMNetworkAdapter -CimSession $nodeName -ErrorAction SilentlyContinue

                It "[SUT: $nodeName]-[SMB Adapter: $($thisRDMAEnabledAdapter.VMNetworkAdapter)]-[Noun: SMBClientNetworkInterface] SMB Client must report RDMA Capable" {
                    ($SMBClientNetworkInterface | Where-Object InterfaceIndex -eq $NetAdapter.IfIndex).RdmaCapable | Should be $true
                }
            }
        }

        Context "[Modal Unit]-[SMB Direct]-[SUT: $nodeName]-SMB Server Settings" {
            $SMBServer                 = Get-SmbServerConfiguration    -CimSession $nodeName -ErrorAction SilentlyContinue
            $SMBServerNetworkInterface = Get-SmbServerNetworkInterface -CimSession $nodeName -ErrorAction SilentlyContinue

            It "[SUT: $nodeName]-[Noun: SmbServerConfiguration] SMB Multichannel must be enabled on the SMB server" {
                ($SMBServer).EnableMultichannel | Should Be 'True'
            }

            It "[SUT: $nodeName]-[Noun: SmbServerConfiguration] SMB Encryption must be disabled on the SMB server" {
                ($SMBServer).EncryptData | Should Be 'false'
            }

            It "[SUT: $nodeName]-[Noun: SmbServerConfiguration] SMB Signing must be disabled on the SMB server" {
                ($SMBServer).EnableSecuritySignature | Should Be 'false'
            }

            foreach ($thisRDMAEnabledAdapter in $cfgRDMAEnabledAdapters) {
                $NetAdapter = @()
                $NetAdapter = Get-NetAdapter -Name $thisRDMAEnabledAdapter.Name -CimSession $nodeName -ErrorAction SilentlyContinue

                It "[SUT: $nodeName]-[SMB Adapter: $($thisRDMAEnabledAdapter.Name)]-[Noun: SMBServerNetworkInterface] SMB Client must report RDMA Capable" {
                    (($SMBServerNetworkInterface | Where-Object InterfaceIndex -eq $NetAdapter.IfIndex) | Select-Object -first 1).RdmaCapable | Should be $true
                }
            }

            foreach ($thisRDMAEnabledAdapter in $thisCfgVMSwitch.RDMAEnabledAdapters) {
                $NetAdapter = @()
                $NetAdapter = Get-NetAdapter -Name $thisRDMAEnabledAdapter.VMNetworkAdapter -CimSession $nodeName -ErrorAction SilentlyContinue

                It "[SUT: $nodeName]-[SMB Adapter: $($thisRDMAEnabledAdapter.VMNetworkAdapter)]-[Noun: SMBServerNetworkInterface] SMB Client must report RDMA Capable" {
                    (($SMBServerNetworkInterface | Where-Object InterfaceIndex -eq $NetAdapter.IfIndex) | Select-Object -first 1).RdmaCapable | Should be $true
                }
            }

            $VMHostLiveMigration = Get-VMHost -CimSession $nodeName -ErrorAction SilentlyContinue
            $SMBBandwidthLimit   = Get-SmbBandwidthLimit -Category LiveMigration -CimSession $nodeName -ErrorAction SilentlyContinue

            If ($VMHostLiveMigration.VirtualMachineMigrationPerformanceOption -eq 'SMB') {
                $AdapterLinkSpeed = ($actNetAdapterState.NetAdapter | Where-Object Name -eq $thisRDMAEnabledAdapter.Name).ReceiveLinkSpeed

                $configData.NonNodeData.NetQos | Foreach-Object {
                    $thisPolicy = $_

                    If ($thisPolicy.ContainsKey('NetDirectPortMatchCondition')) {
                        Switch ($AdapterLinkSpeed) {
                            # SMB Bandwidth Limit is being calculated MB and being compared to adapter speed which is in Gbps converted to MiBps

                            {$_ -le 10000000000} {
                                $expectedLimitMB = (((($thisPolicy.BandwidthPercentage / 100) * .6) * $AdapterLinkSpeed) / 8) / 1000000
                                It "Should have a Live Migration limit of less than $expectedLimitMB MBps" {
                                    $SMBBandwidthLimit.BytesPerSecond / 1MB | Should BeLessThan ($expectedLimitMB + 1)
                                }
                            }

                            # Setting to a Max of 750 MBps for adapters over 10 Gbps 
                            # https://techcommunity.microsoft.com/t5/failover-clustering/optimizing-hyper-v-live-migrations-on-an-hyperconverged/ba-p/396609
                            {$_ -gt 10000000000} {
                                $expectedLimitMB = (((($thisPolicy.BandwidthPercentage / 100) * .6) * $AdapterLinkSpeed) / 8) / 1000000
                                It "Should have an Live Migration limit of 750 MBps" {
                                    $SMBBandwidthLimit.BytesPerSecond / 1MB | Should Be 750
                                }
                            }

                            default { It 'Link speed was not identified and so optimal live migration limit could not be determined' { $false | Should be $true } }
                        }
                    }
                }
            }
        }
    }
}

#TODO: Update test helpers to check for VLAN Isolation and not VMnetworkAdapterVlan
