# 🔧 Fix: Icon Vẫn Có Nền Xám

## ❌ Vấn đề

File `ic_notification.png` đã có (24x24px) nhưng vẫn hiển thị **ô vuông xám**.

## 🎯 Nguyên nhân

**Icon có nền màu xám** (không transparent) → Android không thể hiển thị đúng.

Android notification icon **PHẢI** có:
- ✅ **Transparent background** (KHÔNG có nền màu xám)
- ✅ **Monochrome** (chỉ màu trắng + transparent)
- ✅ **24x24 px**

## ✅ Giải pháp

### Cách nhanh nhất: Dùng Android Asset Studio ⭐

1. **Mở**: https://romannurik.github.io/AndroidAssetStudio/icons-notification.html
2. **Upload logo** của bạn (`https://socdo.vn/uploads/logo/logo.png`)
3. **Click "Generate"**
4. **Download zip** và giải nén
5. **Tìm file** `ic_notification.png` trong folder `drawable-mdpi/`
6. **Thay thế file hiện tại**:
   ```
   android/app/src/main/res/drawable-mdpi/ic_notification.png
   ```

**Ưu điểm**: Tự động tạo icon với:
- ✅ Transparent background
- ✅ Monochrome (chỉ màu trắng + transparent)
- ✅ Đúng kích thước (24x24px)

### Cách 2: Sửa file hiện tại

1. **Mở** `ic_notification.png` trong image editor (Photoshop/GIMP)
2. **Xóa nền màu xám**:
   - Dùng Magic Wand tool để chọn nền xám
   - Delete nền xám
   - Để transparent
3. **Convert thành đơn sắc**:
   - Chỉ giữ màu trắng
   - Xóa tất cả màu khác
4. **Export** với transparent background
5. **Save** lại file

## 📋 Sau khi sửa

1. **Clean và rebuild app**:
   ```bash
   cd C:\laragon\www\socdo_mobile
   flutter clean
   flutter pub get
   flutter build apk
   ```
2. **Uninstall app cũ** trên điện thoại
3. **Install app mới**
4. **Test notification** → Icon sẽ hiển thị logo (không có nền xám) ✅

## ⚠️ Lưu ý QUAN TRỌNG

- **Background PHẢI transparent** (KHÔNG được có nền màu xám)
- **Icon PHẢI là monochrome** (chỉ màu trắng + transparent)
- **Kích thước**: 24x24 px
- **Tên file**: `ic_notification.png` (không có dấu gạch ngang)

## 🔍 Kiểm tra icon

Sau khi tạo/sửa, mở file `ic_notification.png` trong image editor:
- ✅ Nền phải **transparent** (không có màu xám)
- ✅ Logo phải **màu trắng**
- ✅ Không có màu khác

## ✅ Kết quả mong đợi

- Icon nhỏ (ô vuông xám) → sẽ hiển thị logo màu trắng trên nền transparent ✅
- Logo lớn → vẫn hiển thị bình thường
- Notification đẹp như Shopee, Lazada ✅

