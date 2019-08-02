pwd=$1
device=$2
hostName=$3

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

if [[ -z "$hostName" ]]; then
  printf "Host name (e.g.: SRV1): "
  read -r hostName
fi

if [[ -z "$hostName" ]]; then
  echo "Host name required!"
  exit 1
fi

mirrlistFile="/etc/pacman.d/mirrorlist"
mv $mirrlistFile $mirrlistFile.bkp
curl "https://www.archlinux.org/mirrorlist/?country=BR&protocol=http&protocol=https&ip_version=4" -o $mirrlistFile
sed -i 's/#S/S/g' $mirrlistFile
pacman -Syy

timedatectl set-ntp true

uefiPartitionNumber="1"
swapPartitionNumber="2"
linuxFSPartitionNumber="3"

#sfdisk -d /dev/"$device" > t
sfdisk /dev/$device << EOF
label: dos
label-id: 0xd5e8d73e
device: /dev/"$device"
unit: sectors

/dev/"$device""$uefiPartitionNumber" : start=        2048, size=     1048576, type=ef
/dev/"$device""$swapPartitionNumber" : start=     1050624, size=    20971520, type=82
/dev/"$device""$linuxFSPartitionNumber" : start=    22022144, size=   187693056, type=83
EOF

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

install2="arch-install2.sh"
curl https://raw.githubusercontent.com/vinils/baxh/master/arch/install2.sh -o $install2
chmod +xr $install2
cp $install2 /mnt/root
arch-chroot /"$mntDir" /root/$install2 $bootDir $pwd $hostName
rm /mnt/root/$install2
rm $install2

umount /dev/"$device""$uefiPartitionNumber"
umount /dev/"$device""$linuxFSPartitionNumber"
reboot
