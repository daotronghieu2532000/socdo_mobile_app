# 📱 TIẾN TRÌNH BUILD IOS VÀ ĐẨY LÊN APP STORE

## 📊 TỔNG QUAN DỰ ÁN

**Tên App:** Socdo Mobile  
**Platform:** Flutter  
**Trạng thái hiện tại:** ✅ Đã build thành công Android APK  
**Mục tiêu:** Build iOS app và deploy lên App Store

---

## ⚠️ VẤN ĐỀ CẦN SỬA TRƯỚC KHI BUILD IOS

### 1. Bundle Identifier không đúng
**Hiện tại:** `com.example.socdo`  
**Vấn đề:** Bundle ID example không được phép trên App Store  
**Cần đổi thành:** `com.socdo.mobile` (để khớp với Android)

**File cần sửa:** `ios/Runner.xcodeproj/project.pbxproj`  
**Số chỗ cần sửa:** 6 vị trí

### 2. Thiếu GoogleService-Info.plist
**Vấn đề:** Chưa có file Firebase config cho iOS  
**Cần làm:** Thêm iOS app vào Firebase project và download file `GoogleService-Info.plist`

### 3. AppDelegate chưa config Firebase
**File:** `ios/Runner/AppDelegate.swift`  
**Vấn đề:** Chưa import và initialize Firebase  
**Cần thêm:** `import FirebaseCore` và `FirebaseApp.configure()`

### 4. Thiếu iOS Permissions
**File:** `ios/Runner/Info.plist`  
**Vấn đề:** App sử dụng `image_picker` nhưng chưa khai báo permissions  
**Hậu quả:** App Store sẽ reject app nếu thiếu  
**Cần thêm:**
- `NSCameraUsageDescription` (camera permission)
- `NSPhotoLibraryUsageDescription` (photo library permission)
- `NSPhotoLibraryAddUsageDescription` (save photo permission)

---

## 📋 CHI TIẾT CÁC BƯỚC CẦN LÀM

### PHẦN 1: CẤU HÌNH CODE (1-2 giờ)

#### Bước 1.1: Đổi Bundle Identifier (15 phút)

**Cách 1: Sửa trong file project.pbxproj**
- Mở file `ios/Runner.xcodeproj/project.pbxproj`
- Tìm tất cả `com.example.socdo` và thay thành `com.socdo.mobile`
- Có 6 vị trí cần sửa:
  - 3 vị trí cho Runner (Debug, Release, Profile)
  - 3 vị trí cho RunnerTests (Debug, Release, Profile)

**Cách 2: Sửa trong Xcode (dễ hơn)**
1. Mở Xcode: `ios/Runner.xcworkspace`
2. Chọn target "Runner"
3. Vào tab "Signing & Capabilities"
4. Đổi Bundle Identifier từ `com.example.socdo` → `com.socdo.mobile`
5. Làm tương tự cho target "RunnerTests" (đổi thành `com.socdo.mobile.RunnerTests`)

#### Bước 1.2: Thêm iOS App vào Firebase (30 phút)

1. Đăng nhập Firebase Console: https://console.firebase.google.com
2. Chọn project `socdomobile`
3. Click "Add app" → Chọn biểu tượng iOS
4. Điền thông tin:
   - **Bundle ID:** `com.socdo.mobile`
   - **App nickname:** `Socdo iOS`
   - **App Store ID:** (bỏ qua nếu chưa có)
5. Click "Register app"
6. Tải file `GoogleService-Info.plist`
7. **QUAN TRỌNG:** Mở Xcode (`ios/Runner.xcworkspace`) và drag file vào folder `Runner`
   - ✅ Check "Copy items if needed"
   - ✅ Chọn target "Runner"
   - KHÔNG copy trực tiếp vào folder!

#### Bước 1.3: Cập nhật AppDelegate.swift (10 phút)

Mở file `ios/Runner/AppDelegate.swift` và sửa thành:

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

#### Bước 1.4: Thêm Permissions vào Info.plist (15 phút)

Mở file `ios/Runner/Info.plist` và thêm các dòng sau vào trong tag `<dict>`:

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

**Vị trí:** Thêm trước thẻ `</dict>` cuối cùng

