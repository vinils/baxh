::Drivers

pnputil -i -a ".\SOFTWARES\SETUP\X299\2016 server\DRIVERS\ASMedia_SATA3(v3.2.1)\Driver\scsi\i386\*.inf"
pnputil -i -a ".\SOFTWARES\SETUP\X299\2016 server\DRIVERS\ASMedia_SATA3(v3.2.1)\Driver\scsi\amd64\*.inf"

pnputil -i -a ".\SOFTWARES\SETUP\X299\2016 server\DRIVERS\ASMedia_SATA3(v3.2.1)\Driver\stahci\i386\*.inf"
pnputil -i -a ".\SOFTWARES\SETUP\X299\2016 server\DRIVERS\ASMedia_SATA3(v3.2.1)\Driver\stahci\amd64\*.inf"

pnputil -i -a ".\SOFTWARES\SETUP\X299\2016 server\DRIVERS\ASMedia_SATA3(v3.2.1)\Driver\stor\i386\*.inf"
pnputil -i -a ".\SOFTWARES\SETUP\X299\2016 server\DRIVERS\ASMedia_SATA3(v3.2.1)\Driver\stor\amd64\*.inf"

pnputil -i -a ".\SOFTWARES\SETUP\X299\2016 server\DRIVERS\ASMedia_SATA3(v3.2.1)\Driver_Win10\stahci\i386\*.inf"
pnputil -i -a ".\SOFTWARES\SETUP\X299\2016 server\DRIVERS\ASMedia_SATA3(v3.2.1)\Driver_Win10\stahci\amd64\*.inf"

pnputil -i -a ".\SOFTWARES\SETUP\X299\2016 server\DRIVERS\Floppy(v15.7.1.1015)\f6flpy-x86\*.inf"
pnputil -i -a ".\SOFTWARES\SETUP\X299\2016 server\DRIVERS\Floppy(v15.7.1.1015)\f6flpy-x64\*.inf"

".\SOFTWARES\SETUP\X299\2016 server\DRIVERS\Intel_Bluetooth(v19.60.0.3g)\Win10\Intel Bluetooth.msi" /passive /norestart

pnputil -i -a ".\SOFTWARES\SETUP\X299\2016 server\DRIVERS\Intel_LAN(v23.5.2)\PRO40GB\Winx64\NDIS65\*.inf"
pnputil -i -a ".\SOFTWARES\SETUP\X299\2016 server\DRIVERS\Intel_LAN(v23.5.2)\PRO40GB\Winx64\NDIS68\*.inf"
pnputil -i -a ".\SOFTWARES\SETUP\X299\2016 server\DRIVERS\Intel_LAN(v23.5.2)\PRO100\Winx64\NDIS62\*.inf"
pnputil -i -a ".\SOFTWARES\SETUP\X299\2016 server\DRIVERS\Intel_LAN(v23.5.2)\PRO1000\Winx64\NDIS65\*.inf"
pnputil -i -a ".\SOFTWARES\SETUP\X299\2016 server\DRIVERS\Intel_LAN(v23.5.2)\PRO1000\Winx64\NDIS68\*.inf"
pnputil -i -a ".\SOFTWARES\SETUP\X299\2016 server\DRIVERS\Intel_LAN(v23.5.2)\PROXGB\Winx64\NDIS65\*.inf"
pnputil -i -a ".\SOFTWARES\SETUP\X299\2016 server\DRIVERS\Intel_LAN(v23.5.2)\PROXGB\Winx64\NDIS68\*.inf"
".\SOFTWARES\SETUP\X299\2016 server\DRIVERS\Intel_LAN(v23.5.2)\APPS\PROSETDX\Winx64\DxSetup.exe" /quiet /passive
::notworking
::".\SOFTWARES\SETUP\X299\2016 server\DRIVERS\Intel_WiFi(v19.60.00)\IntelWifi_19_60_00.exe" /SILENT

pnputil -i -a ".\SOFTWARES\SETUP\X299\2016 server\DRIVERS\Realtek_Audio(v8051_FF10)\WIN64\*.inf"

".\SOFTWARES\SETUP\X299\2016 server\DRIVERS\chipset-10.1.17\SetupChipset.exe" -s -norestart
::pnputil -i -a ".\SOFTWARES\SETUP\X299\2016 server\DRIVERS\chipset-10.1.17\DriverFiles\production\W2K12R2-x64\*.inf"
pnputil -i -a ".\SOFTWARES\SETUP\X299\2016 server\DRIVERS\chipset-10.1.17\DriverFiles\production\Windows10-x64\*.inf"
pnputil -i -a ".\SOFTWARES\SETUP\X299\2016 server\DRIVERS\chipset-10.1.17\DriverFiles\production\W2K16-x64\*.inf"
::pnputil -i -a ".\SOFTWARES\SETUP\X299\2016 server\DRIVERS\chipset-10.1.17\DriverFiles\production\Windows10-x86\*.inf"
".\SOFTWARES\SETUP\X299\2016 server\DRIVERS\INF(v10.1.1.44_Public)\SetupChipset.exe" -s -norestart
".\SOFTWARES\SETUP\X299\2016 server\DRIVERS\Chipset_Win10_10.1.1.44\SetupChipset.exe" -s -norestart

shutdown /r /f
