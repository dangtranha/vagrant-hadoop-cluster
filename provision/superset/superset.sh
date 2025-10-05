sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt update
sudo apt install python3.10 python3.10-dev python3.10-venv build-essential libssl-dev libffi-dev libsasl2-dev libldap2-dev default-libmysqlclient-dev


sudo apt install python3.10-venv
python3.10 -m venv venv
. venv/bin/activate

pip install apache_superset

export SUPERSET_SECRET_KEY=YOUR-SECRET-KEY # For production use, make sure this is a strong key, for example generated using `openssl rand -base64 42`. See https://superset.apache.org/docs/configuration/configuring-superset#specifying-a-secret_key
export FLASK_APP=superset

pip uninstall marshmallow -y
pip install marshmallow==3.19.0


pip install pyhive[hive]

CONFIG_FILE="$HOME/superset_config.py"

# Tạo file superset_config.py
cat > "$CONFIG_FILE" << 'EOF'
# superset_config.py

# Timeout cho SQL Lab và chart queries (giây)
SQLLAB_TIMEOUT = 300  # 5 phút
EOF

superset db upgrade

export SUPERSET_ADMIN_USERNAME=admin
export SUPERSET_ADMIN_FIRST_NAME=Admin
export SUPERSET_ADMIN_LAST_NAME=User
export SUPERSET_ADMIN_EMAIL=admin@example.com
export SUPERSET_ADMIN_PASSWORD=admin

# Create an admin user in your metadata database (use `admin` as username to be able to load the examples)
superset fab create-admin --username $SUPERSET_ADMIN_USERNAME \
                           --firstname $SUPERSET_ADMIN_FIRST_NAME \
                           --lastname $SUPERSET_ADMIN_LAST_NAME \
                           --email $SUPERSET_ADMIN_EMAIL \
                           --password $SUPERSET_ADMIN_PASSWORD

# Load some data to play with
superset load_examples

# Create default roles and permissions
superset init


# To start a development web server on port 8088, use -p to bind to another port
superset run -h 0.0.0.0 -p 8088 