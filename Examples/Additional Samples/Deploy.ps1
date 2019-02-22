$AllNodes    = @()
$NonNodeData = @()

$Nodes = 'TK5-3WP07R0511', 'TK5-3WP07R0512'

$Nodes | ForEach-Object {
	$AllNodes   += @{
        NodeName = $_

        Role = 'S2DClusterNode'

        VMSwitch = @(
            @{
                Name = 'VMSTest'
                EmbeddedTeamingEnabled = $true

                RDMAEnabledAdapters = @(
                    @{ Name = 'RoCE-01'  ; VMNetworkAdapter = 'SMB01' ; VLANID = '101' ; JumboPacket = 9014 }
                    @{ Name = 'RoCE-02'  ; VMNetworkAdapter = 'SMB02' ; VLANID = '101' ; JumboPacket = 9014 }
                )

                RDMADisabledAdapters = @(
                    @{ VMNetworkAdapter = 'Mgmt' }
                )
            }
        )
    }
}

$NonNodeData = @{
    NetQoS = @(
        @{ Name = 'Cluster' ; Template = 'Cluster'              ; PriorityValue8021Action = 7 ; BandwidthPercentage = 1  ; Algorithm = 'ETS' }
        @{ Name = 'SMB'     ; NetDirectPortMatchCondition = 445 ; PriorityValue8021Action = 3 ; BandwidthPercentage = 60 ; Algorithm = 'ETS' }
        @{ Name = 'DEFAULT' ; Template = 'Default'              ; PriorityValue8021Action = 0 ; BandwidthPercentage = 39 ; Algorithm = 'ETS' }
    )

    AzureAutomation = @{
        ResourceGroupName = 'RG-Automation'
        AutomationAccountName = 'Automation'
    }
}

$Global:configData = @{
    AllNodes    = $AllNodes
    NonNodeData = $NonNodeData
}
