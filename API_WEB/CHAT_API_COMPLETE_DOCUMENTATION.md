# Chat API Documentation

## Tổng quan
API Chat cho phép khách hàng và nhà cung cấp (NCC) giao tiếp qua tin nhắn realtime.

## Base URL
```
https://api.socdo.vn/v1/chat_api_correct
```

## Authentication
Tất cả requests cần có JWT token trong header:
```
Authorization: Bearer [your_jwt_token]
```

## Các Actions

### 1. Tạo phiên chat
**Action:** `create_session`

**Method:** GET/POST

**Parameters:**
- `user_id` (int, required): ID của khách hàng
- `shop_id` (int, required): ID của shop/NCC

**Example:**
```
GET: https://api.socdo.vn/v1/chat_api_correct?action=create_session&user_id=8050&shop_id=23933
```

**Response:**
```json
{
    "success": true,
    "session_id": "12",
    "phien": "e0eaa70470cdb1c0e6c366e1add84d18",
    "shop_info": {
        "shop_id": "23933",
        "shop_name": "Socdo Choice",
        "shop_avatar": "/uploads/avatar/socdo-choice-1755673719.jpg"
    }
}
```

### 2. Lấy danh sách tin nhắn
**Action:** `get_messages`

**Method:** GET/POST

**Parameters:**
- `phien` (string, required): ID phiên chat
- `page` (int, optional): Trang (default: 1)
- `limit` (int, optional): Số tin nhắn/trang (default: 50, max: 100)

**Example:**
```
GET: https://api.socdo.vn/v1/chat_api_correct?action=get_messages&phien=e0eaa70470cdb1c0e6c366e1add84d18
```

**Response:**
```json
{
    "success": true,
    "messages": [
        {
            "id": "16",
            "phien": "e0eaa70470cdb1c0e6c366e1add84d18",
            "sender_id": "8050",
            "sender_type": "customer",
            "sender_name": "Customer Name",
            "sender_avatar": "/images/user.png",
            "content": "chào o",
            "is_read": true,
            "date_post": 1755680434,
            "date_formatted": "2025-08-20 10:20:34",
            "product_id": 0,
            "variant_id": 0
        }
    ],
    "pagination": {
        "page": 1,
        "limit": 50,
        "total": 1,
        "total_pages": 1
    }
}
```

### 3. Gửi tin nhắn
**Action:** `send_message`

**Method:** POST

**Parameters:**
- `phien` (string, required): ID phiên chat
- `content` (string, required): Nội dung tin nhắn
- `sender_type` (string, required): "customer" hoặc "ncc"
- `product_id` (int, optional): ID sản phẩm liên quan
- `variant_id` (int, optional): ID biến thể sản phẩm

**Example:**
```
POST: https://api.socdo.vn/v1/chat_api_correct
Body: {
    "action": "send_message",
    "phien": "e0eaa70470cdb1c0e6c366e1add84d18",
    "content": "Xin chào!",
    "sender_type": "customer"
}
```

**Response:**
```json
{
    "success": true,
    "message_id": "47",
    "message": "Tin nhắn đã được gửi thành công"
}
```

### 4. Đánh dấu đã đọc
**Action:** `mark_read`

**Method:** GET/POST

**Parameters:**
- `phien` (string, required): ID phiên chat
- `mark_all` (boolean, optional): Đánh dấu tất cả tin nhắn
- `message_ids` (string/array, optional): Danh sách ID tin nhắn (dùng dấu phẩy phân cách)

**Example:**
```
GET: https://api.socdo.vn/v1/chat_api_correct?action=mark_read&phien=e0eaa70470cdb1c0e6c366e1add84d18&mark_all=true
```

**Response:**
```json
{
    "success": true,
    "message": "Đã đánh dấu tất cả tin nhắn là đã đọc"
}
```

### 5. Lấy danh sách phiên chat
**Action:** `list_sessions`

**Method:** GET/POST

**Parameters:**
- `user_id` (int, required): ID của user
- `user_type` (string, required): "customer" hoặc "ncc"
- `page` (int, optional): Trang (default: 1)
- `limit` (int, optional): Số phiên/trang (default: 20, max: 100)

