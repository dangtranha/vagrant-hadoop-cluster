#!/bin/bash
set -ex
CONFIG_FILE="/vagrant/clustering_config.json"

USERNAME=$(jq -r '.user.username' $CONFIG_FILE)
PASSWORD=$(jq -r '.user.password' $CONFIG_FILE)

MASTER_IP=$(jq -r '.master.ip' $CONFIG_FILE)
MASTER_HOST=$(jq -r '.master.hostname' $CONFIG_FILE)

SLAVE_IP=$(jq -r '.slave.ip' $CONFIG_FILE)
SLAVE_HOST=$(jq -r '.slave.hostname' $CONFIG_FILE)

su - $USERNAME <<EOF
set -ex
~/hadoop/sbin/start-all.sh

~/hadoop/bin/hdfs dfs -mkdir -p /tmp
~/hadoop/bin/hdfs dfs -mkdir -p /user/hive/warehouse
~/hadoop/bin/hdfs dfs -chmod 777 /tmp
~/hadoop/bin/hdfs dfs -chmod 777 /user/hive/warehouse

$HIVE_HOME/bin/schematool -dbType derby -initSchema --verbose || true
chmod -R 777 ~/hive/metastore_db/ || true
~/hive/bin/hiveserver2 &
EOF