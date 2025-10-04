#!/bin/bash
set -ex
CONFIG_FILE="/vagrant/clustering_config.json"

USERNAME=$(jq -r '.user.username' $CONFIG_FILE)
PASSWORD=$(jq -r '.user.password' $CONFIG_FILE)

MASTER_IP=$(jq -r '.master.ip' $CONFIG_FILE)
MASTER_HOST=$(jq -r '.master.hostname' $CONFIG_FILE)

SLAVE_IP=$(jq -r '.slave.ip' $CONFIG_FILE)
SLAVE_HOST=$(jq -r '.slave.hostname' $CONFIG_FILE)

su - $USERNAME <<'EOF'
cd ~

# Tải Derby nếu chưa có
if [ ! -f /shared/db-derby-10.15.2.0-bin.tar.gz ]; then
    wget https://archive.apache.org/dist/db/derby/db-derby-10.15.2.0/db-derby-10.15.2.0-bin.tar.gz -P /shared
fi

# Giải nén nếu chưa có derby
if [ ! -d derby ]; then
    cp /shared/db-derby-10.15.2.0-bin.tar.gz .
    tar -xvzf db-derby-10.15.2.0-bin.tar.gz
    mv db-derby-10.15.2.0-bin derby
    rm -f db-derby-10.15.2.0-bin.tar.gz
fi

# Thiết lập Derby environment
echo "export DERBY_HOME=/home/$USER/derby" >> ~/.bashrc
echo 'export PATH=$PATH:$DERBY_HOME/bin' >> ~/.bashrc
echo 'export CLASSPATH=$CLASSPATH:$DERBY_HOME/lib/derby.jar:$DERBY_HOME/lib/derbytools.jar' >> ~/.bashrc
source ~/.bashrc

# Tạo thư mục database
mkdir -p ~/derby/data
chmod 777 ~/derby/data

EOF
