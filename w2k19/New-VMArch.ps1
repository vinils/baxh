#https://blogs.msdn.microsoft.com/virtual_pc_guy/2017/04/18/editing-a-vmcx-file/
#Import-VM -Path 'E:\W10Temp\8A3A77D4-C45E-4161-856D-1A7745A769CC.vmcx' -Copy -GenerateNewId -VhdDestinationPath 'E:\Hyper-V\Virtual hard disks\W10Temp'
#Import-VM -Path 'E:\W10Temp_oldG1\Virtual Machines\B54C094D-610C-41DA-A510-49246A11E6D4.vmcx' -Copy -GenerateNewId

$baseName = 'ArchTemp'
$Name = $args[0]
$DriveOpt = $args[1]

switch($DriveOpt) {
   1 { $drive = 'D:' }
   2 { $drive = 'E:' }
   3 { $drive = 'F:' }
   4 { $drive = 'G:' }
   5 { $drive = 'H:' }
   6 { $drive = 'Z:' }
}

$filePath = "$drive\Hyper-V\Virtual hard disks\$Name.vhdx"
copy "E:\Hyper-V\Virtual hard disks\$baseName.vhdx" $filePath

New-VM -Name $Name `
  -VHDPath $filePath `
  -MemoryStartupBytes 10GB `
  -Generation 2 `
  -SwitchName ExternalSwitch

Set-VMMemory -VMName $Name -DynamicMemoryEnabled $true -StartupBytes 2GB
Set-VMProcessor -VMName $Name -Count 2
Set-VMFirmware -VMName $Name -EnableSecureBoot Off

Write-Host "Starting VM"
Start-VM -VMName $Name

Write-Host "Rename Computer"
Write-Host "echo $Name > /etc/hostname"
