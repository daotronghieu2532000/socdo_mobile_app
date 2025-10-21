# Hệ thống thông báo Mobile App - Socdo

## Tổng quan
Hệ thống thông báo mới được thiết kế để thay thế bảng `notification` cũ, phục vụ cho mobile app với các tính năng:
- Thông báo đơn hàng (mới, thay đổi trạng thái)
- Thông báo affiliate (đơn hàng, hoa hồng)
- Thông báo nạp/rút tiền
- Thông báo voucher (mới, sắp hết hạn)

## Cấu trúc Database

### Bảng `notification_mobile`
```sql
CREATE TABLE `notification_mobile` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(11) NOT NULL COMMENT 'ID người dùng nhận thông báo',
  `type` varchar(50) NOT NULL COMMENT 'Loại thông báo: order, affiliate_order, deposit, withdrawal, voucher_new, voucher_expiring',
  `title` varchar(255) NOT NULL COMMENT 'Tiêu đề thông báo',
  `content` text NOT NULL COMMENT 'Nội dung thông báo',
  `data` json DEFAULT NULL COMMENT 'Dữ liệu bổ sung (JSON)',
  `related_id` int(11) DEFAULT NULL COMMENT 'ID liên quan (đơn hàng, voucher, etc.)',
  `related_type` varchar(50) DEFAULT NULL COMMENT 'Loại đối tượng liên quan: order, coupon, affiliate_order',
  `priority` enum('low','medium','high') DEFAULT 'medium' COMMENT 'Mức độ ưu tiên',
  `is_read` tinyint(1) DEFAULT 0 COMMENT '0: chưa đọc, 1: đã đọc',
  `read_at` int(11) DEFAULT NULL COMMENT 'Thời gian đọc (timestamp)',
  `created_at` int(11) NOT NULL COMMENT 'Thời gian tạo (timestamp)',
  `updated_at` int(11) DEFAULT NULL COMMENT 'Thời gian cập nhật (timestamp)',
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `type` (`type`),
  KEY `is_read` (`is_read`),
  KEY `created_at` (`created_at`),
  KEY `related_id` (`related_id`),
  KEY `related_type` (`related_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

## API Endpoints

### 1. Lấy danh sách thông báo
**Endpoint:** `GET /notifications_mobile.php`

**Parameters:**
- `user_id` (required): ID người dùng
- `page` (optional): Trang (default: 1)
- `limit` (optional): Số lượng mỗi trang (default: 20)
- `type` (optional): Lọc theo loại thông báo
- `unread_only` (optional): Chỉ lấy thông báo chưa đọc

**Response:**
```json
{
  "success": true,
  "message": "Lấy danh sách thông báo thành công",
  "data": {
    "notifications": [...],
    "unread_count": 5,
    "pagination": {...},
    "type_map": {...}
  }
}
```

### 2. Đánh dấu thông báo đã đọc
**Endpoint:** `POST /notification_mark_read_mobile.php`

**Parameters:**
- `user_id` (required): ID người dùng
- `notification_id` (optional): ID thông báo cụ thể
- `mark_all` (optional): Đánh dấu tất cả đã đọc
- `type` (optional): Lọc theo loại khi mark_all

## Cách sử dụng

### 1. Tích hợp vào API hiện tại

#### Tạo thông báo đơn hàng mới:
```php
require_once './notification_mobile_helper.php';

$notificationHelper = new NotificationMobileHelper($conn);
$notificationHelper->notifyNewOrder($user_id, $order_id, $order_code, $total_amount);
```

#### Tạo thông báo thay đổi trạng thái đơn hàng:
```php
$notificationHelper->notifyOrderStatusChange($user_id, $order_id, $order_code, $old_status, $new_status);
```

#### Tạo thông báo affiliate:
```php
$notificationHelper->notifyNewAffiliateOrder($user_id, $order_id, $order_code, $commission_amount);
```

#### Tạo thông báo nạp/rút tiền:
```php
// Nạp tiền
$notificationHelper->notifyDeposit($user_id, $amount, $method);

// Rút tiền
$notificationHelper->notifyWithdrawal($user_id, $amount, $status, $method);
```

