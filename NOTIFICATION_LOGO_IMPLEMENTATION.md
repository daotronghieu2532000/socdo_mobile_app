# 🎯 Implementation: Thêm Logo vào Push Notification

## ✅ Đã hoàn thành

### 1. **Cập nhật FCM Push Service** (`API_WEB/fcm_push_service_v1.php`)
- ✅ Thêm logo URL: `https://socdo.vn/uploads/logo/logo.png`
- ✅ Thêm `image` vào Android notification config
- ✅ Thêm `fcm_options.image` vào iOS APNS config
- ✅ Thêm `channel_id` để match với Flutter app channel
- ✅ Thêm debug logging để kiểm tra logo URL và payload

### 2. **Cập nhật Local Notification Service** (`lib/src/core/services/local_notification_service.dart`)
- ✅ Đã tối ưu code (bỏ unused import)
- ✅ Logo sẽ được FCM tự động handle từ payload

## 📋 Cấu hình FCM Payload

### Android Notification
```php
'android' => array(
    'priority' => 'high',
    'notification' => array(
        'image' => 'https://socdo.vn/uploads/logo/logo.png', // Large image khi expand
        'channel_id' => 'socdo_channel', // Match với Flutter app
        'sound' => 'default',
        'click_action' => 'FLUTTER_NOTIFICATION_CLICK'
    )
)
```

### iOS Notification
```php
'apns' => array(
    'payload' => array(
        'aps' => array(
            'mutable-content' => 1 // Cần cho notification service extension
        ),
        'fcm_options' => array(
            'image' => 'https://socdo.vn/uploads/logo/logo.png'
        )
    )
)
```

## 🔍 Debug Logging

Logs được ghi vào: `API_WEB/debug_push_notifications.log`

```
[FCMPushServiceV1] sendToDevice - logoUrl: https://socdo.vn/uploads/logo/logo.png
[FCMPushServiceV1] sendToDevice - message payload: {...}
```

## 📱 Cách Logo Hiển Thị

### Android
- **Icon nhỏ (trái)**: Dùng app icon mặc định (`@mipmap/ic_launcher`)
- **Large Image**: Hiển thị logo khi notification được expand (kéo xuống)
- **Big Picture Style**: Logo hiển thị full khi notification expand

### iOS
- **Notification Image**: Hiển thị qua notification service extension (cần cấu hình thêm trong iOS project)
- **Fallback**: Nếu không có extension, vẫn hiển thị notification bình thường

## ✅ Kiểm tra

### 1. Kiểm tra Logo URL có truy cập được không
```bash
curl -I https://socdo.vn/uploads/logo/logo.png
# Response phải là 200 OK
```

### 2. Kiểm tra Log
Xem file `API_WEB/debug_push_notifications.log`:
- Logo URL có được gửi trong payload
- FCM response có success không

### 3. Test trên Device
1. Tạo đơn hàng mới → Trigger tạo notification
2. Xem notification trên Android:
   - Icon nhỏ: App icon
   - Expand notification → Logo hiển thị
3. Xem notification trên iOS (nếu có)

## 🔧 Lưu ý

1. **Logo URL phải public**: Không yêu cầu authentication
2. **Logo format**: PNG, JPG (khuyến nghị PNG với transparent background)
3. **Logo size**: Android recommend 512x512px, iOS recommend 1024x1024px
4. **Channel ID**: Phải match giữa server và Flutter app (`socdo_channel`)

## 🚀 Trigger Flow

1. **Order Created/Updated** → Trigger tự động INSERT vào `notification_mobile`
2. **Shutdown Function** → `sendPushForExistingNotification()` được gọi async
3. **FCM Service** → Build payload với logo URL → Gửi đến FCM
4. **FCM Server** → Gửi push đến device
5. **Device** → Hiển thị notification với logo

## 📝 Files Đã Thay Đổi

- ✅ `API_WEB/fcm_push_service_v1.php` - Thêm logo vào payload
- ✅ `lib/src/core/services/local_notification_service.dart` - Tối ưu code

## 🐛 Troubleshooting

### Logo không hiển thị
1. Kiểm tra logo URL có accessible: `https://socdo.vn/uploads/logo/logo.png`
2. Kiểm tra log xem logo URL có được gửi không
3. Trên Android: Phải expand notification để thấy large image
4. Kiểm tra channel_id có match không

### Notification không đến
1. Kiểm tra device token có active không
2. Kiểm tra FCM response trong log
3. Kiểm tra network connectivity

## 📚 Tài liệu tham khảo

- FCM HTTP V1 API: https://firebase.google.com/docs/cloud-messaging/send-message
- Android Notification Image: https://developer.android.com/training/notify-user/expanded#large-picture
- iOS Notification Service Extension: https://developer.apple.com/documentation/usernotifications/unnotificationserviceextension

