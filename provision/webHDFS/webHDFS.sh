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

if [ ! -f /shared/flask_hdfs_ui_copy.tar.gz ]; then
    wget -O /shared/flask_hdfs_ui_copy.tar.gz "https://www.dropbox.com/scl/fi/mdc1pg4foiw3lqejywfc7/flask_hdfs_ui_copy.tar.gz?rlkey=6sciqw1fa436ot2q5c8q36w97&st=6hhqt15n&dl=1"
fi

if [ ! -d ~/flask_hdfs_ui ]; then
    cp /shared/flask_hdfs_ui_copy.tar.gz ~
    tar -xvzf ~/flask_hdfs_ui_copy.tar.gz -C ~
    mv ~/flask_hdfs_ui_copy ~/flask_hdfs_ui
    rm -f ~/flask_hdfs_ui_copy.tar.gz
fi

cd ~/flask_hdfs_ui
sed -i "s|{{MASTER_HOST}}|$MASTER_HOST|g" app.py
sed -i "s|{{USERNAME}}|$USERNAME|g" app.py

find . -type f -name '*.py' -exec dos2unix -q {} \;

rm -rf venv
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install flask requests pandas

nohup python app.py > flask.log 2>&1 &
EOF
