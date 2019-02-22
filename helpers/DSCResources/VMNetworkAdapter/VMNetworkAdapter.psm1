enum Ensure {
    Absent
    Present
}

[DscResource()]
Class VMNetworkAdapterTeamMapping {
    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    [DscProperty(Key)]
    [String] $PhysicalNetAdapterName

    [DscProperty(Key)]
    [String] $VMNetworkAdapterName

    [VMNetworkAdapterTeamMapping] Get() {
        $VMNetworkAdapterTeamMapping = Get-VMNetworkAdapterTeamMapping -ManagementOS -VMNetworkAdapterName $this.VMNetworkAdapterName

        $this.PhysicalNetAdapterName = $VMNetworkAdapterTeamMapping.NetAdapterName
        $this.VMNetworkAdapterName   = $VMNetworkAdapterTeamMapping.ParentAdapter.Name

        return $this
    }

    [bool] Test() {
        $VMNetworkAdapterTeamMapping = Get-VMNetworkAdapterTeamMapping -ManagementOS -VMNetworkAdapterName $this.VMNetworkAdapterName

        $testState = $false
        if ($this.Ensure -eq [Ensure]::Present) {
            If ($VMNetworkAdapterTeamMapping.NetAdapterName -eq $this.PhysicalNetAdapterName -and
                    $VMNetworkAdapterTeamMapping.ParentAdapter.Name -eq $this.VMNetworkAdapterName) {
                $testState = $true
            }
            Else { $testState =  $false }
        }
        elseif ($this.Ensure -eq [Ensure]::Absent) {
            If ($VMNetworkAdapterTeamMapping) { $testState = $false }
            Else { $testState =  $true }
        }

        Return $testState
    }

    [Void] Set() {
        if ($this.Ensure -eq [Ensure]::Present) {
            Write-Verbose "Mapping $($this.VMNetworkAdapterName) to $($this.PhysicalNetAdapterName)"
            Set-VMNetworkAdapterTeamMapping -ManagementOS -VMNetworkAdapterName $this.VMNetworkAdapterName -PhysicalNetAdapterName $this.PhysicalNetAdapterName
            Write-Verbose "$($this.VMNetworkAdapterName) is now mapped to $($this.PhysicalNetAdapterName)"
        }
        elseif ($this.Ensure -eq [Ensure]::Absent) {
            Write-Verbose "Removing team mapping for $($this.VMNetworkAdapterName)"
            Remove-VMNetworkAdapterTeamMapping -ManagementOS -Name $this.VMNetworkAdapterName
            Write-Verbose "Team mapping for $($this.VMNetworkAdapterName) is now removed"
        }
    }
}

[DscResource()]
Class VMNetworkAdapterSettings {
    [DscProperty(Key)]
    [String] $VMNetworkAdapterName

    [DscProperty(Mandatory)]
    [String] $VMName = 'ManagementOS'

    [DscProperty()]
    [ValidateSet('On','Off')]
    [String] $IeeePriorityTag = 'Off'

    [VMNetworkAdapterSettings] Get() {
        $params = @{}

        if ($this.VMName -eq 'ManagementOS') {
            $params.Add('ManagementOS', $true)
        }
        else { $params.Add('VMName', $this.VMName)} 

        $VMNetworkAdapter = Get-VMNetworkAdapter -VMNetworkAdapterName $this.VMNetworkAdapterName @params -ErrorAction SilentlyContinue

        $this.VMNetworkAdapterName = $VMNetworkAdapter.Name
        $this.IeeePriorityTag = $VMNetworkAdapter.IeeePriorityTag

        return $this
    }

    [bool] Test() {
        $params = @{}
        if ($this.VMName -eq 'ManagementOS') {$params.Add('ManagementOS', $true)}
        else {$params.Add('VMName', $this.VMName)} 

        $VMNetworkAdapter = Get-VMNetworkAdapter -VMNetworkAdapterName $this.VMNetworkAdapterName @params -ErrorAction SilentlyContinue

        $testState = $false
        If ($this.IeeePriorityTag -eq $VMNetworkAdapter.IeeePriorityTag) { $testState = $true }
        Else { $testState =  $false }

        Return $testState
    }

    [Void] Set() {
        $params = @{}
        if ($this.VMName -eq 'ManagementOS') {$params.Add('ManagementOS', $true)}
        else {$params.Add('VMName', $this.VMName)} 

        $VMNetworkAdapter = Get-VMNetworkAdapter -VMNetworkAdapterName $this.VMNetworkAdapterName @params -ErrorAction SilentlyContinue

        if ($this.IeeePriorityTag -ne $VMNetworkAdapter.IeeePriorityTag) {
            Write-Verbose "Configuring IEEEPriorityTag on vNIC $($VMNetworkAdapter.Name) to $($this.IeeePriorityTag)"
            Set-VMNetworkAdapter -VMNetworkAdapterName $this.VMNetworkAdapterName @params -IeeePriorityTag $this.IeeePriorityTag
            Write-Verbose "IEEEPriorityTag on vNIC $($VMNetworkAdapter.Name) is now $($this.IeeePriorityTag)"
        }
    }
}

