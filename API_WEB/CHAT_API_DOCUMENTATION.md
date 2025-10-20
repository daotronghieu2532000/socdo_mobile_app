# 📱 API Chat Realtime cho App Mobile

## 🔐 Authentication
Tất cả API đều sử dụng JWT token với:
- **Key**: `Socdo123@2025`
- **Issuer**: `api.socdo.vn`
- **Header**: `Authorization: Bearer <token>`

## 📋 Danh Sách API

### 1. **Tạo Phiên Chat**
```
POST /includes/API_socdo/chat_api.php
Action: create_session
```

**Parameters:**
- `shop_id` (int): ID nhà bán

**Response:**
```json
{
    "success": true,
    "session_id": 123,
    "phien": "chat_123_456_1234567890_1234",
    "shop_info": {
        "shop_id": 123,
        "shop_name": "Tên Shop",
        "shop_avatar": "/images/shop.png"
    }
}
```

### 2. **Danh Sách Phiên Chat**
```
POST /includes/API_socdo/chat_api.php
Action: list_sessions
```

**Parameters:**
- `page` (int): Trang (mặc định: 1)
- `limit` (int): Số lượng/trang (mặc định: 20)

**Response:**
```json
{
    "success": true,
    "sessions": [
        {
            "session_id": 123,
            "phien": "chat_123_456_1234567890_1234",
            "shop_id": 123,
            "shop_name": "Tên Shop",
            "shop_avatar": "/images/shop.png",
            "last_message": "Tin nhắn cuối cùng",
            "last_message_time": 1234567890,
            "last_message_formatted": "14:30 25/01/2025",
            "unread_count": 5
        }
    ],
    "pagination": {
        "current_page": 1,
        "per_page": 20,
        "total": 50,
        "total_pages": 3
    }
}
```

### 3. **Lấy Tin Nhắn**
```
POST /includes/API_socdo/chat_api.php
Action: get_messages
```

**Parameters:**
- `session_id` (int): ID phiên chat
- `phien` (string): Mã phiên chat
- `page` (int): Trang (mặc định: 1)
- `limit` (int): Số lượng/trang (mặc định: 50)

**Response:**
```json
{
    "success": true,
    "messages": [
        {
            "id": 456,
            "sender_id": 123,
            "sender_type": "customer",
            "sender_name": "Tên Khách",
            "sender_avatar": "/images/user.png",
            "message": "Nội dung tin nhắn",
            "date_post": 1234567890,
            "date_formatted": "14:30 25/01/2025",
            "is_read": 1,
            "is_own": true
        }
    ],
    "phien": "chat_123_456_1234567890_1234",
    "pagination": {
        "current_page": 1,
        "per_page": 50,
        "total": 100,
        "total_pages": 2
    }
}
```

### 4. **Gửi Tin Nhắn**
```
POST /includes/API_socdo/chat_api.php
Action: send_message
```

**Parameters:**
- `session_id` (int): ID phiên chat
- `phien` (string): Mã phiên chat
- `message` (string): Nội dung tin nhắn
- `product_id` (int): ID sản phẩm (tùy chọn)
- `variant_id` (int): ID biến thể (tùy chọn)

**Response:**
```json
{
    "success": true,
    "message": {
        "id": 456,
        "sender_id": 123,
        "sender_type": "customer",
        "sender_name": "Tên Khách",
        "sender_avatar": "/images/user.png",
        "message": "Nội dung tin nhắn",
        "date_post": 1234567890,
        "date_formatted": "14:30 25/01/2025",
        "is_read": 0,
        "is_own": true
    }
}
```

### 5. **Đánh Dấu Đã Đọc**
```
POST /includes/API_socdo/chat_api.php
Action: mark_read
```

**Parameters:**
- `session_id` (int): ID phiên chat
- `phien` (string): Mã phiên chat

**Response:**
```json
{
    "success": true,
    "message": "Đã đánh dấu đọc"
}
```

### 6. **Đếm Tin Nhắn Chưa Đọc**
```
POST /includes/API_socdo/chat_api.php
Action: get_unread_count
```

