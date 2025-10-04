#!/bin/bash
set -ex

HIVE_USER="hadoopminhnhat"
HIVE_HOME="/home/$HIVE_USER/hive"
HIVE_TGZ="/vagrant/shared/apache-hive-3.1.3-bin.tar.gz"

# Tạo thư mục cài Hive
mkdir -p $HIVE_HOME
mkdir -p $HIVE_HOME/warehouse
chmod 777 $HIVE_HOME/warehouse

# Copy và giải nén Hive
cp $HIVE_TGZ $HIVE_HOME/
cd $HIVE_HOME
tar -xvzf apache-hive-3.1.3-bin.tar.gz
mv apache-hive-3.1.3-bin/* .
rm -rf apache-hive-3.1.3-bin apache-hive-3.1.3-bin.tar.gz

# Tạo và chỉnh hive-env.sh trực tiếp
HIVE_CONF_DIR="$HIVE_HOME/conf"
mkdir -p $HIVE_CONF_DIR
cat > $HIVE_CONF_DIR/hive-env.sh <<EOL
export HADOOP_HOME=/home/$HIVE_USER/hadoop
export HIVE_HOME=$HIVE_HOME
export PATH=\$PATH:\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin:\$HIVE_HOME/bin
export CLASSPATH=\$CLASSPATH:\$HADOOP_HOME/lib/*:.:\$HIVE_HOME/lib/*:.
EOL
chmod +x $HIVE_CONF_DIR/hive-env.sh

# Thêm vào .bashrc nếu chưa có
grep -q "HIVE_HOME=$HIVE_HOME" ~/.bashrc || cat >> ~/.bashrc <<EOL
export HADOOP_HOME=/home/$HIVE_USER/hadoop
export HIVE_HOME=$HIVE_HOME
export PATH=\$PATH:\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin:\$HIVE_HOME/bin
export CLASSPATH=\$CLASSPATH:\$HADOOP_HOME/lib/*:.:\$HIVE_HOME/lib/*:.
EOL

echo "Hive đã được cài đặt xong tại $HIVE_HOME."
echo "Hãy chạy 'source ~/.bashrc' để cập nhật PATH và CLASSPATH cho shell hiện tại."
