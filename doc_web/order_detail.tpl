<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>API Chi Tiết Đơn Hàng - Mobile</title>
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
        .timeline-step {
            background: #f8f9fa;
            border: 1px solid #dee2e6;
            border-radius: 5px;
            padding: 15px;
            margin: 10px 0;
        }
        .timeline-completed {
            background: #d4edda;
            border-color: #c3e6cb;
        }
        .timeline-in-progress {
            background: #d1ecf1;
            border-color: #bee5eb;
        }
        .timeline-pending {
            background: #fff3cd;
            border-color: #ffeaa7;
        }
        .response-example {
            background: #2d3748;
            color: #e2e8f0;
            padding: 20px;
            border-radius: 5px;
            overflow-x: auto;
            font-family: 'Courier New', monospace;
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
    </style>
</head>
<body>
    <div class="container">
        <h1>📱 API Chi Tiết Đơn Hàng - Mobile</h1>
        
        <p><strong>Mô tả:</strong> API để lấy thông tin chi tiết của một đơn hàng cụ thể, bao gồm timeline trạng thái, danh sách sản phẩm và thông tin giao hàng.</p>
        
        <h2>🔗 Endpoint</h2>
        <div class="endpoint">
            <span class="method get">GET</span> /includes/order_detail.php
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
                    <td>order_id</td>
                    <td>integer</td>
                    <td><span class="optional">Optional</span></td>
                    <td>ID đơn hàng (sử dụng order_id hoặc ma_don)</td>
                </tr>
                <tr>
                    <td>ma_don</td>
                    <td>string</td>
                    <td><span class="optional">Optional</span></td>
                    <td>Mã đơn hàng (sử dụng order_id hoặc ma_don)</td>
                </tr>
            </tbody>
        </table>
        
        <h2>💡 Ví Dụ Request</h2>
        <div class="example">
            <strong>Lấy chi tiết đơn hàng theo ID:</strong><br>
            GET /includes/order_detail.php?order_id=123<br><br>
            
            <strong>Lấy chi tiết đơn hàng theo mã đơn:</strong><br>
            GET /includes/order_detail.php?ma_don=DH202401001
        </div>
        
        <h2>📤 Response Format</h2>
        <div class="response-example">
{
  "success": true,
  "data": {
    "order": {
      "id": 123,
      "ma_don": "DH202401001",
      "status": 5,
      "status_text": "Giao thành công",
      "status_class": "delivered",
      "status_icon": "fa-check-circle",
      "tongtien": 250000,
      "tongtien_formatted": "250.000đ",
      "tamtinh": 230000,
      "tamtinh_formatted": "230.000đ",
      "phi_ship": 30000,
      "phi_ship_formatted": "30.000đ",
      "giam": 10000,
      "giam_formatted": "10.000đ",
      "voucher_tmdt": 0,
      "voucher_tmdt_formatted": "0đ",
      "thanhtoan": "COD",
      "coupon_code": "GIAM10",
      "ghi_chu": "Giao vào giờ hành chính",
      "shipping_provider": "GHTK",
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
          "price_formatted": "150.000đ",
          "total": 300000,
          "total_formatted": "300.000đ",
          "size": "L",
          "color": "Đen",
          "shop_name": "Shop Thời Trang",
          "weight": 0.5,
          "variant_id": 789
        }
      ],
      "product_count": 1,
      "customer_info": {
        "ho_ten": "Nguyễn Văn A",
        "email": "nguyenvana@email.com",
        "dien_thoai": "0123456789",
        "dia_chi": "123 Đường ABC",
        "tinh": 1,
        "tinh_name": "Hà Nội",
        "huyen": 1,
        "huyen_name": "Quận Ba Đình",
        "xa": 1,
        "xa_name": "Phường Phúc Xá",
        "full_address": "123 Đường ABC, Phường Phúc Xá, Quận Ba Đình, Hà Nội"
      },
      "timeline": [
        {
          "id": 0,
          "title": "Đơn hàng đã được đặt",
          "description": "Đơn hàng của bạn đã được tiếp nhận và đang chờ xác nhận",
          "icon": "fa-check",
          "class": "completed",
          "date": 1704067200
        },
        {
          "id": 1,
          "title": "Đã tiếp nhận đơn",
          "description": "Đơn hàng đã được tiếp nhận và đang chuẩn bị",
          "icon": "fa-check-circle",
          "class": "completed",
          "date": 1704070800
        },
        {
          "id": 2,
          "title": "Đã giao đơn vị vận chuyển",
          "description": "Đơn hàng đã được giao cho đơn vị vận chuyển",
          "icon": "fa-shipping-fast",
          "class": "completed",
          "date": 1704074400
        },
        {
          "id": 3,
          "title": "Đang giao hàng",
          "description": "Đơn hàng đang trên đường giao đến bạn",
          "icon": "fa-truck",
          "class": "completed",
          "date": 1704150000
        },
        {
          "id": 4,
          "title": "Giao thành công",
          "description": "Đơn hàng đã được giao thành công",
          "icon": "fa-check-circle",
          "class": "completed",
          "date": 1704153600
        }
      ],
      "can_cancel": false,
      "can_reorder": true,
      "tracking_info": {
        "shipping_provider": "GHTK",
        "ninja_response": null
      }
    }
  }
}
        </div>
        
        <h2>📊 Timeline Trạng Thái</h2>
        <div class="timeline-step timeline-completed">
            <h4>✅ Đơn hàng đã được đặt</h4>
            <p>Đơn hàng của bạn đã được tiếp nhận và đang chờ xác nhận</p>
            <small>Icon: fa-check | Class: completed</small>
        </div>
        
        <div class="timeline-step timeline-completed">
            <h4>✅ Đã tiếp nhận đơn</h4>
            <p>Đơn hàng đã được tiếp nhận và đang chuẩn bị</p>
            <small>Icon: fa-check-circle | Class: completed</small>
        </div>
        
        <div class="timeline-step timeline-completed">
            <h4>✅ Đã giao đơn vị vận chuyển</h4>
            <p>Đơn hàng đã được giao cho đơn vị vận chuyển</p>
            <small>Icon: fa-shipping-fast | Class: completed</small>
        </div>
        
        <div class="timeline-step timeline-in-progress">
            <h4>🚚 Đang giao hàng</h4>
            <p>Đơn hàng đang trên đường giao đến bạn</p>
            <small>Icon: fa-truck | Class: in-progress</small>
        </div>
        
        <div class="timeline-step timeline-pending">
            <h4>⏳ Giao thành công</h4>
            <p>Đơn hàng đã được giao thành công</p>
            <small>Icon: fa-check-circle | Class: pending</small>
        </div>
        
        <h2>❌ Error Response</h2>
        <div class="response-example">
{
  "success": false,
  "message": "Không tìm thấy đơn hàng"
}
        </div>
        
        <h2>🔧 Sử Dụng Trong Mobile App</h2>
        <div class="example">
            <strong>Swift (iOS):</strong><br>
            <pre>
