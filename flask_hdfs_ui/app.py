from flask import Flask, render_template, request, redirect, jsonify
import requests
import json
import os

app = Flask(__name__)

NAMENODE_HOST = "http://192.168.56.10:9870"
USER = "hadoop"

# ------------------------------
# 🔹 HÀM XỬ LÝ HDFS
# ------------------------------
def list_hdfs_dir(path="/"):
    if not path.startswith("/"):
        path = "/" + path
    url = f"{NAMENODE_HOST}/webhdfs/v1{path}?op=LISTSTATUS&user.name={USER}"
    res = requests.get(url)
    if res.status_code == 200:
        return res.json().get("FileStatuses", {}).get("FileStatus", [])
    return []

def list_all_hdfs_dirs(base="/data"):
    dirs = []
    items = list_hdfs_dir(base)
    for i in items:
        if i["type"] == "DIRECTORY":
            sub = f"{base.rstrip('/')}/{i['pathSuffix']}"
            dirs.append(sub)
            dirs.extend(list_all_hdfs_dirs(sub))
    return dirs

def read_hdfs_csv(path):
    url = f"{NAMENODE_HOST}/webhdfs/v1{path}?op=OPEN&user.name={USER}"
    res = requests.get(url, allow_redirects=True)
    if res.status_code == 200:
        return res.text
    else:
        raise Exception(f"Lỗi đọc file {path}: {res.status_code}")

def write_hdfs_csv(path, content):
    create_url = f"{NAMENODE_HOST}/webhdfs/v1{path}?op=CREATE&overwrite=true&user.name={USER}"
    redirect_res = requests.put(create_url, allow_redirects=False)
    if redirect_res.status_code not in [307, 201]:
        raise Exception(f"Không thể tạo file: {redirect_res.status_code}")

    upload_url = redirect_res.headers.get("Location")
    put_res = requests.put(upload_url, data=content.encode("utf-8"), allow_redirects=True)
    if put_res.status_code not in [200, 201]:
        raise Exception(f"Lỗi ghi file {path} - Code: {put_res.status_code}")
    return True

# ------------------------------
# 🔹 GIAO DIỆN CHÍNH
# ------------------------------
# Biến tạm để lưu tiêu đề (có thể dùng DB hoặc file sau này)
chart_titles = {}

@app.route("/")
def index():
    folders = list_all_hdfs_dirs("/cleandata_csv")
    return render_template("index.html", folders=folders, files=[], current_path="/data")

# --- Danh sách thư mục không cần vẽ biểu đồ ---
NO_CHART_DIRS = ["/data/data_clean"]

@app.route("/view_data")
def view_data():
    path = request.args.get("path", "/cleandata_csv")

    # Lấy danh sách thư mục và file
    folders = [
        f"{path}/{f['pathSuffix']}"
        for f in list_hdfs_dir(path)
        if f["type"] == "DIRECTORY"
    ]
    files = [f for f in list_hdfs_dir(path) if f["type"] == "FILE"]

    action = request.args.get("action", "list")

    if action == "list":
        return render_template(
            "index.html",
            folders=folders,
            files=files,
            current_path=path
        )

    elif action == "open":
        # ✅ Nếu là thư mục data_clean → chỉ hiển thị dữ liệu, không hiển thị biểu đồ
        if path.startswith("/data/data_clean"):
            try:
                raw_data = read_hdfs_csv(path)

                lines = raw_data.strip().split("\n")[:200]
                csv_data = "\n".join(lines)

            except Exception as e:
                csv_data = f"Lỗi khi đọc file CSV: {e}"

            return render_template(
                "index.html",
                folders=folders,
                files=files,
                current_path=path,
                csv_data=csv_data,
                labels=[],
                values=[],
                chart_type="",   # ⚠️ Không có biểu đồ
                title=None,
                action=action
            )

        # ✅ Nếu không phải thư mục data_clean → xử lý bình thường (vẽ biểu đồ)
        try:
            csv_data = read_hdfs_csv(path)
            lines = csv_data.strip().split("\n")[:200]  # đọc 200 dòng đầu
        except Exception as e:
            csv_data = f"Lỗi khi đọc file CSV: {e}"
            lines = []

        labels, values = [], []
        for line in lines:
            parts = line.replace("\t", ",").split(",")
            if len(parts) >= 1:
                labels.append(parts[0].strip())
                if len(parts) >= 2:
                    try:
                        values.append(float(parts[1]))
                    except:
                        values.append(0)

        # Lấy tiêu đề nếu có
        title = chart_titles.get(path, "Biểu đồ chưa có tên")

        # Xác định kiểu biểu đồ
        if not values or all(v == 0 for v in values):
            chart_type = "pie"
            values = [1] * len(labels)
        else:
            chart_type = "bar"

        return render_template(
            "index.html",
            folders=folders,
            files=files,
            current_path=path,
            csv_data="\n".join(lines),
            labels=labels,
            values=values,
            chart_type=chart_type,
            title=title,
            action=action
        )

    return redirect("/")


TITLE_FILE = "chart_titles.json"

# Load khi khởi động server
if os.path.exists(TITLE_FILE):
    with open(TITLE_FILE, "r", encoding="utf-8") as f:
        chart_titles = json.load(f)
else:
    chart_titles = {}

@app.route("/update_title", methods=["POST"])
def update_title():
    path = request.form.get("path")
    new_title = request.form.get("chart_title", "").strip()
    if path and new_title:
        chart_titles[path] = new_title
        with open(TITLE_FILE, "w", encoding="utf-8") as f:
            json.dump(chart_titles, f, ensure_ascii=False, indent=2)
    return redirect(f"/view_data?action=open&path={path}")


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000, debug=True)
