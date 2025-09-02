import socket
import json
import subprocess

def get_ipv4_192():
    """Lấy IP đầu tiên có dạng 192.168.*.*"""
    hostname = socket.gethostname()
    ips = socket.gethostbyname_ex(hostname)[2]
    for ip in ips:
        if ip.startswith("192.168."):
            return ip
    raise Exception("Không tìm thấy IP 192.168.*.*")

def increment_ip(ip, inc):
    """Cộng số vào octet cuối của IP"""
    parts = list(map(int, ip.split('.')))
    parts[3] += inc
    if parts[3] > 254:
        raise ValueError("Octet cuối vượt quá 254")
    return '.'.join(map(str, parts))

# Xử lý IP & ghi file
current_ip = get_ipv4_192()
master_ip = increment_ip(current_ip, 9)
slave_ip = increment_ip(master_ip, 10)

# Vòng lặp nhập & xác nhận thông tin
while True:
    username = input("Nhập username Hadoop: ")
    password = input("Nhập password Hadoop: ")
    
    print("Vui lòng không nhập trùng hostname cho Master và Slave. Lỗi ráng chịu nhé các tình yêu :))")
    master_host_input = input("Nhập hostname Master (Enter để mặc định hadoop-master): ")
    slave_host_input = input("Nhập hostname Slave (Enter để mặc định hadoop-slave): ")

    master_host = "hadoop-master" if master_host_input.strip() == "" else master_host_input.strip()
    slave_host = "hadoop-slave" if slave_host_input.strip() == "" else slave_host_input.strip()

    if master_host == slave_host:
        print("Hostname Master và Slave không được trùng. Vui lòng nhập lại.\n")
        continue

    # In ra thông tin vừa nhập
    print("\n===== Thông tin cấu hình bạn đã nhập =====")
    print(f"Username: {username}")
    print(f"Password: {password}")
    print(f"Master hostname: {master_host}")
    print(f"Slave hostname:  {slave_host}")
    print(f"Master IP: {master_ip}")
    print(f"Slave IP: {slave_ip}")
    print("=========================================\n")

    confirm = input("Bạn có xác nhận các thông tin trên không? (y/n): ").strip().lower()
    if confirm in ("y", "yes", ""):
        break
    else:
        print("Nhập lại toàn bộ thông tin...\n")


config = {
    "user": {
        "username": username,
        "password": password
    },
    "master": {
        "ip": master_ip,
        "hostname": master_host
    },
    "slave": {
        "ip": slave_ip,
        "hostname": slave_host
    }
}
with open("clustering_config.json", "w") as f:
    json.dump(config, f, indent=2)
print("Đang khởi động Vagrant...\n")

try:
    subprocess.run(["vagrant", "up"], check=True)
    print("Vagrant đã khởi động thành công!")
    print("Sử dụng: vagrant ssh master hoặc vagrant ssh slave để kết nối.")
    print("Xem thêm lệnh tại: vagrant --help hoặc https://www.vagrantup.com/docs")

except subprocess.CalledProcessError as e:
    print(f"Lỗi khi chạy vagrant up: {e}")
    print("Thử reset lại Vagrant bằng cách destroy -f và up lại...")
    try:
        subprocess.run(["vagrant", "destroy", "-f"], check=True)
        subprocess.run(["vagrant", "up"], check=True)
        print("Vagrant đã khởi động thành công sau khi reset!")
        print("Sử dụng: vagrant ssh master hoặc vagrant ssh slave để kết nối.")
    except subprocess.CalledProcessError as e2:
        print(f"Vagrant vẫn lỗi sau khi reset: {e2}")
        print("Hãy kiểm tra lại Vagrantfile, plugin, hoặc cấu hình hệ thống.")
