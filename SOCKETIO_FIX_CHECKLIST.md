# Checklist: Sửa Socket.IO sau khi Mentor đổi port

## 🔍 Vấn đề hiện tại:
- Process 355 (chat.trungtamkcnphutho.vn) đang chiếm port 3000
- PM2 process 0 (chat.socdo.vn) bị errored vì port 3000 đã được dùng
- Flutter app không thể kết nối Socket.IO

## ✅ Sau khi Mentor đổi port:

### 1. **Kiểm tra port mới của chat.socdo.vn**
```bash
# SSH vào server
ssh -p 2222 root@167.179.110.50

# Kiểm tra process đang chạy
pm2 list

# Kiểm tra port mới
netstat -tulpn | grep node
# Hoặc
lsof -i :<PORT_MỚI>
```

### 2. **Cập nhật Nginx config**
- File: `/etc/nginx/conf.d/chat.socdo.vn.conf`
- File: `/etc/nginx/config-https/chat.socdo.vn-https.conf`
- Thay `proxy_pass http://localhost:3000` → `proxy_pass http://localhost:<PORT_MỚI>`

### 3. **Reload Nginx**
```bash
nginx -t
nginx -s reload
# Hoặc
systemctl reload nginx
```

### 4. **Cập nhật Flutter app (nếu cần)**
- File: `lib/src/core/services/socketio_service.dart`
- Hiện tại: `https://chat.socdo.vn` (không cần đổi vì Nginx sẽ proxy)
- **KHÔNG CẦN** đổi trong Flutter app vì Nginx đã proxy

### 5. **Kiểm tra kết nối**
```bash
# Test từ server
curl -I https://chat.socdo.vn/socket.io/

# Test WebSocket connection
# (có thể dùng browser console hoặc Flutter app)
```

### 6. **Kiểm tra HTTPS config cho WebSocket**
Đảm bảo HTTPS config có:
```nginx
location /socket.io/ {
    proxy_pass http://localhost:<PORT_MỚI>;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_read_timeout 60s;
    proxy_send_timeout 60s;
}
```

## 📝 Notes:
- Port thay đổi chỉ ảnh hưởng đến Nginx config
- Flutter app vẫn connect đến `https://chat.socdo.vn` (không cần đổi)
- Chỉ cần cập nhật Nginx `proxy_pass` đến port mới