func getOrderDetail(orderId: Int) {
    let url = URL(string: "https://api.example.com/includes/order_detail.php?order_id=\(orderId)")!
    var request = URLRequest(url: url)
    request.setValue("Bearer \(jwtToken)", forHTTPHeaderField: "Authorization")
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let data = data {
            let orderDetail = try? JSONDecoder().decode(OrderDetailResponse.self, from: data)
            DispatchQueue.main.async {
                // Cập nhật UI với chi tiết đơn hàng
                self.updateOrderDetailUI(orderDetail)
            }
        }
    }.resume()
}
            </pre>
            
            <strong>Kotlin (Android):</strong><br>
            <pre>
fun getOrderDetail(orderId: Int) {
    val url = "https://api.example.com/includes/order_detail.php?order_id=$orderId"
    val request = Request.Builder()
        .url(url)
        .addHeader("Authorization", "Bearer $jwtToken")
        .build()
    
    client.newCall(request).enqueue(object : Callback {
        override fun onResponse(call: Call, response: Response) {
            val orderDetail = Gson().fromJson(response.body?.string(), OrderDetailResponse::class.java)
            runOnUiThread {
                // Cập nhật UI với chi tiết đơn hàng
                updateOrderDetailUI(orderDetail)
            }
        }
    })
}
            </pre>
        </div>
        
        <h2>📝 Ghi Chú</h2>
        <ul>
            <li>API trả về đầy đủ thông tin đơn hàng bao gồm timeline trạng thái</li>
            <li>Timeline hiển thị tiến trình giao hàng theo thời gian thực</li>
            <li>Thông tin khách hàng bao gồm địa chỉ giao hàng đầy đủ</li>
            <li>Có thể hủy đơn hàng khi status = 0 hoặc 1</li>
            <li>Có thể đặt lại đơn hàng khi status = 5 (giao thành công)</li>
            <li>Tracking info chứa thông tin từ đơn vị vận chuyển</li>
        </ul>
        
        <h2>🎨 UI Suggestions</h2>
        <div class="example">
            <strong>Timeline Component:</strong><br>
            - Hiển thị timeline dọc với các bước trạng thái<br>
            - Màu sắc khác nhau cho completed/in-progress/pending<br>
            - Icon phù hợp cho từng bước<br>
            - Hiển thị thời gian cập nhật<br><br>
            
            <strong>Product List:</strong><br>
            - Hiển thị danh sách sản phẩm với hình ảnh<br>
            - Thông tin size, color, quantity<br>
            - Giá và thành tiền rõ ràng<br><br>
            
            <strong>Customer Info:</strong><br>
            - Thông tin khách hàng và địa chỉ giao hàng<br>
            - Hiển thị địa chỉ đầy đủ với tỉnh/huyện/xã<br>
            - Thông tin liên hệ
        </div>
    </div>
</body>
</html>
