# ✅ Fix Notification Logo - Giải pháp cuối cùng

## 🎯 Vấn đề

Notification icon đang hiển thị hình vuông xám thay vì logo.

## ✅ Giải pháp đã implement

### 1. **Dùng logo.png có sẵn**
- Logo đã có trong: `android/app/src/main/res/drawable-mdpi/logo.png`
- Set small icon: `@drawable/logo`
- Set initialization: `@drawable/logo`

### 2. **Download logo từ URL cho largeIcon**
- Download logo từ `https://socdo.vn/uploads/logo/logo.png`
- Cache trong 24h để tránh download nhiều lần
- Dùng làm `largeIcon` (hiển thị logo lớn trong notification)

## 📋 Code đã được cập nhật

### `local_notification_service.dart`

```dart
// Small icon - dùng logo.png có sẵn
const androidSettings = AndroidInitializationSettings('@drawable/logo');

// Trong showNotification:
final androidDetails = AndroidNotificationDetails(
  'socdo_channel',
  'Socdo Notifications',
  channelDescription: 'Thông báo từ ứng dụng Socdo',
  importance: Importance.high,
  priority: Priority.high,
  showWhen: true,
  icon: '@drawable/logo', // Small icon - logo.png có sẵn
  largeIcon: logoPath != null ? FilePathAndroidBitmap(logoPath) : null, // Large icon từ URL
);
```

## ⚠️ Vấn đề có thể xảy ra

### Nếu logo.png quá lớn
- Android small icon nên là **24x24 px** (monochrome)
- Logo hiện tại có thể quá lớn → Android sẽ scale nhưng có thể hiển thị không đẹp

### Nếu logo.png có màu
- Android small icon nên là đơn sắc (monochrome)
- Logo có màu vẫn hoạt động nhưng Android có thể convert thành đơn sắc

## ✅ Kết quả

- **Small icon** (bên trái): Sẽ dùng logo.png thay vì hình vuông xám
- **Large icon** (bên phải): Logo download từ URL (nếu thành công)
- **Large image**: Logo từ FCM payload khi expand notification

## 🚀 Test

1. Rebuild app: `flutter clean && flutter pub get && flutter build apk`
2. Install app mới
3. Tạo đơn hàng mới
4. Kiểm tra notification - icon sẽ hiển thị logo thay vì hình vuông xám

## 📝 Nếu vẫn không hiển thị logo

Nếu logo.png quá lớn hoặc có vấn đề, tạo notification icon mới:
1. Resize logo thành **24x24 px**
2. Tạo version đơn sắc (nếu có thể)
3. Đặt vào `android/app/src/main/res/drawable-mdpi/ic_notification.png`
4. Update code: `icon: '@drawable/ic_notification'`

