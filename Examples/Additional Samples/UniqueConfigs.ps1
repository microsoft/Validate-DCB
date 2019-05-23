$AllNodes    = @()
$NonNodeData = @()

# Custom helper to get nodes from multiple clusters
$Nodes = 'TK5-3WP07R0511', 'TK5-3WP07R0512'

$Nodes | ForEach-Object {
	$AllNodes   += @{
        NodeName = $_
        
        RDMAEnabledAdapters = @(
            @{ Name = 'RoCE-01' ; VLANID = '101' ; JumboPacket = 9000 }
            @{ Name = 'RoCE-02' ; VLANID = '101' ; JumboPacket = 9000 }
        )

        RDMADisabledAdapters = @(
            @{ Name = 'Mgmt' }
            @{ Name = 'Clus' }
        )
    }
}

# Custom helper to get nodes from multiple clusters
$Nodes = Get-DCBClusterNodes -Clusters 'S2DCluster01', 'S2DCluster02'

$Nodes | ForEach-Object {
	$AllNodes   += @{
        NodeName = $_
        
        VMSwitch = @(
            @{
                Name = 'VMSTest'
                EmbeddedTeamingEnabled = $true

                RDMAEnabledAdapters = @(
                    @{ Name = 'RoCE-01'  ; VMNetworkAdapter = 'SMB01' ; VLANID = '101' ; JumboPacket = 9000 }
                    @{ Name = 'RoCE-02'  ; VMNetworkAdapter = 'SMB02' ; VLANID = '101' ; JumboPacket = 9000 }
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
}

$Global:configData = @{
    AllNodes    = $AllNodes
    NonNodeData = $NonNodeData
}
