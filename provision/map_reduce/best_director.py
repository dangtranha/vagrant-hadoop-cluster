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
    Reducer: cộng tổng revenue theo director
    và in ra director có doanh thu cao nhất
    """
    current_director = None
    total_revenue = 0.0

    max_revenue = 0.0
    top_director = None

    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue
        try:
            director, revenue_str = line.split("\t")
            revenue = float(revenue_str)
        except:
            continue

        if current_director == director:
            total_revenue += revenue
        else:
            if current_director:
                print(f"{current_director}\t{total_revenue}")
                if total_revenue > max_revenue:
                    max_revenue = total_revenue
                    top_director = current_director
            current_director = director
            total_revenue = revenue

    # Xử lý director cuối cùng
    if current_director:
        print(f"{current_director}\t{total_revenue}")
        if total_revenue > max_revenue:
            max_revenue = total_revenue
            top_director = current_director

    # In ra top director
    print(f"\nTop director: {top_director} with revenue: ${max_revenue:,.2f}")

# ================= Main =================
if __name__ == "__main__":
    if len(sys.argv) < 2:
        sys.exit("Usage: python3 combined_mapreduce.py <mapper|reducer>")
    mode = sys.argv[1].lower()
    if mode == "mapper":
        mapper()
    elif mode == "reducer":
        reducer()
    else:
        sys.exit("Invalid mode. Use 'mapper' or 'reducer'.")
