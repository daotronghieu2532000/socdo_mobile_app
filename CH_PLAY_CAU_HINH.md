# 📱 HƯỚNG DẪN CẤU HÌNH APP ĐỂ ĐẨY LÊN CH PLAY

## ✅ ĐÃ CẤU HÌNH SẴN

Tôi đã cập nhật các file sau cho bạn:

1. ✅ **android/app/build.gradle.kts** - Đã cấu hình signing cho release build
2. ✅ **android/app/src/main/AndroidManifest.xml** - Đã sửa app label thành "Socdo"
3. ✅ **.gitignore** - Đã thêm keystore files vào ignore list
4. ✅ **android/keystore.properties.example** - Template file để bạn tạo keystore.properties

---

## 🔧 CÁC BƯỚC BẠN CẦN LÀM

### BƯỚC 1: TẠO RELEASE SIGNING KEY (10 phút)

**⚠️ QUAN TRỌNG:** Đây là bước BẮT BUỘC! Google Play sẽ KHÔNG CHẤP NHẬN app dùng debug key.

#### 1.1. Tạo keystore file

**Mở terminal/command prompt và chạy:**

```bash
cd android/app
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

**Khi được hỏi, điền thông tin:**
- **Keystore password:** Nhập password mạnh (VÍ DỤ: `MyApp123!@#`)
- **Re-enter password:** Nhập lại password
- **First and last name:** Tên bạn hoặc công ty (ví dụ: `Socdo Company`)
- **Organizational Unit:** (có thể bỏ qua, nhấn Enter)
- **Organization:** Tên công ty (ví dụ: `Socdo`)
- **City:** Tên thành phố (ví dụ: `Ho Chi Minh`)
- **State/Province:** Tên tỉnh/thành (ví dụ: `Ho Chi Minh`)
- **Country code:** `VN` (hoặc mã nước bạn)

**⚠️ LƯU LẠI:**
- Password bạn vừa nhập
- File `upload-keystore.jks` sẽ được tạo trong `android/app/`

#### 1.2. Tạo file keystore.properties

**Tạo file mới:** `android/keystore.properties`

**Nội dung file:**
```properties
storePassword=PASSWORD_BẠN_VỪA_NHẬP
keyPassword=PASSWORD_BẠN_VỪA_NHẬP
keyAlias=upload
storeFile=upload-keystore.jks
```

**Ví dụ:**
```properties
storePassword=MyApp123!@#
keyPassword=MyApp123!@#
keyAlias=upload
storeFile=upload-keystore.jks
```

**⚠️ LƯU Ý:**
- File này chứa password, KHÔNG được commit lên Git
- Đã được thêm vào `.gitignore` rồi nên an toàn

---

### BƯỚC 2: BUILD APP BUNDLE (AAB) (5-15 phút)

**Google Play chỉ chấp nhận file AAB (Android App Bundle), không phải APK!**

**Chạy lệnh:**
```bash
flutter build appbundle --release
```

**File output sẽ ở:** `build/app/outputs/bundle/release/app-release.aab`

**Thời gian build:** 5-15 phút (tùy máy)

---

### BƯỚC 3: UPLOAD LÊN GOOGLE PLAY CONSOLE (30 phút)

#### 3.1. Đăng nhập Google Play Console

1. Truy cập: https://play.google.com/console
2. Đăng nhập với tài khoản Google của bạn

#### 3.2. Tạo app mới (nếu chưa có)

1. Click **"Tạo ứng dụng"** (Create app)
2. Điền thông tin:
   - **Tên ứng dụng:** `Socdo` (hoặc tên bạn muốn)
   - **Ngôn ngữ mặc định:** `Tiếng Việt`
   - **Ứng dụng hay trò chơi:** Chọn `Ứng dụng`
   - **Miễn phí hay có phí:** Chọn `Miễn phí`
3. Click **"Tạo ứng dụng"**

#### 3.3. Upload AAB file

1. Vào menu bên trái → **Phát hành** (Release) → **Production** (hoặc **Testing** để test trước)
2. Click **"Tạo bản phát hành mới"** (Create new release)
3. Click **"Tải lên"** (Upload) và chọn file `app-release.aab`
4. Điền **Ghi chú bản phát hành** (Release notes):
   ```
   Phiên bản đầu tiên
   - Tính năng mua sắm
   - Quản lý đơn hàng
   - Thông báo đẩy
   ```
