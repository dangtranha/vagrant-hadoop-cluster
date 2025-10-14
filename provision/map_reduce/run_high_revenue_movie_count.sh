#!/bin/bash

# Đường dẫn tới file CSV trên HDFS
INPUT_HDFS="/cleandata_csv/combined_movies"

# Thư mục output trên HDFS
OUTPUT_HDFS="/output/high_revenue_movie_count"

# Hadoop Streaming jar
HADOOP_STREAMING_JAR="$HADOOP_HOME/share/hadoop/tools/lib/hadoop-streaming-3.4.1.jar"

if [ ! -f "$HADOOP_STREAMING_JAR" ]; then
    echo "⚠️  HADOOP_HOME chưa set hoặc jar không tồn tại, dùng mặc định"
    HADOOP_STREAMING_JAR="/home/hadoopquocthinh/hadoop/share/hadoop/tools/lib/hadoop-streaming-3.4.1.jar"
fi

# Xóa output cũ nếu có
hadoop fs -rm -r -skipTrash $OUTPUT_HDFS || true

# Chạy Hadoop Streaming
hadoop jar $HADOOP_STREAMING_JAR \
    -input $INPUT_HDFS \
    -output $OUTPUT_HDFS \
    -mapper "python3 high_revenue_movie_count.py mapper" \
    -reducer "python3 high_revenue_movie_count.py reducer" \
    -file high_revenue_movie_count.py

echo "✅ Hoàn tất: kết quả tại $OUTPUT_HDFS"
