# ⚡ Quick Start: Tạo Notification Icon

## 🎯 Vấn đề

Icon nhỏ trong notification đang hiển thị hình vuông xám thay vì logo.

## ✅ Giải pháp

Cần tạo notification icon resource từ logo trong Flutter app.

## 📋 Các bước nhanh

### 1. Download Logo từ Server
```bash
# Logo URL: https://socdo.vn/uploads/logo/logo.png
# Server path: /home/socdo.vn/public_html/uploads/logo/logo.png
```

### 2. Tạo Notification Icon
- Mở logo trong image editor
- Resize thành **24x24 px** (base size)
- Export thành PNG với transparent background
- Tên file: `ic_notification.png`

### 3. Đặt Icon vào Flutter App
```
android/app/src/main/res/
└── drawable-mdpi/
    └── ic_notification.png (24x24 px)
```

**Lưu ý**: Chỉ cần tạo 1 size (mdpi) để test nhanh. Sau đó tạo thêm các sizes khác.

### 4. Rebuild App
```bash
flutter clean
flutter pub get
flutter build apk
# Hoặc flutter run
```

### 5. Test
- Install app mới
- Tạo đơn hàng mới
- Kiểm tra notification - icon sẽ hiển thị logo

## 📝 Tạo Multiple Sizes (Optional)

Để hiển thị tốt trên tất cả thiết bị, tạo các sizes:
- **mdpi** (1x): 24x24 px → `drawable-mdpi/ic_notification.png`
- **hdpi** (1.5x): 36x36 px → `drawable-hdpi/ic_notification.png`
- **xhdpi** (2x): 48x48 px → `drawable-xhdpi/ic_notification.png`
- **xxhdpi** (3x): 72x72 px → `drawable-xxhdpi/ic_notification.png`
- **xxxhdpi** (4x): 96x96 px → `drawable-xxxhdpi/ic_notification.png`

## ⚠️ Lưu ý

- Icon **PHẢI** tồn tại trong `drawable-*/ic_notification.png`
- Nếu không có icon, Android sẽ fallback về default icon
- Icon nên là đơn sắc (monochrome) để hiển thị tốt
- Transparent background để hiển thị đẹp

## ✅ Code đã được cập nhật

- ✅ `local_notification_service.dart` - Đã set `@drawable/ic_notification`

## 🚀 Sau khi tạo icon

1. Icon sẽ hiển thị logo thay vì hình vuông xám
2. Tương tự như Shopee, Lazada có logo đẹp trong notification

