#!/bin/bash
#helpfull links
#https://www.youtube.com/watch?v=qHoXTjrbLlo&t=523s
#https://github.com/Lend27/linuxstuff/blob/master/15thingsArch
#https://www.youtube.com/watch?v=DAmXKDJ3D7M

pwd=$1

if [[ -z "$pwd" ]]; then
  printf "Password: "
  read -r pwd
fi

if [[ -z "$pwd" ]]; then
  echo "Password required!"
  exit 1
fi

#################################################################
#devices drives sonds

pacman -S --noconfirm alsa-utils
#alsamixer
#speaker-test -c 2

#################################################################
#video

pacman -S --noconfirm mesa
#check video
#lspci | grep VGA
#>> 65:00.0 VGA compatible controller: Advanced Micro Devices, Inc. [AMD/ATI] Cedar [Radeon HD 5000/6000/7350/8350 Series]
#https://wiki.archlinux.org/index.php/AMDGPU
#check pacman -Ss xf86-video | less
pacman -S --noconfirm xf86-video-amdgpu

#################################################################

#pacman -S --noconfirm xorg-server xorg-xinit xorg-server-utils

#################################################################

#echo "[archlinuxfr]" >> /etc/pacman.conf
#echo "SigLevel = Never" >> /etc/pacman.conf
#echo "Server = http://repo.archlinux.fr/\$arch" >> /etc/pacman.conf
#pacman -Syu

#################################################################
#wifi

wlanDevName="wlp4s0"
pacman -S --noconfirm wpa_supplicant

#cat << EOF | tee /etc/netctl/$wlanDevName.Gil
#Description='GIL'
#Interface=$wlanDevName
#Connection=wireless
#Security=wpa
#IP=dhcp
#ESSID='Gil'
## Prepend hexadecimal keys with \"
## If your key starts with ", write it as '""<key>"'
## See also: the section on special quoting rules in netctl.profile(5)
#Key=\"baf4fd23d657dbf3bdd65caaec79dcbb669e9e1d26932d2acae01987a1b6b4b0
## Uncomment this if your ssid is hidden
##Hidden=yes
## Set a priority for automatic profile selection
##Priority=10
#EOF

#cat << EOF | tee /etc/netctl/$wlanDevName.VIVO-F762
#Description='A simple WPA encrypted wireless connection'
#Interface=$wlanDevName
#Connection=wireless
#Security=wpa
#IP=dhcp
#ESSID='VIVO-F762'
## Prepend hexadecimal keys with \"
## If your key starts with ", write it as '""<key>"'
## See also: the section on special quoting rules in netctl.profile(5)
#Key=\"23acc791a3c554a22ec2e4684f35923679b89bca32c236b332d697269eea3a43
## Uncomment this if your ssid is hidden
##Hidden=yes
## Set a priority for automatic profile selection
#Priority=10
#EOF

##PROBLEM - DHCPv6 REPLY: No addresses available for this interface
#cat << EOF | sudo tee -a /etc/dhcpcd.conf
#noipv6rs
#noipv6
#EOF
#sysctl -w net.ipv6.conf.all.disable_ipv6=1

#ip link set $wlanDevName down
#systemctl enable --now netctl-auto@$wlanDevName.service
#netctl-auto enable $wlanDevName.VIVO-F762
#netctl-auto switch-to wlp4s0.VIVO-F762
#################################################################

#################################################################
#(If running under VMWare) Install VM tools - (*never tested)
#pacman -S --noconfirm open-vm-tools open-vm-tools-dkms
#dkms add open-vm-tools/9.4.0
#cat /proc/version > /etc/arch-release
#systemctl --now enable vmtoolsd
#vmware-toolbox-cmd timesync enable

#pacman -S --noconfirm virtualbox-guest-utils
#cat << EOF | tee -a /etc/modules-load.d/virtualbox.conf
#vboxguest
#vboxsf
#vboxvideo
#EOF
#sudo systemctl enable vboxservice.service
#################################################################

#################################################################
pacman -S --noconfirm ntp

#if no ipv6 - disable ntp - err msg : ntpd unable to create socket on
echo "NTPD_OPTS='-4 -g'" >> /etc/default/ntp

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
##Install dev tools for AUR
#pacman -S --noconfirm base-devel
#################################################################

# adding git, support for ntfs mount
pacman -S --noconfirm ntfs-3g

# removing unecessary packages
pacman -Rns $(pacman -Qtdq)

#update mirror list
pacman -S --noconfirm reflector
reflector --latest 200 --protocol http --protocol https --sort rate --save /etc/pacman.d/mirrorlist && sudo pacman -Syy &
