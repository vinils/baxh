#!/bin/bash

rm /etc/pacman.d/mirrorlist
curl "https://www.archlinux.org/mirrorlist/?country=BR&protocol=http&protocol=https&ip_version=4" -o mirrorlist
sudo sed -i 's/#S/S/g' mirrorlist
sudo mv mirrorlist /etc/pacman.d/mirrorlist

#sudo pacman -S pacman-contrib
#sudo curl -o ~/mirrorlist https://www.archlinux.org/mirrorlist/all/
#sudo rankmirrors ~/mirrorlist > ~/mirrorlist.fastest
#sudo mv -v ~/mirrorlist.fastest /etc/pacman.d/mirrorlist
#sudo pacman -Syy
