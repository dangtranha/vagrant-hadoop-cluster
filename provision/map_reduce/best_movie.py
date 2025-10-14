#!/usr/bin/env python3
import sys
import csv
import heapq  # dùng để lấy top N nhanh

# ================= Mapper =================
def mapper():
    """
    Mapper: đọc CSV, output:
    movie_title \t score
    score = rating * revenue
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
            rating_str = fields[1].strip()
            revenue_str = fields[2].strip()
            if not rating_str or not revenue_str:
                continue  # bỏ dòng thiếu rating hoặc revenue
            rating = float(rating_str)
            revenue = float(revenue_str)
            score = rating * revenue
            print(f"{movie_title}\t{score}")
        except:
            continue

# ================= Reducer =================
def reducer(top_n=20):
    """
    Reducer: tìm Top N phim có score cao nhất
    """
    top_movies = []  # min-heap để giữ top N (movie_title, score)

    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue
        try:
            movie_title, score_str = line.split("\t")
            score = float(score_str)
        except:
            continue

        # Giữ heap chỉ có top N phần tử
        if len(top_movies) < top_n:
            heapq.heappush(top_movies, (score, movie_title))
        else:
            heapq.heappushpop(top_movies, (score, movie_title))

    # Sắp xếp lại theo score giảm dần
    top_movies_sorted = sorted(top_movies, key=lambda x: x[0], reverse=True)

    print(f"Top {top_n} movies with highest (rating * revenue):")
    for rank, (score, title) in enumerate(top_movies_sorted, start=1):
        print(f"{rank}. {title}\t{score:,.2f}")

# ================= Main =================
if __name__ == "__main__":
    if len(sys.argv) < 2:
        sys.exit("Usage: python3 best_movie.py <mapper|reducer>")
    mode = sys.argv[1].lower()
    if mode == "mapper":
        mapper()
    elif mode == "reducer":
        reducer(top_n=20)
    else:
        sys.exit("Invalid mode. Use 'mapper' or 'reducer'.")
