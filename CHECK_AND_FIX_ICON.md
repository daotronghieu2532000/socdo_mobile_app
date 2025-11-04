# ✅ Checklist: Kiểm tra và Sửa Notification Icon

## 📋 File đã có

File `ic_notification.png` đã tồn tại tại:
```
android/app/src/main/res/drawable-mdpi/ic_notification.png
```

## ✅ Kiểm tra file hiện tại

### 1. Kiểm tra kích thước
- **Phải là**: 24x24 px (cho mdpi)
- **Nếu lớn hơn**: Android sẽ scale nhưng có thể không đẹp

### 2. Kiểm tra background
- **Phải là**: Transparent (trong suốt)
- **Nếu có nền xám**: Cần xóa → để transparent

### 3. Kiểm tra màu sắc
- **Phải là**: Đơn sắc - chỉ màu **TRẮNG** và transparent
- **Nếu có màu khác**: Cần convert thành đơn sắc

### 4. Kiểm tra tên file
- **Phải là**: `ic_notification.png` (không có dấu gạch ngang)
- ✅ Đã đúng

## 🛠️ Nếu icon vẫn hiển thị nền xám

### Cách sửa nhanh nhất:

1. **Dùng Android Asset Studio**:
   - Mở: https://romannurik.github.io/AndroidAssetStudio/icons-notification.html
   - Upload logo của bạn
   - Click "Generate"
   - Download và copy `ic_notification.png` mới vào app

2. **Hoặc sửa file hiện tại**:
   - Mở `ic_notification.png` trong image editor
   - Xóa nền màu xám → để transparent
   - Save lại

## ✅ Sau khi sửa

1. Rebuild app: `flutter clean && flutter pub get && flutter build apk`
2. Test notification
3. Icon nhỏ sẽ hiển thị logo (không có nền xám) ✅

## 📝 Lưu ý

- File `ic_notification.png` đã có nhưng cần kiểm tra:
  - ✅ Kích thước: 24x24 px
  - ✅ Background: Transparent (không có nền xám)
  - ✅ Màu sắc: Chỉ màu trắng + transparent
  - ✅ Tên file: `ic_notification.png` (không có dấu gạch ngang)

