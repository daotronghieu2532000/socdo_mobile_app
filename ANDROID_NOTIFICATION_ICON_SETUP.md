# 📱 Hướng dẫn: Tạo Notification Icon cho Android

## 🎯 Mục tiêu

Tạo notification icon (icon nhỏ bên trái) hiển thị logo thay vì icon mặc định (hình vuông xám).

## 📋 Bước 1: Tạo Notification Icon từ Logo

### 1.1 Download Logo từ Server
- URL: `https://socdo.vn/uploads/logo/logo.png`
- Server path: `/home/socdo.vn/public_html/uploads/logo/logo.png`

### 1.2 Tạo Notification Icon
1. Mở logo trong image editor
2. Tạo version đơn sắc (monochrome) hoặc giữ nguyên màu
3. Resize thành các kích thước:
   - **mdpi**: 24x24 px
   - **hdpi**: 36x36 px
   - **xhdpi**: 48x48 px
   - **xxhdpi**: 72x72 px
   - **xxxhdpi**: 96x96 px

### 1.3 Đặt Icon vào Flutter App
Tạo file: `android/app/src/main/res/drawable-mdpi/ic_notification.png`
Tạo file: `android/app/src/main/res/drawable-hdpi/ic_notification.png`
Tạo file: `android/app/src/main/res/drawable-xhdpi/ic_notification.png`
Tạo file: `android/app/src/main/res/drawable-xxhdpi/ic_notification.png`
Tạo file: `android/app/src/main/res/drawable-xxxhdpi/ic_notification.png`

## 📝 Bước 2: Code đã được cập nhật

Code đã được cập nhật trong:
- `lib/src/core/services/local_notification_service.dart`

```dart
// AndroidInitializationSettings
const androidSettings = AndroidInitializationSettings('@drawable/ic_notification');

// AndroidNotificationDetails
icon: '@drawable/ic_notification', // Custom notification icon (logo)
```

## ✅ Kết quả

Sau khi tạo icon resource:
- Icon nhỏ trong notification sẽ hiển thị logo thay vì icon mặc định
- Tương tự như Shopee, Lazada có logo đẹp trong notification

## 🔧 Nếu chưa có icon resource

Nếu icon `@drawable/ic_notification` chưa tồn tại:
- Android sẽ fallback về default icon
- Cần tạo icon resource như hướng dẫn ở trên

## 📝 Lưu ý

- **Icon phải là resource trong app** (không thể dùng URL)
- **Icon nên là đơn sắc** (monochrome) để hiển thị tốt trên các nền khác nhau
- **Kích thước**: 24dp (nhưng cần nhiều sizes cho các density)

## 🚀 Next Steps

1. Download logo từ server
2. Tạo notification icon từ logo (resize thành các sizes)
3. Đặt icon vào `android/app/src/main/res/drawable-*/ic_notification.png`
4. Rebuild app
5. Test notification - icon sẽ hiển thị logo

