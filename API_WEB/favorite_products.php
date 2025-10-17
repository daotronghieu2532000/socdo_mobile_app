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
        $user_id = isset($_GET['user_id']) ? intval($_GET['user_id']) : 0;
        $page = isset($_GET['page']) ? intval($_GET['page']) : 1;
        $limit = isset($_GET['limit']) ? intval($_GET['limit']) : 50;
        
        // Validate parameters
        if ($user_id <= 0) {
            http_response_code(400);
            echo json_encode([
                "success" => false,
                "message" => "Thiếu user_id"
            ]);
            exit;
        }
        
        $get_all = isset($_GET['all']) && $_GET['all'] == '1';
        
        if ($limit > 500) $limit = 500;
        if ($limit < 1) $limit = 50;
        if ($page < 1) $page = 1;
        
        // Override limit nếu get_all = true
        if ($get_all) {
            $limit = 999999;
            $page = 1;
        }
        
        $start = ($page - 1) * $limit;
        
        // Đếm tổng số sản phẩm yêu thích
        $count_query = "SELECT COUNT(DISTINCT s.id) as total 
                       FROM yeu_thich_san_pham y
                       JOIN sanpham s ON y.product_id = s.id
                       WHERE y.user_id = '$user_id'";
        $count_result = mysqli_query($conn, $count_query);
        $total_favorites = mysqli_fetch_assoc($count_result)['total'];
        
        // Lấy danh sách sản phẩm yêu thích - theo logic hàm list_sanpham_yeuthich
        $sql = "SELECT DISTINCT
                s.id, s.tieu_de, s.link, s.gia_cu, s.gia_moi, s.gia_ctv, s.minh_hoa, s.shop, s.ma_sanpham,
                s.thuong_hieu, s.kho, s.ban, s.view, s.box_banchay, s.box_noibat, s.box_flash, 
                s.date_post, s.noi_bat, s.cat,
                COALESCE(pc.total_reviews, 0) AS total_reviews,
                COALESCE(pc.avg_rating, 0) AS avg_rating,
                y.id as favorite_id
                FROM yeu_thich_san_pham y
                JOIN sanpham s ON y.product_id = s.id
                LEFT JOIN phanloai_sanpham p ON s.id = p.sp_id
                LEFT JOIN (
                    SELECT product_id, COUNT(*) AS total_reviews, AVG(rating) AS avg_rating
                    FROM product_comments
                    WHERE status = 'approved' AND parent_id = 0
                    GROUP BY product_id
                ) AS pc ON s.id = pc.product_id
                WHERE y.user_id = '$user_id'
                ORDER BY y.id DESC
                LIMIT $start, $limit";
        
        $result = mysqli_query($conn, $sql);
        
        if (!$result) {
            http_response_code(500);
            echo json_encode([
                "success" => false,
                "message" => "Lỗi truy vấn database: " . mysqli_error($conn)
            ]);
            exit;
        }
        
        $products = array();
        $checked_ids = array();
        $current_time = time();
        
        while ($r_sp = mysqli_fetch_assoc($result)) {
            $id_sp = $r_sp['id'];
            
            // Tránh trùng lặp
            if (in_array($id_sp, $checked_ids)) continue;
            $checked_ids[] = $id_sp;
            
            // Xử lý giá từ bảng phanloai_sanpham nếu có
            $sql_pl = "SELECT MIN(gia_moi) AS gia_moi_min, MAX(gia_cu) AS gia_cu_max, MIN(gia_ctv) AS gia_ctv_min FROM phanloai_sanpham WHERE sp_id = '$id_sp'";
            $res_pl = mysqli_query($conn, $sql_pl);
            $row_pl = mysqli_fetch_assoc($res_pl);
            
            if ($row_pl && $row_pl['gia_moi_min'] !== null && $row_pl['gia_moi_min'] > 0) {
                $gia_moi_main = (int) $row_pl['gia_moi_min'];
                $gia_cu_main = (int) $row_pl['gia_cu_max'];
                $gia_ctv_main = (int) $row_pl['gia_ctv_min'];
            } else {
                $gia_cu_main = (int) preg_replace('/[^0-9]/', '', $r_sp['gia_cu']);
                $gia_moi_main = (int) preg_replace('/[^0-9]/', '', $r_sp['gia_moi']);
                $gia_ctv_main = (int) preg_replace('/[^0-9]/', '', $r_sp['gia_ctv']);
            }
            
            // Tính phần trăm giảm giá
            $giam = ($gia_cu_main > $gia_moi_main && $gia_cu_main > 0) ? 
                   ceil((($gia_cu_main - $gia_moi_main) / $gia_cu_main) * 100) : 0;
            
            // Format giá tiền
            $r_sp['gia_cu_formatted'] = number_format($gia_cu_main);
            $r_sp['gia_moi_formatted'] = number_format($gia_moi_main);
            $r_sp['gia_ctv_formatted'] = number_format($gia_ctv_main);
            $r_sp['discount_percent'] = $giam;
            $r_sp['date_post_formatted'] = date('d/m/Y H:i:s', $r_sp['date_post']);
            $r_sp['favorite_id'] = $r_sp['favorite_id'];
            
            // Xử lý hình ảnh
            $original_image = $r_sp['minh_hoa'];
            $thumb_image = str_replace('/uploads/minh-hoa/', '/uploads/thumbs/sanpham_anh_340x340/', $original_image);
            
            if (!empty($thumb_image) && file_exists($thumb_image)) {
                $r_sp['image_url'] = 'https://socdo.vn/' . $thumb_image;
            } elseif (!empty($original_image) && file_exists($original_image)) {
                $r_sp['image_url'] = 'https://socdo.vn/' . $original_image;
            } else {
                $r_sp['image_url'] = 'https://socdo.vn/images/no-images.jpg';
            }
            
            // Tạo URL sản phẩm
            $r_sp['product_url'] = 'https://socdo.vn/san-pham/' . $r_sp['id'] . '/' . $r_sp['link'] . '.html';
            
            // Xử lý voucher và freeship icons
            $deal_shop = $r_sp['shop'];
            $voucher_icon = '';
            $freeship_icon = '';
            
            if ($deal_shop) {
                // Check voucher
                $check_coupon = mysqli_query($conn, "SELECT id FROM coupon WHERE FIND_IN_SET('$id_sp', sanpham) AND shop = '$deal_shop' AND '$current_time' BETWEEN start AND expired LIMIT 1");
                if (mysqli_num_rows($check_coupon) > 0) {
                    $voucher_icon = 'Voucher';
                } else {
                    $check_coupon_all = mysqli_query($conn, "SELECT id FROM coupon WHERE shop = '$deal_shop' AND kieu = 'all' AND '$current_time' BETWEEN start AND expired LIMIT 1");
                    if (mysqli_num_rows($check_coupon_all) > 0) {
                        $voucher_icon = 'Voucher';
                    }
                }
                
                // Check freeship
                $check_freeship = mysqli_query($conn, "SELECT id FROM transport WHERE user_id = '$deal_shop' AND (free_ship_all = 1 OR free_ship_discount > 0) LIMIT 1");
                if (mysqli_num_rows($check_freeship) > 0) {
                    $freeship_icon = 'Freeship';
                }
            }
            
            // Thêm badges
            $badges = array();
            if ($r_sp['box_banchay'] == 1) $badges[] = 'Bán chạy';
            if ($r_sp['box_noibat'] == 1) $badges[] = 'Nổi bật';
            if ($r_sp['box_flash'] == 1) $badges[] = 'Flash sale';
            if ($giam > 0) $badges[] = "-$giam%";
            if (!empty($voucher_icon)) $badges[] = $voucher_icon;
            if (!empty($freeship_icon)) $badges[] = $freeship_icon;
            $badges[] = 'Chính hãng';
            
            $r_sp['badges'] = $badges;
            $r_sp['voucher_icon'] = $voucher_icon;
            $r_sp['freeship_icon'] = $freeship_icon;
            $r_sp['chinhhang_icon'] = 'Chính hãng';
            
            // Label sale
            if ($giam > 0) {
                $r_sp['label_sale'] = '<div class="label_product"><div class="label_wrapper">-' . $giam . '%</div></div>';
            } else {
                $r_sp['label_sale'] = '';
            }
            
            // Rating và reviews (fake data như hàm gốc)
            $r_sp['total_reviews'] = rand(3, 99);
            $r_sp['avg_rating'] = rand(40, 50) / 10; // 4.0 - 5.0
            $r_sp['sold_count'] = $r_sp['ban'] + rand(10, 100);
            
            // Star HTML
            $avg_rating = $r_sp['avg_rating'];
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
            $r_sp['star_html'] = $star_html;
            
            $products[] = $r_sp;
        }
        
        // Tính toán thông tin phân trang
        $total_pages = ceil($total_favorites / $limit);
        
        $response = [
            "success" => true,
            "message" => "Lấy danh sách sản phẩm yêu thích thành công",
            "data" => [
                "products" => $products,
                "pagination" => [
                    "current_page" => $page,
                    "total_pages" => $total_pages,
                    "total_favorites" => $total_favorites,
                    "limit" => $limit,
                    "has_next" => $page < $total_pages,
                    "has_prev" => $page > 1
                ],
                "user_id" => $user_id
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

