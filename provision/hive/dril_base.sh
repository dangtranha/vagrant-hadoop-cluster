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

# ============= ZooKeeper Setup ==============
if [ ! -f /shared/apache-zookeeper-3.6.0-bin.tar.gz ]; then
    wget https://archive.apache.org/dist/zookeeper/zookeeper-3.6.0/apache-zookeeper-3.6.0-bin.tar.gz -P /shared
fi

if [ ! -d apache-zookeeper-3.6.0 ]; then
    cp /shared/apache-zookeeper-3.6.0-bin.tar.gz .
    tar -xvzf apache-zookeeper-3.6.0-bin.tar.gz
    mv apache-zookeeper-3.6.0-bin zookeeper
    rm -f apache-zookeeper-3.6.0-bin.tar.gz
fi
mkdir ~/zookeeper/data

echo "export ZOOKEEPER_HOME=/home/$USER/zookeeper" >> ~/.bashrc
echo 'export PATH=$PATH:$ZOOKEEPER_HOME/bin' >> ~/.bashrc
source ~/.bashrc

if [ -f $ZOOKEEPER_HOME/conf/zoo.cfg ]; then
    # Xóa file cũ nếu tồn tại để tránh trùng cấu hình
    rm -f $ZOOKEEPER_HOME/conf/zoo.cfg
fi

echo 'tickTime=2000' >> $ZOOKEEPER_HOME/conf/zoo.cfg
echo 'initLimit=5' >> $ZOOKEEPER_HOME/conf/zoo.cfg
echo 'syncLimit=2' >> $ZOOKEEPER_HOME/conf/zoo.cfg
echo "dataDir=/home/$USER/zookeeper/data" >> $ZOOKEEPER_HOME/conf/zoo.cfg
echo 'clientPort=2181' >> $ZOOKEEPER_HOME/conf/zoo.cfg
echo 'server.1=master:2888:3888' >> $ZOOKEEPER_HOME/conf/zoo.cfg

chmod 777 $ZOOKEEPER_HOME/conf/zoo.cfg

# ============= Drill Setup ==============
if [ ! -f /shared/apache-drill-1.19.0.tar.gz ]; then
    wget https://archive.apache.org/dist/drill/drill-1.19.0/apache-drill-1.19.0.tar.gz -P /shared
fi

if [ ! -d apache-drill-1.19.0 ]; then
    cp /shared/apache-drill-1.19.0.tar.gz .
    tar -xvzf apache-drill-1.19.0.tar.gz
    mv apache-drill-1.19.0 drill
    rm -f apache-drill-1.19.0.tar.gz
fi

echo "export DRILL_HOME=/home/$USER/drill" >> ~/.bashrc
echo 'export PATH=$PATH:$DRILL_HOME/bin' >> ~/.bashrc
source ~/.bashrc

# Tạo thư mục logs cho Drill
mkdir -p ~/drill/log

EOF
