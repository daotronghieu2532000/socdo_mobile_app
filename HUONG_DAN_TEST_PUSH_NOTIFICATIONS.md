# 🧪 HƯỚNG DẪN TEST PUSH NOTIFICATIONS

## 📋 CHECKLIST TRƯỚC KHI TEST

### ✅ Đã hoàn thành:
- [x] Tạo bảng `device_tokens` trong database
- [x] Upload file JSON lên server
- [x] Upload các file API lên server
- [x] Cập nhật `notification_mobile_helper.php`

---

## 🚀 BƯỚC 1: CÀI ĐẶT DEPENDENCIES FLUTTER

### Chạy lệnh:
```bash
cd /path/to/socdo_mobile
flutter pub get
```

**Kết quả mong đợi**: 
- ✅ Các packages được cài đặt:
  - firebase_core
  - firebase_messaging
  - flutter_local_notifications

**Nếu có lỗi**: Kiểm tra `pubspec.yaml` có đúng dependencies không.

---

## 📱 BƯỚC 2: BUILD VÀ CHẠY APP TRÊN DEVICE THẬT

⚠️ **QUAN TRỌNG**: Phải test trên **device thật**, emulator có thể không nhận được push notifications!

### 2.1. Kết nối thiết bị Android:
```bash
# Kiểm tra device đã kết nối
adb devices

# Chạy app
flutter run
```

### 2.2. Kiểm tra log khi app khởi động:

Trong console, tìm các dòng:
```
✅ Firebase initialized
🚀 Bắt đầu khởi tạo app...
✅ FCM Token obtained: ...
✅ Device token registered successfully
```

**Nếu thấy các dòng này** → Firebase và FCM đã hoạt động! ✅

**Nếu KHÔNG thấy**:
- Kiểm tra có lỗi gì không
- Kiểm tra internet connection
- Kiểm tra permission notification đã được grant chưa

---

## 🔑 BƯỚC 3: ĐĂNG NHẬP VÀ KIỂM TRA TOKEN

### 3.1. Đăng nhập vào app:
- Mở app
- Đăng nhập bằng tài khoản bất kỳ (dùng tài khoản cũ cũng được)
- Sau khi đăng nhập thành công → token sẽ tự động được register

### 3.2. Kiểm tra token đã được lưu trong database:

**Cách 1: Qua phpMyAdmin**
```sql
-- Xem tất cả tokens đã register
SELECT * FROM device_tokens ORDER BY created_at DESC;

-- Xem token của user cụ thể (thay YOUR_USER_ID)
SELECT * FROM device_tokens WHERE user_id = YOUR_USER_ID;
```

**Cách 2: Qua API** (nếu có endpoint test)

**Kết quả mong đợi**:
- ✅ Có 1 record trong bảng `device_tokens`
- ✅ `user_id` = ID user vừa đăng nhập
- ✅ `device_token` có giá trị (dài, bắt đầu bằng...)
- ✅ `platform` = 'android'
- ✅ `is_active` = 1

---

## 🧪 BƯỚC 4: TEST GỬI PUSH NOTIFICATION

### Option 1: Test bằng API tạo notification (Test tự động)

#### Tạo một đơn hàng mới:
1. Đăng nhập vào app
2. Thêm sản phẩm vào giỏ hàng
3. Đặt hàng

**Kết quả mong đợi**:
- ✅ Notification được tạo trong `notification_mobile` table
- ✅ Push notification được gửi qua FCM
- ✅ Device nhận được notification
- ✅ Hiển thị trên màn hình điện thoại

---

### Option 2: Test manual qua API (Test thủ công)

#### Bước 4.1: Lấy Device Token từ database

```sql
-- Lấy device token của user
SELECT device_token, user_id, platform 
FROM device_tokens 
WHERE user_id = YOUR_USER_ID 
AND is_active = 1 
LIMIT 1;
```

Copy `device_token` (ví dụ: `dGhpcyBpcyBhIGZha2UgdG9rZW4...`)

#### Bước 4.2: Test gửi push bằng cURL hoặc Postman

**Chú ý**: Cần **Access Token** từ FCM V1 API trước. Nhưng để test nhanh, bạn có thể test qua `notification_mobile_helper.php`:

#### Test qua notification_mobile_helper:

Tạo file test: `API_WEB/test_send_push.php`

```php
<?php
require_once './config.php';
require_once './notification_mobile_helper.php';

$generatorHelper = new NotificationMobileHelper($conn);

// Thay YOUR_USER_ID bằng user ID thực tế
$user_id = YOUR_USER_ID; // Lấy từ database hoặc dùng user đã đăng nhập

// Test: Tạo notification và gửi push
$result = $generatorHelper->notifyNewOrder(
    $user_id,
    999, // order_id (fake)
    'TEST-' . time(), // order_code
    50000 // total_amount
);

if ($result) {
    echo "✅ Notification created and push sent!\n";
    echo "Check your device for push notification.\n";
} else {
    echo "❌ Failed to send push\n";
}
?>
```

