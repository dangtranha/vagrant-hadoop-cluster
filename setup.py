import socket
import json

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

# Nhập thông tin người dùng
username = input("Nhập username Hadoop: ")
password = input("Nhập password Hadoop: ")

# Nhập hostname master/slave, 0 để mặc định
master_host_input = input("Nhập hostname Master (hoặc 0 để mặc định hadoop-master): ")
slave_host_input = input("Nhập hostname Slave (hoặc 0 để mặc định hadoop-slave): ")

master_host = "hadoop-master" if master_host_input.strip() == "0" else master_host_input.strip()
slave_host = "hadoop-slave" if slave_host_input.strip() == "0" else slave_host_input.strip()

# Lấy IP hiện tại và tính IP master/slave
current_ip = get_ipv4_192()
master_ip = increment_ip(current_ip, 9)
slave_ip = increment_ip(master_ip, 10)

# Tạo cấu trúc JSON
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

# Xuất ra file
with open("clustering_config.json", "w") as f:
    json.dump(config, f, indent=2)

print("File clustering_config.json đã tạo thành công:")
print(json.dumps(config, indent=2))


print("vagrant ssh master/slave để sử dụng.")
