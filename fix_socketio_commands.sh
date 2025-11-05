#!/bin/bash
# Script sửa lỗi Socket.IO - chạy từng bước

echo "=== BƯỚC 1: KIỂM TRA HTTPS CONFIG ==="
cat /etc/nginx/config-https/chat.socdo.vn-https.conf
echo ""

echo "=== BƯỚC 2: DỪNG PM2 PROCESS 0 (ERrored) ==="
pm2 delete 0
echo ""

echo "=== BƯỚC 3: KIỂM TRA PROCESS 355 ==="
ps aux | grep 355 | grep -v grep
echo ""

echo "=== BƯỚC 4: KIỂM TRA NGINX ERROR LOG ==="
tail -n 20 /home/chat.socdo.vn/logs/error.log | grep -i websocket
echo ""

echo "=== BƯỚC 5: TEST KẾT NỐI HTTPS ==="
curl -I https://chat.socdo.vn 2>&1 | head -10
echo ""

echo "=== BƯỚC 6: TEST WEBSOCKET ENDPOINT ==="
curl -I https://chat.socdo.vn/socket.io/ 2>&1 | head -10
echo ""

