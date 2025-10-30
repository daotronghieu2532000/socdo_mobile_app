# 📱 LÝ THUYẾT VÀ PHƯƠNG ÁN PUSH NOTIFICATIONS CHO APP SOCDO_MOBILE

## 📋 MỤC LỤC
1. [Tổng quan về Push Notifications](#1-tổng-quan-về-push-notifications)
2. [Các loại thông báo](#2-các-loại-thông-báo)
3. [Phương án triển khai trong Flutter](#3-phương-án-triển-khai-trong-flutter)
4. [So sánh các giải pháp](#4-so-sánh-các-giải-pháp)
5. [Cách các app lớn triển khai](#5-cách-các-app-lớn-triển-khai)
6. [Khuyến nghị cho Socdo Mobile](#6-khuyến-nghị-cho-socdo-mobile)
7. [Kiến trúc hệ thống đề xuất](#7-kiến-trúc-hệ-thống-đề-xuất)

---

## 1. TỔNG QUAN VỀ PUSH NOTIFICATIONS

### 1.1. Push Notification là gì?
Push Notification là thông báo được gửi từ server đến thiết bị người dùng, xuất hiện trên màn hình điện thoại ngay cả khi app đang đóng hoặc ở background.

### 1.2. In-App Notification vs Push Notification

| Đặc điểm | In-App Notification | Push Notification |
|----------|-------------------|-------------------|
| **Hoạt động khi** | Chỉ khi app đang mở | App đóng/background/foreground |
| **Lưu trữ** | Database của server | Hiển thị ngay trên màn hình |
| **Đánh thức thiết bị** | ❌ Không | ✅ Có thể |
| **Yêu cầu** | Chỉ cần API | Cần device token + push service |
| **Ví dụ trong app hiện tại** | ✅ Đã có (`notification_mobile`) | ❌ Chưa có |

### 1.3. Các trạng thái nhận thông báo

1. **Foreground** (App đang mở):
   - Thông báo đến nhưng không tự hiển thị notification
   - Cần xử lý trong code để hiển thị
   
2. **Background** (App đang chạy nhưng bị ẩn):
   - Thông báo hiển thị trên notification tray
   - Khi tap vào → mở app và xử lý

3. **Terminated** (App đã tắt hoàn toàn):
   - Thông báo hiển thị trên notification tray
   - Khi tap vào → khởi động app và xử lý

---

## 2. CÁC LOẠI THÔNG BÁO

### 2.1. Thông báo tự động (Automatic/Push)
- **Định nghĩa**: Gửi từ server khi có sự kiện xảy ra
- **Ví dụ**:
  - Đơn hàng mới được tạo
  - Trạng thái đơn hàng thay đổi
  - Voucher sắp hết hạn (từ cron job)
  - Nạp/rút tiền hoàn tất
  - Đơn hàng affiliate mới
- **Đặc điểm**: Không cần hành động từ người dùng

### 2.2. Thông báo chủ động (Scheduled/Local)
- **Định nghĩa**: Được lên lịch và hiển thị bởi chính app
- **Ví dụ**:
  - Nhắc nhở xem sản phẩm đã lưu
  - Nhắc nhở về flash sale sắp bắt đầu
  - Nhắc nhở voucher sắp hết hạn (kiểm tra local)
- **Đặc điểm**: Cần app đã từng được mở, không cần server

### 2.3. Thông báo hàng loạt (Bulk/Broadcast)
- **Định nghĩa**: Gửi đến nhiều người dùng cùng lúc
- **Ví dụ**:
  - Khuyến mãi chung cho tất cả người dùng
  - Thông báo sự kiện lớn
  - Thông báo bảo trì hệ thống

### 2.4. Thông báo cá nhân hóa (Personalized)
- **Định nghĩa**: Dựa trên hành vi, sở thích người dùng
- **Ví dụ**:
  - "Bạn đã xem sản phẩm này, giờ đang giảm giá!"
  - "Cửa hàng bạn thích đang có sản phẩm mới"

---

## 3. PHƯƠNG ÁN TRIỂN KHAI TRONG FLUTTER

### 3.1. Firebase Cloud Messaging (FCM) - ⭐ ĐƯỢC KHUYẾN NGHỊ NHẤT

#### ✅ Ưu điểm:
- **Miễn phí**: Không giới hạn số lượng thông báo
- **Độ tin cậy cao**: Google hỗ trợ, ổn định
- **Tích hợp dễ**: Có sẵn package `firebase_messaging`
- **Tính năng đầy đủ**:
  - Data messages (gửi dữ liệu tùy ý)
  - Notification messages (hiển thị tự động)
  - Topic subscription (gửi theo nhóm)
  - Device groups
  - Scheduled notifications
- **Đa nền tảng**: Android, iOS, Web
- **Analytics**: Có sẵn trong Firebase Console

#### ❌ Nhược điểm:
- Cần tài khoản Google Firebase
- Cần cấu hình Firebase project
- Android bắt buộc phải dùng FCM (không có lựa chọn khác)

#### 📦 Packages cần thiết:
```yaml
dependencies:
  firebase_core: ^2.24.0
 pling
  firebase_messaging: ^14.7.9
  flutter_local_notifications: ^16.3.0  # Hiển thị notification khi app ở foreground
```

#### 🔧 Kiến trúc FCM:
```
Server (PHP) 
    ↓ HTTP Request với FCM Server Key
Firebase Cloud Messaging Service
    ↓ Push qua internet
Device (Android/iOS)
    ↓ Đăng ký FCM Token
Firebase Cloud Messaging Service
```

### 3.2. OneSignal - ⭐ THAY THẾ TỐT CHO FCM

#### ✅ Ưu điểm:
- **Dashboard đẹp**: UI quản lý dễ dùng hơn Firebase
- **Phân tích tốt**: Analytics chi tiết về delivery rate, open rate
- **Tính năng nâng cao**:
  - A/B testing notifications
  - Scheduled notifications
  - Rich notifications (hình ảnh, buttons)
  - Deep linking dễ dàng
- **Miễn phí**: 10,000 subscribers miễn phí/tháng
- **Hỗ trợ đa nền tảng**: Android, iOS, Web, Email, SMS

#### ❌ Nhược điểm:
- Giới hạn ở free tier
- Phụ thuộc vào service bên thứ 3
- Android vẫn dùng FCM ở backend (OneSignal là wrapper)

#### 📦 Packages:
```yaml
dependencies:
  onesignal_flutter: ^5.0.0
```

### 3.3. Local Notifications (flutter_local_notifications)

#### ✅ Ưu điểm:
- **Không cần internet**: Hoạt động offline
- **Không cần server**: Lên lịch từ trong app
- **Nhanh**: Không cần gửi qua mạng

#### ❌ Nhược điểm:
- **Không thể gửi từ server**: Chỉ hoạt động khi app đã chạy
- **Không đánh thức thiết bị**: Khi app đóng hoàn toàn
- **Dùng kết hợp**: Thường dùng với FCM để hiển thị khi app ở foreground

#### 📦 Packages:
```yaml
dependencies:
  flutter_local_notifications: ^16.3.0
```

### 3.4. APNs (Apple Push Notification service) - CHỈ CHO iOS

#### ✅ Ưu điểm:
- Native cho iOS
- Độ tin cậy cao

#### ❌ Nhược điểm:
- Chỉ hoạt động trên iOS
- Cần cấu hình Apple Developer Certificate
- FCM đã hỗ trợ APNs ở backend, không cần implement riêng

---

## 4. SO SÁNH CÁC GIẢI PHÁP

| Tiêu chí | FCM | OneSignal | Local Notifications |
|----------|-----|-----------|-------------------|
| **Miễn phí** | ✅ Không giới hạn | ⚠️ 10K subscribers/tháng | ✅ Hoàn toàn miễn phí |
| **Gửi từ server** | ✅ Có | ✅ Có | ❌ Không |
| **Cài đặt độ khó** | Trung bình | Dễ | Dễ |
| **Dashboard** | Trung bình | ✅ Rất tốt | ❌ Không có |
| **Analytics** | Cơ bản | ✅ Rất chi tiết | ❌ Không có |
| **A/B Testing** | ❌ Không | ✅ Có | ❌ Không |
| **Rich Notifications** | ✅ Có | ✅ Có (tốt hơn) | ✅ Có |
| **Offline Support** | ❌ Không | ❌ Không | ✅ Có |
| **Độ phổ biến** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Documentation** | Tốt | Rất tốt | Tốt |

### ⚡ KẾT LUẬN SO SÁNH:
1. **FCM**: Phù hợp nếu muốn tự kiểm soát, không phụ thuộc service thứ 3
2. **OneSignal**: Phù hợp nếu cần dashboard và analytics tốt, chấp nhận phụ thuộc
3. **Local Notifications**: Dùng kết hợp với FCM/OneSignal, không thể thay thế hoàn toàn

---

## 5. CÁCH CÁC APP LỚN TRIỂN KHAI

### 5.1. Shopee - Hệ thống thông báo đa tầng

#### Các loại thông báo Shopee gửi:

1. **Thông báo đơn hàng**:
   - "Đơn hàng của bạn đang được chuẩn bị"
   - "Đơn hàng đang được giao đến bạn"
   - "Bạn có 1 sản phẩm cần đánh giá"
   
2. **Thông báo khuyến mãi**:
   - "Flash Sale 0đ sắp bắt đầu"
   - "Voucher 50K cho bạn"
   - "Miễn phí ship cho đơn từ 299K"
   
3. **Thông báo livestream**:
   - "Shop đang livestream: [Tên shop]"
   - Hiển thị trong tab "Cập nhật xã hội"
   
4. **Thông báo cá nhân hóa**:
   - "Sản phẩm bạn xem đang giảm giá X%"
   - "Shop bạn thích có sản phẩm mới"
   - "Bạn có X sản phẩm trong giỏ hàng chưa thanh toán"

#### Cách Shopee làm:

```
Backend (Shopee Server)
    ↓
Firebase Cloud Messaging (hoặc custom push service)
    ↓
Device Token Management
    ↓
Push đến thiết bị
    ↓
App hiển thị notification + Deep link
```

#### Tính năng đặc biệt:
- **Rich Notifications**: Có hình ảnh, nút bấm
- **Action Buttons**: "Xem ngay", "Đánh giá ngay"
- **Deep Linking**: Tap vào → mở trực tiếp màn hình liên quan
- **Silent Notifications**: Cập nhật dữ liệu trong app mà không hiển thị
- **Notification Grouping**: Nhóm nhiều thông báo cùng loại

### 5.2. Tiki - Push notification thông minh

#### Đặc điểm:
- Thông báo dựa trên hành vi người dùng
- Phân tích thời gian mở app để gửi đúng lúc
- A/B testing nội dung thông báo
- Sử dụng OneSignal hoặc custom solution tương tự

### 5.3. Lazada

#### Đặc điểm:
- Thông báo "Price Drop" cho sản phẩm đã xem
- Thông báo flash sale theo khu vực
- Sử dụng geolocation để gửi thông báo phù hợp

---

## 6. KHUYẾN NGHỊ CHO SOCDO MOBILE

### 🎯 PHƯƠNG ÁN ĐƯỢC KHUYẾN NGHỊ: **FCM + Local Notifications**

#### Lý do chọn FCM:
1. ✅ **Miễn phí không giới hạn**: Phù hợp với startup, không lo chi phí
2. ✅ **Ổn định và tin cậy**: Google hỗ trợ tốt, ít downtime
3. ✅ **Kiểm soát hoàn toàn**: Không phụ thuộc service thứ 3
4. ✅ **Tích hợp dễ**: Có sẵn package Flutter
5. ✅ **Tương thích tốt**: Android bắt buộc dùng FCM, iOS cũng hỗ trợ

#### Kết hợp với Local Notifications:
- Hiển thị notification khi app ở foreground (FCM không tự hiển thị)
- Lên lịch thông báo local (ví dụ: nhắc nhở xem voucher sắp hết hạn)

### 📋 KIẾN TRÚC ĐỀ XUẤT:

```
┌─────────────────────────────────────────────────────────┐
│                    BACKEND (PHP)                         │
│  ┌──────────────────────────────────────────────────┐   │
│  │  NotificationMobileHelper (đã có)                │   │
│  │  - Tạo thông báo vào DB (đã có)                  │   │
│  │  - Gửi Push qua FCM (CẦN THÊM)                   │   │
│  └──────────────────────────────────────────────────┘   │
│                         │                                │
│                         ▼                                │
│  ┌──────────────────────────────────────────────────┐   │
│  │  FCM Push Service (CẦN TẠO)                      │   │
│  JSON payload:                                       │   │
│  {                                                   │   │
│    "to": "device_token",                             │   │
│    "notification": {                                 │   │
│      "title": "...",                                 │   │
│      "body": "..."                                   │   │
│    },                                                │   │
│    "data": {                                         │   │
│      "type": "order",                                │   │
│      "related_id": 123                               │   │
│    }                                                 │   │
│  }                                                   │   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│              FIREBASE CLOUD MESSAGING                    │
│              (Google Server)                             │
└─────────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│              MOBILE APP (Flutter)                        │
│  ┌──────────────────────────────────────────────────┐   │
│  │  1. Đăng ký FCM Token khi app khởi động          │   │
│  │  2. Gửi Token lên server để lưu vào DB           │   │
│  │  3. Lắng nghe thông báo từ FCM                   │   │
│  │  4. Hiển thị notification (foreground/background)│   │
│  │  5. Xử lý deep linking khi tap notification      │   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

### 🗄️ CẤU TRÚC DATABASE CẦN THÊM:

#### Bảng `device_tokens` (CẦN TẠO MỚI):
```sql
CREATE TABLE `device_tokens` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(11) NOT NULL,
  `device_token` varchar(255) NOT NULL COMMENT 'FCM Token',
  `platform` enum('android','ios') NOT NULL,
  `app_version` varchar(20) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1 COMMENT '1: active, 0: inactive',
  `last_used_at` int(11) DEFAULT NULL,
  `created_at` int(11) NOT NULL,
  `updated_at` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_device` (`user_id`,`device_token`),
  KEY `device_token` (`device_token`),
  KEY `user_id` (`user_id`),
  KEY `is_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

#### Logic:
- Một user có thể có nhiều device tokens (nhiều thiết bị)
- Khi gửi push, gửi đến tất cả tokens của user
- Token có thể bị invalid → đánh dấu `is_active = 0`

### 📱 FLOW HOẠT ĐỘNG:

#### 1. Khi người dùng đăng nhập:
```
App khởi động
    ↓
Yêu cầu quyền notification
    ↓
Lấy FCM Token
    ↓
Gửi Token + user_id lên server
    ↓
Server lưu vào bảng device_tokens
```

#### 2. Khi có sự kiện cần thông báo (ví dụ: đơn hàng mới):
```
Backend nhận sự kiện
    ↓
NotificationMobileHelper tạo thông báo trong DB
    ↓
Lấy device_tokens của user từ DB
    ↓
Gửi request đến FCM API với tất cả tokens
    ↓
FCM gửi push đến các thiết bị
    ↓
App nhận notification → Hiển thị trên màn hình
    ↓
User tap → Deep link vào màn hình đơn hàng
```

#### 3. Khi app ở các trạng thái khác nhau:

**Foreground (App đang mở)**:
- FCM nhận notification nhưng không tự hiển thị
- Cần dùng `flutter_local_notifications` để hiển thị
- Có thể cập nhật UI trực tiếp

**Background (App bị ẩn)**:
- Notification tự hiển thị trên notification tray
- Tap vào → mở app và xử lý deep link

**Terminated (App đã tắt)**:
- Notification tự hiển thị
- Tap vào → khởi động app và xử lý deep link

---

## 7. KIẾN TRÚC HỆ THỐNG ĐỀ XUẤT

### 7.1. Stack công nghệ:

#### Mobile (Flutter):
- `firebase_core`: ^2.24.0
- `firebase_messaging`: ^14.7.9
- `flutter_local_notifications`: ^16.3.0

#### Backend (PHP):
- `curl` để gửi request đến FCM API
- Sử dụng FCM Server Key (lấy từ Firebase Console)

### 7.2. Các file/module cần tạo:

#### Flutter:
1. `lib/src/core/services/push_notification_service.dart`
   - Khởi tạo FCM
   - Lấy và lưu FCM token
   - Xử lý thông báo ở các trạng thái
   - Deep linking

2. `lib/src/core/services/local_notification_service.dart`
   - Hiển thị notification khi app ở foreground
   - Lên lịch local notifications

#### Backend (PHP):
1. `API_WEB/register_device_token.php`
   - Nhận device token từ app
   - Lưu vào bảng `device_tokens`

2. `API_WEB/fcm_push_service.php` (hoặc class)
   - Gửi push notification đến FCM
   - Hỗ trợ gửi đến 1 user, nhiều users, topic

3. Tích hợp vào các file hiện có:
   - `notification_mobile_helper.php`: Thêm gửi push sau khi tạo notification

### 7.3. Ví dụ code flow:

#### Flutter - Khởi tạo:
```dart
// lib/src/core/services/push_notification_service.dart
class PushNotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  
  Future<void> initialize() async {
    // Yêu cầu quyền
    NotificationSettings settings = await _messaging.requestPermission();
    
    // Lấy token
    String? token = await _messaging.getToken();
    
    // Gửi token lên server
    await _registerToken(token);
    
    // Lắng nghe thông báo
    _setupMessageHandlers();
  }
}
```

#### Backend - Gửi push:
```php
// API_WEB/fcm_push_service.php
class FCMPushService {
    private $serverKey = 'YOUR_FCM_SERVER_KEY';
    
    public function sendToUser($userId, $title, $body, $data) {
        // Lấy device tokens của user
        $tokens = $this->getUserTokens($userId);
        
        // Gửi đến từng token
        foreach ($tokens as $token) {
            $this->sendPush($token, $title, $body, $data);
        }
    }
}
```

---

## 8. NEXT STEPS - CÁC BƯỚC TRIỂN KHAI

### Phase 1: Setup cơ bản (Tuần 1)
1. ✅ Tạo Firebase project
2. ✅ Cấu hình Android (google-services.json)
3. ✅ Cấu hình iOS (GoogleService-Info.plist, APNs)
4. ✅ Thêm dependencies vào pubspec.yaml
5. ✅ Tạo bảng device_tokens trong database

### Phase 2: Flutter implementation (Tuần 1-2)
1. ✅ Tạo PushNotificationService
2. ✅ Tạo LocalNotificationService
3. ✅ Tích hợp vào app initialization
4. ✅ Test lấy token và gửi lên server

### Phase 3: Backend implementation (Tuần 2)
1. ✅ Tạo API register_device_token.php
2. ✅ Tạo FCMPushService class
3. ✅ Tích hợp vào NotificationMobileHelper
4. ✅ Test gửi push từ backend

### Phase 4: Testing & Refinement (Tuần 3)
1. ✅ Test ở các trạng thái (foreground/background/terminated)
2. ✅ Test deep linking
3. ✅ Test với nhiều thiết bị
4. ✅ Tối ưu và fix bugs

---

## 9. TÀI LIỆU THAM KHẢO

### Official Documentation:
- [Firebase Cloud Messaging Flutter](https://firebase.flutter.dev/docs/messaging/overview)
- [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications)
- [FCM HTTP v1 API](https://firebase.google.com/docs/cloud-messaging/migrate-v1)

### Best Practices:
- [Google Push Notification Best Practices](https://developer.android.com/develop/ui/views/notifications)
- [Apple Human Interface Guidelines - Notifications](https://developer.apple.com/design/human-interface-guidelines/notifications)

---

## 10. KẾT LUẬN

### ✅ Phương án được chọn: **Firebase Cloud Messaging (FCM) + Local Notifications**

### Lý do:
1. ✅ Miễn phí, không giới hạn
2. ✅ Ổn định, tin cậy cao
3. ✅ Tích hợp dễ dàng với Flutter
4. ✅ Kiểm soát hoàn toàn
5. ✅ Phù hợp với quy mô startup → enterprise

### Điểm khác biệt so với hệ thống hiện tại:
- **Hiện tại**: Chỉ có in-app notifications (phải mở app mới thấy)
- **Sau khi implement**: Có push notifications (hiển thị ngay trên màn hình, kể cả khi app đóng)

### ROI (Return on Investment):
- **Thời gian implement**: 2-3 tuần
- **Chi phí**: 0đ (miễn phí)
- **Lợi ích**: Tăng engagement, giữ chân user, tăng conversion rate

---

**📝 Tài liệu này sẽ được cập nhật khi có thông tin mới hoặc sau khi testing thực tế.**

