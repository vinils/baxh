#!/bin/bash

myusr="myuser"

su $myusr
cd ~
mkdir builds
cd builds

sudo pacman -S --noconfirm --needed base-devel

git clone https://aur.archlinux.org/perl-authen-pam.git
cd perl-authen-pam
makepkg -s --noconfirm
sudo pacman -U --noconfirm ./*.pkg.tar.xz
cd ..

git clone https://aur.archlinux.org/perl-encode-detect.git
cd perl-encode-detect
makepkg -s --noconfirm
sudo pacman -U --noconfirm ./*.pkg.tar.xz
cd ..

git clone https://aur.archlinux.org/webmin.git
cd webmin
makepkg -s --noconfirm
sudo pacman -U --noconfirm ./*.pkg.tar.xz
cd ..

sudo systemctl --now enable webmin

#https://<server>:10000
