<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>API Đánh Dấu Thông Báo Đã Đọc - Mobile</title>
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
        .post { background-color: #007bff; }
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
        .response-example {
            background: #2d3748;
            color: #e2e8f0;
            padding: 20px;
            border-radius: 5px;
            overflow-x: auto;
            font-family: 'Courier New', monospace;
        }
        .success-badge {
            background: #28a745;
            color: white;
            padding: 5px 10px;
            border-radius: 15px;
            font-size: 12px;
            font-weight: bold;
        }
        .warning-badge {
            background: #ffc107;
            color: #000;
            padding: 5px 10px;
            border-radius: 15px;
            font-size: 12px;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>📱 API Đánh Dấu Thông Báo Đã Đọc - Mobile</h1>
        
        <p><strong>Mô tả:</strong> API để đánh dấu thông báo đã đọc (một thông báo cụ thể hoặc tất cả thông báo).</p>
        
        <h2>🔗 Endpoint</h2>
        <div class="endpoint">
            <span class="method post">POST</span> /includes/notification_mark_read.php
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
                    <td>notification_id</td>
                    <td>integer</td>
                    <td><span class="optional">Optional</span></td>
                    <td>ID thông báo cụ thể cần đánh dấu đã đọc (sử dụng notification_id hoặc mark_all)</td>
                </tr>
                <tr>
                    <td>mark_all</td>
                    <td>boolean</td>
                    <td><span class="optional">Optional</span></td>
                    <td>Đánh dấu tất cả thông báo đã đọc (true/false)</td>
                </tr>
                <tr>
                    <td>type</td>
                    <td>string</td>
                    <td><span class="optional">Optional</span></td>
                    <td>Chỉ đánh dấu đã đọc cho loại thông báo cụ thể (khi mark_all=true)</td>
                </tr>
            </tbody>
        </table>
        
        <h2>💡 Ví Dụ Request</h2>
        
        <h3>Đánh dấu một thông báo đã đọc</h3>
        <div class="example">
            <strong>Method:</strong> POST<br>
            <strong>Content-Type:</strong> application/x-www-form-urlencoded<br><br>
            <strong>Body:</strong><br>
            notification_id=123
        </div>
        
        <h3>Đánh dấu tất cả thông báo đã đọc</h3>
        <div class="example">
            <strong>Method:</strong> POST<br>
            <strong>Content-Type:</strong> application/x-www-form-urlencoded<br><br>
            <strong>Body:</strong><br>
            mark_all=true
        </div>
        
        <h3>Đánh dấu tất cả thông báo đơn hàng đã đọc</h3>
        <div class="example">
            <strong>Method:</strong> POST<br>
            <strong>Content-Type:</strong> application/x-www-form-urlencoded<br><br>
            <strong>Body:</strong><br>
            mark_all=true&type=donhang
        </div>
        
        <h2>📤 Response Format</h2>
        
        <h3>Success Response</h3>
        <div class="response-example">
{
  "success": true,
  "message": "Đã đánh dấu thông báo là đã đọc",
  "data": {
    "unread_count": 3,
    "affected_rows": 1
  }
}
        </div>
        
        <h3>Success Response (Mark All)</h3>
        <div class="response-example">
{
  "success": true,
  "message": "Đã đánh dấu tất cả thông báo là đã đọc",
  "data": {
    "unread_count": 0,
    "affected_rows": 15
  }
}
        </div>
        
        <h3>Error Response</h3>
        <div class="response-example">
{
  "success": false,
  "message": "Không thể cập nhật trạng thái thông báo"
}
        </div>
        
        <h2>🔧 Sử Dụng Trong Mobile App</h2>
        
        <h3>Swift (iOS)</h3>
        <div class="example">
            <pre>
// Đánh dấu một thông báo đã đọc
func markNotificationAsRead(notificationId: Int) {
    let url = URL(string: "https://api.example.com/includes/notification_mark_read.php")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("Bearer \(jwtToken)", forHTTPHeaderField: "Authorization")
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    
    let body = "notification_id=\(notificationId)"
    request.httpBody = body.data(using: .utf8)
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let data = data {
            let result = try? JSONDecoder().decode(MarkReadResponse.self, from: data)
            DispatchQueue.main.async {
                // Cập nhật UI với số lượng thông báo chưa đọc mới
                self.updateUnreadBadge(result?.data.unread_count ?? 0)
            }
        }
    }.resume()
}

// Đánh dấu tất cả thông báo đã đọc
func markAllNotificationsAsRead() {
    let url = URL(string: "https://api.example.com/includes/notification_mark_read.php")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("Bearer \(jwtToken)", forHTTPHeaderField: "Authorization")
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    
    let body = "mark_all=true"
    request.httpBody = body.data(using: .utf8)
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        // Xử lý response
    }.resume()
}
            </pre>
        </div>
        
        <h3>Kotlin (Android)</h3>
        <div class="example">
            <pre>
