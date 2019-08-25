$baseName = 'W19Temp'
$Name = $args[0]
$DriveOpt = $args[1]
$UriSettings = $args[2]

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

$Credential = New-Object System.Management.Automation.PSCredential ("MyUser", (new-object System.Security.SecureString))
Wait-VMPowershell -Name $Name -Credential $Credential

if($UriSettings -ne $null) { 
  Write-Host "Installing custom configurations"
  Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { onlinerun $using:UriSettings }
}

Write-Host "Renaming computer name"
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Rename-computer -computername $(HOSTNAME) -newname $using:Name }

Restart-VM $Name -Force
Wait-VMPowershell -Name $Name -Credential $Credential

Write-Host $(Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { ipconfig | findstr /i "ipv4" })
