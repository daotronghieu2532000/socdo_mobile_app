# 📱 Tạo Notification Icon từ Logo Asset

## 🎯 Vấn đề

Notification icon đang hiển thị hình vuông xám. Cần tạo notification icon resource từ logo.

## ✅ Giải pháp

Logo đã có trong assets: `lib/src/core/assets/images/logo.png`

## 📋 Các bước

### 1. Copy Logo từ Assets sang Android Drawable

Từ logo trong `lib/src/core/assets/images/logo.png`, tạo notification icon:

#### Bước 1.1: Tạo các kích thước icon
- Resize logo thành các sizes:
  - **mdpi**: 24x24 px → `android/app/src/main/res/drawable-mdpi/ic_notification.png`
  - **hdpi**: 36x36 px → `android/app/src/main/res/drawable-hdpi/ic_notification.png`
  - **xhdpi**: 48x48 px → `android/app/src/main/res/drawable-xhdpi/ic_notification.png`
  - **xxhdpi**: 72x72 px → `android/app/src/main/res/drawable-xxhdpi/ic_notification.png`
  - **xxxhdpi**: 96x96 px → `android/app/src/main/res/drawable-xxxhdpi/ic_notification.png`

#### Bước 1.2: Cách nhanh nhất
1. Mở `lib/src/core/assets/images/logo.png` trong image editor
2. Resize thành 24x24 px
3. Save as `android/app/src/main/res/drawable-mdpi/ic_notification.png`
4. (Optional) Tạo thêm các sizes khác cho các density

### 2. Uncomment Code

Sau khi tạo icon resource, uncomment trong `local_notification_service.dart`:

```dart
// AndroidInitializationSettings
const androidSettings = AndroidInitializationSettings('@drawable/ic_notification');

// AndroidNotificationDetails
icon: '@drawable/ic_notification', // Custom notification icon (logo)
```

### 3. Rebuild App

```bash
flutter clean
flutter pub get
flutter build apk
```

## ✅ Kết quả

- Icon nhỏ sẽ hiển thị logo thay vì hình vuông xám
- Tương tự như Shopee, Lazada có logo đẹp

## 📝 Lưu ý

- Icon **PHẢI** tồn tại trong `drawable-*/ic_notification.png`
- Ít nhất cần 1 size (mdpi) để test
- Icon nên là đơn sắc (monochrome) nhưng có thể giữ màu

