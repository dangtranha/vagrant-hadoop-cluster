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

# Tải Hive nếu chưa có
if [ ! -f /shared/apache-hive-3.1.3-bin.tar.gz ]; then
    wget https://archive.apache.org/dist/hive/hive-3.1.3/apache-hive-3.1.3-bin.tar.gz -P /shared
fi

if [ ! -d hive ]; then
    cp /shared/apache-hive-3.1.3-bin.tar.gz .
    tar -xvzf apache-hive-3.1.3-bin.tar.gz
    mv apache-hive-3.1.3-bin hive
    rm -f apache-hive-3.1.3-bin.tar.gz
fi


# Thiết lập Hive environment

echo "export HIVE_HOME=/home/$USER/hive" >> ~/.bashrc
echo 'export PATH=$PATH:$HIVE_HOME/bin' >> ~/.bashrc
echo "export CLASSPATH=$CLASSPATH:/home/$USER/hadoop/lib/*:." >> ~/.bashrc
echo "export CLASSPATH=$CLASSPATH:/home/$USER/hive/lib/*:." >> ~/.bashrc
echo 'export HIVE_CONF_DIR=$HIVE_HOME/conf' >> ~/.bashrc
source ~/.bashrc

cd ~/hive/conf
cp hive-env.sh.template hive-env.sh
echo "export HADOOP_HOME=/home/$USER/hadoop" >> ~/hive/conf/hive-env.sh
echo 'export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64' >> ~/hive/conf/hive-env.sh
echo 'export HIVE_HOME=$HIVE_HOME' >> ~/hive/conf/hive-env.sh
echo 'export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$HIVE_HOME/bin' >> ~/hive/conf/hive-env.sh
echo 'export CLASSPATH=$CLASSPATH:$HADOOP_HOME/lib/*:.:$HIVE_HOME/lib/*:.' >> ~/hive/conf/hive-env.sh
chmod +x ~/hive/conf/hive-env.sh
chmod 777 ~/hive/

EOF
