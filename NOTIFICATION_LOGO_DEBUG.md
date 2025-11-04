# 🔍 Debug: Logo trong Android Notification

## ⚠️ Lưu ý quan trọng

### Icon nhỏ (bên trái) vs Large Image

Trong Android notification có 2 loại image:

1. **Icon nhỏ (bên trái)**: 
   - Luôn dùng app icon từ `AndroidManifest.xml` (`@mipmap/ic_launcher`)
   - **KHÔNG THỂ** thay đổi bằng URL từ server
   - Đây là giới hạn của Android - icon phải là resource trong app

2. **Large Image**:
   - Hiển thị logo từ URL (`android.notification.image`)
   - **CHỈ hiển thị** khi notification được **expand** (kéo xuống)
   - Hoặc là Big Picture Style notification

## 📱 Cách xem logo trong notification

### Android
1. Nhận notification
2. **Kéo xuống** (expand notification) → Logo sẽ hiển thị
3. Icon nhỏ vẫn là app icon (không đổi được)

### iOS
- Logo hiển thị qua notification service extension
- Cần cấu hình thêm trong iOS project

## 🔍 Debug Logs đã thêm

### 1. Logo URL Check
```
[LOGO_CHECK] Logo URL accessible: https://socdo.vn/uploads/logo/logo.png (HTTP 200)
```
- Kiểm tra logo URL có accessible không
- Nếu không accessible → FCM không thể download image

### 2. Payload Verification
```
[FCMPushServiceV1] sendToDevice - android.notification.image: https://socdo.vn/uploads/logo/logo.png
[FCMPushServiceV1] sendToDevice - android.notification.channel_id: socdo_channel
```
- Xác nhận image URL và channel_id có được set đúng không

### 3. FCM Response
```
[FCMPushServiceV1] sendToDevice - FCM Response HTTP Code: 200
[FCMPushServiceV1] sendToDevice - Message sent successfully! FCM Message ID: ...
```
- Xác nhận FCM đã nhận và xử lý message

## 🐛 Các vấn đề có thể gặp

### 1. Logo không hiển thị (icon nhỏ)
**Nguyên nhân**: Icon nhỏ không thể thay đổi bằng URL
**Giải pháp**: Phải thay đổi app icon trong Android project

### 2. Logo không hiển thị (large image)
**Nguyên nhân**:
- Logo URL không accessible
- Notification chưa được expand
- Channel ID không match

**Kiểm tra**:
- Xem log `[LOGO_CHECK]` - Logo URL có accessible không?
- Thử expand notification (kéo xuống)
- Kiểm tra channel_id có match với Flutter app không

### 3. Logo hiển thị nhưng không đúng
**Nguyên nhân**: Logo URL trỏ đến file sai hoặc format không đúng
**Giải pháp**: Kiểm tra file `/home/socdo.vn/public_html/uploads/logo/logo.png`

## ✅ Checklist

- [ ] Logo URL accessible (check log `[LOGO_CHECK]`)
- [ ] Image URL được set trong payload (check log `android.notification.image`)
- [ ] Channel ID match với Flutter app (`socdo_channel`)
- [ ] FCM response thành công (HTTP 200, có `name` field)
- [ ] Đã thử expand notification trên Android

## 📝 Next Steps

1. Tạo đơn hàng mới
2. Xem debug log để kiểm tra:
   - Logo URL có accessible không
   - Payload có đúng không
   - FCM response có thành công không
3. Trên Android: Expand notification để xem large image

