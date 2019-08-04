$Name = 'W19Temp'
New-VM -Name $Name `
  -MemoryStartupBytes 10GB `
  -NewVHDPath "E:\Hyper-V\Virtual Hard Disks\$Name.vhdx" `
  -NewVHDSizeBytes 100GB `
  -SwitchName ExternalSwitch

SET-VMProcessor –VMName $Name –Count 2
Set-VMMemory -VMName $Name -DynamicMemoryEnabled $true -StartupBytes 2GB
Set-VMDvdDrive -VMName $Name -Path 'd:\SOFTWARES\WORK\MS Windows\2019 Server\17763.379.190312-0539.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso'
Start-VM -Name $Name

Write-Host "Waiting you to install windows"
Wait-VM -Name $Name -For Heartbeat

Write-Host "Waiting you to set the VM password"
Write-Host ""
pause

$Credential = $(Get-Credential)

Write-Host "enable execution of PowerShell scripts"
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { set-executionpolicy remotesigned }

Write-Host "disable windows defender"
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Uninstall-WindowsFeature Windows-Defender }

Write-Output "Disabling Firewall..."
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\StandardProfile" -Force }
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\StandardProfile" -Name "EnableFirewall" -Type DWord -Value 0 }

#Disable UAC
#Write-Output "Lowering UAC level..."
#Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Type DWord -Value 0
#Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "PromptOnSecureDesktop" -Type DWord -Value 0
Write-Host "Disabling UAC"
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { New-ItemProperty -Path HKLM:Software\Microsoft\Windows\CurrentVersion\policies\system -Name EnableLUA -PropertyType DWord -Value 0 -Force }

Write-Host "Enabling Remote Desktop"
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\' -Name "fDenyTSConnections" -Value 0 }
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\' -Name "UserAuthentication" -Value 0 }
# enable rdp with blank password
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -Name LimitBlankPasswordUse -Value 0 }
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Enable-NetFirewallRule -DisplayGroup "Remote Desktop" }

Write-Host $(Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { ipconfig | findstr /i "ipv4" })

Write-Host "Renaming computer name"
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Rename-computer -computername $(HOSTNAME) -newname $using:Name }

Write-Host "Installing update tools"
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Install-PackageProvider -Name NuGet -Force }
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Install-Module PSWindowsUpdate -Force }
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Install-Module -Name PendingReboot -Force }

do {
  $updatesNumber = Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { return (Get-WindowsUpdate).Count }
  $isRebootPending = Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { return (Test-PendingReboot).IsRebootPending }

  Write-Host "Updating windows"
  Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Install-WindowsUpdate -AcceptAll -IgnoreReboot }

  if($isRebootPending) {
    Write-Host "Restarting VM"
    Restart-VM $Name -Force
    Wait-VMPowershell -Name $Name -Credential $Credential
  }
} while($isRebootPending -or $updatesNumber -gt 0)
