# ✅ Checklist: Tạo Notification Icon

## 🎯 Yêu cầu BẮT BUỘC

- ✅ **Tên file**: `ic_notification.png` (KHÔNG có dấu gạch ngang `-`)
- ✅ **Kích thước**: 24x24 px (cho mdpi)
- ✅ **Format**: PNG với **transparent background** (KHÔNG có nền màu xám)
- ✅ **Màu sắc**: **Đơn sắc** (monochrome) - chỉ màu **TRẮNG** và **transparent**
- ✅ **Vị trí**: `android/app/src/main/res/drawable-mdpi/ic_notification.png`

## 📋 Các bước

### Bước 1: Tạo Icon

#### Cách nhanh nhất (Khuyên dùng) ⭐
1. Mở: **https://romannurik.github.io/AndroidAssetStudio/icons-notification.html**
2. Upload logo của bạn
3. Click "Generate"
4. Download zip file
5. Giải nén và tìm `ic_notification.png`

#### Cách thủ công
1. Download logo từ: `https://socdo.vn/uploads/logo/logo.png`
2. Mở trong image editor (Photoshop/GIMP)
3. **Resize thành 24x24 px**
4. **Xóa nền màu xám** → đảm bảo nền **transparent**
5. **Convert thành đơn sắc** - chỉ giữ màu trắng, xóa tất cả màu khác
6. **Export thành PNG** với transparent background
7. **Đặt tên**: `ic_notification.png` (KHÔNG có dấu gạch ngang)

### Bước 2: Copy vào App

Copy `ic_notification.png` vào:
```
android/app/src/main/res/drawable-mdpi/ic_notification.png
```

**Lưu ý**: 
- Tên file PHẢI là `ic_notification.png` (không phải `logo-removebg-preview.png`)
- KHÔNG được có dấu gạch ngang `-` trong tên file
- Ít nhất cần file trong `drawable-mdpi/`

### Bước 3: Rebuild App

```bash
flutter clean
flutter pub get
flutter build apk
```

## ⚠️ Lưu ý QUAN TRỌNG

1. **Tên file**: `ic_notification.png` - KHÔNG có dấu gạch ngang
2. **Nền transparent**: PHẢI xóa nền màu xám → chỉ transparent
3. **Kích thước**: 24x24 px - đúng size
4. **Màu sắc**: Chỉ màu trắng và transparent - đơn sắc

## ✅ Code đã sẵn sàng

Code đã set: `icon: '@drawable/ic_notification'`

Sau khi tạo file → Rebuild app → Icon sẽ hiển thị logo ✅

