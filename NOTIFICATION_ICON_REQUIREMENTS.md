# ⚠️ YÊU CẦU BẮT BUỘC: Notification Icon

## 🎯 Vấn đề hiện tại

Icon nhỏ (ô vuông xám) vẫn chưa hiển thị logo.

## ⚠️ Yêu cầu BẮT BUỘC cho Android Notification Icon

### 1. **Kích thước**
- **mdpi**: 24x24 px (bắt buộc)
- **hdpi**: 36x36 px (optional)
- **xhdpi**: 48x48 px (optional)
- **xxhdpi**: 72x72 px (optional)
- **xxxhdpi**: 96x96 px (optional)

### 2. **Format**
- **File**: PNG với transparent background
- **Tên**: `ic_notification.png` (không phải `logo.png`)
- **Vị trí**: `android/app/src/main/res/drawable-mdpi/ic_notification.png`

### 3. **Màu sắc**
- **PHẢI là đơn sắc** (monochrome):
  - Chỉ màu TRẮNG và transparent
  - KHÔNG có màu khác
- Android sẽ tự động convert màu thành đơn sắc nếu icon có màu

### 4. **Kích thước file**
- File icon PHẢI là 24x24 px (cho mdpi)
- Android sẽ scale nếu lớn hơn nhưng có thể hiển thị không đẹp

## ✅ Giải pháp nhanh nhất

### Dùng Android Asset Studio (Khuyên dùng)

1. **Mở**: https://romannurik.github.io/AndroidAssetStudio/icons-notification.html
2. **Upload logo** của bạn (bất kỳ kích thước nào)
3. **Click "Generate"**
4. **Download zip** file
5. **Giải nén** và copy `ic_notification.png` vào:
   ```
   android/app/src/main/res/drawable-mdpi/ic_notification.png
   ```

**Done!** Icon sẽ tự động được resize và convert thành đơn sắc.

## 📋 Code đã được cập nhật

Code đã set: `icon: '@drawable/ic_notification'`

## 🚀 Sau khi tạo icon

1. Rebuild app: `flutter clean && flutter pub get && flutter build apk`
2. Install app mới
3. Test notification - icon nhỏ sẽ hiển thị logo ✅

## ⚠️ Lưu ý

- **Logo hiện tại** (`logo.png`) có thể quá lớn hoặc có màu → không phù hợp
- **CẦN TẠO** `ic_notification.png` mới với đúng yêu cầu
- **Ít nhất** cần file trong `drawable-mdpi/` để test

