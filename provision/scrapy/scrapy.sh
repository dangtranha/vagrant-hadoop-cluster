#!/usr/bin/env bash
set -e

echo "[1/4] Cập nhật apt-get..."
sudo apt-get update -y

echo "[2/4] Cài Python3, pip và các gói hỗ trợ build..."
sudo apt-get install -y python3 python3-pip python3-venv build-essential libxml2-dev libxslt1-dev zlib1g-dev

echo "[3/4] Cài virtualenv và thư viện Scrapy..."
mkdir -p /home/vagrant/scrapy-env
cd /home/vagrant/scrapy-env

# Tạo venv nếu chưa có
if [ ! -d "venv" ]; then
  python3 -m venv venv
fi

# Activate venv và cài requirements
source venv/bin/activate

cat <<EOF > requirements.txt
scrapy>=2.11.0
pymongo>=4.9.0
pyspark>=3.5.0

EOF

pip install --upgrade pip setuptools wheel
pip install -r requirements.txt

deactivate

echo " Scrapy environment và pymongo đã sẵn sàng"
echo " Vào env: source /home/vagrant/scrapy-env/venv/bin/activate"
