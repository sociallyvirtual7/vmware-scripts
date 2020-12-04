Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false
Connect-VIServer “vCenter_Server_IP_Address/FQDN” -Credential (Get-Credential)

$datanames = Import-Csv ‘C:\Users\Admin\Desktop\File_with_datastore_name_NAA_Ids.csv‘

foreach ($dataname in $datanames)
{
$dataname.Datastore_Name
$dataname.Naa_Id
New-Datastore -VMHost ESXi-01.mycloud.lab -Name $dataname.Datastore_Name -Path $dataname.Naa_Id -Vmfs -FileSystemVersion 6
Get-Cluster -name “Cloud-Clu-01” | Get-VMhost | Get-VMHostStorage –RescanAllHBA
Start-Sleep -Seconds 15
}

Disconnect-VIServer -Confirm:$false