# 📱 Các Bước Tạo Notification Icon Đúng Cách

## 🎯 Vấn đề

Icon nhỏ (ô vuông xám) vẫn không hiển thị logo. Logo lớn đã có nhưng icon nhỏ vẫn là hình vuông xám.

## ✅ Giải pháp

Small icon trong Android **PHẢI** là:
- **Kích thước**: 24x24 dp (hoặc 24x24 px cho mdpi)
- **Đơn sắc** (monochrome): Chỉ màu trắng và transparent
- **Format**: PNG với transparent background

## 📋 Các bước chi tiết

### Bước 1: Tạo Notification Icon từ Logo

1. **Mở logo trong image editor** (Photoshop, GIMP, hoặc online tool)

2. **Resize thành 24x24 px** (base size cho mdpi)

3. **Convert thành đơn sắc (monochrome)**:
   - Chỉ giữ lại màu trắng và transparent
   - Xóa tất cả màu khác
   - Hoặc dùng logo trắng trên nền transparent

4. **Export thành PNG** với transparent background

5. **Đặt tên**: `ic_notification.png`

### Bước 2: Copy Icon vào Flutter App

Copy icon vào các thư mục:

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

**Lưu ý**: Ít nhất cần file trong `drawable-mdpi/` để test.

### Bước 3: Update Code

Code đã được set: `icon: '@drawable/logo'`

Nếu tạo `ic_notification.png`, update thành:
```dart
icon: '@drawable/ic_notification',
```

### Bước 4: Rebuild App

```bash
flutter clean
flutter pub get
flutter build apk
```

## ✅ Kết quả

- Icon nhỏ (ô vuông xám) sẽ hiển thị logo thay vì hình vuông xám
- Tương tự như Shopee, Lazada có logo đẹp trong notification

## 🛠️ Tools Online để tạo icon

- **Android Asset Studio**: https://romannurik.github.io/AndroidAssetStudio/icons-notification.html
- Upload logo → Generate notification icon → Download → Copy vào app

## ⚠️ Lưu ý quan trọng

- **Icon PHẢI là đơn sắc** (white + transparent)
- **Kích thước PHẢI là 24x24 px** (cho mdpi)
- **Format PHẢI là PNG** với transparent background
- **Tên file PHẢI không có số** (ic_notification.png, không phải logo.png)

