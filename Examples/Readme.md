# Configuration File

This section will help you use or create a configuration file. We recommend that you create a separate configuration file:

- Per stamp, or cluster
- If the configuration changes between nodes

## Example Configurations

The [Converged NIC Guide](https://aka.ms/ConvergedRDMA) guides you through the implementation of NDK Mode 1 (Native RDMA) and NDK Mode 2 (Host Virtual NIC RDMA).  If your configuration matches those examples exactly, you can use the pre-defined configurations in the examples folder to validate your system.

&emsp;&emsp;<img src="..\helpers/pics/Examples.png" width="250">

While your actual environment may not match this configuration exactly, this provides a DIY learning opportunity when coupled with the configuration guide.

To leverage these example configurations, specify the ****ExampleConfig**** parameter during initiate.

To specify the *NDKm1-examples.DCB.config* example file

> ```
> .\initiate.ps1 -ExampleConfig NDKm1
> ```

To specify the *NDKm2-examples.DCB.config* example file

> ```
> .\initiate.ps1 -ExampleConfig NDKm2
> ```

## Additional Samples

The [Example Configurations](#Example-Configurations) may not meet your exact configuration so we provide some additional samples of commonly seen customer scenarios.  The samples in the ****\examples\additional samples**** folder show you have to create a configuration file for more complex scenarios.  This folder contains the following examples:

|     FileName       | Description |
| -----------------  | ----------- |
| Cluster-Single.ps1 | Configuration with a single cluster  |
| Cluster-Multi.ps1  | Configuration with multiple clusters | 
| UniqueConfigs.ps1  | Configuration with nodes containing unique configurations |
| MultipleVMSwitch.ps1 | Configuration containing multiple VMSwitches       |
| ComboModes.ps1 | Configuration with Native RDMA and Host Virtual NIC RDMA |


## Custom Configuration

It is likely that you will need to create a custom configuration.  We recommend starting with the example/sample that most closely represents your configuration.  Next, use the following guidance to update the configuration.

This section outlines the requirements and possibilities in the configuration file.

### $ConfigData

During runtime, a global variable named $ConfigData carries the data from the config file.  This variable has two sub-keys:

- ****AllNodes**** contains details specific to one or more nodes e.g. NodeNames, RDMA Adapters, VMSwitch configuration, etc.
- ****NonNodeData**** contains data that applies to all nodes

:information_source: ****Note:**** Even if your configuration doesn’t change node to node, they should stay in the same structure.  Currently only the ****NetQos**** settings belong in the ****NonNodeData****.

&emsp;&emsp;<img src="..\helpers\pics\ConfigDataConfigFile.png" width="300">

### NonNodeData

#### NonNodeData.NetQos

NetQos policies and traffic classes are defined under the NonNodeData section.  Each NetQos policy defined requires the following entries:

- ****Name**** This is the name of the NetQosPolicy and Traffic class expected on systems
- ****NetDirectPortMatchCondition**** or ****Template**** 
    - RDMA requires the use of the ****NetDirectPortMatchCondition**** entry.
    - ****Template**** can only be used to specify non-RDMA traffic.
- ****PriorityValue8021Action**** The expected Priority of the NetQos and Traffic Class
- ****BandwidthPercentage**** A reservation for that traffic class
- ****Algorithm**** The expected Algorithm to be used – Currently, the only Algorithm is ETS

Here is an example NetQos configuration.  As you can see each policy has it’s own hashtable of keys and values specified above.  This specific example expects the nodes to have three NetQos policies and traffic classes.

<img src="..\helpers\pics\NonNodeData.png">

The first defined policy is named ****ClusterHB**** which uses the ****Cluster template****, is assigned ****Priority 5****, a ****Bandwidth Reservation**** of ****1%**** of the adapter's bandwidth, and uses the ****ETS Algorithm****.

The second policy is named ****SMB****, defines the ****NetDirectPortMatchCondition**** (instead of the template) for port ****445****, a ****priority**** of ****3****, a ****bandwidth reservation**** of ****60%**** of the adapter's bandwidth, and uses the ****ETS Algorithm.****

This configuration will check for a configuration on the node like this:

<img src="..\helpers\pics\Get-NetQosPolicy.png" >

<img src="..\helpers\pics\Get-NetQosTrafficClass.png" >

### AllNodes

#### AllNodes.NodeName

Each node to be tested (SUT) must be defined in the configuration file.  Since nodes in a cluster will have the same configuration, you can use PowerShell to simplify the work you need to perform.  Each node with the same configuration can be defined using the ****$Nodes**** Variable as shown here:

&emsp;&emsp;<img src="..\helpers\pics\Nodes.png" >

To get a list of nodes from a cluster:

&emsp;&emsp;<img src="..\helpers\pics\Get-ClusterNode.png" >

However you generate your list of nodes, they must be comma separated so they can be passed across a pipeline as shown here.

&emsp;&emsp;<img src="..\helpers\pics\ForEach-Object.png" >

#### AllNodes.RDMAEnabledAdapters

Adapters entered in this section are in Native RDMA mode (not attached to a vSwitch) – This section is optional, however there must be at least one adapter defined between this section and [AllNodes.VMSwitch.RDMAEnabledAdapters](#AllNodes.VMSwitch.RDMAEnabledAdapters) defined later.

&emsp;&emsp;<img src="..\helpers\pics\RDMAEnabledAdapters.png" >

> :warning: Do not put RDMAEnabledAdapters in mode 2 (attached to a vSwitch) in this section.

The following options are currently supported:
- ****Name**** - (Required) The name of the adapter.  Use `Get-NetAdapter` to determine the adapter name

- ****VLANID**** - (Required) The VLAN assigned to the adapter.  Use `Get-NetAdapterAdvancedProperty -RegistryKeyword VLANID` to determine the assigned VLAN

- ****JumboPacket**** - (Optional) The jumbo frame size expected on the adapter.  Use the following command to determine the assigned jumbo frame size `Get-NetAdapterAdvancedProperty -RegistryKeyword *JumboPacket`

This configuration will check for a configuration on the node like this:

&emsp;&emsp;<img src="..\helpers\pics\Get-NetAdapterRDMA.png" >

&emsp;&emsp;<img src="..\helpers\pics\Get-NetAdapterAdvancedPropertyVLAN.png" >

&emsp;&emsp;<img src="..\helpers\pics\Get-NetAdapterAdvancedPropertyJumbo.png" >

#### AllNodes.RDMADisabledAdapters

This section is optional. The tool will verify that any adapter specified here has RDMA disabled. For example, using `Get-NetAdapterRDMA` to identify that RDMA is disabled.

The following options are currently supported:
- ****Name**** - The name of the adapter.  Use `Get-NetAdapter` to determine the adapter name

> :warning: Do not put host virtual NICs that should be RDMA Disabled in this section.  These virtual NICs should be defined in ****AllNodes.VMSwitch.RDMADisabledAdapters**** defined later.

#### AllNodes.VMSwitch

This section defines one or more VMSwitch(es) configured on the systems. Each VMSwitch defined requires the following entries:

The following options are currently supported:

- ****Name**** (Required)
    - ****Type:**** [System.String]
    - ****Description:**** The Name of the VMSwitch
    - ****Note:**** Use `Get-VMSwitch` to determine the Name

&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;<img src="..\helpers\pics\Get-VMSwitchName.png" >

- ****EmbeddedTeamingEnabled**** (Required)
    - ****Type**** [System.Boolean]
    - ****Description**** Defines whether this is an embedded team (SET)
    - ****Note:**** Use `Get-VMSwitch | Select *Embedded*` to determine if this is an embedded team

&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; <img src="..\helpers\pics\Get-VMSwitchSET.png" >

> :warning: If this is NOT a SET team, there can only be one adapter listed in the corresponding VMSwitch.RDMAEnabledAdapters section

- ****IovEnabled**** (Optional)
    - ****Type:**** [System.Boolean]
    - ****Description:**** Defines whether the VMSwitch should support SR-IOV
    - ****Note:**** Use `Get-VMSwitch | Select IovEnabled` to determine the Name

&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;<img src="..\helpers\pics\Get-VMSwitchIov.png" >

- ****LoadBalancingAlgorithm**** (Optional)
    - ****Type:**** [System.String]
    - ****Possible Entries:**** 'HyperVPort' or 'Dynamic'
    - ****Description:**** Defines the load balancing algorithm for the VMSwitch
    - ****Note:**** Use `Get-VMSwitch | Select *LoadBalancing*` to determine the algorithm

&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;<img src="..\helpers\pics\Get-VMSwitchLoadBalancing.png" >

> :information_source: ****Note:**** The Load Balancing Algorithm of ****Hyper-V**** is now the recommended for Windows Server 2016 and Windows Server 2019.

#### AllNodes.VMSwitch.RDMAEnabledAdapters

Adapters entered in this section are in Host Virtual NIC RDMA mode (attached to a vSwitch).  This section is optional, however there must be at least one adapter defined between this section and [AllNodes.RDMAEnabledAdapters](#AllNodes.RDMAEnabledAdapters) defined previously.

&emsp;&emsp; <img src="..\helpers\pics\VMSwitch_RDMAEnabledAdaptersFull.png" >

> :warning: Do not put RDMAEnabledAdapters in mode 1 (native RDMA adapters) in this section.

The following options are currently supported:
- ****Name**** - (Required) The name of the adapter.  Use `Get-NetAdapter` to determine the adapter name

- ****VMNetworkAdapter**** - The name of the virtual adapter.  Use `Get-VMNetworkAdapter -ManagementOS` to determine the adapter name

- ****VLANID**** - (Required) The VLAN assigned to the adapter.  Use `Get-NetAdapterAdvancedProperty -RegistryKeyword VLANID` to determine the assigned VLAN

- ****JumboPacket**** - (Optional) The jumbo frame size expected on the adapter.  Use the following command to determine the assigned jumbo frame size `Get-NetAdapterAdvancedProperty -RegistryKeyword *JumboPacket`

RDMA Adapters in this mode require a host vNIC.  To avoid ambiguity for the virtual NICs names, we chose to use the ****VMNetworkAdapter**** parameter.

&emsp;&emsp; <img src="..\helpers\pics\Get-VMNetworkAdapter.png" >

&emsp;&emsp; <img src="..\helpers\pics\Get-VMNetworkAdapterTeamMapping.png" >

#### AllNodes.VMSwitch.RDMADisabledAdapters

This section is optional.  The tool will verify that any adapter or VMNetworkAdapter specified here has RDMA disabled.  As an example, you might want SMB01 and SMB02 to have RDMA enabled, but Mgmt VMNetworkAdapter (which is likely connected to a different vlan) to have RDMA disabled.

The following options are currently supported:

- ****Name**** - The name of the adapter.  Use `Get-NetAdapter` to determine the adapter name

- ****VMNetworkAdapter**** - The name of the virtual adapter.  Use `Get-VMNetworkAdapter -ManagementOS` to determine the adapter name

For example, using `Get-NetAdapterRDMA` to identify that RDMA is disabled.

&emsp;&emsp; <img src="..\helpers\pics\VMSwitch_RDMADisabledAdapters.png" >

