# Tính năng Đánh giá Ứng dụng và Báo lỗi

## Tổng quan
Đã tạo hệ thống đánh giá ứng dụng và báo lỗi cho Socdo Mobile App với các tính năng:

### 1. Đánh giá Ứng dụng
- Người dùng có thể đánh giá ứng dụng từ 0.5 đến 5 sao
- Có thể thêm góp ý bằng text
- Hiển thị thông tin thiết bị và phiên bản app tự động

### 2. Báo lỗi
- Người dùng có thể báo lỗi kèm theo ảnh chụp màn hình
- Gửi mô tả chi tiết về lỗi
- Thu thập thông tin thiết bị tự động

## Cấu trúc Database

### Bảng `app_ratings`
```sql
CREATE TABLE IF NOT EXISTS `app_ratings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL COMMENT 'ID người dùng đánh giá',
  `rating` decimal(2,1) NOT NULL COMMENT 'Số sao đánh giá (0.5 - 5.0)',
  `comment` text DEFAULT NULL COMMENT 'Nội dung góp ý',
  `device_info` varchar(255) DEFAULT NULL COMMENT 'Thông tin thiết bị',
  `app_version` varchar(50) DEFAULT NULL COMMENT 'Phiên bản ứng dụng',
  `status` tinyint(1) DEFAULT 1 COMMENT '1: hiển thị, 0: ẩn',
  `created_at` int(11) NOT NULL COMMENT 'Thời gian tạo (timestamp)',
  `updated_at` int(11) DEFAULT NULL COMMENT 'Thời gian cập nhật (timestamp)',
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `rating` (`rating`),
  KEY `created_at` (`created_at`),
  KEY `status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### Bảng `app_reports`
```sql
CREATE TABLE IF NOT EXISTS `app_reports` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL COMMENT 'ID người dùng báo lỗi',
  `image_url` varchar(500) DEFAULT NULL COMMENT 'Đường dẫn ảnh chụp lỗi',
  `description` text NOT NULL COMMENT 'Mô tả chi tiết lỗi',
  `device_info` varchar(255) DEFAULT NULL COMMENT 'Thông tin thiết bị',
  `app_version` varchar(50) DEFAULT NULL COMMENT 'Phiên bản ứng dụng',
  `status` varchar(50) DEFAULT 'pending' COMMENT 'Trạng thái: pending, reviewed, fixed, rejected',
  `admin_notes` text DEFAULT NULL COMMENT 'Ghi chú từ admin',
  `created_at` int(11) NOT NULL COMMENT 'Thời gian tạo (timestamp)',
  `updated_at` int(11) DEFAULT NULL COMMENT 'Thời gian cập nhật (timestamp)',
  `reviewed_at` int(11) DEFAULT NULL COMMENT 'Thời gian admin xem (timestamp)',
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `status` (`status`),
  KEY `created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

## API Endpoints

### 1. Submit App Rating
**Endpoint:** `POST /app_rating`

**Headers:**
```
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

**Request Body:**
```json
{
  "rating": 4.5,
  "comment": "Ứng dụng rất tốt!",
  "device_info": "Samsung Galaxy S21",
  "app_version": "1.0.0"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Cảm ơn bạn đã đánh giá ứng dụng!",
  "data": {
    "rating_id": 1,
    "rating": 4.5,
    "comment": "Ứng dụng rất tốt!",
    "created_at": 1736284800
  }
}
```

### 2. Submit App Report
**Endpoint:** `POST /app_report`

**Headers:**
```
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

**Request Body:**
```json
{
  "description": "App bị crash khi thanh toán",
  "image_url": "https://socdo.vn/uploads/reports/123.jpg",
  "device_info": "iPhone 13 Pro",
  "app_version": "1.0.0"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Cảm ơn bạn đã báo lỗi!",
  "data": {
    "report_id": 1,
    "description": "App bị crash khi thanh toán",
    "image_url": "https://socdo.vn/uploads/reports/123.jpg",
    "status": "pending",
    "created_at": 1736284800
  }
}
```

## Cấu trúc Flutter

### Models
- `lib/src/core/models/app_rating.dart` - Model cho đánh giá
- `lib/src/core/models/app_report.dart` - Model cho báo lỗi

### Screens
- `lib/src/presentation/account/app_rating_screen.dart` - Màn hình đánh giá
- `lib/src/presentation/account/app_report_screen.dart` - Màn hình báo lỗi

### API Services
- `lib/src/core/services/api_service.dart` - Đã thêm methods:
  - `submitAppRating()` - Gửi đánh giá
  - `submitAppReport()` - Gửi báo lỗi

### Navigation
- `lib/src/presentation/account/widgets/action_row.dart` - Đã thêm navigation:
  - "Đánh giá ứng dụng" → `AppRatingScreen`
  - "Báo lỗi cho chúng tôi" → `AppReportScreen`

## Dependencies mới
Đã thêm vào `pubspec.yaml`:
```yaml
flutter_rating_bar: ^4.0.1
device_info_plus: ^10.1.0
package_info_plus: ^8.0.0
```

## Cách sử dụng

### 1. Cài đặt Database
Chạy 2 file SQL để tạo bảng:
```bash
# Tại database server
mysql -u root -p socdo < database_web/create_app_ratings_table.sql
mysql -u root -p socdo < database_web/create_app_reports_table.sql
```

### 2. Cài đặt Dependencies Flutter
```bash
flutter pub get
```

### 3. Sử dụng trong App
Từ trang "Tài khoản của tôi":
- Chọn "Đánh giá ứng dụng" để gửi đánh giá
- Chọn "Báo lỗi cho chúng tôi" để gửi báo lỗi

## Tính năng
### Đánh giá ứng dụng
- Star rating với 0.5 sao increments (0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5, 5)
- Text input cho góp ý (tùy chọn)
- Hiển thị đánh giá text dựa trên số sao
- Giao diện đơn giản, hiện đại, sang trọng

### Báo lỗi
- Image picker để chọn ảnh chụp lỗi
- Text input cho mô tả chi tiết
- Upload ảnh lên server
- Thu thập thông tin thiết bị và version app tự động
- Preview ảnh trước khi gửi

## Giao diện
- Thiết kế đơn giản, không màu mè
- Màu chủ đạo: #2196F3 (blue)
- Card style với shadow nhẹ
- Responsive và user-friendly

