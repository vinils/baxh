#!/bin/bash
#https://kyau.net/wiki/ArchLinux:KVM

myusr="myuser"

if [ "$(id -u)" -ne 0 ]; then
    echo 'This script must be run with root privileges' >&2
    exit 1
fi

###### VT-x
sudo modprobe -r kvm_intel
sudo modprobe kvm_intel nested=1
echo 'options kvm_intel nested=1' >> /etc/modprobe.d/kvm_intel.conf
##/etc/modules-load.d/virtio.conf
#sudo modprobe 9pnet_virtio virtio_net virtio_pci
#echo "options kvm_intel nested=1" >> /etc/modules-load.d/virtio.conf
#echo "9pnet_virtio" >> /etc/modules-load.d/virtio.conf
#echo "virtio_net" >> /etc/modules-load.d/virtio.conf
#echo "virtio_pci" >> /etc/modules-load.d/virtio.conf
sudo -H -u $myusr bash -c "sudo pacman -S --noconfirm dmidecode ovmf qemu-headless qemu-headless-arch-extra libvirt bridge-utils ebtables openbsd-netcat virt-install"

#echo "dynamic_ownership = 0" >> /etc/libvirt/qemu.conf
##check
#sudo systool -m kvm_intel -v | grep nested

###########
grpKvmId="78"
sudo useradd -g kvm -s /usr/bin/nologin kvm
echo "user = \"kvm\"" >> /etc/libvirt/qemu.conf
echo "group = \"kvm\"" >> /etc/libvirt/qemu.conf
sudo groupmod -g $grpKvmId kvm
sudo usermod -u $grpKvmId kvm

sudo gpasswd -a $myusr kvm
sudo gpasswd -a $myusr libvirt

sudo gpasswd -a root kvm
sudo gpasswd -a root libvirt

#This solution is not persistent across reboots, for that you have to create an udev rule: /etc/udev/rules.d/65-kvm.rules
#KERNEL=="kvm", NAME="%k", GROUP="kvm", MODE="0660"

echo "/* Allow users in kvm group to manage the libvirt daemon without authentication */" >> /etc/polkit-1/rules.d/50-libvirt.rules
echo "polkit.addRule(function(action, subject) {" >> /etc/polkit-1/rules.d/50-libvirt.rules
echo "    if (action.id == \"org.libvirt.unix.manage\" &&" >> /etc/polkit-1/rules.d/50-libvirt.rules
echo "      subject.isInGroup(\"libvirt\")) {" >> /etc/polkit-1/rules.d/50-libvirt.rules
echo "        return polkit.Result.YES;" >> /etc/polkit-1/rules.d/50-libvirt.rules
echo "    }" >> /etc/polkit-1/rules.d/50-libvirt.rules
echo "});" >> /etc/polkit-1/rules.d/50-libvirt.rules

##check
#grep kvm /etc/group

echo "hugetlbfs /dev/hugepages hugetlbfs mode=1770,gid=$grpKvmId 0 0" >> /etc/fstab
sudo umount /dev/hugepages
sudo mount /dev/hugepages

##check
# sudo mount | grep huge
# ls -FalG /dev/ | grep huge

echo 15360 | sudo tee /proc/sys/vm/nr_hugepages
echo "vm.nr_hugepages = 15360" >> /etc/sysctl.d/40-hugepages.conf
##check
#grep HugePages_Total /proc/meminfo
#cat /proc/meminfo
#output >> HugePages_Total:   15360
#output >> HugePages_Free:    15360

echo "hugetlbfs_mount = \"/dev/hugepages\"" >> /etc/libvirt/qemu.conf
##veriy IOMMU
#sudo dmesg | grep -e DMAR -e IOMMU
##output >>  [ 0.000000] DMAR: IOMMU enabled.

echo "nvram = [" >> /etc/libvirt/qemu.conf
echo "	\"/usr/share/ovmf/x64/OVMF_CODE.fd:/usr/share/ovmf/x64/OVMF_VARS.fd\"" >> /etc/libvirt/qemu.conf
echo "]" >> /etc/libvirt/qemu.conf