[DscResource()]
Class VMNetworkAdapterIsolation {
    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    [DscProperty(Key)]
    [String] $VMNetworkAdapterName

    [DscProperty(Mandatory)]
    [ValidateRange(0,4096)]
    [uint16] $DefaultIsolationID

    [DscProperty()]
    [Boolean] $AllowUntaggedTraffic

    [DscProperty()]
    [ValidateSet('Vlan','None')]
    [String] $IsolationMode

    [VMNetworkAdapterIsolation] Get() {
        $VMNetworkAdapterIsolation = Get-VMNetworkAdapterIsolation -ManagementOS -VMNetworkAdapterName $this.VMNetworkAdapterName

        $this.IsolationMode = $VMNetworkAdapterIsolation.IsolationMode
        $this.DefaultIsolationID   = $VMNetworkAdapterIsolation.DefaultIsolationID
        $this.AllowUntaggedTraffic = $VMNetworkAdapterIsolation.AllowUntaggedTraffic

        return $this
    }

    [bool] Test() {
        $VMNetworkAdapterIsolation = Get-VMNetworkAdapterIsolation -ManagementOS -VMNetworkAdapterName $this.VMNetworkAdapterName

        $testState = $false
        if ($this.Ensure -eq [Ensure]::Present) {
            if (     $VMNetworkAdapterIsolation.IsolationMode        -eq $this.IsolationMode `
                -and $VMNetworkAdapterIsolation.AllowUntaggedTraffic -eq $this.AllowUntaggedTraffic `
                -and $VMNetworkAdapterIsolation.DefaultIsolationID   -eq $this.DefaultIsolationID )
            { $testState = $true }
            else { $testState = $false }
        }
        elseif ($this.Ensure -eq [Ensure]::Absent) {
            If ($VMNetworkAdapterIsolation) { $testState = $false }
            Else { $testState =  $true }
        }

        Return $testState
    }

    [Void] Set() {
        if ($this.Ensure -eq [Ensure]::Present) {
            Write-Verbose "Removing VMNetworkAdapterVlan if configured on $($this.VMNetworkAdapterName)"
            Set-VMNetworkAdapterVlan -ManagementOS -VMNetworkAdapterName $this.VMNetworkAdapterName -Untagged

            Write-Verbose "Configuring Isolation for $($this.VMNetworkAdapterName)"
            Set-VMNetworkAdapterIsolation -ManagementOS -IsolationMode $this.IsolationMode -DefaultIsolationID $this.DefaultIsolationID`
                -AllowUntaggedTraffic $this.AllowUntaggedTraffic -VMNetworkAdapterName $this.VMNetworkAdapterName

            Write-Verbose "VLAN Isolation for $($this.VMNetworkAdapterName) is now configured"
        }
        elseif ($this.Ensure -eq [Ensure]::Absent) {
            Write-Verbose "Resetting Isolation for $($this.VMNetworkAdapterName)"
            Set-VMNetworkAdapterIsolation -ManagementOS -VMNetworkAdapterName $this.VMNetworkAdapterName -IsolationMode 'None'
            Write-Verbose "Isolation for $($this.VMNetworkAdapterName) is now reset"
        }
    }
}
