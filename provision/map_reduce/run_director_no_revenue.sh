#!/bin/bash
INPUT_HDFS="/cleandata_csv/combined_movies"
OUTPUT_HDFS="/output/director_no_revenue"
HADOOP_STREAMING_JAR="$HADOOP_HOME/share/hadoop/tools/lib/hadoop-streaming-3.4.1.jar"

hadoop fs -rm -r -skipTrash $OUTPUT_HDFS || true

hadoop jar $HADOOP_STREAMING_JAR \
    -input $INPUT_HDFS \
    -output $OUTPUT_HDFS \
    -mapper "python3 director_no_revenue.py mapper" \
    -reducer "python3 director_no_revenue.py reducer" \
    -file director_no_revenue.py

echo "✅ Hoàn tất: kết quả tại $OUTPUT_HDFS"
