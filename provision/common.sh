#!/bin/bash
set -ex

apt-get update -y
apt-get install -y openjdk-11-jdk ssh pdsh wget sshpass jq

sudo ufw disable
sudo systemctl disable ufw

sudo sed -i 's/^#*PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config
sudo sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo systemctl restart ssh

# Đọc config từ JSON
CONFIG_FILE="/vagrant/clustering_config.json"

USERNAME=$(jq -r '.user.username' $CONFIG_FILE)
PASSWORD=$(jq -r '.user.password' $CONFIG_FILE)

MASTER_IP=$(jq -r '.master.ip' $CONFIG_FILE)
MASTER_HOST=$(jq -r '.master.hostname' $CONFIG_FILE)

SLAVE_IP=$(jq -r '.slave.ip' $CONFIG_FILE)
SLAVE_HOST=$(jq -r '.slave.hostname' $CONFIG_FILE)

# Tạo user
if ! id "$USERNAME" &>/dev/null; then
    sudo adduser --disabled-password --gecos "" "$USERNAME"
    echo "$USERNAME:$PASSWORD" | sudo chpasswd
    sudo usermod -aG sudo "$USERNAME"
    echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers
fi

# Chỉnh hosts từ JSON
sudo sed -i '/^127\.0\.[12]\.1/ s/^/#/' /etc/hosts

grep -q "$MASTER_IP $MASTER_HOST" /etc/hosts || echo "$MASTER_IP $MASTER_HOST" | sudo tee -a /etc/hosts
grep -q "$SLAVE_IP $SLAVE_HOST" /etc/hosts || echo "$SLAVE_IP $SLAVE_HOST" | sudo tee -a /etc/hosts
