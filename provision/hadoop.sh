#!/bin/bash
su - hadoop-22133012 <<'EOF'
cd ~
if [ ! -d hadoop ]; then
  wget https://dlcdn.apache.org/hadoop/common/hadoop-3.4.1/hadoop-3.4.1.tar.gz
  tar -xvzf hadoop-3.4.1.tar.gz
  mv hadoop-3.4.1 hadoop
fi

# Set env
echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64' >> ~/.bashrc
echo 'export HADOOP_HOME=/home/hadoop-22133012/hadoop' >> ~/.bashrc
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

# Copy configs
cp /vagrant/configs/*.xml ~/hadoop/etc/hadoop/
EOF
