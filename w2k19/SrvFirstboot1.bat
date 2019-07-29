netdom renamecomputer %COMPUTERNAME% /newname:SRV1

::onlinerun https://raw.githubusercontent.com/vinils/baxh/master/w2k19/DriversNetWork.bat
::onlinerun https://raw.githubusercontent.com/vinils/baxh/master/w2k19/DriversNetworkAfterReboot.ps1
::onlinerun https://raw.githubusercontent.com/vinils/baxh/master/w2k19/EnableRemoteDesktop.ps1

powershell.exe -command "& Invoke-WebRequest https://raw.githubusercontent.com/vinils/baxh/master/windows/onlinerun.bat -OutFile C:\WINDOWS\System32\onlinerun.bat"
powershell.exe -command "& Invoke-WebRequest https://raw.githubusercontent.com/vinils/baxh/master/windows/onlinerun.ps1 -OutFile C:\WINDOWS\System32\onlinerun.ps1"
powershell.exe -command "& Invoke-WebRequest https://raw.githubusercontent.com/vinils/baxh/master/w2k19/Wait-VMPowershell.ps1 -OutFile C:\WINDOWS\System32\Wait-VMPowershell.ps1"
powershell.exe -command "& Invoke-WebRequest https://raw.githubusercontent.com/vinils/baxh/master/w2k19/EnableNestedVM.ps1 -OutFile C:\WINDOWS\System32\EnableNestedVM.ps1"

###########################
# Firewall

#netsh advfirewall set allprofiles state off
###LOG
##netsh advfirewall set currentprofile logging filename %systemroot%\system32\LogFiles\Firewall\pfirewall.log
#netsh advfirewall set currentprofile logging maxfilesize 4096
#netsh advfirewall set currentprofile logging droppedconnections enable
##netsh advfirewall set currentprofile logging allowedconnections enable

netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=yes
netsh advfirewall firewall set rule name="File and Printer Sharing (SMB-In)" dir=in new enable=Yes
########

###########################
# Hyper-v Switch
#Get-NetAdapter 

### NAT
##$swichName = "NAT"
##New-VMSwitch -SwitchName $swichName -SwitchType Internal
##New-NetIPAddress -IPAddress 172.19.60.97 -PrefixLength 28 -InterfaceIndex (Get-NetAdapter -Name $swichName).ifIndex
#New-NetNat -Name "NAT" -InternalIPInterfaceAddressPrefix 28
 
New-VMSwitch -name PrivateSwitch -SwitchType Private  
New-VMSwitch -name InternalSwitch -SwitchType Internal  
New-VMSwitch -name ExternalSwitch  -NetAdapterName "Ethernet 2" -AllowManagementOS $true

###########################
# Drivers
onlinerun https://raw.githubusercontent.com/vinils/baxh/master/w2k19/Drivers.bat

shutdown /r /f
