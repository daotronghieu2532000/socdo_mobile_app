<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>API Danh Sách Đơn Hàng - Mobile</title>
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
        .get { background-color: #28a745; }
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
        .status-badge {
            display: inline-block;
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: bold;
            color: white;
        }
        .status-pending { background-color: #ffc107; }
        .status-received { background-color: #17a2b8; }
        .status-shipping { background-color: #6f42c1; }
        .status-delivered { background-color: #28a745; }
        .status-cancelled { background-color: #dc3545; }
        .response-example {
            background: #2d3748;
            color: #e2e8f0;
            padding: 20px;
            border-radius: 5px;
            overflow-x: auto;
            font-family: 'Courier New', monospace;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>📱 API Danh Sách Đơn Hàng - Mobile</h1>
        
        <p><strong>Mô tả:</strong> API để lấy danh sách đơn hàng của người dùng với khả năng lọc theo trạng thái, ngày tháng và phân trang.</p>
        
        <h2>🔗 Endpoint</h2>
        <div class="endpoint">
            <span class="method get">GET</span> /includes/orders_list.php
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
                    <td>Số đơn hàng mỗi trang (mặc định: 20, tối đa: 50)</td>
                </tr>
                <tr>
                    <td>status</td>
                    <td>integer</td>
                    <td><span class="optional">Optional</span></td>
                    <td>Lọc theo trạng thái đơn hàng (0-14)</td>
                </tr>
                <tr>
                    <td>start_date</td>
                    <td>string</td>
                    <td><span class="optional">Optional</span></td>
                    <td>Ngày bắt đầu (format: YYYY-MM-DD)</td>
                </tr>
                <tr>
                    <td>end_date</td>
                    <td>string</td>
                    <td><span class="optional">Optional</span></td>
                    <td>Ngày kết thúc (format: YYYY-MM-DD)</td>
                </tr>
            </tbody>
        </table>
        
        <h2>📊 Trạng Thái Đơn Hàng</h2>
        <table class="param-table">
            <thead>
                <tr>
                    <th>Code</th>
                    <th>Trạng Thái</th>
                    <th>Class</th>
                    <th>Icon</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td>0</td>
                    <td><span class="status-badge status-pending">Chờ xử lý</span></td>
                    <td>pending</td>
                    <td>fa-clock-o</td>
                </tr>
                <tr>
                    <td>1</td>
                    <td><span class="status-badge status-received">Đã tiếp nhận đơn</span></td>
                    <td>received</td>
                    <td>fa-check-circle</td>
                </tr>
                <tr>
                    <td>2</td>
                    <td><span class="status-badge status-shipping">Đã giao đơn vị vận chuyển</span></td>
                    <td>shipping</td>
                    <td>fa-truck</td>
                </tr>
                <tr>
                    <td>3</td>
                    <td><span class="status-badge status-pending">Yêu cầu hủy đơn</span></td>
                    <td>cancel-request</td>
                    <td>fa-exclamation-triangle</td>
                </tr>
                <tr>
                    <td>4</td>
                    <td><span class="status-badge status-cancelled">Đã hủy đơn</span></td>
                    <td>cancelled</td>
                    <td>fa-times-circle</td>
                </tr>
                <tr>
                    <td>5</td>
                    <td><span class="status-badge status-delivered">Giao thành công</span></td>
                    <td>delivered</td>
                    <td>fa-check-circle</td>
                </tr>
                <tr>
                    <td>6</td>
                    <td><span class="status-badge status-cancelled">Đã hoàn đơn</span></td>
                    <td>returned</td>
                    <td>fa-undo</td>
                </tr>
                <tr>
                    <td>7</td>
                    <td><span class="status-badge status-cancelled">Lỗi khi giao hàng</span></td>
                    <td>error</td>
                    <td>fa-exclamation-triangle</td>
                </tr>
                <tr>
                    <td>8</td>
                    <td><span class="status-badge status-shipping">Đang vận chuyển</span></td>
                    <td>in-transit</td>
                    <td>fa-truck</td>
                </tr>
                <tr>
                    <td>9</td>
                    <td><span class="status-badge status-pending">Đang chờ lên lịch lại</span></td>
                    <td>reschedule</td>
                    <td>fa-calendar</td>
                </tr>
                <tr>
                    <td>10</td>
                    <td><span class="status-badge status-received">Đã phân công tài xế</span></td>
                    <td>assigned</td>
                    <td>fa-user</td>
                </tr>
                <tr>
                    <td>11</td>
                    <td><span class="status-badge status-received">Đã lấy hàng</span></td>
                    <td>picked</td>
                    <td>fa-hand-grab-o</td>
                </tr>
                <tr>
                    <td>12</td>
                    <td><span class="status-badge status-shipping">Đã đến bưu cục</span></td>
                    <td>arrived</td>
                    <td>fa-building</td>
                </tr>
                <tr>
                    <td>14</td>
                    <td><span class="status-badge status-cancelled">Ngoại lệ trả hàng</span></td>
                    <td>exception</td>
                    <td>fa-warning</td>
                </tr>
            </tbody>
        </table>
        
        <h2>💡 Ví Dụ Request</h2>
        <div class="example">
            <strong>Lấy đơn hàng trang đầu:</strong><br>
            GET /includes/orders_list.php?page=1&limit=10<br><br>
            
            <strong>Lấy đơn hàng đang vận chuyển:</strong><br>
            GET /includes/orders_list.php?status=8<br><br>
            
            <strong>Lấy đơn hàng trong tháng:</strong><br>
            GET /includes/orders_list.php?start_date=2024-01-01&end_date=2024-01-31
        </div>
        
        <h2>📤 Response Format</h2>
        <div class="response-example">
{
  "success": true,
  "data": {
    "orders": [
      {
        "id": 123,
        "ma_don": "DH202401001",
        "status": 5,
        "status_text": "Giao thành công",
        "status_class": "delivered",
        "status_icon": "fa-check-circle",
        "tongtien": 250000,
        "tongtien_formatted": "250.000đ",
        "tamtinh": 230000,
        "phi_ship": 30000,
        "giam": 10000,
        "voucher_tmdt": 0,
        "thanhtoan": "COD",
        "date_post": 1704067200,
        "date_post_formatted": "01/01/2024 00:00",
        "date_update": 1704153600,
        "date_update_formatted": "02/01/2024 00:00",
        "products": [
          {
            "id": 456,
            "name": "Áo thun nam cao cấp",
            "image": "/uploads/products/ao-thun-1.jpg",
            "quantity": 2,
            "price": 150000,
            "total": 300000,
            "size": "L",
            "color": "Đen",
            "shop_name": "Shop Thời Trang"
          }
        ],
        "product_count": 1,
        "shipping_provider": "GHTK",
        "can_cancel": false,
        "can_reorder": true
      }
    ],
    "pagination": {
      "current_page": 1,
      "per_page": 20,
      "total_orders": 25,
      "total_pages": 2,
      "has_next": true,
      "has_prev": false
    },
    "status_map": {
      "0": {
        "text": "Chờ xử lý",
        "class": "pending",
        "icon": "fa-clock-o"
      }
    },
    "filters": {
      "status": null,
      "start_date": null,
      "end_date": null
    }
  }
}
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
let url = URL(string: "https://api.example.com/includes/orders_list.php?page=1&limit=10")!
var request = URLRequest(url: url)
request.setValue("Bearer \(jwtToken)", forHTTPHeaderField: "Authorization")

URLSession.shared.dataTask(with: request) { data, response, error in
    // Xử lý response
}.resume()
            </pre>
            
            <strong>Kotlin (Android):</strong><br>
            <pre>
val url = "https://api.example.com/includes/orders_list.php?page=1&limit=10"
val request = Request.Builder()
    .url(url)
    .addHeader("Authorization", "Bearer $jwtToken")
    .build()

client.newCall(request).enqueue(object : Callback {
    // Xử lý response
})
            </pre>
        </div>
        
        <h2>📝 Ghi Chú</h2>
        <ul>
            <li>API trả về đơn hàng theo thứ tự mới nhất trước</li>
            <li>Trạng thái đơn hàng được cập nhật tự động từ webhook của đơn vị vận chuyển</li>
            <li>Có thể hủy đơn hàng khi status = 0 hoặc 1</li>
            <li>Có thể đặt lại đơn hàng khi status = 5 (giao thành công)</li>
            <li>Thông tin sản phẩm được lưu dưới dạng JSON trong database</li>
        </ul>
    </div>
</body>
</html>
