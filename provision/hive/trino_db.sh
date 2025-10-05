#!/bin/bash
set -ex

CONFIG_FILE="/vagrant/clustering_config.json"

USERNAME=$(jq -r '.user.username' $CONFIG_FILE)
MASTER_IP=$(jq -r '.master.ip' $CONFIG_FILE)

TRINO_VERSION=351
TRINO_TAR="trino-server-${TRINO_VERSION}.tar.gz"
TRINO_HOME="/home/$USERNAME/trino"
TRINO_DATA_DIR="$TRINO_HOME/data"
SHARED_DIR="/vagrant/shared"
HIVE_METASTORE_URI="thrift://${MASTER_IP}:9083"


# Đảm bảo thư mục shared tồn tại
mkdir -p $SHARED_DIR

# Copy hoặc tải Trino
#!/bin/bash
set -ex

su - $USERNAME <<'EOF'
cd ~

# Tải Trino nếu chưa có
if [ ! -f /vagrant/shared/trino-server-351.tar.gz ]; then
    wget https://repo1.maven.org/maven2/io/trino/trino-server/351/trino-server-351.tar.gz -P /vagrant/shared
fi

# Giải nén nếu chưa có
if [ ! -d trino ]; then
    cp /vagrant/shared/trino-server-351.tar.gz .
    tar -xvzf trino-server-351.tar.gz
    mv trino-server-351 trino
    rm -f trino-server-351.tar.gz
fi

# Tạo thư mục cấu hình và data
mkdir -p trino/etc/catalog
mkdir -p trino/data

# Cấu hình Trino
cat > trino/etc/config.properties <<EOC
coordinator=true
node-scheduler.include-coordinator=true
http-server.http.port=8081
query.max-memory=1GB
query.max-memory-per-node=512MB
discovery-server.enabled=true
discovery.uri=http://hadoop-master:8081
EOC

cat > trino/etc/jvm.config <<EOC
-server
-Xmx2G
-XX:+UseG1GC
-XX:G1HeapRegionSize=32M
-XX:+UseGCOverheadLimit
-XX:+ExplicitGCInvokesConcurrent
EOC

cat > trino/etc/node.properties <<EOC
node.environment=production
node.id=$(uuidgen)
node.data-dir=trino/data
EOC

cat > trino/etc/catalog/hive.properties <<EOC
connector.name=hive-hadoop2
hive.metastore.uri=thrift://hadoop-master:9083
hive.config.resources=/home/$USERNAME/hadoop/etc/hadoop/core-site.xml,/home/$USERNAME/hadoop/etc/hadoop/hdfs-site.xml
EOC

# Tạo script start nhanh
cat > ~/start-trino.sh <<'EOS'
#!/bin/bash
cd ~/trino
bin/launcher start
EOS

chmod +x ~/start-trino.sh
chmod -R 777 trino
EOF
