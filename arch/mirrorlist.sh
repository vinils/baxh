#!/bin/bash

rm /etc/pacman.d/mirrorlist
curl "https://www.archlinux.org/mirrorlist/?country=BR&protocol=http&protocol=https&ip_version=4" -o mirrorlist
sudo sed -i 's/#S/S/g' mirrorlist
sudo mv mirrorlist /etc/pacman.d/mirrorlist
sudo pacman -Syy

#sudo pacman -S pacman-contrib
#sudo curl -o ~/mirrorlist https://www.archlinux.org/mirrorlist/all/
#sudo rankmirrors ~/mirrorlist > ~/mirrorlist.fastest
#sudo mv -v ~/mirrorlist.fastest /etc/pacman.d/mirrorlist
#sudo pacman -Syy

#sudo pacman -S reflector
##Verbosely rate and sort the five most recently synchronized mirrors by download speed, and overwrite the file /etc/pacman.d/mirrorlist:
#sudo reflector --verbose --latest 5 --sort rate --save /etc/pacman.d/mirrorlist
##Select the 200 most recently synchronized HTTP or HTTPS mirrors, sort them by download speed, and overwrite the file /etc/pacman.d/mirrorlist:
#sudo reflector --latest 200 --protocol http --protocol https --sort rate --save /etc/pacman.d/mirrorlist
##Select the HTTPS mirrors synchronized within the last 12 hours and located in the US, sort them by download speed, and overwrite the file /etc/pacman.d/mirrorlist:
#sudo reflector --country 'United States' --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
