# 🚀 IOS DEPLOYMENT QUICK START - TÓM TẮT NHANH

## ⚡ CÁC BƯỚC CẦN LÀM NGAY

### 1️⃣ CẤU HÌNH CODE (30-60 phút)

#### A. Đổi Bundle ID
**Vấn đề:** Hiện đang là `com.example.socdo` → Cần đổi thành `com.socdo.mobile`

**Cách làm:**
- Mở file `ios/Runner.xcodeproj/project.pbxproj`
- Tìm và thay tất cả `com.example.socdo` → `com.socdo.mobile`
- Hoặc mở Xcode: `ios/Runner.xcworkspace` → Signing & Capabilities → Đổi Bundle Identifier

#### B. Thêm GoogleService-Info.plist
1. Vào Firebase Console → Project `socdomobile`
2. Add iOS app với Bundle ID: `com.socdo.mobile`
3. Download `GoogleService-Info.plist`
4. Mở Xcode: `ios/Runner.xcworkspace`
5. Drag file vào folder `Runner` (qua Xcode, không copy trực tiếp!)
6. ✅ Check "Copy items if needed"

#### C. Cập nhật AppDelegate.swift
Thêm vào file `ios/Runner/AppDelegate.swift`:

```swift
import FirebaseCore  // Thêm dòng này

override func application(...) -> Bool {
    FirebaseApp.configure()  // Thêm dòng này trước GeneratedPluginRegistrant
    GeneratedPluginRegistrant.register(with: self)
    ...
}
```

#### D. Thêm Permissions vào Info.plist
Thêm vào `ios/Runner/Info.plist` (trong `<dict>` tag):

```xml
<key>NSCameraUsageDescription</key>
<string>Cần truy cập camera để chụp ảnh sản phẩm và báo lỗi</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>Cần truy cập thư viện ảnh để chọn ảnh sản phẩm và báo lỗi</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>Cần quyền lưu ảnh vào thư viện</string>
```

#### E. Chạy Pod Install
```bash
cd ios
pod install
cd ..
```

---

### 2️⃣ APPLE DEVELOPER SETUP (1-2 giờ)

**Yêu cầu:** Apple Developer Account ($99/năm) - BẮT BUỘC

#### A. Tạo App ID
1. Vào https://developer.apple.com/account
2. Certificates, Identifiers & Profiles → Identifiers → +
3. App IDs → Continue
4. Bundle ID: `com.socdo.mobile`
5. ✅ Check "Push Notifications"
6. Register

#### B. Tạo APNs Key (cho Firebase)
1. Keys → + → Đặt tên: "Socdo Push Key"
2. ✅ Check "Apple Push Notifications service (APNs)"
3. Continue → Register
4. **DOWNLOAD KEY FILE (.p8) - CHỈ TẢI ĐƯỢC 1 LẦN!**
5. Lưu lại: Key ID, Team ID
6. Upload vào Firebase:
   - Firebase Console → Project Settings → Cloud Messaging
   - Apple app configuration → Upload .p8 file
   - Nhập Key ID và Team ID

#### C. Tạo App Store Connect Record
1. Vào https://appstoreconnect.apple.com
2. My Apps → + → New App
3. Bundle ID: Chọn `com.socdo.mobile`
4. Name: "Socdo" (hoặc tên bạn muốn)
5. Create

---

### 3️⃣ BUILD (Cần Mac - 1-2 giờ)

#### A. Mở Xcode
```bash
open ios/Runner.xcworkspace
```

#### B. Setup Signing
1. Chọn target "Runner"
2. Tab "Signing & Capabilities"
3. ✅ Check "Automatically manage signing"
4. Chọn Team (Apple Developer account của bạn)

#### C. Build
```bash
flutter build ios --release
```

#### D. Archive trong Xcode
1. Product → Archive (phải chọn "Any iOS Device", không phải simulator)
2. Đợi build xong
3. Organizer sẽ tự mở

---

### 4️⃣ TESTFLIGHT (2-4 giờ)

1. Trong Xcode Organizer → Distribute App
2. Chọn "App Store Connect" → Upload
3. Chọn options → Upload
4. Đợi upload xong (5-15 phút)
5. Vào App Store Connect → TestFlight
6. Build sẽ process (15-60 phút)
7. Thêm internal testers → Test

---

### 5️⃣ SUBMIT APP STORE (2-4 giờ chuẩn bị + 1-3 ngày review)

#### Chuẩn bị:
- [ ] Screenshots (iPhone 6.7", 6.5", 5.5")
- [ ] App description (tiếng Việt hoặc tiếng Anh)
- [ ] Keywords
- [ ] Privacy Policy URL (BẮT BUỘC!)
- [ ] Support URL
- [ ] Demo account (nếu app cần login)

#### Submit:
1. App Store Connect → My Apps → Socdo
2. Version mới → Click "+" trong Build section
3. Chọn build đã upload
4. Điền tất cả metadata
5. Submit for Review

---

## ⏱️ TỔNG THỜI GIAN

| Nếu đã có | Thời gian |
|-----------|-----------|
| Apple Developer Account | ✅ |
| Mac Computer | ✅ |
| **Code config** | **30-60 phút** |
| **Apple setup** | **1-2 giờ** |
| **Build & Test** | **1-2 giờ** |
| **TestFlight** | **2-4 giờ** |
| **Submission** | **2-4 giờ** |
| **Apple Review** | **1-3 ngày** |
| **TỔNG** | **~1 ngày làm việc + 1-3 ngày review** |

---

## ❗ VẤN ĐỀ QUAN TRỌNG

### ⚠️ KHÔNG CÓ MAC?
Bạn CẦN một trong các lựa chọn sau:
1. **Thuê máy Mac build service** (Codemagic, Bitrise, AppCircle)
2. **Dùng macOS trên máy ảo** (không được Apple khuyến nghị)
3. **Mượn/thuê máy Mac thật** (tốt nhất)

### ⚠️ BUNDLE ID KHÔNG ĐÚNG
- Hiện tại: `com.example.socdo` (example - sẽ bị reject!)
- Cần đổi: `com.socdo.mobile` (khớp với Android)

### ⚠️ THIẾU PERMISSIONS
App dùng `image_picker` → CẦN thêm permission descriptions vào Info.plist, nếu không App Store sẽ reject!

---

## ✅ CHECKLIST NHANH

**Code:**
- [ ] Bundle ID: `com.socdo.mobile`
- [ ] GoogleService-Info.plist đã thêm vào Xcode
- [ ] AppDelegate có `FirebaseApp.configure()`
- [ ] Info.plist có camera/photo library permissions
- [ ] `pod install` đã chạy

**Apple:**
- [ ] App ID đã tạo (`com.socdo.mobile`)
- [ ] APNs Key đã tạo và upload vào Firebase
- [ ] App Store Connect record đã tạo

**Build:**
- [ ] Xcode signing đã setup
- [ ] Build thành công
- [ ] Test trên device (nếu có)

**Submit:**
- [ ] Screenshots đã chuẩn bị
- [ ] Metadata đã điền
- [ ] Privacy Policy URL có
- [ ] Submit for review

---

**Xem chi tiết đầy đủ tại:** `IOS_APP_STORE_DEPLOYMENT_GUIDE.md`