echo "spice_listen = \"0.0.0.0\"" >> /etc/libvirt/qemu.conf
echo "spice_tls = 1" >> /etc/libvirt/qemu.conf
echo "spice_tls_x509_cert_dir = \"/etc/pki/libvirt-spice\"" >> /etc/libvirt/qemu.conf
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

sudo systemctl --now enable libvirtd
##check
#virsh --connect qemu:///system
#quit


echo "[Match]" >> /etc/systemd/network/management.network
echo "Name=enp5s0" >> /etc/systemd/network/management.network
echo " " >> /etc/systemd/network/management.network
echo "[Network]" >> /etc/systemd/network/management.network
echo "DHCP=ipv4" >> /etc/systemd/network/management.network
echo "LinkLocalAddressing=no" >> /etc/systemd/network/management.network
echo "[DHCP]" >> /etc/systemd/network/management.network
echo "UseDomains=true" >> /etc/systemd/network/management.network

echo "[NetDev]" >> /etc/systemd/network/bond0.netdev
echo "Name=bond0" >> /etc/systemd/network/bond0.netdev
echo "Description=KVM vSwitch" >> /etc/systemd/network/bond0.netdev
echo "Kind=bond" >> /etc/systemd/network/bond0.netdev
echo " " >> /etc/systemd/network/bond0.netdev
echo "[Bond]" >> /etc/systemd/network/bond0.netdev
#echo "Mode=balance-rr" >> /etc/systemd/network/bond0.netdev
echo "Mode=balance-tlb" >> /etc/systemd/network/bond0.netdev
#echo "TransmitHashPolicy=layer3+4" >> /etc/systemd/network/bond0.netdev
echo "MIIMonitorSec=1s" >> /etc/systemd/network/bond0.netdev
echo "LACPTransmitRate=fast" >> /etc/systemd/network/bond0.netdev	

echo "[Match]" >> /etc/systemd/network/bond0.network
echo "Name=enp0s31f6" >> /etc/systemd/network/bond0.network
echo "Name=wlp4s0" >> /etc/systemd/network/bond0.network
echo " "
echo "[Network]" >> /etc/systemd/network/bond0.network
echo "Bond=bond0" >> /etc/systemd/network/bond0.network

echo "[Match]" >> /etc/systemd/network/vswitch.network
echo "Name=kvm0" >> /etc/systemd/network/vswitch.network
echo " " >> /etc/systemd/network/vswitch.network
echo "[Network]" >> /etc/systemd/network/vswitch.network
echo "DHCP=ipv4" >> /etc/systemd/network/vswitch.network
echo "LinkLocalAddressing=no" >> /etc/systemd/network/vswitch.network
echo "[DHCP]" >> /etc/systemd/network/vswitch.network
echo "UseDomains=true" >> /etc/systemd/network/vswitch.network

echo "[NetDev]" >> /etc/systemd/network/kvm0.netdev
echo "Name=kvm0" >> /etc/systemd/network/kvm0.netdev
echo "Kind=bridge" >> /etc/systemd/network/kvm0.netdev

echo "[Match]" >> /etc/systemd/network/kvm0.network
echo "Name=bond0" >> /etc/systemd/network/kvm0.network
echo " " >> /etc/systemd/network/kvm0.network
echo "[Network]" >> /etc/systemd/network/kvm0.network
echo "Bridge=kvm0" >> /etc/systemd/network/kvm0.network

sudo systemctl --now enable systemd-networkd
sudo systemctl restart systemd-networkd



echo "<network>" >> /etc/libvirt/bridge.xml
echo "        <name>kvm0</name>" >> /etc/libvirt/bridge.xml
echo "        <forward mode=\"bridge\"/>" >> /etc/libvirt/bridge.xml
echo "        <bridge name=\"kvm0\"/>" >> /etc/libvirt/bridge.xml
echo "</network>" >> /etc/libvirt/bridge.xml
virsh net-define --file /etc/libvirt/bridge.xml
virsh net-autostart kvm0
virsh net-start kvm0
virsh net-destroy default
virsh net-undefine default
sudo systemctl disable nftables
sudo systemctl stop nftables
pacman -S --noconfirm dnsmasq firewalld
sudo systemctl --now enable firewalld
##check
#sudo firewall-cmd --state
#sudo systemctl status firewalld
firewall-cmd --permanent --zone=public --add-interface=enp5s0
firewall-cmd --permanent --zone=public --add-interface=kvm0
#check
#sudo firewall-cmd --list-all

