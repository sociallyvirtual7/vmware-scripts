Set-ExecutionPolicy RemoteSigned
 
$cred = Get-Credential
$vRAFQDN = "vRA_FQDN"
$vRATenant = "TenantName"
 
#Connecting to vRA Server using PowervRA 3.7.0 Module
Connect-vRAServer -Server $vRAFQDN -Tenant $vRATenant -Username $cred.UserName -Password $cred.Password -IgnoreCertRequirements
 
#Fetching List of vRealize Automation Managed Virtual Machines
$filter = Get-vRAResource | where {$_.ResourceType -eq "Infrastructure.Virtual"}
$date = Get-Date -Format "yyyy-MM-dd-hh-mm-tt"
$print =  $filter | Select Data,Owners,ResourceId
$output = $print | Select @{Name="VMName";Expression={$_.Data.MachineName}}, @{Name="BusinessGroup";Expression={$_.Data.MachineGroupName}},`
@{Name="Owner";Expression={$_.Owners}}, @{Name="OwnersID";Expression={""}}, @{Name="ResourceID";Expression={$_.ResourceId}}, @{Name="ReservationName";Expression={$_.Data.MachineReservationName}},`
@{Name="vCPUs";Expression={$_.Data.MachineCPU}}, @{Name="Memory (MB)";Expression={$_.Data.MachineMemory}}, @{Name="Storage (GB)";Expression={$_.Data.MachineStorage}}
  
$output = $output | where {$_.VMName -ne $null}
  
$output | ft -AutoSize -Wrap
 
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $True }
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add('Accept','application/json')
$headers.Add('Content-Type','application/json')
  
$Body = @{
    username = $cred.UserName
    password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($cred.Password))
    tenant = $vRATenant
} | ConvertTo-Json
  
#Generating API Bearer Token for vRA Login
  
$url = "https://" + $vRAFQDN
$tokenurl = $url + "/identity/api/tokens"
$token = Invoke-RestMethod -Method Post -Uri $tokenurl -Body $Body -Headers $headers -Verbose
$token = $token.id
$headers.Add('Authorization',"Bearer $token")
$printvalue = @{}
$i=0;
 
#Get Machine Owner's ID for each Managed Machine
 
foreach ($item in $output)
{
    $owneridurl = $url + "/catalog-service/api/consumer/resources/" + $item.ResourceId
    $ownersId = Invoke-RestMethod -Method Get -Headers $headers -uri $owneridurl -Verbose
    $item.OwnersID = $ownersId.owners.ref
    $printvalue[$i] = $item
    $i = $i + 1
}
 
$printvalue.Values | FT -AutoSize -Wrap
  
$printvalue.Values | Export-Csv C:\Users\Administrator\Desktop\vRAManagedMachineReport-$date.csv -NoTypeInformation