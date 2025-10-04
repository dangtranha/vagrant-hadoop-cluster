#!/bin/bash
set -ex

# Đọc username từ JSON config
CONFIG_FILE="/vagrant/clustering_config.json"
USERNAME=$(jq -r '.user.username' "$CONFIG_FILE")

# Cấu hình Spark
SPARK_VERSION=3.5.0
HADOOP_VERSION=3
SPARK_HOME=/usr/local/spark
TMP_DIR=/tmp
SHARED_DIR=/vagrant/shared

MONGO_SPARK_VERSION=10.5.0
MONGO_SPARK_JAR=$SPARK_HOME/jars/mongo-spark-connector_2.12-$MONGO_SPARK_VERSION.jar

mkdir -p $SHARED_DIR

# 1. Cài Spark nếu chưa có
if [ ! -d "$SPARK_HOME" ]; then
    echo "[1/4] Cài Spark $SPARK_VERSION..."
    cd $TMP_DIR
    if [ ! -f "$SHARED_DIR/spark-$SPARK_VERSION-bin-hadoop$HADOOP_VERSION.tgz" ]; then
        wget https://archive.apache.org/dist/spark/spark-$SPARK_VERSION/spark-$SPARK_VERSION-bin-hadoop$HADOOP_VERSION.tgz \
            -O "$SHARED_DIR/spark-$SPARK_VERSION-bin-hadoop$HADOOP_VERSION.tgz"
    fi
    cp "$SHARED_DIR/spark-$SPARK_VERSION-bin-hadoop$HADOOP_VERSION.tgz" .
    sudo tar -xzf spark-$SPARK_VERSION-bin-hadoop$HADOOP_VERSION.tgz -C /usr/local/
    sudo mv /usr/local/spark-$SPARK_VERSION-bin-hadoop$HADOOP_VERSION $SPARK_HOME
else
    echo "Spark đã được cài đặt, bỏ qua."
fi

# 2. Cấu hình biến môi trường
PROFILE_FILE=/etc/profile.d/spark.sh
if [ ! -f "$PROFILE_FILE" ]; then
    echo "[2/4] Cấu hình biến môi trường cho Spark..."
    sudo tee $PROFILE_FILE > /dev/null <<EOF
export SPARK_HOME=$SPARK_HOME
export PATH=\$PATH:\$SPARK_HOME/bin
EOF
    source $PROFILE_FILE
fi

# 3. Tải MongoDB Spark Connector
echo "[3/4] Tải MongoDB Spark Connector..."
sudo mkdir -p $SPARK_HOME/jars
if [ ! -f "$MONGO_SPARK_JAR" ]; then
    wget -O "$MONGO_SPARK_JAR" "https://repo1.maven.org/maven2/org/mongodb/spark/mongo-spark-connector_2.12/$MONGO_SPARK_VERSION/mongo-spark-connector_2.12-$MONGO_SPARK_VERSION.jar"
fi

# 4. Tải MongoDB Java Driver + BSON
echo "[4/4] Tải MongoDB Java Driver + BSON..."
cd $SPARK_HOME/jars
if [ ! -f "mongodb-driver-sync-4.10.2.jar" ]; then
    wget https://repo1.maven.org/maven2/org/mongodb/mongodb-driver-sync/4.10.2/mongodb-driver-sync-4.10.2.jar
fi
if [ ! -f "bson-4.10.2.jar" ]; then
    wget https://repo1.maven.org/maven2/org/mongodb/bson/4.10.2/bson-4.10.2.jar
fi
if [ ! -f "mongodb-driver-core-4.10.2.jar" ]; then
    wget https://repo1.maven.org/maven2/org/mongodb/mongodb-driver-core/4.10.2/mongodb-driver-core-4.10.2.jar
fi

# Copy dữ liệu cleandata về home của user
sudo mkdir -p /home/$USERNAME/cleandata
if [ -d /vagrant/cleandata ]; then
    sudo cp -r /vagrant/cleandata/* /home/$USERNAME/cleandata/ || true
fi
sudo chown -R $USERNAME:$USERNAME /home/$USERNAME/cleandata

echo " Spark $SPARK_VERSION + MongoDB Spark Connector $MONGO_SPARK_VERSION + MongoDB Driver đã được cài đặt."
echo " Chạy 'source /etc/profile.d/spark.sh' nếu cần cập nhật biến môi trường."
