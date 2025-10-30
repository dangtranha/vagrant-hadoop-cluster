# Phân Tích Dữ Liệu Phim Ảnh Với Hệ Thống Hadoop Ecosystem

**Đồ án cuối kỳ - Big Data Essentials**
**Trường Đại học Sư phạm Kỹ thuật TP. Hồ Chí Minh**
**Ngành Kỹ thuật Dữ liệu**

---

## 1. Giới thiệu

Dự án này xây dựng một **hệ thống xử lý dữ liệu lớn (Big Data Pipeline)** nhằm **phân tích dữ liệu phim ảnh** từ hai nguồn chính: **The Movie Database (TMDb)** và **Box Office Mojo**.
Toàn bộ hệ thống được triển khai trên **Hadoop Ecosystem**, sử dụng **Vagrant** để tự động hóa môi trường và **Flask** để hiển thị kết quả trực quan.

Mục tiêu chính là khai thác dữ liệu phim quy mô lớn, xác định các yếu tố ảnh hưởng đến doanh thu và đánh giá phim, đồng thời trình bày kết quả qua giao diện web.

---

## 2. Kiến trúc hệ thống

Hệ thống được thiết kế theo pipeline xử lý nhiều tầng, kết hợp các công nghệ trong hệ sinh thái Hadoop:

```
+---------------------+
|  Scrapy (Python)    | --> Thu thập dữ liệu phim, đạo diễn, doanh thu
+---------------------+
            ↓
+---------------------+
|  MongoDB            | --> Lưu trữ dữ liệu thô dạng document
+---------------------+
            ↓
+---------------------+
|  Apache Spark       | --> Làm sạch và chuyển đổi dữ liệu
+---------------------+
            ↓
+---------------------+
|  Hadoop HDFS        | --> Lưu trữ phân tán dữ liệu lớn
+---------------------+
            ↓
+---------------------+
|  Hive / MapReduce   | --> Truy vấn và phân tích dữ liệu song song
+---------------------+
            ↓
+---------------------+
|  Flask Web UI       | --> Trực quan hóa kết quả phân tích
+---------------------+
```

---

## 3. Công nghệ sử dụng

| Thành phần                     | Vai trò                                 |
| ------------------------------ | --------------------------------------- |
| Vagrant + VirtualBox           | Tạo và quản lý cụm Hadoop tự động       |
| Hadoop (HDFS, YARN, MapReduce) | Lưu trữ và xử lý dữ liệu phân tán       |
| Apache Hive                    | Truy vấn dữ liệu bằng ngôn ngữ SQL      |
| Apache Spark                   | Làm sạch, biến đổi và xử lý dữ liệu     |
| MongoDB                        | Lưu trữ dữ liệu thô dạng document       |
| Scrapy                         | Cào dữ liệu từ TMDb và Box Office Mojo  |
| Flask                          | Xây dựng giao diện web hiển thị kết quả |
| Python                         | Kết nối và điều phối toàn bộ pipeline   |

---

## 4. Cấu trúc thư mục

```
vagrant-hadoop-cluster/
├── Vagrantfile                 # Cấu hình cụm Hadoop qua Vagrant
├── clustering_config.json       # Cấu hình node (Master/Worker)
├── setup.py                     # Script thiết lập môi trường
├── flask_hdfs_ui/               # Ứng dụng Flask giao tiếp HDFS
│   ├── app.py
│   ├── chart_titles.json
│   ├── requirements.txt
│   └── flask_hdfs_ui_copy.tar.gz
└── provision/                   # Script khởi tạo và chạy dịch vụ
    ├── common.sh
    └── start-all-service.sh
```

---

## 5. Quy trình hoạt động

### 5.1. Thu thập dữ liệu

* **Nguồn:** The Movie Database (TMDb) và Box Office Mojo
* **Công cụ:** Scrapy
* **Các spider chính:**

  * `tmdb_movies`: Lấy thông tin phim (tên, ngày phát hành, điểm đánh giá, thể loại, diễn viên, ngân sách).
  * `tmdb_director`: Lấy thông tin đạo diễn (năm sinh, nơi sinh, danh sách phim).
  * `movie_profit`: Thu thập dữ liệu doanh thu (domestic, international, worldwide).

