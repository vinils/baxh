#!/bin/bash
usr=$1
pwd=$2

if [[ -z "$usr" ]]; then
  printf "User: "
  read -r usr
fi

if [[ -z "$pwd" ]]; then
  printf "Password: "
  read -r pwd
fi

pacman -Sy --noconfirm samba

useradd -m $usr
#(echo "$pwd"; sleep 1; echo "$pwd" ) | sudo smbpasswd -s -a $usr
yes "$pwd" | pdbedit -a $usr -t

cat <<EOF | tee /etc/samba/smb.conf
[global]
   workgroup = WORKGROUP
   server string = Samba Server
   server role = standalone server
   log file = /var/log/samba/log.%m
   max log size = 50
   dns proxy = no

EOF

cat <<EOF | tee -a /etc/samba/smb.conf
[share]
   comment = Share Dados
   path = /mnt/dados
   read only = no
   guest only = no
   guest ok = no

EOF

#mkdir /mnt/dados
#chmod 0777 /mnt/dados

systemctl enable --now smb.service nmb.service

#If you are using a firewall, do not forget to open required ports (usually 137-139 + 445). For a complete list, see Samba port usage.

firewall-cmd --zone=public --permanent --add-port=137-139/tcp
firewall-cmd --zone=public --permanent --add-port=445/tcp

#################################################################
#BUG Unkwon connection problem
firewall-cmd --set-log-denied=all
firewall-cmd --set-log-denied=off
#################################################################

#check
#smbclient -L <machine0name> -U <user>
