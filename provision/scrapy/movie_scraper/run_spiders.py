import os
import subprocess
import json
from pymongo import MongoClient

# MongoDB config
MONGO_URI = "mongodb://localhost:27017"
DB_NAME = "movies_db"

# Thư mục lưu dữ liệu
data_folder = 'data'
os.makedirs(data_folder, exist_ok=True)

# Danh sách spider và file xuất
spiders = {
    "tmdb_movies": "tmdb_movies.json",
    "tmdb_director": "tmdb_director.json",
    "movie_profit": "movie_profit.json"
}

client = MongoClient(MONGO_URI)
db = client[DB_NAME]

for spider_name, output_file in spiders.items():
    output_path = os.path.join(data_folder, output_file)
    collection = db[spider_name]  # mỗi spider lưu vào 1 collection riêng

    # Nếu file chưa tồn tại → chạy spider
    if not os.path.exists(output_path):
        print(f"[RUN] Chạy spider: {spider_name} -> {output_file}")
        subprocess.run(
            ["scrapy", "crawl", spider_name, "-o", output_path, "-t", "json"],
            check=True
        )
    else:
        print(f"[SKIP] {output_file} đã tồn tại")

    # Load dữ liệu từ JSON vào MongoDB
    with open(output_path, "r", encoding="utf-8") as f:
        data = json.load(f)
        if data:
            collection.delete_many({})  # Xoá dữ liệu cũ (nếu muốn)
            collection.insert_many(data)
            print(f"[MONGO] Đã insert {len(data)} records vào collection '{spider_name}'")
        else:
            print(f"[MONGO] File {output_file} rỗng, bỏ qua insert")

print(" Tất cả dữ liệu đã được xử lý và lưu vào MongoDB")
