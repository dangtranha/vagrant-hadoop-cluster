#!/bin/bash
set -ex

DERBY_USER="hadoopminhnhat"
DERBY_HOME="/home/$DERBY_USER/derby"
DERBY_TGZ="/vagrant/shared/db-derby-10.15.2.0-bin.tar.gz"

# Tạo thư mục cài Derby
mkdir -p $DERBY_HOME
mkdir -p $DERBY_HOME/databases
chmod 777 $DERBY_HOME/databases

# Copy và giải nén Derby
cp $DERBY_TGZ $DERBY_HOME/
cd $DERBY_HOME
tar -xvzf db-derby-10.15.2.0-bin.tar.gz
mv db-derby-10.15.2.0-bin/* .
rm -rf db-derby-10.15.2.0-bin db-derby-10.15.2.0-bin.tar.gz

# Thiết lập biến môi trường trong .bashrc nếu chưa có
grep -q "DERBY_HOME=$DERBY_HOME" ~/.bashrc || cat >> ~/.bashrc <<EOL
export DERBY_HOME=$DERBY_HOME
export PATH=\$PATH:\$DERBY_HOME/bin
export CLASSPATH=\$CLASSPATH:\$DERBY_HOME/lib/derby.jar:\$DERBY_HOME/lib/derbytools.jar
EOL

echo "Apache Derby đã được cài đặt tại $DERBY_HOME."
