#!/bin/bash
set -ex

CONFIG_FILE="/vagrant/clustering_config.json"

USERNAME=$(jq -r '.user.username' $CONFIG_FILE)
PASSWORD=$(jq -r '.user.password' $CONFIG_FILE)
MASTER_HOST=$(jq -r '.master.hostname' $CONFIG_FILE)
SLAVE_HOST=$(jq -r '.slave.hostname' $CONFIG_FILE)

# Chạy các lệnh với user Hadoop
su - $USERNAME <<EOF
set -ex
cd ~

# Tạo SSH key nếu chưa có
if [ ! -f ~/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
fi

cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

# Master → Master
sshpass -p '$PASSWORD' ssh-copy-id -i ~/.ssh/id_rsa.pub -o StrictHostKeyChecking=no $MASTER_HOST

# Master → Slave
sshpass -p '$PASSWORD' ssh-copy-id -i ~/.ssh/id_rsa.pub -o StrictHostKeyChecking=no $SLAVE_HOST

# Format Namenode (chỉ master)
HOSTNAME=\$(hostname)
if [ "\$HOSTNAME" = "$MASTER_HOST" ]; then
    hadoop/bin/hdfs namenode -format -force
fi
EOF