**Response:**
```json
{
    "success": true,
    "unread_count": 15
}
```

### 7. **Đóng Phiên Chat**
```
POST /includes/API_socdo/chat_api.php
Action: close_session
```

**Parameters:**
- `session_id` (int): ID phiên chat
- `phien` (string): Mã phiên chat

**Response:**
```json
{
    "success": true,
    "message": "Đã đóng phiên chat"
}
```

### 8. **Tìm Kiếm Tin Nhắn**
```
POST /includes/API_socdo/chat_api.php
Action: search_messages
```

**Parameters:**
- `session_id` (int): ID phiên chat
- `phien` (string): Mã phiên chat
- `keyword` (string): Từ khóa tìm kiếm
- `page` (int): Trang (mặc định: 1)
- `limit` (int): Số lượng/trang (mặc định: 20)

**Response:**
```json
{
    "success": true,
    "messages": [
        {
            "id": 456,
            "sender_id": 123,
            "sender_type": "customer",
            "sender_name": "Tên Khách",
            "sender_avatar": "/images/user.png",
            "message": "Tin nhắn chứa từ khóa",
            "date_post": 1234567890,
            "date_formatted": "14:30 25/01/2025",
            "is_read": 1,
            "is_own": true
        }
    ],
    "keyword": "từ khóa",
    "pagination": {
        "current_page": 1,
        "per_page": 20,
        "total": 5,
        "total_pages": 1
    }
}
```

## 🔄 Realtime Support

### **Server-Sent Events (SSE)**
```
GET /includes/API_socdo/chat_sse.php?token=<jwt_token>&phien=<phien>&session_id=<session_id>
```

**Events:**
- `connected`: Kết nối thành công
- `ping`: Ping để giữ kết nối
- `new_message`: Tin nhắn mới
- `message_read`: Tin nhắn đã được đọc
- `error`: Lỗi

**Example JavaScript:**
```javascript
const eventSource = new EventSource('/includes/API_socdo/chat_sse.php?token=' + token + '&phien=' + phien);

eventSource.onmessage = function(event) {
    const data = JSON.parse(event.data);
    
    switch(data.type) {
        case 'connected':
            console.log('Kết nối SSE thành công');
            break;
        case 'new_message':
            // Hiển thị tin nhắn mới
            displayMessage(data.message);
            break;
        case 'message_read':
            // Cập nhật trạng thái đã đọc
            updateMessageStatus(data.message_id);
            break;
        case 'ping':
            // Giữ kết nối
            break;
        case 'error':
            console.error('Lỗi SSE:', data.message);
            break;
    }
};
```

### **Socket Events**
```
POST /includes/API_socdo/emit_socket.php
```

**Events được emit:**
- `ncc_new_message`: NCC gửi tin nhắn
- `customer_new_message`: Customer gửi tin nhắn
- `update_total_chat_ncc`: Cập nhật badge
- `ncc_message_seen`: NCC đã đọc tin nhắn
- `customer_message_seen`: Customer đã đọc tin nhắn

## 📱 Flow Sử Dụng Cho App Mobile

### **1. Khởi Tạo Chat**
```javascript
// Tạo phiên chat với shop
const createSession = async (shopId) => {
    const response = await fetch('/includes/API_socdo/chat_api.php', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Authorization': 'Bearer ' + token
        },
        body: `action=create_session&shop_id=${shopId}`
    });
    
    return await response.json();
};
```

### **2. Load Danh Sách Chat**
```javascript
// Lấy danh sách phiên chat
const loadChatList = async (page = 1) => {
    const response = await fetch('/includes/API_socdo/chat_api.php', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Authorization': 'Bearer ' + token
        },
        body: `action=list_sessions&page=${page}&limit=20`
    });
    
    return await response.json();
};
```

### **3. Load Tin Nhắn**
```javascript
// Lấy tin nhắn của phiên chat
const loadMessages = async (sessionId, page = 1) => {
    const response = await fetch('/includes/API_socdo/chat_api.php', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Authorization': 'Bearer ' + token
        },
        body: `action=get_messages&session_id=${sessionId}&page=${page}&limit=50`
    });
    
    return await response.json();
};
```

