$Name = 'ArchTemp'
New-VHD -Path "E:\Hyper-V\Virtual Hard Disks\$Name.vhdx" -SizeBytes 100GB -Dynamic -BlockSizeBytes 1MB
New-VM -Name $Name -MemoryStartupBytes 10GB -VHDPath "E:\Hyper-V\Virtual Hard Disks\$Name.vhdx" -Generation 2 -SwitchName ExternalSwitch

Add-VMScsiController -VMName $Name
Add-VMDvdDrive -VMName $Name -ControllerNumber 1 -ControllerLocation 0 -Path 'Z:\SOFTWARES\WORK\Linux\archlinux-2019.07.01-x86_64.iso'
$DVDDrive = Get-VMDvdDrive -VMName $Name
Set-VMFirmware -VMName $Name -EnableSecureBoot Off -FirstBootDevice $DVDDrive

Set-VMMemory -VMName $Name -DynamicMemoryEnabled $true -StartupBytes 2GB
Set-VMProcessor -VMName $Name -Count 2

Start-VM -Name $Name

Write-Host "Waiting you to install Arch"
Wait-VM -Name $Name -For Heartbeat

###
# onlinerun ArchSetup
