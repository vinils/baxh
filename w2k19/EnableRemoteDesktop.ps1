#######
# remote desktop

#Enable Remote Desktop connections
Set-ItemProperty ‘HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\‘ -Name “fDenyTSConnections” -Value 0
#Enable Network Level Authentication
Set-ItemProperty ‘HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\‘ -Name “UserAuthentication” -Value 0
#Enable Windows firewall rules to allow incoming RDP
Enable-NetFirewallRule -DisplayGroup “Remote Desktop”
#######
