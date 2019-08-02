$Name = 'ArchTemp1'
New-VHD -Path "E:\Hyper-V\Virtual Hard Disks\$Name.vhdx" -SizeBytes 100GB -Dynamic -BlockSizeBytes 1MB
New-VM -Name $Name -MemoryStartupBytes 10GB -VHDPath "E:\Hyper-V\Virtual Hard Disks\$Name.vhdx" -Generation 2 -SwitchName ExternalSwitch
Add-VMScsiController -VMName $Name
Add-VMDvdDrive -VMName $Name -ControllerNumber 1 -ControllerLocation 0 -Path 'D:\SOFTWARES\WORK\Linux\archlinux-2019.07.01-x86_64.iso'
$DVDDrive = Get-VMDvdDrive -VMName $Name
Set-VMFirmware -VMName $Name -EnableSecureBoot Off -FirstBootDevice $DVDDrive
Start-VM -Name $Name

Write-Host "Waiting you to install Arch"
Wait-VM -Name $Name -For Heartbeat

#onlinerun ArchSetup
