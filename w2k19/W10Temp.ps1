$Name = 'W10Temp'

New-VM -Name $Name `
  -NewVHDPath "E:\Hyper-V\Virtual Hard Disks\$Name.vhdx" `
  -NewVHDSizeBytes 100GB `
  -MemoryStartupBytes 10GB `
  -SwitchName ExternalSwitch

SET-VMProcessor –VMName $Name –Count 2
Set-VMMemory -VMName $Name -DynamicMemoryEnabled $true -StartupBytes 2GB
Add-VMDvdDrive -VMName $Name -Path 'D:\SOFTWARES\WORK\MS Windows\10\Win10_1903_V1_EnglishInternational_x64.iso'
Start-VM -Name $Name

Write-Host "Waiting you to install windows"
Wait-VM -Name $Name -For Heartbeat

Write-Host "Waiting you to set the VM password for user MyUser"
Write-Host ""
pause

$inputpwd = Read-Host -Prompt 'Password:'
$pwd = ConvertTo-SecureString -String $inputpwd -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential ("MyUser", $pwd)

Write-Host "enable execution of PowerShell scripts"
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { set-executionpolicy remotesigned }

#Write-Host "disable windows defender"
#Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Stop-Service WinDefend }
#Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Set-Service WinDefend -StartupType Disabled }
#Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name "DisableAntiSpyware" -Value 1 -Type DWord -Force }
#Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows Defender" -Name "DisableRoutinelyTakingAction" -Value 1 }

#Write-Output "Disabling Firewall..."
#Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\StandardProfile" -Force }
#Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\StandardProfile" -Name "EnableFirewall" -Type DWord -Value 0 }

##Disable UAC
##Write-Output "Lowering UAC level..."
##Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Type DWord -Value 0
##Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "PromptOnSecureDesktop" -Type DWord -Value 0
#Write-Host "Disabling UAC"
#Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { New-ItemProperty -Path HKLM:Software\Microsoft\Windows\CurrentVersion\policies\system -Name EnableLUA -PropertyType DWord -Value 0 -Force }

Write-Host "Enabling Remote Desktop"
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\' -Name "fDenyTSConnections" -Value 0 }
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\' -Name "UserAuthentication" -Value 0 }
# enable rdp with blank password
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -Name LimitBlankPasswordUse -Value 0 }
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Enable-NetFirewallRule -DisplayGroup "Remote Desktop" }

#Write-Host "Installing Net framework 3.5"
#Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Add-WindowsCapability –Online -Name NetFx3~~~~ –Source D:\sources\sxs }

Write-Host "Install Windows subsistem for linux"
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Enable-WindowsOptionalFeature -Online -FeatureName -NoRestart Microsoft-Windows-Subsystem-Linux }

#removing mail app
#Write-Host "Removing mail app"
#Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { get-appxpackage *microsoft.windowscommunicationsapps* | remove-appxpackage }

Write-Host "Installing update tools"
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Install-PackageProvider -Name NuGet -Force }
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Install-Module PSWindowsUpdate -Force }
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Install-Module -Name PendingReboot -Force }

Write-Host "Renaming computer name"
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Rename-computer -computername $(HOSTNAME) -newname $using:Name }

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

Write-Host "password unset"
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Set-LocalUser -name MyUser -Password ([securestring]::new()) }
$Credential = New-Object System.Management.Automation.PSCredential ("MyUser", (new-object System.Security.SecureString))
              
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { ipconfig }

$officeDrive = Set-VMDvdDrive -VMName $Name -Path 'D:\SOFTWARES\WORK\MS Office\2019\Professional2019Retail - Copy.iso'
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { "D:\Office\Setup64.exe /Configure /q" }
#Remove-VMDvdDrive -VMDvdDrive $officeDrive

Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { del "C:\Users\MyUser\Desktop\Microsoft Edge.lnk" }
Write-Host "unpin microsoft edge"
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { ((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | ?{$_.Name -eq "Microsoft Edge"}).Verbs() | ?{$_.Name.replace('&','') -match 'Unpin from taskbar'} | %{$_.DoIt(); $exec = $true} }
Write-Host "unpin store"
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { ((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | ?{$_.Name -eq "Microsoft Store"}).Verbs() | ?{$_.Name.replace('&','') -match 'Unpin from taskbar'} | %{$_.DoIt(); $exec = $true} }
Write-Host "unpin mail"
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { ((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | ?{$_.Name -eq "Mail"}).Verbs() | ?{$_.Name.replace('&','') -match 'Unpin from taskbar'} | %{$_.DoIt(); $exec = $true} }
Write-Host "install chocolatey"
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1')) }
Write-Host "install NotepePlusPlus"
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { choco install -y --limit-output --no-progress NotepadPlusPlus }
Write-Host "install 7zip"
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { choco install -y --limit-output --no-progress 7zip }
Write-Host "install docker cli"
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { choco install -y --limit-output --no-progress docker-cli }

Write-Host "control painel small icons"
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" }
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" -Name "StartupPage" -Type DWord -Value 1 }
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" -Name "AllItemsIconView" -Type DWord -Value 1 }

Write-Output "Showing hidden files..."
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Type DWord -Value 1 }
Write-Output "Showing known file extensions..."
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Type DWord -Value 0 }

Write-Host "Installing Google Chrome"
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { choco install -y --no-progress googlechrome }
Write-Host "removing microsoft chrome link from desktop"
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { del "C:\Users\Public\Desktop\Google Chrome.lnk" }
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { del "C:\Users\MyUser\Desktop\Google Chrome.lnk" }
Write-Host "pin chrome"
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { ((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | Where-Object {$_.Name -eq "Google Chrome"}).Verbs() }
Write-Host "Installing Git"
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { choco install -y --no-progress git }

#Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Enable-ComputerRestore -Confirm -Drive "C:\" }
#Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Checkpoint-Computer -Description "W10PlusOffice" }
#Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Restore-Computer -Confirm -RestorePoint (Get-ComputerRestorePoint | Where {$_.Description -eq "W10PlusOffice"}).SequenceNumber }
##Get-ComputerRestorePoint -LastStatus
