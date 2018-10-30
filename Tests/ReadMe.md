# Tests list and Descriptions

## Global Tests

Environmental tests.  If you can't / don't pass these, you will see a lot of red on the screen.

### The TestHost

#### Verify TestHost has Pester Module

#### Verify TestHost has the 3x Version of Pester

This testing infrastructure uses the default Pester Module included with Windows 10, Server 2016, or Server 2019

#### Verify the TestHost is sufficient version

The system testing others must be running either Windows 10, Server 2016, or Server 2019

#### Verify PowerShell Modules are available on the TestHost

We require certain PowerShell modules and cmdlets to run the tests

#### Verify PowerShell cmdlets are available on the TestHost

We require certain PowerShell modules and cmdlets to run the tests

### The Config File

Verifying the config file for structural integrity.

#### Verify the config file exists

You can use either a default config file from our examples folder using the $ExampleConfig variable in the \examples folder OR the $ConfigFilePath.  Either way, this file must exist in the expected or user-defined location.

#### Verify configData contains the AllNodes HashTable

This section of the config file is required and defines the nodes, vSwitches, and configured adapters. Please see the examples file for structural setup.

#### Verify configData contains the NonNodeData HashTable

This section of the config file is required for configuration items that are not specific to a Node.  For example, the NetQos configuration must be the same on all nodes and so is not identified with a Node (virtual switches, vNICs etc. may be different per host, if setup in the config file properly). Please see the examples file for structural setup.

#### Verify that the entries under $configData are in $legend

Verify that entries under $configData are one of 'AllNodes' or 'NonNodeData'

#### Verify at least one node is specified [NodeName]

Please see the examples file for structural setup.

#### Verify nodes are only listed once in the config file [NodeName]

Cannot have duplicate names or conflicts can occur and/or extends the testing time

#### Verify Config File includes at least one RDMAEnabledAdapters entry

At least one RDMA Adapter must be specified under: AllNodes.RDMAEnabledAdapters or AllNodes.vmswitch.RDMAEnabledAdapters

#### Verify that the entries under $configData.AllNodes are in $legend

Verify that entries under $configData.AllNodes are one of 'NodeName','RDMAEnabledAdapters','RDMADisabledAdapters','VMSwitch'

### ConfigFile.RDMAEnabledAdapters

This section is optional, but at least one of AllNodes.RDMAEnabledAdapters or AllNodes.vmswitch.RDMAEnabledAdapters must be specified.  If this section is specified, these tests will verify proper format and required parameters.

Adapters in this section are expected to be configured for Native RDMA (NDK Mode 1)

#### Verify each RDMAEnabledAdapter includes the Name property from Get-NetAdapter

Use Get-NetAdapter to identify the physical adapter name

#### Verify each RDMAEnabledAdapter includes the VLANID property from Get-NetAdapterAdvancedProperty

A vlan is required for RDMA.  Use the Get-NetAdapterAdvancedProperty cmdlet to identify the RegistryValue for the RegistryKeyword of VLANID for the specific physical adapter.

#### Verify each RDMAEnabledAdapter's VLANID property is not '0'

A vlan is required for RDMA. Zero cannot be used.

#### Verify RDMAEnabledAdapter Entry is not included in RDMADisabledAdapter

This is a conflict.  A physical adapter cannot be both enabled for RDMA and Disabled.

#### Verify RDMAEnabledAdapter Entry is not included in vmswitch.RDMADisabledAdapter

This is a conflict.  A physical adapter attached to a VMSwitch should only be specified in the VMSwitch.RDMAEnabledAdapters section.  In addition, it should not be specified in the VMSwitch.RDMADisabledAdapter.

#### Verify entries under $configData.AllNodes.VMSwitch.RDMADisabledAdapters are in $legend

Verify that entries under $configData.AllNodes.VMSwitch.RDMADisabledAdapters are one of 'Name','VMNetworkAdapter'

### ConfigFile.VMSwitch.RDMAEnabledAdapters

This section is optional, but at least one of AllNodes.RDMAEnabledAdapters or AllNodes.vmswitch.RDMAEnabledAdapters must be specified.  If this section is specified, these tests will verify proper format and required parameters.

Adapters in this section are expected to be configured for Virtual NIC RDMA (NDK Mode 2)

