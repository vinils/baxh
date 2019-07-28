::::::::::::::
::https://blog.workinghardinit.work/2017/06/19/installing-intel-i211-i217v-i218v-i219v-drivers-windows-server-2016-eufi-boot/
::
::VEN_8086&DEV_1539
::PCI\VEN_8086&DEV_1539&SUBSYS_85F01043&REV_03 - I211
::
::VEN_8086&DEV_15B8
::PCI\VEN_8086&DEV_15B8&SUBSYS_15B81849&REV_00
::
::
::Get-ChildItem -Path “C:\Users\Administrator\Downloads\PROWinx64\PRO1000\Winx64\NDIS65” -recurse | Select-String -pattern “VEN_8086&DEV_1539” | ::group path | select name
::C:\Users\Administrator\Downloads\PROWinx64\PRO1000\Winx64\NDIS65\e1r65x64.inf
::
::Get-ChildItem -Path "C:\Users\Administrator\Downloads\PROWinx64\PRO1000\Winx64\NDIS65" -recurse | Select-String -pattern “VEN_8086&DEV_15B8” | ::group path | select name
::C:\Users\Administrator\Downloads\PROWinx64\PRO1000\Winx64\NDIS65\e1d65x64.inf

bcdedit /set loadoptions DISABLE_INTEGRITY_CHECKS
bcdedit /set TESTSIGNING ON
bcdedit /set NOINTEGRITYCHECKS OFF

shutdown /r /f

::(remember this below)
::Settings\Update & Security\Recovery - restart now
::Troubleshoot\Startup Settings - restart
::select disable drive signature enforcement
::(end remeber)
