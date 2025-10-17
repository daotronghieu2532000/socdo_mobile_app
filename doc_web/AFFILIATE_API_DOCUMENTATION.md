# AFFILIATE API DOCUMENTATION

## Tổng quan hệ thống Affiliate

Hệ thống Affiliate cho phép người dùng kiếm hoa hồng bằng cách chia sẻ link sản phẩm. Khi có người mua hàng qua link của affiliate, họ sẽ nhận được hoa hồng theo cấu hình của shop.

### Luồng hoạt động:

1. **Đăng ký Affiliate**: User đăng ký tham gia chương trình (dk_aff = 1)
2. **Shop tạo Campaign**: Shop cấu hình hoa hồng cho sản phẩm (bảng `sanpham_aff`)
3. **Tạo Link**: Affiliate tạo link rút gọn cho sản phẩm
4. **Tracking**: Khi user click vào link, `utm_source` được lưu vào session/cart
5. **Đặt hàng**: Hoa hồng được tính và lưu vào `donhang.sanpham[].hoa_hong`
6. **Trả hoa hồng**: Khi đơn hàng giao thành công (status = 5):
   - Cộng hoa hồng cho affiliate trực tiếp
   - Cộng hoa hồng nhóm cho parent (nếu có)
7. **Rút tiền**: Sau 7 ngày, affiliate có thể claim commission và tạo yêu cầu rút tiền

---

## 1. AFFILIATE DASHBOARD

**Endpoint**: `GET /v1/affiliate_dashboard`

**Mô tả**: Lấy thống kê tổng quan về hoạt động affiliate

**Parameters**:
- `user_id` (optional): ID của affiliate. Nếu không truyền sẽ lấy từ JWT token

**Headers**:
```
Authorization: Bearer {jwt_token}
```

**Response**:
```json
{
  "success": true,
  "data": {
    "total_clicks": 1250,
    "total_orders": 38,
    "total_commission": 4500000,
    "monthly_revenue": 12000000,
    "conversion_rate": 3.04,
    "conversion_text": "Tốt",
    "total_members": 5,
    "pending_commission": 450000,
    "withdrawable_balance": 4050000,
    "claimable_amount": 450000
  }
}
```

**Giải thích các field**:
- `total_clicks`: Tổng số lượt click vào các link affiliate
- `total_orders`: Tổng số đơn hàng thành công (status = 5)
- `total_commission`: Tổng hoa hồng đã nhận
- `monthly_revenue`: Doanh thu tháng hiện tại
- `conversion_rate`: Tỷ lệ chuyển đổi (orders/clicks * 100)
- `conversion_text`: "Tốt" (>3%), "Trung bình" (1-3%), "Cần cải thiện" (<1%)
- `total_members`: Số thành viên trong team (downline)
- `pending_commission`: Hoa hồng chưa đủ 7 ngày
- `withdrawable_balance`: Số dư có thể rút
- `claimable_amount`: Hoa hồng đã đủ 7 ngày, có thể claim

---

## 2. AFFILIATE PRODUCTS LIST

**Endpoint**: `GET /v1/affiliate_products`

**Mô tả**: Lấy danh sách sản phẩm có chương trình affiliate đang hoạt động

**Parameters**:
- `user_id` (optional): ID của affiliate
- `page` (optional, default=1): Trang hiện tại
- `limit` (optional, default=20, max=50): Số sản phẩm mỗi trang
- `search` (optional): Từ khóa tìm kiếm
- `category` (optional): ID danh mục

**Response**:
```json
{
  "success": true,
  "data": {
    "products": [
      {
        "id": 123,
        "title": "Điện thoại iPhone 15 Pro Max",
        "link": "https://socdo.vn/product/iphone-15-pro-max.html",
        "image": "https://socdo.vn/uploads/...",
        "price": 29990000,
        "old_price": 34990000,
        "sold": 125,
        "shop_id": 456,
        "commission_info": [
          {
            "variant_id": "main",
            "type": "phantram",
            "value": 5
          },
          {
            "variant_id": 789,
            "type": "tru",
            "value": 500000
          }
        ],
        "short_link": "https://socdo.xyz/x/abc123",
        "campaign_name": "Flash Sale Tháng 10"
      }
    ],
    "pagination": {
      "current_page": 1,
      "total_pages": 5,
      "total_products": 95,
      "limit": 20
    }
  }
}
```

**Commission Info**:
- `type = "phantram"`: Hoa hồng theo % của giá sản phẩm
- `type = "tru"`: Hoa hồng cố định (VND)
- `variant_id = "main"`: Áp dụng cho sản phẩm chính (không có variant)
- `variant_id = {số}`: Áp dụng cho variant cụ thể

---

## 3. CREATE AFFILIATE LINK

**Endpoint**: `POST /v1/affiliate_create_link`