#### Bước 1.5: Cập nhật Podfile và chạy pod install (10 phút)

1. Mở file `ios/Podfile`
2. Uncomment dòng `platform :ios, '13.0'` (nếu đang comment)
3. Chạy lệnh:
```bash
cd ios
pod install
cd ..
```

---

### PHẦN 2: APPLE DEVELOPER SETUP (2-3 giờ)

**Yêu cầu bắt buộc:** Apple Developer Account ($99/năm)

#### Bước 2.1: Tạo App ID (15 phút)

1. Đăng nhập: https://developer.apple.com/account
2. Vào "Certificates, Identifiers & Profiles"
3. Chọn "Identifiers" → Click nút "+"
4. Chọn "App IDs" → Continue
5. Chọn "App" → Continue
6. Điền thông tin:
   - **Description:** Socdo Mobile
   - **Bundle ID:** `com.socdo.mobile` (chọn "Explicit")
7. **Capabilities:** Check các mục sau:
   - ✅ Push Notifications (QUAN TRỌNG!)
   - ✅ Background Modes (nếu cần background processing)
8. Click "Continue" → "Register"

#### Bước 2.2: Tạo APNs Key cho Firebase (30 phút)

1. Vào "Certificates, Identifiers & Profiles"
2. Chọn "Keys" → Click nút "+"
3. Điền thông tin:
   - **Key Name:** Socdo Push Notification Key
   - ✅ Check "Apple Push Notifications service (APNs)"
4. Click "Continue" → "Register"
5. **QUAN TRỌNG:** Download key file (.p8) - CHỈ TẢI ĐƯỢC 1 LẦN!
6. Lưu lại:
   - Key ID (hiển thị sau khi tạo)
   - Team ID (trong membership section)

7. Upload vào Firebase:
   - Vào Firebase Console → Project Settings → Tab "Cloud Messaging"
   - Scroll xuống "Apple app configuration"
   - Click "Upload" trong "APNs Authentication Key"
   - Upload file .p8 vừa tải
   - Nhập Key ID
   - Nhập Team ID
   - Click "Upload"

#### Bước 2.3: Tạo Provisioning Profiles (30 phút)

**Development Profile (cho test trên device):**
1. Vào "Certificates, Identifiers & Profiles"
2. Chọn "Profiles" → Click "+"
3. Chọn "iOS App Development" → Continue
4. Chọn App ID: `com.socdo.mobile` → Continue
5. Chọn Certificate (Development) → Continue
6. Chọn Devices (iPhone/iPad để test) → Continue
7. Đặt tên: "Socdo Development" → Generate
8. Download profile

**Distribution Profile (cho App Store):**
1. Chọn "Profiles" → Click "+"
2. Chọn "App Store" → Continue
3. Chọn App ID: `com.socdo.mobile` → Continue
4. Chọn Certificate (Distribution) → Continue
5. Đặt tên: "Socdo App Store" → Generate
6. Download profile

**Lưu ý:** Nếu chọn "Automatically manage signing" trong Xcode thì không cần download manual.

#### Bước 2.4: Tạo App trong App Store Connect (20 phút)

1. Đăng nhập: https://appstoreconnect.apple.com
2. Click "My Apps" → Click nút "+"
3. Chọn "New App"
4. Điền thông tin:
   - **Platform:** iOS
   - **Name:** Socdo (hoặc tên bạn muốn hiển thị trên App Store)
   - **Primary Language:** Vietnamese hoặc English
   - **Bundle ID:** Chọn `com.socdo.mobile` (từ dropdown)
   - **SKU:** `socdo-mobile-001` (unique identifier, tự đặt)
5. Click "Create"

---

### PHẦN 3: BUILD VÀ TEST (2-4 giờ)

**Yêu cầu:** Máy Mac với Xcode đã cài

#### Bước 3.1: Setup Xcode Signing (15 phút)

1. Mở Xcode: `ios/Runner.xcworkspace` (KHÔNG phải .xcodeproj!)
2. Chọn target "Runner"
3. Vào tab "Signing & Capabilities"
4. ✅ Check "Automatically manage signing"
5. Chọn Team (Apple Developer account của bạn)
6. Xcode sẽ tự động tạo certificates và profiles

