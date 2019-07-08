#!/bin/bash
install2="arch-install2.bash"
curl https://raw.githubusercontent.com/vinils/baxh/master/arch/install2.bash -o $install2
chmod 777 $install2

pwd=$1
device=$2
#uefiSpace=$2
uefiSpace="512"
#swapSpace=$3
swapSpace="145"
#hostName=$5
hostName="SRV1"

if [[ -z "$pwd" ]]; then
  printf "Password: "
  read -r pwd
fi

if [[ -z "$pwd" ]]; then
  echo "Password required!"
  exit 1
fi


if [[ -z "$device" ]]; then
  lsblk
  printf "Device name (e.g.: sdf): "
  read -r device
fi

if [[ -z "$device" ]]; then
  echo "Device name required!"
  exit 1
fi


if [[ -z "$uefiSpace" ]]; then
  printf "UEFI space in MB(e.g.: 512): "
  read -r uefiSpace
fi

if [[ -z "$uefiSpace" ]]; then
  echo "UEFI space required!"
  exit 1
fi


if [[ -z "$swapSpace" ]]; then
  printf "SWAP space in GB (e.g.: 145): "
  read -r swapSpace
fi

if [[ -z "$swapSpace" ]]; then
  echo "SWAP space required!"
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


timedatectl set-ntp true

uefiPartitionNumber="1"
swapPartitionNumber="2"
linuxFSPartitionNumber="3"

#https://wiki.archlinux.org/index.php/Installation_guide_(Portugu%C3%AAs)

################## FDISK #################
ttt1=+"$uefiSpace"M
ttt2=+"$swapSpace"G
fdisk /dev/"$device" <<EEOF
o
n
p
$uefiPartitionNumber
$ttt1
t
ef
n
p
$swapPartitionNumber
$ttt2
t
$swapPartitionNumber
82
n
p
$linuxFSPartitionNumber
w
EEOF
#check
#fdisk -l
############################################


mntDir="mnt"
bootDir="boot"

mkfs.ext4 -F /dev/"$device""$linuxFSPartitionNumber"
mkfs.fat -F32 -n BOOT /dev/"$device""$uefiPartitionNumber"

mkswap -L  swap /dev/"$device""$swapPartitionNumber"
swapon /dev/"$device""$swapPartitionNumber"
#check
#swapon -s
#free -h

mount /dev/"$device""$linuxFSPartitionNumber" /"$mntDir"
mkdir /"$mntDir"/"$bootDir"
mount /dev/"$device""$uefiPartitionNumber" /"$mntDir"/"$bootDir"

pacstrap /"$mntDir" base
genfstab -U /"$mntDir" >> /"$mntDir"/etc/fstab
#check
#cat /mnt/etc/fstab
cp $install2 /mnt/root
arch-chroot /"$mntDir" /root/$install2 $bootDir $pwd $hostName
rm /mnt/root/$install2
rm $install2

umount /dev/"$device""$uefiPartitionNumber"
umount /dev/"$device""$linuxFSPartitionNumber"
reboot
