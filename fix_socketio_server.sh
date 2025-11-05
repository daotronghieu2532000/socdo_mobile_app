#!/bin/bash
# Script sửa lỗi Socket.IO server

echo "=== 1. KIỂM TRA FILE index.js Ở chat.socdo.vn ==="
cat /home/chat.socdo.vn/public_html/index.js
echo ""

echo "=== 2. KIỂM TRA PROCESS 355 (ĐANG CHẠY) ==="
ps aux | grep 355
echo ""

echo "=== 3. KIỂM TRA NGINX CONFIG ==="
find /etc/nginx -name "*chat*" -type f
echo ""

echo "=== 4. XEM NGINX CONFIG CHO chat.socdo.vn ==="
cat /etc/nginx/sites-available/chat.socdo.vn 2>/dev/null || cat /etc/nginx/conf.d/chat.socdo.vn.conf 2>/dev/null || echo "Không tìm thấy"
echo ""

echo "=== 5. KIỂM TRA PM2 PROCESS DETAILS ==="
pm2 describe 0
pm2 describe 1
echo ""

echo "=== 6. XEM LOGS CHI TIẾT CỦA PM2 PROCESS 1 (ONLINE) ==="
pm2 logs 1 --lines 50
echo ""

