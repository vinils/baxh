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
$global:Session = New-PSSession -VMName $global:VMName -Credential $global:VMCredential  
SetDefaultScriptsSession  

####### Optional #######
Resize-VHD -Path 'F:\Hyper-V\Virtual Hard Disks\VMDev1.vhdx' -SizeBytes 90GB
Extend-WinOSDiskSize -Session $Session
########################

Write-Host "Renaming computer name"  
Invoke-Command -Session $global:Session -ScriptBlock { Rename-computer -computername $(HOSTNAME) -newname $using:VMName }  

SetupMachine -UnpinEdge -UnpinMSStore -UnpinMail -EnableVMIntegrationService -UACLower -DisableFirewall -ControlPainelSmallIcons -ShowHiddenFiles -ShowFileExtensions -InstallChrome -Install7Zip -InstallNotepadPlusPlus -DisableWindowsDefender

Restart-VM $global:VMName -Force  
Wait-VM -Session $global:Session 
SetDefaultScriptsSession  

SetupMachine -InstallGit -InstallDockerCli -InstallDotNetFramework471DeveloperPack -InstallWindowsSubsystemLinux -InstallVirtualMachinePlatform -InstallHyperV -InstallSQLManagementStudio -InstallVisualStudio2019Community -InstallCurl -InstallPython2_7_15 -InstallCMake  

Write-Host "enalbe hyperv remote connection"
RunVMCommand -Command "Add-Content -Path C:\windows\System32\drivers\etc\hosts. -Value '192.168.15.251          SRV1 '"
#Invoke-Command -Session $global:Session -ScriptBlock { 
#	$networkListManager = [Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]'{DCB00C01-570F-4A9B-8D69-199FDBA5723B}')) 
#	$connections = $networkListManager.GetNetworkConnections() 
#	# Set network location to Private for all networks 
#	$connections | % {$_.GetNetwork().SetCategory(1)}
#}
#RunVMCommand -Command "Enable-PSRemoting -Force"
RunVMCommand -Command "Enable-PSRemoting -SkipNetworkProfileCheck"
RunVMCommand -Command "Set-Item WSMan:\localhost\Client\TrustedHosts -Value SRV1 -Force"
RunVMCommand -Command "Enable-WSManCredSSP -Role client -DelegateComputer SRV1 -Force"

RunVMCommand -Command "New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation' -Name 'AllowFreshCredentialsWhenNTLMOnly' -Value 1 -PropertyType Dword -Force"
RunVMCommand -Command "New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation'  -Name 'AllowFreshCredentialsWhenNTLMOnly' -Value 'Default Value' -Force"
RunVMCommand -Command "New-ItemProperty  -Path  'hklm:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation\AllowFreshCredentialsWhenNTLMOnly' -Name '1' -PropertyType 'String' -Value '*'"

pause
#---> dcomcnfg > COM SECURITY > Access Permissions > Edit Limits > Anonymous Login > ALLOW Remote Access
RunVMCommand -Command "cmdkey /add:SRV1 /user:Administrator /pass"

Restart-VM $global:VMName -Force  
Wait-VM -Session $global:Session  
```
