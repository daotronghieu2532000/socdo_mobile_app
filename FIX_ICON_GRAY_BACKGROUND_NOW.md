# 🔧 Fix NGAY: Icon Vẫn Có Nền Xám

## ❌ Vấn đề

File `ic_notification.png` đã có (24x24px) nhưng vẫn hiển thị **ô vuông xám**.

## 🎯 Nguyên nhân

**Icon hiện tại có nền màu xám** (không transparent) → Android không thể hiển thị đúng.

Android notification icon **PHẢI** có:
- ✅ **Transparent background** (KHÔNG có nền màu xám)
- ✅ **Monochrome** (chỉ màu trắng + transparent)
- ✅ **24x24 px**

## ✅ Giải pháp: Tạo Icon Mới

### Bước 1: Tạo Icon Mới với Android Asset Studio ⭐

1. **Mở trình duyệt**: https://romannurik.github.io/AndroidAssetStudio/icons-notification.html
2. **Click "Upload image"**
3. **Chọn logo của bạn**:
   - Download từ: `https://socdo.vn/uploads/logo/logo.png`
   - Hoặc upload logo bất kỳ
4. **Click "Generate"**
5. **Download zip** file
6. **Giải nén zip**
7. **Tìm file** `ic_notification.png` trong folder `res/drawable-mdpi/`
8. **Copy file** `ic_notification.png` mới này

### Bước 2: Thay Thế File Hiện Tại

1. **Xóa file cũ** (nếu cần):
   ```
   android/app/src/main/res/drawable-mdpi/ic_notification.png
   ```
2. **Paste file mới** vào:
   ```
   android/app/src/main/res/drawable-mdpi/ic_notification.png
   ```

**Lưu ý**: File mới từ Android Asset Studio sẽ có:
- ✅ Transparent background (không có nền màu xám)
- ✅ Monochrome (chỉ màu trắng + transparent)
- ✅ Đúng kích thước (24x24px)

### Bước 3: Rebuild App

```bash
cd C:\laragon\www\socdo_mobile
flutter clean
flutter pub get
flutter build apk
```

### Bước 4: Install và Test

1. **Uninstall app cũ** trên điện thoại (quan trọng!)
2. **Install app mới**
3. **Test notification** → Icon sẽ hiển thị logo (không có nền xám) ✅

## ⚠️ Lưu ý QUAN TRỌNG

- **Background PHẢI transparent** (KHÔNG được có nền màu xám)
- **Icon PHẢI là monochrome** (chỉ màu trắng + transparent)
- **PHẢI uninstall app cũ** trước khi install app mới
- **PHẢI rebuild app** sau khi thay thế icon

## ✅ Kết quả mong đợi

- Icon nhỏ (ô vuông xám) → sẽ hiển thị logo màu trắng trên nền transparent ✅
- Logo lớn → vẫn hiển thị bình thường
- Notification đẹp như Shopee, Lazada ✅

## 🎯 Tại sao dùng Android Asset Studio?

- ✅ Tự động tạo icon với transparent background
- ✅ Tự động convert thành monochrome
- ✅ Tự động resize đúng kích thước
- ✅ Đảm bảo đúng chuẩn Android