#### Bước 3.2: Build App (1-2 giờ cho lần đầu)

**Cách 1: Build qua Flutter CLI**
```bash
flutter build ios --release
```

**Cách 2: Build qua Xcode (khuyến nghị cho lần đầu)**
1. Trong Xcode, chọn "Any iOS Device" (không phải simulator)
2. Product → Archive
3. Đợi build xong (5-10 phút)
4. Window Organizer sẽ tự mở

**Lưu ý:** Lần đầu build sẽ lâu hơn vì cần download dependencies.

#### Bước 3.3: Test trên Device thật (30 phút)

1. Kết nối iPhone/iPad qua USB
2. Trust computer trên device
3. Trong Xcode, chọn device từ device selector
4. Click Run button (▶️) hoặc Cmd+R
5. Xcode sẽ install app lên device

**Lưu ý:** Cần device đã được đăng ký trong Apple Developer Portal.

---

### PHẦN 4: TESTFLIGHT (2-4 giờ)

#### Bước 4.1: Upload Build (15 phút)

1. Trong Xcode Organizer, chọn archive vừa build
2. Click "Distribute App"
3. Chọn "App Store Connect" → Next
4. Chọn "Upload" → Next
5. Chọn Distribution options:
   - ✅ "Automatically manage signing" (khuyến nghị)
   - Hoặc chọn Distribution provisioning profile đã tạo
6. Click "Upload"
7. Đợi upload xong (5-15 phút tùy internet)

#### Bước 4.2: Processing Build (15-60 phút)

1. Vào App Store Connect → My Apps → Socdo
2. Vào tab "TestFlight"
3. Build sẽ hiện ở mục "Processing" (15-60 phút)
4. Đợi đến khi status chuyển sang "Ready to Test"

#### Bước 4.3: Invite Testers (15 phút)

1. Vào "Internal Testing" hoặc "External Testing"
2. Click "+" để thêm testers
3. Nhập email của testers
4. Chọn build vừa upload
5. Click "Start Testing"
6. Testers sẽ nhận email mời

---

### PHẦN 5: SUBMIT LÊN APP STORE (3-5 giờ chuẩn bị + 1-3 ngày review)

#### Bước 5.1: Chuẩn bị Metadata (2-4 giờ)

**Cần chuẩn bị:**

1. **Screenshots:**
   - iPhone 6.7" (iPhone 14 Pro Max): 1290 x 2796 px - Cần 1-10 ảnh
   - iPhone 6.5" (iPhone 11 Pro Max): 1242 x 2688 px - Cần 1-10 ảnh
   - iPhone 5.5" (iPhone 8 Plus): 1242 x 2208 px - Cần 1-10 ảnh
   - Có thể dùng tool để resize nếu chỉ có 1 bộ screenshots

2. **App Description:** 
   - Mô tả app (tối đa 4000 ký tự)
   - Viết bằng tiếng Việt hoặc tiếng Anh

3. **Keywords:**
   - Từ khóa tìm kiếm (tối đa 100 ký tự)
   - Dùng dấu phẩy ngăn cách: `shopping, ecommerce, vietnam, mua sắm`

4. **Privacy Policy URL:** 
   - **BẮT BUỘC!** App Store sẽ reject nếu thiếu
   - URL website có Privacy Policy
   - Có thể dùng GitHub Pages, Firebase Hosting, hoặc website riêng

5. **Support URL:**
   - Website hỗ trợ khách hàng
   - Có thể là email hoặc trang web hỗ trợ

6. **Demo Account (nếu app cần login):**
   - Username/Email
   - Password
   - Hướng dẫn test app cho reviewer

#### Bước 5.2: Upload Build vào Version (15 phút)

**Cách 1: Qua Xcode Organizer (khuyến nghị)**
- Như bước 4.1, nhưng trong App Store Connect sẽ chọn build để submit

**Cách 2: Qua App Store Connect**
1. Vào App Store Connect → My Apps → Socdo
2. Tạo version mới (1.0.0) hoặc chọn version hiện có
3. Trong section "Build", click "+"
4. Chọn build đã upload từ TestFlight

#### Bước 5.3: Điền App Review Information (20 phút)

Trong App Store Connect:

