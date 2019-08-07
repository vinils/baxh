pacman -S --noconfirm docker
systemctl enable --now docker.service
gpasswd -a myuser docker


ssh-keygen -t rsa
ssh-copy-id -f myuser@192.168.15.31

eval "$(ssh-agent -s)"
eval "$(ssh-add ~/.ssh/id_rsa)"
docker-machine create --driver generic --generic-ip-address=192.168.15.31 --generic-ssh-key ~/.ssh/id_rsa --generic-ssh-user=myuser --generic-ssh-port=22 ArchDocker2
docker-machine regenerate-certs ArchDocker2
