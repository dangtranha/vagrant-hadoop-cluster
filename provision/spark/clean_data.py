#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from pyspark.sql import SparkSession
from pyspark.sql.functions import col, explode, regexp_replace

# ========================
# Khởi tạo Spark
# ========================
spark = SparkSession.builder \
    .appName("Clean Movie Data") \
    .getOrCreate()

# ========================
# Đọc dữ liệu JSON từ HDFS
# ========================
movie_profit_path = "hdfs:///data/movie_profit"
director_path     = "hdfs:///data/tmdb_director"
movies_path       = "hdfs:///data/tmdb_movies"

df_profit   = spark.read.json(movie_profit_path)
df_director = spark.read.json(director_path)
df_movies   = spark.read.json(movies_path)

# ========================
# Xử lý Profit
# ========================
df_profit_clean = df_profit.select(
    col("movie_name").alias("title"),
    col("worldwide")
)

df_profit_clean = df_profit_clean.withColumn(
    "revenue",
    regexp_replace(col("worldwide"), "[$,]", "").cast("long")
).drop("worldwide")

# ========================
# Xử lý Director
# ========================
df_director_clean = df_director.select(
    col("director_name"),
    explode("credits").alias("credit")
).select(
    col("director_name"),
    col("credit.title").alias("title")
)

# ========================
# Xử lý Movies
# ========================
df_movies_clean = df_movies.select(
    col("title"),
    col("rating").cast("float")
)

# ========================
# Xuất CSV riêng
# ========================
df_profit_clean.write.mode("overwrite").option("header", True).csv("hdfs:///cleandata_csv/clean_profit")
df_director_clean.write.mode("overwrite").option("header", True).csv("hdfs:///cleandata_csv/clean_director")
df_movies_clean.write.mode("overwrite").option("header", True).csv("hdfs:///cleandata_csv/clean_movies")

# ========================
# Tạo CSV tổng hợp
# ========================
df_combined = df_movies_clean.join(df_profit_clean, on="title", how="left") \
                             .join(df_director_clean, on="title", how="left") \
                             .select(
                                 col("title"),
                                 col("rating"),
                                 col("revenue"),
                                 col("director_name")
                             ) \
                             .dropDuplicates(['title'])  # bỏ tất cả dòng trùng nhau dựa trên title

df_combined.write.mode("overwrite").option("header", True).csv("hdfs:///data/cleandata_csv/combined_movies")

# ========================
# Kết thúc Spark
# ========================
spark.stop()
print("Đã xuất 3 file CSV riêng + 1 file CSV tổng hợp lên HDFS thành công (đã loại bỏ trùng).")
