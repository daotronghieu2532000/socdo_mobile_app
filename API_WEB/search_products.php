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
    
    // Lấy tham số tìm kiếm - CHỈ KEYWORD
    $keyword = isset($_GET['keyword']) ? addslashes(strip_tags($_GET['keyword'])) : '';
    $page = isset($_GET['page']) ? intval($_GET['page']) : 1;
    $limit = isset($_GET['limit']) ? intval($_GET['limit']) : 1000;

    // Validate limit
    $get_all = isset($_GET['all']) && $_GET['all'] == '1';
    
    if ($limit > 500) $limit = 1000;
    if ($limit < 1) $limit = 400;
    if ($page < 1) $page = 1;
    
    // Override limit nếu get_all = true
    if ($get_all) {
        $limit = 999999;
        $page = 1;
    }
    
    $start = ($page - 1) * $limit;
    
    // Validation keyword - BẮT BUỘC phải có từ khóa
    if (empty($keyword)) {
        http_response_code(400);
        echo json_encode([
            "success" => false,
            "message" => "Vui lòng nhập từ khóa tìm kiếm"
        ]);
        exit;
    }
    
    // Xây dựng câu WHERE cho tìm kiếm
    // Thêm logic tìm kiếm theo danh mục
    $category_search = '';
    $category_query = "SELECT cat_id FROM category_sanpham WHERE cat_tieude LIKE '%$keyword%' OR cat_title LIKE '%$keyword%'";
    $category_result = mysqli_query($conn, $category_query);
    
    if ($category_result && mysqli_num_rows($category_result) > 0) {
        $category_ids = array();
        while ($row = mysqli_fetch_assoc($category_result)) {
            $category_ids[] = $row['cat_id'];
        }
        
        if (!empty($category_ids)) {
            $category_search = " OR (";
            foreach ($category_ids as $index => $cat_id) {
                if ($index > 0) $category_search .= " OR ";
                $category_search .= "FIND_IN_SET($cat_id, sanpham.cat) > 0";
            }
            $category_search .= ")";
        }
    }
    
    $where_clause = "sanpham.kho > 0 AND sanpham.active = 0 AND (sanpham.tieu_de LIKE '%$keyword%' OR sanpham.ma_sanpham LIKE '%$keyword%'$category_search)";
    
    // ORDER BY theo logic hàm list_sanpham_timkiem
    $order_clause = 'has_rating DESC, avg_rating DESC, sanpham.view DESC';
    
    // Đếm tổng số sản phẩm
    $count_query = "SELECT COUNT(*) as total 
                   FROM sanpham
                   LEFT JOIN transport ON sanpham.kho_id = transport.id
                   LEFT JOIN tinh_moi ON transport.province = tinh_moi.id
                   LEFT JOIN (
                       SELECT product_id, AVG(rating) AS avg_rating, COUNT(*) AS total_reviews
                       FROM product_comments
                       WHERE status = 'approved' AND parent_id = 0
                       GROUP BY product_id
                   ) AS pc ON sanpham.id = pc.product_id
                   WHERE $where_clause";
    $count_result = mysqli_query($conn, $count_query);
    $total_products = mysqli_fetch_assoc($count_result)['total'];
    
    // Lấy danh sách sản phẩm - CHỈ CÁC TRƯỜNG CẦN THIẾT
    $query = "SELECT sanpham.id, sanpham.ma_sanpham, sanpham.tieu_de, sanpham.minh_hoa, 
              sanpham.link, sanpham.gia_cu, sanpham.gia_moi, sanpham.gia_drop, sanpham.gia_ctv,
              sanpham.thuong_hieu, sanpham.kho, sanpham.kho_hcm, sanpham.ban, sanpham.view,
              sanpham.box_banchay, sanpham.box_noibat, sanpham.box_flash, sanpham.date_post, sanpham.shop,
              tinh_moi.tieu_de AS province_name,
              IFNULL(pc.avg_rating, 0) AS avg_rating,
              IFNULL(pc.total_reviews, 0) AS total_reviews,
              IF(IFNULL(pc.total_reviews, 0) > 0, 1, 0) AS has_rating
              FROM sanpham
              LEFT JOIN transport ON sanpham.kho_id = transport.id
              LEFT JOIN tinh_moi ON transport.province = tinh_moi.id
              LEFT JOIN (
                  SELECT product_id, AVG(rating) AS avg_rating, COUNT(*) AS total_reviews
                  FROM product_comments
                  WHERE status = 'approved' AND parent_id = 0
                  GROUP BY product_id
              ) AS pc ON sanpham.id = pc.product_id
              WHERE $where_clause
              ORDER BY $order_clause
              LIMIT $start, $limit";
              
    $result = mysqli_query($conn, $query);
    
    if (!$result) {
        http_response_code(500);
        echo json_encode([
            "success" => false,
            "message" => "Lỗi truy vấn database: " . mysqli_error($conn)
        ]);
        exit;
    }
    
    $products = array();
    $current_time = time();
    $today = date('Ymd');
    
    while ($row = mysqli_fetch_assoc($result)) {
        $id_sp = $row['id'];
        $row['date_post_formatted'] = date('d/m/Y', $row['date_post']);
        
        // Xử lý giá từ bảng phanloai_sanpham - theo logic hàm gốc
        $sql_pl = mysqli_query($conn, "SELECT MAX(gia_cu) AS max_gia_cu, MIN(gia_moi) AS min_gia_moi FROM phanloai_sanpham WHERE sp_id = '$id_sp'");
        if ($sql_pl && mysqli_num_rows($sql_pl) > 0) {
            $pl = mysqli_fetch_assoc($sql_pl);
            if ($pl['max_gia_cu'] !== null && $pl['min_gia_moi'] !== null) {
                $row['gia_cu'] = (int) $pl['max_gia_cu'];
                $row['gia_moi'] = (int) $pl['min_gia_moi'];
            }
        }
        
        // Tính phần trăm giảm giá
        $discount_percent = 0;
        if ($row['gia_cu'] > $row['gia_moi'] && $row['gia_cu'] > 0) {
            $discount_percent = ceil((($row['gia_cu'] - $row['gia_moi']) / $row['gia_cu']) * 100);
        }
        
        // Số lượng đã bán (fake data theo logic hàm gốc)
        srand($id_sp);
        $total_sold = rand(200, 500);
        $start_date = "20250312";
        $days_passed = (int) ((strtotime($today) - strtotime($start_date)) / (60 * 60 * 24));
        srand($id_sp + $days_passed);
        $random_increment = rand(1, 5);
        $sold_today = min($total_sold, rand(20, 100) + ($days_passed * $random_increment));
        
        // Format giá tiền
        $row['gia_cu_formatted'] = number_format($row['gia_cu']);
        $row['gia_moi_formatted'] = number_format($row['gia_moi']);
        $row['gia_drop_formatted'] = number_format($row['gia_drop']);
        $row['gia_ctv_formatted'] = number_format($row['gia_ctv']);
        $row['discount_percent'] = $discount_percent;
        $row['total_sold'] = $total_sold;
        $row['sold_today'] = $sold_today;
        
        // Xử lý tỉnh thành
        if (empty($row['province_name'])) {
            $row['province_name'] = 'Thành phố Hà Nội';
        }
        $row['province_name'] = str_replace(['Tỉnh ', 'Thành phố '], '', $row['province_name']);
        
        // Xử lý hình ảnh - ưu tiên thumbnail
        $original_image = $row['minh_hoa'];
        $thumb_image = str_replace('/uploads/minh-hoa/', '/uploads/thumbs/sanpham_anh_340x340/', $original_image);
        
        if (!empty($thumb_image) && file_exists($thumb_image)) {
            $row['image_url'] = 'https://socdo.vn/' . $thumb_image;
        } elseif (!empty($original_image) && file_exists($original_image)) {
            $row['image_url'] = 'https://socdo.vn/' . $original_image;
        } else {
            $row['image_url'] = 'https://socdo.vn/images/no-images.jpg';
        }
        
        // Rating và reviews - theo logic hàm gốc
        $total_reviews = $row['total_reviews'] > 0 ? $row['total_reviews'] : rand(3, 99);
        $avg_rating = $row['avg_rating'] > 0 ? round($row['avg_rating'], 1) : rand(40, 50) / 10;
        
        // Star HTML
        $star_html = '';
        for ($j = 1; $j <= 5; $j++) {
            if ($j <= floor($avg_rating)) {
                $star_html .= '<i class="fas fa-star" style="color: #ffc107"></i>';
            } elseif ($j - $avg_rating <= 0.75 && $avg_rating > floor($avg_rating)) {
                $star_html .= '<i class="fas fa-star-half-alt" style="color: #ffc107"></i>';
            } else {
                $star_html .= '<i class="far fa-star" style="color: #ffc107"></i>';
            }
        }
        
        $row['star_html'] = $star_html;
        $row['review_count'] = "($total_reviews)";
        $row['avg_rating'] = $avg_rating;
        $row['total_reviews'] = $total_reviews;
        
        // Xử lý voucher và freeship - theo logic hàm gốc
        $deal_shop = $row['shop'];
        $voucher_icon = '';
        $freeship_icon = '';
        
        // Check voucher - Logic chuẩn với hệ thống
        $check_coupon = mysqli_query($conn, "SELECT id FROM coupon WHERE FIND_IN_SET('$id_sp', sanpham) AND shop = '$deal_shop' AND kieu = 'sanpham' AND status = '2' AND '$current_time' BETWEEN start AND expired LIMIT 1");
        if (mysqli_num_rows($check_coupon) > 0) {
            $voucher_icon = 'Voucher';
        } else {
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
            $base_price = $row['gia_moi'];
            
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
        
        $chinhhang_icon = 'Chính hãng';
        
        // Thêm badges
        $badges = array();
        if ($row['box_banchay'] == 1) $badges[] = 'Bán chạy';
        if ($row['box_noibat'] == 1) $badges[] = 'Nổi bật';
        if ($row['box_flash'] == 1) $badges[] = 'Flash sale';
        if ($discount_percent > 0) $badges[] = "-$discount_percent%";
        if (!empty($voucher_icon)) $badges[] = $voucher_icon;
        if (!empty($freeship_icon)) $badges[] = $freeship_icon;
        $badges[] = $chinhhang_icon;
        
        $row['badges'] = $badges;
        $row['voucher_icon'] = $voucher_icon;
        $row['freeship_icon'] = $freeship_icon;
        $row['chinhhang_icon'] = $chinhhang_icon;
        
        // Thông tin kho
        $row['warehouse_name'] = '';
        $row['province_name'] = $row['province_name'] ?? 'Thành phố Hà Nội';
        
        // Label sale
        if ($discount_percent > 0) {
            $row['label_sale'] = '<div class="label_product"><div class="label_wrapper">-' . $discount_percent . '%</div></div>';
        } else {
            $row['label_sale'] = '';
        }
        
        // Tạo URL sản phẩm
        $row['product_url'] = 'https://socdo.vn/san-pham/' . $row['id'] . '/' . $row['link'] . '.html';
        
        $products[] = $row;
    }
    
    // Tính toán thông tin phân trang
    $total_pages = ceil($total_products / $limit);
    
    $response = [
        "success" => true,
        "message" => "Lấy danh sách sản phẩm thành công",
        "data" => [
            "products" => $products,
            "pagination" => [
                "current_page" => $page,
                "total_pages" => $total_pages,
                "total_products" => $total_products,
                "limit" => $limit,
                "has_next" => $page < $total_pages,
                "has_prev" => $page > 1
            ],
            "search_params" => [
                "keyword" => $keyword,
                "page" => $page,
                "limit" => $limit
            ]
        ]
    ];
    http_response_code(200);
    echo json_encode($response, JSON_UNESCAPED_UNICODE);
    
} catch (Exception $e) {
    http_response_code(401);
    echo json_encode(array(
        "success" => false,
        "message" => "Token không hợp lệ",
        "error" => $e->getMessage()
    ));
}
?>
