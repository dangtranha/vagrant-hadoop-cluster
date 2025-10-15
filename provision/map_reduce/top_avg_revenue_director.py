#!/usr/bin/env python3
import sys
import csv

# ================= Mapper =================
def mapper():
    """
    Mapper: xuất mỗi đạo diễn với doanh thu và số phim = 1
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
            revenue_str = fields[2].strip()
            if not director_name:
                continue
            revenue = float(revenue_str) if revenue_str else 0.0
            print(f"{director_name}\t{revenue}\t1")
        except:
            continue

# ================= Reducer =================
def reducer(top_n=5):
    """
    Reducer: tính doanh thu trung bình mỗi đạo diễn
    và in Top N đạo diễn có doanh thu trung bình cao nhất
    """
    director_totals = {}
    
    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue
        try:
            director, revenue_str, count_str = line.split("\t")
            revenue = float(revenue_str)
            count = int(count_str)
        except:
            continue

        if director in director_totals:
            director_totals[director]['revenue'] += revenue
            director_totals[director]['count'] += count
        else:
            director_totals[director] = {'revenue': revenue, 'count': count}

    # Tính trung bình và sắp xếp Top N
    avg_revenues = [(d, v['revenue']/v['count']) for d,v in director_totals.items()]
    avg_revenues.sort(key=lambda x: x[1], reverse=True)

    print(f"Top {top_n} directors by average revenue:")
    for director, avg in avg_revenues[:top_n]:
        print(f"{director}\t{avg:,.2f}")

# ================= Main =================
if __name__ == "__main__":
    if len(sys.argv) < 2:
        sys.exit("Usage: python3 top_avg_revenue_director.py <mapper|reducer>")
    mode = sys.argv[1].lower()
    if mode == "mapper":
        mapper()
    elif mode == "reducer":
        reducer()
    else:
        sys.exit("Invalid mode. Use 'mapper' or 'reducer'.")
