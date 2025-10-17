<?php
header("Access-Control-Allow-Methods: GET, POST, PUT");
require_once './vendor/autoload.php';
use \Firebase\JWT\JWT;
use \Firebase\JWT\Key;

// Cấu hình thông tin JWT
$key = "Socdo123@2025"; // Key bí mật dùng để ký JWT
$issuer = "api.socdo.vn"; // Tên ứng dụng phát hành token

// Lấy token từ header Authorization
$headers = apache_request_headers();
$authHeader = isset($headers['Authorization']) ? $headers['Authorization'] : '';
if (!$authHeader || !preg_match('/Bearer\s(\S+)/', $authHeader, $matches)) {
    http_response_code(401);
    echo json_encode(array("message" => "Không tìm thấy token"));
    exit;
}

$jwt = $matches[1]; // Lấy token từ Bearer

try {
    // Giải mã JWT
    $decoded = JWT::decode($jwt, new Key($key, 'HS256'));
    
    // Kiểm tra issuer
    if ($decoded->iss !== $issuer) {
        http_response_code(401);
        echo json_encode(array("message" => "Issuer không hợp lệ"));
        exit;
    }
    
    $method = $_SERVER['REQUEST_METHOD'];
    
    if ($method === 'GET') {
        // Lấy danh sách đơn hàng hoặc chi tiết đơn hàng
        $order_id = isset($_GET['order_id']) ? intval($_GET['order_id']) : 0;
        
        if ($order_id > 0) {
            // Lấy chi tiết đơn hàng
            $query = "SELECT * FROM donhang WHERE id = $order_id LIMIT 1";
            $result = mysqli_query($conn, $query);
            
            if (!$result || mysqli_num_rows($result) == 0) {
                http_response_code(404);
                echo json_encode([
                    "success" => false,
                    "message" => "Không tìm thấy đơn hàng"
                ]);
                exit;
            }
            
            $order = mysqli_fetch_assoc($result);
            
            // Xử lý thông tin sản phẩm
            $products = array();
            if (!empty($order['sanpham'])) {
                $sanpham_data = json_decode($order['sanpham'], true);
                if (is_array($sanpham_data)) {
                    foreach ($sanpham_data as $item) {
                        if (isset($item['id'])) {
                            $product_id = intval($item['id']);
                            $product_query = "SELECT id, tieu_de, minh_hoa, gia_moi, link FROM sanpham WHERE id = $product_id LIMIT 1";
                            $product_result = mysqli_query($conn, $product_query);
                            if ($product_result && mysqli_num_rows($product_result) > 0) {
                                $product = mysqli_fetch_assoc($product_result);
                                $product['quantity'] = isset($item['qty']) ? intval($item['qty']) : 1;
                                $product['price'] = isset($item['price']) ? intval($item['price']) : $product['gia_moi'];
                                $product['total'] = $product['quantity'] * $product['price'];
                                $product['price_formatted'] = number_format($product['price']);
                                $product['total_formatted'] = number_format($product['total']);
                                
                                if (!empty($product['minh_hoa']) && file_exists($product['minh_hoa'])) {
                                    $product['image_url'] = 'https://socdo.vn/' . $product['minh_hoa'];
                                } else {
                                    $product['image_url'] = 'https://socdo.vn/images/no-images.jpg';
                                }
                                
                                $products[] = $product;
                            }
                        }
                    }
                }
            }
            
            // Xử lý thông tin địa chỉ
            $address_info = array();
            if ($order['tinh'] > 0) {
                $tinh_query = "SELECT tieu_de FROM tinh_moi WHERE id = " . intval($order['tinh']) . " LIMIT 1";
                $tinh_result = mysqli_query($conn, $tinh_query);
                if ($tinh_result && mysqli_num_rows($tinh_result) > 0) {
                    $address_info['tinh'] = mysqli_fetch_assoc($tinh_result)['tieu_de'];
                }
            }
            
            if ($order['huyen'] > 0) {
                $huyen_query = "SELECT tieu_de FROM huyen_moi WHERE id = " . intval($order['huyen']) . " LIMIT 1";
                $huyen_result = mysqli_query($conn, $huyen_query);
                if ($huyen_result && mysqli_num_rows($huyen_result) > 0) {
                    $address_info['huyen'] = mysqli_fetch_assoc($huyen_result)['tieu_de'];
                }
            }
            
            // Format các trường
            $order['tamtinh_formatted'] = number_format($order['tamtinh']);
            $order['giam_formatted'] = number_format($order['giam']);
            $order['phi_ship_formatted'] = number_format($order['phi_ship']);
            $order['tongtien_formatted'] = number_format($order['tongtien']);
            $order['date_post_formatted'] = date('d/m/Y H:i:s', $order['date_post']);
            $order['date_update_formatted'] = date('d/m/Y H:i:s', $order['date_update']);
            
            // Trạng thái đơn hàng
            $status_text = array(
                0 => 'Chờ xác nhận',
                1 => 'Đã xác nhận',
                2 => 'Đang giao hàng',
                3 => 'Đã giao hàng',
                4 => 'Đã hủy'
            );
            
            $order['status_text'] = isset($status_text[$order['status']]) ? $status_text[$order['status']] : 'Không xác định';
            $order['products'] = $products;
            $order['address_info'] = $address_info;
            $order['full_address'] = trim($order['dia_chi'] . ', ' . 
                                        (isset($address_info['huyen']) ? $address_info['huyen'] . ', ' : '') . 
                                        (isset($address_info['tinh']) ? $address_info['tinh'] : ''));
            
            $response = [
                "success" => true,
                "message" => "Lấy chi tiết đơn hàng thành công",
                "data" => $order
            ];
            
        } else {
            // Lấy danh sách đơn hàng
            $user_id = isset($_GET['user_id']) ? intval($_GET['user_id']) : 0;
            $status = isset($_GET['status']) ? intval($_GET['status']) : -1;
            $page = isset($_GET['page']) ? intval($_GET['page']) : 1;
            $limit = isset($_GET['limit']) ? intval($_GET['limit']) : 20;
            $date_from = isset($_GET['date_from']) ? addslashes($_GET['date_from']) : '';
            $date_to = isset($_GET['date_to']) ? addslashes($_GET['date_to']) : '';
            $search = isset($_GET['search']) ? addslashes(strip_tags($_GET['search'])) : '';
            
            // Validate parameters
            $get_all = isset($_GET['all']) && $_GET['all'] == '1';
            
            if ($limit > 500) $limit = 500;
            if ($limit < 1) $limit = 20;
            if ($page < 1) $page = 1;
            
            // Override limit nếu get_all = true
            if ($get_all) {
                $limit = 999999;
                $page = 1;
            }
            
            $start = ($page - 1) * $limit;
            
            // Xây dựng điều kiện WHERE
            $where_conditions = array();
            
            if ($user_id > 0) {
                $where_conditions[] = "user_id = $user_id";
            }
            
            if ($status >= 0) {
                $where_conditions[] = "status = $status";
            }
            
            if (!empty($search)) {
                $where_conditions[] = "(ma_don LIKE '%$search%' OR ho_ten LIKE '%$search%' OR dien_thoai LIKE '%$search%' OR email LIKE '%$search%')";
            }
            
            if (!empty($date_from)) {
                $date_from_timestamp = strtotime($date_from);
                if ($date_from_timestamp) {
                    $where_conditions[] = "date_post >= $date_from_timestamp";
                }
            }
            
            if (!empty($date_to)) {
                $date_to_timestamp = strtotime($date_to . ' 23:59:59');
                if ($date_to_timestamp) {
                    $where_conditions[] = "date_post <= $date_to_timestamp";
                }
            }
            
            $where_clause = !empty($where_conditions) ? 'WHERE ' . implode(' AND ', $where_conditions) : '';
            
            // Đếm tổng số đơn hàng
            $count_query = "SELECT COUNT(*) as total FROM donhang $where_clause";
            $count_result = mysqli_query($conn, $count_query);
            $total_orders = mysqli_fetch_assoc($count_result)['total'];
            
            // Lấy danh sách đơn hàng
            $query = "SELECT id, ma_don, user_id, ho_ten, email, dien_thoai, dia_chi, tinh, huyen, 
                     tamtinh, giam, phi_ship, tongtien, status, thanhtoan, date_post, date_update, utm_source
                     FROM donhang $where_clause ORDER BY date_post DESC LIMIT $start, $limit";
            $result = mysqli_query($conn, $query);
            
            if (!$result) {
                http_response_code(500);
                echo json_encode([
                    "success" => false,
                    "message" => "Lỗi truy vấn database: " . mysqli_error($conn)
                ]);
                exit;
            }
            
            $orders = array();
            $status_text = array(
                0 => 'Chờ xác nhận',
                1 => 'Đã xác nhận', 
                2 => 'Đang giao hàng',
                3 => 'Đã giao hàng',
                4 => 'Đã hủy'
            );
            
            while ($row = mysqli_fetch_assoc($result)) {
                // Format các trường
                $row['tamtinh_formatted'] = number_format($row['tamtinh']);
                $row['giam_formatted'] = number_format($row['giam']);
                $row['phi_ship_formatted'] = number_format($row['phi_ship']);
                $row['tongtien_formatted'] = number_format($row['tongtien']);
                $row['date_post_formatted'] = date('d/m/Y H:i:s', $row['date_post']);
                $row['date_update_formatted'] = date('d/m/Y H:i:s', $row['date_update']);
                $row['status_text'] = isset($status_text[$row['status']]) ? $status_text[$row['status']] : 'Không xác định';
                
                $orders[] = $row;
            }
            
            // Tính toán thông tin phân trang
            $total_pages = ceil($total_orders / $limit);
            
            $response = [
                "success" => true,
                "message" => "Lấy danh sách đơn hàng thành công",
                "data" => [
                    "orders" => $orders,
                    "pagination" => [
                        "current_page" => $page,
                        "total_pages" => $total_pages,
                        "total_orders" => $total_orders,
                        "limit" => $limit,
                        "has_next" => $page < $total_pages,
                        "has_prev" => $page > 1
                    ],
                    "filters" => [
                        "user_id" => $user_id,
                        "status" => $status,
                        "search" => $search,
                        "date_from" => $date_from,
                        "date_to" => $date_to
                    ]
                ]
            ];
        }
        
        http_response_code(200);
        echo json_encode($response, JSON_UNESCAPED_UNICODE);
        
    } elseif ($method === 'POST') {
        // Tạo đơn hàng mới
        $data = json_decode(file_get_contents("php://input"), true);
        
        // Validate required fields
        $required_fields = ['user_id', 'ho_ten', 'dien_thoai', 'dia_chi', 'sanpham', 'tamtinh', 'tongtien'];
        foreach ($required_fields as $field) {
            if (!isset($data[$field]) || (is_string($data[$field]) && trim($data[$field]) === '')) {
                http_response_code(400);
                echo json_encode([
                    "success" => false,
                    "message" => "Thiếu trường bắt buộc: $field"
                ]);
                exit;
            }
        }
        
        // Generate mã đơn hàng
        $class_index = $tlca_do->load('class_index');
        $ma_don = $class_index->creat_random($conn, 'donhang');
        
        $user_id = intval($data['user_id']);
        $ho_ten = addslashes(strip_tags($data['ho_ten']));
        $email = isset($data['email']) ? addslashes(strip_tags($data['email'])) : '';
        $dien_thoai = addslashes(strip_tags($data['dien_thoai']));
        $dia_chi = addslashes(strip_tags($data['dia_chi']));
        $tinh = isset($data['tinh']) ? intval($data['tinh']) : 0;
        $huyen = isset($data['huyen']) ? intval($data['huyen']) : 0;
        $xa = isset($data['xa']) ? intval($data['xa']) : 0;
        $dropship = isset($data['dropship']) ? intval($data['dropship']) : 0;
        $sanpham = addslashes(json_encode($data['sanpham']));
        $tamtinh = intval($data['tamtinh']);
        $coupon = isset($data['coupon']) ? addslashes($data['coupon']) : '';
        $giam = isset($data['giam']) ? intval($data['giam']) : 0;
        $phi_ship = isset($data['phi_ship']) ? intval($data['phi_ship']) : 0;
        $tongtien = intval($data['tongtien']);
        $kho = isset($data['kho']) ? addslashes($data['kho']) : '';
        $status = isset($data['status']) ? intval($data['status']) : 0;
        $thanhtoan = isset($data['thanhtoan']) ? addslashes($data['thanhtoan']) : 'cod';
        $ghi_chu = isset($data['ghi_chu']) ? addslashes(strip_tags($data['ghi_chu'])) : '';
        $utm_source = isset($data['utm_source']) ? addslashes($data['utm_source']) : '';
        $utm_campaign = isset($data['utm_campaign']) ? addslashes($data['utm_campaign']) : '';
        $shop_id = isset($data['shop_id']) ? addslashes($data['shop_id']) : '';
        
        $date_post = time();
        $date_update = $date_post;
        
        // Insert vào database
        $insert_query = "INSERT INTO donhang (ma_don, user_id, ho_ten, email, dien_thoai, dia_chi, tinh, huyen, xa, dropship, sanpham, tamtinh, coupon, giam, phi_ship, tongtien, kho, status, thanhtoan, ghi_chu, utm_source, utm_campaign, date_update, date_post, shop_id) 
                        VALUES ('$ma_don', '$user_id', '$ho_ten', '$email', '$dien_thoai', '$dia_chi', '$tinh', '$huyen', '$xa', '$dropship', '$sanpham', '$tamtinh', '$coupon', '$giam', '$phi_ship', '$tongtien', '$kho', '$status', '$thanhtoan', '$ghi_chu', '$utm_source', '$utm_campaign', '$date_update', '$date_post', '$shop_id')";
        
        $result = mysqli_query($conn, $insert_query);
        
        if ($result) {
            $order_id = mysqli_insert_id($conn);
            
            http_response_code(201);
            echo json_encode([
                "success" => true,
                "message" => "Tạo đơn hàng thành công",
                "data" => [
                    "order_id" => $order_id,
                    "ma_don" => $ma_don,
                    "ho_ten" => $data['ho_ten'],
                    "tongtien" => $tongtien,
                    "tongtien_formatted" => number_format($tongtien),
                    "status" => $status,
                    "date_post" => date('d/m/Y H:i:s', $date_post)
                ]
            ]);
        } else {
            http_response_code(500);
            echo json_encode([
                "success" => false,
                "message" => "Lỗi tạo đơn hàng: " . mysqli_error($conn)
            ]);
        }
        
    } elseif ($method === 'PUT') {
        // Cập nhật trạng thái đơn hàng
        $data = json_decode(file_get_contents("php://input"), true);
        
        if (!isset($data['order_id']) || !isset($data['status'])) {
            http_response_code(400);
            echo json_encode([
                "success" => false,
                "message" => "Thiếu order_id hoặc status"
            ]);
            exit;
        }
        
        $order_id = intval($data['order_id']);
        $status = intval($data['status']);
        $date_update = time();
        
        // Validate status
        if (!in_array($status, [0, 1, 2, 3, 4])) {
            http_response_code(400);
            echo json_encode([
                "success" => false,
                "message" => "Trạng thái không hợp lệ (0-4)"
            ]);
            exit;
        }
        
        // Update database
        $update_query = "UPDATE donhang SET status = $status, date_update = $date_update WHERE id = $order_id";
        $result = mysqli_query($conn, $update_query);
        
        if ($result) {
            if (mysqli_affected_rows($conn) > 0) {
                $status_text = array(
                    0 => 'Chờ xác nhận',
                    1 => 'Đã xác nhận',
                    2 => 'Đang giao hàng', 
                    3 => 'Đã giao hàng',
                    4 => 'Đã hủy'
                );
                
                http_response_code(200);
                echo json_encode([
                    "success" => true,
                    "message" => "Cập nhật trạng thái đơn hàng thành công",
                    "data" => [
                        "order_id" => $order_id,
                        "status" => $status,
                        "status_text" => $status_text[$status],
                        "date_update" => date('d/m/Y H:i:s', $date_update)
                    ]
                ]);
            } else {
                http_response_code(404);
                echo json_encode([
                    "success" => false,
                    "message" => "Không tìm thấy đơn hàng"
                ]);
            }
        } else {
            http_response_code(500);
            echo json_encode([
                "success" => false,
                "message" => "Lỗi cập nhật đơn hàng: " . mysqli_error($conn)
            ]);
        }
        
    } else {
        http_response_code(405);
        echo json_encode([
            "success" => false,
            "message" => "Phương thức không được hỗ trợ"
        ]);
    }
    
} catch (Exception $e) {
    http_response_code(401);
    echo json_encode(array(
        "success" => false,
        "message" => "Token không hợp lệ",
        "error" => $e->getMessage()
    ));
}
?>
