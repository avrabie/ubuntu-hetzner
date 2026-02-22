
hostnamectl set-hostname ubuntu1.s4v3.net
apt update && upgrade -y
hostname

TODO: "go and change the FQDN in hetzner > server > networking add reverse: RDNS"
TODO: change cloudflare, add A record for FQDN for DNS

adduser moldo
usermod -aG sudo moldo
groups moldo

ssh-keygen -t ed25519 -C "your_email@example.com"
ssh-copy-id moldo@ubuntu1.s4v3.net
ssh-copy-id root@ubuntu1.s4v3.net


# Create mount points for PVs
mkdir -p /mnt/minio-data/minio
mkdir -p /mnt/minio-data/postgres
mkdir -p /mnt/keycloak-data/keycloak
mkdir -p /mnt/keycloak-data/postgres

Give permissions to /mnt/
sudo chmod -R 777 /mnt/keycloak-data
sudo chmod -R 777 /mnt/minio-data