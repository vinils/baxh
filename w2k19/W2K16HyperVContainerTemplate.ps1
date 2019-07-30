$Name = 'SRVMSCONTTmp'

New-VM -Name $Name -MemoryStartupBytes 10GB -NewVHDPath "E:\Hyper-V\Virtual Hard Disks\$Name.vhdx" -NewVHDSizeBytes 100GB -SwitchName ExternalSwitch
Set-VMDvdDrive -VMName $Name -Path 'd:\SOFTWARES\WORK\MS Windows\2016 Server\14393.0.161119-1705.RS1_REFRESH_SERVERHYPERCORE_OEM_X64FRE_EN-US.ISO'
######################
# enable nested
Set-VMProcessor -VMName $Name -ExposeVirtualizationExtensions $true
Set-VMMemory $Name -DynamicMemoryEnabled $true
Get-VMNetworkAdapter -VMname $Name | Set-VMNetworkAdapter -MacAddressSpoofing On
######################
Start-VM -Name $Name

Write-Host "Waiting you to install windows"
Wait-VM -Name $Name -For Heartbeat

Write-Host "Waiting you to set the VM password"
Write-Host ""
pause

##Set Powershell default
#Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -name Shell -Value 'PowerShell.exe -noExit'

$Credential = $(Get-Credential)

#######
Write-Host "Enabling remote desktop"
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\' -Name “fDenyTSConnections” -Value 0 }
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\' -Name “UserAuthentication” -Value 0 }
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Enable-NetFirewallRule -DisplayGroup "Remote Desktop" }
#######
Write-Host "Removing Windows defender"
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Uninstall-WindowsFeature Windows-Defender }
Write-Host "Installing windows container feature"
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Install-WindowsFeature -Name Containers }
Write-Host "Installing nuget (required for PSWindowsUpdate)"
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force }
Write-Host "Installing windows update"
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Install-Module PSWindowsUpdate -Force }
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Get-WindowsUpdate }
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Install-WindowsUpdate -AcceptAll -IgnoreReboot }
#######
Write-Host "Renaming computer name"
Invoke-Command -VMName W2K16HyperVContainerTemplate -Credential $Credential -ScriptBlock { Rename-computer -computername $(HOSTNAME) -newname $using:Name }
#######
Write-Host "Restarting VM"
Restart-VM $Name -Force
Wait-VMPowershell -Name $Name -Credential $Credential
#######
Write-Host "Installing docker"
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Install-Module DockerMsftProvider -Force }
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Find-PackageProvider DockerMsftProvider | Install-PackageProvider }
##Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Install-Package Docker -ProviderName DockerMsftProvider -Force }
#Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Install-Module -Name DockerMsftProvider -Force }
##in case "Cannot verify the file SHA256. Deleting the file" - https://github.com/MicrosoftDocs/Virtualization-Documentation/issues/919
###cd C:\Users\Administrator\AppData\Local\Temp\1\DockerMsftProvider
##cd C:\Users\Administrator\AppData\Local\Temp\2\DockerMsftProvider
##Invoke-WebRequest -UseBasicParsing -OutFile docker-19-03-1.zip https://download.docker.com/components/engine/windows-server/19.03/docker-19.03.1.zip
##Start-BitsTransfer -Source https://download.docker.com/components/engine/windows-server/19.03/docker-19.03.1.zip -Destination Docker-19-03-1.zip
###Get-FileHash -Path Docker-19-03-1.zip -Algorithm SHA256
##Install-Package -Name docker -ProviderName DockerMsftProvider -Verbose

#Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Start-Service docker }

##check
#Get-Package -Name Docker -ProviderName DockerMsftProvider
#output -> docker                         19.03.1          DockerDefault                    DockerMsftProvider
#docker --version
#output Docker version 19.03.1, build f660560464

##UPGRADE
#Install-Package -Name Docker -ProviderName DockerMsftProvider -Update -Force
#Start-Service Docker

###Try it Out!
##docker run -it hello-world:nanoserver-sac2016
##docker run --name nanoiis -d -it -p 8081:80 nanoserver/iis
##iwr -useb -method Head http://<ip>:8081

##.NET Core Docker Samples
##https://github.com/dotnet/dotnet-docker-samples/blob/master/README.DockerHub.md
##docker run microsoft/dotnet-samples:dotnetapp

##images - https://hub.docker.com/search?q=nanoserver%20sac2016&type=image

##https://hub.docker.com/r/nanoserver/iis
##https://docs.microsoft.com/pt-br/windows-server/get-started/iis-on-nano-server
##docker pull nanoserver/iis

##https://hub.docker.com/_/microsoft-windows-servercore-iis
##docker pull mcr.microsoft.com/windows/servercore/iis:windowsservercore-ltsc2016

##https://hub.docker.com/_/microsoft-dotnet-framework-aspnet
##docker pull mcr.microsoft.com/dotnet/framework/aspnet:4.8

##https://hub.docker.com/r/microsoft/aspnetcore/
##FROM microsoft/aspnetcore
##WORKDIR /app
##COPY . .
##ENTRYPOINT ["dotnet", "myapp.dll"]
##docker build -t myapp .
##docker run -d -p 8000:80 myapp


## working with docker
##https://www.red-gate.com/simple-talk/sysadmin/containerization/working-windows-containers-docker-save-data/

## dealing with version compatibility
##https://docs.microsoft.com/en-us/virtualization/windowscontainers/deploy-containers/version-compatibility

