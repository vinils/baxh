#!/bin/bash
#https://kyau.net/wiki/ArchLinux:KVM


#################################################################
#enable VTd
sudo modprobe -r kvm_intel
sudo modprobe kvm_intel nested=1
cat << EOF | sudo tee -a /etc/modprobe.d/kvm_intel.conf
options kvm-intel nested=1
options kvm-intel enable_shadow_vmcs=1
options kvm-intel enable_apicv=1
options kvm-intel ept=1
EOF
#################################################################


sudo pacman -S --noconfirm qemu-headless libvirt bridge-utils openbsd-netcat dmidecode


#################################################################
#Cannot check dnsmasq binary /usr/bin/dnsmasq: No such file or directory direct firewall backend requested,
sudo systemctl disable nftables
sudo systemctl stop nftables
sudo pacman -S --noconfirm dnsmasq ebtables ipset firewalld
sudo systemctl --now enable firewalld
##check
#sudo firewall-cmd --state
#sudo systemctl status firewalld
sudo firewall-cmd --permanent --zone=public --add-interface=enp5s0
sudo firewall-cmd --permanent --zone=public --add-interface=bond0
sudo firewall-cmd --permanent --zone=public --add-interface=kvm0
sudo firewall-cmd --zone=public --permanent --add-service=https
sudo firewall-cmd --zone=public --permanent --add-port=5900-5950/udp
sudo firewall-cmd --zone=public --permanent --add-port=5900-5950/tcp
#check
#sudo firewall-cmd --list-all
#################################################################


#################################################################
#allow remote connection from users in libvirt group
sudo usermod -a -G libvirt $(whoami)
sudo usermod -a -G libvirt root
#newgrp libvirt
sudo pacman -S --noconfirm polkit
cat << EOF | sudo tee -a /etc/polkit-1/rules.d/50-libvirt.rules
/* Allow users in kvm group to manage the libvirt daemon without authentication */
polkit.addRule(function(action, subject) {
    if (action.id == "org.libvirt.unix.manage" &&
      subject.isInGroup("libvirt")) {
        return polkit.Result.YES;
    }
});
EOF
#################################################################


sudo systemctl enable --now libvirtd


#################################################################
#Adding the OVMF firmware to libvirt.
sudo pacman -S --noconfirm ovmf
cat << EOF | sudo tee -a /etc/libvirt/qemu.conf
nvram = [
    "/usr/share/ovmf/x64/OVMF_CODE.fd:/usr/share/ovmf/x64/OVMF_VARS.fd"
]
EOF
#################################################################


#################################################################
#network

cat << EOF | sudo tee -a /etc/libvirt/bridge.xml
<network>
        <name>kvm0</name>
        <forward mode="bridge"/>
        <bridge name="kvm0"/>
</network>
EOF

sudo virsh net-define --file /etc/libvirt/bridge.xml
sudo virsh net-autostart kvm0
sudo virsh net-start kvm0
sudo virsh net-destroy default
sudo virsh net-undefine default
#################################################################


#################################################################
sudo useradd -g kvm -s /usr/bin/nologin kvm
echo "user = \"root\"" | sudo tee -a /etc/libvirt/qemu.conf
echo "group = \"root\"" | sudo tee -a /etc/libvirt/qemu.conf
sudo usermod -a -G kvm $(whoami)
sudo usermod -a -G kvm root
##check
#virsh list --all
# wrong output >> libvir: Remote error : Permission denied
#################################################################


#################################################################
cat << EOF | sudo tee -a /etc/fstab

# /dev/sda2
UUID="98B88774B8875024"  /mnt/dados  ntfs-3g  defaults  0 0
EOF
sudo mkdir /mnt/dados
sudo mount -t ntfs-3g /dev/sda2 /mnt/dados
sudo mkdir /etc/libvirt/volume

cat << EOF | sudo tee -a /etc/libvirt/volume/isos.vol
<pool type="dir">
  <name>isoimages</name>
  <target>
  <path>/mnt/dados/SOFTWARES/WORK/MS Windows/2016 Server/</path>
  <permissions>
    <mode>0770</mode>
    <owner>78</owner>
    <group>78</group>
  </permissions>
  </target>
</pool>
EOF

cat << EOF | sudo tee -a /etc/libvirt/volume/kvmDrivers.vol
<pool type="dir">
  <name>isoimages</name>
  <target>
  <path>/mnt/dados/SOFTWARES/WORK/KVM/</path>
  <permissions>
    <mode>0770</mode>
    <owner>78</owner>
    <group>78</group>
  </permissions>
  </target>
</pool>
EOF

sudo chown kvm:kvm /var/lib/libvirt/images/
sudo setfacl -m u:kvm:rx /var/lib/libvirt/images/
echo "ENV{DM_VG_NAME}==\"vdisk\" ENV{DM_LV_NAME}==\"*\" OWNER=\"kvm\"" | sudo tee -a /etc/udev/rules.d/90-kvm.rules
sudo virsh pool-define /etc/libvirt/volume/isos.vol
sudo virsh pool-define /etc/libvirt/volume/kvmDrivers.vol
sudo virsh pool-build isoimages
sudo virsh pool-autostart isoimages
#################################################################


