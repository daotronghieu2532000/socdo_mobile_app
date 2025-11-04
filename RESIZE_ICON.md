# 🔧 Fix: Resize ic_notification.png về 24x24px

## ❌ Vấn đề

File `ic_notification.png` hiện tại: **100x100 px** (SAI)

Android notification icon PHẢI: **24x24 px**

## ✅ Giải pháp

### Cách 1: Dùng Android Asset Studio (Khuyên dùng)

1. Mở: https://romannurik.github.io/AndroidAssetStudio/icons-notification.html
2. Upload logo gốc
3. Generate → Download
4. Copy `ic_notification.png` từ `res/drawable-mdpi/` (sẽ tự động 24x24px)
5. Thay thế vào:
   - `android/app/src/main/res/drawable/ic_notification.png`
   - `android/app/src/main/res/drawable-mdpi/ic_notification.png`

### Cách 2: Resize thủ công

1. Mở file `ic_notification.png` trong image editor
2. Resize về **24x24 px**
3. Save lại
4. Thay thế vào cả 2 vị trí

## 📋 Sau khi resize

1. **Clean build:**
   ```bash
   flutter clean
   flutter pub get
   flutter build apk
   ```
2. **Install app mới** (quan trọng!)
3. **Test notification** → Icon sẽ hiển thị đúng

