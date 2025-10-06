#!/bin/bash
set -ex

CONFIG_FILE="/vagrant/clustering_config.json"

USERNAME=$(jq -r '.user.username' $CONFIG_FILE)
PASSWORD=$(jq -r '.user.password' $CONFIG_FILE)

MASTER_IP=$(jq -r '.master.ip' $CONFIG_FILE)
MASTER_HOST=$(jq -r '.master.hostname' $CONFIG_FILE)

SLAVE_IP=$(jq -r '.slave.ip' $CONFIG_FILE)
SLAVE_HOST=$(jq -r '.slave.hostname' $CONFIG_FILE)

# Chạy dưới user đã định
su - $USERNAME <<'EOF'
cd ~
~/hadoop/sbin/start-all.sh


if ! pgrep -f "hive --service hiveserver2" > /dev/null; then
    echo "Starting HiveServer2..."
    ~/hive/bin/hiveserver2 &
    sleep 5
else
    echo "HiveServer2 already running. Skipping..."
fi

if ! pgrep -f "python app.py" > /dev/null; then
    echo "Starting Flask app..."
    cd ~/flask_hdfs_ui
    source venv/bin/activate
    nohup python app.py > ~/flask.log 2>&1 &
else
    echo "Flask app already running. Skipping..."
fi
cd ~

EOF
