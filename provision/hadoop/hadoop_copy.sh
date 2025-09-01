#!/bin/bash
set -ex
CONFIG_FILE="/vagrant/clustering_config.json"
USERNAME=$(jq -r '.user.username' $CONFIG_FILE)
PASSWORD=$(jq -r '.user.password' $CONFIG_FILE)

MASTER_IP=$(jq -r '.master.ip' $CONFIG_FILE)
MASTER_HOST=$(jq -r '.master.hostname' $CONFIG_FILE)

SLAVE_IP=$(jq -r '.slave.ip' $CONFIG_FILE)
SLAVE_HOST=$(jq -r '.slave.hostname' $CONFIG_FILE)

su - $USERNAME -c "
cd ~

HADOOP_CONF_DIR="/home/$USERNAME/hadoop/etc/hadoop"

for file in core-site.xml hdfs-site.xml yarn-site.xml mapred-site.xml workers; do
    [ -f \$HADOOP_CONF_DIR/\$file ] || continue
    sed -i -e 's/{{USER}}/$USERNAME/g' \
           -e 's/{{MASTER_HOST}}/$MASTER_HOST/g' \
           -e 's/{{MASTER_IP}}/$MASTER_IP/g' \
           -e 's/{{SLAVE_HOST}}/$SLAVE_HOST/g' \
           -e 's/{{SLAVE_IP}}/$SLAVE_IP/g' \
           \$HADOOP_CONF_DIR/\$file
done
"