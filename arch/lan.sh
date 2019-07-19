#!/bin/bash

ethGig=enp5s0
ether2=eno1
wifi=wlp4s0

cat << EOF | tee -a /etc/systemd/network/management.network
[Match]
Name=$ethGig

[Network]
DHCP=yes
#DHCP=ipv4
LinkLocalAddressing=no
UseDomains=true
#RouteMetric=10
#IPv6PrivacyExtensions=true
## to use static IP uncomment these instead of DHCP
#DNS=192.168.1.254
#Address=192.168.1.87/24
#Gateway=192.168.1.254
EOF

bnd=bond0

cat << EOF | tee -a /etc/systemd/network/20-$ether2.network
[Match]
Name=$ether2

[Network]
Bond=$bnd
PrimarySlave=true
EOF

cat << EOF | tee -a /etc/systemd/network/20-$wifi.network
[Match]
Name=$wifi

[Network]
Bond=$bnd
EOF

cat << EOF | tee -a /etc/systemd/network/10-$bnd.network
[Match]
Name=$bnd

[Network]
DHCP=yes
LinkLocalAddressing=no
UseDomains=true
EOF

cat << EOF | tee -a /etc/systemd/network/10-$bnd.netdev
[NetDev]
Name=$bnd
Description=Bond 0
Kind=bond

[Bond]
Mode=active-backup
PrimaryReselectPolicy=always
TransmitHashPolicy=layer3+4
MIIMonitorSec=1s
LACPTransmitRate=fast
EOF

mv /etc/resolv.conf /etc/resolv.conf.bak
ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
systemctl enable --now systemd-networkd
systemctl enable --now systemd-resolved


pacman -S --noconfirm wpa_supplicant
cat << EOF | tee -a /etc/wpa_supplicant/wpa_supplicant-$wifi.conf
#wpa_supplicant -B -i $wifi -c <(wpa_passphrase essid pwd_phrase)
ctrl_interface=/run/wpa_supplicant
#ctrl_interface_group=wheel
update_config=1
 
network={
        ssid="VIVO-F762"
        psk=23acc791a3c554a22ec2e4684f35923679b89bca32c236b332d697269eea3a43
}
 
network={
        ssid="Gil"
        psk=baf4fd23d657dbf3bdd65caaec79dcbb669e9e1d26932d2acae01987a1b6b4b0
}
EOF
systemctl enable --now wpa_supplicant@$wifi
