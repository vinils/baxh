## Load Windows scripts
```powershell
$global:W10Source='https://raw.githubusercontent.com/vinils/baxh/master/w10/w10.psm1'
iex (iwr $global:W10Source -Headers @{"Cache-Control"="no-cache"} -UseBasicParsing | Select-Object -Expand Content)

```

## Create VM
```powershell
$VMName="VMDev1"  
$DefaultPassword = (new-object System.Security.SecureString)  
$VMCredential = New-Object System.Management.Automation.PSCredential ("MyUser", $DefaultPassword)  

New-VMW10 `
	-Name $VMName `
	-Credential $VMCredential `
	-VHDTemplate 'E:\Hyper-V\Virtual Hard Disks\W10Temp.vhdx' `
	-VHDFolderPath 'F:\Hyper-V\Virtual Hard Disks\' `
	-SwitchName "ExternalSwitch"
	
Set-VM -VMName $VMName -AutomaticCheckpointsEnabled $True
```

## Optional
```powershell
Resize-VHD -Path "F:\Hyper-V\Virtual Hard Disks\$VMName.vhdx" -SizeBytes 90GB
Start-VM $VMName
Wait-VM -Name $VMName -Credential $VMCredential

$session=New-PSSession -VMName $VMName -Credential $VMCredential
Invoke-Command -Session $Session -ScriptBlock {
	iex (iwr $using:W10Source -Headers @{"Cache-Control"="no-cache"} -UseBasicParsing | Select-Object -Expand Content)
	Extend-WinOSDiskSize
}

Write-Host "enable VM Integration Service"
Get-VM -Name $VMName | Get-VMIntegrationService | ? {-not($_.Enabled)} | Enable-VMIntegrationService -Verbose
```

## Install
```powershell
Start-VM $VMName
Wait-VM -Name $VMName -Credential $VMCredential

$session=New-PSSession -VMName $VMName -Credential $VMCredential

Invoke-Command -Session $Session -ScriptBlock {
	Rename-computer -computername $(HOSTNAME) -newname $using:VMName

	iex (iwr $using:W10Source -Headers @{"Cache-Control"="no-cache"} -UseBasicParsing | Select-Object -Expand Content)
	SetupMachine -UnpinEdge -UnpinMSStore -UnpinMail -UACLower -DisableFirewall -ControlPainelSmallIcons -ShowHiddenFiles -ShowFileExtensions -InstallChrome -Install7Zip -InstallNotepadPlusPlus -DisableWindowsDefender
}

Restart-VM $global:VMName -Force  
Wait-VM -Name $VMName -Credential $VMCredential
$session=New-PSSession -VMName $VMName -Credential $VMCredential

Invoke-Command -Session $Session -ScriptBlock {
	iex (iwr $using:W10Source -Headers @{"Cache-Control"="no-cache"} -UseBasicParsing | Select-Object -Expand Content)
	SetupMachine -InstallGit -InstallDockerCli -InstallDotNetFramework471DeveloperPack -InstallWindowsSubsystemLinux -InstallVirtualMachinePlatform -InstallHyperV -InstallSQLManagementStudio -InstallVisualStudio2019Community -InstallCurl -InstallPython2_7_15 -InstallCMake  
}

Restart-VM $global:VMName -Force  
Wait-VM -Name $VMName -Credential $VMCredential
$session=New-PSSession -VMName $VMName -Credential $VMCredential

Invoke-Command -Session $Session -ScriptBlock {
	Write-Host "enalbe hyperv remote connection"
	Add-Content -Path C:\windows\System32\drivers\etc\hosts. -Value '192.168.15.251          SRV1 '
	#Invoke-Command -Session $global:Session -ScriptBlock { 
	#	$networkListManager = [Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]'{DCB00C01-570F-4A9B-8D69-199FDBA5723B}')) 
	#	$connections = $networkListManager.GetNetworkConnections() 
	#	# Set network location to Private for all networks 
	#	$connections | % {$_.GetNetwork().SetCategory(1)}
	#}
	#Enable-PSRemoting -Force
	Enable-PSRemoting -SkipNetworkProfileCheck
	Set-Item WSMan:\localhost\Client\TrustedHosts -Value SRV1 -Force
	Enable-WSManCredSSP -Role client -DelegateComputer SRV1 -Force

	New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation' -Name 'AllowFreshCredentialsWhenNTLMOnly' -Value 1 -PropertyType Dword -Force
	New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation'  -Name 'AllowFreshCredentialsWhenNTLMOnly' -Value 'Default Value' -Force
	New-ItemProperty  -Path  'hklm:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation\AllowFreshCredentialsWhenNTLMOnly' -Name '1' -PropertyType 'String' -Value '*'

	pause
	#---> dcomcnfg > COM SECURITY > Access Permissions > Edit Limits > Anonymous Login > ALLOW Remote Access
	cmdkey /add:SRV1 /user:Administrator /pass
}
```
