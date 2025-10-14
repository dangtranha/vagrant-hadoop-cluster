#!/usr/bin/env python3
import sys
import csv

# ================= Mapper =================
def mapper():
    """
    Mapper: xuất mỗi đạo diễn 1 dòng
    """
    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue
        try:
            reader = csv.reader([line])
            fields = next(reader)
            if fields[0].lower() == 'title':  # bỏ header
                continue
            director_name = fields[3].strip()
            if not director_name:
                continue  # bỏ dòng không có director
            print(f"{director_name}\t1")
        except:
            continue


# ================= Reducer =================
def reducer():
    """
    Reducer: đếm số phim mỗi đạo diễn và xuất top 20 đạo diễn nhiều phim nhất
    """
    director_counts = {}

    # Đếm số phim mỗi đạo diễn
    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue
        try:
            director, value = line.split("\t")
            value = int(value)
        except:
            continue

        director_counts[director] = director_counts.get(director, 0) + value

    # Sắp xếp giảm dần theo số phim
    top_20 = sorted(director_counts.items(), key=lambda x: x[1], reverse=True)[:20]

    print("Top 20 directors with most movies:")
    for director, count in top_20:
        print(f"{director}\t{count}")


# ================= Main =================
if __name__ == "__main__":
    if len(sys.argv) < 2:
        sys.exit("Usage: python3 director_movie_count.py <mapper|reducer>")
    mode = sys.argv[1].lower()
    if mode == "mapper":
        mapper()
    elif mode == "reducer":
        reducer()
    else:
        sys.exit("Invalid mode. Use 'mapper' or 'reducer'.")