#### Verify that the entries under $configData.AllNodes.VMSwitch are in $legend

Verify that entries under $configData.AllNodes.VMSwitch are one of 'Name','EmbeddedTeamingEnabled','IovEnabled','LoadBalancingAlgorithm','RDMAEnabledAdapters','RDMADisabledAdapters'

#### Verify VMSwitch entry contains the Name property

Use Get-VMSwitch to identify the VMSwitch name

#### Verify VMSwitch entry contains the EmbeddedTeamingEnabled property

This property is required for specified VMSwitches.

#### Verify VMSwitch EmbeddedTeamingEnabled property is a boolean

Possible values include $true or $false

#### Verify VMSwitch IovEnabled property is a boolean

Optional.  If specified, this must be a boolean

#### Verify VMSwitch Load Balancing Algorithm is either Dynamic (2016 Default) or HyperVPort (2019 Default)

Optional.  If specified the value must be either HyperVPort or Dynamic

### Verify VMSwitch.Name entries are unique

#### Verify that the only entries under $configData.AllNodes.VMSwitch.RDMAEnabledAdapters are in $legend

Verify that entries under $configData.AllNodes.VMSwitch.RDMAEnabledAdapters are one of 'Name','VMNetworkAdapter','VLANID','JumboPacket'

#### Verify each VMSwitch.RDMAEnabledAdapter includes the Name property from Get-NetAdapter

#### Verify each VMSwitch.RDMAEnabledAdapter includes the Name property from Get-VMNetworkAdapter -ManagementOS

The config file requires VMNetworkAdapter names for a virtual NIC rather than the Get-NetAdapter vNIC name.  This is intended to avoid ambiguity and simplify scenarios where customers have no renamed Get-NetAdapter and Get-VMNetworkAdapter

#### Verify each VMSwitch.RDMAEnabledAdapter includes the VLANID property from Get-NetAdapterAdvancedProperty

A vlan is required for RDMA.  Use the Get-NetAdapterAdvancedProperty cmdlet to identify the RegistryValue for the RegistryKeyword of VLANID for the specific physical adapter.

#### Verify each VMSwitch.RDMAEnabledAdapter's VLANID property is not 0

A vlan is required for RDMA. Zero cannot be used.

#### Verify each VMSwitch.RDMAEnabledAdapter entry is not included in RDMADisabledAdapter

Cannot have duplicate names or conflicts can occur and/or extends the testing time

#### Verify VMSwitch.RDMAEnabledAdapter Entry is not included in VMSwitch.RDMADisabledAdapter

Cannot have duplicate names or conflicts can occur and/or extends the testing time

#### Verify that the only entries under $configData.NonNodeData are in $legend

Verify that entries under $configData.NonNodeData are one of 'NetQos'

#### Verify NetQos is included in the config file

NetQos section is required

#### Verify at least 2 policies exist in the Qos Policies (Default and one for SMB)

Two policies are the minimum required

#### Verify the default policy is specified in the config file

#### Verify At least one policy must specify the NetDirectPortMatchCondition

This property identifies the RDMA port. If template is used instead of NetDirectPortMatchCondition, RDMA is not used.

#### Verify BandwidthPercentage totals 100

### Verify that the only entries under $configData.NonNodeData.NetQos are in $legend

Verify that entries under $configData.NonNodeData.NetQos are one of 'Name', 'NetDirectPortMatchCondition', 'Template', 'PriorityValue8021Action', 'BandwidthPercentage'. 'Algorithm'

#### Verify Name property is specified for each policy

#### Verify either NetDirectPortMatchCondition or Template are specified

#### Verify PriorityValue8021Action is specified

#### Verify BandwidthPercentage is specified

#### Verify Algorithm is specified

### The Systems Under Test

#### Verify Basic Network Connectivity to each Node

#### Verify each node responds to WinRM

#### Verify the SUTs are Server SKU, 2016 or Higher

2016 or 2019 Server SKUs are required

#### Verify that the required features exist on the SUT

#### Verify that each required module existed on the SUT

#### Verify the following cmdlets are available on each SUT

#### Verify none of the nodes are actually virtual machines

Each node in AllNodes must be a physical machine or a bunch or many errors will ensue...
