#!/bin/bash
set -ex

echo '[1/4] Cài đặt MongoDB nếu chưa có...'
if ! command -v mongod >/dev/null 2>&1; then
    wget -qO - https://www.mongodb.org/static/pgp/server-7.0.asc | sudo gpg --dearmor -o /usr/share/keyrings/mongodb-server-7.0.gpg
    echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" \
        | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
    sudo apt-get update -y
    sudo apt-get install -y mongodb-org
else
    echo 'MongoDB đã được cài đặt, bỏ qua.'
fi

echo '[2/4] Ngăn MongoDB tự chạy và chỉnh bindIp...'
sudo systemctl disable mongod
sudo systemctl stop mongod || true
sudo sed -i 's/^  bindIp:.*/  bindIp: 0.0.0.0/' /etc/mongod.conf

echo '[3/4] Khởi động lại MongoDB (không bật authentication)...'
sudo systemctl enable mongod
sudo systemctl start mongod
sleep 3

echo '[4/4] Hoàn tất cài đặt MongoDB'
mongod --version
