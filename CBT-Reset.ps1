###############################################################################
# Objective	: To reset CBT for VMs impacted by CBT file corruption issue
# Author	: Vasantha Kumar B.G.	
# Optional	: This script can perform CBT reset operations as per KB# 2139574
###############################################################################

# Show Disclaimer
Write-Host "DISCLAIMER. THIS SCRIPT IS PROVIDED TO YOU "AS IS" WITHOUT WARRANTIES OR" -ForegroundColor "yellow"
Write-Host "CONDITIONS OF ANY KIND, WHETHER ORAL OR WRITTEN, EXPRESS OR IMPLIED. THE" -ForegroundColor "yellow"
Write-Host "AUTHOR SPECIFICALLY DISCLAIMS ANY IMPLIED WARRANTIES OR CONDITIONS OF"  -ForegroundColor "yellow"
Write-Host "MERCHANTABILITY, SATISFACTORY QUALITY, NON-INFRINGEMENT AND FITNESS FOR"  -ForegroundColor "yellow"
Write-Host "A PARTICULAR PURPOSE." -ForegroundColor "yellow"
Write-Host ""
Write-Host ""
Write-Host "PRESS CONTROL + C TO REJECT, ANY OTHER KEY TO ACCEPT" -ForegroundColor "red"
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# connect to required server
#Get VMware hostname/ip
#Connect-VIServer -Server Server_IP -User 'User' -Password 'password'
$h = read-host "Specify VMware vCenter or ESXi (hostname or ip)"
Write-Host "`nConnecting to VMware server", $h,"(waiting for logon window)...`n" -foreground "green"
Connect-VIServer $h;

$resetVMs = 'null'
$VMCount = 'null'
# To collect all the VMs which is supported by CBT.
$CBT_Enabled_VMs = Get-VM | Get-View | Where-Object {$_.Config.Version -ge "vmx-07"} | Where-Object {$_.Config.changeTrackingEnabled -eq $true} | Select Name

# Total count of CBT Enabled VMs
$VMCount = $CBT_Enabled_VMs.Count
Write-Host "Total No of CBT Enabled VMs is:" $VMCount

if ($VMCount) {
	# To list VM Names for which CBT will be reset
	Write-Host "List of VMs for which CBT will be reset are:" -ForegroundColor "green"
	Write-Host " ==========================="
	foreach ($vm in Get-VM) {
		$view = Get-View $vm
	
		if ($view.Config.Version -ge "vmx-07" -and $view.Config.changeTrackingEnabled -eq $true) {
			
			if (($view.snapshot -eq $null) -and ($vm.PowerState -eq 'PoweredOn')) {
				Write-Host ""$vm ":"$vm.PowerState 
				$resetVMs = $VMCount
			}
		}
	}
	Write-Host " ==========================="
	Write-Host ""
	Write-Host ""
	
	# To list VM Names for which CBT will Not reset
	Write-Host "List of VMs for which CBT will be NOT be reset" -ForegroundColor "red"
	Write-Host "Since Snapshot exists OR Power-State is Off:" -ForegroundColor "yellow"
	Write-Host " ==========================="
	foreach ($vm in Get-VM) {
		$view = Get-View $vm
	
		if ($view.Config.Version -ge "vmx-07" -and $view.Config.changeTrackingEnabled -eq $true) {
	
			if (($view.snapshot -ne $null) -or ($vm.PowerState -ne 'PoweredOn')) {
				Write-Host ""$vm ":"$vm.PowerState 
			}
		}
	}
	Write-Host " ==========================="
	Write-Host ""
	Write-Host ""
	
	if ($resetVMs -ne 'null') {
		Write-Host "Continue to Reset CBT"
		Write-Host "PRESS CONTROL + C TO REJECT, ANY OTHER KEY TO ACCEPT" -ForegroundColor "red"
		$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
		foreach ($vm in Get-VM) {
			$view = Get-View $vm
			if ($view.Config.Version -ge "vmx-07" -and $view.Config.changeTrackingEnabled -eq $true) {
				if (($view.snapshot -eq $null) -and ($vm.PowerState -eq 'PoweredOn')) {
					#Disable CBT 
					Write-Host "Disabling CBT for" $vm
					$spec = New-Object VMware.Vim.VirtualMachineConfigSpec
					$spec.ChangeTrackingEnabled = $false 
					$vm.ExtensionData.ReconfigVM($spec) 
					
					#Take/Remove Snapshot to reconfigure VM State
					$SnapName = New-Snapshot -vm $vm -Quiesce -Name "CBT-Rest-Snapshot"
					$SnapRemove = Remove-Snapshot -Snapshot $SnapName -Confirm:$false 
			
					#Enable CBT 
					Write-Host "Enabling CBT for" $vm
					$spec = New-Object VMware.Vim.VirtualMachineConfigSpec
					$spec.ChangeTrackingEnabled = $true 
					$vm.ExtensionData.ReconfigVM($spec) 
								
					#Take/Remove Snapshot to reconfigure VM State
					$SnapName1 = New-Snapshot -vm $vm -Quiesce -Name "CBT-Verify-Snapshot"
					$SnapRemove1 = Remove-Snapshot -Snapshot $SnapName1 -Confirm:$false
				}
			}
		}
	}
	else {
		Write-Host "No VMs qualify to Reset CBT, Please check if CBT Enabled VMs are either powered-off or have snapshots" -ForegroundColor "yellow"
	}
}
else {
	Write-Host "No CBT enabled VMs found, Hence exiting" -ForegroundColor "yellow"
}

 




