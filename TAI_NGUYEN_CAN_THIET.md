# 📋 TÀI NGUYÊN CẦN THIẾT ĐỂ IMPLEMENT FCM

## 🎯 DANH SÁCH TÀI NGUYÊN

### 1. 🔥 FIREBASE ACCOUNT & PROJECT

#### ✅ Cần có:
- **Firebase account** (dùng Google account)
  - Nếu chưa có → Tạo tại [firebase.google.com](https://firebase.google.com)
  - Miễn phí hoàn toàn.

- **Firebase Project**
  - Tôi sẽ hướng dẫn tạo trong quá trình implement
  - Cần có quyền tạo project trong Firebase Console

#### 📦 Bạn cần cung cấp:
- ✅ Google account để login Firebase (hoặc tự tạo)
- ✅ Quyền truix cập Firebase Console (nếu có team)

#### 🔑 Kết quả sẽ có:
- Firebase Project ID
- FCM Server Key (sẽ được lưu an toàn)

---

### 2. 🍎 APPLE DEVELOPER ACCOUNT (CHO iOS)

#### ✅ Cần có:
- **Apple Developer Account**
  - Giá: **$99/năm**
  - Đăng ký tại [developer.apple.com](https://developer.apple.com)
  - Cần để tạo APNs (Apple Push Notification service) key

#### ⚠️ Lưu ý:
- Nếu **chỉ deploy Android** → không cần Apple Developer account
- Nếu **cần deploy iOS** → bắt buộc phải có
- Có thể implement Android trước, iOS sau

#### 📦 Bạn cần cung cấp:
- ✅ Apple Developer account credentials (hoặc tự tạo)
- ✅ Quyền truy cập Apple Developer portal

#### 🔑 Kết quả sẽ có:
- APNs Authentication Key (.p8 file)
- Key ID
- Team ID

---

### 3. 💾 DATABASE ACCESS

#### ✅ Cần có:
- **Quyền truy cập database**
  - Tạo bảng mới (`device_tokens`)
  - INSERT, UPDATE, SELECT trên bảng mới
  - Có thể cần CREATE INDEX

#### 📦 Bạn cần cung cấp:
- ✅ Database credentials (hoặc tôi sẽ hướng dẫn tạo bảng)
- ✅ Quyền CREATE TABLE (hoặc file SQL để bạn chạy)

#### 🔑 Kết quả sẽ có:
- Bảng `device_tokens` trong database
- SQL migration file (`device_tokens.sql`)

---

### 4. 🖥️ BACKEND SERVER ACCESS

#### ✅ Cần có:
- **Quyền deploy files lên server**
  - Upload PHP files mới
  - Sửa PHP files hiện có
  - Tạo config files

#### 📦 Bạn cần cung cấp:
- ✅ Server access (FTP/SFTP/SSH) hoặc repo access
- ✅ Hoặc tôi sẽ tạo files, bạn tự deploy

#### 🔑 Kết quả sẽ có:
- `API_WEB/register_device_token.php`
- `API_WEB/fcm_push_service.php`
- `API_WEB/fcm_config.php`
- Updated `API_WEB/notification_mobile_helper.php`

---

### 5. 📱 APP CONFIGURATION

#### ✅ Cần có:
- **Android Package Name**
  - Lấy từ `android/app/build.gradle.kts`
  - Ví dụ: `com.example.socdo`

- **iOS Bundle ID**
  - Lấy từ Xcode project
  - Ví dụ: `com.example.socdo`

#### 📦 Bạn cần cung cấp:
- ✅ Package name/Bundle ID của app
- ✅ Hoặc tôi sẽ lấy từ project files

#### 🔑 Kết quả sẽ có:
- `google-services.json` (Android)
- `GoogleService-Info.plist` (iOS)

---

### 6. 🔐 KEYS & CREDENTIALS (SAU KHI SETUP FIREBASE)

#### ✅ Sẽ có sau khi setup Firebase:
- **FCM Server Key**
  - Lấy từ Firebase Console
  - Dùng để gửi push từ backend
  - **QUAN TRỌNG**: Không được commit vào Git

- **Android SHA-1 Certificate** (tùy chọn)
  - Để Google Sign-In, Dynamic Links
  - Không bắt buộc cho FCM

#### 📦 Bạn cần làm:
- ✅ Lưu FCM Server Key an toàn (không commit Git)
- ✅ Hoặc tôi sẽ tạo config file, bạn điền key vào

---

## 📝 CHECKLIST CHO BẠN

### Trước khi bắt đầu:

#### Firebase:
- [ ] Có Google account (hoặc sẵn sàng tạo)
- [ ] Có thể truy cập [Firebase Console](https://console.firebase.google.com)
- [ ] Quyết định tên Firebase project (ví dụ: `socdo-mobile`)

#### iOS (nếu cần):
- [ ] Có Apple Developer account ($99/năm)
- [ ] Có thể truy cập [Apple Developer Portal](https://developer.apple.com)
- [ ] Biết Bundle ID của iOS app

#### Database:
- [ ] Có quyền CREATE TABLE trong database
- [ ] Hoặc có thể chạy SQL scripts
- [ ] Database name: `socdo` (hoặc tên khác?)

#### Backend:
- [ ] Có quyền upload/sửa files trong `API_WEB/`
- [ ] Hoặc có Git access để commit
- [ ] Server đã có PHP + cURL enabled

#### App:
- [ ] Có thể build và run app trên device/emulator
- [ ] Có thể test trên Android device (hoặc iOS nếu cần)

---

## 🚫 NHỮNG GÌ KHÔNG CẦN

### ❌ Không cần:
- **Thêm server/hosting** - FCM tự động xử lý
- **Thêm database** - chỉ cần thêm 1 bảng
- **Thêm domains** - dùng Firebase domain
- **SSL certificates** - Firebase đã có HTTPS
- **Monitoring tools** - Firebase Console có sẵn
- **Payment** - FCM hoàn toàn miễn phí (trừ Apple Developer nếu cần iOS)

---

## 📋 WORKFLOW ĐỀ XUẤT

### Option 1: Tôi làm hết (Bạn cung cấp credentials)
1. Bạn cung cấp Firebase account access
2. Bạn cung cấp database access hoặc SQL scripts
3. Bạn cung cấp backend server access
4. Tôi implement và test

### Option 2: Tôi hướng dẫn (Bạn tự làm)
1. Tôi tạo hướng dẫn chi tiết từng bước
2. Tôi tạo code/files
3. Bạn setup Firebase, deploy backend, test
4. Tôi hỗ trợ khi gặp vấn đề

### Option 3: Kết hợp (Recommended)
1. **Tôi làm**:
   - Tạo Firebase project structure
   - Viết code Flutter và PHP
   - Tạo SQL scripts
   - Tạo documentation

2. **Bạn làm**:
   - Tạo Firebase project (hoặc cho tôi access)
   - Chạy SQL scripts
   - Deploy backend files
   - Test trên device

---

## 💡 LƯU Ý QUAN TRỌNG

### 🔐 Bảo mật:
- ⚠️ **FCM Server Key** không được commit vào Git
- ✅ Sử dụng `.env` file hoặc config file riêng
- ✅ Server Key chỉ được dùng ở backend

### 📱 Testing:
- ✅ Test trên **real device** (emulator có thể có vấn đề)
- ✅ Test cả Android và iOS nếu cần
- ✅ Test các trạng thái: foreground, background, terminated

### 🚀 Deployment:
- ✅ Test kỹ trên staging trước khi lên production
- ✅ Backup database trước khi chạy migration
- ✅ Có rollback plan nếu có vấn đề

---

## ✅ SẴN SÀNG BẮT ĐẦU?

Khi bạn đã có:
1. ✅ Firebase account (hoặc sẵn sàng tạo)
2. ✅ Database access (hoặc SQL access)
3. ✅ Backend access (hoặc có thể deploy)
4. ✅ App có thể build và chạy

→ **SẴN SÀNG BẮT ĐẦU IMPLEMENT!** 🚀

---

**📅 Cập nhật**: `2025-01-XX`
**👤 Chuẩn bị bởi**: AI Assistant
**📌 Status**: Ready when you are!

