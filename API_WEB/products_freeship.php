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
        $page = isset($_GET['page']) ? intval($_GET['page']) : 1;
        $limit = isset($_GET['limit']) ? intval($_GET['limit']) : 20;
        $category_id = isset($_GET['category_id']) ? intval($_GET['category_id']) : 0;
        $shop_id = isset($_GET['shop_id']) ? intval($_GET['shop_id']) : 0;
        $sort = isset($_GET['sort']) ? trim($_GET['sort']) : 'time-desc'; // time-desc, time-asc, price-asc, price-desc
        $min_price = isset($_GET['min_price']) ? intval($_GET['min_price']) : 0;
        $max_price = isset($_GET['max_price']) ? intval($_GET['max_price']) : 0;
        
        // Validate parameters
        if ($page < 1) $page = 1;
        if ($limit < 1 || $limit > 100) $limit = 20;
        
        $offset = ($page - 1) * $limit;
        
        // Xây dựng WHERE clause
        $where_conditions = array("sanpham.status = 1");
        
        // Điều kiện ship 0đ - Logic từ transport table
        $where_conditions[] = "EXISTS (
            SELECT 1 FROM transport t 
            WHERE t.user_id = sanpham.shop 
            AND (t.free_ship_all = 1 OR t.free_ship_discount > 0)
        )";
        
        // Lọc theo danh mục
        if ($category_id > 0) {
            $where_conditions[] = "FIND_IN_SET('$category_id', sanpham.cat) > 0";
        }
        
        // Lọc theo shop
        if ($shop_id > 0) {
            $where_conditions[] = "sanpham.shop = '$shop_id'";
        }
        
        // Lọc theo giá
        if ($min_price > 0) {
            $where_conditions[] = "sanpham.gia_moi >= '$min_price'";
        }
        if ($max_price > 0) {
            $where_conditions[] = "sanpham.gia_moi <= '$max_price'";
        }
        
        $where_clause = "WHERE " . implode(" AND ", $where_conditions);
        
        // Đếm tổng số sản phẩm
        $count_query = "SELECT COUNT(*) as total FROM sanpham $where_clause";
        $count_result = mysqli_query($conn, $count_query);
        $total_records = 0;
        if ($count_result) {
            $count_row = mysqli_fetch_assoc($count_result);
            $total_records = $count_row['total'];
        }
        
        $total_pages = ceil($total_records / $limit);
        
        // Xử lý sắp xếp
        $allowed_sorts = ['time-desc', 'time-asc', 'price-asc', 'price-desc'];
        $sort = in_array($sort, $allowed_sorts) ? $sort : 'time-desc';
        
        switch ($sort) {
            case 'time-desc':
                $order_by = "ORDER BY sanpham.id DESC";
                break;
            case 'time-asc':
                $order_by = "ORDER BY sanpham.id ASC";
                break;
            case 'price-asc':
                $order_by = "ORDER BY sanpham.gia_moi ASC";
                break;
            case 'price-desc':
                $order_by = "ORDER BY sanpham.gia_moi DESC";
                break;
            default:
                $order_by = "ORDER BY sanpham.id DESC";
        }
        
        // Lấy danh sách sản phẩm với thông tin shop
        $products_query = "
            SELECT 
                sanpham.*,
                th.tieu_de as brand_name,
                th.anh_thuong_hieu as brand_logo,
                t.free_ship_all,
                t.free_ship_discount,
                t.free_ship_min_order,
                t.fee_ship_products,
                t.ten_kho AS warehouse_name,
                tm.tieu_de AS province_name,
                u.name as shop_name,
                u.avatar as shop_avatar
            FROM sanpham 
            LEFT JOIN thuong_hieu th ON th.id = sanpham.thuong_hieu
            LEFT JOIN transport t ON t.user_id = sanpham.shop AND (t.free_ship_all IN (0,1,2,3) OR t.free_ship_discount > 0)
            LEFT JOIN tinh_moi tm ON t.province = tm.id
            LEFT JOIN user_info u ON u.user_id = sanpham.shop
            $where_clause 
            $order_by 
            LIMIT $offset, $limit
        ";
        
        $products_result = mysqli_query($conn, $products_query);
        
        if (!$products_result) {
            http_response_code(500);
            echo json_encode([
                "success" => false,
                "message" => "Lỗi truy vấn database"
            ]);
            exit;
        }
        
        $products = array();
        
        while ($product = mysqli_fetch_assoc($products_result)) {
            // Sử dụng helper function để thêm badges và location
            require_once './product_badge_helper.php';
            $product = addProductBadgesAndLocation($product, $conn);
            
            // Format dữ liệu sản phẩm
            $product_data = array();
            $product_data['id'] = intval($product['id']);
            $product_data['name'] = $product['tieu_de'];
            $product_data['slug'] = $product['link'];
            $product_data['price'] = intval($product['gia_moi']);
            $product_data['old_price'] = intval($product['gia_cu']);
            $product_data['discount_percent'] = 0;
            
            // Tính % giảm giá
            if ($product['gia_cu'] > 0 && $product['gia_moi'] < $product['gia_cu']) {
                $product_data['discount_percent'] = round((($product['gia_cu'] - $product['gia_moi']) / $product['gia_cu']) * 100);
            }
            
            $product_data['shop_id'] = intval($product['shop']);
            $product_data['category_ids'] = explode(',', $product['cat']);
            $product_data['category_ids'] = array_filter(array_map('intval', $product_data['category_ids']));
            $product_data['brand_id'] = intval($product['thuong_hieu']);
            $product_data['brand_name'] = $product['brand_name'] ?: '';
            $product_data['brand_logo'] = $product['brand_logo'] ? 'https://socdo.vn/' . $product['brand_logo'] : '';
            
            // Xử lý hình ảnh
            if (!empty($product['minh_hoa'])) {
                $product_data['image'] = 'https://socdo.vn/' . $product['minh_hoa'];
                
                // Tạo thumbnail
                $thumb_image = str_replace('/uploads/minh-hoa/', '/uploads/thumbs/sanpham_anh_340x340/', $product['minh_hoa']);
                $product_data['thumb'] = 'https://socdo.vn/' . $thumb_image;
            } else {
                $product_data['image'] = '';
                $product_data['thumb'] = '';
            }
            
            // Tạo URL sản phẩm
            $product_data['product_url'] = 'https://socdo.vn/san-pham/' . $product_data['id'] . '/' . $product_data['slug'] . '.html';
            
            // Thông tin ship từ helper function
            $product_data['has_voucher'] = $product['has_voucher'];
            $product_data['has_freeship'] = $product['has_freeship'];
            $product_data['freeship_type'] = $product['freeship_type'];
            $product_data['freeship_label'] = $product['freeship_label'];
            $product_data['location_text'] = $product['location_text'];
            
            // Tạo badges
            $badges = array();
            if ($product_data['discount_percent'] > 0) $badges[] = "-{$product_data['discount_percent']}%";
            if ($product['has_voucher']) $badges[] = 'Voucher';
            if ($product['has_freeship']) $badges[] = $product['freeship_label'] ?: 'Freeship';
            $badges[] = 'Chính hãng';
            $product_data['badges'] = $badges;
            
            $products[] = $product_data;
        }
        
        $response = [
            "success" => true,
            "message" => "Lấy danh sách sản phẩm ship 0đ thành công",
            "data" => [
                "products" => $products,
                "pagination" => [
                    "current_page" => $page,
                    "total_pages" => $total_pages,
                    "total_records" => $total_records,
                    "per_page" => $limit,
                    "has_next" => $page < $total_pages,
                    "has_prev" => $page > 1
                ],
                "filters" => [
                    "category_id" => $category_id,
                    "shop_id" => $shop_id,
                    "sort" => $sort,
                    "min_price" => $min_price,
                    "max_price" => $max_price
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
 