[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$cred = Get-Credential
Connect-vRAServer -Server ‘vRA_Server/Portal_Address‘ -Username $cred.UserName -Password $cred.Password -Tenant ‘Tenant_Name‘ -IgnoreCertRequirements

$netids = Get-vRAExternalNetworkProfile
$out = @()
foreach ($netid in $netids)
{
$print = $netid | Select @{Name=”Name”;Expression={$_.Name}}, @{Name=”SubnetMask”;Expression={$_.SubnetMask}},`
@{Name=”BeginIPv4Address”;Expression={$_.DefinedRanges.beginIPv4Address}},`
@{Name=”EndIPv4Address”;Expression={$_.DefinedRanges.endIPv4Address}}
$out = $out + $print
}

$out | Export-Csv C:\Users\Administrator\vRANetProfileRanges.csv -NoTypeInformation
Disconnect-vRAServer -Confirm:$false