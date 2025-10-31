# 🔄 HƯỚNG DẪN MIGRATE SANG FCM HTTP V1 API

## ⚠️ THAY ĐỔI QUAN TRỌNG

Firebase đã **không còn hỗ trợ Legacy API** nữa, bây giờ phải dùng **HTTP V1 API**.

### Sự khác biệt:

| Legacy API (Cũ) | HTTP V1 API (Mới) |
|-----------------|-------------------|
| Dùng **Server Key** | Dùng **Service Account JSON** |
| Endpoint: `https://fcm.googleapis.com/fcm/send` | Endpoint: `https://fcm.googleapis.com/v1/projects/{project_id}/messages:send` |
| Header: `Authorization: key=...` | Header: `Authorization: Bearer {access_token}` |
| Đơn giản hơn | Phức tạp hơn nhưng bảo mật tốt hơn |

---

## 📁 ĐẶT FILE SERVICE ACCOUNT JSON

### Vị trí: `API_WEB/socdomobile-36bf021cb402.json`

⚠️ **QUAN TRỌNG**: File này chứa private key, **KHÔNG được commit vào Git!**

### Th_GIT .gitignore:

Thêm vào file `.gitignore`:

```
# Firebase Service Account (bảo mật)
API_WEB/socdomobile-*.json
API_WEB/*-*.json
!API_WEB/composer.json
```

---

## 🔧 CẤU HÌNH

File `API_WEB/fcm_config.php` đã được cập nhật để dùng Service Account JSON.

Đường dẫn trong `fcm_config.php`:
```php
$FCM_SERVICE_ACCOUNT_JSON_PATH = __DIR__ . '/socdomobile-36bf021cb402.json';
```

### ✅ Checklist:
- [x] File JSON đã được đặt tại `API_WEB/socdomobile-36bf021cb402.json`
- [x] File `fcm_config.php` đã được cập nhật
- [x] File JSON đã được thêm vào `.gitignore`

---

## 📝 CẬP NHẬT FCM_PUSH_SERVICE.PHP

Hiện tại `fcm_push_service.php` vẫn dùng Legacy API. 

Có 2 cách implement HTTP V1 API:

### Option 1: Dùng Google Auth Library (Recommended - dễ hơn)

Cần cài đặt thêm package:

```bash
cd API_WEB
composer require google/auth
composer require google/cloud-core
```

### Option 2: Manual JWT Signing (Không cần thêm package)

Sử dụng JWT library có sẵn trong project để tự sign JWT token.

---

## 🚀 IMPLEMENTATION

Tôi sẽ tạo phiên bản HTTP V1 API cho `fcm_push_service.php` sử dụng manual JWT signing (không cần composer packages mới).

