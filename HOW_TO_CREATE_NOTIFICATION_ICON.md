# 📱 Cách Tạo Notification Icon Đúng Cách - BẮT BUỘC

## 🎯 Vấn đề

Icon nhỏ (ô vuông xám) vẫn chưa hiển thị logo. Logo lớn đã có nhưng icon nhỏ vẫn là hình vuông xám.

## ⚠️ Lý do

Logo hiện tại (`logo.png`) có thể:
- **Quá lớn** (không phải 24x24 px)
- **Có màu** (không phải đơn sắc)
- **Không phù hợp** cho Android notification icon

## ✅ Giải pháp BẮT BUỘC

### Small Icon trong Android PHẢI:
- **Kích thước**: 24x24 px (cho mdpi)
- **Đơn sắc**: Chỉ màu TRẮNG và transparent (không có màu khác)
- **Format**: PNG với transparent background
- **Tên file**: `ic_notification.png` (không phải `logo.png`)

## 📋 Các bước chi tiết

### Bước 1: Download Logo từ Server

```bash
# Download logo
curl -o logo.png https://socdo.vn/uploads/logo/logo.png
```

Hoặc lấy từ: `lib/src/core/assets/images/logo.png`

### Bước 2: Tạo Notification Icon

#### Cách 1: Dùng Android Asset Studio (Dễ nhất) ⭐

1. Mở: https://romannurik.github.io/AndroidAssetStudio/icons-notification.html
2. Upload logo của bạn
3. Click "Generate"
4. Download zip file
5. Giải nén và copy `ic_notification.png` vào:
   ```
   android/app/src/main/res/
   ├── drawable-mdpi/ic_notification.png (24x24 px)
   ├── drawable-hdpi/ic_notification.png (36x36 px)
   ├── drawable-xhdpi/ic_notification.png (48x48 px)
   ├── drawable-xxhdpi/ic_notification.png (72x72 px)
   └── drawable-xxxhdpi/ic_notification.png (96x96 px)
   ```

#### Cách 2: Dùng Image Editor (Photoshop/GIMP)

1. Mở logo trong image editor
2. **Resize thành 24x24 px** (mdpi)
3. **Convert thành đơn sắc**:
   - Chỉ giữ lại màu TRẮNG
   - Xóa tất cả màu khác
   - Hoặc dùng logo trắng trên nền transparent
4. **Export thành PNG** với transparent background
5. **Đặt tên**: `ic_notification.png`

### Bước 3: Copy Icon vào Flutter App

Copy `ic_notification.png` vào:
```
android/app/src/main/res/drawable-mdpi/ic_notification.png (24x24 px)
```

**Lưu ý**: Ít nhất cần file trong `drawable-mdpi/` để test.

### Bước 4: Update Code

Code hiện tại đang dùng: `icon: '@drawable/logo'`

Update thành:
```dart
icon: '@drawable/ic_notification',
```

### Bước 5: Rebuild App

```bash
flutter clean
flutter pub get
flutter build apk
```

## ✅ Kết quả

- **Icon nhỏ** (ô vuông xám) sẽ hiển thị logo thay vì hình vuông xám
- **Logo lớn** vẫn hiển thị bình thường
- Tương tự như Shopee, Lazada có logo đẹp trong notification

## 🛠️ Tool Online (Khuyên dùng)

**Android Asset Studio**: https://romannurik.github.io/AndroidAssetStudio/icons-notification.html

- Upload logo → Tự động generate đúng size và format
- Download → Copy vào app → Done!

## ⚠️ Lưu ý QUAN TRỌNG

1. **Icon PHẢI là đơn sắc** (white + transparent)
2. **Kích thước PHẢI là 24x24 px** (cho mdpi)
3. **Tên file PHẢI là `ic_notification.png`** (không phải `logo.png`)
4. **Format PHẢI là PNG** với transparent background

## 🚀 Sau khi tạo icon

1. Icon nhỏ sẽ hiển thị logo thay vì hình vuông xám ✅
2. Logo lớn vẫn hiển thị bình thường ✅
3. Notification sẽ đẹp như Shopee, Lazada ✅

