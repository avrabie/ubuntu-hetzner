#!/usr/bin/env bash

echo "Hello Ubuntu!"
echo "Please modify the script for your desired FQDN"
hostnamectl set-hostname ubuntu1.s4v3.net
apt update && upgrade -y
hostname

echo "go and change the FQDN in hetzner > server > networking"

