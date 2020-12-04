Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false
Connect-VIServer “vCenter_Server_IP_Address/FQDN” -Credential (Get-Credential)
$VMs = Get-Content C:\Scripts\VMShutdown\VMList.txt
foreach ($VM in $VMs)
{
Write-Host “Initiating Guest Shutdown for VM ” + $VM -ForegroundColor DarkRed
Shutdown-VMGuest -VM $VM -Confirm:$false
Start-Sleep -Seconds “20“
}

foreach ($VM in $VMs)
{
Get-VM $VM | Select Name, PowerState | Ft -AutoSize -Wrap
}
Disconnect-VIServer -Confirm:$false