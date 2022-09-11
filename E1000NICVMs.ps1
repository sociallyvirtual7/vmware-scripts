$vms = ForEach( $VM in (Get-Cluster "Cluster_Name" | Get-VM) ) { $VM|Where{ $VM|Get-NetworkAdapter|Where{ $_.Type -like "*e1000*" -or $_.Type -like "*Flexible*"} } }
$vms | Sort-Object "Name"