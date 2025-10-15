#!/bin/bash

# Đường dẫn tới file combined CSV trên HDFS
INPUT_HDFS="/cleandata_csv/combined_movies"

# Thư mục output trên HDFS
OUTPUT_HDFS="/output/director_revenue_temp"

# Đường dẫn tới Hadoop Streaming jar
HADOOP_STREAMING_JAR="$HADOOP_HOME/share/hadoop/tools/lib/hadoop-streaming-3.4.1.jar"

# Nếu HADOOP_HOME chưa set, dùng đường dẫn mặc định
if [ ! -f "$HADOOP_STREAMING_JAR" ]; then
    echo "⚠️  HADOOP_HOME chưa set hoặc jar không tồn tại, dùng mặc định"
    HADOOP_STREAMING_JAR="/home/hadoopquocthinh/hadoop/share/hadoop/tools/lib/hadoop-streaming-3.4.1.jar"
fi

# Xóa output cũ nếu tồn tại
hadoop fs -rm -r -skipTrash $OUTPUT_HDFS || true

# Chạy Hadoop Streaming MapReduce
hadoop jar $HADOOP_STREAMING_JAR \
    -input $INPUT_HDFS \
    -output $OUTPUT_HDFS \
    -mapper "python3 best_director.py mapper" \
    -reducer "python3 best_director.py reducer" \
    -file best_director.py

echo "✅ Hoàn tất: kết quả tại $OUTPUT_HDFS"
