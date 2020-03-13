## Load Windows scripts
```powershell
$global:W10Source='https://raw.githubusercontent.com/vinils/baxh/master/w10/w10.psm1'  
iex (iwr $global:W10Source -Headers @{"Cache-Control"="no-cache"} -UseBasicParsing | Select-Object -Expand Content)  
```

## Create VM
```powershell
$global:VMName="VMDev1"  
$DefaultPassword = (new-object System.Security.SecureString)  
$global:VMCredential = New-Object System.Management.Automation.PSCredential ("MyUser", $DefaultPassword)  

New-VMW10 `  
	-VHDTemplate 'E:\Hyper-V\Virtual Hard Disks\W10Temp.vhdx' `  
	-VHDFolderPath 'F:\Hyper-V\Virtual Hard Disks\' `  
	-SwitchName "ExternalSwitch"  
	
Set-VM -VMName $global:VMName -AutomaticCheckpointsEnabled $True
```

## Load Hyper-V scripts
```powershell
$global:HyperVSource='https://raw.githubusercontent.com/vinils/baxh/master/hypervW10/hyperv.psm1'  
iex (iwr $global:HyperVSource -Headers @{"Cache-Control"="no-cache"} -UseBasicParsing | Select-Object -Expand Content)  
```

## SetUp VM
```powershell
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

#RunVMCommand "choco install -y visualstudio2017professional --package-parameters='--add Microsoft.VisualStudio.Component.Git'"  
RunVMCommand -Command "choco install -y --limit-output --no-progress visualstudio2019community --package-parameters='--add Microsoft.VisualStudio.Component.CoreEditor --add Microsoft.VisualStudio.Workload.CoreEditor --add Microsoft.NetCore.Component.SDK --add Microsoft.VisualStudio.Component.NuGet --add Microsoft.Net.Component.4.6.1.TargetingPack --add Microsoft.VisualStudio.Component.Roslyn.Compiler --add Microsoft.VisualStudio.Component.Roslyn.LanguageServices --add Microsoft.VisualStudio.Component.FSharp --add Microsoft.NetCore.Component.DevelopmentTools --add Microsoft.VisualStudio.Component.FSharp.WebTemplates --add Microsoft.VisualStudio.ComponentGroup.WebToolsExtensions --add Microsoft.VisualStudio.Component.DockerTools --add Microsoft.NetCore.Component.Web --add Microsoft.Net.Component.4.8.SDK --add Microsoft.Net.Component.4.7.2.TargetingPack --add Microsoft.Net.ComponentGroup.DevelopmentPrerequisites --add Microsoft.VisualStudio.Component.TypeScript.3.7 --add Microsoft.VisualStudio.Component.JavaScript.TypeScript --add Microsoft.VisualStudio.Component.JavaScript.Diagnostics --add Microsoft.Component.MSBuild --add Microsoft.VisualStudio.Component.TextTemplating --add Component.Microsoft.VisualStudio.RazorExtension --add Microsoft.VisualStudio.Component.IISExpress --add Microsoft.VisualStudio.Component.SQL.ADAL --add Microsoft.VisualStudio.Component.SQL.LocalDB.Runtime --add Microsoft.VisualStudio.Component.Common.Azure.Tools --add Microsoft.VisualStudio.Component.SQL.CLR --add Microsoft.VisualStudio.Component.MSODBC.SQL --add Microsoft.VisualStudio.Component.MSSQL.CMDLnUtils --add Microsoft.VisualStudio.Component.ManagedDesktop.Core --add Microsoft.Net.Component.4.5.2.TargetingPack --add Microsoft.Net.Component.4.5.TargetingPack --add Microsoft.VisualStudio.Component.SQL.SSDT --add Microsoft.VisualStudio.Component.SQL.DataSources --add Component.Microsoft.Web.LibraryManager --add Microsoft.VisualStudio.ComponentGroup.Web --add Microsoft.VisualStudio.Component.Web --add Microsoft.VisualStudio.Component.IntelliCode --add Microsoft.Net.Component.4.TargetingPack --add Microsoft.Net.Component.4.5.1.TargetingPack --add Microsoft.Net.Component.4.6.TargetingPack --add Microsoft.Net.ComponentGroup.TargetingPacks.Common --add Microsoft.Net.Core.Component.SDK.2.1 --add Component.Microsoft.VisualStudio.Web.AzureFunctions --add Microsoft.VisualStudio.ComponentGroup.AzureFunctions --add Microsoft.VisualStudio.Component.Azure.Compute.Emulator --add Microsoft.VisualStudio.Component.Azure.Storage.Emulator --add Microsoft.VisualStudio.Component.Azure.ClientLibs --add Microsoft.VisualStudio.Component.Azure.AuthoringTools --add Microsoft.VisualStudio.Component.CloudExplorer --add Microsoft.VisualStudio.ComponentGroup.Web.CloudTools --add Microsoft.VisualStudio.Component.DiagnosticTools --add Microsoft.VisualStudio.Component.EntityFramework --add Microsoft.VisualStudio.Component.AspNet45 --add Microsoft.VisualStudio.Component.AppInsights.Tools --add Microsoft.VisualStudio.Component.WebDeploy --add Component.Microsoft.VisualStudio.LiveShare --add Microsoft.VisualStudio.Workload.NetWeb'"

RunVMCommand -Command "choco install -y --limit-output --no-progress googlechrome --ignore-checksums"  
RunVMCommand -Command "DoUnpin 'Microsoft Edge'; DoUnpin 'Microsoft Store'; DoUnpin 'Mail'"  
RunVMCommand -Command "DoPin 'Google Chrome'; DoPin 'Visual Studio 2019'"  

RunVMCommand -Command "choco install -y --limit-output --no-progress sql-server-management-studio"  

RunVMCommand -Command "DISM /online /enable-feature /NoRestart /FeatureName:Microsoft-Windows-Subsystem-Linux -NoRestart"
RunVMCommand -Command "DISM /online /enable-feature /NoRestart /FeatureName:VirtualMachinePlatform -NoRestart"
RunVMCommand -Command "Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart"

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
```
