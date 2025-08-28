#!/bin/bash
set -ex

apt-get update -y
apt-get install -y openjdk-11-jdk ssh pdsh wget

sudo sed -i 's/^#*PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config
sudo sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo systemctl restart ssh

sudo adduser --disabled-password --gecos "" hadoop-22133012
echo "hadoop-22133012:dangha12042004" | sudo chpasswd
sudo usermod -aG sudo hadoop-22133012
echo "hadoop-22133012 ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers