# 🐛 Fix: Notification không hiển thị do icon không tồn tại

## 🔍 Vấn đề

Sau khi cập nhật code dùng `@drawable/ic_notification`, notification không hiển thị vì icon này chưa tồn tại trong app.

## ✅ Giải pháp tạm thời

Đã revert về `@mipmap/ic_launcher` để notification hoạt động trở lại.

## 📋 Các bước tiếp theo

### 1. Tạo Notification Icon Resource

1. Download logo từ server:
   ```
   https://socdo.vn/uploads/logo/logo.png
   ```

2. Tạo notification icon từ logo:
   - Resize thành 24x24 px (mdpi)
   - Export PNG với transparent background
   - Tên file: `ic_notification.png`

3. Đặt icon vào app:
   ```
   android/app/src/main/res/drawable-mdpi/ic_notification.png
   ```

### 2. Sau khi tạo icon, uncomment trong code:

```dart
// lib/src/core/services/local_notification_service.dart

// AndroidInitializationSettings
const androidSettings = AndroidInitializationSettings('@drawable/ic_notification');

// AndroidNotificationDetails
icon: '@drawable/ic_notification', // Custom notification icon (logo)
```

## ✅ Code đã được fix

- ✅ Revert về `@mipmap/ic_launcher` để notification hoạt động ngay
- ✅ Thêm comment hướng dẫn uncomment sau khi tạo icon

## 🚀 Test

1. Rebuild app
2. Test notification - sẽ hiển thị lại với icon mặc định
3. Sau khi tạo icon resource, uncomment code và rebuild

