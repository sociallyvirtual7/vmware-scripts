Connect-VIServer -Server vCenter_FQDN/IP_Address -Credential (Get-Credential)
$vDSwitchDetails = Get-VDSwitch
$vDSwitchNames = $vDSwitchDetails.Name
$datestamp = Get-Date -Format “MM-dd-yyyy”
Foreach ($vDSwitchName in $vDSwitchNames)
{
$DestiationDir = “C:\Users\Administrator\Desktop\Scripts\vDSExport\”+ $datestamp + “\” + $vDSwitchName + “\”
New-Item -Path $DestiationDir -ItemType “Directory” -Force
$filename= $DestiationDir + $vDSwitchName + “.zip”
Get-VDSwitch -Name $vDSwitchName | Export-VDSwitch -Description “vDS Backup” -Destination $filename
}
Disconnect-VIServer -Confirm:$false