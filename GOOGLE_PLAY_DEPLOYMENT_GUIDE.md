# 📱 HƯỚNG DẪN ĐẨY APP LÊN GOOGLE PLAY (CH PLAY)

## ⚠️ VẤN ĐỀ QUAN TRỌNG CẦN SỬA NGAY

### 1. Signing Config - ĐANG DÙNG DEBUG KEY! ⚠️
**File:** `android/app/build.gradle.kts` (dòng 39)  
**Vấn đề:** Đang dùng debug signing cho release build  
**Hậu quả:** Google Play sẽ KHÔNG CHẤP NHẬN debug-signed APK/AAB  
**Cần làm:** Tạo release signing key và cấu hình

### 2. App Label
**File:** `android/app/src/main/AndroidManifest.xml` (dòng 7)  
**Hiện tại:** `android:label="socdo"`  
**Nên sửa:** Tên app đẹp hơn (ví dụ: "Socdo" hoặc "Socdo Mobile")

---

## 🔧 BƯỚC 1: TẠO RELEASE SIGNING KEY

### 1.1. Tạo keystore file

**Mở terminal/command prompt và chạy:**

```bash
cd android/app
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

**Khi được hỏi, điền thông tin:**
- **Keystore password:** (Nhập password mạnh, LƯU LẠI!)
- **Re-enter password:** (Nhập lại)
- **First and last name:** Tên bạn hoặc tên công ty
- **Organizational Unit:** (Có thể bỏ qua)
- **Organization:** Tên công ty (ví dụ: Socdo)
- **City:** Thành phố
- **State/Province:** Tỉnh/Thành phố
- **Country code:** VN (hoặc mã nước bạn)

**⚠️ QUAN TRỌNG:** 
- Lưu file `upload-keystore.jks` và password ở nơi AN TOÀN
- Nếu mất file này, bạn sẽ KHÔNG THỂ update app lên Google Play nữa!

**Thời gian:** 5 phút

---

### 1.2. Tạo file keystore.properties

**Tạo file:** `android/keystore.properties`

**Nội dung file:**
```properties
storePassword=<PASSWORD_VỪA_TẠO>
keyPassword=<PASSWORD_VỪA_TẠO>
keyAlias=upload
storeFile=upload-keystore.jks
```

**⚠️ QUAN TRỌNG:** 
- File này chứa password, KHÔNG được commit lên Git!
- Thêm vào `.gitignore`: `android/keystore.properties`
- Thêm vào `.gitignore`: `android/app/upload-keystore.jks`

**Thời gian:** 5 phút

---

### 1.3. Thêm vào .gitignore

**Mở file:** `.gitignore`

**Thêm vào cuối file:**
```
# Keystore files
android/keystore.properties
android/app/upload-keystore.jks
*.jks
*.keystore
```

**Thời gian:** 2 phút

---

## 📝 BƯỚC 2: CẤU HÌNH BUILD.GRADLE.KTS

### 2.1. Cập nhật android/app/build.gradle.kts

**File hiện tại:** `android/app/build.gradle.kts`

**Cần thay thế phần `buildTypes`:**

```kotlin
android {
    namespace = "com.socdo.mobile"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.socdo.mobile"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Đọc keystore.properties
    val keystorePropertiesFile = rootProject.file("keystore.properties")
    val keystoreProperties = java.util.Properties()
    if (keystorePropertiesFile.exists()) {
        keystoreProperties.load(java.io.FileInputStream(keystorePropertiesFile))
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            // Tối ưu hóa cho production
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}
```

**Thời gian:** 15 phút

---

## 🏷️ BƯỚC 3: CẬP NHẬT APP LABEL (Tùy chọn nhưng nên làm)

### 3.1. Sửa AndroidManifest.xml

**File:** `android/app/src/main/AndroidManifest.xml`

**Thay đổi dòng 7:**
```xml
android:label="Socdo"
```

Hoặc nếu muốn tên đầy đủ:
```xml
android:label="Socdo Mobile"
```

**Thời gian:** 2 phút

---

## 📦 BƯỚC 4: BUILD APP BUNDLE (AAB)

### 4.1. Build release AAB

**Google Play yêu cầu file AAB (Android App Bundle), không phải APK**

**Chạy lệnh:**
```bash
flutter build appbundle --release
```

**File output sẽ ở:** `build/app/outputs/bundle/release/app-release.aab`

**Thời gian:** 5-15 phút (tùy máy)

---

## 🚀 BƯỚC 5: CHUẨN BỊ CHO GOOGLE PLAY CONSOLE

### 5.1. Thông tin cần chuẩn bị

**Trong Google Play Console, bạn cần:**

1. **App Name:** Tên app (tối đa 50 ký tự)
   - Ví dụ: "Socdo" hoặc "Socdo Mobile"

2. **Short Description:** Mô tả ngắn (tối đa 80 ký tự)
   - Ví dụ: "Ứng dụng mua sắm Socdo - Sản phẩm chất lượng, giá tốt"

3. **Full Description:** Mô tả đầy đủ (tối đa 4000 ký tự)
   - Mô tả chi tiết về app, tính năng, lợi ích

4. **Graphics:**
   - **App Icon:** 512x512 px (PNG, không trong suốt)
   - **Feature Graphic:** 1024x500 px (cho Play Store listing)
   - **Screenshots:** 
     - Phone: ít nhất 2 screenshots (tối đa 8)
     - Tablet: (tùy chọn) ít nhất 2 screenshots
   - **Promo Graphic:** 180x120 px (tùy chọn)

5. **App Category:** 
   - Chọn category phù hợp (ví dụ: Shopping, Lifestyle)

6. **Content Rating:** 
   - Cần điền questionnaire về nội dung app
   - Google sẽ tự động rate

7. **Privacy Policy URL:** 
   - **BẮT BUỘC!** Phải có URL privacy policy
   - Có thể dùng GitHub Pages, Firebase Hosting, hoặc website riêng

8. **Target Audience:**
   - Chọn độ tuổi target

9. **Pricing & Distribution:**
   - Miễn phí hay có phí
   - Quốc gia phân phối (chọn tất cả hoặc chọn quốc gia)

---

## 📋 BƯỚC 6: UPLOAD VÀ SUBMIT

### 6.1. Upload AAB file

1. Đăng nhập Google Play Console: https://play.google.com/console
2. Chọn app bạn vừa tạo (hoặc tạo mới)
3. Vào menu bên trái → **Release** → **Production** (hoặc **Testing**)
4. Click **Create new release**
5. Upload file `app-release.aab`
6. Điền **Release notes** (ghi chú version này)
7. Click **Save**

### 6.2. Hoàn thiện Store Listing

1. Vào **Store presence** → **Main store listing**
2. Điền tất cả thông tin:
   - App name
   - Short description
   - Full description
   - Graphics (icon, screenshots, feature graphic)
   - Category
   - Contact details

### 6.3. Content Rating

1. Vào **Policy** → **App content**
2. Click **Start rating**
3. Điền questionnaire
4. Submit để được rate tự động

### 6.4. Privacy Policy

1. Vào **Policy** → **App content**
2. Scroll xuống **Privacy Policy**
3. Thêm URL privacy policy

### 6.5. Submit for Review

1. Kiểm tra tất cả sections đã điền đầy đủ (không có dấu cảnh báo đỏ)
2. Vào **Release** → **Production**
3. Click **Review release**
4. Nếu OK, click **Start rollout to Production**
5. Đợi Google review (thường 1-3 ngày)

---

## ✅ CHECKLIST HOÀN CHỈNH

### Code Configuration
- [ ] Tạo keystore file (`upload-keystore.jks`)
- [ ] Tạo file `keystore.properties`
- [ ] Thêm keystore vào `.gitignore`
- [ ] Cập nhật `build.gradle.kts` với signing config
- [ ] Sửa app label trong AndroidManifest.xml (tùy chọn)
- [ ] Build AAB thành công: `flutter build appbundle --release`

### Google Play Console
- [ ] Tạo app mới trong Play Console
- [ ] Upload AAB file
- [ ] Điền app name
- [ ] Điền short description
- [ ] Điền full description
- [ ] Upload app icon (512x512)
- [ ] Upload feature graphic (1024x500)
- [ ] Upload screenshots (ít nhất 2)
- [ ] Chọn category
- [ ] Hoàn thành content rating
- [ ] Thêm Privacy Policy URL
- [ ] Chọn pricing (Free/Paid)
- [ ] Chọn countries for distribution
- [ ] Submit for review

---

## ⏱️ ƯỚC TÍNH THỜI GIAN

| Giai đoạn | Thời gian |
|-----------|-----------|
| Tạo keystore | 5 phút |
| Cấu hình build.gradle | 15 phút |
| Build AAB | 5-15 phút |
| Chuẩn bị metadata | 2-4 giờ |
| Upload & submit | 30 phút |
| **Google Review** | **1-3 ngày** |

**Tổng:** ~1 ngày làm việc + 1-3 ngày review

---

## 🔐 BẢO MẬT KEYSTORE

**QUAN TRỌNG:** 
- Lưu file `upload-keystore.jks` và password ở nơi AN TOÀN
- Backup ở nhiều nơi (cloud, USB, máy khác)
- Nếu mất file này, bạn sẽ KHÔNG THỂ update app nữa!
- Phải tạo app mới từ đầu nếu mất keystore

**Lưu trữ:**
- ✅ Google Drive (encrypted)
- ✅ USB drive (giữ ở nơi an toàn)
- ✅ Password manager (1Password, LastPass)
- ✅ In ra giấy (giữ trong két an toàn)

---

## ❓ VẤN ĐỀ THƯỜNG GẶP

### Lỗi: "Keystore file not found"
- Đảm bảo file `upload-keystore.jks` ở trong `android/app/`
- Đảm bảo đường dẫn trong `keystore.properties` đúng

### Lỗi: "Password incorrect"
- Kiểm tra password trong `keystore.properties` đúng
- Không có khoảng trắng thừa

### Google Play reject vì thiếu Privacy Policy
- Phải có Privacy Policy URL
- URL phải accessible (không 404)
- Phải bằng ngôn ngữ của target audience

### Build AAB lỗi
- Đảm bảo đã chạy `flutter pub get`
- Đảm bảo keystore.properties đúng format
- Kiểm tra file keystore tồn tại

---

## 📚 TÀI LIỆU THAM KHẢO

- [Flutter Android Deployment](https://docs.flutter.dev/deployment/android)
- [Google Play Console](https://play.google.com/console)
- [Android App Signing](https://developer.android.com/studio/publish/app-signing)

---

**Chúc bạn thành công! 🚀**


