from pyspark.sql import SparkSession
from pyspark.sql import functions as F
from pyspark.sql.types import DoubleType, IntegerType, DateType
import re

# =============================
# 1. Khởi tạo SparkSession
# =============================
spark = SparkSession.builder \
    .appName("CleanMoviesData") \
    .getOrCreate()

# =============================
# 2. Hàm tiện ích
# =============================

def clean_money(col):
    """Chuyển tiền tệ dạng '$123,456' hoặc '-' thành số (int/float)"""
    return F.when(
        (F.col(col).isNull()) | (F.col(col) == "-"), None
    ).otherwise(
        F.regexp_replace(F.col(col), "[$,]", "").cast(DoubleType())
    )

def parse_release_date(col):
    """
    Tách '09/19/2025 (VN)' thành (date, country).
    """
    return (
        F.regexp_extract(F.col(col), r"(\d{2}/\d{2}/\d{4})", 1).alias("release_date"),
        F.regexp_extract(F.col(col), r"\((\w+)\)", 1).alias("release_country")
    )

def clean_unicode(col):
    """Loại bỏ escape unicode kiểu \\u00f1 -> ñ"""
    return F.regexp_replace(col, r"\\u[0-9a-fA-F]{4}", "")

# =============================
# 3. Làm sạch từng dataset
# =============================

collections = ["tmdb_movies", "tmdb_director", "movie_profit"]

for coll in collections:
    print(f" Đang xử lý {coll}...")

    df = spark.read.parquet(f"hdfs://master-2213039:9000/movies/{coll}") # Đổi tên hostname lại 

    if coll == "tmdb_movies":
        # rating -> int
        df = df.withColumn("rating", F.col("rating").cast(IntegerType()))

        # release_date -> date + country
        release_date, release_country = parse_release_date("release_date")
        df = df.withColumn("release_date_clean", F.to_date(release_date, "MM/dd/yyyy")) \
               .withColumn("release_country", release_country)

        # budget -> float
        df = df.withColumn("budget_clean", clean_money("budget"))

        # keywords -> chuỗi
        df = df.withColumn("keywords_str", F.concat_ws(", ", F.col("keywords")))

        df_clean = df.dropDuplicates()

    elif coll == "tmdb_director":
        # làm sạch text unicode
        df = df.withColumn("director_name", clean_unicode("director_name")) \
               .withColumn("place_of_birth", F.when(F.col("place_of_birth") == "-", None).otherwise(F.col("place_of_birth"))) \
               .withColumn("known_for", F.lower(F.col("known_for")))

        # credits.year -> int/null, chỉ giữ year và title
        df = df.withColumn(
            "credits",
            F.expr("""
                transform(credits, x -> named_struct(
                    'year', CASE WHEN x.year = '—' THEN null ELSE x.year END,
                    'title', x.title
                ))
            """)
        )

        df_clean = df.dropDuplicates()

    elif coll == "movie_profit":
        df = df.withColumn("domestic_clean", clean_money("domestic")) \
               .withColumn("international_clean", clean_money("international")) \
               .withColumn("worldwide_clean", clean_money("worldwide"))

        df_clean = df.dropDuplicates()

    # =============================
    # 4. Ghi kết quả ra HDFS
    # =============================
    output_path = f"hdfs://master-2213039:9000/movies_clean/{coll}"
    df_clean.write.mode("overwrite").parquet(output_path)
    print(f" Đã lưu {coll} sạch tại {output_path}")

spark.stop()
