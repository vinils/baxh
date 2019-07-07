!/bin/bash

pacman -Syu

#################################################################
#wifi

wlanDevName="wlp4s0"

pacman -S --noconfirm wpa_supplicant
echo "#/usr/share/doc/wpa_supplicant/wpa_supplicant.conf" >> /etc/wpa_supplicant/wpa_supplicant-$wlanDevName.conf
echo "#wpa_supplicant -B -i $wlanDevName -c <(wpa_passphrase essid pwd_phrase)"
echo "ctrl_interface=/run/wpa_supplicant" >> /etc/wpa_supplicant/wpa_supplicant-$wlanDevName.conf
echo "#ctrl_interface_group=wheel" >> /etc/wpa_supplicant/wpa_supplicant-$wlanDevName.conf
echo "update_config=1" >> /etc/wpa_supplicant/wpa_supplicant-$wlanDevName.conf
echo " "
echo "network={" >> /etc/wpa_supplicant/wpa_supplicant-$wlanDevName.conf
echo "        ssid=\"VIVO-F762\"" >> /etc/wpa_supplicant/wpa_supplicant-$wlanDevName.conf
echo "        priority=1" >> /etc/wpa_supplicant/wpa_supplicant-$wlanDevName.conf
echo "        psk=23acc791a3c554a22ec2e4684f35923679b89bca32c236b332d697269eea3a43" >> /etc/wpa_supplicant/wpa_supplicant-$wlanDevName.conf
echo "}" >> /etc/wpa_supplicant/wpa_supplicant-$wlanDevName.conf
echo " "
echo "network={" >> /etc/wpa_supplicant/wpa_supplicant-$wlanDevName.conf
echo "        ssid=\"Gil\"" >> /etc/wpa_supplicant/wpa_supplicant-$wlanDevName.conf
echo "        psk=baf4fd23d657dbf3bdd65caaec79dcbb669e9e1d26932d2acae01987a1b6b4b0" >> /etc/wpa_supplicant/wpa_supplicant-$wlanDevName.conf
echo "}" >> /etc/wpa_supplicant/wpa_supplicant-$wlanDevName.conf

ln -s /usr/share/dhcpcd/hooks/10-wpa_supplicant /usr/lib/dhcpcd/dhcpcd-hooks/
#################################################################

#################################################################
#(If running under VMWare) Install VM tools
#pacman -S --noconfirm open-vm-tools open-vm-tools-dkms
#dkms add open-vm-tools/9.4.0
#cat /proc/version > /etc/arch-release
#systemctl start vmtoolsd
#systemctl enable vmtoolsd
#vmware-toolbox-cmd timesync enable
#################################################################

#################################################################
pacman -S --noconfirm ntp
systemctl enable ntpd
#################################################################

#################################################################
#pacman -S --noconfirm webmin
#https://gitlab.com/mauriciobaeza/empresa-libre/wikis/Instalando-Webmin-en-la-M%C3%A1quina-Virtual-Arch-Linux-de-Empresa-Libre
#https://www.hiroom2.com/2017/10/21/archlinux-20171001-webmin-en/
#systemctl start webmin
#systemctl enable webmin
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
sudo sed --in-place 's/^#\s*\(%$wheelGrp\s\+ALL=(ALL)\s\+NOPASSWD:\s\+ALL\)/\1/' /etc/sudoers
#check
#visudo
#################################################################

#################################################################
#Install dev tools for AUR

#pacman -S --noconfirm base-devel
#pacman -S --noconfirm wget
#################################################################

#################################################################
#Install Yaourt

#su $myusr
#cd ~
#mkdir builds && cd builds

#wget https://aur.archlinux.org/packages/pa/package-query/package-query.tar.gz
#tar -xvzf package-query.tar.gz
#cd package-query
#makepkg -s
#sudo pacman -U package-query-*.xz

#cd ~/builds
#wget https://aur.archlinux.org/packages/ya/yaourt/yaourt.tar.gz
#tar -xvzf yaourt.tar.gz
#cd yaourt
#makepkg -s
#sudo pacman -U yaourt-*.xz
#################################################################

reboot