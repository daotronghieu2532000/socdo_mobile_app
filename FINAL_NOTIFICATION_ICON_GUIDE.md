# ✅ Hướng dẫn cuối cùng: Tạo Notification Icon

## ✅ Xác nhận

Bạn đã hiểu đúng:
- **Kích thước**: 24x24 px
- **Tên file**: `ic_notification.png` (KHÔNG có dấu gạch ngang)
- **Format**: PNG với transparent background

## 🎯 Yêu cầu CHI TIẾT

### 1. Kích thước
- **mdpi**: 24x24 px (bắt buộc)
- Optional: 36x36px (hdpi), 48x48px (xhdpi), 72x72px (xxhdpi), 96x96px (xxxhdpi)

### 2. Format
- **File**: PNG
- **Background**: **Transparent** (KHÔNG có nền màu xám)
- **Tên**: `ic_notification.png` (KHÔNG có dấu gạch ngang `-`)

### 3. Màu sắc
- **Đơn sắc** (monochrome):
  - Chỉ màu **TRẮNG** và **transparent**
  - KHÔNG có màu khác
  - KHÔNG có nền màu xám

### 4. Vị trí
```
android/app/src/main/res/drawable-mdpi/ic_notification.png
```

## 🛠️ Cách làm

### Bước 1: Tạo Icon

#### Cách 1: Android Asset Studio (Khuyên dùng) ⭐

1. Mở: **https://romannurik.github.io/AndroidAssetStudio/icons-notification.html**
2. Click "Upload image"
3. Chọn logo của bạn
4. Click "Generate"
5. Download zip file
6. Giải nén → tìm `ic_notification.png`

**Ưu điểm**: Tự động resize và convert thành đơn sắc + transparent background

#### Cách 2: Tạo thủ công

1. Download logo: `https://socdo.vn/uploads/logo/logo.png`
2. Mở trong image editor (Photoshop/GIMP/Canva)
3. **Resize**: 24x24 px
4. **Xóa nền**: Xóa nền màu xám → chỉ transparent
5. **Convert đơn sắc**: Chỉ giữ màu trắng, xóa tất cả màu khác
6. **Export**: PNG với transparent background
7. **Đặt tên**: `ic_notification.png`

### Bước 2: Copy vào App

Copy `ic_notification.png` vào:
```
android/app/src/main/res/drawable-mdpi/ic_notification.png
```

**Lưu ý**: 
- File PHẢI có tên `ic_notification.png` (không phải `logo.png`, `logo-removebg.png`, v.v.)
- KHÔNG được có dấu gạch ngang `-` trong tên file

### Bước 3: Rebuild App

```bash
cd C:\laragon\www\socdo_mobile
flutter clean
flutter pub get
flutter build apk
```

## ✅ Code đã sẵn sàng

Code đã set: `icon: '@drawable/ic_notification'`

Sau khi tạo file → Rebuild app → Icon sẽ hiển thị logo ✅

## 🎯 Kết quả mong đợi

- ✅ Icon nhỏ (ô vuông xám) → sẽ hiển thị logo
- ✅ Logo lớn → vẫn hiển thị bình thường
- ✅ Notification đẹp như Shopee, Lazada

## ⚠️ Lưu ý

- **Tên file**: `ic_notification.png` - KHÔNG có dấu gạch ngang
- **Nền transparent**: PHẢI xóa nền màu xám
- **Kích thước**: 24x24 px - đúng size
- **Màu sắc**: Chỉ màu trắng + transparent

