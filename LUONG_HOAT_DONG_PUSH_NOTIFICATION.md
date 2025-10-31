# 📱 LUỒNG HOẠT ĐỘNG PUSH NOTIFICATION - TỪ APP ĐẾN MÀN HÌNH ĐIỆN THOẠI

## 🎯 TỔNG QUAN

Hệ thống push notification sử dụng **FCM (Firebase Cloud Messaging)** kết hợp với **flutter_local_notifications** để gửi thông báo từ backend đến màn hình điện thoại của user.

---

## 📊 SƠ ĐỒ LUỒNG HOẠT ĐỘNG

### **PHASE 1: KHỞI TẠO & ĐĂNG KÝ TOKEN**

```
┌─────────────────────────────────────────────────────────────┐
│  1. APP KHỞI ĐỘNG                                          │
│     - main.dart: Firebase.initializeApp()                 │
│     - AppInitializationService.initializeApp()             │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  2. KHỞI TẠO PUSH NOTIFICATION SERVICE                     │
│     - PushNotificationService.initialize()                 │
│     ├─ LocalNotificationService.initialize()               │
│     ├─ Request permission (alert, badge, sound)            │
│     └─ Setup message handlers                              │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  3. LẤY FCM TOKEN                                           │
│     - FirebaseMessaging.instance.getToken()                │
│     → Token: "fXXXXXXXXX..."                                │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  4. ĐĂNG KÝ TOKEN LÊN BACKEND                               │
│     - ApiService.registerDeviceToken()                      │
│     POST /register_device_token                             │
│     Body: {                                                 │
│       user_id: 9016,                                       │
│       device_token: "fXXXXXXXXX...",                       │
│       platform: "android",                                 │
│       device_model: "Samsung Galaxy S21",                   │
│       app_version: "1.0.0"                                 │
│     }                                                       │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  5. BACKEND LƯU TOKEN                                      │
│     - register_device_token.php                             │
│     INSERT INTO device_tokens (...)                         │
│     → Lưu vào DB: device_tokens table                      │
└─────────────────────────────────────────────────────────────┘
```

**Kết quả**: Token đã được lưu, app sẵn sàng nhận push notification.

---

### **PHASE 2: BACKEND GỬI PUSH NOTIFICATION**

```
┌─────────────────────────────────────────────────────────────┐
│  1. SỰ KIỆN XẢY RA (Ví dụ: User đặt hàng)                  │
│     - create_order.php chạy                                │
│     - INSERT INTO donhang (...)                            │
│     - INSERT INTO notification_mobile (...)                │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  2. SHUTDOWN FUNCTION TRIGGER (ASYNC)                      │
│     - register_shutdown_function()                         │
│     → Chạy SAU KHI response 200 đã gửi về client           │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  3. NOTIFICATION HELPER GỬI PUSH                           │
│     - NotificationMobileHelper                               │
│     → sendPushForExistingNotification()                     │
│     → sendPushNotification()                                │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  4. LẤY DEVICE TOKENS TỪ DB                                │
│     - FCMPushServiceV1.sendToUser()                        │
│     SELECT device_token FROM device_tokens                  │
│     WHERE user_id = 9016 AND is_active = 1                 │
│     → Danh sách tokens: ["fXXX...", "fYYY..."]            │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  5. TẠO JWT & LẤY ACCESS TOKEN                             │
│     - FCMPushServiceV1.getAccessToken()                    │
│     ├─ Tạo JWT từ Service Account JSON                    │
│     ├─ Sign JWT với private key (RS256)                   │
│     └─ POST https://oauth2.googleapis.com/token            │
│        → Access Token: "ya29.XXXXX..."                     │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  6. GỬI PUSH ĐẾN FCM API                                    │
│     - FCMPushServiceV1.sendToDevice()                      │
│     POST https://fcm.googleapis.com/v1/projects/           │
│          socdomobile/messages:send                          │
│     Headers:                                                │
│       Authorization: Bearer ya29.XXXXX...                  │
│       Content-Type: application/json                       │
│     Body: {                                                 │
│       message: {                                            │
│         token: "fXXX...",                                  │
│         notification: {                                     │
│           title: "Đơn hàng mới #DH251030...",              │
│           body: "Bạn vừa đặt đơn hàng..."                  │
│         },                                                 │
│         data: {                                             │
│           type: "order",                                   │
│           related_id: "12345",                             │
│           order_code: "DH251030..."                        │
│         }                                                  │
│       }                                                     │
│     }                                                       │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  7. FCM GỬI PUSH ĐẾN THIẾT BỊ                               │
│     - FCM Server nhận request                              │
│     - Gửi push đến Google Play Services (Android)          │
│     - Google Play Services gửi đến thiết bị                │
└─────────────────────────────────────────────────────────────┘
```