**Mô tả**: Tạo hoặc lấy link rút gọn affiliate cho sản phẩm

**Body**:
```json
{
  "user_id": 123,
  "sp_id": 456
}
```

**Response**:
```json
{
  "success": true,
  "data": {
    "short_link": "https://socdo.xyz/x/abc123",
    "full_link": "https://socdo.vn/product/iphone-15-pro-max.html",
    "sp_id": 456
  }
}
```

**Lưu ý**:
- Nếu đã tồn tại link cho sản phẩm này, API sẽ trả về link cũ
- Link rút gọn có format: `https://socdo.xyz/x/{code}` (6 ký tự ngẫu nhiên)

---

## 4. MY AFFILIATE LINKS

**Endpoint**: `GET /v1/affiliate_my_links`

**Mô tả**: Lấy danh sách các link affiliate đã tạo và thống kê hiệu suất

**Parameters**:
- `user_id` (optional): ID của affiliate
- `page` (optional, default=1)
- `limit` (optional, default=20, max=50)

**Response**:
```json
{
  "success": true,
  "data": {
    "links": [
      {
        "id": 789,
        "sp_id": 456,
        "product_title": "Điện thoại iPhone 15 Pro Max",
        "product_image": "https://socdo.vn/uploads/...",
        "product_price": 29990000,
        "shop_id": 123,
        "short_link": "https://socdo.xyz/x/abc123",
        "full_link": "https://socdo.vn/product/...",
        "clicks": 45,
        "orders": 3,
        "commission": 1500000,
        "created_at": "2025-10-01 14:30:00"
      }
    ],
    "pagination": {
      "current_page": 1,
      "total_pages": 3,
      "total_links": 52,
      "limit": 20
    }
  }
}
```

---

## 5. AFFILIATE ORDERS

**Endpoint**: `GET /v1/affiliate_orders`

**Mô tả**: Lấy danh sách đơn hàng có hoa hồng của affiliate

**Parameters**:
- `user_id` (optional): ID của affiliate
- `page` (optional, default=1)
- `limit` (optional, default=20, max=50)

**Response**:
```json
{
  "success": true,
  "data": {
    "orders": [
      {
        "order_id": 12345,
        "ma_don": "DH001_123_456",
        "products": [
          {
            "sp_id": 456,
            "title": "Điện thoại iPhone 15 Pro Max",
            "quantity": 1,
            "price": 29990000,
            "commission": 500000,
            "size": "128GB",
            "color": "Titan Xanh"
          }
        ],
        "total_amount": 30490000,
        "total_commission": 500000,
        "status": {
          "code": 5,
          "text": "Giao thành công",
          "color": "#4CAF50"
        },
        "created_at": "2025-10-05 10:30:00",
        "commission_paid": true
      }
    ],
    "pagination": {
      "current_page": 1,
      "total_pages": 2,
      "total_orders": 38,
      "limit": 20
    }
  }
}
```

**Status Codes**:
- 0: Chờ xử lý
- 1: Đã tiếp nhận đơn
- 2: Đã giao đơn vị vận chuyển
- 3: Yêu cầu hủy đơn
- 4: Đã hủy đơn
- 5: Giao thành công (hoa hồng được trả)
- 6: Đã hoàn đơn

---

## 6. CLAIM COMMISSION

**Endpoint**: `POST /v1/affiliate_claim_commission`

**Mô tả**: Chuyển hoa hồng từ pending sang withdrawable (sau 7 ngày)

**Body**:
```json
{
  "user_id": 123
}
```

**Response**:
```json
{
  "success": true,
  "message": "Đã chuyển 450,000đ vào số dư có thể rút",
  "data": {
    "claimed_amount": 450000,
    "transactions_count": 5,
    "new_withdrawable_balance": 4500000
  }
}
```

**Lưu ý**:
- Chỉ chuyển được hoa hồng từ các đơn hàng đã giao thành công hơn 7 ngày
- Hoa hồng được chuyển từ `user_info.user_money` → `user_info.user_money2`
- Cập nhật `lichsu_chitieu.transferred_to_withdrawable` từ 0 → 1

---

## 7. WITHDRAW REQUEST

**Endpoint**: `POST /v1/affiliate_withdraw`

**Mô tả**: Tạo yêu cầu rút tiền hoa hồng

**Body**:
```json
{
  "user_id": 123,
  "amount": 500000,
  "bank_account": "1234567890",
  "bank_name": "Vietcombank",
  "account_holder": "NGUYEN VAN A"
}
```

**Response**:
```json
{
  "success": true,
  "message": "Yêu cầu rút tiền 500,000 VND đã được gửi thành công",
  "data": {
    "amount": 500000,
    "remaining_balance": 4000000
  }
}
```

