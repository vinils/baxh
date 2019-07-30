$Name = 'SRVMS19CTT2'

New-VM -Name $Name -MemoryStartupBytes 10GB -NewVHDPath "E:\Hyper-V\Virtual Hard Disks\$Name.vhdx" -NewVHDSizeBytes 100GB -SwitchName ExternalSwitch
Set-VMDvdDrive -VMName $Name -Path 'd:\SOFTWARES\WORK\MS Windows\2019 Server\17763.557.190612-0019.rs5_release_svc_refresh_SERVERHYPERCORE_OEM_x64FRE_en-us.iso'
######################
## enable nested
#Set-VMProcessor -VMName $Name -ExposeVirtualizationExtensions $true
#Set-VMMemory $Name -DynamicMemoryEnabled $true
#Get-VMNetworkAdapter -VMname $Name | Set-VMNetworkAdapter -MacAddressSpoofing On
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
Write-Host "Renaming computer name"
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Rename-computer -computername $(HOSTNAME) -newname $using:Name }
#######
Write-Host "Enabling remote desktop"
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\' -Name "fDenyTSConnections" -Value 0 }
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\' -Name "UserAuthentication" -Value 0 }
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Enable-NetFirewallRule -DisplayGroup "Remote Desktop" }
#######
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Install-Module DockerMsftProvider -Force }
##bug not working with force
#Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Install-Package Docker -ProviderName DockerMsftProvider -Force }
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Install-Package Docker -ProviderName DockerMsftProvider }
##bug not valid SHA1
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Invoke-WebRequest -UseBasicParsing -OutFile C:\Users\ADMINI~1\AppData\Local\Temp\DockerMsftProvider\docker-19-03-1.zip https://download.docker.com/components/engine/windows-server/19.03/docker-19.03.1.zip }
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Install-Package Docker -ProviderName DockerMsftProvider }
########
##Write-Host "Removing Windows defender"
#Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Uninstall-WindowsFeature Windows-Defender }
##Write-Host "Installing windows container feature"
##Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Install-WindowsFeature -Name Containers }
#Write-Host "Installing nuget (required for PSWindowsUpdate)"
#Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force }
#Write-Host "Installing windows update"
#Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Install-Module PSWindowsUpdate -Force }
#Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Get-WindowsUpdate }
#Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Install-WindowsUpdate -AcceptAll -IgnoreReboot }
########
##(Install-WindowsFeature Containers).RestartNeeded
#Write-Host "Restarting VM"
#Restart-VM $Name -Force
#Wait-VMPowershell -Name $Name -Credential $Credential
########
#Write-Host "Installing docker"
#Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Install-Module DockerMsftProvider -Force }
##Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Install-Package Docker -ProviderName DockerMsftProvider -Force }
##problem - Cannot verify the file SHA256. Deleting the file
#Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Invoke-WebRequest -UseBasicParsing -OutFile C:\Users\ADMINI~1\AppData\Local\Temp\1\DockerMsftProvider\docker-19-03-1.zip https://download.docker.com/components/engine/windows-server/19.03/docker-19.03.1.zip }
##some kind of bug that cant use -Force arg
#Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Install-Package Docker -ProviderName DockerMsftProvider }

#Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Start-Service docker }

##check
#Get-Package -Name Docker -ProviderName DockerMsftProvider
#output -> docker                         19.03.1          DockerDefault                    DockerMsftProvider
#docker --version
#output Docker version 19.03.1, build f660560464

##UPGRADE
#Install-Package -Name Docker -ProviderName DockerMsftProvider -Update -Force
#Start-Service Docker
