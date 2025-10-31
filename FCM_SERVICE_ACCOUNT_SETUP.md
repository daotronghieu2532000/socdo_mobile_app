# 📋 HƯỚNG DẪN SỬ DỤNG SERVICE ACCOUNT JSON

## ✅ ĐÃ CÓ FILE SERVICE ACCOUNT

File: `android/app/socdomobile-36bf021cb402.json`

---

## 📁 ĐẶT FILE VÀO ĐÚNG VỊ TRÍ

### Bước 1: Di chuyển file vào thư mục API_WEB

File JSON hiện tại đang ở: `android/app/socdomobile-36bf021cb402.json`

**Cần di chuyển đến**: `API_WEB/socdomobile-36bf021cb402.json`

```bash
# Trên Linux/Mac:
mv android/app/socdomobile-36bf021cb402.json API_WEB/

# Hoặc copy:
cp android/app/socdomobile-36bf021cb402.json API_WEB/
```

⚠️ **Lưu ý**: File JSON chứa **private key**, rất nhạy cảm về bảo mật!

---

## 🔐 BẢO MẬT FILE JSON

### Thêm vào .gitignore

Tạo hoặc cập nhật file `.gitignore` ở root project:

```gitignore
# Firebase Service Account (BẢO MẬT - không commit!)
API_WEB/socdomobile-*.json
API_WEB/*-*.json
!API_WEB/composer.json
```

### Kiểm tra file đã được ignore chưa:

```bash
git status
# File JSON không nên xuất hiện trong danh sách
```

---

## ✅ KIỂM TRA FILE ĐÃ ĐẶT ĐÚNG

File `API_WEB/fcm_config.php` đã được cấu hình với đường dẫn:

```php
$FCM_SERVICE_ACCOUNT_JSON_PATH = __DIR__ . '/socdomobile-36bf021cb402.json';
```

Điều này có nghĩa file JSON phải nằm trong cùng thư mục với `fcm_config.php`:

```
API_WEB/
  ├── fcm_config.php
  ├── fcm_push_service_v1.php
  ├── socdomobile-36bf021cb402.json  ← File này phải ở đây
  └── ...
```

---

## 🧪 TEST CẤU HÌNH

### Test 1: Kiểm tra file tồn tại

Tạo file test: `API_WEB/test_fcm_config.php`

```php
<?php
require_once './fcm_config.php';

try {
    $data = getFCMServiceAccountData();
    echo "✅ Service Account file OK\n";
    echo "Project ID: " . $data['project_id'] . "\n";
    echo "Client Email: " . $data['client_email'] . "\n";
} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
?>
```

Chạy:
```bash
php API_WEB/test_fcm_config.php
```

Kết quả mong đợi:
```
✅ Service Account file OK
Project ID: socdomobile
Client Email: firebase-adminsdk-fbsvc@socdomobile.iam.gserviceaccount.com
```

---

## 📝 CẬP NHẬT CODE

### File đã được cập nhật:

1. ✅ `API_WEB/fcm_config.php` - Đã cấu hình để đọc Service Account JSON
2. ✅ `API_WEB/fcm_push_service_v1.php` - Đã implement HTTP V1 API
3. ✅ `API_WEB/notification_mobile_helper.php` - Đã chuyển sang dùng V1 API

### Migration từ Legacy sang V1:

File `fcm_push_service.php` (Legacy) vẫn còn nhưng không được dùng nữa.

Bạn có thể:
- **Option 1**: Xóa file `fcm_push_service.php` (khuyến nghị)
- **Option 2**: Giữ lại để tham khảo

---

## 🚀 SẴN SÀNG SỬ DỤNG

Sau khi:
1. ✅ Di chuyển file JSON vào `API_WEB/`
2. ✅ Thêm vào `.gitignore`
3. ✅ Test cấu hình thành công

→ Bạn có thể bắt đầu test gửi push notifications!

---

## 🐛 TROUBLESHOOTING

### Lỗi: "Service Account JSON file không tồn tại"

**Nguyên nhân**: File JSON chưa được đặt đúng vị trí

**Giải pháp**: 
- Kiểm tra đường dẫn trong `fcm_config.php`
- Đảm bảo file JSON nằm trong `API_WEB/`
- Kiểm tra quyền truy cập file (read permission)

### Lỗi: "Cannot parse Service Account JSON"

**Nguyên nhân**: File JSON bị hỏng hoặc không đúng format

**Giải pháp**:
- Kiểm tra file JSON có đầy đủ không
- Đảm bảo file là valid JSON (có thể test bằng `json_decode()`)
- Tải lại file JSON từ Firebase Console nếu cần

### Lỗi OpenSSL khi sign JWT

**Nguyên nhân**: PHP chưa cài OpenSSL extension

**Giải pháp**:
```php
// Kiểm tra OpenSSL có enabled không
php -m | grep openssl

// Nếu không có, cần enable trong php.ini
extension=openssl
```

---

**📅 Created**: 2025-01-XX
**✅ Status**: Ready to use

