#!/bin/bash

# Thư mục chứa tất cả các script .sh (giả sử đang ở map_reduce)
SCRIPT_DIR="$(pwd)"

echo "✅ Chạy tất cả các script .sh trong $SCRIPT_DIR ..."

# Tạo thư mục log nếu chưa có
LOG_DIR="$SCRIPT_DIR/logs"
mkdir -p "$LOG_DIR"

# Lặp qua tất cả các file .sh trong thư mục
for script in "$SCRIPT_DIR"/*.sh; do
    # Bỏ qua chính run_all.sh
    if [ "$(basename "$script")" != "run_all.sh" ]; then
        echo "⏳ Đang chạy $script ..."
        chmod +x "$script"                  # đảm bảo có quyền chạy

        # Chạy script, ghi stdout và stderr vào file log riêng
        LOG_FILE="$LOG_DIR/$(basename "$script").log"
        "$script" > "$LOG_FILE" 2>&1

        # Kiểm tra kết quả chạy
        if [ $? -eq 0 ]; then
            echo "✅ Hoàn tất $script. Log: $LOG_FILE"
        else
            echo "⚠️  Script $script chạy lỗi. Kiểm tra log: $LOG_FILE"
        fi
        echo "-------------------------------------"
    fi
done

echo "🎉 Hoàn tất chạy tất cả script!"
