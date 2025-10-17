<?php
header("Access-Control-Allow-Methods: GET");
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
        $category_id = isset($_GET['category_id']) ? intval($_GET['category_id']) : 0;
        $page = isset($_GET['page']) ? intval($_GET['page']) : 1;
        $limit = isset($_GET['limit']) ? intval($_GET['limit']) : 20;
        $sort = isset($_GET['sort']) ? addslashes($_GET['sort']) : 'newest'; // newest, price_asc, price_desc, popular
        
        // Validate parameters
        if ($category_id <= 0) {
            http_response_code(400);
            echo json_encode([
                "success" => false,
                "message" => "Category ID không hợp lệ"
            ]);
            exit;
        }
        
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
        
        // Kiểm tra danh mục có tồn tại không
        $category_check = "SELECT cat_id, cat_tieude FROM category_sanpham WHERE cat_id = $category_id LIMIT 1";
        $category_result = mysqli_query($conn, $category_check);
        
        if (!$category_result || mysqli_num_rows($category_result) == 0) {
            http_response_code(404);
            echo json_encode([
                "success" => false,
                "message" => "Không tìm thấy danh mục"
            ]);
            exit;
        }
        
        $category_info = mysqli_fetch_assoc($category_result);
        
        // Xây dựng query sắp xếp
        $order_by = "ORDER BY ";
        switch ($sort) {
            case 'price_asc':
                $order_by .= "gia_moi ASC";
                break;
            case 'price_desc':
                $order_by .= "gia_moi DESC";
                break;
            case 'popular':
                $order_by .= "ban DESC, view DESC";
                break;
            case 'newest':
            default:
                $order_by .= "date_post DESC, id DESC";
                break;
        }
        
        // Đếm tổng số sản phẩm trong danh mục
        $count_query = "SELECT COUNT(*) as total FROM sanpham WHERE FIND_IN_SET($category_id, cat) > 0 AND kho > 0";
        $count_result = mysqli_query($conn, $count_query);
        $total_products = mysqli_fetch_assoc($count_result)['total'];
        
        // Lấy danh sách sản phẩm
        $products_query = "SELECT s.*, 
                          t.ten_kho AS warehouse_name,
                          tm.tieu_de AS province_name
                          FROM sanpham s
                          LEFT JOIN transport t ON s.kho_id = t.id
                          LEFT JOIN tinh_moi tm ON t.province = tm.id
                          WHERE FIND_IN_SET($category_id, s.cat) > 0 AND s.kho > 0 $order_by LIMIT $start, $limit";
        $products_result = mysqli_query($conn, $products_query);
        
        if (!$products_result) {
            http_response_code(500);
            echo json_encode([
                "success" => false,
                "message" => "Lỗi truy vấn database: " . mysqli_error($conn)
            ]);
            exit;
        }
        
        $products = array();
        while ($product = mysqli_fetch_assoc($products_result)) {
            // Xử lý hình ảnh sản phẩm
            $image_url = '';
            if (!empty($product['minh_hoa'])) {
                if (strpos($product['minh_hoa'], 'http') === 0) {
                    $image_url = $product['minh_hoa'];
                } else {
                    $image_url = 'https://socdo.vn/' . ltrim($product['minh_hoa'], '/');
                }
            } else {
                $image_url = 'https://socdo.vn/images/no-images.jpg';
            }
            
            // Tính phần trăm giảm giá
            $discount_percent = 0;
            if ($product['gia_cu'] > 0 && $product['gia_moi'] > 0) {
                $discount_percent = round((($product['gia_cu'] - $product['gia_moi']) / $product['gia_cu']) * 100);
            }
            
            // Sử dụng helper function để thêm badges và location
            require_once './product_badge_helper.php';
            $product = addProductBadgesAndLocation($product, $conn);
            
            // Format dữ liệu sản phẩm
            $product_data = array(
                'id' => intval($product['id']),
                'tieu_de' => $product['tieu_de'],
                'minh_hoa' => $image_url,
                'gia_cu' => intval($product['gia_cu']),
                'gia_moi' => intval($product['gia_moi']),
                'discount_percent' => $discount_percent,
                'kho' => intval($product['kho']),
                'ban' => intval($product['ban']),
                'view' => intval($product['view']),
                'thuong_hieu' => $product['thuong_hieu'],
                'noi_ban' => $product['noi_ban'],
                'cat' => $product['cat'],
                'link' => $product['link'],
                'date_post' => $product['date_post'],
                'shop' => $product['shop'] ? intval($product['shop']) : null,
                'status' => $product['status'] ? intval($product['status']) : null,
                'box_banchay' => intval($product['box_banchay']),
                'box_noibat' => intval($product['box_noibat']),
                'box_flash' => intval($product['box_flash']),
                'warehouse_name' => $product['warehouse_name'],
                'province_name' => $product['province_name'],
                'hasVoucher' => $product['has_voucher'],
                'isFreeship' => $product['has_freeship'],
                'location_text' => $product['location_text'],
                'badges' => array(),
            );
            
            // Tạo badges array cho UI
            $badges = array();
            
            // Discount badge
            if ($discount_percent > 0) {
                $badges[] = "Giảm $discount_percent%";
            }
            
            // Flash sale badge
            if ($product['box_flash'] == 1) {
                $badges[] = "FLASH SALE";
            }
            
            // Bestseller badge
            if ($product['box_banchay'] == 1) {
                $badges[] = "BÁN CHẠY";
            }
            
            // Featured badge
            if ($product['box_noibat'] == 1) {
                $badges[] = "NỔI BẬT";
            }
            
            // Voucher badge
            if ($product['has_voucher']) {
                $badges[] = "Voucher";
            }
            
            // Freeship badge
            if ($product['has_freeship']) {
                $badges[] = $product['freeship_label'] ?: "Freeship";
            }
            
            // Chính hãng badge
            $badges[] = "Chính hãng";
            
            $product_data['badges'] = $badges;
            
            $products[] = $product_data;
        }
        
        // Tính toán thông tin phân trang
        $total_pages = ceil($total_products / $limit);
        
        $response = [
            "success" => true,
            "message" => "Lấy danh sách sản phẩm theo danh mục thành công",
            "data" => [
                "category" => [
                    "id" => intval($category_info['cat_id']),
                    "name" => $category_info['cat_tieude']
                ],
                "products" => $products,
                "pagination" => [
                    "current_page" => $page,
                    "total_pages" => $total_pages,
                    "total_products" => $total_products,
                    "limit" => $limit,
                    "has_next" => $page < $total_pages,
                    "has_prev" => $page > 1
                ],
                "filters" => [
                    "category_id" => $category_id,
                    "sort" => $sort
                ]
            ]
        ];
        
        http_response_code(200);
        echo json_encode($response, JSON_UNESCAPED_UNICODE);
        
    } else {
        http_response_code(405);
        echo json_encode([
            "success" => false,
            "message" => "Chỉ hỗ trợ phương thức GET"
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
