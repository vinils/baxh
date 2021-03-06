#!/bin/bash

bootDir=$1
pwd=$2
hostName=$3

if [[ -z "$bootDir" ]]; then
  printf "Boot dir name (e.g.: boot): "
  read -r bootDir
fi

if [[ -z "$bootDir" ]]; then
  echo "Boot dir name required!"
  exit 1
fi


if [[ -z "$pwd" ]]; then
  printf "Password: "
  read -r pwd
fi

if [[ -z "$pwd" ]]; then
  echo "Password required!"
  exit 1
fi


if [[ -z "$hostName" ]]; then
  printf "Host name (e.g.: SRV1): "
  read -r hostName
fi

if [[ -z "$hostName" ]]; then
  echo "Host name required!"
  exit 1
fi

curl https://raw.githubusercontent.com/vinils/baxh/master/linux/onlinerun -o /bin/onlinerun
chmod +xr /bin/onlinerun

cat << EOF | tee -a /etc/pacman.conf
[multilib]
Include = /etc/pacman.d/mirrorlist
EOF
mirrlistFile="/etc/pacman.d/mirrorlist"
mv $mirrlistFile $mirrlistFile.bkp
curl "https://www.archlinux.org/mirrorlist/?country=BR&protocol=http&protocol=https&ip_version=4" -o $mirrlistFile
sed -i 's/#S/S/g' $mirrlistFile
pacman -Syy

ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
hwclock --systohc --utc

echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "pt_BR.UTF-8 UTF-8" >> /etc/locale.gen
echo "pt_BR ISO-8859-1" >> /etc/locale.gen
#cat /etc/locale.gen
locale-gen
 # export LANG=pt_BR.UTF-8

echo "$hostName" >> /etc/hostname

echo "127.0.0.1	localhost.localdomain	localhost" >> /etc/hosts
echo "::1		localhost.localdomain	localhost" >> /etc/hosts
echo "127.0.1.1	$hostname.localdomain	$hostname" >> /etc/hosts

#mkinitcpio -p linux

echo "root:$pwd" | chpasswd

pacman -S --noconfirm grub efibootmgr os-prober
grub-install --target=x86_64-efi --efi-directory=/"$bootDir"
cd /boot/efi/arch
grub-install --target=x86_64-efi --efi-directory=/"$bootDir" --recheck
#(if intell virtualization VT-x)
sed -i 's/GRUB_CMDLINE_LINUX=\"/GRUB_CMDLINE_LINUX=\"intremap=no_x2apic_optout\ intel_iommu=on\ iommu=pt/g' /etc/default/grub
grub-mkconfig -o /"$bootDir"/grub/grub.cfg


pacman -S --noconfirm openssh
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
systemctl enable sshd.socket


####################################################################################################
# uptdate firmware

sudo pacman -S fwupd
fwupdmgr refresh
fwupdmgr get-updates
fwupdmgr update

#pcis
update-pciids

####################################################################################################
#firstboot

onlinerun https://raw.githubusercontent.com/vinils/baxh/master/arch/firstboot.sh $pwd

####################################################################################################
#LAN

#light way
systemctl enable dhcpcd

#custom way
#onlinerun https://raw.githubusercontent.com/vinils/baxh/master/arch/lan.sh

####################################################################################################
