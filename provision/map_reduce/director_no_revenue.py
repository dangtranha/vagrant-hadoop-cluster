#!/usr/bin/env python3
import sys
import csv

# ================= Mapper =================
def mapper():
    """
    Mapper: xuất mỗi đạo diễn 1 dòng với revenue
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
            print(f"{director_name}\t{revenue}")
        except:
            continue


# ================= Reducer =================
def reducer():
    """
    Reducer: in ra toàn bộ đạo diễn có tất cả phim revenue = 0
    """
    current_director = None
    all_zero = True  # mặc định là tất cả = 0 cho đạo diễn hiện tại

    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue
        try:
            director, revenue_str = line.split("\t")
            revenue = float(revenue_str)
        except:
            continue

        # Nếu cùng đạo diễn
        if current_director == director:
            if revenue != 0:
                all_zero = False  # có ít nhất 1 phim có doanh thu
        else:
            # In đạo diễn trước nếu đủ điều kiện
            if current_director is not None and all_zero:
                print(f"{current_director}")

            # Chuyển sang đạo diễn mới
            current_director = director
            all_zero = (revenue == 0)

    # Kiểm tra đạo diễn cuối cùng
    if current_director is not None and all_zero:
        print(f"{current_director}")


# ================= Main =================
if __name__ == "__main__":
    if len(sys.argv) < 2:
        sys.exit("Usage: python3 director_no_revenue.py <mapper|reducer>")
    mode = sys.argv[1].lower()
    if mode == "mapper":
        mapper()
    elif mode == "reducer":
        reducer()
    else:
        sys.exit("Invalid mode. Use 'mapper' or 'reducer'.")
