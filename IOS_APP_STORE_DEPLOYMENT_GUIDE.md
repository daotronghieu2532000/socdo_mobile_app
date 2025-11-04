# 📱 HƯỚNG DẪN BUILD VÀ DEPLOY IOS APP LÊN APP STORE

## 📋 TỔNG QUAN DỰ ÁN

**App Name:** Socdo Mobile  
**Platform:** Flutter (đã build thành công Android APK)  
**Mục tiêu:** Build iOS app và deploy lên App Store

### Hiện trạng:
- ✅ Android APK đã build thành công
- ✅ Firebase đã được config cho Android
- ✅ iOS folder đã có cấu trúc cơ bản
- ⚠️ Chưa có Apple Developer Account setup
- ⚠️ Chưa có Firebase iOS config (GoogleService-Info.plist)
- ⚠️ Chưa có iOS permissions trong Info.plist
- ⚠️ Bundle ID chưa đúng production (đang là `com.example.socdo`)

---

## 🎯 PHẦN 1: CHUẨN BỊ VÀ YÊU CẦU

### 1.1. Apple Developer Account
**Bắt buộc:** Cần có Apple Developer Account ($99/năm)
- Đăng ký tại: https://developer.apple.com/programs/
- Cần có để:
  - Tạo App ID
  - Tạo Provisioning Profiles
  - Submit app lên App Store
  - Tạo APNs Key cho Firebase

**Thời gian:** 1-3 ngày (nếu chưa có account)

### 1.2. Mac Computer
**Bắt buộc:** Cần máy Mac để:
- Build iOS app (không thể build trên Windows/Linux)
- Mở Xcode để config project
- Archive và upload app lên App Store Connect

**Lựa chọn thay thế:**
- Dùng macOS trên máy ảo (không được Apple khuyến nghị)
- Dùng dịch vụ CI/CD cloud (Codemagic, Bitrise, AppCircle)
- Thuê máy Mac build service

**Thời gian:** Ngay nếu có Mac, hoặc cần thuê/service

### 1.3. Firebase Project
**Trạng thái:** Đã có project `socdomobile` cho Android
**Cần làm:** Thêm iOS app vào Firebase project

### 1.4. Xcode
**Cần cài đặt:** Xcode từ Mac App Store (miễn phí)
- Version mới nhất được khuyến nghị
- Cần cài đặt Command Line Tools

---

## 🔧 PHẦN 2: CẤU HÌNH DỰ ÁN

### 2.1. Cập nhật Bundle Identifier

**Vấn đề hiện tại:**  
Bundle ID đang là `com.example.socdo` (example bundle ID không được chấp nhận trên App Store)

**Cần thay đổi thành:** `com.socdo.mobile` (để khớp với Android: `com.socdo.mobile`)

**Các file cần sửa:**

#### A. `ios/Runner.xcodeproj/project.pbxproj`
Tìm và thay thế tất cả `com.example.socdo` thành `com.socdo.mobile`

#### B. Xcode Project Settings
1. Mở Xcode: `ios/Runner.xcworkspace`
2. Chọn target `Runner`
3. Vào tab "Signing & Capabilities"
4. Thay đổi Bundle Identifier thành `com.socdo.mobile`

**Thời gian:** 15 phút

---

### 2.2. Thêm iOS App vào Firebase

**Bước 1:** Đăng nhập Firebase Console
- Truy cập: https://console.firebase.google.com
- Chọn project `socdomobile`

**Bước 2:** Thêm iOS app
1. Click "Add app" → Chọn iOS
2. Điền thông tin:
   - **Bundle ID:** `com.socdo.mobile`
   - **App nickname:** `Socdo iOS`
   - **App Store ID:** (bỏ qua nếu chưa có)
3. Click "Register app"

