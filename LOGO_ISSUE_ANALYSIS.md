# 🔍 Phân tích: Logo không hiển thị

## ❌ Vấn đề phát hiện

Từ log `debug_push_notifications.log`:

```
[LOGO_CHECK] Logo URL NOT accessible: https://socdo.vn/uploads/logo/logo.png 
(HTTP 0, Error: Failed connect to socdo.vn:443; Connection refused)
```

## 🔍 Nguyên nhân

1. **Server PHP không thể connect đến HTTPS**
   - Lỗi: `Connection refused` khi connect đến `socdo.vn:443`
   - Có thể do:
     - Server PHP không có quyền access HTTPS/443
     - Firewall block port 443
     - SSL/TLS configuration issue

2. **FCM vẫn nhận message thành công**
   - FCM Response: HTTP 200 ✅
   - Message sent successfully ✅
   - Logo URL vẫn được gửi trong payload ✅

3. **Nhưng FCM không thể download image**
   - Nếu logo URL không accessible từ internet → FCM không thể download
   - Kết quả: Notification hiển thị nhưng không có logo

## ✅ Giải pháp

### Option 1: Kiểm tra logo URL từ internet
```bash
curl -I https://socdo.vn/uploads/logo/logo.png
# Phải trả về HTTP 200
```

### Option 2: Thử HTTP thay vì HTTPS (nếu có vấn đề SSL)
```php
$logoUrl = 'http://socdo.vn/uploads/logo/logo.png';
```
⚠️ Lưu ý: HTTP không an toàn, chỉ dùng tạm để test

### Option 3: Sử dụng CDN hoặc static URL
```php
$logoUrl = 'https://cdn.socdo.vn/logo.png';
// Hoặc
$logoUrl = 'https://static.socdo.vn/uploads/logo/logo.png';
```

### Option 4: Upload logo lên Firebase Storage
- Upload logo lên Firebase Storage
- Dùng URL public từ Firebase
- Đảm bảo 100% accessible

## 🧪 Kiểm tra

1. **Từ browser**: Truy cập https://socdo.vn/uploads/logo/logo.png
   - Phải thấy logo hiển thị
   - Không có lỗi 404, 403, hoặc SSL error

2. **Từ command line** (nếu có SSH access):
   ```bash
   curl -I https://socdo.vn/uploads/logo/logo.png
   # Phải trả về: HTTP/1.1 200 OK
   ```

3. **Kiểm tra file tồn tại**:
   - File: `/home/socdo.vn/public_html/uploads/logo/logo.png`
   - Phải tồn tại và có quyền đọc

## 📝 Next Steps

1. Kiểm tra logo URL có accessible từ internet không
2. Nếu không accessible:
   - Fix SSL/firewall issue
   - Hoặc dùng HTTP (test only)
   - Hoặc upload lên CDN/Firebase Storage
3. Sau khi fix, test lại notification

## 🔧 Quick Fix (Test)

Nếu muốn test nhanh, có thể thử HTTP (không secure):

```php
$logoUrl = 'http://socdo.vn/uploads/logo/logo.png';
```

Nhưng nên fix HTTPS để production an toàn.