**Lưu ý**:
- Chỉ rút được từ số dư `user_money2` (đã claim)
- Yêu cầu được lưu vào bảng `rut_tien` với `status = 0` (chờ duyệt)
- Admin sẽ xử lý và chuyển khoản thủ công

---

## Error Responses

Tất cả API đều có thể trả về error với format:

```json
{
  "success": false,
  "message": "Error message here"
}
```

**Common Errors**:
- `User ID is required`: Thiếu user_id
- `User is not registered for affiliate program`: User chưa đăng ký affiliate
- `Insufficient withdrawable balance`: Số dư không đủ để rút
- `Invalid withdrawal amount`: Số tiền rút không hợp lệ
- `Product not found`: Sản phẩm không tồn tại

---

## Authentication

Tất cả API đều hỗ trợ 2 cách xác thực:

### 1. Query Parameter (ưu tiên):
```
GET /v1/affiliate_dashboard?user_id=123
```

### 2. JWT Token (fallback):
```
GET /v1/affiliate_dashboard
Headers: Authorization: Bearer {jwt_token}
```

JWT token được tạo từ:
- `secret_key`: Lấy từ `index_setting.key`
- `issuer`: Lấy từ `index_setting.issuer`
- Algorithm: HS256

---

## Database Tables

### 1. `sanpham_aff`
Lưu cấu hình hoa hồng của shop cho từng campaign:
```sql
- id: INT
- shop: INT (shop owner ID)
- tieu_de: VARCHAR (campaign name)
- main_product: TEXT (CSV sp_ids)
- sub_product: TEXT (JSON commission config)
- sub_id: TEXT (CSV variant_ids)
- date_start: INT (timestamp)
- date_end: INT (timestamp)
- date_post: INT (timestamp)
```

**sub_product format**:
```json
{
  "123": [
    {"variant_id": "main", "loai": "phantram", "hoa_hong": 10},
    {"variant_id": "456", "loai": "tru", "hoa_hong": 50000}
  ]
}
```

### 2. `rut_gon_shop`
Lưu link rút gọn affiliate:
```sql
- id: INT
- sp_id: INT (product ID)
- link: TEXT (full product URL)
- rut_gon: VARCHAR(50) (short code)
- user_id: INT (affiliate ID)
- shop: INT (shop owner ID)
- click: INT (click count - not auto-incremented)
- date_post: INT (timestamp)
```

### 3. `lichsu_chitieu`
Lưu lịch sử hoa hồng:
```sql
- id: INT
- user_id: INT
- sotien: DECIMAL
- truoc: DECIMAL (balance before)
- sau: DECIMAL (balance after)
- noidung: TEXT (description)
- date_post: INT (timestamp)
- transferred_to_withdrawable: TINYINT (0=pending, 1=claimable)
```

### 4. `rut_tien`
Yêu cầu rút tiền:
```sql
- id: INT
- user_id: INT
- so_tien: DECIMAL
- chu_khoan: VARCHAR (account holder name)
- so_taikhoan: VARCHAR (bank account)
- ngan_hang: VARCHAR (bank name)
- status: TINYINT (0=pending, 1=approved, 2=rejected)
- date_post: INT (timestamp)
```

### 5. `user_info`
Thông tin user và số dư:
```sql
- user_id: INT
- dk_aff: TINYINT (0=not registered, 1=registered)
- aff: INT (parent affiliate ID)
- user_money: DECIMAL (total commission earned)
- user_money2: DECIMAL (withdrawable balance)
```

---

## Testing với Postman

### Example 1: Get Dashboard
```
GET https://api.socdo.vn/v1/affiliate_dashboard?user_id=123
```

### Example 2: Create Link
```
POST https://api.socdo.vn/v1/affiliate_create_link
Content-Type: application/json

{
  "user_id": 123,
  "sp_id": 456
}
```

### Example 3: Claim Commission
```
POST https://api.socdo.vn/v1/affiliate_claim_commission
Content-Type: application/json

{
  "user_id": 123
}
```

---

## Notes

1. **Commission Calculation**:
   - `phantram`: `commission = product_price * (value / 100)`
   - `tru`: `commission = value * quantity`

2. **Group Commission**:
   - Khi affiliate có parent (`user_info.aff > 0`)
   - Parent nhận % hoa hồng từ con (`index_setting.hoahong_nhom`)
   - Ví dụ: Con nhận 500k, parent nhận 50k (nếu hoahong_nhom = 10%)

3. **Click Tracking**:
   - Hiện tại `rut_gon_shop.click` không tự động tăng
   - Cần implement tracking khi user click vào link rút gọn

4. **Commission Timeline**:
   - Ngày 0: Đơn hàng giao thành công → Cộng vào `user_money`
   - Ngày 7: Có thể claim → Chuyển vào `user_money2`
   - Bất kỳ lúc nào: Rút tiền từ `user_money2`

