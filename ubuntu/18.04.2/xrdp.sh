#!/bin/bash
sudo apt install -y xrdp
sudo apt install xorg-video-abi-23
sudo dpkg --configure -a
sudo apt install xorgxrdp

#Authentication Required to Create Managed Color Device
sudo bash -c "cat > /etc/polkit-1/localauthority/50-local.d/45-allow-colord.pkla" <<EOF
[Allow Colord all Users]
Identity=unix-user:*
Action=org.freedesktop.color-manager.create-device;org.freedesktop.color-manager.create-profile;org.freedesktop.color-manager.delete-device;org.freedesktop.color-manager.delete-profile;org.freedesktop.color-manager.modify-device;org.freedesktop.color-manager.modify-profile
ResultAny=no
ResultInactive=no
ResultActive=yes
EOF


# Add script to setup the ubuntu session properly
if [ ! -e /etc/xrdp/startubuntu.sh ]; then
sudo bash -c "cat >> /etc/xrdp/startubuntu.sh" << EOF
#!/bin/sh
export GNOME_SHELL_SESSION_MODE=ubuntu
export XDG_CURRENT_DESKTOP=ubuntu:GNOME
exec /etc/xrdp/startwm.sh
EOF
sudo chmod a+x /etc/xrdp/startubuntu.sh
fi
# use the script to setup the ubuntu session
sudo sed -i_orig -e 's/startwm/startubuntu/g' /etc/xrdp/sesman.ini


# use rdp security.
sudo sed -i_orig -e 's/security_layer=negotiate/security_layer=rdp/g' /etc/xrdp/xrdp.ini
# remove encryption validation.
sudo sed -i_orig -e 's/crypt_level=high/crypt_level=none/g' /etc/xrdp/xrdp.ini
# if local - disable bitmap compression to be faster
#sudo sed -i_orig -e 's/bitmap_compression=true/bitmap_compression=false/g' /etc/xrdp/xrdp.ini

# rename the redirected drives to 'shared-drives'
#sed -i -e 's/FuseMountName=thinclient_drives/FuseMountName=shared-drives/g' /etc/xrdp/sesman.ini
# Changed the allowed_users
#sed -i_orig -e 's/allowed_users=console/allowed_users=anybody/g' /etc/X11/Xwrapper.config


sudo systemctl daemon-reload
sudo systemctl restart xrdp
sudo systemctl restart xrdp-sesman