#### Tạo thông báo voucher:
```php
// Voucher mới
$notificationHelper->notifyNewVoucher($user_id, $voucher_code, $discount_amount, $expired_date);

// Voucher sắp hết hạn
$notificationHelper->notifyVoucherExpiring($user_id, $voucher_code, $discount_amount, $expired_date);
```

### 2. Cập nhật Mobile App

#### API Service đã được cập nhật:
- `getNotifications()` → sử dụng `/notifications_mobile`
- `markNotificationRead()` → sử dụng `/notification_mark_read_mobile`

#### Icon thông báo trong HomeAppBar:
- Đã tích hợp sẵn với API mới
- Hiển thị số lượng thông báo chưa đọc
- Navigate đến trang thông báo khi tap

### 3. Cron Job

#### Thiết lập cron job kiểm tra voucher sắp hết hạn:
```bash
# Chạy mỗi giờ
0 * * * * /usr/bin/php /path/to/socdo_mobile/API_WEB/cron_check_voucher_expiring.php socdo_cron_2025
```

#### Hoặc tạo file cron.sh:
```bash
#!/bin/bash
cd /path/to/socdo_mobile/API_WEB
php cron_check_voucher_expiring.php socdo_cron_2025
```

## Các loại thông báo

### 1. Order (Đơn hàng)
- **order**: Đơn hàng mới, thay đổi trạng thái
- **affiliate_order**: Đơn hàng affiliate mới

### 2. Financial (Tài chính)
- **deposit**: Nạp tiền thành công
- **withdrawal**: Rút tiền (chờ duyệt, đã duyệt, từ chối, hoàn thành)

### 3. Voucher (Mã giảm giá)
- **voucher_new**: Voucher mới có sẵn
- **voucher_expiring**: Voucher sắp hết hạn (< 24h)

## Mức độ ưu tiên

- **high**: Đơn hàng mới, đang giao hàng, voucher sắp hết hạn, rút tiền bị từ chối
- **medium**: Thay đổi trạng thái đơn hàng, nạp/rút tiền, voucher mới
- **low**: Các thông báo khác

## Migration từ hệ thống cũ

### 1. Database
```sql
-- Chạy file notification_mobile.sql để tạo bảng mới
-- Không cần migrate dữ liệu từ bảng cũ vì cấu trúc khác hoàn toàn
```

### 2. API
- Thay đổi endpoint từ `/notifications_list` → `/notifications_mobile`
- Thay đổi endpoint từ `/notification_mark_read` → `/notification_mark_read_mobile`

### 3. Mobile App
- API service đã được cập nhật tự động
- Không cần thay đổi UI, chỉ cần test lại chức năng

## Testing

### 1. Test API
```bash
# Test lấy thông báo
curl -X GET "http://localhost/socdo_mobile/API_WEB/notifications_mobile.php?user_id=1"

# Test đánh dấu đã đọc
curl -X POST "http://localhost/socdo_mobile/API_WEB/notification_mark_read_mobile.php" \
  -d "user_id=1&notification_id=1"
```

### 2. Test Mobile App
- Mở app và kiểm tra icon thông báo
- Tap vào icon để xem danh sách thông báo
- Test đánh dấu đã đọc

### 3. Test Cron Job
```bash
# Test manual
php /path/to/socdo_mobile/API_WEB/cron_check_voucher_expiring.php socdo_cron_2025
```

## Troubleshooting

### 1. Lỗi database
- Kiểm tra bảng `notification_mobile` đã được tạo chưa
- Kiểm tra foreign key constraint với `user_info`

### 2. Lỗi API
- Kiểm tra JWT token
- Kiểm tra user_id có tồn tại không
- Kiểm tra log error trong PHP

### 3. Lỗi Mobile App
- Kiểm tra endpoint URL
- Kiểm tra network connection
- Kiểm tra response format

## Maintenance

### 1. Dọn dẹp thông báo cũ
```sql
-- Xóa thông báo cũ hơn 30 ngày
DELETE FROM notification_mobile WHERE created_at < (UNIX_TIMESTAMP() - 30*24*3600);
```

### 2. Backup
```sql
-- Backup thông báo quan trọng
SELECT * FROM notification_mobile WHERE priority = 'high' AND created_at > (UNIX_TIMESTAMP() - 7*24*3600);
```

### 3. Monitoring
- Theo dõi số lượng thông báo chưa đọc
- Theo dõi performance của cron job
- Theo dõi error log
