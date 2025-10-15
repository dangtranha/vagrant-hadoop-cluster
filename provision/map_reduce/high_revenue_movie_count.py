#!/usr/bin/env python3
import sys
import csv
import heapq  # dùng heap để lấy top nhanh

# ================= Mapper =================
def mapper():
    """
    Mapper: đọc CSV, chỉ lấy các phim có revenue >= 100,000,000
    Output: movie_title \t revenue
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
            movie_title = fields[0].strip()
            revenue_str = fields[2].strip()
            if not revenue_str:
                continue
            revenue = float(revenue_str)
            if revenue >= 100_000_000:
                print(f"{movie_title}\t{revenue}")
        except:
            continue

# ================= Reducer =================
def reducer(top_n=20):
    """
    Reducer: tìm Top N phim có revenue cao nhất (>=100 triệu)
    """
    top_movies = []

    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue
        try:
            movie_title, revenue_str = line.split("\t")
            revenue = float(revenue_str)
        except:
            continue

        # giữ top N phim có doanh thu cao nhất
        if len(top_movies) < top_n:
            heapq.heappush(top_movies, (revenue, movie_title))
        else:
            heapq.heappushpop(top_movies, (revenue, movie_title))

    # sắp xếp giảm dần theo revenue
    top_movies_sorted = sorted(top_movies, key=lambda x: x[0], reverse=True)

    print(f"Top {top_n} movies with revenue >= 100 million:")
    for rank, (revenue, title) in enumerate(top_movies_sorted, start=1):
        print(f"{rank}. {title}\t{revenue:,.2f}")

# ================= Main =================
if __name__ == "__main__":
    if len(sys.argv) < 2:
        sys.exit("Usage: python3 high_revenue_movie_count.py <mapper|reducer>")
    mode = sys.argv[1].lower()
    if mode == "mapper":
        mapper()
    elif mode == "reducer":
        reducer(top_n=20)
    else:
        sys.exit("Invalid mode. Use 'mapper' or 'reducer'.")
