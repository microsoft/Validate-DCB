Describe "[Global Unit]" -Tag Global {
    Context "[Global Unit]-[Test Host: $($env:COMPUTERNAME)]-System Requirements" {
        $pesterModule = (Get-Module -Name Pester -ListAvailable -ErrorAction SilentlyContinue)

        ### Verify TestHost has Pester Module
        It "[Global Unit]-[TestHost: ${env:ComputerName}] must have Pester module" {
            $pesterModule | Should Not BeNullOrEmpty
        }

        ### Verify TestHost has the 3x Version of Pester
        If (Get-Module -Name Pester -ListAvailable -ErrorAction SilentlyContinue) {
            It "[Global Unit]-[TestHost: ${env:ComputerName}] must have Pester 3x module" {
                $pesterModule.Version.Major | Should Be 3
            }
        }

        $NodeOS = Get-CimInstance -ClassName 'Win32_OperatingSystem'
        
        ### Verify the TestHost is sufficient version
        It "[Global Unit]-[TestHost: ${env:ComputerName}] must be Windows 10, Server 2016, or Server 2019" {
            $caption =  ($NodeOS.Caption -like '*Windows 10*') -or 
                        ($NodeOS.Caption -like '*Windows Server 2016*') -or
                        ($NodeOS.Caption -like '*Windows Server 2019*') 
            
            $caption | Should be $true
        }

        ### Verify PowerShell Modules are available on the TestHost
        $reqModules  = @('ServerManager','DcbQos', 'NetQos', 'NetAdapter')

        # Add Hyper-V cmdlets to the list if there's at least one vmSwitch defined in the config
        If ($ConfigData.AllNodes.VMSwitch.Count -ge 1) {
            $reqModules += 'Hyper-V'
        }

        $reqModules | ForEach-Object {
            It "[Global Unit]-[TestHost: ${env:ComputerName}] Must have the module [$_] available" {
                $module = Get-Module $_ -ListAvailable -ErrorAction SilentlyContinue
                $module | Should not BeNullOrEmpty
            }
        }

        If ($Deploy) {
            $fnNetworkConfig = Get-ChildItem 'Function:\NetworkConfig'
            It "[Global Unit]-[TestHost: ${env:ComputerName}] must have the NetworkConfig command" {
                $fnNetworkConfig | Should not BeNullOrEmpty
            }

            It "[Global Unit]-[TestHost: ${env:ComputerName}] NetworkConfig command must be a Configuration" {
                $fnNetworkConfig.CommandType | Should be 'Configuration'
            }
        }

        ### Verify PowerShell cmdlets are available on the TestHost
        $reqCmdlets  = @('Get-WindowsFeature','Get-NetQosPolicy', 'Get-NetQosFlowControl',
                         'Get-NetQosTrafficClass', 'Get-NetAdapterQos', 'Get-NetQosDcbxSetting')

        # Add Hyper-V cmdlets to the list if there's at least one vmSwitch defined in the config
        If ($ConfigData.AllNodes.VMSwitch.Count -ge 1) {
            $reqCmdlets += 'Get-VMSwitch'
        }

        $reqCmdlets | ForEach-Object {
            It "[Global Unit]-[TestHost: ${env:ComputerName}] must have the cmdlet [$_] available" {
                $cmd = Get-Command $_ -ErrorAction SilentlyContinue
                $cmd | Should not BeNullOrEmpty
            }
        }
    }

    Context "[Global Unit]-Config File Integrity" {
        ### Verify the config file exists
        $configFileExists = Get-ChildItem -Path $configFile -ErrorAction SilentlyContinue        
        It "[Config File] $($configFileExists.Name) must exist" {
            $configFileExists.Exists | Should Be $true
        }

        ### Verify configData contains the AllNodes HashTable
        It "[Config File]-[AllNodes] Config File must contain the AllNodes Hashtable" {
            $configData.AllNodes | Should BeOfType System.Collections.Hashtable
        }

        ### Verify configData contains the NonNodeData HashTable
        It "[Config File]-[NonNodeData] Config File must contain the NonNodeData Hashtable" {
            $configData.NonNodeData | Should BeOfType System.Collections.Hashtable
        }

        $legend = @('AllNodes','NonNodeData', 'Drivers')
        $configData.Keys.GetEnumerator() | ForEach-Object {
            ### Verify that the entries under $configData are in $legend
            It "[Config File]-[Tested key: $_] Should contain only recognized keys" {
                $_ -in $legend | Should be $true
            }
        }

        ### Verify at least one node is specified [NodeName]
        It "[Config File]-[AllNodes.NodeName] Config File must contain at least 1 Node" {
            $configData.AllNodes.NodeName.Count | Should BeGreaterThan 0
        }

        ### Verify nodes are only listed once in the config file [NodeName]
        $reference = $configData.AllNodes.NodeName | Select-Object -Unique -ErrorAction SilentlyContinue

        It "[Config File]-[AllNodes.NodeName] Nodes cannot be specified more than once in the config file" {
            Compare-Object -ReferenceObject $reference -DifferenceObject $ConfigData.AllNodes.NodeName | Should BeNullOrEmpty
        }

        ### Verify Config File includes at least one RDMAEnabledAdapters entry
        It "[Config File]-[AllNodes] Must include at least one RDMAEnabledAdapters or vmswitch.RDMAEnabledAdapters entry" {
            ($configData.AllNodes.RDMAEnabledAdapters + $configData.AllNodes.vmswitch.RDMAEnabledAdapters).Count | Should BeGreaterThan 0
        }

        foreach ($thisNode in $configData.AllNodes) {
            $AdapterEntry = 1

            $legend = @('Role','NodeName','RDMAEnabledAdapters','RDMADisabledAdapters','VMSwitch')
            ($configData.AllNodes.Keys.GetEnumerator() | Select-Object -Unique) | ForEach-Object {
                ### Verify that the entries under $configData.AllNodes are in $legend
                It "[Config File]-[AllNodes]-[$($thisNode.NodeName)]-[Tested key: $_] Should contain only recognized keys" {
                    $_ -in $legend | Should be $true
                }
            }

            foreach ($thisRDMADisabledAdapter in $thisNode.RDMADisabledAdapters) {
                $legend = @('Name')
                ($thisRDMADisabledAdapter.Keys.GetEnumerator() | Select-Object -Unique) | ForEach-Object {
                    ### Verify that the only entries under $configData.AllNodes.RDMADisabledAdapters are in $legend
                    It "[Config File]-[AllNodes.RDMADisabledAdapters]-[RDMADisabledAdapter: $($thisRDMADisabledAdapter.Name)]-[Tested key: $_]-Should contain only recognized keys" {
                        $_ -in $legend | Should be $true
                    }
                }
            }

            foreach ($thisRDMAEnabledAdapter in $thisNode.RDMAEnabledAdapters) {
                $legend = @('Name','VLANID','JumboPacket','EncapOverhead')
                ($thisRDMAEnabledAdapter.Keys.GetEnumerator() | Select-Object -Unique) | ForEach-Object {
                    ### Verify that the entries under $configData.AllNodes.RDMAEnabledAdapters are in $legend
                    It "[Config File]-[AllNodes.RDMAEnabledAdapters]-[RDMAEnabledAdapter: $($thisRDMAEnabledAdapter.Name)]-[Tested key: $_]-Should contain only recognized keys" {
                        $_ -in $legend | Should be $true
                    }
                }

                ### Verify each RDMAEnabledAdapter includes the Name property from Get-NetAdapter
                It "[Config File]-[AllNodes.RDMAEnabledAdapters]-[Node: $($thisNode.NodeName)]-[Entry: $AdapterEntry]-[Noun: NetAdapter] Must include the Name property for each entry" {
                    $thisRDMAEnabledAdapter.Name | Should not BeNullOrEmpty 
                }
    
                ### Verify each RDMAEnabledAdapter includes the VLANID property from Get-NetAdapterAdvancedProperty
                It "[Config File]-[AllNodes.RDMAEnabledAdapters]-[Node: $($thisNode.NodeName)]-[Entry: $($thisRDMAEnabledAdapter.Name)]-[Noun: NetAdapterAdvancedProperty] Must include the VLANID property for each entry" {
                    $thisRDMAEnabledAdapter.VLANID | Should not BeNullOrEmpty 
                }
    
                ### Verify each RDMAEnabledAdapter's VLANID property is not '0'
                It "[Config File]-[AllNodes.RDMAEnabledAdapters]-[Node: $($thisNode.NodeName)]-[Entry: $($thisRDMAEnabledAdapter.Name)]-[Noun: NetAdapterAdvancedProperty] VLANID property should not be non-zero" {
                    $thisRDMAEnabledAdapter.VLANID | Should Not Be '0'
                }
                
                ### Verify RDMAEnabledAdapter Entry is not included in RDMADisabledAdapter
                It "[Config File]-[AllNodes.RDMAEnabledAdapters]-[Node: $($thisNode.NodeName)]-[Entry: $($thisRDMAEnabledAdapter.Name)]-[Noun: NetAdapterRDMA] Should not be in both RDMAEnabledAdapters and RDMADisabledAdapters" {
                    $thisRDMAEnabledAdapter.Name -in $thisNode.RDMADisabledAdapters.Name | Should Be $false
                }

                ### Verify RDMAEnabledAdapter Entry is not included in vmswitch.RDMADisabledAdapter
                It "[Config File]-[AllNodes.RDMAEnabledAdapters]-[Node: $($thisNode.NodeName)]-[Entry: $($thisRDMAEnabledAdapter.Name)]-[Noun: NetAdapterRDMA] Should not be in both RDMAEnabledAdapters and vmswitch.RDMADisabledAdapters" {
                    $thisRDMAEnabledAdapter.Name -in $thisNode.vmswitch.RDMADisabledAdapters.Name | Should Be $false
                }

                $AdapterEntry ++
            }

            $AdapterEntry = 1
            $VMSwitchEntry = 1

            foreach ($thisVMSwitch in $thisNode.vmSwitch) {
                $RDMADisabledAdapters = $thisVMSwitch.RDMADisabledAdapters
                $legend = @('Name','VMNetworkAdapter')

                foreach ($thisRDMADisabledAdapter in $RDMADisabledAdapters) {
                    $thisRDMADisabledAdapter.Keys.GetEnumerator() | ForEach-Object {
                        ### Verify entries under $configData.AllNodes.VMSwitch.RDMADisabledAdapters are in $legend
                        It "[Config File]-[AllNodes.VMSwitch.RDMADisabledAdapters]-[VMSwitch: $($thisVMSwitch.Name))]-[RDMADisabledAdapter: $($thisRDMADisabledAdapter.($_))]-[Tested key: $_]-Should contain only recognized keys" {
                            $_ -in $legend | Should be $true
                        }
                    }
                }
            }

            foreach ($thisVMSwitch in $thisNode.VMSwitch) {
                $legend = @('Name','EmbeddedTeamingEnabled','IovEnabled','LoadBalancingAlgorithm','RDMAEnabledAdapters','RDMADisabledAdapters')
                $thisVMSwitch.Keys.GetEnumerator() | ForEach-Object {
                    ### Verify that the entries under $configData.AllNodes.VMSwitch are in $legend
                    It "[Config File]-[AllNodes.VMSwitch.RDMAEnabledAdapters]-[Node: $($thisNode.NodeName)]-[Entry: $($thisVMSwitch.Name))]-[Tested key: $_]-Should contain only recognized keys" {
                        $_ -in $legend | Should be $true
                    }
                }

                ### Verify VMSwitch entry contains the Name property
                It "[Config File]-[AllNodes.VMSwitch]-[Node: $($thisNode.NodeName)]-[Entry: $VMSwitchEntry)]-[Noun: VMSwitch] Must include the Name Property" {
                    $thisVMSwitch.Name | Should not BeNullOrEmpty
                }

                ### Verify VMSwitch entry contains the EmbeddedTeamingEnabled property
                It "[Config File]-[AllNodes.VMSwitch]-[Node: $($thisNode.NodeName)]-[Entry: $($thisVMSwitch.Name))]-[Noun: VMSwitch] Must include the EmbeddedTeamingEnabled Property" {
                    $thisVMSwitch.EmbeddedTeamingEnabled | Should not BeNullOrEmpty
                }

                ### Verify VMSwitch EmbeddedTeamingEnabled property is a boolean
                It "[Config File]-[AllNodes.VMSwitch]-[Node: $($thisNode.NodeName)]-[Entry: $($thisVMSwitch.Name))]-[Noun: VMSwitch] EmbeddedTeamingEnabled Property must be a boolean" {
                    $thisVMSwitch.EmbeddedTeamingEnabled | Should BeOfType System.Boolean
                }

                If ($thisVMSwitch.ContainsKey('IovEnabled')) {
                    ### Verify VMSwitch IovEnabled property is a boolean
                    It "[Config File]-[AllNodes.VMSwitch]-[Node: $($thisNode.NodeName)]-[Entry: $($thisVMSwitch.Name))]-[Noun: VMSwitch] The IovEnabled property must be boolean" {
                        $thisVMSwitch.IovEnabled | Should BeOfType System.Boolean
                    }
                }

                If ($thisVMSwitch.ContainsKey('LoadBalancingAlgorithm')) {
                    ### Verify VMSwitch Load Balancing Algorithm is either Dynamic (2016 Default) or HyperVPort (2019 Default)
                    It "[Config File]-[AllNodes.VMSwitch]-[Node: $($thisNode.NodeName)]-[Entry: $($thisVMSwitch.Name))]-[Noun: VMSwitch] The LoadBalancingAlgorithm property must be either HyperVPort or Dynamic " {
                        ($thisVMSwitch.LoadBalancingAlgorithm -eq 'Dynamic' -or $thisVMSwitch.LoadBalancingAlgorithm -eq 'HyperVPort') | Should be $true
                    }
                }

                $reference = $thisNode.VMSwitch.Name | Select-Object -Unique -ErrorAction SilentlyContinue

                ### Verify VMSwitch.Name entries are unique
                It "[Config File]-[AllNodes.VMSwitch] VMSwitch.Name cannot be specified more than once in the config file" {
                    Compare-Object -ReferenceObject $reference -DifferenceObject $thisNode.VMSwitch.Name | Should BeNullOrEmpty
                }

                foreach ($thisRDMAEnabledAdapter in $thisVMSwitch.RDMAEnabledAdapters) {
                    $legend = @('Name','VMNetworkAdapter','VLANID','JumboPacket','EncapOverhead')
                    $thisRDMAEnabledAdapter.Keys.GetEnumerator() | ForEach-Object {
                        ### Verify that the only entries under $configData.AllNodes.VMSwitch.RDMAEnabledAdapters are in $legend
                        It "[Config File]-[AllNodes.VMSwitch.RDMAEnabledAdapters]-[Node: $($thisNode.NodeName)]-[Entry: $($thisVMSwitch.Name))]-[RDMAEnabledAdapter: $($thisRDMAEnabledAdapter.Name)]-[Tested Key: $_]-Should contain only recognized keys" {
                            $_ -in $legend | Should be $true
                        }
                    }

                    ### Verify each VMSwitch.RDMAEnabledAdapter includes the Name property from Get-NetAdapter
                    It "[Config File]-[AllNodes.VMSwitch.RDMAEnabledAdapters]-[Node: $($thisNode.NodeName)]-[Entry: $AdapterEntry]-[Noun: NetAdapter] Must include the Name property for each entry" {
                        $thisRDMAEnabledAdapter.Name | Should not BeNullOrEmpty 
                    }

                    ### Verify each VMSwitch.RDMAEnabledAdapter includes the Name property from Get-VMNetworkAdapter -ManagementOS
                    It "[Config File]-[AllNodes.VMSwitch.RDMAEnabledAdapters]-[Node: $($thisNode.NodeName)]-[Entry: $($thisRDMAEnabledAdapter.Name)]-[Noun: VMNetworkAdapter] Must include the VMNetworkAdapter property for each entry" {
                        $thisRDMAEnabledAdapter.VMNetworkAdapter | Should not BeNullOrEmpty 
                    }

                    ### Verify each VMSwitch.RDMAEnabledAdapter includes the VLANID property from Get-NetAdapterAdvancedProperty
                    It "[Config File]-[AllNodes.VMSwitch.RDMAEnabledAdapters]-[Node: $($thisNode.NodeName)]-[Entry: $($thisRDMAEnabledAdapter.Name)]-[Noun: NetAdapterAdvancedProperty] Must include the VLANID property for each entry" {
                        $thisRDMAEnabledAdapter.VLANID | Should not BeNullOrEmpty 
                    }

                    ### Verify each VMSwitch.RDMAEnabledAdapter's VLANID property is not 0
                    It "[Config File]-[AllNodes.VMSwitch.RDMAEnabledAdapters]-[Node: $($thisNode.NodeName)]-[Entry: $($thisRDMAEnabledAdapter.Name)]-[Noun: NetAdapterAdvancedProperty] VLANID property should not be non-zero" {
                        $thisRDMAEnabledAdapter.VLANID | Should Not Be '0'
                    }

                    ### Verify each VMSwitch.RDMAEnabledAdapter entry is not included in RDMADisabledAdapter
                    It "[Config File]-[AllNodes.VMSwitch.RDMAEnabledAdapters]-[Node: $($thisNode.NodeName)]-[Entry: $($thisRDMAEnabledAdapter.Name)]-[Noun: NetAdapterRDMA] Should not be in both VMSwitch.RDMAEnabledAdapters and RDMADisabledAdapters" {
                        $thisRDMAEnabledAdapter.Name -in $thisNode.RDMADisabledAdapters.Name | Should Be $false
                    }

                    ### Verify VMSwitch.RDMAEnabledAdapter Entry is not included in VMSwitch.RDMADisabledAdapter
                    It "[Config File]-[AllNodes.VMSwitch.RDMAEnabledAdapters]-[Node: $($thisNode.NodeName)]-[Entry: $($thisRDMAEnabledAdapter.Name)]-[Noun: NetAdapterRDMA] Should not be in both VMSwitch.RDMAEnabledAdapters and VMSwitch.RDMADisabledAdapters" {
                        $thisRDMAEnabledAdapter.Name -in $thisNode.VMSwitch.RDMADisabledAdapters.Name | Should Be $false
                    }

                    $AdapterEntry ++
                }

                $VMSwitchEntry ++
            }
        }

        $legend = @('NetQos', 'AzureAutomation')
        $configData.NonNodeData.Keys.GetEnumerator() | ForEach-Object {
            ### Verify that the only entries under $configData.NonNodeData are in $legend
            It "[Config File]-[NonNodeData]-[Tested key: $_] Should contain only recognized keys" {
                $_ -in $legend | Should be $true
            }
        }

        ### Verify NetQos is included in the config file
        It "[Config File]-[NonNodeData.NetQos] Config File must contain the NetQos section" {
            $ConfigData.NonNodeData.NetQos | Should not BeNullOrEmpty
        }

        ### Verify at least 3 policies exist in the Qos Policies (Default and one for SMB)
        It "[Config File]-[NonNodeData.NetQos]-[Noun: NetQosPolicy] NetQos must contain at least 3 policies" {
            $ConfigData.NonNodeData.NetQos.Count | Should BeGreaterThan 2
        }

        ### Verify the default policy is specified in the config file
        It "[Config File]-[NonNodeData.NetQos]-[Noun: NetQosPolicy] NetQos must specify a 'Default' policy" {
            $ConfigData.NonNodeData.NetQos.Name -contains 'Default' | Should be $true
        }

        ### Verify the Cluster policy is specified in the config file
        It "[Config File]-[NonNodeData.NetQos]-[Noun: NetQosPolicy] NetQos must specify a Cluster policy" {
            $ConfigData.NonNodeData.NetQos.Template -contains 'Cluster' | Should be $true
        }

        # Note: Templates only specify TCP settings and do not apply to RDMA
        #       For RDMA, please use NetDirectPortMatchCondition 

        ### Verify At least one policy must specify the NetDirectPortMatchCondition
        It "[Config File]-[NonNodeData.NetQos]-[Noun: NetQosPolicy] must specify the 'NetDirectPortMatchCondition' property for exactly 1 policy" {
            $ConfigData.NonNodeData.NetQos.Keys -contains 'NetDirectPortMatchCondition' | Should be $true
        }

        ### Verify Cluster Bandwidth Percentage is equal to 1%
        It "[Config File]-[NonNodeData.NetQos]-[Noun: NetQosTrafficClass] Cluster BandwidthPercentage must be 1%" {
            ($ConfigData.NonNodeData.NetQos.GetEnumerator().Where{ $_.Template -eq 'Cluster' }).BandwidthPercentage | Should be 1
        }

        ### Verify BandwidthPercentage totals 100
        It "[Config File]-[NonNodeData.NetQos]-[Noun: NetQosTrafficClass] BandwidthPercentage must total 100%" {
            ($ConfigData.NonNodeData.NetQos.BandwidthPercentage | Measure-Object -Sum).Sum | Should Be 100
        }

        $policyEntry = 1

        foreach ($thisPolicy in $ConfigData.NonNodeData.NetQos) {
            $legend = @('Name', 'NetDirectPortMatchCondition', 'Template', 'PriorityValue8021Action', 'BandwidthPercentage', 'Algorithm')
            $thisPolicy.Keys.GetEnumerator() | ForEach-Object {
                ### Verify that the only entries under $configData.NonNodeData.NetQos are in $legend
                It "[Config File]-[NonNodeData]-[Tested key: $_] Should contain only recognized keys" {
                    $_ -in $legend | Should be $true
                }
            }
            ### Verify Name property is specified for each policy
            It "[Config File]-[NonNodeData.NetQos]-[Policy Entry: $policyEntry]-[Noun: NetQosPolicy] Must specify the 'Name' property" {
                $thisPolicy.Name | Should not BeNullOrEmpty
            }

            ### Verify either NetDirectPortMatchCondition or Template are specified
            It "[Config File]-[NonNodeData.NetQos]-[Policy: $($thisPolicy.Name)]-[Noun: NetQosPolicy] Must specify either 'Template' or 'NetDirectPortMatchCondition' property" {
                ($thisPolicy.NetDirectPortMatchCondition -or $thisPolicy.Template) | Should Be $true
            }

            ### Verify PriorityValue8021Action is specified
            It "[Config File]-[NonNodeData.NetQos]-[Policy: $($thisPolicy.Name)]-[Noun: NetQosPolicy] Must specify the 'PriorityValue8021Action' property" {
                $thisPolicy.PriorityValue8021Action | Should not BeNullOrEmpty
            }

            ### Verify BandwidthPercentage is specified
            It "[Config File]-[NonNodeData.NetQos]-[Policy: $($thisPolicy.Name)]-[Noun: NetQosTrafficClass] Must specify the 'BandwidthPercentage' property" {
                $thisPolicy.BandwidthPercentage | Should not BeNullOrEmpty
            }

            ### Verify Algorithm is specified
            It "[Config File]-[NonNodeData.NetQos]-[Policy: $($thisPolicy.Name)]-[Noun: NetQosTrafficClass] Must specify the 'Algorithm' property" {
                $thisPolicy.Algorithm | Should not BeNullOrEmpty
            }

            $policyEntry ++
        }
    }

    $ConfigData.AllNodes | ForEach-Object {
        $nodeName = $_.NodeName
        
        Context "[Global Unit]-[SUT: $nodeName]-Connectivity Tests" {
            ### Verify Basic Network Connectivity to each Node
            It "[Global Unit]-[SUT: $nodeName] must respond to available over the network" {
                Test-NetConnection -ComputerName $nodeName -InformationLevel Quiet | Should Be $true
            }

            ### Verify each node responds to WinRM
            It "[Global Unit]-[SUT: $nodeName] must respond to WinRM requests" {
                Test-NetConnection -ComputerName $nodeName -CommonTCPPort WINRM -InformationLevel Quiet | Should Be $true
            }
        }

        Context "[Global Unit]-[SUT: $nodeName]-System Requirements" {
            $NodeOS = Get-CimInstance -CimSession $nodeName -ClassName 'Win32_OperatingSystem'

            ### Verify the SUTs are Server SKU, 2016 or Higher
            It "[Global Unit]-[SUT: $nodeName] must be Server 2016, or Server 2019" {
                $caption =  ($NodeOS.Caption -like '*Windows Server 2016*') -or
                            ($NodeOS.Caption -like '*Windows Server 2019*') 
                
                $caption | Should be $true
            }

            $reqModules  = @('DcbQos', 'NetQos', 'NetAdapter','ServerManager')
            $reqFeatures = @('Data-Center-Bridging')

            # Add Hyper-V to the list if there's at least one vmSwitch defined in the config
            If ($ConfigData.AllNodes.VMSwitch.Count -ge 1) {
                $reqFeatures += 'Hyper-V'
                $reqModules  += 'Hyper-V'
            }

            $actModules, $actFeatureState = Invoke-Command -ComputerName $nodeName -ScriptBlock {
                $deploy       = $using:deploy
                $modules      = Get-Module         -Name $using:reqModules -ListAvailable -ErrorAction SilentlyContinue
                $featureState = Get-WindowsFeature -Name $using:reqFeatures -ErrorAction SilentlyContinue

                return $Modules, $featureState
            }         

            ### Verify that the required features exist on the SUT
            $reqFeatures | ForEach-Object {
                It "[Global Unit]-[SUT: $nodeName] should have the Windows Feature [$_] installed" {
                    ($actFeatureState | Where-Object Name -eq $_).InstallState | Should be 'Installed'
                } 
            }

            ### Verify that each required module existed on the SUT
            $reqModules | ForEach-Object {
                It "[Global Unit]-[SUT: $nodeName] should have the module [$_] installed" {
                    ($actModules | Where-Object Name -eq $_) | Sort-Object Version -Descending | Select-Object -First 1 | Should be $true
                }
            }

            ### Verify the following cmdlets are available on each SUT
            $reqCmdlets  = @('Get-WindowsFeature','Get-NetQosPolicy', 'Get-NetQosFlowControl',
                            'Get-NetQosTrafficClass', 'Get-NetAdapterQos', 'Get-NetQosDcbxSetting')

            # Add Hyper-V cmdlets to the list if there's at least one vmSwitch defined in the config
            If ($ConfigData.AllNodes.VMSwitch.Count -ge 1) {
                $reqCmdlets += 'Get-VMSwitch'
            }

            $reqCmdlets | ForEach-Object {
                It "[Global Unit]-[SUT: $nodeName] should have the cmdlet [$_] available" {
                    $actModules.ExportedCommands.Values -contains $_ | Should be $true
                }
            }

            ### Verify none of the nodes are actually virtual machines
            It "[Global Unit]-[SUT: $nodeName] should not be a virtual machine" {
                (Get-CimInstance -ComputerName $nodeName -ClassName Win32_ComputerSystem) | Should Not Be 'Virtual Machine'
            }
        }
    }

    If ($deploy) {
        Context "Deployment" {
            $AzureRMContext = Get-AzureRmContext -ErrorAction SilentlyContinue
            It '[Global Unit]-[Noun: AzureRMContext] Azure Context should be logged in using Connect-AzureRMAccount' {
                $AzureRMContext | Should Not BeNullOrEmpty
            }

            It "[Global Unit]-[Noun: AzureRMContext] Azure Context specifies an account. Current Account is [$($AzureRMContext.Account.ID)]" {
                $AzureRMContext.Account | Should Not BeNullOrEmpty
            }

            It "[Global Unit]-[Noun: AzureRMContext] Azure Context specifies a subscription. Current subscription [$($AzureRMContext.Subscription.Name)]" {
                $AzureRMContext.Subscription.Name | Should Not BeNullOrEmpty
            }

            $AzureRMResourceGroup = Get-AzureRmResourceGroup -Name $configData.NonNodeData.AzureAutomation.ResourceGroupName -ErrorAction SilentlyContinue
            It "[Global Unit]-[Noun: AzureRmResourceGroup] Azure Resource Group [$($configData.NonNodeData.AzureAutomation.ResourceGroupName)] should be available in the account" {
                $AzureRMResourceGroup | Should Not BeNullOrEmpty
            }

            # Sub-expression required for cmdlet to work properly
            $AzureRMAutomationAccount = Get-AzureRmAutomationAccount -Name $configData.NonNodeData.AzureAutomation.AutomationAccountName -ResourceGroupName $($configData.NonNodeData.AzureAutomation.ResourceGroupName) -ErrorAction SilentlyContinue

            It "[Global Unit]-[Noun: AzureRmAutomationAccount] Azure Automation Account [$($configData.NonNodeData.AzureAutomation.AutomationAccountName)] should be found in the Resource Group" {
                $AzureRMAutomationAccount | Should Not BeNullOrEmpty
            }
        }
    }
}
