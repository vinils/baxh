$Name = 'W10Temp1'

New-VM -Name $Name `
  -NewVHDPath "E:\Hyper-V\Virtual Hard Disks\$Name.vhdx" `
  -NewVHDSizeBytes 100GB `
  -MemoryStartupBytes 10GB `
  -Generation 2 `
  -SwitchName ExternalSwitch

Add-VMScsiController -VMName $Name
Add-VMDvdDrive -VMName $Name -ControllerNumber 1 -ControllerLocation 0 -Path 'D:\SOFTWARES\WORK\MS Windows\10\Win10_1903_V1_EnglishInternational_x64.iso'
$DVDDrive = Get-VMDvdDrive -VMName $Name
Set-VMFirmware -VMName $Name -FirstBootDevice $DVDDrive

Set-VMMemory -VMName $Name -DynamicMemoryEnabled $true -StartupBytes 2GB
Set-VMProcessor -VMName $Name -Count 2
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

Write-Host "Enabling Remote Desktop"
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\' -Name "fDenyTSConnections" -Value 0 }
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\' -Name "UserAuthentication" -Value 0 }
# enable rdp with blank password
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -Name LimitBlankPasswordUse -Value 0 }
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { netsh advfirewall firewall set rule group="remote desktop" new enable=Yes }

Write-Host $(Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { ipconfig | findstr /i "ipv4" })

Write-Host "password unset"
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Set-LocalUser -name MyUser -Password ([securestring]::new()) }
$Credential = New-Object System.Management.Automation.PSCredential ("MyUser", (new-object System.Security.SecureString))

##Disable UAC
##Write-Output "Lowering UAC level..."
##Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Type DWord -Value 0
##Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "PromptOnSecureDesktop" -Type DWord -Value 0
#Write-Host "Disabling UAC"
#Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { New-ItemProperty -Path HKLM:Software\Microsoft\Windows\CurrentVersion\policies\system -Name EnableLUA -PropertyType DWord -Value 0 -Force }

Write-Host "disable windows defender"
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Stop-Service WinDefend }
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender" /v DisableAntiSpyware /t REG_DWORD /d 1 /f }
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v DisableRealtimeMonitoring /t REG_DWORD /d 1 /f }
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v DDisableOnAccessProtection /t REG_DWORD /d 1 /f }
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v DisableScanOnRealtimeEnable /t REG_DWORD /d 1 /f }
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v DisableRoutinelyTakingAction /t REG_DWORD /d 1 /f }

#Write-Output "Disabling Firewall..."
#Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\StandardProfile" -Force }
#Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\StandardProfile" -Name "EnableFirewall" -Type DWord -Value 0 }

#Write-Output "Stop showing messages of firewall and defender disbaled"
#

#Write-Host "Installing Net framework 3.5"
#Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Add-WindowsCapability –Online -Name NetFx3~~~~ –Source D:\sources\sxs }

#Write-Host "Install Windows subsistem for linux"
#Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Enable-WindowsOptionalFeature -Online -FeatureName -NoRestart Microsoft-Windows-Subsystem-Linux }

#Write-Host "Install Hyper-v management tools"
#Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Dism /online /Get-FeatureInfo /FeatureName:Microsoft-Hyper-V-Tools-All }

#Write-Host "Install Server Management"
#https://www.microsoft.com/pt-BR/download/details.aspx?id=45520

#Write-Host "Remove extra keyboards"

#Write-Host "CMD as Administrator allways"

#Write-Host "Powershell as Administrator allways"


#\\192.168.15.250\d$\SOFTWARES\WORK\MS Office\2019\
#D:\Setup.exe
Write-Host "Custom windows install opportunity (office/disable firewall/defender)"
pause


#removing mail app
#Write-Host "Removing mail app"
#Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { get-appxpackage *microsoft.windowscommunicationsapps* | remove-appxpackage }

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
Write-Host "Installing Git"
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { choco install -y --no-progress git }
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
#Write-Host "pin chrome"
#Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { ((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | Where-Object {$_.Name -eq "Google Chrome"}).Verbs() }
#Write-Host "Setting Chrome as default"
#
#Write-Host "Installing Chrome Adblock"
#

#############################################################3
### Remote connection
#https://www.hasanhuseyinaltin.com/remotely-manage-hyper-v-2016-via-windows-10/
#https://docs.microsoft.com/en-us/windows-server/virtualization/hyper-v/manage/remotely-manage-hyper-v-hosts
#https://blog.ropnop.com/remotely-managing-hyper-v-in-a-workgroup-environment/
#http://pc-addicts.com/remotely-manage-hyper-v-server-2012-core/

##localcomputer
######
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { 
  Add-Content -Path C:\windows\System32\drivers\etc\hosts. -Value '192.168.15.251          SRV1 '
  Enable-PSRemoting -Force
  Set-Item WSMan:\localhost\Client\TrustedHosts -Value SRV1 -Force
  Enable-WSManCredSSP -Role client -DelegateComputer SRV1 -Force

  #Get-NetAdapter|Get-NetConnectionProfile
  #Set-NetConnectionProfile -InterfaceAlias 'Ethernet' -NetworkCategory Private

  #You might also need to configure the following group policy (run gpedit.msc):
  #Computer Configuration > Administrative Templates > System > Credentials Delegation > Allow delegating fresh credentials with NTLM-only server authentication
  New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation' -Name "AllowFreshCredentialsWhenNTLMOnly" -Value 1 -PropertyType Dword -Force
  New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation'  -Name "AllowFreshCredentialsWhenNTLMOnly" -Value "Default Value" -Force
  New-ItemProperty  -Path  'hklm:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation\AllowFreshCredentialsWhenNTLMOnly' -Name "1" -PropertyType "String" -Value '*'

  #---> dcomcnfg > COM SECURITY > Access Permissions > Edit Limits > Anonymous Login > ALLOW Remote Access

  cmdkey /add:SRV1 /user:Administrator /pass
  #######

  ##get-service winrm
  #start-service winrm
  #set-Item WSMan:\localhost\Client\TrustedHosts -Value SRV1 -Force
  #Enable-WSManCredSSP -Role Client –DelegateComputer SRV1 -Force
}
#############################################################
