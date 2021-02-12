Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false
$cred = Get-Credential
Connect-VIServer vCenter_IP/FQDN -Credential $cred
$vms = Get-VM
$output = New-Object System.Collections.ArrayList($null)
$vmpermission = @()
foreach ($vm in $vms)
{
    $permissions = $vm | Get-VIPermission | Get-Unique
    Foreach ($permission in $permissions)
    {
        $formatpermission = $permission.Principal + " (" + $permission.Role + ")"
        $permission | Add-Member -NotePropertyName FormatPermission -NotePropertyValue $formatpermission
    }
    $vmpermission = [pscustomobject]@{VMName=$vm.Name;Role=$permissions.FormatPermission  -join ', '}
    [void]($output.Add($vmpermission))
}
 
$output | Export-csv C:\Users\VMPermissionsExport.csv -NoTypeInformation