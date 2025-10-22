<?php
header("Access-Control-Allow-Methods: GET, POST");
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
        // Lấy danh sách flash sale
        $status = isset($_GET['status']) ? addslashes($_GET['status']) : 'all';
        $page = isset($_GET['page']) ? intval($_GET['page']) : 1;
        $limit = isset($_GET['limit']) ? intval($_GET['limit']) : 500;
        $shop = isset($_GET['shop']) ? intval($_GET['shop']) : 0;
        
        // Validate parameters
        $get_all = isset($_GET['all']) && $_GET['all'] == '1';
        
        
        if ($limit > 500) $limit = 500;
        if ($limit < 1) $limit = 100;
        if ($page < 1) $page = 1;
        
        // Override limit nếu get_all = true
        if ($get_all) {
            $limit = 999999;
            $page = 1;
        }
        
        $start = ($page - 1) * $limit;
        $current_time = time();
        
        // Xây dựng điều kiện WHERE
        $where_conditions = array();
        
        if ($shop > 0) {
            $where_conditions[] = "shop = $shop";
        }
        
        switch ($status) {
            case 'active':
                $where_conditions[] = "date_start <= $current_time AND date_end >= $current_time";
                break;
            case 'upcoming':
                $where_conditions[] = "date_start > $current_time";
                break;
            case 'expired':
                $where_conditions[] = "date_end < $current_time";
                break;
            default:
                // Lấy tất cả
                break;
        }
        
        $where_clause = !empty($where_conditions) ? 'WHERE ' . implode(' AND ', $where_conditions) : '';
        
        // Đếm tổng số deal
        $count_query = "SELECT COUNT(*) as total FROM deal $where_clause";
        $count_result = mysqli_query($conn, $count_query);
        $total_deals = mysqli_fetch_assoc($count_result)['total'];
        
        // Lấy danh sách deal
        $query = "SELECT * FROM deal $where_clause ORDER BY date_start DESC LIMIT $start, $limit";
        $result = mysqli_query($conn, $query);
        
        if (!$result) {
            http_response_code(500);
            echo json_encode([
                "success" => false,
                "message" => "Lỗi truy vấn database: " . mysqli_error($conn)
            ]);
            exit;
        }
        
        $deals = array();
        while ($row = mysqli_fetch_assoc($result)) {
            // Helper: build image url without file_exists (minh_hoa lưu đường dẫn tương đối uploads/...)
            $build_image_url = function($rel_path) {
                if (!empty($rel_path)) {
                    $clean = ltrim($rel_path, '/');
                    return 'https://socdo.vn/' . $clean;
                }
                return 'https://socdo.vn/images/no-images.jpg';
            };

            // Xử lý thông tin sản phẩm chính
            $main_products = array();
            if (!empty($row['main_product'])) {
                $main_product_ids = explode(',', $row['main_product']);
                foreach ($main_product_ids as $product_id) {
                    $product_id = intval(trim($product_id));
                    if ($product_id > 0) {
                        $product_query = "SELECT id, tieu_de, minh_hoa, gia_cu, gia_moi, link FROM sanpham WHERE id = $product_id LIMIT 1";
                        $product_result = mysqli_query($conn, $product_query);
                        if ($product_result && mysqli_num_rows($product_result) > 0) {
                            $product = mysqli_fetch_assoc($product_result);
                            $product['gia_cu_formatted'] = number_format($product['gia_cu']);
                            $product['gia_moi_formatted'] = number_format($product['gia_moi']);
                            $product['discount_percent'] = $product['gia_cu'] > 0 ? round((($product['gia_cu'] - $product['gia_moi']) / $product['gia_cu']) * 100) : 0;
                            $product['image_url'] = $build_image_url($product['minh_hoa']);
                            $product['product_url'] = 'https://socdo.vn/san-pham/' . $product['id'] . '/' . $product['link'] . '.html';
                            $main_products[] = $product;
                        }
                    }
                }
            }

            // Xử lý thông tin sản phẩm phụ
            $sub_products = array();
            if (!empty($row['sub_product'])) {
                $sub_json = json_decode($row['sub_product'], true);
                if (json_last_error() === JSON_ERROR_NONE && is_array($sub_json)) {
                    // Keys là product_id
                    foreach ($sub_json as $pid => $_) {
                        $product_id = intval($pid);
                        if ($product_id > 0) {
                            $product_query = "SELECT id, tieu_de, minh_hoa, gia_cu, gia_moi, link FROM sanpham WHERE id = $product_id LIMIT 1";
                            $product_result = mysqli_query($conn, $product_query);
                            if ($product_result && mysqli_num_rows($product_result) > 0) {
                                $product = mysqli_fetch_assoc($product_result);
                                $product['gia_cu_formatted'] = number_format($product['gia_cu']);
                                $product['gia_moi_formatted'] = number_format($product['gia_moi']);
                                $product['discount_percent'] = $product['gia_cu'] > 0 ? round((($product['gia_cu'] - $product['gia_moi']) / $product['gia_cu']) * 100) : 0;
                                $product['image_url'] = $build_image_url($product['minh_hoa']);
                                $product['product_url'] = 'https://socdo.vn/san-pham/' . $product['id'] . '/' . $product['link'] . '.html';
                                $sub_products[] = $product;
                            }
                        }
                    }
                } else {
                    // Fallback: nếu không phải JSON thì xử lý như CSV id (giữ tương thích)
                    $sub_product_ids = explode(',', $row['sub_product']);
                    foreach ($sub_product_ids as $product_id) {
                        $product_id = intval(trim($product_id));
                        if ($product_id > 0) {
                            $product_query = "SELECT id, tieu_de, minh_hoa, gia_cu, gia_moi, link FROM sanpham WHERE id = $product_id LIMIT 1";
                            $product_result = mysqli_query($conn, $product_query);
                            if ($product_result && mysqli_num_rows($product_result) > 0) {
                                $product = mysqli_fetch_assoc($product_result);
                                $product['gia_cu_formatted'] = number_format($product['gia_cu']);
                                $product['gia_moi_formatted'] = number_format($product['gia_moi']);
                                $product['discount_percent'] = $product['gia_cu'] > 0 ? round((($product['gia_cu'] - $product['gia_moi']) / $product['gia_cu']) * 100) : 0;
                                $product['image_url'] = $build_image_url($product['minh_hoa']);
                                $product['product_url'] = 'https://socdo.vn/san-pham/' . $product['id'] . '/' . $product['link'] . '.html';
                                $sub_products[] = $product;
                            }
                        }
                    }
                }
            }
            
            // Xác định trạng thái deal
            $deal_status = 'expired';
            if ($row['date_start'] > $current_time) {
                $deal_status = 'upcoming';
            } elseif ($row['date_start'] <= $current_time && $row['date_end'] >= $current_time) {
                $deal_status = 'active';
            }
            
            // Format thời gian
            $row['date_start_formatted'] = date('d/m/Y H:i:s', $row['date_start']);
            $row['date_end_formatted'] = date('d/m/Y H:i:s', $row['date_end']);
            $row['date_post_formatted'] = date('d/m/Y H:i:s', $row['date_post']);
            
            // Tính thời gian còn lại (nếu đang active)
            $time_remaining = 0;
            if ($deal_status === 'active') {
                $time_remaining = $row['date_end'] - $current_time;
            } elseif ($deal_status === 'upcoming') {
                $time_remaining = $row['date_start'] - $current_time;
            }
            
            $row['main_products'] = $main_products;
            $row['sub_products'] = $sub_products;
            $row['deal_status'] = $deal_status;
            $row['time_remaining'] = $time_remaining;
            $row['time_remaining_formatted'] = $time_remaining > 0 ? gmdate('H:i:s', $time_remaining) : '00:00:00';
            
            $deals[] = $row;
        }
        
        // Tính toán thông tin phân trang
        $total_pages = ceil($total_deals / $limit);
        
        $response = [
            "success" => true,
            "message" => "Lấy danh sách flash sale thành công",
            "data" => [
                "deals" => $deals,
                "pagination" => [
                    "current_page" => $page,
                    "total_pages" => $total_pages,
                    "total_deals" => $total_deals,
                    "limit" => $limit,
                    "has_next" => $page < $total_pages,
                    "has_prev" => $page > 1
                ],
                "filters" => [
                    "status" => $status,
                    "shop" => $shop
                ]
            ]
        ];
        
        http_response_code(200);
        echo json_encode($response, JSON_UNESCAPED_UNICODE);
        
    } elseif ($method === 'POST') {
        // Tạo flash sale mới
        $data = json_decode(file_get_contents("php://input"), true);
        
        // Validate required fields
        $required_fields = ['tieu_de', 'main_product', 'date_start', 'date_end', 'loai'];
        foreach ($required_fields as $field) {
            if (empty($data[$field])) {
                http_response_code(400);
                echo json_encode([
                    "success" => false,
                    "message" => "Thiếu trường bắt buộc: $field"
                ]);
                exit;
            }
        }
        
        $tieu_de = addslashes(strip_tags($data['tieu_de']));
        $shop = isset($data['shop']) ? intval($data['shop']) : 0;
        $main_product = addslashes($data['main_product']);
        $sub_product = isset($data['sub_product']) ? addslashes($data['sub_product']) : '';
        $sub_id = isset($data['sub_id']) ? addslashes($data['sub_id']) : '';
        $date_start = intval($data['date_start']);
        $date_end = intval($data['date_end']);
        $loai = addslashes($data['loai']);
        $status = isset($data['status']) ? intval($data['status']) : 0;
        $timeline = isset($data['timeline']) ? addslashes($data['timeline']) : '';
        $date_post = time();
        
        // Validate dates
        if ($date_start >= $date_end) {
            http_response_code(400);
            echo json_encode([
                "success" => false,
                "message" => "Thời gian bắt đầu phải nhỏ hơn thời gian kết thúc"
            ]);
            exit;
        }
        
        if ($date_start < time()) {
            http_response_code(400);
            echo json_encode([
                "success" => false,
                "message" => "Thời gian bắt đầu phải lớn hơn thời gian hiện tại"
            ]);
            exit;
        }
        
        // Insert vào database
        $insert_query = "INSERT INTO deal (shop, tieu_de, main_product, sub_product, sub_id, date_start, date_end, loai, date_post, status, timeline) 
                        VALUES ('$shop', '$tieu_de', '$main_product', '$sub_product', '$sub_id', '$date_start', '$date_end', '$loai', '$date_post', '$status', '$timeline')";
        
        $result = mysqli_query($conn, $insert_query);
        
        if ($result) {
            $deal_id = mysqli_insert_id($conn);
            
            http_response_code(201);
            echo json_encode([
                "success" => true,
                "message" => "Tạo flash sale thành công",
                "data" => [
                    "deal_id" => $deal_id,
                    "tieu_de" => $data['tieu_de'],
                    "date_start" => date('d/m/Y H:i:s', $date_start),
                    "date_end" => date('d/m/Y H:i:s', $date_end)
                ]
            ]);
        } else {
            http_response_code(500);
            echo json_encode([
                "success" => false,
                "message" => "Lỗi tạo flash sale: " . mysqli_error($conn)
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
