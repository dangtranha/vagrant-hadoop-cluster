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
cat <<EOL >> ~/.bashrc
export JAVA_HOME=/usr/lib/jvm/java-1.11.0-openjdk-amd64
export HADOOP_HOME=\$HOME/hadoop
export PATH=\$PATH:\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin
export HADOOP_MAPRED_HOME=\$HADOOP_HOME
export HADOOP_COMMON_HOME=\$HADOOP_HOME
export HADOOP_HDFS_HOME=\$HADOOP_HOME
export HADOOP_CONF_DIR=\$HADOOP_HOME/etc/hadoop
export HADOOP_YARN_HOME=\$HADOOP_HOME
export HADOOP_COMMON_LIB_NATIVE_DIR=\$HADOOP_HOME/lib/native
export HADOOP_OPTS="-Djava.library.path=\$HADOOP_HOME/lib/native"
EOL
source ~/.bashrc

#HADOOP_CONF_DIR="/home/$USERNAME/hadoop/etc/hadoop"

# Copy file config Hadoop
cp /vagrant/configs/core-site.xml ~/hadoop/etc/hadoop
cp /vagrant/configs/hdfs-site.xml ~/hadoop/etc/hadoop
cp /vagrant/configs/yarn-site.xml ~/hadoop/etc/hadoop


if [ "$HOSTNAME" = "$MASTER_HOST" ]; then
    cp /vagrant/configs/mapred-site.xml ~/hadoop/etc/hadoop
    cp /vagrant/configs/workers ~/hadoop/etc/hadoop
fi


# # Replace placeholders trực tiếp trong file đã copy
# for file in core-site.xml hdfs-site.xml yarn-site.xml; do
#     sed -i -e "s/{{USER}}/$USER/g" \
#            -e "s/{{MASTER_HOST}}/$MASTER_HOST/g" \
#            -e "s/{{MASTER_IP}}/$MASTER_IP/g" \
#            -e "s/{{SLAVE_HOST}}/$SLAVE_HOST/g" \
#            -e "s/{{SLAVE_IP}}/$SLAVE_IP/g" \
#            ~/hadoop/etc/hadoop/$file
# done

chmod 777 ~/hadoop/etc/hadoop/*.xml
EOF