**Chạy test**:
```bash
php API_WEB/test_send_push.php
```

**Kết quả mong đợi**:
- ✅ Console hiển thị "✅ Notification created and push sent!"
- ✅ Device nhận được push notification
- ✅ Notification hiển thị trên màn hình

---

## 🔍 BƯỚC 5: KIỂM TRA CHI TIẾT

### 5.1. Kiểm tra logs trong app:

Khi nhận được notification, xem console log:
```
📱 Foreground message received: ...
📱 App opened from notification: ...
```

### 5.2. Test các trạng thái app:

#### Test Foreground (App đang mở):
1. Mở app
2. Gửi test notification
3. **Kết quả mong đợi**: Notification hiển thị trong app (local notification)

#### Test Background (App bị ẩn):
1. Mở app, sau đó nhấn Home button (app vẫn chạy)
2. Gửi test notification
3. **Kết quả mong đợi**: Notification hiển thị trên notification tray

#### Test Terminated (App đã tắt):
1. Đóng app hoàn toàn (swipe away)
2. Gửi test notification
3. **Kết quả mong đợi**: Notification hiển thị trên notification tray

### 5.3. Test tap notification:

1. Gửi notification
2. Tap vào notification
3. **Kết quả mong đợi**: App mở và navigate đến màn hình phù hợp (ví dụ: order detail nếu là notification đơn hàng)

---

## 🐛 TROUBLESHOOTING

### ❌ Lỗi: "Firebase not initialized"

**Nguyên nhân**: Firebase chưa được khởi tạo trong `main.dart`

**Giải pháp**:
- Kiểm tra `lib/main.dart` có `Firebase.initializeApp()` chưa
- Kiểm tra `google-services.json` có đúng không

---

### ❌ Lỗi: "No FCM token"

**Nguyên nhân**: 
- Chưa có internet
- Chưa grant permission
- Test trên emulator

**Giải pháp**:
- Affirm internet connection
- Grant notification permission khi app hỏi
- Test trên device thật (KHÔNG dùng emulator)

---

### ❌ Lỗi: "Cannot register device token"

**Nguyên nhân**: API endpoint không hoạt động

**Giải pháp**:
1. Test API endpoint:
```bash
# Test bằng Postman hoặc cURL
curl -X POST https://api.socdo.vn/v1/register_device_token \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": YOUR_USER_ID,
    "device_token": "test_token",
    "platform": "android"
  }'
```

2. Kiểm tra response có lỗi gì không
3. Kiểm tra database connection
4. Kiểm tra file `register_device_token.php` đã upload đúng chưa

---

### ❌ Lỗi: "Push không được gửi từ backend"

**Nguyên nhân**: 
- FCM Service Account JSON không đúng
- insufficient permissions
- OpenSSL không support RS256

**Giải pháp**:
1. Kiểm tra file JSON có đúng không:
```php
// Test trong fcm_config.php
$data = getFCMServiceAccountData();
print_r($data); // Kiểm tra có data không
```

2. Kiểm tra PHP có OpenSSL enabled:
```bash
php -m | grep openssl
오grep
```

3. Kiểm tra error log trong PHP:
```bash
tail -f /path/to/error.log
```

---

### ❌ Notification được gửi nhưng không hiển thị

**Nguyên nhân**:
- User đã tắt notifications trong settings
- App đang ở foreground (cần local notification)
- Permission chưa được grant

**Giải pháp**:
- Kiểm tra Settings > Apps > Socdo > Notifications (đảm bảo ON)
- Grant permission khi app hỏi
- Test khi app ở background/terminated

---

## 📊 CHECKLIST TEST HOÀN CHỈNH

### Phase 1: Setup
- [ ] Chạy `flutter pub get`
- [ ] Build app trên device thật
- [ ] Kiểm tra Firebase initialized trong log

### Phase 2: Token Registration
- [ ] Đăng nhập vào app
- [ ] Kiểm tra log: "✅ FCM Token obtained"
- [ ] Kiểm tra log: "✅ Device token registered successfully"
- [ ] Kiểm tra database có record trong `device_tokens`

### Phase 3: Test Push Notifications
- [ ] Test Foreground: App mở → Gửi push → Nhận notification
- [ ] Test Background: App bị ẩn → Gửi push → Nhận notification
- [ ] Test Terminated: App đóng → Gửi push → Nhận notification
- [ ] Test tap notification → App mở đúng màn hình

### Phase 4: Test Integration
- [ ] Tạo đơn hàng → Nhận push notification
- [ ] Đổi trạng thái đơn hàng → Nhận push notification
- [ ] Test các loại notifications khác (voucher, deposit, etc.)

---

## 🎯 NEXT STEPS SAU KHI TEST THÀNH PGA

1. ✅ Verify tất cả loại notifications hoạt động
2. ✅ Setup deep linking cho các màn hình
3. ✅ Tối ưu notification icons và sounds
4. ✅ Test trên nhiều thiết bị khác nhau
5. ✅ Deploy lên production

---

**📅 Created**: 2025-01-XX
**✅ Status**: Ready to test!

