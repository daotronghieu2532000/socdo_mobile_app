# 📋 GIẢI THÍCH $FCM_PROJECT_ID VÀ $FCM_API_URL

## 🔍 $FCM_PROJECT_ID LÀ GÌ?

**`$FCM_PROJECT_ID`** là **Project ID của Firebase project** của bạn.

### ✅ Bạn đã có sẵn rồi!

**Cách 1: Lấy từ Firebase Console**
1. Vào https://console.firebase.google.com/
2. Chọn project của bạn (`socdomobile`)
3. Vào **Project Settings** (⚙️ icon)
4. Xem **Project ID** ở đầu trang

**Cách 2: Lấy từ Service Account JSON file** (ĐÃ CÓ)
- Mở file `socdomobile-36bf021cb402.json`
- Tìm field `"project_id"` → giá trị là `"socdomobile"`

**Hiện tại trong code**: `$FCM_PROJECT_ID = 'socdomobile'` ✅ **ĐÚNG RỒI!**

---

## 🔍 $FCM_API_URL LÀ GÌ?

**`$FCM_API_URL`** là **URL endpoint của FCM HTTP V1 API** để gửi push notification.

### ✅ Không cần lấy, được tạo tự động!

**Công thức**:
```
https://fcm.googleapis.com/v1/projects/{PROJECT_ID}/messages:send
```

**Với PROJECT_ID = 'socdomobile'**:
```
https://fcm.googleapis.com/v1/projects/socdomobile/messages:send
```

**Hiện tại trong code**: 
```php
$FCM_API_URL = 'https://fcm.googleapis.com/v1/projects/' . $FCM_PROJECT_ID . '/messages:send';
```
✅ **ĐÚNG RỒI!**

---

## 🎯 KẾT LUẬN

### ✅ **Bạn KHÔNG cần làm gì!**

1. **`$FCM_PROJECT_ID`**: Đã có trong file JSON (`"project_id": "socdomobile"`) ✅
2. **`$FCM_API_URL`**: Được tạo tự động từ Project ID ✅

### 💡 **CẢI THIỆN (Tùy chọn)**

Tôi sẽ sửa code để **tự động lấy Project ID từ file JSON** thay vì hardcode, để đảm bảo luôn đúng.

---

**📅 Created**: 2025-01-XX  
**✅ Status**: Project ID = 'socdomobile' (Đúng rồi!)