**Bước 3:** Tải GoogleService-Info.plist
1. Tải file `GoogleService-Info.plist`
2. **KHÔNG** copy trực tiếp vào folder
3. Mở Xcode: `ios/Runner.xcworkspace`
4. Drag & drop file vào folder `Runner` trong Xcode
5. ✅ Check "Copy items if needed"
6. ✅ Chọn target "Runner"
7. ✅ Check "Add to targets: Runner"

**Lưu ý:** Phải thêm qua Xcode để Xcode tự động link vào project

**Thời gian:** 30 phút

---

### 2.3. Cấu hình Firebase trong AppDelegate.swift

**File hiện tại:** `ios/Runner/AppDelegate.swift`

**Cần thêm:**

```swift
import Flutter
import UIKit
import FirebaseCore  // Thêm dòng này

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Thêm dòng này
    FirebaseApp.configure()
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

**Thời gian:** 10 phút

---

### 2.4. Thêm iOS Permissions vào Info.plist

**File:** `ios/Runner/Info.plist`

**Vấn đề:** App sử dụng `image_picker` (để chụp ảnh và chọn ảnh) nhưng chưa có permission descriptions. App Store sẽ reject nếu thiếu.

**Cần thêm vào Info.plist:**

```xml
<!-- Camera permission (cho image_picker chụp ảnh) -->
<key>NSCameraUsageDescription</key>
<string>Cần truy cập camera để chụp ảnh sản phẩm và báo lỗi</string>

<!-- Photo Library permission (cho image_picker chọn ảnh) -->
<key>NSPhotoLibraryUsageDescription</key>
<string>Cần truy cập thư viện ảnh để chọn ảnh sản phẩm và báo lỗi</string>

