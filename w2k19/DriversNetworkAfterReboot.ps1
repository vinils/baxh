pnputil -i -a '.\SOFTWARES\SETUP\X299\2016 server\DRIVERS\Network\NDIS65\*.inf'

bcdedit /set loadoptions ENABLE_INTEGRITY_CHECKS
bcdedit /set TESTSIGNING OFF
bcdedit /set NOINTEGRITYCHECKS ON

shutdown /r /f
