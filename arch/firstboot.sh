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
#Key='maria123'
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
#Key='J629109887'
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
