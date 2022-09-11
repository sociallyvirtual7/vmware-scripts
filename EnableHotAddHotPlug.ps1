Connect-VIServer vCenter_Hostname -Credential (Get-Credential)

$vms = Get-VM | where {($_.PowerState -eq "PoweredOff") -and ($_.ExtensionData.Summary.Runtime.ConnectionState -eq "connected")}

$spec = New-Object VMware.Vim.VirtualMachineConfigSpec
$spec.CpuHotAddEnabled = $true
$spec.MemoryHotAddEnabled = $true

foreach ($vm in $vms)
{

    if(-not $vm.ExtensionData.Config.cpuHotAddEnabled -or -not $vm.ExtensionData.Config.memoryHotAddEnabled){
    $vm.ExtensionData.ReconfigVM($spec)
    }
}
Disconnect-VIServer -Confirm:$false