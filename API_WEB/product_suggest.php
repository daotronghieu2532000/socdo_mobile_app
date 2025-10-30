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
        $type = isset($_GET['type']) ? addslashes($_GET['type']) : 'home_suggest';
        $product_id = isset($_GET['product_id']) ? intval($_GET['product_id']) : 0;
        $category_id = isset($_GET['category_id']) ? intval($_GET['category_id']) : 0;
        $user_id = isset($_GET['user_id']) ? intval($_GET['user_id']) : 0;
        $limit = isset($_GET['limit']) ? intval($_GET['limit']) : 500;
        $exclude_ids = isset($_GET['exclude_ids']) ? addslashes($_GET['exclude_ids']) : '';
        $is_member = isset($_GET['is_member']) ? intval($_GET['is_member']) : 0;
        
        // Validate limit
        $get_all = isset($_GET['all']) && $_GET['all'] == '1';
        
        if ($limit > 500) $limit = 500;
        if ($limit < 1) $limit = 400;
        
        // Override limit nếu get_all = true
        if ($get_all) {
            $limit = 999999;
        }
        
        $products = array();
        
        switch ($type) {
            case 'home_suggest':
                // Gợi ý trang chủ - theo logic hàm list_home_goiy
                $one_month_ago = date('Ymd', strtotime('-3 month'));
                $exclude_condition = !empty($exclude_ids) ? " AND s.id NOT IN ($exclude_ids)" : "";
                
                $query = "SELECT s.*, 
                         p.id AS pl,
                         COALESCE(pc.total_reviews, 0) AS total_reviews,
                         COALESCE(pc.avg_rating, 0) AS avg_rating,
                         t.ten_kho AS warehouse_name,
                         tm.tieu_de AS province_name
                         FROM sanpham AS s
                         LEFT JOIN phanloai_sanpham AS p ON s.id = p.sp_id
                         LEFT JOIN (
                             SELECT product_id, COUNT(*) AS total_reviews, AVG(rating) AS avg_rating
                             FROM product_comments
                             WHERE status = 'approved' AND parent_id = 0
                             GROUP BY product_id
                         ) AS pc ON s.id = pc.product_id
                         LEFT JOIN transport t ON s.kho_id = t.id AND t.user_id = s.shop
                         LEFT JOIN tinh_moi tm ON t.province = tm.id
                         WHERE s.active = 0 
                         AND s.kho >= 0
                         AND ((NOT EXISTS (SELECT 1 FROM phanloai_sanpham pl WHERE pl.sp_id = s.id) AND s.kho > 0) OR EXISTS (SELECT 1 FROM phanloai_sanpham pl WHERE pl.sp_id = s.id AND pl.kho_sanpham_socdo > 0))
                         AND s.date_post >= UNIX_TIMESTAMP('$one_month_ago')
                         AND s.date_post <= UNIX_TIMESTAMP(NOW()) 
                         $exclude_condition
                         GROUP BY s.id
                         ORDER BY s.date_post DESC
                         LIMIT $limit";
                break;
                
            case 'related':
                // Sản phẩm liên quan dựa trên danh mục
                if ($product_id > 0) {
                    $product_query = "SELECT cat, thuong_hieu, gia_moi FROM sanpham WHERE id = $product_id LIMIT 1";
                    $product_result = mysqli_query($conn, $product_query);
                    
                    if ($product_result && mysqli_num_rows($product_result) > 0) {
                        $product_info = mysqli_fetch_assoc($product_result);
                        $category = $product_info['cat'];
                        $brand = addslashes($product_info['thuong_hieu']);
                        $price_range_min = $product_info['gia_moi'] * 0.7;
                        $price_range_max = $product_info['gia_moi'] * 1.3;
                        
                        $exclude_condition = !empty($exclude_ids) ? " AND s.id NOT IN ($exclude_ids)" : " AND s.id != $product_id";
                        
                        $query = "SELECT s.id, s.ma_sanpham, s.tieu_de, s.minh_hoa, s.gia_cu, s.gia_moi, s.gia_ctv, s.thuong_hieu, 
                                  s.kho, s.ban, s.view, s.box_banchay, s.box_noibat, s.date_post, s.link, s.noi_bat, s.shop,
                                  t.ten_kho AS warehouse_name,
                                  tm.tieu_de AS province_name
                                  FROM sanpham s
                                  LEFT JOIN transport t ON s.kho_id = t.id AND t.user_id = s.shop
                                  LEFT JOIN tinh_moi tm ON t.province = tm.id
                                  WHERE s.active = 0 AND s.kho >= 0 AND ((NOT EXISTS (SELECT 1 FROM phanloai_sanpham pl WHERE pl.sp_id = s.id) AND s.kho > 0) OR EXISTS (SELECT 1 FROM phanloai_sanpham pl WHERE pl.sp_id = s.id AND pl.kho_sanpham_socdo > 0)) $exclude_condition
                                  AND (
                                      (s.thuong_hieu = '$brand' AND FIND_IN_SET('$category', s.cat) > 0) OR
                                      (FIND_IN_SET('$category', s.cat) > 0 AND s.gia_moi BETWEEN $price_range_min AND $price_range_max) OR
                                      (s.thuong_hieu = '$brand')
                                  )
                                  ORDER BY 
                                      (s.thuong_hieu = '$brand' AND FIND_IN_SET('$category', s.cat) > 0) DESC,
                                      (FIND_IN_SET('$category', s.cat) > 0) DESC,
                                      s.view DESC, s.ban DESC
                                  LIMIT $limit";
                    } else {
                        $exclude_condition = !empty($exclude_ids) ? " AND s.id NOT IN ($exclude_ids)" : "";
                        $query = "SELECT s.id, s.ma_sanpham, s.tieu_de, s.minh_hoa, s.gia_cu, s.gia_moi, s.gia_ctv, s.thuong_hieu, 
                                  s.kho, s.ban, s.view, s.box_banchay, s.box_noibat, s.date_post, s.link, s.noi_bat, s.shop,
                                  t.ten_kho AS warehouse_name,
                                  tm.tieu_de AS province_name
                                  FROM sanpham s
                                  LEFT JOIN transport t ON s.kho_id = t.id AND t.user_id = s.shop
                                  LEFT JOIN tinh_moi tm ON t.province = tm.id
                                  WHERE s.kho > 0 AND s.active = 0 AND s.box_banchay = 1 $exclude_condition
                                  ORDER BY s.ban DESC, s.view DESC 
                                  LIMIT $limit";
                    }
                } else {
                    http_response_code(400);
                    echo json_encode([
                        "success" => false,
                        "message" => "Thiếu product_id cho loại related"
                    ]);
                    exit;
                }
                break;
                
            case 'bestseller':
                $category_condition = $category_id > 0 ? " AND FIND_IN_SET($category_id, cat) > 0" : "";
                $exclude_condition = !empty($exclude_ids) ? " AND s.id NOT IN ($exclude_ids)" : "";
                
                $query = "SELECT s.id, s.ma_sanpham, s.tieu_de, s.minh_hoa, s.gia_cu, s.gia_moi, s.gia_ctv, s.thuong_hieu, 
                          s.kho, s.ban, s.view, s.box_banchay, s.box_noibat, s.date_post, s.link, s.noi_bat, s.shop,
                          t.ten_kho AS warehouse_name,
                          tm.tieu_de AS province_name
                          FROM sanpham s
                          LEFT JOIN transport t ON s.kho_id = t.id AND t.user_id = s.shop
                          LEFT JOIN tinh_moi tm ON t.province = tm.id
                          WHERE s.active = 0 AND s.kho >= 0 AND ((NOT EXISTS (SELECT 1 FROM phanloai_sanpham pl WHERE pl.sp_id = s.id) AND s.kho > 0) OR EXISTS (SELECT 1 FROM phanloai_sanpham pl WHERE pl.sp_id = s.id AND pl.kho_sanpham_socdo > 0)) AND s.box_banchay = 1 $category_condition $exclude_condition
                          ORDER BY s.ban DESC, s.view DESC 
                          LIMIT $limit";
                break;
                
            case 'featured':
                $category_condition = $category_id > 0 ? " AND FIND_IN_SET($category_id, cat) > 0" : "";
                $exclude_condition = !empty($exclude_ids) ? " AND s.id NOT IN ($exclude_ids)" : "";
                
                $query = "SELECT s.id, s.ma_sanpham, s.tieu_de, s.minh_hoa, s.gia_cu, s.gia_moi, s.gia_ctv, s.thuong_hieu, 
                          s.kho, s.ban, s.view, s.box_banchay, s.box_noibat, s.date_post, s.link, s.noi_bat, s.shop,
                          t.ten_kho AS warehouse_name,
                          tm.tieu_de AS province_name
                          FROM sanpham s
                          LEFT JOIN transport t ON s.kho_id = t.id AND t.user_id = s.shop
                          LEFT JOIN tinh_moi tm ON t.province = tm.id
                          WHERE s.active = 0 AND s.kho >= 0 AND ((NOT EXISTS (SELECT 1 FROM phanloai_sanpham pl WHERE pl.sp_id = s.id) AND s.kho > 0) OR EXISTS (SELECT 1 FROM phanloai_sanpham pl WHERE pl.sp_id = s.id AND pl.kho_sanpham_socdo > 0)) AND s.box_noibat = 1 $category_condition $exclude_condition
                          ORDER BY s.view DESC, s.date_post DESC 
                          LIMIT $limit";
                break;
                
            case 'flash_sale':
                $category_condition = $category_id > 0 ? " AND FIND_IN_SET($category_id, cat) > 0" : "";
                $exclude_condition = !empty($exclude_ids) ? " AND s.id NOT IN ($exclude_ids)" : "";
                
                $query = "SELECT s.id, s.ma_sanpham, s.tieu_de, s.minh_hoa, s.gia_cu, s.gia_moi, s.gia_ctv, s.thuong_hieu, 
                          s.kho, s.ban, s.view, s.box_banchay, s.box_noibat, s.box_flash, s.date_post, s.link, s.noi_bat, s.shop,
                          t.ten_kho AS warehouse_name,
                          tm.tieu_de AS province_name
                          FROM sanpham s
                          LEFT JOIN transport t ON s.kho_id = t.id AND t.user_id = s.shop
                          LEFT JOIN tinh_moi tm ON t.province = tm.id
                          WHERE s.active = 0 AND s.kho >= 0 AND ((NOT EXISTS (SELECT 1 FROM phanloai_sanpham pl WHERE pl.sp_id = s.id) AND s.kho > 0) OR EXISTS (SELECT 1 FROM phanloai_sanpham pl WHERE pl.sp_id = s.id AND pl.kho_sanpham_socdo > 0)) AND s.box_flash = 1 $category_condition $exclude_condition
                          ORDER BY s.date_post DESC, s.view DESC 
                          LIMIT $limit";
                break;
                
            case 'newest':
                $category_condition = $category_id > 0 ? " AND FIND_IN_SET($category_id, cat) > 0" : "";
                $exclude_condition = !empty($exclude_ids) ? " AND s.id NOT IN ($exclude_ids)" : "";
                
                $query = "SELECT s.id, s.ma_sanpham, s.tieu_de, s.minh_hoa, s.gia_cu, s.gia_moi, s.gia_ctv, s.thuong_hieu, 
                          s.kho, s.ban, s.view, s.box_banchay, s.box_noibat, s.date_post, s.link, s.noi_bat, s.shop,
                          t.ten_kho AS warehouse_name,
                          tm.tieu_de AS province_name
                          FROM sanpham s
                          LEFT JOIN transport t ON s.kho_id = t.id AND t.user_id = s.shop
                          LEFT JOIN tinh_moi tm ON t.province = tm.id
                          WHERE s.active = 0 AND s.kho >= 0 AND ((NOT EXISTS (SELECT 1 FROM phanloai_sanpham pl WHERE pl.sp_id = s.id) AND s.kho > 0) OR EXISTS (SELECT 1 FROM phanloai_sanpham pl WHERE pl.sp_id = s.id AND pl.kho_sanpham_socdo > 0)) $category_condition $exclude_condition
                          ORDER BY s.date_post DESC, s.id DESC 
                          LIMIT $limit";
                break;
                
            case 'random':
                $category_condition = $category_id > 0 ? " AND FIND_IN_SET($category_id, cat) > 0" : "";
                $exclude_condition = !empty($exclude_ids) ? " AND s.id NOT IN ($exclude_ids)" : "";
                
                $query = "SELECT s.id, s.ma_sanpham, s.tieu_de, s.minh_hoa, s.gia_cu, s.gia_moi, s.gia_ctv, s.thuong_hieu, 
                          s.kho, s.ban, s.view, s.box_banchay, s.box_noibat, s.date_post, s.link, s.noi_bat, s.shop,
                          t.ten_kho AS warehouse_name,
                          tm.tieu_de AS province_name
                          FROM sanpham s
                          LEFT JOIN transport t ON s.kho_id = t.id AND t.user_id = s.shop
                          LEFT JOIN tinh_moi tm ON t.province = tm.id
                          WHERE s.active = 0 AND s.kho >= 0 AND ((NOT EXISTS (SELECT 1 FROM phanloai_sanpham pl WHERE pl.sp_id = s.id) AND s.kho > 0) OR EXISTS (SELECT 1 FROM phanloai_sanpham pl WHERE pl.sp_id = s.id AND pl.kho_sanpham_socdo > 0)) $category_condition $exclude_condition
                          ORDER BY RAND() 
                          LIMIT $limit";
                break;
                
            default:
                http_response_code(400);
                echo json_encode([
                    "success" => false,
                    "message" => "Loại gợi ý không hợp lệ. Các loại hỗ trợ: home_suggest, related, bestseller, featured, flash_sale, newest, random"
                ]);
                exit;
        }
        
        $result = mysqli_query($conn, $query);
        
        if (!$result) {
            http_response_code(500);
            echo json_encode([
                "success" => false,
                "message" => "Lỗi truy vấn database: " . mysqli_error($conn),
                "query" => $query,
                "exclude_ids" => $exclude_ids
            ]);
            exit;
        }
        
        $current_time = time();
        
        while ($row = mysqli_fetch_assoc($result)) {
            $id_sp = $row['id'];
            
            // Xử lý giá từ bảng phanloai_sanpham nếu có
            $sql_pl = "SELECT MIN(gia_moi) AS gia_moi_min, MAX(gia_cu) AS gia_cu_max, MIN(gia_ctv) AS gia_ctv_min FROM phanloai_sanpham WHERE sp_id = '$id_sp'";
            $res_pl = mysqli_query($conn, $sql_pl);
            $row_pl = mysqli_fetch_assoc($res_pl);
            
            if ($row_pl && $row_pl['gia_moi_min'] !== null && $row_pl['gia_moi_min'] > 0) {
                $gia_moi_main = (int) $row_pl['gia_moi_min'];
                $gia_cu_main = (int) $row_pl['gia_cu_max'];
                $gia_ctv_main = (int) $row_pl['gia_ctv_min'];
            } else {
                $gia_cu_main = (int) preg_replace('/[^0-9]/', '', $row['gia_cu']);
                $gia_moi_main = (int) preg_replace('/[^0-9]/', '', $row['gia_moi']);
                $gia_ctv_main = (int) preg_replace('/[^0-9]/', '', $row['gia_ctv']);
            }
            
            // Tính phần trăm giảm giá
            $discount_percent = ($gia_cu_main > $gia_moi_main && $gia_cu_main > 0) ? 
                               ceil((($gia_cu_main - $gia_moi_main) / $gia_cu_main) * 100) : 0;
            
            // Format giá tiền
            $row['gia_cu_formatted'] = number_format($gia_cu_main);
            $row['gia_moi_formatted'] = number_format($gia_moi_main);
            $row['gia_ctv_formatted'] = number_format($gia_ctv_main);
            $row['discount_percent'] = $discount_percent;
            $row['date_post_formatted'] = date('d/m/Y H:i:s', $row['date_post']);
            
            // Xử lý hình ảnh - theo logic hàm gốc
            $original_image = $row['minh_hoa'];
            $thumb_image = str_replace('/uploads/minh-hoa/', '/uploads/thumbs/sanpham_anh_340x340/', $original_image);
            
        if (!empty($thumb_image) && file_exists($thumb_image)) {
            $row['image_url'] = 'https://socdo.vn/' . $thumb_image;
        } elseif (!empty($original_image) && file_exists($original_image)) {
            $row['image_url'] = 'https://socdo.vn/' . $original_image;
        } else {
            $row['image_url'] = 'https://socdo.vn/images/no-images.jpg';
        }
            
            // Tạo URL sản phẩm
        $row['product_url'] = 'https://socdo.vn/san-pham/' . $row['id'] . '/' . $row['link'] . '.html';
            
            // Xử lý voucher và freeship icons
            $deal_shop = $row['shop'];
            $voucher_icon = '';
            $freeship_icon = '';
            
            // Check voucher - Logic chuẩn với hệ thống
            $voucher_icon = '';
            
            // Kiểm tra voucher cho sản phẩm cụ thể
            $check_coupon = mysqli_query($conn, "SELECT id FROM coupon WHERE FIND_IN_SET('$id_sp', sanpham) AND shop = '$deal_shop' AND kieu = 'sanpham' AND status = '2' AND '$current_time' BETWEEN start AND expired LIMIT 1");
            if (mysqli_num_rows($check_coupon) > 0) {
                $voucher_icon = 'Voucher';
            } else {
                // Kiểm tra voucher toàn shop
                $check_coupon_all = mysqli_query($conn, "SELECT id FROM coupon WHERE shop = '$deal_shop' AND kieu = 'all' AND status = '2' AND '$current_time' BETWEEN start AND expired LIMIT 1");
                if (mysqli_num_rows($check_coupon_all) > 0) {
                    $voucher_icon = 'Voucher';
                }
            }
            
            // Check freeship - Logic chuẩn với 4 mode
            $freeship_query = "SELECT free_ship_all, free_ship_discount, free_ship_min_order, fee_ship_products FROM transport WHERE user_id = '$deal_shop' AND (free_ship_all > 0 OR free_ship_discount > 0) LIMIT 1";
            $freeship_result = mysqli_query($conn, $freeship_query);
            $freeship_label = '';
            
            if ($freeship_result && mysqli_num_rows($freeship_result) > 0) {
                $freeship_data = mysqli_fetch_assoc($freeship_result);
                $mode = intval($freeship_data['free_ship_all'] ?? 0);
                $discount = intval($freeship_data['free_ship_discount'] ?? 0);
                $minOrder = intval($freeship_data['free_ship_min_order'] ?? 0);
                
                // Lấy giá sản phẩm để kiểm tra điều kiện min_order
                $base_price = $gia_moi_main;
                
                // Mode 0: Giảm cố định (VD: -15,000đ) - Cần kiểm tra điều kiện min_order
                if ($mode === 0 && $discount > 0 && $base_price >= $minOrder) {
                    $freeship_label = 'Giảm ' . number_format($discount) . 'đ ship';
                }
                // Mode 1: Freeship toàn bộ (100%)
                elseif ($mode === 1) {
                    $freeship_label = 'Freeship 100%';
                }
                // Mode 2: Giảm theo % (VD: -50%) - Cần kiểm tra điều kiện min_order
                elseif ($mode === 2 && $discount > 0 && $base_price >= $minOrder) {
                    $freeship_label = 'Giảm ' . intval($discount) . '% ship';
                }
                // Mode 3: Ưu đãi ship theo sản phẩm cụ thể - cần kiểm tra fee_ship_products
                elseif ($mode === 3) {
                    $fee_ship_products = $freeship_data['fee_ship_products'] ?? '';
                    $ship_discount_amount = 0;
                    
                    if (!empty($fee_ship_products)) {
                        $fee_ship_products_array = json_decode($fee_ship_products, true);
                        if (is_array($fee_ship_products_array)) {
                            foreach ($fee_ship_products_array as $ship_item) {
                                if (isset($ship_item['sp_id']) && $ship_item['sp_id'] == $id_sp) {
                                    // Lấy số tiền hỗ trợ ship cụ thể
                                    if (isset($ship_item['ship_support'])) {
                                        $ship_discount_amount = intval($ship_item['ship_support']);
                                    }
                                    break;
                                }
                            }
                        }
                    }
                    
                    // Hiển thị số tiền hỗ trợ ship cụ thể
                    if ($ship_discount_amount > 0) {
                        $freeship_label = 'Hỗ trợ ship ' . number_format($ship_discount_amount) . '₫';
                    }
                }
                
                $freeship_icon = $freeship_label ?: '';
            }
            
            // Thêm badges
            $badges = array();
            if ($row['box_banchay'] == 1) $badges[] = 'Bán chạy';
            if ($row['box_noibat'] == 1) $badges[] = 'Nổi bật';
            if (isset($row['box_flash']) && $row['box_flash'] == 1) $badges[] = 'Flash sale';
            if ($discount_percent > 0) $badges[] = "-$discount_percent%";
            if (!empty($voucher_icon)) $badges[] = $voucher_icon;
            if (!empty($freeship_icon)) $badges[] = $freeship_icon;
            $badges[] = 'Chính hãng';
            
            $row['badges'] = $badges;
            $row['voucher_icon'] = $voucher_icon;
            $row['freeship_icon'] = $freeship_icon;
            $row['chinhhang_icon'] = 'Chính hãng';
            
            // Rating và reviews (fake data như hàm gốc)
            $row['total_reviews'] = rand(3, 99);
            $row['avg_rating'] = rand(40, 50) / 10; // 4.0 - 5.0
            $row['sold_count'] = $row['ban'] + rand(10, 100);
            
            // Star HTML
            $avg_rating = $row['avg_rating'];
            $star_html = '';
            for ($i = 1; $i <= 5; $i++) {
                if ($i <= floor($avg_rating)) {
                    $star_html .= '<i class="fa fa-star" style="color: #ffc107"></i>';
                } elseif ($i - $avg_rating < 1) {
                    $star_html .= '<i class="fa fa-star-half-o" style="color: #ffc107"></i>';
                } else {
                    $star_html .= '<i class="fa fa-star-o" style="color: #ffc107"></i>';
                }
            }
            $row['star_html'] = $star_html;
            
            // Price for members
            if ($is_member) {
                $row['price_thanhvien'] = '<span class="price-thanhvien"><i class="fa fa-user"></i>' . $row['gia_ctv_formatted'] . '₫</span>';
            } else {
                $row['price_thanhvien'] = '';
            }
            
            $products[] = $row;
        }
        
        $response = [
            "success" => true,
            "message" => "Lấy gợi ý sản phẩm thành công",
            "data" => [
                "type" => $type,
                "total_products" => count($products),
                "products" => $products,
                "parameters" => [
                    "product_id" => $product_id,
                    "category_id" => $category_id,
                    "user_id" => $user_id,
                    "limit" => $limit,
                    "exclude_ids" => $exclude_ids,
                    "is_member" => $is_member
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
