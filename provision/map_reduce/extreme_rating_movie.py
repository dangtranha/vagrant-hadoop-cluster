#!/usr/bin/env python3
import sys
import csv
import heapq

# ================= Mapper =================
def mapper():
    """
    Mapper: xuất movie_title và rating
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
            if not rating_str:
                continue
            rating = float(rating_str)
            print(f"{movie_title}\t{rating}")
        except:
            continue


# ================= Reducer =================
def reducer():
    """
    Reducer: in ra Top 50 phim có rating cao nhất
    """
    top_movies = []  # dùng min-heap để giữ top 50

    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue
        try:
            movie, rating_str = line.split("\t")
            rating = float(rating_str)
        except:
            continue

        # Thêm vào heap, giới hạn 50 phần tử
        if len(top_movies) < 50:
            heapq.heappush(top_movies, (rating, movie))
        else:
            heapq.heappushpop(top_movies, (rating, movie))

    # Sắp xếp giảm dần rating
    top_movies.sort(reverse=True)

    print("===== Top 50 Movies by Rating =====")
    for i, (rating, movie) in enumerate(top_movies, start=1):
        print(f"{i:02d}. {movie}\t{rating:.2f}")


# ================= Main =================
if __name__ == "__main__":
    if len(sys.argv) < 2:
        sys.exit("Usage: python3 top50_rating_movie.py <mapper|reducer>")
    mode = sys.argv[1].lower()
    if mode == "mapper":
        mapper()
    elif mode == "reducer":
        reducer()
    else:
        sys.exit("Invalid mode. Use 'mapper' or 'reducer'.")