1. **Contact Information:**
   - First Name, Last Name
   - Phone number
   - Email

2. **Demo Account:** (nếu app cần login)
   - Username
   - Password
   - Notes: Hướng dẫn test app

3. **Notes:** Ghi chú thêm cho reviewer nếu cần

#### Bước 5.4: Export Compliance (10 phút)

1. **Does your app use encryption?**
   - Thường chọn "Yes" vì HTTPS là encryption
   - Cần khai báo export compliance

2. **Content Rights:**
   - Xác nhận bạn có quyền sử dụng nội dung trong app

#### Bước 5.5: Submit for Review (5 phút)

1. Kiểm tra lại tất cả thông tin đã điền
2. Đảm bảo build đã được chọn
3. Đảm bảo tất cả metadata đã điền đầy đủ
4. Click "Submit for Review"
5. Xác nhận submit

**Review time:** Thường 1-3 ngày, có thể lâu hơn nếu có vấn đề.

---

## ⏱️ ƯỚC TÍNH THỜI GIAN TỔNG THỂ

| Giai đoạn | Thời gian | Ghi chú |
|-----------|-----------|---------|
| **Chuẩn bị** | | |
| Apple Developer Account | 1-3 ngày | Nếu chưa có |
| Mac Computer/Service | 1 ngày | Nếu cần thuê |
| **Cấu hình Code** | **1-2 giờ** | |
| - Đổi Bundle ID | 15 phút | |
| - Firebase iOS setup | 30 phút | |
| - AppDelegate config | 10 phút | |
| - Info.plist permissions | 15 phút | |
| - Pod install | 10 phút | |
| **Apple Developer Setup** | **2-3 giờ** | |
| - App ID | 15 phút | |
| - APNs Key | 30 phút | |
| - Provisioning Profiles | 30 phút | |
| - App Store Connect | 20 phút | |
| **Build & Test** | **2-4 giờ** | |
| - Xcode setup | 1 giờ | |
| - Build | 30 phút - 2 giờ | Lần đầu lâu hơn |
| - Device testing | 30 phút | |
| **TestFlight** | **2-4 giờ** | |
| - Upload | 15 phút | |
| - Processing | 15-60 phút | |
| - Test | 1-2 giờ | |
| **App Store Submission** | **3-5 giờ** | |
| - Metadata preparation | 2-4 giờ | |
| - Upload & Submit | 30 phút | |
| - **Review từ Apple** | **1-3 ngày** | ⏳ |

### Tổng thời gian (nếu đã có Apple Developer Account và Mac):
- **Làm việc nhanh:** 1 ngày
- **Làm việc cẩn thận:** 2-3 ngày
- **Review từ Apple:** +1-3 ngày
- **TỔNG:** **2-6 ngày** (không kể thời gian đợi review)

---

## ⚠️ LƯU Ý QUAN TRỌNG

### 1. Không có Mac?
**Giải pháp:**
- Thuê dịch vụ build (Codemagic, Bitrise, AppCircle) - ~$50-100/tháng
- Dùng macOS trên máy ảo (không được khuyến nghị)
- Thuê/mượn máy Mac thật (tốt nhất)

### 2. Bundle ID phải đúng
- Không được dùng `com.example.*`
- Phải unique (không trùng với app khác)
- Nên khớp với Android package name

### 3. Permissions bắt buộc
- App Store sẽ reject nếu thiếu permission descriptions
- Phải giải thích rõ tại sao cần permission đó

### 4. Privacy Policy bắt buộc
- App Store sẽ reject nếu thiếu Privacy Policy URL
- Phải là URL thật, accessible

---

## 📚 TÀI LIỆU THAM KHẢO

1. **Hướng dẫn chi tiết:** `IOS_APP_STORE_DEPLOYMENT_GUIDE.md`
2. **Quick Start:** `IOS_DEPLOYMENT_QUICK_START.md`
3. **Flutter iOS Docs:** https://docs.flutter.dev/deployment/ios
4. **Apple Developer:** https://developer.apple.com
5. **App Store Connect:** https://appstoreconnect.apple.com
6. **Firebase iOS Setup:** https://firebase.google.com/docs/ios/setup

---

**Chúc bạn thành công! 🚀**

