[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$cred = Get-Credential
Connect-vRAServer -Server 'vRA_FQDN' -Username $cred.UserName -Password $cred.Password -Tenant "Tenant_Name" -IgnoreCertRequirements
$filter = (Get-vRAResource | where {$_.ResourceType -eq "Infrastructure.Virtual"}).Data
<#$businessgroups = $filter | Select MachineGroupName -Unique
foreach ($businessgroup in $businessgroups)
{
    $businessgroup | Out-File C:\Users\asapra\Desktop\Report.csv -Append
    $out = $filter | where {$_.MachineGroupName -eq $businessgroup.MachineGroupName} |  Select MachineName, ip_address, MachineGuestOperatingSystem
    $out | Out-File C:\Users\asapra\Desktop\Report.csv -Append
}#>
$filter | Select MachineGroupName, MachineName, ip_address
Disconnect-vRAServer -Confirm:$false