Dữ liệu sau khi cào được lưu dạng JSON và đưa vào MongoDB.

### 5.2. Lưu trữ dữ liệu

* MongoDB lưu dữ liệu thô ở định dạng document.
* Spark đọc dữ liệu từ MongoDB, xử lý và ghi lại vào HDFS ở định dạng JSON hoặc Parquet.

### 5.3. Làm sạch và tiền xử lý

* Chuẩn hóa ký tự và mã hóa Unicode.
* Tách các cột ngày phát hành và quốc gia.
* Chuyển đổi giá trị ngân sách, doanh thu sang số thực.
* Tách danh sách diễn viên thành từng dòng riêng biệt.
* Hợp nhất dữ liệu từ ba nguồn thành file `combined_movies.csv`.

### 5.4. Phân tích dữ liệu

* Sử dụng MapReduce để:

  * Tính danh sách 20 phim có điểm đánh giá cao nhất.
  * Phân tích doanh thu, đạo diễn, thể loại và quốc gia.
* Hive được sử dụng để truy vấn và thống kê dữ liệu tổng hợp.

### 5.5. Trực quan hóa kết quả

Ứng dụng Flask HDFS UI kết nối qua WebHDFS API để:

* Xem và truy xuất file trên HDFS.
* Hiển thị biểu đồ thống kê dạng cột, tròn, và đường.
* Truy cập tại địa chỉ: `http://localhost:5000`

---

## 6. Hướng dẫn triển khai

### Bước 1: Cài đặt công cụ

Cài đặt các thành phần cần thiết:

* Vagrant ≥ 2.4
* VirtualBox ≥ 7.0
* Python ≥ 3.8
* Git

### Bước 2: Clone và khởi tạo cụm Hadoop

```bash
git clone https://github.com/dangtranha/vagrant-hadoop-cluster.git
cd vagrant-hadoop-cluster
vagrant up
```

### Bước 3: Truy cập vào các node

```bash
vagrant ssh master
vagrant ssh worker1
```

### Bước 4: Khởi động dịch vụ Hadoop

```bash
bash provision/start-all-service.sh
```

### Bước 5: Chạy ứng dụng Flask

```bash
cd flask_hdfs_ui
pip install -r requirements.txt
python app.py
```

Mở trình duyệt và truy cập `http://localhost:5000`.

---

## 7. Kết quả đạt được

* Hoàn thiện hệ thống xử lý dữ liệu phim ảnh từ khâu thu thập đến phân tích.
* Tự động triển khai Hadoop Cluster bằng Vagrant.
* Tích hợp thành công MongoDB – Spark – Hadoop – Hive – Flask.
* Phân tích được mối quan hệ giữa ngân sách, doanh thu, thể loại và đạo diễn.
* Cung cấp giao diện trực quan giúp người dùng khai thác dữ liệu dễ dàng.

---

## 8. Hướng phát triển

* Bổ sung mô hình **dự đoán doanh thu phim** sử dụng Spark MLlib.
* Mở rộng nguồn dữ liệu từ IMDb hoặc Rotten Tomatoes.
* Xây dựng dashboard trực quan bằng Power BI hoặc Apache Superset.
* Tích hợp Kafka và Spark Streaming để xử lý dữ liệu thời gian thực.

---

## 9. Thông tin nhóm thực hiện

| Họ và tên             | MSSV     |
| --------------------- | -------- |
| Trần Hà Đăng          | 22133012 |
| Nguyễn Nam Hy         | 22133029 |
| Nguyễn Ngọc Minh Nhật | 22133039 |
| Nguyễn Quốc Thịnh     | 22133056 |
| Trần Bảo Việt         | 22133065 |

**Giảng viên hướng dẫn:** ThS. Trần Quang Khải

---

## 10. Giấy phép

Dự án phát hành theo **Giấy phép MIT**.
Được phép sử dụng, chỉnh sửa và phân phối phục vụ học tập, nghiên cứu và phát triển.
