# 🚀 GOOGLE PLAY QUICK START - TÓM TẮT NHANH

## ⚡ CÁC BƯỚC CẦN LÀM NGAY

### 1️⃣ TẠO RELEASE SIGNING KEY (10 phút)

**Vấn đề:** Hiện đang dùng debug key → Google Play sẽ KHÔNG CHẤP NHẬN!

**Cách làm:**

1. **Tạo keystore file:**
```bash
cd android/app
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. **Điền thông tin khi được hỏi:**
   - Password: (Nhập password mạnh, LƯU LẠI!)
   - Tên, tổ chức, thành phố, quốc gia

3. **Tạo file keystore.properties:**
```bash
cd android
cp keystore.properties.example keystore.properties
```

4. **Sửa file `android/keystore.properties`:**
   - Thay `YOUR_KEYSTORE_PASSWORD_HERE` → password vừa tạo
   - Thay `YOUR_KEY_PASSWORD_HERE` → password vừa tạo (thường giống nhau)
   - Giữ nguyên `keyAlias=upload` và `storeFile=upload-keystore.jks`

**⚠️ QUAN TRỌNG:** 
- Lưu file `upload-keystore.jks` và password ở nơi AN TOÀN!
- Nếu mất, bạn sẽ KHÔNG THỂ update app lên Google Play nữa!

---

### 2️⃣ BUILD APP BUNDLE (AAB) (5-15 phút)

**Google Play yêu cầu file AAB, không phải APK!**

```bash
flutter build appbundle --release
```

**File output:** `build/app/outputs/bundle/release/app-release.aab`

---

### 3️⃣ UPLOAD LÊN GOOGLE PLAY CONSOLE (30 phút)

1. **Đăng nhập:** https://play.google.com/console
2. **Tạo app mới** (nếu chưa có):
   - Tên ứng dụng: "Socdo" (hoặc tên bạn muốn)
   - Ngôn ngữ: Tiếng Việt
   - Ứng dụng hay trò chơi: Ứng dụng
   - Miễn phí hay có phí: Miễn phí
3. **Upload AAB:**
   - Vào **Release** → **Production** (hoặc **Testing**)
   - Click **Create new release**
   - Upload file `app-release.aab`
   - Điền **Release notes** (ví dụ: "Phiên bản đầu tiên")
   - Click **Save**

---

### 4️⃣ CHUẨN BỊ STORE LISTING (2-4 giờ)

**Cần chuẩn bị:**

1. **App Icon:** 512x512 px (PNG)
2. **Feature Graphic:** 1024x500 px (cho Play Store)
3. **Screenshots:** Ít nhất 2 ảnh (tối đa 8)
4. **App Description:** Mô tả app (tối đa 4000 ký tự)
5. **Short Description:** Mô tả ngắn (tối đa 80 ký tự)
6. **Privacy Policy URL:** BẮT BUỘC! (URL website có privacy policy)

**Điền vào Google Play Console:**
- Vào **Store presence** → **Main store listing**
- Upload graphics và điền thông tin

---

### 5️⃣ HOÀN THIỆN CÁC PHẦN CÒN LẠI (1-2 giờ)

1. **Content Rating:**
   - Vào **Policy** → **App content**
   - Click **Start rating**
   - Điền questionnaire
   - Submit

2. **Privacy Policy:**
   - Vào **Policy** → **App content**
   - Thêm Privacy Policy URL

3. **Pricing & Distribution:**
   - Chọn quốc gia phân phối
   - Xác nhận miễn phí/có phí

---

### 6️⃣ SUBMIT FOR REVIEW (5 phút)

1. Kiểm tra tất cả sections đã điền (không có dấu cảnh báo đỏ)
2. Vào **Release** → **Production**
3. Click **Review release**
4. Click **Start rollout to Production**
5. Đợi Google review (1-3 ngày)

---

## ✅ CHECKLIST NHANH

**Code:**
- [ ] Tạo keystore file (`upload-keystore.jks`)
- [ ] Tạo file `keystore.properties` (từ template)
- [ ] Build AAB thành công: `flutter build appbundle --release`

**Google Play Console:**
- [ ] Tạo app mới
- [ ] Upload AAB file
- [ ] Upload app icon (512x512)
- [ ] Upload feature graphic (1024x500)
- [ ] Upload screenshots (ít nhất 2)
- [ ] Điền app description
- [ ] Hoàn thành content rating
- [ ] Thêm Privacy Policy URL
- [ ] Submit for review

---

## ⏱️ THỜI GIAN

| Giai đoạn | Thời gian |
|-----------|-----------|
| Tạo keystore | 10 phút |
| Build AAB | 5-15 phút |
| Upload | 15 phút |
| Chuẩn bị metadata | 2-4 giờ |
| Submit | 30 phút |
| **Google Review** | **1-3 ngày** |

**Tổng:** ~1 ngày làm việc + 1-3 ngày review

---

## ⚠️ LƯU Ý QUAN TRỌNG

### 1. Keystore File
- **LƯU LẠI Ở NHIỀU NƠI!** (Google Drive, USB, máy khác)
- Nếu mất file này, bạn sẽ KHÔNG THỂ update app nữa!
- Phải tạo app mới từ đầu nếu mất keystore

### 2. Privacy Policy
- **BẮT BUỘC!** App Store sẽ reject nếu thiếu
- Phải là URL thật, accessible
- Có thể dùng GitHub Pages, Firebase Hosting

### 3. Content Rating
- Phải hoàn thành trước khi submit
- Google sẽ tự động rate dựa trên questionnaire

---

**Xem hướng dẫn chi tiết tại:** `GOOGLE_PLAY_DEPLOYMENT_GUIDE.md`


