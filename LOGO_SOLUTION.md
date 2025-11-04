# ✅ Giải pháp: Logo trong Notification

## 📍 Logo hiện tại

**Vị trí:** Logo đang ở đúng vị trí, KHÔNG CẦN di chuyển!

```
Server path: /home/socdo.vn/public_html/uploads/logo/logo.png
URL: https://socdo.vn/uploads/logo/logo.png
```

## 🔍 Giải thích vấn đề

### 1. ✅ Logo URL đúng và accessible
- Logo có thể truy cập từ browser: `https://socdo.vn/uploads/logo/logo.png` ✅
- URL đúng và file tồn tại ✅

### 2. ⚠️ Server PHP không check được HTTPS
- Lỗi: `Connection refused` khi server PHP check logo URL
- **KHÔNG PHẢI VẤN ĐỀ** vì:
  - FCM server sẽ tự download image từ URL đó
  - FCM không phụ thuộc vào server PHP check
  - Logo URL vẫn được gửi trong payload ✅

### 3. 🎯 Icon nhỏ vs Large Image trong Android

#### **Icon nhỏ (bên trái)** - KHÔNG THỂ thay đổi bằng URL
- Luôn dùng app icon từ `AndroidManifest.xml` (`@mipmap/ic_launcher`)
- Đây là **GIỚI HẠN CỦA ANDROID** - icon phải là resource trong app
- **KHÔNG THỂ** thay bằng URL từ server

#### **Large Image (logo)** - Có thể dùng URL
- Hiển thị logo từ URL (`android.notification.image`)
- **CHỈ hiển thị** khi notification được **EXPAND** (kéo xuống)
- Logo URL đã được set đúng trong payload ✅

## 📱 Cách logo hiển thị trên Android

### Khi notification collapse (thu gọn):
- **Icon nhỏ**: App icon mặc định (không thay đổi được)
- **Không thấy logo** (vì chưa expand)

### Khi notification expand (kéo xuống):
- **Large image**: Logo từ URL sẽ hiển thị ✅
- Logo sẽ được FCM tự download và hiển thị

## ✅ Giải pháp

### 1. Logo URL đã đúng
```php
$logoUrl = 'https://socdo.vn/uploads/logo/logo.png';
```
- ✅ URL accessible từ internet
- ✅ FCM sẽ tự download image
- ✅ Logo sẽ hiển thị khi expand notification

### 2. Không cần di chuyển logo
- Logo đang ở đúng vị trí
- URL public và accessible
- Không cần thay đổi gì

### 3. Để thấy logo trên Android
1. Nhận notification
2. **Kéo xuống** (expand notification)
3. Logo sẽ hiển thị trong large image area

## 🎯 Tóm tắt

| Vấn đề | Giải pháp | Trạng thái |
|--------|-----------|------------|
| Logo URL | `https://socdo.vn/uploads/logo/logo.png` | ✅ Đúng |
| Logo vị trí | `/home/socdo.vn/public_html/uploads/logo/logo.png` | ✅ Đúng |
| Icon nhỏ | App icon (không thay đổi được) | ⚠️ Giới hạn Android |
| Large image | URL đã set, hiển thị khi expand | ✅ Hoạt động |
| FCM download | Tự động download từ URL | ✅ Hoạt động |

## 🔧 Next Steps

1. **Logo URL đã đúng** - Không cần thay đổi
2. **Test trên Android**:
   - Nhận notification
   - **Kéo xuống** (expand notification)
   - Logo sẽ hiển thị trong large image
3. **Nếu vẫn không thấy logo**:
   - Kiểm tra FCM response có thành công không
   - Thử expand notification trên Android
   - Kiểm tra logo URL có accessible từ internet không

## 📝 Lưu ý

- **Icon nhỏ**: Luôn là app icon, không thay đổi được
- **Large image**: Logo sẽ hiển thị khi expand notification
- **FCM**: Sẽ tự download image từ URL (không cần server PHP check)

