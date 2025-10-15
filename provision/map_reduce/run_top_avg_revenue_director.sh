#!/bin/bash

# Đường dẫn tới file CSV trên HDFS
INPUT_HDFS="/cleandata_csv/combined_movies"

# Thư mục output trên HDFS
OUTPUT_HDFS="/output/top_avg_revenue_director"

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
    -mapper "python3 top_avg_revenue_director.py mapper" \
    -reducer "python3 top_avg_revenue_director.py reducer" \
    -file top_avg_revenue_director.py

echo "✅ Hoàn tất: kết quả tại $OUTPUT_HDFS"
