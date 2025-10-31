# 🗺️ ROADMAP IMPLEMENTATION - FCM PUSH NOTIFICATIONS

## 📋 TỔNG QUAN

Tài liệu này mô tả chi tiết từng bước để implement FCM Push Notifications vào dự án Socdo Mobile.

**Thời gian ước tính**: 2-3 tuần  
**Độ khó**: Trung bình  
**Yêu cầu**: Firebase account, Apple Developer account (cho iOS)

---

## 🎯 CÁC BƯỚC TỔNG QUAN

```
Phase 1: Setup Firebase & Configuration (Tuần 1)
    ↓
Phase 2: Database Setup (Tuần 1)
    ↓
Phase 3: Flutter Implementation (Tuần 1-2)
    ↓
Phase 4: Backend Implementation (Tuần 2)
    ↓
Phase 5: Integration & Testing (Tuần 3)
    ↓
Phase 6: Production Deployment (Tuần 3)
```

---

## 📦 PHASE 1: SETUP FIREBASE & CONFIGURATION

### Step 1.1: Tạo Firebase Project
**Mục tiêu**: Tạo project Firebase và cấu hình cơ bản

#### Các bước:
1. Truy cập [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" (hoặc "Create a project")
3. Đặt tên project: `socdo-mobile` (hoặc tên bạn muốn)
4. Chọn Google Analytics (khuyến nghị: Enable)
5. Chọn Google Analytics account (hoặc tạo mới)
6. Click "Create project"

#### Kết quả:
- ✅ Firebase Project được tạo
- ✅ Project ID được assign
- ✅ Có thể truy cập Firebase Console

---

### Step 1.2: Thêm Android App vào Firebase

**Mục tiêu**: Setup Android app để có thể nhận push notifications

#### Các bước:
1. Trong Firebase Console, click "Add app" → Chọn Android
2. Điền thông tin:
   - **Package name**: Lấy từ `android/app/build.gradle.kts`
     - Tìm: `applicationId = "com.example.socdo"` (hoặc tên tương tự)
   - **App nickname**: `Socdo Android` (tùy chọn)
   - **Debug signing certificate SHA-1**: (Bỏ qua lần này, có thể thêm sau)
3. Click "Register app"
4. Tải file `google-services.json`
5. Đặt file vào: `android/app/google-services.json`

#### Cấu hình Android:
1. Mở `android/build.gradle.kts`
2. Thêm vào `dependencies`:
```kotlin
dependencies {
    classpath("com.google.gms:google-services:4.4.0")
}
```

3. Mở `android/app/build.gradle라.kts`
4. Thêm ở đầu file:
```kotlin
plugins {
    id("com.google.gms.google-services")
}
```

#### Kết quả:
- ✅ File `google-services.json` đã được thêm
- ✅ Android build config đã được cập nhật
- ✅ Android app đã được đăng ký với Firebase

---

### Step 1.3: Thêm iOS App vào Firebase

**Mục tiêu**: Setup iOS app để có thể nhận push notifications

#### Yêu cầu trước:
- ✅ Apple Developer account ($99/năm)
- ✅ Bundle ID của iOS app

#### Các bước:
1. Trong Firebase Console, click "Add app" → Chọn iOS
2. Điền thông tin:
   - **Bundle ID**: Lấy từ Xcode project
     - Mở `ios/Runner.xcodeproj`
     - Tìm trong "Signing & Capabilities" → Bundle Identifier
   - **App nickname**: `Socdo iOS` (tùy chọn)
   - **App Store ID**: (Bỏ qua nếu chưa có)
3. Click "Register app"
4. Tải file `GoogleService-Info.plist`
5. Mở Xcode: `ios/Runner.xcworkspace`
6. Drag & drop file `GoogleService-Info.plist` vào `Runner` folder trong Xcode
7. Đảm bảo "Copy items if needed" được check

#### Cấu hình iOS - APNs (Apple Push Notification service):
1. **Tạo APNs Key**:
   - Truy cập [Apple Developer](https://developer.apple.com/account/)
   - Vào "Certificates, Identifiers & Profiles"
   - Click "Keys" → "+"
   - Đặt tên: "Socdo Push Notification Key"
   - Check "Apple Push Notifications service (APNs)"
   - Click "Continue" → "Register"
   - **Download key file** (chỉ tải được 1 lần!)

2. **Upload APNs Key vào Firebase**:
   - Vào Firebase Console → Project Settings → Cloud Messaging
   - Tab "Apple app configuration"
   - Upload APNs Authentication Key (file .p8 vừa tải)
   - Điền Key ID và Team ID

#### Kết quả:
- ✅ File `GoogleService-Info.plist` đã được thêm
- ✅ APNs đã được cấu hình
- ✅ iOS app đã được đăng ký với Firebase

---

### Step 1.4: Lấy FCM Server Key

**Mục tiêu**: Lấy Server Key để backend có thể gửi push notifications

#### Các bước:
1. Vào Firebase Console → Project Settings
2. Tab "Cloud Messaging"
3. Tìm "Server key" (Android) hoặc "Cloud Messaging API (Legacy)"
4. Copy Server Key (sẽ dùng cho backend)

#### Lưu ý bảo mật:
- ⚠️ **KHÔNG commit Server Key vào Git**
- ✅ Lưu vào file config riêng (`.env` hoặc config file)
- ✅ Đặt trong server, không expose ra client

#### Kết quả:
- ✅ Có FCM Server Key
- ✅ Key đã được lưu an toàn

---

## 🗄️ PHASE 2: DATABASE SETUP

### Step 2.1: Tạo bảng `device_tokens`

**Mục tiêu**: Lưu FCM tokens của các thiết bị người dùng

#### Tạo file SQL:
**File**: `database_web/device_tokens.sql`

```sql
-- phpMyAdmin SQL Dump
-- Table: device_tokens
-- Mô tả: Lưu FCM tokens để gửi push notifications

CREATE TABLE `device_tokens` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(11) NOT NULL COMMENT 'ID người dùng',
  `device_token` varchar(255) NOT NULL COMMENT 'FCM Token từ Firebase',
  `platform` enum('android','ios') NOT NULL COMMENT 'Nền tảng: android hoặc ios',
  `app_version` varchar(20) DEFAULT NULL COMMENT 'Version của app (ví dụ: 1.0.0)',
  `device_model` varchar(100) DEFAULT NULL COMMENT 'Model thiết bị (ví dụ: Samsung Galaxy S21)',
  `is_active` tinyint(1) DEFAULT 1 COMMENT '1: active (nhận push), 0: inactive',
  `last_used_at` int(11) DEFAULT NULL COMMENT 'Timestamp lần cuối sử dụng token',
  `created_at` int(11) NOT NULL COMMENT 'Timestamp tạo record',
  `updated_at` int(11) DEFAULT NULL COMMENT 'Timestamp cập nhật',
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_device_token` (`user_id`,`device_token`),
  KEY `device_token` (`device_token`),
  KEY `user_id` (`user_id`),
  KEY `is_active` (`is_active`),
  KEY `platform` (`platform`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

#### Chạy SQL:
1. Mở phpMyAdmin hoặc database client
2. Chọn database `socdo` (hoặc tên database của bạn)
3. Import file `device_tokens.sql`

#### Kết quả:
- ✅ Bảng `device_tokens` đã được tạo
- ✅ Indexes đã được setup để query nhanh

---

## 📱 PHASE 3: FLUTTER IMPLEMENTATION

### Step 3.1: Thêm Dependencies

**Mục tiêu**: Thêm các packages cần thiết

#### Cập nhật `pubspec.yaml`:
```yaml
dependencies:
  # ... existing dependencies ...
  
  # Firebase
  firebase_core: ^2.24.0
  firebase_messaging: ^14.7.9
  
  # Local Notifications (để hiển thị khi app ở foreground)
  flutter_local_notifications: ^16.3.0
```

#### Chạy:
```bash
flutter pub get
```

#### Kết quả:
- ✅ Packages đã được cài đặt
- ✅ Dependencies đã được resolve

---

### Step 3.2: Khởi tạo Firebase trong main.dart

**Mục tiêu**: Initialize Firebase khi app start

#### Sửa `lib/main.dart`:
```dart
import 'package:firebase_core/firebase_core.dart';
import 'src/app.dart';
import 'src/core/services/app_initialization_service.dart';
import 'src/core/services/app_lifecycle_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // KHỞI TẠO FIREBASE TRƯỚC
  await Firebase.initializeApp();
  
  // Khởi tạo app services
  await _initializeApp();
  
  runApp(const SocdoApp());
}

// ... rest of code ...
```

#### Kết quả:
- ✅ Firebase đã được khởi tạo
- ✅ App có thể sử dụng Firebase services

---

### Step 3.3: Tạo PushNotificationService

**Mục tiêu**: Service chính để quản lý push notifications

#### Tạo file: `lib/src/core/services/push_notification_service.dart`

**Chức năng chính**:
1. Initialize FCM
2. Request notification permission
3. Get FCM token
4. Register token lên server
5. Listen for notifications
6. Handle notification tap (deep linking)

#### Kết quả:
- ✅ Service đã được tạo
- ✅ Có thể get FCM token

---

### Step 3.4: Tạo LocalNotificationService

**Mục tiêu**: Hiển thị notification khi app ở foreground

#### Tạo file: `lib/src/core/services/local_notification_service.dart`

**Chức năng chính**:
1. Initialize local notifications
2. Hiển thị notification khi app ở foreground
3. Handle notification tap

#### Kết quả:
- ✅ Service đã được tạo
- ✅ Có thể hiển thị notification trong app

---

### Step 3.5: Tạo NotificationHandler

**Mục tiêu**: Xử lý deep linking khi user tap notification

#### Tạo file: `lib/src/core/services/notification_handler.dart`

**Chức năng chính**:
1. Parse notification data
2. Navigate đến màn hình phù hợp
3. Handle các loại notifications khác nhau (order, voucher, etc.)

#### Kết quả及格:
- ✅ Handler đã được tạo
- ✅ Deep linking hoạt động

---

### Step 3.6: Tích hợp vào AppInitializationService

**Mục tiêu**: Khởi tạo push notification service khi app start

#### Sửa `lib/src/core/services/app_initialization_service.dart`:
- Thêm init PushNotificationService
- Register token sau khi login

#### Kết quả:
- ✅ Push service tự động khởi tạo khi app start
- ✅ Token tự động được register

---

### Step 3.7: Tích hợp vào AuthService

**Mục tiêu**: Register token khi user login

#### Sửa `lib/src/core/services/auth_service.dart`:
- Sau khi login thành công → register FCM token

#### Kết quả detergent:
- ✅ Token được register khi login
- ✅ Token được update khi user switch account

---

## 🔧 PHASE 4: BACKEND IMPLEMENTATION

### Step 4.1: Tạo API register_device_token.php

**Mục tiêu**: API để app gửi FCM token lên server

#### Tạo file: `API_WEB/register_device_token.php`

**Chức năng**:
1. Nhận FCM token từ app
2. Lưu/update vào bảng `device_tokens`
3. Handle multiple devices của 1 user
4. Mark old tokens as inactive nếu cần

#### Kết quả:
- ✅ API endpoint đã sẵn sàng
- ✅ Token được lưu vào database

---

### Step 4.2: Tạo FCMPushService class

**Mục tiêu**: Service để gửi push notifications qua FCM API

#### Tạo file: `API_WEB/fcm_push_service.php`

**Chức năng**:
1. Send push to 1 user (lấy tất cả tokens của user)
2. Send push to multiple users
3. Send push to specific device token
4. Handle FCM API response
5. Mark invalid tokens as inactive

#### Kết quả:
- ✅ Service đã được tạo
- ✅ Có thể gửi push từ backend

---

### Step 4.3: Tạo FCM Config file

**Mục tiêu**: Lưu FCM Server Key an toàn

#### Tạo file: `API_WEB/fcm_config.php`
- Lưu FCM Server Key
- Không commit vào Git (thêm vào .gitignore)

#### Kết quả:
- ✅ Config đã được setup
- ✅ Key được bảo mật

---

### Step 4.4: Tích hợp vào NotificationMobileHelper

**Mục tiêu**: Tự động gửi push khi tạo notification

#### Sửa `API_WEB/notification_mobile_helper.php`:
- Sau khi tạo notification → gọi FCMPushService

#### Kết quả:
- ✅ Push tự động gửiág khi có notification mới

---

## 🧪 PHASE 5: TESTING

### Step 5.1: Test Basic Flow
- ✅ Test get FCM token
- ✅ Test register token lên server
- ✅ Test gửi push từ backend
- ✅ Test nhận notification

### Step 5.2: Test Different States
- ✅ Test khi app ở foreground
- ✅ Test khi app ở background
- ✅ Test khi app terminated
- ✅ Test deep linking

### Step 5.3: Test Edge Cases
- ✅ Test với nhiều devices của 1 user
- ✅ Test với invalid token
- ✅ Test với user không có device token
- ✅ Test với network issues

---

## 🚀 PHASE 6: PRODUCTION DEPLOYMENT

### Step 6.1: Review và Cleanup
- ✅ Review code
- ✅ Remove debug logs
- ✅ Update documentation

### Step 6.2: Deploy Backend
- ✅ Deploy PHP files
- ✅ Update database
- ✅ Test trên production server

### Step 6.3: Deploy App
- ✅ Build release APK/IPA
- ✅ Test trên real devices
- ✅ Release lên stores

---

## 📋 CHECKLIST TỔNG HỢP

### Tài nguyên cần có:
- [ ] Firebase account (Google account)
- [ ] Firebase project đã tạo
- [ ] Apple Developer account ($99/năm) - nếu deploy iOS
- [ ] APNs key đã tạo và upload lên Firebase
- [ ] Database access để tạo bảng mới
- [ ] Server access để deploy backend files

### Files cần tạo:
- [ ] `google-services.json` (Android)
- [ ] `GoogleService-Info.plist` (iOS)
- [ ] `device_tokens.sql`
- [ ] `lib/src/core/services/push_notification_service.dart`
- [ ] `lib/src/core/services/local_notification_service.dart`
- [ ] `lib/src/core/services/notification_handler.dart`
- [ ] `API_WEB/register_device_token.php`
- [ ] `API_WEB/fcm_push_service.php`
- [ ] `API_WEB/fcm_config.php`

### Files cần sửa:
- [ ] `pubspec.yaml`
- [ ] `lib/main.dart`
- [ ] `android/build.gradle.kts`
- [ ] `android/app/build.gradle.kts`
- [ ] `lib/src/core/services/app_initialization_service.dart`
- [ ] `lib/src/core/services/auth_service.dart`
- [ ] `API_WEB/notification_mobile_helper.php`

---

**📅 Cập nhật**: `2025-01-XX`
**⏱️ Thời gian ước tính**: 2-3 tuần
**✅ Status**: Ready to implement

