# 🐛 Bug Fix: Notification không gửi được sau khi thêm logo

## ❌ Vấn đề
Sau khi thêm logo vào notification, push notification không còn gửi được nữa.

## 🔍 Nguyên nhân
Trong log `debug_push_notifications.log`, thấy lỗi:
```
FCM API Error: HTTP 400 - {
  "error": {
    "code": 400,
    "message": "Value for APS key [mutable-content] is either 0 or 1.",
    "status": "INVALID_ARGUMENT",
    "field": "message.apns.payload.aps.mutable-content",
    "description": "Value for APS key [mutable-content] is either 0 or 1."
  }
}
```

**Vấn đề**: `mutable-content` được set là boolean `true`, nhưng FCM yêu cầu phải là số `0` hoặc `1`.

## ✅ Giải pháp
Đã sửa trong `API_WEB/fcm_push_service_v1.php`:
```php
// TRƯỚC (SAI):
'mutable-content' => true

// SAU (ĐÚNG):
'mutable-content' => 1
```

## 📝 Lưu ý
- APNS payload chỉ chấp nhận số nguyên `0` hoặc `1` cho boolean fields
- Không được dùng `true`/`false` trong PHP array khi encode JSON cho FCM APNS

## ✅ Đã sửa
- File: `API_WEB/fcm_push_service_v1.php` line 228
- Thay đổi: `mutable-content` từ `true` → `1`

## 🧪 Test lại
1. Tạo đơn hàng mới
2. Kiểm tra log: `debug_push_notifications.log` phải thấy `success => 1`
3. Notification phải đến điện thoại

