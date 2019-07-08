!/bin/bash
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

ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
hwclock --systohc --utc

echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "pt_BR.UTF-8 UTF-8" >> /etc/locale.gen
echo "pt_BR ISO-8859-1" >> /etc/locale.gen
#cat /etc/locale.gen
locale-gen
 # export LANG=pt_BR.UTF-8

#https://wiki.archlinux.org/index.php/Network_configuration_(Portugu%C3%AAs)
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
grub-install --target=x86_64-efi --efi-directory=/"$bootDir" --bootloader-id=arch_gru

#(if intell virtualization VT-x)
sed -i 's/GRUB_CMDLINE_LINUX=\"/GRUB_CMDLINE_LINUX=\"intel_iommu=on iommu=pt/g' /etc/default/grub

grub-mkconfig -o /"$bootDir"/grub/grub.cfg


#ls /sys/class/net || ip link
systemctl enable dhcpcd.service

pacman -S --noconfirm openssh
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
#systemctl enable sshd.service
systemctl enable sshd.socket
© 2019 GitHub, Inc.
