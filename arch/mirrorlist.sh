#!/bin/bash

sudo rm /etc/pacman.d/mirrorlist
sudo curl "https://www.archlinux.org/mirrorlist/?country=BR&protocol=http&protocol=https&ip_version=4" -o mirrorlist
sudo sed -i 's/#S/S/g' mirrorlist
sudo mv mirrorlist /etc/pacman.d/mirrorlist
