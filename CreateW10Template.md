# Create virtual windows 10 machine template

## Load windows scripts  
```powershell
$global:W10Source='https://raw.githubusercontent.com/vinils/baxh/master/w10/w10.psm1'  
iex (iwr $global:W10Source -Headers @{"Cache-Control"="no-cache"} -UseBasicParsing | Select-Object -Expand Content)  
```

## Create VM  
```powershell
$global:VMName="W10Temp"  
New-VM -Name $global:VMName -NewVHDFolderPath "E:\Hyper-V\Virtual hard disks" -OSISOFilePath 'Z:\SOFTWARES\WORK\MS Windows\10\en_windows_10_business_editions_version_1909_x64_dvd_ada535d0.iso' -SwitchName "ExternalSwitch"  

Write-Host "Waiting you to start, install OS and set a user..."  
Pause  
```

## Load Hyper-V scripts  
```powershell
$global:HyperVSource='https://raw.githubusercontent.com/vinils/baxh/master/hypervW10/hyperv.psm1'  
iex (iwr $global:HyperVSource -Headers @{"Cache-Control"="no-cache"} -UseBasicParsing | Select-Object -Expand Content)  
```

## Setup machine
```powershell
$global:VMCredential=$(Get-Credential MyVMUser)  
$global:Session = New-PSSession -VMName $global:VMName -Credential $global:VMCredential  
SetDefaultScriptsSession  

SetupMachine -InstallNugetPackageProvider -InstallNugetPSWindowsUpdate -DisableAutomaticCheckpoints -EnableRDP -EnableRDPBlankPassword -InstallDotNetFrameWork35  

$DefaultPassword = (new-object System.Security.SecureString)  
$deafultCredential = New-Object System.Management.Automation.PSCredential ("MyUser", $DefaultPassword)  
ChangeUser -Credential $(Get-Credential $deafultCredential)  

$global:VMName="W10Temp"  
Invoke-Command -Session $global:Session -ScriptBlock { Rename-computer -computername $(HOSTNAME) -newname $using:VMName }  

Update-VMW  
Update-VMW  
Update-VMW  
Update-VMW  
Update-VMW  
Update-VMW  

Stop-VM -Name $global:VMName -Force  
```



--docker-machine create --hyperv-disk-size "500000" --hyperv-memory "15000" --hyperv-cpu-count "3" -d hyperv dckMyHealth1  
--docker-machine env dckMyHealth1  
