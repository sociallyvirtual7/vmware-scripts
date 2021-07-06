[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$cred = Get-Credential
Connect-vRAServer -Server 'vRA_FQDN' -Username $cred.UserName -Password $cred.Password -Tenant "Tenant_Name" -IgnoreCertRequirements
$BGReserves = Get-vRAReservation | Select CreatedDate, Name, TenantId, ExtensionData
$fetchVMDetails= Get-vRAResource | where {$_.ResourceType -eq "Infrastructure.Virtual"}
$output = @()
    foreach($BGReserve in $BGReserves)
    {

        $ReserveVMDetails = ($fetchVMDetails | where {$_.Data.MachineReservationName -eq $BGReserve.name}).Data  | Select MachineName, MachineMemory, MachineStorage
    foreach ($ReserveVMDetail in $ReserveVMDetails)
    {
        $MachineQuotaUsed = $MachineQuotaUsed + 1
        $MemoryUsedinMB = $MemoryUsedinMB + $ReserveVMDetail.MachineMemory
        $StorageUsedinGB = $StorageUsedinGB + $ReserveVMDetail.MachineStorage
    }
    $MemoryUsedinGB = $MemoryUsedinMB/1024
        $fetchReserveDetails = $BGReserve.ExtensionData.entries
        $fetchQuotavalue = ($fetchReserveDetails |  where {$_.key -eq "machineQuota"}).value.value
        $BGReserve | Add-Member -NotePropertyName MachineQuota -NotePropertyValue $fetchQuotavalue
        $fetchMemoryReserve = (($fetchReserveDetails | where {$_.key -eq "reservationMemory"}).value.values.entries | where {$_.key -eq "memoryReservedSizeMb"}).value.value/1024
        $BGReserve | Add-Member -NotePropertyName MemoryReservedinGB -NotePropertyValue $fetchMemoryReserve
        $fetchStorageReserve = (($fetchReserveDetails | where {$_.key -eq "reservationStorages"}).value.items.values.entries | where {$_.key -eq "storageReservedSizeGB"}).value.value
        $BGReserve | Add-Member -NotePropertyName StorageReservedinGB -NotePropertyValue $fetchStorageReserve
        $MachineQuotaAllocated = $MachineQuotaAllocated + $fetchQuotavalue
        $BGReserve | Add-Member -NotePropertyName MachinesAllocated -NotePropertyValue $MachineQuotaUsed
        $MemoryAllocatedinGB = $MemoryAllocatedinGB + $fetchMemoryReserve
        $BGReserve | Add-Member -NotePropertyName MemoryAllocatedinGB -NotePropertyValue $MemoryUsedinGB
        $StorageAllocatedinGB = $StorageAllocatedinGB + $fetchStorageReserve
        $BGReserve | Add-Member -NotePropertyName StorageAllocatedinGB -NotePropertyValue $StorageUsedinGB
        $MachineQuotaAllocated = 0
        $MemoryAllocatedinGB = 0
        $StorageAllocatedinGB = 0
        $MemoryUsedinMB = 0
        $MemoryUsedinGB = 0
        $StorageUsedinGB = 0
        $MachineQuotaUsed = 0
    }

$output = $BGReserves | Select Name, CreatedDate, TenantId, MachineQuota, MachinesAllocated, MemoryReservedinGB, MemoryAllocatedinGB, StorageReservedinGB, StorageAllocatedinGB
$output | FT -AutoSize -Wrap

$output | Export-Csv "Path_To_Target.csv" -NoTypeInformation

Disconnect-vRAServer -Confirm:$false