// Đánh dấu một thông báo đã đọc
fun markNotificationAsRead(notificationId: Int) {
    val url = "https://api.example.com/includes/notification_mark_read.php"
    val requestBody = FormBody.Builder()
        .add("notification_id", notificationId.toString())
        .build()
    
    val request = Request.Builder()
        .url(url)
        .post(requestBody)
        .addHeader("Authorization", "Bearer $jwtToken")
        .build()
    
    client.newCall(request).enqueue(object : Callback {
        override fun onResponse(call: Call, response: Response) {
            val result = Gson().fromJson(response.body?.string(), MarkReadResponse::class.java)
            runOnUiThread {
                // Cập nhật UI với số lượng thông báo chưa đọc mới
                updateUnreadBadge(result.data.unread_count)
            }
        }
    })
}

// Đánh dấu tất cả thông báo đã đọc
fun markAllNotificationsAsRead() {
    val url = "https://api.example.com/includes/notification_mark_read.php"
    val requestBody = FormBody.Builder()
        .add("mark_all", "true")
        .build()
    
    val request = Request.Builder()
        .url(url)
        .post(requestBody)
        .addHeader("Authorization", "Bearer $jwtToken")
        .build()
    
    client.newCall(request).enqueue(object : Callback {
        // Xử lý response
    })
}
            </pre>
        </div>
        
        <h2>📱 UI Integration Examples</h2>
        
        <h3>Notification List Item</h3>
        <div class="example">
            <pre>
// Khi user tap vào thông báo
func didTapNotification(notification: Notification) {
    // Đánh dấu đã đọc
    markNotificationAsRead(notificationId: notification.id)
    
    // Điều hướng đến action URL
    if let actionUrl = notification.action_url {
        navigateToUrl(actionUrl)
    }
}
            </pre>
        </div>
        
        <h3>Mark All Button</h3>
        <div class="example">
            <pre>
// Button "Đánh dấu tất cả đã đọc"
@IBAction func markAllAsReadButtonTapped(_ sender: UIButton) {
    markAllNotificationsAsRead()
    
    // Cập nhật UI ngay lập tức
    updateNotificationListUI()
    updateUnreadBadge(0)
}
            </pre>
        </div>
        
        <h2>📝 Ghi Chú</h2>
        <ul>
            <li>API hỗ trợ đánh dấu một thông báo cụ thể hoặc tất cả thông báo</li>
            <li>Có thể lọc theo loại thông báo khi đánh dấu tất cả</li>
            <li>Response trả về số lượng thông báo chưa đọc còn lại</li>
            <li>Affected rows cho biết số lượng thông báo đã được cập nhật</li>
            <li>Nên cập nhật UI ngay lập tức sau khi gọi API thành công</li>
        </ul>
        
        <h2>🎨 UI Suggestions</h2>
        <div class="example">
            <strong>Notification Badge:</strong><br>
            - Hiển thị số lượng thông báo chưa đọc<br>
            - Ẩn badge khi unread_count = 0<br>
            - Animation khi số lượng thay đổi<br><br>
            
            <strong>Notification List:</strong><br>
            - Visual indicator cho thông báo chưa đọc<br>
            - Tap để đánh dấu đã đọc và điều hướng<br>
            - Swipe action để đánh dấu đã đọc<br><br>
            
            <strong>Mark All Button:</strong><br>
            - Hiển thị khi có thông báo chưa đọc<br>
            - Confirmation dialog trước khi đánh dấu tất cả<br>
            - Loading indicator trong quá trình xử lý
        </div>
        
        <h2>⚠️ Lưu Ý</h2>
        <div class="example">
            <div class="warning-badge">⚠️ Lưu ý</div>
            <ul>
                <li>Phải cung cấp ít nhất một trong hai tham số: notification_id hoặc mark_all=true</li>
                <li>Nếu cung cấp cả hai, API sẽ ưu tiên notification_id</li>
                <li>Type parameter chỉ có hiệu lực khi mark_all=true</li>
                <li>API chỉ cập nhật thông báo của user hiện tại (từ JWT token)</li>
                <li>Nên xử lý error case khi network hoặc server có vấn đề</li>
            </ul>
        </div>
    </div>
</body>
</html>
