from pyspark.sql import SparkSession

# Tạo SparkSession với connector MongoDB
spark = SparkSession.builder \
    .appName("MongoToHDFS") \
    .config("spark.mongodb.read.connection.uri", "mongodb://localhost:27017/movies_db") \
    .getOrCreate()

collections = ["tmdb_movies", "tmdb_director", "movie_profit"]

for coll in collections:
    print(f"Đang xử lý collection: {coll}")

    # Đọc từ MongoDB
    df = spark.read.format("mongodb") \
        .option("database", "movies_db") \
        .option("collection", coll) \
        .load()

    # Show để kiểm tra
    df.show(5, truncate=False)

    # Ghi ra HDFS (dạng json)
    output_path = f"hdfs://master:9000/data/{coll}"
    df.write.mode("overwrite").json(output_path)

    print(f" Đã lưu {coll} vào {output_path}")

spark.stop()
