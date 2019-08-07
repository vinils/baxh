#https://blogs.msdn.microsoft.com/virtual_pc_guy/2017/04/18/editing-a-vmcx-file/
#Import-VM -Path 'E:\W10Temp\8A3A77D4-C45E-4161-856D-1A7745A769CC.vmcx' -Copy -GenerateNewId -VhdDestinationPath 'E:\Hyper-V\Virtual hard disks\W10Temp'
#Import-VM -Path 'E:\W10Temp_oldG1\Virtual Machines\B54C094D-610C-41DA-A510-49246A11E6D4.vmcx' -Copy -GenerateNewId

$baseName = 'W10Temp'
$Name = $args[1]

switch($args[2]) {
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

$Credential = New-Object System.Management.Automation.PSCredential ("MyUser", (new-object System.Security.SecureString))
Wait-VMPowershell -Name $Name -Credential $Credential

if($args[3] -ne $null) { 
  Write-Host "Installing custom configurations"
  Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { onlinerun $using:args[3] }
}

Write-Host "Renaming computer name"
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Rename-computer -computername $(HOSTNAME) -newname $using:Name }

Restart-VM $Name -Force
Wait-VMPowershell -Name $Name -Credential $Credential

Write-Host $(Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { ipconfig | findstr /i "ipv4" })