---

### **PHASE 3: APP NHẬN & HIỂN THỊ NOTIFICATION**

#### **3.1. App ở FOREGROUND (App đang mở)**

```
┌─────────────────────────────────────────────────────────────┐
│  1. FCM GỬI PUSH ĐẾN APP                                    │
│     - FirebaseMessaging.onMessage.listen()                  │
│     → _handleForegroundMessage()                            │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  2. FCM KHÔNG TỰ HIỂN THỊ KHI APP FOREGROUND               │
│     → Cần dùng LocalNotificationService                     │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  3. HIỂN THỊ LOCAL NOTIFICATION                            │
│     - LocalNotificationService.showNotification()           │
│     - FlutterLocalNotificationsPlugin.show()                │
│     → Notification xuất hiện trên màn hình                  │
│     → User thấy:                                            │
│        📱 "Đơn hàng mới #DH251030..."                      │
│        "Bạn vừa đặt đơn hàng..."                           │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  4. USER TAP NOTIFICATION                                   │
│     - LocalNotificationService.onNotificationTap()          │
│     → NotificationHandler.handleNotificationData()            │
│     → Navigate đến OrderDetailScreen                        │
└─────────────────────────────────────────────────────────────┘
```

#### **3.2. App ở BACKGROUND (App bị ẩn)**

```
┌─────────────────────────────────────────────────────────────┐
│  1. FCM GỬI PUSH ĐẾN APP                                    │
│     - firebaseMessagingBackgroundHandler()                  │
│     → Chỉ log, không hiển thị UI                            │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  2. ANDROID TỰ ĐỘNG HIỂN THỊ NOTIFICATION                  │
│     - Google Play Services nhận push                        │
│     - Android System hiển thị notification                 │
│     → Notification tray xuất hiện                           │
│     → User thấy notification trên thanh status bar         │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  3. USER TAP NOTIFICATION                                   │
│     - FirebaseMessaging.onMessageOpenedApp.listen()          │
│     → NotificationHandler.handleNotificationData()          │
│     → App mở lên → Navigate đến OrderDetailScreen          │
└─────────────────────────────────────────────────────────────┘
```

#### **3.3. App ở TERMINATED (App đã tắt)**

```
┌─────────────────────────────────────────────────────────────┐
│  1. FCM GỬI PUSH ĐẾN APP                                    │
│     - Android System nhận push                             │
│     - Hiển thị notification trên notification tray          │
│     → User thấy notification                                │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  2. USER TAP NOTIFICATION                                   │
│     - App khởi động lại                                    │
│     - FirebaseMessaging.instance.getInitialMessage()        │
│     → NotificationHandler.handleNotificationData()            │
│     → Navigate đến OrderDetailScreen                        │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔧 CÁC THÀNH PHẦN CHÍNH

### **FLUTTER APP (Client-side)**

#### 1. **PushNotificationService** (`lib/src/core/services/push_notification_service.dart`)
- **Chức năng**:
  - Khởi tạo FCM
  - Lấy và đăng ký FCM token
  - Lắng nghe và xử lý push notifications
  - Xử lý token refresh

- **Methods chính**:
  ```dart
  initialize()                    // Khởi tạo service
  _getAndRegisterToken()          // Lấy FCM token và đăng ký
  _handleForegroundMessage()      // Xử lý khi app ở foreground
  _handleNotificationTap()        // Xử lý khi user tap notification
  ```

#### 2. **LocalNotificationService** (`lib/src/core/services/local_notification_service.dart`)
- **Chức năng**:
  - Hiển thị notification khi app ở foreground
  - FCM không tự hiển thị khi app đang mở → cần local notification

- **Methods chính**:
  ```dart
  initialize()                    // Khởi tạo local notifications
  showNotification()              // Hiển thị notification
  ```

#### 3. **NotificationHandler** (`lib/src/core/services/notification_handler.dart`)
- **Chức năng**:
  - Xử lý deep linking khi user tap notification
  - Navigate đến màn hình phù hợp (OrderDetail, Voucher, Balance, ...)

- **Methods chính**:
  ```dart
  handleNotificationData()        // Parse data và navigate
  _navigateToOrderDetail()        // Navigate đến order detail
  _navigateToVouchers()           // Navigate đến voucher list
  ```

### **BACKEND (Server-side)**

#### 1. **register_device_token.php**
- **Chức năng**: Nhận và lưu FCM token từ app
- **Input**: `user_id`, `device_token`, `platform`, `device_model`, `app_version`
- **Output**: Lưu vào bảng `device_tokens`

#### 2. **NotificationMobileHelper** (`API_WEB/notification_mobile_helper.php`)
- **Chức năng**: Tạo notification và gửi push
- **Methods chính**:
  ```php
  createNotification()                    // Tạo notification trong DB
  notifyNewOrder()                        // Thông báo đơn hàng mới
  sendPushNotification()                  // Gửi push notification
  sendPushForExistingNotification()       // Gửi push cho notification đã tồn tại (async)
  ```

#### 3. **FCMPushServiceV1** (`API_WEB/fcm_push_service_v1.php`)
- **Chức năng**: Gửi push notification qua FCM HTTP V1 API
- **Methods chính**:
  ```php
  getAccessToken()              // Lấy access token từ Service Account JSON
  sendToUser()                  // Gửi push đến 1 user (lấy tất cả tokens của user)
  sendToDevice()                // Gửi push đến 1 device token
  sendToMultipleDevices()       // Gửi push đến nhiều devices
  ```

---

## 📋 DATA FLOW

### **1. Token Registration Flow**
```
App (Flutter)
  ├─ PushNotificationService.initialize()
  ├─ FirebaseMessaging.getToken()
  ├─ ApiService.registerDeviceToken()
  │  └─ POST /register_device_token
  │