### **4. Gửi Tin Nhắn**
```javascript
// Gửi tin nhắn
const sendMessage = async (sessionId, message, productId = 0) => {
    const response = await fetch('/includes/API_socdo/chat_api.php', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Authorization': 'Bearer ' + token
        },
        body: `action=send_message&session_id=${sessionId}&message=${encodeURIComponent(message)}&product_id=${productId}`
    });
    
    return await response.json();
};
```

### **5. Đánh Dấu Đã Đọc**
```javascript
// Đánh dấu tin nhắn đã đọc
const markAsRead = async (sessionId) => {
    const response = await fetch('/includes/API_socdo/chat_api.php', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Authorization': 'Bearer ' + token
        },
        body: `action=mark_read&session_id=${sessionId}`
    });
    
    return await response.json();
};
```

### **6. Realtime với SSE**
```javascript
// Kết nối SSE để nhận tin nhắn realtime
const connectSSE = (phien) => {
    const eventSource = new EventSource(`/includes/API_socdo/chat_sse.php?token=${token}&phien=${phien}`);
    
    eventSource.onmessage = function(event) {
        const data = JSON.parse(event.data);
        
        if (data.type === 'new_message') {
            // Thêm tin nhắn mới vào UI
            addMessageToUI(data.message);
        } else if (data.type === 'message_read') {
            // Cập nhật trạng thái đã đọc
            updateMessageReadStatus(data.message_id);
        }
    };
    
    eventSource.onerror = function(event) {
        console.error('SSE connection error');
        // Có thể implement retry logic
    };
    
    return eventSource;
};
```

## 🗄️ Database Schema

### **Bảng `chat_ncc`:**
```sql
CREATE TABLE `chat_ncc` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `phien` varchar(64) NOT NULL,
  `shop_id` int(11) NOT NULL,
  `customer_id` int(11) NOT NULL,
  `sender_id` int(11) NOT NULL,
  `sender_type` enum('customer','ncc') NOT NULL,
  `noi_dung` text NOT NULL,
  `doc` tinyint(1) DEFAULT '0',
  `active` tinyint(1) DEFAULT '1',
  `date_post` int(11) NOT NULL,
  `product_id` int(11) DEFAULT '0',
  `variant_id` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx_phien` (`phien`),
  KEY `idx_shop_customer` (`shop_id`,`customer_id`),
  KEY `idx_date_post` (`date_post`)
);
```

### **Bảng `chat_sessions_ncc`:**
```sql
CREATE TABLE `chat_sessions_ncc` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `phien` varchar(64) NOT NULL,
  `shop_id` int(11) NOT NULL,
  `customer_id` int(11) NOT NULL,
  `product_id` int(11) DEFAULT '0',
  `variant_id` int(11) DEFAULT '0',
  `last_message_time` int(11) NOT NULL,
  `unread_count_customer` int(11) DEFAULT '0',
  `unread_count_ncc` int(11) DEFAULT '0',
  `status` enum('active','closed') DEFAULT 'active',
  `created_at` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `phien` (`phien`),
  KEY `idx_shop_customer` (`shop_id`,`customer_id`)
);
```

## 🔧 Cấu Hình

### **JWT Token Structure:**
```json
{
    "user_id": 123,
    "user_type": "customer",
    "iss": "api.socdo.vn",
    "exp": 1234567890
}
```

### **Error Codes:**
- `401`: Token không hợp lệ
- `400`: Dữ liệu không hợp lệ
- `403`: Không có quyền truy cập
- `500`: Lỗi server

## 📝 Notes

1. **Pagination**: Tất cả API list đều hỗ trợ phân trang
2. **Realtime**: Sử dụng SSE cho realtime, có thể kết hợp với WebSocket
3. **Security**: Tất cả API đều yêu cầu JWT authentication
4. **Performance**: Có index trên các trường quan trọng
5. **Scalability**: Có thể scale bằng cách thêm Redis cho caching
