#!/bin/bash
set -ex
CONFIG_FILE="/vagrant/clustering_config.json"

USERNAME=$(jq -r '.user.username' $CONFIG_FILE)

su - $USERNAME <<EOF

sudo add-apt-repository -y ppa:deadsnakes/ppa
sudo apt update
sudo apt install -y python3.10 python3.10-dev python3.10-venv build-essential libssl-dev libffi-dev libsasl2-dev libldap2-dev default-libmysqlclient-dev


sudo apt install -y python3.10-venv
python3.10 -m venv venv
. venv/bin/activate

pip install apache_superset

export SUPERSET_SECRET_KEY=YOUR-SECRET-KEY # For production use, make sure this is a strong key, for example generated using `openssl rand -base64 42`. See https://superset.apache.org/docs/configuration/configuring-superset#specifying-a-secret_key
export FLASK_APP=superset

pip uninstall marshmallow -y
pip install marshmallow==3.19.0

pip install pyhive[hive]

superset db upgrade

superset fab create-admin


# Create default roles and permissions
superset init


# To start a development web server on port 8088, use -p to bind to another port
superset run -h 0.0.0.0 -p 8088 
EOF
