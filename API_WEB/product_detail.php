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
        $product_id = isset($_GET['product_id']) ? intval($_GET['product_id']) : 0;
        $user_id = isset($_GET['user_id']) ? intval($_GET['user_id']) : 0;
        $is_member = isset($_GET['is_member']) ? intval($_GET['is_member']) : 0;
        
        // Validate parameters
        if ($product_id <= 0) {
            http_response_code(400);
            echo json_encode([
                "success" => false,
                "message" => "Thiếu product_id"
            ]);
            exit;
        }
        
        // Lấy thông tin chi tiết sản phẩm
        $query = "SELECT s.*, 
                  COALESCE(pc.total_reviews, 0) AS total_reviews,
                  COALESCE(pc.avg_rating, 0) AS avg_rating,
                  t.ten_kho AS warehouse_name,
                  tm.tieu_de AS province_name,
                  CASE WHEN y.id IS NOT NULL THEN 1 ELSE 0 END AS is_favorited
                  FROM sanpham s
                  LEFT JOIN (
                      SELECT product_id, COUNT(*) AS total_reviews, AVG(rating) AS avg_rating
                      FROM product_comments
                      WHERE status = 'approved' AND parent_id = 0
                      GROUP BY product_id
                  ) AS pc ON s.id = pc.product_id
                  LEFT JOIN transport t ON s.kho_id = t.id
                  LEFT JOIN tinh_moi tm ON t.province = tm.id
                  LEFT JOIN yeu_thich_san_pham y ON s.id = y.product_id AND y.user_id = '$user_id'
                  WHERE s.id = $product_id AND s.kho > 0 AND s.active = 0
                  LIMIT 1";
        
        $result = mysqli_query($conn, $query);
        
        if (!$result || mysqli_num_rows($result) == 0) {
            http_response_code(404);
            echo json_encode([
                "success" => false,
                "message" => "Không tìm thấy sản phẩm"
            ]);
            exit;
        }
        
        $product = mysqli_fetch_assoc($result);
        $current_time = time();
        
        // Xử lý giá từ bảng phanloai_sanpham nếu có
        $sql_pl = "SELECT MIN(gia_moi) AS gia_moi_min, MAX(gia_cu) AS gia_cu_max, MIN(gia_ctv) AS gia_ctv_min, 
                   MIN(gia_drop) AS gia_drop_min FROM phanloai_sanpham WHERE sp_id = '$product_id'";
        $res_pl = mysqli_query($conn, $sql_pl);
        $row_pl = mysqli_fetch_assoc($res_pl);
        
        if ($row_pl && $row_pl['gia_moi_min'] !== null && $row_pl['gia_moi_min'] > 0) {
            $gia_moi_main = (int) $row_pl['gia_moi_min'];
            $gia_cu_main = (int) $row_pl['gia_cu_max'];
            $gia_ctv_main = (int) $row_pl['gia_ctv_min'];
            $gia_drop_main = (int) $row_pl['gia_drop_min'];
        } else {
            $gia_cu_main = (int) preg_replace('/[^0-9]/', '', $product['gia_cu']);
            $gia_moi_main = (int) preg_replace('/[^0-9]/', '', $product['gia_moi']);
            $gia_ctv_main = (int) preg_replace('/[^0-9]/', '', $product['gia_ctv']);
            $gia_drop_main = (int) preg_replace('/[^0-9]/', '', $product['gia_drop']);
        }
        
        // Tính phần trăm giảm giá
        $discount_percent = ($gia_cu_main > $gia_moi_main && $gia_cu_main > 0) ? 
                           ceil((($gia_cu_main - $gia_moi_main) / $gia_cu_main) * 100) : 0;
        
        // Format giá tiền
        $product['gia_cu_formatted'] = number_format($gia_cu_main);
        $product['gia_moi_formatted'] = number_format($gia_moi_main);
        $product['gia_ctv_formatted'] = number_format($gia_ctv_main);
        $product['gia_drop_formatted'] = number_format($gia_drop_main);
        $product['discount_percent'] = $discount_percent;
        $product['date_post_formatted'] = date('d/m/Y H:i:s', $product['date_post']);
        
        // Xử lý hình ảnh
        $images = array();
        $main_image = $product['minh_hoa'];
        
        // Debug logging
        error_log("DEBUG: Product ID $product_id - minh_hoa: " . $main_image);
        error_log("DEBUG: Product ID $product_id - anh: " . $product['anh']);
        
        // Hình ảnh chính (minh_hoa)
        if (!empty($main_image)) {
            // Sửa đường dẫn để đảm bảo bắt đầu với /
            $main_image = ltrim($main_image, '/');
            $images['main'] = 'https://socdo.vn/' . $main_image;
            
            // Tạo thumbnail path
            $thumb_image = str_replace('/uploads/minh-hoa/', '/uploads/thumbs/sanpham_anh_340x340/', '/' . $main_image);
            $images['thumb'] = 'https://socdo.vn/' . ltrim($thumb_image, '/');
        } else {
            $images['main'] = 'https://socdo.vn/images/no-images.jpg';
            $images['thumb'] = $images['main'];
        }
        
        // Hình ảnh gallery từ cột 'anh' (chi tiết sản phẩm)
        $gallery_images = array();
        if (!empty($product['anh'])) {
            $image_list = explode(',', $product['anh']);
            error_log("DEBUG: Product ID $product_id - image_list count: " . count($image_list));
            foreach ($image_list as $img) {
                $img = trim($img);
                if (!empty($img)) {
                    // Sửa đường dẫn để đảm bảo bắt đầu với /
                    $img = ltrim($img, '/');
                    $gallery_images[] = 'https://socdo.vn/' . $img;
                    error_log("DEBUG: Product ID $product_id - added gallery image: " . $img);
                }
            }
        }
        
        // Nếu không có ảnh gallery, sử dụng ảnh chính
        if (empty($gallery_images)) {
            $gallery_images[] = $images['main'];
        }
        
        $images['gallery'] = $gallery_images;
        
        // Debug logging cho kết quả cuối cùng
        error_log("DEBUG: Product ID $product_id - final images array: " . json_encode($images));
        error_log("DEBUG: Product ID $product_id - gallery count: " . count($gallery_images));
        
        $product['images'] = $images;
        
        // Check if product is in flash sale
        $flash_sale_info = null;
        // Check status IN (1,2) - status 1: web con, status 2: Đăng sàn
        $check_flash_sale = mysqli_query($conn, "SELECT * FROM deal WHERE loai = 'flash_sale' AND status = 2 AND '$current_time' BETWEEN date_start AND date_end LIMIT 50");
        
        if ($check_flash_sale && mysqli_num_rows($check_flash_sale) > 0) {
            // Loop through all active flash sales to find if this product is included
            while ($flash_deal = mysqli_fetch_assoc($check_flash_sale)) {
                $is_in_flash_sale = false;
                
                // Check main_product
                if (!empty($flash_deal['main_product'])) {
                    $main_product_ids = explode(',', $flash_deal['main_product']);
                    $main_product_ids_int = array_map('intval', $main_product_ids);
                    if (in_array(intval($product_id), $main_product_ids_int)) {
                        $is_in_flash_sale = true;
                    }
                }
                
                // Check sub_product (JSON) - product_id can be string or int in JSON
                if (!$is_in_flash_sale && !empty($flash_deal['sub_product'])) {
                    $sub_json = json_decode($flash_deal['sub_product'], true);
                    if (json_last_error() === JSON_ERROR_NONE && is_array($sub_json)) {
                        // Check both string and int keys - try all possible formats
                        $product_id_str = (string)$product_id;
                        $product_id_int = intval($product_id);
                        if (isset($sub_json[$product_id_str]) || isset($sub_json[$product_id_int])) {
                            $is_in_flash_sale = true;
                        }
                    }
                }
                
                // Also check if product has variants in sub_id (variant IDs comma separated)
                if (!$is_in_flash_sale && !empty($flash_deal['sub_id'])) {
                    // sub_id contains variant_id, so we need to check if product has any variants in this sub_id
                    // For now, if sub_id exists, consider it a potential match
                    // This will be more accurate once we get variant_id from product
                }
                
                if ($is_in_flash_sale) {
                    // Parse sub_product JSON để tìm giá flash sale cho sản phẩm này
                    $flash_price = null;
                    $flash_old_price = null;
                    $flash_stock = null;
                    $variant_id = null;
                    
                    if (!empty($flash_deal['sub_product'])) {
                        $sub_json = json_decode($flash_deal['sub_product'], true);
                        if (json_last_error() === JSON_ERROR_NONE && is_array($sub_json)) {
                            // Check both string and int keys - try all possible formats
                            $product_id_str = (string)$product_id;
                            $product_id_int = intval($product_id);
                            
                            $product_variants = null;
                            if (isset($sub_json[$product_id_str])) {
                                $product_variants = $sub_json[$product_id_str];
                            } elseif (isset($sub_json[$product_id_int])) {
                                $product_variants = $sub_json[$product_id_int];
                            }
                            
                            // Lấy giá đầu tiên (hoặc có thể chọn variant đầu tiên)
                            if (!empty($product_variants) && is_array($product_variants)) {
                                $first_variant = reset($product_variants);
                                $flash_price = isset($first_variant['gia']) ? intval($first_variant['gia']) : null;
                                $flash_old_price = isset($first_variant['gia_cu']) ? intval($first_variant['gia_cu']) : null;
                                $flash_stock = isset($first_variant['so_luong']) ? intval($first_variant['so_luong']) : null;
                                $variant_id = isset($first_variant['variant_id']) ? $first_variant['variant_id'] : null;
                            }
                        }
                    }
                    
                    // Nếu không tìm thấy trong sub_product, check main_product
                    if ($flash_price === null) {
                        // Sử dụng giá hiện tại của sản phẩm
                        $flash_price = $gia_moi_main;
                        $flash_old_price = $gia_cu_main;
                    }
                    
                    // Tính thời gian còn lại
                    $time_remaining = $flash_deal['date_end'] - $current_time;
                    
                    $flash_sale_info = array(
                        'is_flash_sale' => true,
                        'deal_id' => $flash_deal['id'],
                        'flash_price' => $flash_price,
                        'flash_old_price' => $flash_old_price,
                        'flash_stock' => $flash_stock,
                        'variant_id' => $variant_id,
                        'date_start' => $flash_deal['date_start'],
                        'date_end' => $flash_deal['date_end'],
                        'time_remaining' => $time_remaining,
                        'time_remaining_formatted' => gmdate('H:i:s', $time_remaining)
                    );
                    
                    // Update giá hiển thị nếu có flash sale
                    if ($flash_price !== null && $flash_price < $gia_moi_main) {
                        $product['gia_moi'] = $flash_price;
                        $product['gia_moi_formatted'] = number_format($flash_price);
                        $discount_percent = ($flash_old_price > $flash_price && $flash_old_price > 0) ? 
                                           ceil((($flash_old_price - $flash_price) / $flash_old_price) * 100) : 0;
                        $product['discount_percent'] = $discount_percent;
                        
                        $gia_cu_main = $flash_old_price;
                        $product['gia_cu_formatted'] = number_format($gia_cu_main);
                    }
                    
                    break; // Found matching flash sale, exit loop
                }
            }
        }
        
        if ($flash_sale_info === null) {
            $flash_sale_info = array('is_flash_sale' => false);
        }
        
        $product['flash_sale_info'] = $flash_sale_info;
        
        // Tạo URL sản phẩm
        $product['product_url'] = 'https://socdo.vn/san-pham/' . $product['id'] . '/' . $product['link'] . '.html';
        
        // Xử lý voucher và freeship icons
        $deal_shop = $product['shop'];
        $voucher_icon = '';
        $freeship_icon = '';
        $coupon_info = array();
        
        if ($deal_shop) {
            // Check voucher cho sản phẩm cụ thể
            $check_coupon = mysqli_query($conn, "SELECT id, ma, loai, giam, mo_ta FROM coupon WHERE FIND_IN_SET('$product_id', sanpham) AND shop = '$deal_shop' AND '$current_time' BETWEEN start AND expired LIMIT 1");
            if (mysqli_num_rows($check_coupon) > 0) {
                $voucher_data = mysqli_fetch_assoc($check_coupon);
                $voucher_icon = 'Voucher';
                $coupon_info = array(
                    'has_coupon' => true,
                    'coupon_code' => $voucher_data['ma'],
                    'coupon_type' => $voucher_data['loai'],
                    'coupon_discount' => $voucher_data['giam'],
                    'coupon_description' => $voucher_data['mo_ta'],
                    'coupon_details' => 'Mã: ' . $voucher_data['ma'] . ($voucher_data['loai'] == 'tru' ? ' - Giảm ' . number_format($voucher_data['giam']) . 'đ' : ' - Giảm ' . $voucher_data['giam'] . '%')
                );
            } else {
                // Check voucher cho toàn shop
                $check_coupon_all = mysqli_query($conn, "SELECT id, ma, loai, giam, mo_ta FROM coupon WHERE shop = '$deal_shop' AND kieu = 'all' AND '$current_time' BETWEEN start AND expired LIMIT 1");
                if (mysqli_num_rows($check_coupon_all) > 0) {
                    $voucher_data = mysqli_fetch_assoc($check_coupon_all);
                    $voucher_icon = 'Voucher';
                    $coupon_info = array(
                        'has_coupon' => true,
                        'coupon_code' => $voucher_data['ma'],
                        'coupon_type' => $voucher_data['loai'],
                        'coupon_discount' => $voucher_data['giam'],
                        'coupon_description' => $voucher_data['mo_ta'],
                        'coupon_details' => 'Mã shop: ' . $voucher_data['ma'] . ($voucher_data['loai'] == 'tru' ? ' - Giảm ' . number_format($voucher_data['giam']) . 'đ' : ' - Giảm ' . $voucher_data['giam'] . '%')
                    );
                } else {
                    $coupon_info = array(
                        'has_coupon' => false,
                        'coupon_code' => '',
                        'coupon_type' => '',
                        'coupon_discount' => 0,
                        'coupon_description' => '',
                        'coupon_details' => ''
                    );
                }
            }
            
            // Check freeship
            $check_freeship = mysqli_query($conn, "SELECT id FROM transport WHERE user_id = '$deal_shop' AND (free_ship_all = 1 OR free_ship_discount > 0) LIMIT 1");
            if (mysqli_num_rows($check_freeship) > 0) {
                $freeship_icon = 'Freeship';
            }
        }
        
        $product['coupon_info'] = $coupon_info;
        
        // Lấy thông tin shop từ bảng user_info
        $shop_info = array();
        if ($deal_shop) {
            $shop_query = "SELECT user_id, username, name, avatar, dia_chi, email, mobile FROM user_info WHERE user_id = '$deal_shop' LIMIT 1";
            $shop_result = mysqli_query($conn, $shop_query);
            if ($shop_result && mysqli_num_rows($shop_result) > 0) {
                $shop_data = mysqli_fetch_assoc($shop_result);
                
                // Đếm tổng số sản phẩm của shop
                $product_count_query = "SELECT COUNT(*) as total FROM sanpham WHERE shop = '$deal_shop' AND status = 1 AND kho > 0 AND active = 0";
                $product_count_result = mysqli_query($conn, $product_count_query);
                $product_count = 0;
                if ($product_count_result) {
                    $count_row = mysqli_fetch_assoc($product_count_result);
                    $product_count = intval($count_row['total']);
                }
                
                $shop_info = array(
                    'shop_id' => intval($shop_data['user_id']),
                    'shop_name' => $shop_data['name'],
                    'shop_username' => $shop_data['username'],
                    'shop_email' => $shop_data['email'],
                    'shop_mobile' => $shop_data['mobile'],
                    'shop_address' => $shop_data['dia_chi'],
                    'shop_avatar' => !empty($shop_data['avatar']) ? 'https://socdo.vn/' . $shop_data['avatar'] : '',
                    'shop_url' => 'https://socdo.vn/shop/' . $shop_data['username'],
                    'total_products' => $product_count
                );
            }
        }
        $product['shop_info'] = $shop_info;
        
        // Thêm badges
        $badges = array();
        if ($product['box_banchay'] == 1) $badges[] = 'Bán chạy';
        if ($product['box_noibat'] == 1) $badges[] = 'Nổi bật';
        if ($product['box_flash'] == 1) $badges[] = 'Flash sale';
        if ($discount_percent > 0) $badges[] = "-$discount_percent%";
        if (!empty($voucher_icon)) $badges[] = $voucher_icon;
        if (!empty($freeship_icon)) $badges[] = $freeship_icon;
        $badges[] = 'Chính hãng';
        
        $product['badges'] = $badges;
        $product['voucher_icon'] = $voucher_icon;
        $product['freeship_icon'] = $freeship_icon;
        $product['chinhhang_icon'] = 'Chính hãng';
        
        // Rating và reviews
        $product['total_reviews'] = $product['total_reviews'] > 0 ? $product['total_reviews'] : rand(3, 99);
        $product['avg_rating'] = $product['avg_rating'] > 0 ? round($product['avg_rating'], 1) : rand(40, 50) / 10;
        $product['sold_count'] = $product['ban'] + rand(10, 100);
        
        // Star HTML
        $avg_rating = $product['avg_rating'];
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
        $product['star_html'] = $star_html;
        
        // Label sale
        if ($discount_percent > 0) {
            $product['label_sale'] = '<div class="label_product"><div class="label_wrapper">-' . $discount_percent . '%</div></div>';
        } else {
            $product['label_sale'] = '';
        }
        
        // Price for members
        if ($is_member) {
            $product['price_thanhvien'] = '<span class="price-thanhvien"><i class="fa fa-user"></i>' . $product['gia_ctv_formatted'] . '₫</span>';
        } else {
            $product['price_thanhvien'] = '';
        }
        
        // Kiểm tra user đã yêu thích sản phẩm này chưa (đã được JOIN trong query chính)
        $is_favorited = ($user_id > 0) ? (intval($product['is_favorited']) === 1) : false;
        $product['is_favorited'] = $is_favorited;
        
        // Lấy danh sách phân loại sản phẩm từ bảng phanloai_sanpham - CHỈ lấy phân loại còn hàng
        $variants_query = "SELECT * FROM phanloai_sanpham WHERE sp_id = '$product_id' AND kho_sanpham_socdo > 0 ORDER BY gia_moi ASC";
        $variants_result = mysqli_query($conn, $variants_query);
        $variants = array();
        
        // Debug: Log số lượng variants
        $variants_count = $variants_result ? mysqli_num_rows($variants_result) : 0;
        error_log("Product $product_id has $variants_count variants");
        
        if ($variants_result && mysqli_num_rows($variants_result) > 0) {
            while ($variant = mysqli_fetch_assoc($variants_result)) {
                // Format giá tiền
                $variant['gia_cu_formatted'] = number_format($variant['gia_cu']);
                $variant['gia_moi_formatted'] = number_format($variant['gia_moi']);
                $variant['gia_ctv_formatted'] = number_format($variant['gia_ctv']);
                $variant['gia_drop_formatted'] = number_format($variant['gia_drop']);
                
                // Thêm field stock để app hiển thị
                $variant['stock'] = intval($variant['kho_sanpham_socdo']);
                
                // Tính phần trăm giảm giá
                $variant_discount = ($variant['gia_cu'] > $variant['gia_moi'] && $variant['gia_cu'] > 0) ? 
                                   ceil((($variant['gia_cu'] - $variant['gia_moi']) / $variant['gia_cu']) * 100) : 0;
                $variant['discount_percent'] = $variant_discount;
                
                // Xử lý hình ảnh biến thể
                if (!empty($variant['image_phanloai']) && file_exists($variant['image_phanloai'])) {
                    $variant['image_url'] = 'https://socdo.vn/' . $variant['image_phanloai'];
                } else {
                    $variant['image_url'] = $images['main']; // Fallback về ảnh chính
                }
                
                // Tạo tên biến thể
                $variant_name_parts = array();
                if (!empty($variant['ten_color'])) {
                    $variant_name_parts[] = $variant['ten_color'];
                }
                if (!empty($variant['ten_size'])) {
                    $variant_name_parts[] = $variant['ten_size'];
                }
                $variant['variant_name'] = !empty($variant_name_parts) ? implode(' - ', $variant_name_parts) : 'Mặc định';
                
                // Thông tin thuộc tính
                $variant['attributes'] = array();
                if (!empty($variant['color'])) {
                    $variant['attributes']['color'] = $variant['color'];
                }
                if (!empty($variant['size'])) {
                    $variant['attributes']['size'] = $variant['size'];
                }
                if (!empty($variant['ma_mau'])) {
                    $variant['attributes']['ma_mau'] = $variant['ma_mau'];
                }
                
                $variants[] = $variant;
            }
        }
        $product['variants'] = $variants;
        
        // Lấy danh mục sản phẩm
        $categories = array();
        if (!empty($product['cat'])) {
            $cat_ids = explode(',', $product['cat']);
            foreach ($cat_ids as $cat_id) {
                $cat_id = intval(trim($cat_id));
                if ($cat_id > 0) {
                    $cat_query = "SELECT cat_id, cat_tieude, cat_link FROM category_sanpham WHERE cat_id = $cat_id LIMIT 1";
                    $cat_result = mysqli_query($conn, $cat_query);
                    if ($cat_result && mysqli_num_rows($cat_result) > 0) {
                        $category = mysqli_fetch_assoc($cat_result);
                        $category['category_url'] = 'https://socdo.vn/danh-muc/' . $category['cat_id'] . '/' . $category['cat_link'] . '.html';
                        $categories[] = $category;
                    }
                }
            }
        }
        $product['categories'] = $categories;
        
        // Cập nhật lượt xem
        $view_update = "UPDATE sanpham SET view = view + 1 WHERE id = $product_id";
        mysqli_query($conn, $view_update);
        $product['view'] = $product['view'] + 1;
        
        // Đảm bảo trả về cột 'anh' để Flutter có thể sử dụng
        $response = [
            "success" => true,
            "message" => "Lấy thông tin sản phẩm thành công",
            "data" => $product
        ];
        
        // Debug: Log response để kiểm tra
        error_log("DEBUG: Product ID $product_id - Final response anh field: " . $product['anh']);
        
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

