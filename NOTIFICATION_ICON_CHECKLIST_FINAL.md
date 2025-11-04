# ✅ Checklist: ic_notification.png và Debug

## ❓ Câu hỏi

1. **Có cần sửa ảnh `ic_notification.png` nữa không?**
2. **Có báo lỗi nữa không?**
3. **Debug như thế nào?**

## ✅ Trả lời

### 1. **Có cần sửa ảnh `ic_notification.png` nữa không?**

**CÓ** - Nếu icon vẫn hiển thị **nền xám** thay vì transparent:

- ✅ **Icon PHẢI có transparent background** (không có nền màu xám)
- ✅ **Icon PHẢI là monochrome** (chỉ màu trắng + transparent)
- ✅ **Kích thước**: 24x24 px

**Nếu icon đã đúng** (transparent background, monochrome):
- ✅ **KHÔNG cần sửa** nữa
- ✅ Icon sẽ được **tint với màu đỏ** từ `color` property
- ✅ Hiển thị đẹp như Shopee/YouTube

**Cách kiểm tra**:
1. Mở `ic_notification.png` trong image editor
2. Kiểm tra:
   - ✅ Nền phải **transparent** (không có màu xám)
   - ✅ Logo phải **màu trắng**
   - ✅ Không có màu khác

**Nếu có nền xám**:
- Dùng Android Asset Studio: https://romannurik.github.io/AndroidAssetStudio/icons-notification.html
- Upload logo → Generate → Download → Copy `ic_notification.png` mới

### 2. **Có báo lỗi nữa không?**

**KHÔNG** - Code đã có try-catch và debug logging:

- ✅ **Try-catch** để bắt lỗi khi show notification
- ✅ **Debug logging** chi tiết để xem lỗi gì
- ✅ **Stack trace** để debug lỗi

**Nếu có lỗi**:
- Sẽ hiển thị trong console/log
- Format: `❌ [NOTIFICATION_DEBUG] ERROR: ...`

### 3. **Debug như thế nào?**

#### A. Xem Log trong Flutter Console

Khi đặt hàng, xem log:

```
🔔 [NOTIFICATION_DEBUG] Starting showNotification
🔔 [NOTIFICATION_DEBUG] id=1, title=..., body=...
🔔 [NOTIFICATION_DEBUG] Icon: @drawable/ic_notification
🔔 [NOTIFICATION_DEBUG] Color: ffffdc143c (Red for tinting)
🔔 [NOTIFICATION_DEBUG] Logo path: /path/to/logo.png
🔔 [NOTIFICATION_DEBUG] Showing notification...
✅ [NOTIFICATION_DEBUG] Notification shown successfully
```

**Nếu có lỗi**:
```
❌ [NOTIFICATION_DEBUG] ERROR showing notification: ...
❌ [NOTIFICATION_DEBUG] Stack trace: ...
```

#### B. Kiểm tra Icon Resource

**Nếu icon resource không tồn tại**:
- Android sẽ **fallback về default icon** (hình vuông xám)
- Notification vẫn hoạt động, nhưng icon không đẹp
- Log sẽ hiển thị: `⚠️ [NOTIFICATION_DEBUG] If icon resource missing, Android will use default icon`

#### C. Test Notification

1. **Rebuild app**:
   ```bash
   flutter clean
   flutter pub get
   flutter build apk
   ```
2. **Install app mới**
3. **Đặt hàng** để test notification
4. **Xem log** trong Flutter console hoặc `adb logcat`

## 📋 Checklist Test

### ✅ Trước khi test:

- [ ] Icon `ic_notification.png` có transparent background (không có nền xám)
- [ ] Icon là monochrome (chỉ màu trắng + transparent)
- [ ] Kích thước: 24x24 px
- [ ] File nằm tại: `android/app/src/main/res/drawable-mdpi/ic_notification.png`
- [ ] Code đã rebuild

### ✅ Khi test:

1. **Đặt hàng** → Xem log:
   ```
   🔔 [NOTIFICATION_DEBUG] Starting showNotification
   🔔 [NOTIFICATION_DEBUG] Icon: @drawable/ic_notification
   🔔 [NOTIFICATION_DEBUG] Color: ffffdc143c (Red for tinting)
   ✅ [NOTIFICATION_DEBUG] Notification shown successfully
   ```

2. **Kiểm tra notification trên điện thoại**:
   - ✅ Icon nhỏ có màu đỏ (tint từ color property)
   - ✅ Logo lớn hiển thị bên phải
   - ✅ Không có lỗi

### ✅ Nếu có vấn đề:

#### Vấn đề 1: Icon vẫn là hình vuông xám
- **Nguyên nhân**: Icon có nền màu xám (không transparent)
- **Giải pháp**: Tạo icon mới với Android Asset Studio (transparent background)

#### Vấn đề 2: Icon không có màu đỏ
- **Nguyên nhân**: Icon resource không tồn tại hoặc Android không tint được
- **Giải pháp**: Kiểm tra log xem icon resource có tồn tại không

#### Vấn đề 3: Notification không hiển thị
- **Nguyên nhân**: Lỗi khi show notification
- **Giải pháp**: Xem log `❌ [NOTIFICATION_DEBUG] ERROR: ...`

## ✅ Kết quả mong đợi

Sau khi test:
- ✅ Icon nhỏ có màu đỏ (tint từ color property)
- ✅ Logo lớn hiển thị bên phải
- ✅ Notification đẹp như Shopee/YouTube
- ✅ Không có lỗi trong log

## 🚀 Sau khi đặt hàng test

Nếu vẫn có vấn đề:
1. **Copy log** từ console
2. **Chụp ảnh** notification trên điện thoại
3. **Gửi cho tôi** để debug tiếp

