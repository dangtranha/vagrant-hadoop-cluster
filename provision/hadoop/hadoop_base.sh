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

# Tải Hadoop nếu chưa có
if [ ! -f /shared/hadoop-3.4.1.tar.gz ]; then
    wget https://dlcdn.apache.org/hadoop/common/hadoop-3.4.1/hadoop-3.4.1.tar.gz -P /shared
fi

if [ ! -d hadoop ]; then
    cp /shared/hadoop-3.4.1.tar.gz .
    tar -xvzf hadoop-3.4.1.tar.gz
    mv hadoop-3.4.1 hadoop
    rm -f hadoop-3.4.1.tar.gz
fi

# SSH key
if [ ! -f ~/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
fi
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

chmod 600 ~/.ssh/authorized_keys

# Tạo thư mục tạm cho master
HOSTNAME=$(hostname)
CONFIG_FILE="/vagrant/clustering_config.json"
MASTER_HOST=$(jq -r '.master.hostname' $CONFIG_FILE)
if [ "$HOSTNAME" = "$MASTER_HOST" ]; then
    [ ! -d tmp ] && mkdir tmp && chmod 777 tmp
fi

# Thiết lập Hadoop environment
grep -q "JAVA_HOME=/usr/lib/jvm/java-1.11.0-openjdk-amd64" ~/hadoop/etc/hadoop/hadoop-env.sh || \
echo "export JAVA_HOME=/usr/lib/jvm/java-1.11.0-openjdk-amd64" >> ~/hadoop/etc/hadoop/hadoop-env.sh

# Thêm biến môi trường vào bashrc
echo 'export JAVA_HOME=/usr/lib/jvm/java-1.11.0-openjdk-amd64' >> ~/.bashrc
echo "export HADOOP_HOME=/home/$USER/hadoop" >> ~/.bashrc
echo 'export PATH=$PATH:$HADOOP_HOME/bin' >> ~/.bashrc
echo 'export PATH=$PATH:$HADOOP_HOME/sbin' >> ~/.bashrc
echo 'export HADOOP_MAPRED_HOME=$HADOOP_HOME' >> ~/.bashrc
echo 'export HADOOP_COMMON_HOME=$HADOOP_HOME' >> ~/.bashrc
echo 'export HADOOP_HDFS_HOME=$HADOOP_HOME' >> ~/.bashrc
echo 'export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop' >> ~/.bashrc
echo 'export HADOOP_YARN_HOME=$HADOOP_HOME ' >> ~/.bashrc
echo 'export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native' >> ~/.bashrc
echo 'export HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib/native"' >> ~/.bashrc
source ~/.bashrc


# Copy file config Hadoop
cp /vagrant/configs/core-site.xml ~/hadoop/etc/hadoop
cp /vagrant/configs/hdfs-site.xml ~/hadoop/etc/hadoop
cp /vagrant/configs/yarn-site.xml ~/hadoop/etc/hadoop

if [ "$HOSTNAME" = "$SLAVE_HOST" ]; then
    cp /vagrant/configs/slave/mapred-site.xml ~/hadoop/etc/hadoop
fi

if [ "$HOSTNAME" = "$MASTER_HOST" ]; then
    cp /vagrant/configs/master/mapred-site.xml ~/hadoop/etc/hadoop
    cp /vagrant/configs/workers ~/hadoop/etc/hadoop
    dos2unix $HADOOP_HOME/etc/hadoop/workers
fi



chmod 777 ~/hadoop/etc/hadoop/*.xml
EOF