add-type @"
 
using System.Net;
 
using System.Security.Cryptography.X509Certificates;
 
public class TrustAllCertsPolicy : ICertificatePolicy {
 
public bool CheckValidationResult(
 
ServicePoint srvPoint, X509Certificate certificate,
 
WebRequest request, int certificateProblem) {
 
return true;
 
}
 
}
 
"@
 
$AllProtocols = [System.Net.SecurityProtocolType]'Tls12'
 
[System.Net.ServicePointManager]::SecurityProtocol = $AllProtocols
 
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
$cred = Get-Credential

$username = $cred.UserName
$password = $cred.Password

$password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))

# Step 1. Create a username:password pair
$credPair = "$($username):$($password)"

$bytes = [System.Text.Encoding]::ASCII.GetBytes($credPair)
$base64 = [System.Convert]::ToBase64String($bytes)
 
$basicAuthValue = “Basic $base64”

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add('Accept','application/json')
$headers.Add('Content-Type','application/json')
$headers.Add('Authorization', $basicAuthValue)
$result = ""
$url = "https://vcsa700.vmlab.local/rest/com/vmware/cis/session"

$result = Invoke-RestMethod -Method POST -Uri $url -Headers $headers -Verbose
$session = @{'vmware-api-session-id' = $result.value}
$vms = Invoke-WebRequest -Uri https://vcsa700.vmlab.local/rest/vcenter/vm -Method Get -Headers $session
$vms = (ConvertFrom-Json $vms.Content).value
$vms