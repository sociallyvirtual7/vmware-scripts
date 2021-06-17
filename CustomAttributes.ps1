Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false
$cred = Get-Credential
Connect-VIServer vCenter_Server_IP_Address/FQDN -Credential $cred
$files = Import-CSV "C:\Users\testuser\Desktop\CustomAttributes.csv"
foreach ($file in $files)
{
$vm = Get-VM -Name $file.VMName
$vm | Set-Annotation -CustomAttribute "AppName" -Value $file.AppName
$vm | Set-Annotation -CustomAttribute "Owner" -Value $file.Owner
$vm | Set-Annotation -CustomAttribute "AppDL" -Value $file.AppDL
$vm | Set-Annotation -CustomAttribute "Env" -Value $file.ENv
}
 
Disconnect-VIServer -Confirm:$false