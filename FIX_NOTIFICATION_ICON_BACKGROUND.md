# 🔧 Fix: Notification Icon Vẫn Có Nền Xám

## 🎯 Vấn đề

Icon `ic_notification.png` đã có (24x24px) nhưng vẫn hiển thị hình vuông xám.

## ❌ Nguyên nhân

**Icon có nền màu xám** thay vì transparent background.

Android notification icon **PHẢI** có:
- ✅ **Transparent background** (không có nền màu xám)
- ✅ **Monochrome** (chỉ màu trắng + transparent)
- ✅ **24x24 px**

## ✅ Giải pháp

### Cách 1: Dùng Android Asset Studio (Khuyên dùng) ⭐

1. **Mở**: https://romannurik.github.io/AndroidAssetStudio/icons-notification.html
2. **Upload logo** của bạn
3. **Click "Generate"**
4. **Download zip** file
5. **Giải nén** → tìm `ic_notification.png`
6. **Copy và thay thế** file hiện tại:
   ```
   android/app/src/main/res/drawable-mdpi/ic_notification.png
   ```

**Ưu điểm**: Tự động tạo icon với transparent background và monochrome ✅

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

1. **Rebuild app**:
   ```bash
   flutter clean
   flutter pub get
   flutter build apk
   ```
2. **Install app mới**
3. **Test notification** → Icon sẽ hiển thị logo (không có nền xám) ✅

## ⚠️ Lưu ý QUAN TRỌNG

- **Background PHẢI transparent** (KHÔNG được có nền màu xám)
- **Icon PHẢI là monochrome** (chỉ màu trắng + transparent)
- **Kích thước**: 24x24 px
- **Tên file**: `ic_notification.png` (không có dấu gạch ngang)

## 🔍 Kiểm tra

Sau khi sửa, mở file `ic_notification.png` trong image editor:
- Nền phải **transparent** (không có màu xám)
- Logo phải **màu trắng**
- Không có màu khác

## ✅ Kết quả mong đợi

- Icon nhỏ (ô vuông xám) → sẽ hiển thị logo màu trắng trên nền transparent
- Logo lớn → vẫn hiển thị bình thường
- Notification đẹp như Shopee, Lazada ✅

