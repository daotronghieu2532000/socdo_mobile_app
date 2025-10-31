# ⚡ BẮT ĐẦU TEST NGAY - PUSH NOTIFICATIONS

## 🎯 BƯỚC ĐẦU TIÊN: Chạy Flutter App

### 1. Cài đặt packages:
```bash
flutter pub get
```

### 2. Kết nối Android device và chạy app:
```bash
flutter run
```

**Kiểm tra console log**, tìm dòng:
```
✅ Firebase initialized
✅ FCM Token obtained: ...
```

→ **Nếu thấy** → Firebase đã hoạt động! ✅

---

## 📱 BƯỚC 2: Đăng nhập và Register Token

### Cách 1: Dùng tài khoản cũ (Nhanh nhất)

1. Mở app
2. Đăng nhập bằng **tài khoản bạn đã có**
3. Sau khi đăng nhập thành công, xem console log:
```
✅ Đăng nhập thành công: ...
✅ Device token registered successfully
```

→ **Token sẽ tự động được register sau khi login!**

### Cách 2: Tài khoản mới

1. Đăng ký tài khoản mới
2. Đăng nhập
3. Token cũng sẽ tự động register

---

## ✅ BƯỚC 3: Kiểm tra token đã được lưu

**Qua phpMyAdmin**:

```sql
-- Xem tất cả tokens
SELECT user_id, LEFT(device_token, 50) as token_preview, platform, is_active, created_at 
FROM device_tokens 
ORDER BY created_at DESC;
```

**KếtLuc mong đợi**:
- Có ít nhất 1 record với `user_id` của bạn
- `device_token` có giá trị (chuỗi dài)
- `is_active` = 1

---

## 🧪 BƯỚC 4: Test gửi push notification

### Cách DỄ NHẤT: Dùng script test

#### Bước 4.1: Lấy User ID

```sql tính
-- Lấy user_id từ database
SELECT user_id FROM device_tokens ORDER BY created_at DESC LIMIT 1;
```

**Copy `user_id`** (ví dụ: `123`)

#### Bước 4.2: Upload file test lên server

File `test_send_push.php` đã được tạo sẵn trong `API_WEB/`

Upload lên server: `/home/api.socdo.vn/public_html/home/themes/socdo/action/process/`

#### Bước 4.3: Chạy test script

**Qua SSH hoặc command line**:
```bash
cd /home/api.socdo.vn/public_html/home/themes/socdo/action/ Borg
php test_send_push.php YOUR_USER_ID
```

**Hoặc qua browser** (nếu có quyền):
```
https://api.socdo.vn/v1/test_send_push.php?user_id=YOUR_USER_ID
```

**Ví dụ**:
```bash
php test_send_push.php 123
```

**Kết quả**:
```
✅ Tìm thấy 1 device token(s) cho user ID 123
🧪 Bắt đầu test gửi push notification...
Test 1: Thông báo đơn hàng mới
   ✅ Notification đơn hàng đã được tạo
✅ Test hoàn tất!
```

---

### Cách TỰ NHIÊN: Tạo đơn hàng thực

1. Trong app, **thêm sản phẩm vào giỏ hàng**
2. **Đặt hàng**
3. **Kết quả mong đợi**: 
   - Đơn hàng được tạo
   - Nhận push notification về đơn hàng mới!

---

## 📱 BƯỚC 5: Kiểm tra nhận notification

### Nếu app đang MỞ:
- Notification sẽ hiển thị trong app (local notification)
- **Xem console log**: `📱 Foreground message received`

### Nếu app đang ĐÓNG hoặc BACKGROUND:
1. **Nhấn Home button** (app chạy background)
2. **Gửi test notification** (qua script hoặc tạo đơn hàng)
3. **Kiểm tra notification tray**:
   - Swipe down từ top màn hình
   - Tìm notification từ app "Socdo"
   - Tap vào → app mở

---

## 🔍 DEBUG - Kiểm tra từng bước

### Check 1: Firebase initialized?

**Xem console log khi app start**:
```
✅ Firebase initialized
```

**Nếu KHÔNG có**:
- Kiểm tra `google-services.json` có đúng không
- Kiểm tra `Firebase.initializeApp()` trong `main.dart`

---

### Check 2: FCM Token được lấy?

**Xem console log**:
```
✅ FCM Token obtained: dGhpcyBpcyBhIGZha2U...
```

**Nếu KHÔNG có**:
- Kiểm tra internet
- Kiểm tra permission notification
- Test trên device thật (KHÔNG dùng emulator)

---

### Check 3: Token được register lên server?

**Xem console log**:
```
✅ Device token registered successfully
```

**Xem database**:
```sql
SELECT * FROM device_tokens WHERE user_id733 = YOUR_USER_ID;
```

**Nếu KHÔNG có record**:
- Kiểm tra API endpoint `/register_device_token`
- Kiểm tra JWT token có hợp lệ không
- Kiểm tra log lỗi trong PHP

---

### Check 4: Push được gửi từ backend?

**Kiểm tra PHP error log**:
```bash
tail -f /path/to/php_error.log
```

**Khi chạy test_send_push.php**, xem có lỗi gì không.

**Nếu có lỗi**:
- Kiểm tra Service Account JSON file
- Kiểm tra OpenSSL có enabled không
- Kiểm tra FCM API có hoạt động không

---

### Check 5: Notification hiển thị?

**Nếu KHÔNG hiển thị**:
- Kiểm tra Settings > Apps > Socdo > Notifications → ON
- Grant permission khi app hỏi
- Test khi app ở **background** (foreground cần local notification)

---

## 📋 CHECKLIST TEST ĐẦY ĐỦ

### Setup:
- [ ] `flutter pub get` → Thành công
- [ ] Build app trên device thật → OK
- [ ] Firebase initialized → OK

### Token Registration:
- [ ] Đăng nhập vào app → OK
- [ ] Log: "✅ FCM Token obtained" → Có
- [ ] Log: "✅ Device token registered" → Có
- [ ] Database có record trong `device_tokens` → Có

### Push Notification:
- [ ] Gửi test push (script hoặc tạo đơn hàng) → OK
- [ ] Nhận được notification → OK
- [ ] Tap notification → App mở → OK

---

## 🎯 TEST THÀNH CÔNG KHI:

✅ App khởi động không lỗi  
✅ FCM token được lấy thành công  
✅ Token được lưu vào database  
✅ Backend gửi được push notification  
✅ Device nhận được notification  
✅ Tap notification → app mở đúng màn hình  

→ **Nếu đủ 6 điều kiện → HOÀN TẤT!** 🎉

---

## 💡 TIPS

1. **Luôn test trên device thật** - emulator không nhận được push
2. **Kiểm tra permission** - cần grant notification permission
3. **Test khi app ở background** - dễ thấy notification hơn
4. **Xem logs** - console log và PHP error log sẽ cho biết lỗi ở đâu

---

**🚀 Bắt đầu test ngay!**

