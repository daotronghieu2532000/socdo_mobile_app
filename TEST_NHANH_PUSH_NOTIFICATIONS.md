# ⚡ TEST NHANH - PUSH NOTIFICATIONS (5 PHÚT)

## 🎯 QUY TRÌNH TEST NHANH

### BƯỚC 1: Cài đặt và build app (2 phút)

```bash
# 1. Cài dependencies
flutter pub get

# 2. Build và chạy trên device thật (KHÔNG dùng emulator!)
flutter run
```

**Kiểm tra**: Xem console log, tìm dòng:
```
✅ Firebase initialized
✅ FCM Token obtained: ...
```

→ Nếu thấy → **OK, tiếp tục!**

---

### BƯỚC 2: Đăng nhập vào app (30 giây)

1. Mở app
2. Đăng nhập bằng **tài khoản bất kỳ** (tài khoản cũ hoặc mới đều được)
3. Xem console log, tìm dòng:
```
✅ Device token registered successfully
```

→ Nếu thấy → **Token đã được lưu!**

---

### BƯỚC 3: Kiểm tra token trong database (30 giây)

**Qua phpMyAdmin hoặc command line**:

```sql
-- Xem token đã được lưu chưa
SELECT user_id, device_token, platform, is_active, created_at 
FROM device_tokens 
ORDER BY created_at DESC 
LIMIT 5;
```

**Kết quả mong đợi**:
- ✅ Có ít nhất 1 record
- ✅ `user_id` = ID user vừa đăng nhập
- ✅ `device_token` có giá trị (chuỗi dài)
- ✅ `is_active` = 1

→ Nếu có record → **OK, token đã được lưu!**

---

### BƯỚC 4: Test gửi push notification (1 phút)

#### Option A: Test qua script PHP (Dễ nhất)

**Tạo file**: `API_WEB/test_send_push.php` (đã có sẵn)

**Lấy User ID**:
```sql
-- Lấy user_id từ bảng device_tokens
SELECT user_id FROM device_tokens ORDER BY created_at DESC LIMIT 1;
```

**Chạy test script**:
```bash
cd /path/to/API_WEB
php test_send_push.php YOUR_USER_ID
```

**Ví dụ**:
```bash
php test_send_push.php 123
```

**Kết quả mong đợi**:
```
✅ Tìm thấy 1 device token(s) cho user ID 123
🧪 Bắt đầu test gửi push notification...
Test 1: Thông báo đơn hàng mới
   ✅ Notification đơn hàng đã được tạo
...
✅ Test hoàn tất!
📱 Hãy kiểm tra device...
```

---

#### Option B: Test qua tạo đơn hàng (Tự nhiên hơn)

1. Trong app, thêm sản phẩm vào giỏ hàng
2. Đặt hàng
3. **Kết quả mong đợi**: Nhận push notification về đơn hàng mới

---

### BƯỚC 5: Kiểm tra nhận notification (30 giây)

#### Nếu app đang MỞ (Foreground):
- Notification sẽ hiển thị trong app (local notification)
- Xem log console: `📱 Foreground message received`

#### Nếu app đang ĐÓNG hoặc BACKGROUND:
- Notification sẽ hiển thị trên **notification tray**
- Swipe down từ top màn hình để xem
- Tap vào notification → app sẽ mở

---

## ✅ CHECKLIST TEST NHANH

- [ ] Chạy `flutter pub get` → Thành công
- [ ] Build app trên device thật → Chạy được
- [ ] Đăng nhập vào app → Thành công
- [ ] Kiểm tra log: "✅ FCM Token obtained" → Có
- [ ] Kiểm tra log: "✅ Device token registered" → Có
- [ ] Kiểm tra database có record trong `device_tokens` → Có
- [ ] Test gửi push (script hoặc tạo đơn hàng) → Gửi được
- [ ] Nhận được notification trên device → Có

---

## 🐛 NẾU KHÔNG THẤY NOTIFICATION

### Kiểm tra nhanh:

1. **Permission**:
   - Settings > Apps > Socdo > Notifications → Bật ON
   - Hoặc grant permission khi app hỏi

2. **App state**:
   - Test khi app ở **background** hoặc **đóng** (foreground có thể không hiển thị tự động)

3. **Database**:
   - Kiểm tra có device token không
   - Kiểm tra `is_active` = 1

4. **Logs**:
   - Xem PHP error log có lỗi gì không
   - Xem Flutter console log

---

## 🎯 TEST THÀNH CÔNG KHI:

✅ App nhận được FCM token  
✅ Token được lưu vào database  
✅ Backend gửi được push qua FCM  
✅ Device nhận được notification  
✅ Tap notification → app mở  

→ **Nếu đủ 5 điều kiện trên → TEST THÀNH CÔNG!** 🎉

---

**📝 Lưu ý**: 
- Test trên **device thật**, không dùng emulator
- Cần **internet connection**
- Cần **grant notification permission**