#################################################################
#Hugepages
grpKvmId="78"
sudo groupmod -g $grpKvmId kvm
sudo usermod -u $grpKvmId kvm

echo "hugetlbfs /dev/hugepages hugetlbfs mode=1770,gid=$grpKvmId 0 0" | sudo tee -a /etc/fstab
sudo umount /dev/hugepages
sudo mount /dev/hugepages
##check
# sudo mount | grep huge
# ls -FalG /dev/ | grep huge

echo 9000 | sudo tee /proc/sys/vm/nr_hugepages
echo "vm.nr_hugepages = 9000" | sudo tee -a /etc/sysctl.d/40-hugepages.conf
##check
#grep HugePages_Total /proc/meminfo
#cat /proc/meminfo
#output >> HugePages_Total:   15360
#output >> HugePages_Free:    15360

echo "hugetlbfs_mount = \"/dev/hugepages\"" | sudo tee -a /etc/libvirt/qemu.conf
##veriy IOMMU
#sudo dmesg | grep -e DMAR -e IOMMU
##output >>  [ 0.000000] DMAR: IOMMU enabled.
#################################################################


#################################################################
#Enable SPICE over TLS will allow SPICE to be exposed externally.
echo "spice_listen = \"0.0.0.0\"" | sudo tee -a /etc/libvirt/qemu.conf
echo "spice_tls = 1" | sudo tee -a /etc/libvirt/qemu.conf
echo "spice_tls_x509_cert_dir = \"/etc/pki/libvirt-spice\"" | sudo tee -a /etc/libvirt/qemu.conf
SERVER_KEY=server-key.pem
/bin/bash << EndOfMessage
#!/bin/bash
# creating a key for our ca
if [ ! -e ca-key.pem ]; then
    openssl genrsa -des3 -out ca-key.pem 1024
fi
# creating a ca
if [ ! -e ca-cert.pem ]; then
    openssl req -new -x509 -days 1095 -key ca-key.pem -out ca-cert.pem -utf8 -subj "/C=WA/L=Seattle/O=KYAU Labs/CN=KVM"
fi
# create server key
if [ ! -e $SERVER_KEY ]; then
    openssl genrsa -out $SERVER_KEY 1024
fi
# create a certificate signing request (csr)
if [ ! -e server-key.csr ]; then
    openssl req -new -key $SERVER_KEY -out server-key.csr -utf8 -subj "/C=WA/L=Seattle/O=KYAU Labs/CN=myhostname.example.com"
fi
# signing our server certificate with this ca
if [ ! -e server-cert.pem ]; then
    openssl x509 -req -days 1095 -in server-key.csr -CA ca-cert.pem -CAkey ca-key.pem -set_serial 01 -out server-cert.pem
fi
# now create a key that doesn't require a passphrase
openssl rsa -in $SERVER_KEY -out $SERVER_KEY.insecure
mv $SERVER_KEY $SERVER_KEY.secure
mv $SERVER_KEY.insecure $SERVER_KEY
# show the results (no other effect)
openssl rsa -noout -text -in $SERVER_KEY
openssl rsa -noout -text -in ca-key.pem
openssl req -noout -text -in server-key.csr
openssl x509 -noout -text -in server-cert.pem
openssl x509 -noout -text -in ca-cert.pem
EndOfMessage
sudo mkdir -p /etc/pki/libvirt-spice
sudo chmod -R a+rx /etc/pki
sudo mv ca-* server-* /etc/pki/libvirt-spice
sudo chmod 660 /etc/pki/libvirt-spice/*
sudo chown kvm:kvm /etc/pki/libvirt-spice/*
#################################################################


sudo systemctl restart libvirtd


#################################################################
#let's be nice to the VMs and give them some time to perform a graceful shutdown before the host powers off
sudo sed -i 's/#ON_SHUTDOWN=.*/ON_SHUTDOWN=shutdown/' /etc/conf.d/libvirt-guests
sudo systemctl enable libvirt-guests
#################################################################


#################################################################
#sudo modprobe 9pnet_virtio virtio_net virtio_pci virtio 9p 9pnet 9pnet_virtio
#echo "options kvm_intel nested=1" | sudo tee -a /etc/modules-load.d/virtio.conf
#echo "9pnet_virtio" | sudo tee -a /etc/modules-load.d/virtio.conf
#echo "virtio_net" | sudo tee -a /etc/modules-load.d/virtio.conf
#echo "virtio_pci" | sudo tee -a /etc/modules-load.d/virtio.conf
#echo "9p" | sudo tee -a /etc/modules-load.d/virtio.conf
#echo "9pnet" | sudo tee -a /etc/modules-load.d/virtio.conf
#echo "9pnet_virtio" | sudo tee -a /etc/modules-load.d/virtio.conf

#echo " mymount /mnt/fs            9p             trans=virtio    0       0" >> sudo tee -a /etc/fstab
#sudo mount -a

##If 9pnet is going to be used, change the global QEMU config to turn off dynamic file ownership.
#echo "dynamic_ownership = 0" | sudo tee -a /etc/libvirt/qemu.conf
#################################################################


#################################################################
#bug unknown I/O socket timeout
sudo firewall-cmd --set-log-denied=all
sudo firewall-cmd --set-log-denied=off
#################################################################


