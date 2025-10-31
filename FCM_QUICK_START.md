# ⚡ QUICK START - FCM Push Notifications

## ✅ ĐÃ HOÀN TẤT

1. ✅ Sửa lỗi SQL: `device_token varchar(191)` (đã fix lỗi index)
2. ✅ Cập nhật sang FCM HTTP V1 API
3. ✅ Tạo `fcm_push_service_v1.php` với Service Account authentication
4. ✅ Cập nhật `notification_mobile_helper.php` để dùng V1 API

---

## 📋 CÁC BƯỚC TIẾP THEO

### 1. ✅ Chạy SQL để tạo bảng

File: `database_web/device_tokens.sql`

```sql
-- Đã được fix: device_token varchar(191) thay vì varchar(255)
-- Import vào database qua phpMyAdmin hoặc command line
```

### 2. 📁 Di chuyển Service Account JSON file

File hiện tại: `android/app/socdomobile-36bf021cb402.json`

**Cần di chuyển đến**: `API_WEB/socdomobile-36bf021cb402.json`

```bash
# Di chuyển file
mv android/app/socdomobile-36bf021cb402.json API_WEB/

# Hoặc copy
cp android/app/socdomobile-36bf021cb402.json API_WEB/
```

### 3. 🔐 Thêm vào .gitignore

Thêm vào file `.gitignore` (nếu chưa có):

```gitignore
# Firebase Service Account (BẢO MẬT)
API_WEB/socdomobile-*.json
API_WEB/*-*.json
!API_WEB/composer.json
```

### 4. ✅ Kiểm tra cấu hình

File `API_WEB/fcm_config.php` đã được cấu hình đúng:

```php
$FCM_SERVICE_ACCOUNT_JSON_PATH = __DIR__ . '/socdomobile-36bf021cb402.json';
$FCM_PROJECT_ID = 'socdomobile';
```

---

## 🧪 TEST

### Test 1: Kiểm tra Service Account file

```php
<?php
// API_WEB/test_fcm_config.php
require_once './fcm_config.php';

try {
    $data = getFCMServiceAccountData();
    echo "✅ Service Account file OK\n";
    echo "Project ID: " . $data['project_id'] . "\n";
} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
```

Chạy: `php API_WEB/test_fcm_config.php`

---

## 📦 FLUTTER SETUP

Đã hoàn tất:
- ✅ Dependencies đã được thêm vào `pubspec.yaml`
- ✅ Firebase đã được initialize trong `main.dart`
- ✅ Push notification service đã được tích hợp

**Cần chạy**:
```bash
flutter pub get
```

---

## 🚀 SẴN SÀNG!

Sau khi:
1. ✅ Chạy SQL tạo bảng
2. ✅ Di chuyển JSON file vào `API_WEB/`
3. ✅ Thêm vào `.gitignore`
4. ✅ Chạy `flutter pub get`

→ Bạn có thể **build và test app** trên device thật!

---

## 📚 TÀI LIỆU THAM KHẢO

- `FCM_SETUP_HUONG_DAN.md` - Hướng dẫn setup chi tiết
- `FCM_SERVICE_ACCOUNT_SETUP.md` - Hướng dẫn Service Account
- `FCM_V1_MIGRATION_GUIDE.md` - Chi tiết về migration sang V1 API

---

**✅ Status**: Ready to test!

