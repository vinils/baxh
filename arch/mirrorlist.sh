#!/bin/bash
country="BR"
destinationFile="/etc/pacman.d/mirrorlist"
rm /etc/pacman.d/mirrorlist
curl "https://www.archlinux.org/mirrorlist/?country=$country&protocol=http&protocol=https&ip_version=4" -o $destinationFile
sed -i 's/#S/S/g' $destinationFile