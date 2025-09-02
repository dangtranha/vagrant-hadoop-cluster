#!/bin/bash
set -ex

CONFIG_FILE="/vagrant/clustering_config.json"

# Đọc thông tin từ JSON
USERNAME=$(jq -r '.user.username' $CONFIG_FILE)
PASSWORD=$(jq -r '.user.password' $CONFIG_FILE)
MASTER_HOST=$(jq -r '.master.hostname' $CONFIG_FILE)
SLAVE_HOST=$(jq -r '.slave.hostname' $CONFIG_FILE)

# Chạy các lệnh dưới user Hadoop
su - $USERNAME <<EOF
set -ex
cd ~

# SSH Master → Master
sshpass -p "$PASSWORD" ssh-copy-id -i ~/.ssh/id_rsa.pub -o StrictHostKeyChecking=no $MASTER_HOST

# SSH Master → Slave
sshpass -p "$PASSWORD" ssh-copy-id -i ~/.ssh/id_rsa.pub -o StrictHostKeyChecking=no $SLAVE_HOST

# Format Namenode (chỉ trên Master)
HOSTNAME=\$(hostname)
if [ "\$HOSTNAME" = "$MASTER_HOST" ]; then
    ~/hadoop/bin/hdfs namenode -format -force
fi
EOF