netdom renamecomputer %COMPUTERNAME% /newname:SRV1

::onlinerun https://raw.githubusercontent.com/vinils/baxh/master/w2k19/DriversNetWork.bat
::onlinerun https://raw.githubusercontent.com/vinils/baxh/master/w2k19/DriversNetworkAfterReboot.ps1
::onlinerun https://raw.githubusercontent.com/vinils/baxh/master/w2k19/EnableRemoteDesktop.ps1

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
New-VMSwitch -name PrivateSwitch -SwitchType Private  
New-VMSwitch -name InternalSwitch -SwitchType Internal  
New-VMSwitch -name ExternalSwitch  -NetAdapterName "Ethernet 2" -AllowManagementOS $true


###########################
# Drivers
onlinerun https://raw.githubusercontent.com/vinils/baxh/master/w2k19/Drivers.bat

shutdown /r /f
