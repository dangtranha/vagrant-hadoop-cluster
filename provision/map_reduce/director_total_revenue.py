#!/usr/bin/env python3
import sys
import csv

# ================= Mapper =================
def mapper():
    """
    Mapper: đọc CSV, output:
    director_name \t revenue
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
            revenue_str = fields[2].strip()
            director_name = fields[3].strip()
            if not director_name:
                continue  # bỏ dòng không có director
            revenue = float(revenue_str) if revenue_str else 0.0
            print(f"{director_name}\t{revenue}")
        except:
            continue


# ================= Reducer =================
def reducer():
    """
    Reducer: cộng tổng revenue theo director và in ra toàn bộ đạo diễn
    """
    revenue_by_director = {}

    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue
        try:
            director, revenue_str = line.split("\t")
            revenue = float(revenue_str)
        except:
            continue

        # Cộng dồn doanh thu theo đạo diễn
        if director in revenue_by_director:
            revenue_by_director[director] += revenue
        else:
            revenue_by_director[director] = revenue

    # Sắp xếp theo doanh thu giảm dần
    sorted_directors = sorted(revenue_by_director.items(), key=lambda x: x[1], reverse=True)

    # In ra toàn bộ đạo diễn cùng tổng doanh thu
    for director, total_revenue in sorted_directors:
        print(f"{director}\t{total_revenue}")


# ================= Main =================
if __name__ == "__main__":
    if len(sys.argv) < 2:
        sys.exit("Usage: python3 director_total_revenue.py <mapper|reducer>")
    mode = sys.argv[1].lower()
    if mode == "mapper":
        mapper()
    elif mode == "reducer":
        reducer()
    else:
        sys.exit("Invalid mode. Use 'mapper' or 'reducer'.")
