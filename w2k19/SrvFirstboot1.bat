netdom renamecomputer %COMPUTERNAME% /newname:SRV1

::onlinerun https://raw.githubusercontent.com/vinils/baxh/master/w2k19/DriversNetWork.bat
::onlinerun https://raw.githubusercontent.com/vinils/baxh/master/w2k19/DriversNetworkAfterReboot.ps1
::onlinerun https://raw.githubusercontent.com/vinils/baxh/master/w2k19/EnableRemoteDesktop.ps1

onlinerun https://raw.githubusercontent.com/vinils/baxh/master/w2k19/Drivers.bat

shutdown /r /f