<!-- Photo Library Add permission (iOS 11+) -->
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Cần quyền lưu ảnh vào thư viện</string>
```

**Thời gian:** 15 phút

---

### 2.5. Cập nhật Podfile (nếu cần)

**File:** `ios/Podfile`

**Hiện tại:** Đã có cấu hình cơ bản, có thể cần thêm platform version

**Kiểm tra:**
```ruby
platform :ios, '13.0'  # Đảm bảo có dòng này (đã comment, cần uncomment)
```

**Sau khi sửa, chạy:**
```bash
cd ios
pod install
cd ..
```

**Thời gian:** 10 phút

---

## 🍎 PHẦN 3: CẤU HÌNH APPLE DEVELOPER

### 3.1. Tạo App ID

**Bước 1:** Đăng nhập Apple Developer Portal
- Truy cập: https://developer.apple.com/account
- Đăng nhập với Apple Developer account

**Bước 2:** Tạo App ID
1. Vào "Certificates, Identifiers & Profiles"
2. Chọn "Identifiers" → Click "+"
3. Chọn "App IDs" → Continue
4. Chọn "App" → Continue
5. Điền thông tin:
   - **Description:** Socdo Mobile
   - **Bundle ID:** `com.socdo.mobile`
   - **Capabilities:** Chọn:
     - ✅ Push Notifications (quan trọng!)
     - ✅ Background Modes (nếu cần)
6. Click "Continue" → "Register"

**Thời gian:** 15 phút

---

### 3.2. Tạo APNs Key (cho Firebase Push Notifications)

**Bước 1:** Tạo APNs Key
1. Vào "Certificates, Identifiers & Profiles"
2. Chọn "Keys" → Click "+"
3. Điền thông tin:
   - **Key Name:** Socdo Push Notification Key
   - Check ✅ **Apple Push Notifications service (APNs)**
4. Click "Continue" → "Register"
5. **⚠️ QUAN TRỌNG:** Download key file (.p8) - CHỈ TẢI ĐƯỢC 1 LẦN!
6. Lưu lại:
   - Key ID (hiển thị sau khi tạo)
   - Team ID (trong membership)

**Bước 2:** Upload APNs Key vào Firebase
1. Vào Firebase Console → Project Settings → Cloud Messaging tab
2. Scroll xuống "Apple app configuration"
3. Upload APNs authentication key:
   - Upload file .p8
   - Nhập Key ID
   - Nhập Team ID
4. Click "Upload"

**Thời gian:** 30 phút

---

### 3.3. Tạo Provisioning Profiles

#### Development Profile (cho testing trên device thật)

1. Vào "Certificates, Identifiers & Profiles"
2. Chọn "Profiles" → Click "+"
3. Chọn "iOS App Development" → Continue
4. Chọn App ID: `com.socdo.mobile` → Continue
5. Chọn Certificates (Development) → Continue
6. Chọn Devices (iPhone/iPad để test) → Continue
7. Đặt tên: "Socdo Development" → Generate
8. Download profile

#### Distribution Profile (cho App Store)

1. Chọn "Profiles" → Click "+"
2. Chọn "App Store" → Continue
3. Chọn App ID: `com.socdo.mobile` → Continue
4. Chọn Certificate (Distribution) → Continue
5. Đặt tên: "Socdo App Store" → Generate
6. Download profile

**Thời gian:** 30 phút

---

### 3.4. Tạo App Store Connect Record

**Bước 1:** Đăng nhập App Store Connect
- Truy cập: https://appstoreconnect.apple.com

**Bước 2:** Tạo App mới
1. Click "My Apps" → "+"
2. Chọn "New App"
3. Điền thông tin:
   - **Platform:** iOS
   - **Name:** Socdo (hoặc tên bạn muốn hiển thị trên App Store)
   - **Primary Language:** Vietnamese hoặc English
   - **Bundle ID:** Chọn `com.socdo.mobile`
   - **SKU:** `socdo-mobile-001` (unique identifier)
4. Click "Create"

**Thời gian:** 20 phút

---

## 📦 PHẦN 4: BUILD VÀ TEST

### 4.1. Build trên Mac

**Yêu cầu:** Máy Mac với Xcode đã cài

**Bước 1:** Cấu hình Signing trong Xcode
1. Mở Xcode: `ios/Runner.xcworkspace` (không phải .xcodeproj!)
2. Chọn target "Runner"
3. Vào tab "Signing & Capabilities"
4. ✅ Check "Automatically manage signing"
5. Chọn Team (Apple Developer account của bạn)
6. Xcode sẽ tự động tạo certificates và profiles

**Bước 2:** Test build
```bash
cd ios
pod install  # Nếu chưa chạy
cd ..
flutter build ios --release
```

**Bước 3:** Archive trong Xcode
1. Mở Xcode: `ios/Runner.xcworkspace`
2. Chọn "Any iOS Device" (không phải simulator)
3. Product → Archive
4. Đợi build xong (5-10 phút)
5. Window sẽ hiện Organizer

**Thời gian:** 1-2 giờ (bao gồm setup và build đầu tiên)

---

### 4.2. Test trên Device thật

**Bước 1:** Kết nối iPhone/iPad
- Dùng USB cable kết nối device
- Trust computer trên device

**Bước 2:** Chọn device trong Xcode
- Chọn device trong device selector

**Bước 3:** Run
- Click Run button hoặc Cmd+R
- Xcode sẽ install app lên device

**Lưu ý:** Cần Development provisioning profile và device đã được đăng ký

**Thời gian:** 30 phút

---

### 4.3. TestFlight (Beta Testing)

**Bước 1:** Upload build lên App Store Connect
1. Trong Xcode Organizer, chọn archive vừa tạo
2. Click "Distribute App"
3. Chọn "App Store Connect" → Next
4. Chọn "Upload" → Next
5. Chọn Distribution options:
   - ✅ "Automatically manage signing" (khuyến nghị)
   - Hoặc chọn Distribution provisioning profile đã tạo
6. Click "Upload"
7. Đợi upload xong (5-15 phút)

**Bước 2:** Xử lý build trong App Store Connect
1. Vào App Store Connect → My Apps → Socdo
2. Vào tab "TestFlight"
3. Build sẽ hiện ở mục "Processing" (15-60 phút)
4. Sau khi process xong, build sẽ ở mục "Ready to Test"

**Bước 3:** Thêm beta testers
1. Vào "Internal Testing" hoặc "External Testing"
2. Thêm email của testers
3. Thêm build vào testing group
4. Testers sẽ nhận email mời

**Thời gian:** 2-4 giờ (bao gồm upload, processing, và invite testers)

---

## 🚀 PHẦN 5: SUBMIT LÊN APP STORE

### 5.1. Chuẩn bị Metadata

Cần chuẩn bị các thông tin sau:

#### App Information
- **Name:** Tên hiển thị trên App Store (tối đa 30 ký tự)
- **Subtitle:** Mô tả ngắn (tối đa 30 ký tự)
- **Category:** 
  - Primary: Shopping (hoặc phù hợp)
  - Secondary: (tùy chọn)
- **Privacy Policy URL:** (Bắt buộc!)

#### App Store Listing
- **Screenshots:** Cần ít nhất:
  - iPhone 6.7" (iPhone 14 Pro Max): 1-10 screenshots
  - iPhone 6.5" (iPhone 11 Pro Max): 1-10 screenshots
  - iPhone 5.5" (iPhone 8 Plus): 1-10 screenshots
- **Description:** Mô tả app (tối đa 4000 ký tự)
- **Keywords:** Từ khóa tìm kiếm (tối đa 100 ký tự, dùng dấu phẩy)
- **Support URL:** Website hỗ trợ
- **Marketing URL:** (Tùy chọn)
- **Promotional Text:** (Tùy chọn, tối đa 170 ký tự)
- **What's New:** Ghi chú version đầu tiên

**Thời gian chuẩn bị:** 2-4 giờ (tùy thuộc vào việc chuẩn bị nội dung)

---

### 5.2. Upload Build

**Cách 1: Qua Xcode (khuyến nghị)**
1. Archive trong Xcode
2. Distribute App → App Store Connect → Upload
3. Chọn options và upload

**Cách 2: Qua App Store Connect**
1. Vào App Store Connect → My Apps → Socdo
2. Vào version muốn submit
3. Click "+" trong "Build" section
4. Chọn build đã upload từ TestFlight

**Thời gian:** 15 phút (không kể build time)

---

### 5.3. Điền App Review Information

**Trong App Store Connect:**

1. **Contact Information:**
   - First Name, Last Name
   - Phone number
   - Email

2. **Demo Account:** (nếu app cần login)
   - Username/Email
   - Password
   - Hướng dẫn test app

3. **Notes:** Ghi chú thêm cho reviewer nếu cần

**Thời gian:** 20 phút

---

### 5.4. Export Compliance & Content Rights

**Cần trả lời:**

1. **Does your app use encryption?**
   - Thường chọn "Yes" vì HTTPS là encryption
   - Cần khai báo export compliance

2. **Content Rights:**
   - Xác nhận bạn có quyền sử dụng nội dung trong app

**Thời gian:** 10 phút

---

### 5.5. Submit for Review

**Bước cuối cùng:**
1. Kiểm tra lại tất cả thông tin
2. Click "Submit for Review"
3. Đợi Apple review (thường 1-3 ngày)

**Thời gian review:** 1-3 ngày (có thể lâu hơn nếu có vấn đề)

---

## ⚠️ PHẦN 6: XỬ LÝ VẤN ĐỀ THƯỜNG GẶP

### 6.1. Build Errors

**Lỗi: "No such module 'FirebaseCore'"**
- Chạy: `cd ios && pod install && cd ..`
- Mở workspace, không phải project: `ios/Runner.xcworkspace`

**Lỗi: "Signing for Runner requires a development team"**
- Vào Xcode → Signing & Capabilities
- Chọn Team
- Check "Automatically manage signing"

**Lỗi: "GoogleService-Info.plist not found"**
- Đảm bảo file đã được thêm vào project qua Xcode
- Check file có trong target "Runner"

---

### 6.2. App Store Rejection

**Thường bị reject vì:**

1. **Thiếu Privacy Policy URL** → Cần thêm URL
2. **Thiếu Permission Descriptions** → Thêm vào Info.plist
3. **App crashes** → Test kỹ trước khi submit
4. **Guideline violations** → Đọc kỹ App Store Review Guidelines
5. **Missing demo account** → Cung cấp account test cho reviewer

---

## ⏱️ PHẦN 7: ƯỚC TÍNH THỜI GIAN

### Timeline tổng thể:

| Giai đoạn | Thời gian | Ghi chú |
|-----------|-----------|---------|
| **Chuẩn bị** | | |
| - Apple Developer Account | 1-3 ngày | Nếu chưa có |
| - Mac Computer/Service | 1 ngày | Nếu cần thuê |
| **Cấu hình** | | |
| - Cập nhật Bundle ID | 15 phút | |
| - Firebase iOS setup | 30 phút | |
| - AppDelegate config | 10 phút | |
| - Info.plist permissions | 15 phút | |
| - Podfile update | 10 phút | |
| **Apple Developer** | | |
| - App ID creation | 15 phút | |
| - APNs Key setup | 30 phút | |
| - Provisioning Profiles | 30 phút | |
| - App Store Connect | 20 phút | |
| **Build & Test** | | |
| - Xcode setup & build | 1-2 giờ | Lần đầu lâu hơn |
| - Device testing | 30 phút | |
| - TestFlight setup | 2-4 giờ | Upload + processing |
| **App Store Submission** | | |
| - Metadata preparation | 2-4 giờ | |
| - Build upload | 15 phút | |
| - Submission | 30 phút | |
| - **Review wait** | **1-3 ngày** | Apple review |
| **TỔNG CỘNG** | **3-7 ngày** | Không tính thời gian review |

### Thời gian thực tế (nếu đã có Apple Developer Account và Mac):
- **Làm việc nhanh:** 1-2 ngày
- **Làm việc cẩn thận:** 3-5 ngày
- **Review từ Apple:** +1-3 ngày

---

## ✅ CHECKLIST HOÀN CHỈNH

### Code Configuration
- [ ] Cập nhật Bundle ID từ `com.example.socdo` → `com.socdo.mobile`
- [ ] Thêm GoogleService-Info.plist vào iOS project
- [ ] Cấu hình Firebase trong AppDelegate.swift
- [ ] Thêm iOS permissions vào Info.plist (Camera, Photo Library)
- [ ] Cập nhật Podfile và chạy `pod install`

### Apple Developer
- [ ] Tạo App ID trên Apple Developer Portal
- [ ] Tạo APNs Key và upload vào Firebase
- [ ] Tạo Development Provisioning Profile
- [ ] Tạo Distribution Provisioning Profile
- [ ] Tạo App trong App Store Connect

### Build & Test
- [ ] Setup Xcode signing (Automatic)
- [ ] Build thành công trên Mac
- [ ] Test trên device thật
- [ ] Upload build lên TestFlight
- [ ] Test qua TestFlight (ít nhất internal testing)

### App Store Submission
- [ ] Chuẩn bị screenshots (đủ kích thước)
- [ ] Viết app description
- [ ] Chuẩn bị keywords
- [ ] Thêm Privacy Policy URL
- [ ] Thêm Support URL
- [ ] Chuẩn bị demo account (nếu cần)
- [ ] Upload build
- [ ] Submit for review

---

## 📚 TÀI LIỆU THAM KHẢO

- [Flutter iOS Deployment](https://docs.flutter.dev/deployment/ios)
- [Apple App Store Connect](https://appstoreconnect.apple.com)
- [Apple Developer Portal](https://developer.apple.com/account)
- [Firebase iOS Setup](https://firebase.google.com/docs/ios/setup)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)

---

**Chúc bạn thành công! 🚀**

