#!/bin/bash
INPUT_HDFS="/cleandata_csv/combined_movies"
OUTPUT_HDFS="/output/extreme_rating_movie"
HADOOP_STREAMING_JAR="$HADOOP_HOME/share/hadoop/tools/lib/hadoop-streaming-3.4.1.jar"

hadoop fs -rm -r -skipTrash $OUTPUT_HDFS || true

hadoop jar $HADOOP_STREAMING_JAR \
    -input $INPUT_HDFS \
    -output $OUTPUT_HDFS \
    -mapper "python3 extreme_rating_movie.py mapper" \
    -reducer "python3 extreme_rating_movie.py reducer" \
    -file extreme_rating_movie.py

echo "✅ Hoàn tất: kết quả tại $OUTPUT_HDFS"
