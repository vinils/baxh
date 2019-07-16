#!/bin/bash

pwd=$1

if [[ -z "$pwd" ]]; then
  printf "Password: "
  read -r pwd
fi

if [[ -z "$pwd" ]]; then
  echo "Password required!"
  exit 1
fi


#echo "[archlinuxfr]" >> /etc/pacman.conf
#echo "SigLevel = Never" >> /etc/pacman.conf
#echo "Server = http://repo.archlinux.fr/\$arch" >> /etc/pacman.conf
#pacman -Syu

#################################################################
#wifi

wlanDevName="wlp4s0"

pacman -S --noconfirm wpa_supplicant
ln -s /usr/share/dhcpcd/hooks/10-wpa_supplicant /usr/lib/dhcpcd/dhcpcd-hooks/
cat << EOF | tee -a /etc/wpa_supplicant/wpa_supplicant-$wlanDevName.conf
#wpa_supplicant -B -i $wlanDevName -c <(wpa_passphrase essid pwd_phrase)
ctrl_interface=/run/wpa_supplicant
#ctrl_interface_group=wheel
update_config=1
 
network={
        ssid="VIVO-F762"
        priority=1
        psk=23acc791a3c554a22ec2e4684f35923679b89bca32c236b332d697269eea3a43
}
 
network={
        ssid=\
        Gil\"
        psk=baf4fd23d657dbf3bdd65caaec79dcbb669e9e1d26932d2acae01987a1b6b4b0
}
EOF
#################################################################

#################################################################
#(If running under VMWare) Install VM tools
#pacman -S --noconfirm open-vm-tools open-vm-tools-dkms
#dkms add open-vm-tools/9.4.0
#cat /proc/version > /etc/arch-release
#systemctl --now enable vmtoolsd
#vmware-toolbox-cmd timesync enable
#################################################################

#################################################################
pacman -S --noconfirm ntp
systemctl --now enable ntpd
#################################################################

myusr="myuser"

#################################################################
#New user

wheelGrp="wheel"

useradd -m -G $wheelGrp -s /bin/bash $myusr
echo "$myusr:$pwd" | chpasswd
#check
#passwd -Sa

pacman -S --noconfirm sudo
echo "$myusr ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$myusr
#check
#visudo
#################################################################

#################################################################
#Install dev tools for AUR

pacman -S --noconfirm base-devel
#################################################################

# adding git, support for ntfs mount
pacman -S --noconfirm git ntfs-3g


## removing unecessary packages
#pacman -Rns $(pacman -Qtdq)
