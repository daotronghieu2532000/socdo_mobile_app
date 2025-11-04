# ⚡ Fix Nhanh: Icon Vẫn Có Nền Xám

## 🎯 Vấn đề

File `ic_notification.png` đã có nhưng vẫn hiển thị hình vuông xám.

## ❌ Nguyên nhân

**Icon có nền màu xám** → Android không thể hiển thị đúng.

## ✅ Giải pháp nhanh nhất

### Dùng Android Asset Studio (Khuyên dùng) ⭐

1. **Mở**: https://romannurik.github.io/AndroidAssetStudio/icons-notification.html
2. **Upload logo** của bạn (`https://socdo.vn/uploads/logo/logo.png`)
3. **Click "Generate"**
4. **Download zip** và giải nén
5. **Copy `ic_notification.png`** vào:
   ```
   android/app/src/main/res/drawable-mdpi/ic_notification.png
   ```
   (Thay thế file hiện tại)

6. **Rebuild app**:
   ```bash
   flutter clean
   flutter pub get
   flutter build apk
   ```

**Done!** Icon sẽ có transparent background và hiển thị đúng ✅

## ⚠️ Lưu ý

- File icon hiện tại **có nền màu xám** → cần thay thế bằng icon có **transparent background**
- Android Asset Studio tự động tạo icon đúng chuẩn ✅

