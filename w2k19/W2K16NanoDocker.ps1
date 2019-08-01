#https://docs.microsoft.com/pt-br/windows-server/get-started/deploy-nano-server

$Name = "W16Docker5"
$isoPath = 'D:\SOFTWARES\WORK\MS Windows\2016 Server\14393.0.161119-1705.RS1_REFRESH_SERVER_EVAL_X64FRE_EN-US.ISO'
$driveLetter = "$($(Get-DiskImage $isoPath | Get-Volume).DriveLetter):"

if($driveLetter -eq ":") {
  #Dismount-DiskImage -ImagePath $isoPath
  MOUNT-DISKIMAGE $isoPath
  $driveLetter = "$($(Get-DiskImage $isoPath | Get-Volume).DriveLetter):"
  Import-Module "$($driveLetter)\NanoServer\NanoServerImageGenerator" -Verbose
}

if (!(Test-Path -Path "C:\NanoServer\")) {
  mkdir c:\NanoServer\
  copy "$($driveLetter)\NanoServer\*.*" c:\NanoServer\
}

$inputpwd = Read-Host -Prompt 'Password:'
$pwd = ConvertTo-SecureString -String $inputpwd -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential ("Administrator", $pwd)

Write-Host "New Nando"
New-NanoServerImage -DeploymentType Guest `
 -ComputerName $Name `
 -ServicingPackagePath 'D:\SOFTWARES\WORK\MS Windows\2016 Server\NanoServerKBs\KB3176936-x64\Windows10.0-KB3176936-x64.cab', `
 'D:\SOFTWARES\WORK\MS Windows\2016 Server\NanoServerKBs\KB3192366-x64\Windows10.0-KB3192366-x64.cab' `
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
#

Write-Host "Creating VM"
New-VM `
 -Name $Name `
 -MemoryStartupBytes 10GB `
 -VHDPath "E:\Hyper-V\Virtual Hard Disks\$Name.vhdx" `
 -Generation 2 `
 -SwitchName ExternalSwitch

Start-VM $Name

Wait-VMPowershell -Name $Name -Credential $Credential

Write-Host "Installing Nuget (required for DockerMsfProvider)"
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force }

Write-Host "Installing Docker"
#Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Install-Module -Name DockerMsftProvider -Repository PSGallery -Force }
#Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Install-Package -Name docker -ProviderName DockerMsftProvider -Force -Verbose }
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Install-Module DockerMsftProvider -Force }
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Install-Package Docker -ProviderName DockerMsftProvider -Force }
$docker = Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { try { Start-Service docker } catch { return $false } }
$count=$count+1

For ($i=1; $i -le 3; $i++) {
  #https://docs.microsoft.com/pt-br/windows-server/get-started/manage-nano-server
  #Scan for Available Updates
  Write-Host "Scanning for Available Updates"
  Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { $(New-CimInstance -Namespace root/Microsoft/Windows/WindowsUpdate -ClassName MSFT_WUOperationsSession | Invoke-CimMethod -MethodName ScanForUpdates -Arguments @{SearchCriteria="IsInstalled=0";OnlineScan=$true}).Updates }
  ##Install Windows Updates
  Write-Host "Installing Windows Updates"
  #Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Invoke-CimMethod -InputObject $(New-CimInstance -Namespace root/Microsoft/Windows/WindowsUpdate -ClassName MSFT_WUOperationsSession) -MethodName ApplyApplicableUpdates }
  Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Invoke-CimMethod -InputObject $(New-CimInstance -Namespace root/Microsoft/Windows/WindowsUpdate -ClassName MSFT_WUOperationsSession) -MethodName ApplyApplicableUpdates }

  Write-Host "Restarting VM"
  Restart-VM $Name -Force
  Wait-VMPowershell -Name $Name -Credential $Credential
}

#Enter-PSSession -VMName $name
##Use Docker
#docker pull tonysneed/helloaspnet:nanoserver
#docker images
#docker run -d -p 8081:5000 --name helloaspnet tonysneed/helloaspnet:nanoserver
#docker ps
##Browse to public DNS or IP of Windows nano server
#iwr -useb -method Head http://<ip>:8081
#http://<ip>:8081
##You should see: Hello World!
