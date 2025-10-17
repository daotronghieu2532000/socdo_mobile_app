<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>API Danh Sách Thông Báo - Mobile</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            line-height: 1.6;
            margin: 0;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        h1 {
            color: #333;
            border-bottom: 3px solid #007bff;
            padding-bottom: 10px;
        }
        .notification-badge {
            background: #dc3545;
            color: white;
            border-radius: 50%;
            padding: 2px 6px;
            font-size: 12px;
            position: absolute;
            top: -5px;
            right: -5px;
        }
        h2 {
            color: #007bff;
            margin-top: 30px;
            border-left: 4px solid #007bff;
            padding-left: 15px;
        }
        .endpoint {
            background: #f8f9fa;
            border: 1px solid #dee2e6;
            border-radius: 5px;
            padding: 15px;
            margin: 15px 0;
            font-family: 'Courier New', monospace;
        }
        .method {
            display: inline-block;
            padding: 5px 10px;
            border-radius: 3px;
            font-weight: bold;
            color: white;
            margin-right: 10px;
        }
        .get { background-color: #28a745; }
        .parameter {
            background: #e9ecef;
            padding: 10px;
            border-radius: 5px;
            margin: 10px 0;
        }
        .param-table {
            width: 100%;
            border-collapse: collapse;
            margin: 15px 0;
        }
        .param-table th, .param-table td {
            border: 1px solid #dee2e6;
            padding: 12px;
            text-align: left;
        }
        .param-table th {
            background-color: #f8f9fa;
            font-weight: bold;
        }
        .required { color: #dc3545; }
        .optional { color: #6c757d; }
        .example {
            background: #f8f9fa;
            border-left: 4px solid #007bff;
            padding: 15px;
            margin: 15px 0;
            overflow-x: auto;
        }
        .type-badge {
            display: inline-block;
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: bold;
            color: white;
            margin-right: 5px;
        }
        .type-donhang { background-color: #007bff; }
        .type-san_pham { background-color: #28a745; }
        .type-tai_khoan { background-color: #17a2b8; }
        .type-thanh_toan { background-color: #ffc107; color: #000; }
        .type-khuyen_mai { background-color: #dc3545; }
        .type-van_chuyen { background-color: #6f42c1; }
        .priority-high { border-left: 4px solid #dc3545; }
        .priority-medium { border-left: 4px solid #ffc107; }
        .priority-low { border-left: 4px solid #28a745; }
        .response-example {
            background: #2d3748;
            color: #e2e8f0;
            padding: 20px;
            border-radius: 5px;
            overflow-x: auto;
            font-family: 'Courier New', monospace;
        }
        .notification-example {
            background: #f8f9fa;
            border: 1px solid #dee2e6;
            border-radius: 5px;
            padding: 15px;
            margin: 10px 0;
        }
        .notification-unread {
            background: #e3f2fd;
            border-left: 4px solid #2196f3;
        }
        .notification-read {
            background: #f5f5f5;
            opacity: 0.7;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>📱 API Danh Sách Thông Báo - Mobile <span class="notification-badge">3</span></h1>
        
        <p><strong>Mô tả:</strong> API để lấy danh sách thông báo của người dùng với khả năng lọc theo loại, trạng thái đọc và phân trang.</p>
        
        <h2>🔗 Endpoint</h2>
        <div class="endpoint">
            <span class="method get">GET</span> /includes/notifications_list.php
        </div>
        
        <h2>🔐 Authentication</h2>
        <p>API yêu cầu JWT token trong header Authorization:</p>
        <div class="example">
            Authorization: Bearer YOUR_JWT_TOKEN
        </div>
        
        <h2>📋 Parameters</h2>
        <table class="param-table">
            <thead>
                <tr>
                    <th>Parameter</th>
                    <th>Type</th>
                    <th>Required</th>
                    <th>Description</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td>page</td>
                    <td>integer</td>
                    <td><span class="optional">Optional</span></td>
                    <td>Số trang (mặc định: 1)</td>
                </tr>
                <tr>
                    <td>limit</td>
                    <td>integer</td>
                    <td><span class="optional">Optional</span></td>
                    <td>Số thông báo mỗi trang (mặc định: 20, tối đa: 100)</td>
                </tr>
                <tr>
                    <td>type</td>
                    <td>string</td>
                    <td><span class="optional">Optional</span></td>
                    <td>Lọc theo loại thông báo (donhang, san_pham, tai_khoan, thanh_toan, khuyen_mai, van_chuyen)</td>
                </tr>
                <tr>
                    <td>unread_only</td>
                    <td>boolean</td>
                    <td><span class="optional">Optional</span></td>
                    <td>Chỉ lấy thông báo chưa đọc (true/false)</td>
                </tr>
            </tbody>
        </table>
        
        <h2>📊 Loại Thông Báo</h2>
        <table class="param-table">
            <thead>
                <tr>
                    <th>Type</th>
                    <th>Tên</th>
                    <th>Icon</th>
                    <th>Màu sắc</th>
                    <th>Mô tả</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td>donhang</td>
                    <td><span class="type-badge type-donhang">Đơn hàng</span></td>
                    <td>fa-shopping-cart</td>
                    <td>#007bff</td>
                    <td>Thông báo về trạng thái đơn hàng</td>
                </tr>
                <tr>
                    <td>san_pham</td>
                    <td><span class="type-badge type-san_pham">Sản phẩm</span></td>
                    <td>fa-box</td>
                    <td>#28a745</td>
                    <td>Thông báo về sản phẩm (hết hàng, tồn ít)</td>
                </tr>
                <tr>
                    <td>tai_khoan</td>
                    <td><span class="type-badge type-tai_khoan">Tài khoản</span></td>
                    <td>fa-user</td>
                    <td>#17a2b8</td>
                    <td>Thông báo về tài khoản người dùng</td>
                </tr>
                <tr>
                    <td>thanh_toan</td>
                    <td><span class="type-badge type-thanh_toan">Thanh toán</span></td>
                    <td>fa-credit-card</td>
                    <td>#ffc107</td>
                    <td>Thông báo về thanh toán</td>
                </tr>
                <tr>
                    <td>khuyen_mai</td>
                    <td><span class="type-badge type-khuyen_mai">Khuyến mại</span></td>
                    <td>fa-gift</td>
                    <td>#dc3545</td>
                    <td>Thông báo về khuyến mại, voucher</td>
                </tr>
                <tr>
                    <td>van_chuyen</td>
                    <td><span class="type-badge type-van_chuyen">Vận chuyển</span></td>
                    <td>fa-truck</td>
                    <td>#6f42c1</td>
                    <td>Thông báo về vận chuyển</td>
                </tr>
            </tbody>
        </table>
        
        <h2>💡 Ví Dụ Request</h2>
        <div class="example">
            <strong>Lấy tất cả thông báo:</strong><br>
            GET /includes/notifications_list.php<br><br>
            
            <strong>Lấy thông báo chưa đọc:</strong><br>
            GET /includes/notifications_list.php?unread_only=true<br><br>
            
            <strong>Lấy thông báo đơn hàng:</strong><br>
            GET /includes/notifications_list.php?type=donhang<br><br>
            
            <strong>Lấy thông báo sản phẩm chưa đọc:</strong><br>
            GET /includes/notifications_list.php?type=san_pham&unread_only=true
        </div>
        
        <h2>📤 Response Format</h2>
        <div class="response-example">
{
  "success": true,
  "data": {
    "notifications": [
      {
        "id": 123,
        "title": "Đơn hàng đã được tiếp nhận",
        "content": "Đơn hàng #DH202401001 của bạn đã được tiếp nhận và đang chuẩn bị",
        "type": "donhang",
        "type_name": "Đơn hàng",
        "type_icon": "fa-shopping-cart",
        "type_color": "#007bff",
        "is_read": false,
        "is_admin": false,
        "sp_id": 0,
        "date_post": 1704067200,
        "date_post_formatted": "01/01/2024 00:00",
        "time_ago": "2 giờ trước",
        "action_url": "/order-detail.html?id=DH202401001",
        "priority": "medium"
      },
      {
        "id": 124,
        "title": "Thông báo hết hàng",
        "content": "Thông báo hết hàng: Sản phẩm <b>Áo thun nam cao cấp</b>",
        "type": "san_pham",
        "type_name": "Sản phẩm",
        "type_icon": "fa-box",
        "type_color": "#28a745",
        "is_read": true,
        "is_admin": true,
        "sp_id": 456,
        "date_post": 1704063600,
        "date_post_formatted": "31/12/2023 23:00",
        "time_ago": "3 giờ trước",
        "action_url": "/sanpham.html?id=456",
        "priority": "high"
      }
    ],
    "unread_count": 5,
    "pagination": {
      "current_page": 1,
      "per_page": 20,
      "total_notifications": 25,
      "total_pages": 2,
      "has_next": true,
      "has_prev": false
    },
    "type_map": {
      "donhang": {
        "name": "Đơn hàng",
        "icon": "fa-shopping-cart",
        "color": "#007bff"
      }
    },
    "filters": {
      "type": null,
      "unread_only": false
    }
  }
}
        </div>
        
        <h2>🔔 Ví Dụ Thông Báo</h2>
        
        <div class="notification-example notification-unread priority-high">
            <h4><span class="type-badge type-san_pham">Sản phẩm</span> Thông báo hết hàng</h4>
            <p><strong>Nội dung:</strong> Thông báo hết hàng: Sản phẩm <b>Áo thun nam cao cấp</b></p>
            <p><strong>Thời gian:</strong> 3 giờ trước</p>
            <p><strong>Ưu tiên:</strong> Cao</p>
            <p><strong>Hành động:</strong> <a href="/sanpham.html?id=456">Xem sản phẩm</a></p>
        </div>
        
        <div class="notification-example notification-unread priority-medium">
            <h4><span class="type-badge type-donhang">Đơn hàng</span> Đơn hàng đã được tiếp nhận</h4>
            <p><strong>Nội dung:</strong> Đơn hàng #DH202401001 của bạn đã được tiếp nhận và đang chuẩn bị</p>
            <p><strong>Thời gian:</strong> 2 giờ trước</p>
            <p><strong>Ưu tiên:</strong> Trung bình</p>
            <p><strong>Hành động:</strong> <a href="/order-detail.html?id=DH202401001">Xem đơn hàng</a></p>
        </div>
        
        <div class="notification-example notification-read priority-low">
            <h4><span class="type-badge type-khuyen_mai">Khuyến mại</span> Voucher mới</h4>
            <p><strong>Nội dung:</strong> Bạn có voucher giảm 10% cho đơn hàng tiếp theo</p>
            <p><strong>Thời gian:</strong> 1 ngày trước</p>
            <p><strong>Ưu tiên:</strong> Thấp</p>
            <p><strong>Hành động:</strong> <a href="/khuyen-mai.html">Xem voucher</a></p>
        </div>
        
        <h2>❌ Error Response</h2>
        <div class="response-example">
{
  "success": false,
  "message": "Token không hợp lệ"
}
        </div>
        
        <h2>🔧 Sử Dụng Trong Mobile App</h2>
        <div class="example">
            <strong>Swift (iOS):</strong><br>
            <pre>
func getNotifications(page: Int = 1, unreadOnly: Bool = false) {
    var urlComponents = URLComponents(string: "https://api.example.com/includes/notifications_list.php")!
    urlComponents.queryItems = [
        URLQueryItem(name: "page", value: "\(page)"),
        URLQueryItem(name: "unread_only", value: unreadOnly ? "true" : "false")
    ]
    
    var request = URLRequest(url: urlComponents.url!)
    request.setValue("Bearer \(jwtToken)", forHTTPHeaderField: "Authorization")
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let data = data {
            let notifications = try? JSONDecoder().decode(NotificationResponse.self, from: data)
            DispatchQueue.main.async {
                // Cập nhật UI với danh sách thông báo
                self.updateNotificationsUI(notifications)
            }
        }
    }.resume()
}
            </pre>
            
            <strong>Kotlin (Android):</strong><br>
            <pre>
fun getNotifications(page: Int = 1, unreadOnly: Boolean = false) {
    val url = "https://api.example.com/includes/notifications_list.php?page=$page&unread_only=$unreadOnly"
    val request = Request.Builder()
        .url(url)
        .addHeader("Authorization", "Bearer $jwtToken")
        .build()
    
    client.newCall(request).enqueue(object : Callback {
        override fun onResponse(call: Call, response: Response) {
            val notifications = Gson().fromJson(response.body?.string(), NotificationResponse::class.java)
            runOnUiThread {
                // Cập nhật UI với danh sách thông báo
                updateNotificationsUI(notifications)
            }
        }
    })
}
            </pre>
        </div>
        
        <h2>📝 Ghi Chú</h2>
        <ul>
            <li>API trả về thông báo theo thứ tự mới nhất trước</li>
            <li>Thông báo được phân loại theo type và có màu sắc tương ứng</li>
            <li>Priority được xác định tự động dựa trên nội dung thông báo</li>
            <li>Action URL giúp điều hướng đến trang liên quan</li>
            <li>Time ago hiển thị thời gian tương đối (vừa xong, 2 giờ trước, 1 ngày trước)</li>
            <li>Unread count được trả về để hiển thị badge số lượng thông báo chưa đọc</li>
        </ul>
        
        <h2>🎨 UI Suggestions</h2>
        <div class="example">
            <strong>Notification List:</strong><br>
            - Hiển thị danh sách thông báo với badge chưa đọc<br>
            - Màu sắc khác nhau cho từng loại thông báo<br>
            - Priority indicator (border màu)<br>
            - Time ago format<br>
            - Tap để đánh dấu đã đọc và điều hướng<br><br>
            
            <strong>Badge Counter:</strong><br>
            - Hiển thị số lượng thông báo chưa đọc trên icon thông báo<br>
            - Ẩn badge khi unread_count = 0<br>
            - Animation khi có thông báo mới<br><br>
            
            <strong>Filter Options:</strong><br>
            - Tab lọc theo loại thông báo<br>
            - Toggle "Chỉ hiển thị chưa đọc"<br>
            - Pull to refresh để tải thông báo mới
        </div>
    </div>
</body>
</html>