Backend (PHP)
  ├─ register_device_token.php
  ├─ Validate JWT token
  ├─ Validate input
  └─ INSERT INTO device_tokens
```

### **2. Push Notification Flow**
```
Backend Event (ví dụ: đơn hàng mới)
  ├─ create_order.php
  │  ├─ INSERT INTO donhang
  │  └─ INSERT INTO notification_mobile
  │
  ├─ register_shutdown_function() [ASYNC]
  │  └─ NotificationMobileHelper.sendPushForExistingNotification()
  │     └─ sendPushNotification()
  │        └─ FCMPushServiceV1.sendToUser()
  │           ├─ SELECT device_tokens FROM DB
  │           ├─ getAccessToken() (JWT → OAuth2 token)
  │           └─ POST FCM API với access token
  │
FCM Server
  ├─ Validate access token
  ├─ Gửi push đến Google Play Services
  └─ Google Play Services → Device
     │
App (Flutter)
  ├─ [Foreground] onMessage → LocalNotificationService.show()
  ├─ [Background] System tự hiển thị
  └─ [Terminated] System tự hiển thị
     │
User Tap Notification
  ├─ NotificationHandler.handleNotificationData()
  └─ Navigate đến màn hình phù hợp
```

---

## 🎯 CÁC TRƯỜNG HỢP XỬ LÝ

### **1. App ở FOREGROUND**
- **FCM behavior**: Nhận message nhưng không tự hiển thị
- **Solution**: Dùng `LocalNotificationService` để hiển thị
- **Flow**: `onMessage` → `_handleForegroundMessage()` → `LocalNotificationService.showNotification()`

### **2. App ở BACKGROUND**
- **FCM behavior**: System tự động hiển thị notification
- **Flow**: `firebaseMessagingBackgroundHandler()` → System hiển thị → User tap → `onMessageOpenedApp`

### **3. App ở TERMINATED**
- **FCM behavior**: System tự động hiển thị notification
- **Flow**: System hiển thị → User tap → App khởi động → `getInitialMessage()` → Navigate

### **4. Token Refresh**
- **Khi nào**: FCM token tự động refresh định kỳ
- **Flow**: `onTokenRefresh.listen()` → `_handleTokenRefresh()` → `_registerTokenToServer()`

---

## ✅ CHECKLIST HOẠT ĐỘNG

### **Client-side (Flutter)**
- [x] Firebase initialized trong `main.dart`
- [x] PushNotificationService khởi tạo khi user login
- [x] FCM token được lấy và đăng ký lên backend
- [x] Listen các message handlers (foreground, background, terminated)
- [x] LocalNotificationService hiển thị khi app foreground
- [x] NotificationHandler xử lý deep linking

### **Server-side (PHP)**
- [x] register_device_token.php nhận và lưu token
- [x] NotificationMobileHelper tạo notification và gửi push
- [x] FCMPushServiceV1 gửi push qua FCM HTTP V1 API
- [x] Push notification chạy async (không block create_order response)

---

## 📝 NOTES QUAN TRỌNG

1. **Token Registration**: Token chỉ được đăng ký khi user đã login
2. **Async Push**: Push notification được gửi async (shutdown function) để không ảnh hưởng response
3. **Foreground Handling**: FCM không tự hiển thị khi app mở → phải dùng LocalNotificationService
4. **Deep Linking**: Notification data chứa `type` và `related_id` để navigate đúng màn hình
5. **Error Handling**: Nếu push fail, đơn hàng vẫn được tạo thành công (không ảnh hưởng)

---

**📅 Created**: 2025-01-XX  
**✅ Status**: Complete - Full flow documented

