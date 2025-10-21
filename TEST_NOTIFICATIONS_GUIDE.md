# 🧪 HƯỚNG DẪN TEST HỆ THỐNG THÔNG BÁO

## ✅ **Đã hoàn thành:**

### 1. **Database & API**
- ✅ Bảng `notification_mobile` đã tạo (tương thích MariaDB 10.1.48)
- ✅ API `notifications_mobile.php` - Lấy danh sách thông báo
- ✅ API `notification_mark_read_mobile.php` - Đánh dấu đã đọc
- ✅ Helper `notification_mobile_helper.php` - Tự động tạo thông báo

### 2. **Mobile App**
- ✅ Cập nhật `api_service.dart` để sử dụng endpoint mới
- ✅ Cập nhật `notifications_screen.dart` với UI mới (icon, màu sắc, priority)
- ✅ Icon thông báo trong `home_app_bar.dart` đã sẵn sàng

## 🧪 **CÁCH TEST:**

### **Bước 1: Tạo thông báo mẫu**
```
http://localhost/socdo_mobile/API_WEB/test_notifications.php?key=test_notifications_2025
```

### **Bước 2: Test Mobile App**
1. Mở app và kiểm tra icon thông báo ở home screen
2. Tap vào icon để xem danh sách thông báo
3. Test đánh dấu đã đọc từng thông báo
4. Test "Đánh dấu tất cả đã đọc"

### **Bước 3: Test tích hợp thực tế**

#### **Tích hợp vào create_order.php:**
```php
// Thêm vào cuối file create_order.php sau khi tạo đơn hàng thành công
if ($order_created_successfully) {
    require_once './notification_mobile_helper.php';
    $notificationHelper = new NotificationMobileHelper($conn);
    
    $notificationHelper->notifyNewOrder(
        $user_id, 
        $order_id, 
        $order_code, 
        $total_amount
    );
}
```

#### **Tích hợp vào order_status.php:**
```php
// Thêm vào file order_status.php khi cập nhật trạng thái
if ($status_updated_successfully) {
    require_once './notification_mobile_helper.php';
    $notificationHelper = new NotificationMobileHelper($conn);
    
    // Lấy thông tin đơn hàng
    $order_query = "SELECT user_id, ma_don FROM donhang WHERE id = '$order_id'";
    $order_result = mysqli_query($conn, $order_query);
    $order_data = mysqli_fetch_assoc($order_result);
    
    $notificationHelper->notifyOrderStatusChange(
        $order_data['user_id'],
        $order_id,
        $order_data['ma_don'],
        $old_status,
        $new_status
    );
}
```

## 📱 **CÁC LOẠI THÔNG BÁO:**

| Loại | Icon | Màu | Priority | Mô tả |
|------|------|-----|----------|-------|
| `order` | 🛒 | Xanh dương | High/Medium | Đơn hàng mới, thay đổi trạng thái |
| `affiliate_order` | 🤝 | Xanh lá | High | Đơn hàng affiliate mới |
| `deposit` | ➕ | Cyan | Medium | Nạp tiền thành công |
| `withdrawal` | ➖ | Cam | Medium/High | Rút tiền (chờ duyệt, hoàn thành, từ chối) |
| `voucher_new` | 🎁 | Đỏ | Medium | Voucher mới |
| `voucher_expiring` | ⏰ | Tím | High | Voucher sắp hết hạn |

## 🔧 **TROUBLESHOOTING:**

### **Nếu không thấy thông báo:**
1. Kiểm tra bảng `notification_mobile` có dữ liệu không
2. Kiểm tra API endpoint có hoạt động không
3. Kiểm tra JWT token trong mobile app
4. Kiểm tra user_id có đúng không

### **Nếu icon thông báo không hiện số:**
1. Kiểm tra `home_app_bar.dart` có gọi API đúng không
2. Kiểm tra `_loadUnread()` method
3. Kiểm tra response từ API

### **Nếu không đánh dấu được đã đọc:**
1. Kiểm tra `markNotificationRead()` method
2. Kiểm tra API `notification_mark_read_mobile.php`
3. Kiểm tra database update

## 📊 **KIỂM TRA DATABASE:**

```sql
-- Xem tất cả thông báo
SELECT * FROM notification_mobile ORDER BY created_at DESC;

-- Đếm thông báo chưa đọc
SELECT COUNT(*) FROM notification_mobile WHERE is_read = 0;

-- Xem thông báo của user cụ thể
SELECT * FROM notification_mobile WHERE user_id = 1 ORDER BY created_at DESC;
```

## 🚀 **SẴN SÀNG TEST!**

Hệ thống đã hoàn thiện và sẵn sàng để test. Bạn có thể:

1. **Tạo thông báo mẫu** bằng file test
2. **Đặt đơn hàng** và tích hợp notification
3. **Đổi trạng thái đơn hàng** và tích hợp notification
4. **Test mobile app** với các chức năng thông báo

Chúc bạn test thành công! 🎉
