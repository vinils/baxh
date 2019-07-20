pacman -Sy --noconfirm samba

useradd -m samba
yes "samba01" | pdbedit -a samba -t

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
   share modes = yes

EOF

mkdir /mnt/dados
#chmod 0777 /mnt/dados

systemctl enable --now smb.service nmb.service

#If you are using a firewall, do not forget to open required ports (usually 137-139 + 445). For a complete list, see Samba port usage.

firewall-cmd --zone=public --permanent --add-port=137-139/tcp
firewall-cmd --zone=public --permanent --add-port=445/tcp