5. Click **"Lưu"** (Save)

---

### BƯỚC 4: CHUẨN BỊ STORE LISTING (2-4 giờ)

**Cần chuẩn bị các graphics và thông tin sau:**

#### 4.1. Graphics cần thiết

1. **App Icon:** 
   - Kích thước: **512x512 px**
   - Format: PNG
   - Không trong suốt
   - File: `app-icon-512.png`

2. **Feature Graphic:**
   - Kích thước: **1024x500 px**
   - Format: PNG hoặc JPG
   - File: `feature-graphic-1024x500.png`

3. **Screenshots:**
   - Phone: Ít nhất **2 screenshots** (tối đa 8)
   - Kích thước: **16:9 hoặc 9:16** (tùy app)
   - Format: PNG hoặc JPG
   - File: `screenshot-1.png`, `screenshot-2.png`, ...

#### 4.2. Thông tin cần điền

1. **App Name:** Tên app (ví dụ: "Socdo")
2. **Short Description:** Mô tả ngắn (tối đa 80 ký tự)
   - Ví dụ: "Ứng dụng mua sắm Socdo - Sản phẩm chất lượng, giá tốt"
3. **Full Description:** Mô tả đầy đủ (tối đa 4000 ký tự)
   - Mô tả chi tiết về app, tính năng, lợi ích
4. **App Category:** Chọn category phù hợp (ví dụ: Shopping, Lifestyle)

#### 4.3. Điền vào Google Play Console

1. Vào **Hiện diện cửa hàng** (Store presence) → **Chi tiết ứng dụng chính** (Main store listing)
2. Upload graphics và điền thông tin:
   - Upload app icon
   - Upload feature graphic
   - Upload screenshots
   - Điền app name, descriptions
   - Chọn category

---

### BƯỚC 5: HOÀN THIỆN CÁC PHẦN CÒN LẠI (1-2 giờ)

#### 5.1. Content Rating (Xếp hạng nội dung)

1. Vào **Chính sách** (Policy) → **Nội dung ứng dụng** (App content)
2. Click **"Bắt đầu xếp hạng"** (Start rating)
3. Điền questionnaire về nội dung app:
   - App có quảng cáo không?
   - App có yêu cầu thanh toán không?
   - App có nội dung người lớn không?
   - ...
4. Click **"Gửi"** (Submit)
5. Google sẽ tự động rate (thường vài phút)

#### 5.2. Privacy Policy (Chính sách bảo mật)

**⚠️ BẮT BUỘC!** Google Play sẽ reject nếu thiếu!

1. Vào **Chính sách** (Policy) → **Nội dung ứng dụng** (App content)
2. Scroll xuống **"Chính sách bảo mật"** (Privacy Policy)
3. Thêm URL privacy policy:
   - Ví dụ: `https://yourwebsite.com/privacy-policy`
   - Hoặc: `https://github.com/yourusername/privacy-policy`
   - URL phải accessible (không 404)

**Lưu ý:** Nếu chưa có Privacy Policy, bạn cần:
- Tạo trang Privacy Policy trên website
- Hoặc dùng GitHub Pages
- Hoặc dùng Firebase Hosting

#### 5.3. Pricing & Distribution (Giá và Phân phối)

1. Vào **Chính sách** (Policy) → **Giá và phân phối** (Pricing & Distribution)
2. Chọn:
   - **Miễn phí** hoặc **Có phí**
   - **Quốc gia phân phối:** Chọn tất cả hoặc chọn quốc gia cụ thể
3. Click **"Lưu"** (Save)

---

### BƯỚC 6: SUBMIT FOR REVIEW (5 phút)

#### 6.1. Kiểm tra tất cả sections

Đảm bảo tất cả sections đã điền đầy đủ:
- ✅ Store listing (đã upload graphics và descriptions)
- ✅ Content rating (đã hoàn thành)
- ✅ Privacy Policy (đã thêm URL)
- ✅ Pricing & Distribution (đã chọn)
- ✅ Release (đã upload AAB)

**Không được có dấu cảnh báo đỏ!**

