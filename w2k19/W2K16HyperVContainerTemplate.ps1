$Name = 'W2K16HyperVContainerTemplate'

New-VM -Name $VMName -MemoryStartupBytes 10GB -NewVHDPath 'C:\Users\Public\Documents\Hyper-V\Virtual Hard Disks\$VMName.vhdx' -NewVHDSizeBytes 100GB -SwitchName ExternalSwitch
Set-VMDvdDrive -VMName $VMName -Path 'd:\SOFTWARES\WORK\MS Windows\2016 Server\14393.0.161119-1705.RS1_REFRESH_SERVERHYPERCORE_OEM_X64FRE_EN-US.ISO'
Start-VM -Name $VMName

Wait-VM -Name $VMName -For Heartbeat

echo "Set VM password"
echo ""
pause

##Set Powershell default
#Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -name Shell -Value 'PowerShell.exe -noExit'

$Credential = $(Get-Credential)
Invoke-Command -VMName W2K16HyperVContainerTemplate -Credential $cred -ScriptBlock { Rename-computer -computername $(HOSTNAME) -newname $VMName }
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Uninstall-WindowsFeature Windows-Defender }
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Uninstall-WindowsFeature Hyper-V }
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Install-Module PSWindowsUpdate -Force }
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Get-WindowsUpdate }
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Install-WindowsUpdate -AcceptAll }
#Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Install-WindowsFeature -Name Containers }
#######
# remote desktop
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Set-ItemProperty ‘HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\‘ -Name “fDenyTSConnections” -Value 0 }
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Set-ItemProperty ‘HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\‘ -Name “UserAuthentication” -Value 0 }
#######

Restart-VM $Name -Force
Wait-VMPowershell -Name $Name -Credential $Credential

Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Install-Module DockerMsftProvider -Force }
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Install-Package Docker -ProviderName DockerMsftProvider -Force }
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Start-Service docker }

##check
#Get-Package -Name Docker -ProviderName DockerMsftProvider
#docker --version

##UPGRADE
#Install-Package -Name Docker -ProviderName DockerMsftProvider -Update -Force
#Start-Service Docker

#Pull the Windows Base Images
#docker pull microsoft/dotnet-samples:dotnetapp-nanoserver-1809
#docker run microsoft/dotnet-samples:dotnetapp-nanoserver-1809
#[Optional] Pull the .NET Core Images
#docker image pull microsoft/dotnet:2.1-sdk-nanoserver-1809
#docker image pull microsoft/dotnet:2.1-aspnetcore-runtime-nanoserver-1809  

#Try it Out!
docker container run -d -p 8080:80 sixeyed/whoami-dotnet:nanoserver-1809  