**Example:**
```
GET: https://api.socdo.vn/v1/chat_api_correct?action=list_sessions&user_id=8050&user_type=customer
```

**Response:**
```json
{
    "success": true,
    "sessions": [
        {
            "id": "12",
            "phien": "e0eaa70470cdb1c0e6c366e1add84d18",
            "shop_id": "23933",
            "customer_id": "8050",
            "shop_name": "Socdo Choice",
            "shop_avatar": "/uploads/avatar/socdo-choice-1755673719.jpg",
            "customer_name": "Customer Name",
            "customer_avatar": "/images/user.png",
            "last_message": "chào o",
            "last_sender_type": "customer",
            "last_message_time": 1755680434,
            "last_message_formatted": "2025-08-20 10:20:34",
            "unread_count_customer": 0,
            "unread_count_ncc": 0,
            "status": "active",
            "created_at": 1755680434,
            "created_formatted": "2025-08-20 10:20:34"
        }
    ],
    "pagination": {
        "page": 1,
        "limit": 20,
        "total": 1,
        "total_pages": 1
    }
}
```

### 6. Đếm tin nhắn chưa đọc
**Action:** `get_unread_count`

**Method:** GET/POST

**Parameters:**
- `user_id` (int, required): ID của user
- `user_type` (string, required): "customer" hoặc "ncc"

**Example:**
```
GET: https://api.socdo.vn/v1/chat_api_correct?action=get_unread_count&user_id=8050&user_type=customer
```

**Response:**
```json
{
    "success": true,
    "unread_count": 5
}
```

### 7. Đóng phiên chat
**Action:** `close_session`

**Method:** GET/POST

**Parameters:**
- `phien` (string, required): ID phiên chat

**Example:**
```
GET: https://api.socdo.vn/v1/chat_api_correct?action=close_session&phien=e0eaa70470cdb1c0e6c366e1add84d18
```

**Response:**
```json
{
    "success": true,
    "message": "Phiên chat đã được đóng"
}
```

## Error Responses

Tất cả error responses có format:
```json
{
    "success": false,
    "message": "Mô tả lỗi"
}
```

## Status Codes
- `200`: Success
- `400`: Bad Request (thiếu parameters)
- `401`: Unauthorized (token không hợp lệ)
- `404`: Not Found (không tìm thấy dữ liệu)
- `500`: Internal Server Error

## Business Rules

### Kiểm tra loại tài khoản:
- **Khách hàng**: `shop = 0`, `ctv = 0`, `dropship = 0`, `nhan_vien = 0`
- **Dropship**: `dropship > 0` (có thể chat và mua hàng)
- **Nhân viên**: `nhan_vien > 0` (có thể chat và mua hàng)
- **CTV**: `ctv > 0` (không được chat với nhà bán khác)
- **Nhà bán**: `shop > 0` hoặc `ctv > 0` hoặc `dropship > 0` hoặc `nhan_vien > 0`

### Quy tắc chat:
1. **Khách hàng, Dropship, Nhân viên** được tạo phiên chat với nhà bán
2. **CTV không thể** sử dụng chức năng chat khách hàng
3. **Shop_id phải là nhà bán** để có thể chat
4. **sender_type = 'customer'** được phép cho khách hàng, dropship, nhân viên (trừ CTV)

### Error Messages:
- `"Tài khoản cộng tác viên (CTV) không thể sử dụng chức năng chat khách hàng"`
- `"Tài khoản này không phải là nhà bán"`
- `"Tài khoản cộng tác viên (CTV) không thể gửi tin nhắn với vai trò khách hàng"`

## Notes
- Tất cả timestamps là Unix timestamp (seconds)
- Pagination bắt đầu từ page = 1
- `sender_type` phải là "customer" hoặc "ncc"
- `user_type` phải là "customer" hoặc "ncc"
- API hỗ trợ cả GET và POST requests
- Cloudflare có thể block một số requests, khuyến nghị sử dụng GET requests
- **Quan trọng**: API kiểm tra nghiêm ngặt loại tài khoản để đảm bảo chỉ khách hàng mới được chat với nhà bán