#other permanent services
sudo firewall-cmd --zone=public --permanent --add-service=https
sudo firewall-cmd --zone=public --permanent --add-port=5900-5950/udp
sudo firewall-cmd --zone=public --permanent --add-port=5900-5950/tcp

mkdir /etc/libvirt/volume
#echo "<pool type=\"logical\">" >> /etc/libvirt/volume/isos.vol
#echo "  <name>isoimages</name>" >> /etc/libvirt/volume/isos.vol
#echo "  <source>" >> /etc/libvirt/volume/isos.vol
#echo "    <device path=\"/dev/sda2\"/>" >> /etc/libvirt/volume/isos.vol
#echo "    <format type=\"nfs\"/>" >> /etc/libvirt/volume/isos.vol
#echo "  </source>" >> /etc/libvirt/volume/isos.vol
#echo "  <target>" >> /etc/libvirt/volume/isos.vol
#echo "    <path>/dev/isoimages</path>" >> /etc/libvirt/volume/isos.vol
#echo "    <permissions>" >> /etc/libvirt/volume/isos.vol
#echo "      <mode>0770</mode>" >> /etc/libvirt/volume/isos.vol
#echo "      <owner>78</owner>" >> /etc/libvirt/volume/isos.vol
#echo "      <group>78</group>" >> /etc/libvirt/volume/isos.vol
#echo "    </permissions>" >> /etc/libvirt/volume/isos.vol
#echo "  </target>" >> /etc/libvirt/volume/isos.vol
#echo "</pool>" >> /etc/libvirt/volume/isos.vol
#virsh pool-define /etc/libvirt/volume/isos.vol
#virsh pool-build isoimages
#virsh pool-start isoimages
#virsh pool-autostart isoimages

echo "<pool type=\"dir\">" >> /etc/libvirt/volume/isos.vol
echo "  <name>isoimages</name>" >> /etc/libvirt/volume/isos.vol
echo "  <target>" >> /etc/libvirt/volume/isos.vol
echo "  <path>/mnt/dados/SOFTWARES/WORK/MS Windows/2016 Server/</path>" >> /etc/libvirt/volume/isos.vol
echo "  <permissions>" >> /etc/libvirt/volume/isos.vol
echo "    <mode>0770</mode>" >> /etc/libvirt/volume/isos.vol
echo "    <owner>78</owner>" >> /etc/libvirt/volume/isos.vol
echo "    <group>78</group>" >> /etc/libvirt/volume/isos.vol
echo "  </permissions>" >> /etc/libvirt/volume/isos.vol
echo "  </target>" >> /etc/libvirt/volume/isos.vol
echo "</pool>" >> /etc/libvirt/volume/isos.vol
chown kvm:kvm /var/lib/libvirt/images/
echo "ENV{DM_VG_NAME}==\"vdisk\" ENV{DM_LV_NAME}==\"*\" OWNER=\"kvm\"" >> /etc/udev/rules.d/90-kvm.rules
virsh pool-define /etc/libvirt/volume/isos.vol
virsh pool-build isoimages
virsh pool-autostart isoimages

mkdir /mnt/dados
sudo mount -t ntfs-3g /dev/sda2 /mnt/dados

#sudo chown kvm:kvm /var/lib/libvirt/images/ubuntu18.04-2.qcow2

#chmod +rx /var/lib/libvirt/images/win2k16.qcow2 
#chown kvm:kvm /var/lib/libvirt/images/
#chmod 777 /var/lib/libvirt/images/
#chown kvm:kvm /var/lib/libvirt/images/win2k16.qcow2
#chmod 777 /var/lib/libvirt/images/win2k16.qcow2
