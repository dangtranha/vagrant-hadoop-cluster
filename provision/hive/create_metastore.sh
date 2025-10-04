#!/bin/bash
set -ex
CONFIG_FILE="/vagrant/clustering_config.json"

USERNAME=$(jq -r '.user.username' $CONFIG_FILE)
PASSWORD=$(jq -r '.user.password' $CONFIG_FILE)

MASTER_IP=$(jq -r '.master.ip' $CONFIG_FILE)
MASTER_HOST=$(jq -r '.master.hostname' $CONFIG_FILE)

SLAVE_IP=$(jq -r '.slave.ip' $CONFIG_FILE)
SLAVE_HOST=$(jq -r '.slave.hostname' $CONFIG_FILE)

sudo -u $USERNAME bash <<EOF
set -ex
/home/$USERNAME/hadoop/sbin/start-all.sh

# Chuẩn bị thư mục HDFS cho Hive
hdfs dfs -mkdir -p /tmp
hdfs dfs -mkdir -p /user/hive/warehouse
hdfs dfs -chmod 777 /tmp
hdfs dfs -chmod 777 /user/hive/warehouse

# Cấp quyền thư mục Hive local
chmod -R 777 \$HIVE_HOME

# Khởi tạo Metastore (Derby)
\$HIVE_HOME/bin/schematool -dbType derby -initSchema --verbose || true

# Cấp quyền metastore
chmod -R 777 \$HIVE_HOME/metastore_db/ || true

# Khởi động HiveServer2 trong nền, ghi log để debug
nohup \$HIVE_HOME/bin/hiveserver2 > /home/$USERNAME/hiveserver2.log 2>&1 &
EOF