## Load Windows scripts
$global:W10Source='https://raw.githubusercontent.com/vinils/baxh/master/w10/w10.psm1'  
iex (iwr $global:W10Source -Headers @{"Cache-Control"="no-cache"} -UseBasicParsing | Select-Object -Expand Content)  

## Create VM
$global:VMName="VMDev1"  
$DefaultPassword = (new-object System.Security.SecureString)  
$global:VMCredential = New-Object System.Management.Automation.PSCredential ("MyUser", $DefaultPassword)  

New-VMW10 `  
	-VHDTemplate 'E:\Hyper-V\Virtual Hard Disks\W10Temp.vhdx' `  
	-VHDFolderPath 'F:\Hyper-V\Virtual Hard Disks\' `  
	-SwitchName "ExternalSwitch"  

## Load Hyper-V scripts
$global:HyperVSource='https://raw.githubusercontent.com/vinils/baxh/master/hypervW10/hyperv.psm1'  
iex (iwr $global:HyperVSource -Headers @{"Cache-Control"="no-cache"} -UseBasicParsing | Select-Object -Expand Content)  

## SetUp VM
-- Optional  
Resize-VHD -Path $VHDFilePath -SizeBytes 30GB  
Extend-WinOSDiskSize -Name $VMName -Credential $Credential  
-------------------  

$global:Session = New-PSSession -VMName $global:VMName -Credential $global:VMCredential  
SetDefaultScriptsSession  

Write-Host "Renaming computer name"  
Invoke-Command -Session $global:Session -ScriptBlock { Rename-computer -computername $(HOSTNAME) -newname $using:VMName }  

SetupMachine  -EnableVMIntegrationService -UACLower -ControlPainelSmallIcons -ShowHiddenFiles -ShowFileExtensions  
-Install7Zip -InstallNotepadPlusPlus -InstallGit -InstallDockerCli -InstallDotNetFramework471DeveloperPack -InstallPython2_7_15 -InstallCurl -InstallCMake  

--RunVMCommand -Command "choco install visualstudio2019enterprise-preview --package-parameters '--allWorkloads --includeRecommended --includeOptional --passive --locale en-US'"  
--RunVMCommand "choco install -y visualstudio2017professional --package-parameters='--add Microsoft.VisualStudio.Component.Git'"  
RunVMCommand -Command "choco install -y --limit-output --no-progress visualstudio2019community"  
RunVMCommand -Command "choco install -y --limit-output --no-progress googlechrome --ignore-checksums"  
RunVMCommand -Command "DoUnpin 'Microsoft Edge'; DoUnpin 'Microsoft Store'; DoUnpin 'Mail'; DoPin 'Google Chrome'; DoPin 'Visual Studio 2019'"  
--RunVMCommand -Command "Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart"  
--RunVMCommand -Command "Enable-WindowsOptionalFeature -Online -FeatureName  Microsoft-Hyper-V-Tools-All -NoRestart"  

RunVMCommand -Command "choco install -y --limit-output --no-progress sql-server-management-studio"  

RunVMCommand -Command "DISM /online /enable-feature /NoRestart /FeatureName:Microsoft-Windows-Subsystem-Linux"
RunVMCommand -Command "DISM /online /enable-feature /NoRestart /FeatureName:VirtualMachinePlatform"
RunVMCommand -Command "Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All"

Write-Host "disable windows defender"
RunVMCommand -Command "Stop-Service WinDefend"
RunVMCommand -Command "Reg add 'HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender' /v DisableAntiSpyware /t REG_DWORD /d 1 /f"
RunVMCommand -Command "Reg add 'HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection' /v DisableRealtimeMonitoring /t REG_DWORD /d 1 /f"
RunVMCommand -Command "Reg add 'HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection' /v DDisableOnAccessProtection /t REG_DWORD /d 1 /f"
RunVMCommand -Command "Reg add 'HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection' /v DisableScanOnRealtimeEnable /t REG_DWORD /d 1 /f"
RunVMCommand -Command "Reg add 'HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection' /v DisableRoutinelyTakingAction /t REG_DWORD /d 1 /f"


Write-Host "enalbe hyperv remote connection"
RunVMCommand -Command "Add-Content -Path C:\windows\System32\drivers\etc\hosts. -Value '192.168.15.251          SRV1 '"
RunVMCommand -Command "Enable-PSRemoting -Force"
RunVMCommand -Command "Set-Item WSMan:\localhost\Client\TrustedHosts -Value SRV1 -Force"
RunVMCommand -Command "Enable-WSManCredSSP -Role client -DelegateComputer SRV1 -Force"

RunVMCommand -Command "New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation' -Name 'AllowFreshCredentialsWhenNTLMOnly' -Value 1 -PropertyType Dword -Force"
RunVMCommand -Command "New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation'  -Name 'AllowFreshCredentialsWhenNTLMOnly' -Value 'Default Value' -Force"
RunVMCommand -Command "New-ItemProperty  -Path  'hklm:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation\AllowFreshCredentialsWhenNTLMOnly' -Name '1' -PropertyType 'String' -Value '*'"

#---> dcomcnfg > COM SECURITY > Access Permissions > Edit Limits > Anonymous Login > ALLOW Remote Access
RunVMCommand -Command "cmdkey /add:SRV1 /user:Administrator /pass"

Restart-VM $global:VMName -Force  
Wait-VM -Session $global:Session  
