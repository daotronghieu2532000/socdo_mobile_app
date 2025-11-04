# 📝 Hướng dẫn nhanh: Tạo Notification Icon

## 🎯 Mục tiêu

Tạo notification icon từ logo để hiển thị trong notification (icon nhỏ bên trái).

## 📋 Các bước

### 1. Lấy Logo từ Server
```bash
# Download logo từ server
curl -o logo.png https://socdo.vn/uploads/logo/logo.png
```

### 2. Tạo Notification Icon
Sử dụng image editor (Photoshop, GIMP, hoặc online tool):
- Resize logo thành kích thước 24x24 px (base size)
- Tạo version đơn sắc (monochrome) nếu có thể
- Export thành PNG với transparent background

### 3. Tạo Multiple Sizes
Tạo các sizes cho các density khác nhau:
- **mdpi** (1x): 24x24 px → `drawable-mdpi/ic_notification.png`
- **hdpi** (1.5x): 36x36 px → `drawable-hdpi/ic_notification.png`
- **xhdpi** (2x): 48x48 px → `drawable-xhdpi/ic_notification.png`
- **xxhdpi** (3x): 72x72 px → `drawable-xxhdpi/ic_notification.png`
- **xxxhdpi** (4x): 96x96 px → `drawable-xxxhdpi/ic_notification.png`

### 4. Đặt Icon vào Flutter App
```
android/app/src/main/res/
├── drawable-mdpi/
│   └── ic_notification.png (24x24 px)
├── drawable-hdpi/
│   └── ic_notification.png (36x36 px)
├── drawable-xhdpi/
│   └── ic_notification.png (48x48 px)
├── drawable-xxhdpi/
│   └── ic_notification.png (72x72 px)
└── drawable-xxxhdpi/
    └── ic_notification.png (96x96 px)
```

## ✅ Code đã được cập nhật

Code đã được cập nhật để dùng custom icon:
- ✅ `local_notification_service.dart` - Đã set `@drawable/ic_notification`

## 🚀 Sau khi tạo icon

1. Rebuild app: `flutter clean && flutter pub get && flutter build apk`
2. Install app mới
3. Test notification - icon sẽ hiển thị logo

## 📝 Lưu ý

- Icon phải tồn tại trong `res/drawable-*/` hoặc app sẽ crash
- Icon nên là đơn sắc (monochrome) để hiển thị tốt
- Nếu không có icon, Android sẽ fallback về default icon

