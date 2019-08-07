pacman -S --noconfirm docker
systemctl enable --now docker.service
gpasswd -a myuser docker


ssh-keygen -t rsa
ssh-copy-id <ubuntu_username>@<ubuntu_ip>

eval "$(ssh-agent -s)"
eval "$(ssh-add ~/.ssh/id_rsa)"
docker-machine create --driver generic --generic-ip-address=192.168.15.26 --generic-ssh-key ~/.ssh/id_rsa --generic-ssh-user=myuser --generic-ssh-port=22 remote-docker-host
docker-machine regenerate-certs ArchDocker2

#docker-machine env ArchDocker2

##bash
#eval $(docker-machine env ArchDocker2)
##cmd
#@FOR /f "tokens=*" %i IN ('docker-machine env ArchDocker2') DO @%i
##powershell
#& "docker-machine.exe" env ArchDocker2 | Invoke-Expression

#docker info

##################################
/etc/systemd/system/docker.socket.d/socket.conf
[Socket]
ListenStream=0.0.0.0:2375
##################################
nano /etc/systemd/system/docker.service.d/override.conf
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H fd:// -H tcp://0.0.0.0:2376
##################################
https://docs.docker.com/config/daemon/
nano /etc/docker/daemon.json
{
  "debug": true,
  "tls": true,
  "tlscert": "/etc/docker/server.pem",
  "tlskey": "/etc/docker/serverkey.pem",
  "hosts": ["tcp://0.0.0.0:2376"]
}
##################################

#https://docs.docker.com/engine/security/https/
openssl genrsa -aes256 -out ca-key.pem 4096
openssl req -new -x509 -days 365 -key ca-key.pem -sha256 -out ca.pem
openssl genrsa -out server-key.pem 4096
#openssl req -subj "/CN=$HOST" -sha256 -new -key server-key.pem -out server.csr
openssl req -subj "/CN=ArchTemp" -sha256 -new -key server-key.pem -out server.csr
echo subjectAltName = DNS:$HOST,IP:10.10.10.20,IP:127.0.0.1 >> extfile.cnf
echo extendedKeyUsage = serverAuth >> extfile.cnf
openssl x509 -req -days 365 -sha256 -in server.csr -CA ca.pem -CAkey ca-key.pem \
  -CAcreateserial -out server-cert.pem -extfile extfile.cnf
openssl genrsa -out key.pem 4096
openssl req -subj '/CN=client' -new -key key.pem -out client.csr
echo extendedKeyUsage = clientAuth > extfile-client.cnf
openssl x509 -req -days 365 -sha256 -in client.csr -CA ca.pem -CAkey ca-key.pem \
  -CAcreateserial -out cert.pem -extfile extfile-client.cnf
rm -v client.csr server.csr extfile.cnf extfile-client.cnf
chmod -v 0400 ca-key.pem key.pem server-key.pem
chmod -v 0444 ca.pem server-cert.pem cert.pem
dockerd --tlsverify --tlscacert=ca.pem --tlscert=server-cert.pem --tlskey=server-key.pem \
  -H=0.0.0.0:2376
