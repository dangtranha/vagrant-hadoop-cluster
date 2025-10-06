#!/bin/bash
set -ex
CONFIG_FILE="/vagrant/clustering_config.json"

USERNAME=$(jq -r '.user.username' $CONFIG_FILE)
PASSWORD=$(jq -r '.user.password' $CONFIG_FILE)

MASTER_IP=$(jq -r '.master.ip' $CONFIG_FILE)
MASTER_HOST=$(jq -r '.master.hostname' $CONFIG_FILE)

SLAVE_IP=$(jq -r '.slave.ip' $CONFIG_FILE)
SLAVE_HOST=$(jq -r '.slave.hostname' $CONFIG_FILE)

USER_HOME="/home/$USERNAME"

su - $USERNAME <<'EOF'
set -ex

HADOOP_HOME="$HOME/hadoop"
HIVE_HOME="$HOME/hive"
METASTORE_DB="$HIVE_HOME/metastore_db"

echo ">>> Running as: $(whoami)"
echo ">>> HOME = $HOME"
echo ">>> Hive home = $HIVE_HOME"

# Start Hadoop
"$HADOOP_HOME/sbin/start-all.sh"

# Prepare HDFS directories
"$HADOOP_HOME/bin/hdfs" dfs -mkdir -p /tmp /user/hive/warehouse
"$HADOOP_HOME/bin/hdfs" dfs -chmod 777 /tmp /user/hive/warehouse

echo "Checking existing schema..."
cd "$HIVE_HOME"
if "$HIVE_HOME/bin/schematool" -dbType derby -info >/dev/null 2>&1; then
    echo "Schema already initialized → skip init"
else
    echo "Schema not found → initializing..."
    rm -rf "$METASTORE_DB"
    "$HIVE_HOME/bin/schematool" -initSchema -dbType derby \
        --url "jdbc:derby:$METASTORE_DB;create=true" \
        --verbose
    chmod -R 777 "$METASTORE_DB"
fi

nohup "$HIVE_HOME/bin/hiveserver2" >/dev/null 2>&1 &
EOF
