
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


