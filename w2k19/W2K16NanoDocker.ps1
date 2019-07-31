#https://docs.microsoft.com/pt-br/windows-server/get-started/deploy-nano-server

$Name = "W16Docker"
$isoPath = 'D:\SOFTWARES\WORK\MS Windows\2016 Server\14393.0.161119-1705.RS1_REFRESH_SERVER_EVAL_X64FRE_EN-US.ISO'

#Dismount-DiskImage -ImagePath $isoPath
MOUNT-DISKIMAGE $isoPath
$driveLetter = "$($(Get-DiskImage $isoPath | Get-Volume).DriveLetter):"
Import-Module "$($driveLetter)\NanoServer\NanoServerImageGenerator" -Verbose
mkdir c:\NanoServer\
copy "$($driveLetter)\NanoServer\*.*" c:\NanoServer\

$inputpwd = Read-Host -Prompt 'Password:'
$pwd = ConvertTo-SecureString -String $inputpwd -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential ("Administrator", $pwd)

New-NanoServerImage -DeploymentType Guest `
 -ComputerName $Name `
 -AdministratorPassword $pwd `
 -Edition DataCenter `
 -MediaPath "$($driveLetter)\" `
 -BasePath c:\NanoServer\ `
 -TargetPath "E:\Hyper-V\Virtual hard disks\$Name.vhdx" `
 -MaxSize 100GB `
 -Containers

##Remote Management
# -EnableRemoteManagementPort `
##IIS
# -ReverseForwarders `
# -Packages 'Microsoft-NanoServer-DSC-Package','Microsoft-NanoServer-IIS-Package' `
##hyper-v
# -Compute `
##dns server
# -Package Microsoft-NanoServer-DNS-Package `

New-VM `
 -Name $Name `
 -MemoryStartupBytes 10GB `
 -VHDPath "E:\Hyper-V\Virtual Hard Disks\$Name.vhdx" `
 -Generation 2 `
 -SwitchName ExternalSwitch

Start-VM $Name

Wait-VMPowershell -Name $Name -Credential $Credential

#https://docs.microsoft.com/pt-br/windows-server/get-started/manage-nano-server
#Scan for Available Updates
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { $(New-CimInstance -Namespace root/Microsoft/Windows/WindowsUpdate -ClassName MSFT_WUOperationsSession | Invoke-CimMethod -MethodName ScanForUpdates -Arguments @{SearchCriteria="IsInstalled=0";OnlineScan=$true}).Updates }
##Install Windows Updates
#Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Invoke-CimMethod -InputObject $(New-CimInstance -Namespace root/Microsoft/Windows/WindowsUpdate -ClassName MSFT_WUOperationsSession) -MethodName ApplyApplicableUpdates }
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { New-CimInstance -Namespace root/Microsoft/Windows/WindowsUpdate -ClassName MSFT_WUOperationsSession | Invoke-CimMethod -MethodName ApplyApplicableUpdates }

Write-Host "Restarting VM"
Restart-VM $Name -Force
Wait-VMPowershell -Name $Name -Credential $Credential

Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force }
#Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Install-Module -Name DockerMsftProvider -Repository PSGallery -Force }
#Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Install-Package -Name docker -ProviderName DockerMsftProvider -Force -Verbose }
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Install-Module DockerMsftProvider -Force }
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Install-Package Docker -ProviderName DockerMsftProvider -Force }

#(Install-WindowsFeature Containers).RestartNeeded
Write-Host "Restarting VM"
Restart-VM $Name -Force
Wait-VMPowershell -Name $Name -Credential $Credential

#Enter-PSSession -VMName $name
##Use Docker
#docker pull tonysneed/helloaspnet:nanoserver
#docker images
#docker run -d -p 80:5000 --name helloaspnet tonysneed/helloaspnet:nanoserver
#docker ps
##Browse to public DNS or IP of Windows nano server
#http://xx.xxx.xxx.xx
##You should see: Hello World!