#### 6.2. Submit for Review

1. Vào **Phát hành** (Release) → **Production**
2. Click **"Xem xét bản phát hành"** (Review release)
3. Nếu tất cả OK, click **"Bắt đầu triển khai lên Production"** (Start rollout to Production)
4. Xác nhận submit

#### 6.3. Đợi Google Review

- **Thời gian review:** Thường **1-3 ngày**
- Google sẽ gửi email khi có kết quả
- Có thể kiểm tra status trong Play Console

---

## ⏱️ ƯỚC TÍNH THỜI GIAN

| Giai đoạn | Thời gian |
|-----------|-----------|
| Tạo keystore | 10 phút |
| Build AAB | 5-15 phút |
| Upload AAB | 15 phút |
| Chuẩn bị graphics & metadata | 2-4 giờ |
| Hoàn thiện các phần | 1-2 giờ |
| Submit | 5 phút |
| **Google Review** | **1-3 ngày** |

**Tổng thời gian làm việc:** ~1 ngày  
**Tổng thời gian:** ~1 ngày + 1-3 ngày review

---

## ✅ CHECKLIST HOÀN CHỈNH

### Code Configuration
- [ ] Tạo keystore file (`upload-keystore.jks`)
- [ ] Tạo file `keystore.properties` (từ template)
- [ ] Build AAB thành công: `flutter build appbundle --release`

### Google Play Console
- [ ] Tạo app mới (nếu chưa có)
- [ ] Upload AAB file
- [ ] Upload app icon (512x512)
- [ ] Upload feature graphic (1024x500)
- [ ] Upload screenshots (ít nhất 2)
- [ ] Điền app name
- [ ] Điền short description
- [ ] Điền full description
- [ ] Chọn category
- [ ] Hoàn thành content rating
- [ ] Thêm Privacy Policy URL
- [ ] Chọn pricing (Free/Paid)
- [ ] Chọn countries for distribution
- [ ] Submit for review

---

## ⚠️ LƯU Ý QUAN TRỌNG

### 1. Keystore File - CỰC KỲ QUAN TRỌNG!

**LƯU LẠI Ở NHIỀU NƠI:**
- ✅ Google Drive (encrypted)
- ✅ USB drive (giữ ở nơi an toàn)
- ✅ Máy tính khác
- ✅ Password manager (1Password, LastPass)

**Nếu mất file này:**
- ❌ Bạn sẽ **KHÔNG THỂ** update app lên Google Play nữa!
- ❌ Phải tạo app mới từ đầu
- ❌ Mất tất cả users và reviews

### 2. Privacy Policy - BẮT BUỘC!

- Google Play sẽ **REJECT** nếu thiếu Privacy Policy URL
- URL phải accessible (không 404)
- Phải bằng ngôn ngữ của target audience

### 3. Content Rating - BẮT BUỘC!

- Phải hoàn thành content rating questionnaire
- Google sẽ tự động rate
- Không thể submit nếu chưa có rating

---

## 📚 TÀI LIỆU THAM KHẢO

**Chi tiết hơn:**
- `GOOGLE_PLAY_DEPLOYMENT_GUIDE.md` - Hướng dẫn chi tiết đầy đủ
- `GOOGLE_PLAY_QUICK_START.md` - Quick start guide

**Tài liệu Google:**
- [Google Play Console](https://play.google.com/console)
- [Flutter Android Deployment](https://docs.flutter.dev/deployment/android)

---

## 🆘 VẤN ĐỀ THƯỜNG GẶP

### Lỗi: "Keystore file not found"
- Đảm bảo file `upload-keystore.jks` ở trong `android/app/`
- Kiểm tra đường dẫn trong `keystore.properties` đúng

### Lỗi: "Password incorrect"
- Kiểm tra password trong `keystore.properties` đúng
- Không có khoảng trắng thừa

### Google Play reject vì thiếu Privacy Policy
- Phải có Privacy Policy URL
- URL phải accessible (không 404)
- Phải bằng ngôn ngữ của target audience

### Build AAB lỗi
- Đảm bảo đã chạy `flutter pub get`
- Đảm bảo `keystore.properties` đúng format
- Kiểm tra file keystore tồn tại

---

**Chúc bạn thành công! 🚀**


