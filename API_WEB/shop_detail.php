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
        $shop_id = isset($_GET['shop_id']) ? intval($_GET['shop_id']) : 0;
        $username = isset($_GET['username']) ? trim($_GET['username']) : '';
        $include_products = isset($_GET['include_products']) ? intval($_GET['include_products']) : 1;
        $include_flash_sale = isset($_GET['include_flash_sale']) ? intval($_GET['include_flash_sale']) : 1;
        $include_vouchers = isset($_GET['include_vouchers']) ? intval($_GET['include_vouchers']) : 1;
        $include_warehouses = isset($_GET['include_warehouses']) ? intval($_GET['include_warehouses']) : 1;
        $include_categories = isset($_GET['include_categories']) ? intval($_GET['include_categories']) : 1;
        $products_limit = isset($_GET['products_limit']) ? intval($_GET['products_limit']) : 20;
        
        // Validate parameters
        if ($shop_id <= 0 && empty($username)) {
            http_response_code(400);
            echo json_encode([
                "success" => false,
                "message" => "Phải cung cấp shop_id hoặc username"
            ]);
            exit;
        }
        
        if ($products_limit < 1 || $products_limit > 100) $products_limit = 20;
        
        $current_time = time();
        
        // Lấy shop_id từ username nếu cần
        if ($shop_id <= 0 && !empty($username)) {
            $username_query = "SELECT user_id FROM user_info WHERE username = '" . mysqli_real_escape_string($conn, $username) . "' AND ctv = '1' LIMIT 1";
            $username_result = mysqli_query($conn, $username_query);
            
            if (!$username_result || mysqli_num_rows($username_result) == 0) {
                http_response_code(404);
                echo json_encode([
                    "success" => false,
                    "message" => "Không tìm thấy shop với username: " . $username
                ]);
                exit;
            }
            
            $username_data = mysqli_fetch_assoc($username_result);
            $shop_id = intval($username_data['user_id']);
        }
        
        // Lấy thông tin cơ bản shop
        $shop_query = "SELECT user_id, shop, username, name, avatar, email, mobile, dia_chi, about, 
                              ctv, dropship, leader, created, date_update, ip_address, logined, end_online
                       FROM user_info 
                       WHERE user_id = '$shop_id' LIMIT 1";
        $shop_result = mysqli_query($conn, $shop_query);
        
        if (!$shop_result || mysqli_num_rows($shop_result) == 0) {
            http_response_code(404);
            echo json_encode([
                "success" => false,
                "message" => "Không tìm thấy shop"
            ]);
            exit;
        }
        
        $shop_data = mysqli_fetch_assoc($shop_result);
        
        // Format thông tin shop cơ bản
        $shop_info = array();
        $shop_info['shop_id'] = intval($shop_data['user_id']);
        $shop_info['parent_shop_id'] = intval($shop_data['shop']);
        $shop_info['username'] = $shop_data['username'];
        $shop_info['name'] = $shop_data['name'];
        $shop_info['email'] = $shop_data['email'];
        $shop_info['mobile'] = $shop_data['mobile'];
        $shop_info['address'] = $shop_data['dia_chi'];
        $shop_info['about'] = $shop_data['about'];
        $shop_info['avatar_url'] = !empty($shop_data['avatar']) ? 'https://socdo.vn/' . $shop_data['avatar'] : '';
        $shop_info['shop_url'] = 'https://socdo.vn/shop/' . $shop_data['username'];
        
        // Thông tin vai trò
        $shop_info['is_ctv'] = intval($shop_data['ctv']);
        $shop_info['is_dropship'] = intval($shop_data['dropship']);
        $shop_info['is_leader'] = intval($shop_data['leader']);
        
        // Thông tin thời gian
        $shop_info['created_at'] = intval($shop_data['created']);
        $shop_info['created_at_formatted'] = date('d/m/Y H:i:s', $shop_data['created']);
        $shop_info['updated_at'] = intval($shop_data['date_update']);
        $shop_info['last_login'] = intval($shop_data['logined']);
        $shop_info['last_online'] = intval($shop_data['end_online']);
        
        // Đếm tổng số sản phẩm
        $product_count_query = "SELECT COUNT(*) as total FROM sanpham WHERE shop = '$shop_id' AND status = 1";
        $product_count_result = mysqli_query($conn, $product_count_query);
        $product_count = 0;
        if ($product_count_result) {
            $count_row = mysqli_fetch_assoc($product_count_result);
            $product_count = intval($count_row['total']);
        }
        $shop_info['total_products'] = $product_count;
        
        // Lấy sản phẩm shop
        $products = array();
        if ($include_products) {
            $products_query = "SELECT s.id, s.ma_sanpham, s.tieu_de, s.minh_hoa, s.link, s.cat, s.gia_cu, s.gia_moi, s.gia_ctv,
                                     s.thuong_hieu, s.kho, s.ban, s.view, s.box_banchay, s.box_noibat, s.box_flash, 
                                     s.date_post, s.status, s.chinhhang, s.free_ship_all, s.free_ship_min_order, s.free_ship_discount,
                                     t.ten_kho as warehouse_name, tm.tieu_de as province_name
                              FROM sanpham s
                              LEFT JOIN transport t ON s.kho_id = t.id AND t.user_id = s.shop
                              LEFT JOIN tinh_moi tm ON t.province = tm.id
                              WHERE s.shop = '$shop_id' AND s.status = 1
                              GROUP BY s.id
                              ORDER BY s.date_post DESC
                              LIMIT $products_limit";
            
            $products_result = mysqli_query($conn, $products_query);
            
            if ($products_result) {
                while ($product = mysqli_fetch_assoc($products_result)) {
                    $product_data = array();
                    $product_data['id'] = intval($product['id']);
                    $product_data['name'] = $product['tieu_de'];
                    $product_data['slug'] = $product['link'];
                    $product_data['price'] = intval($product['gia_moi']);
                    $product_data['old_price'] = intval($product['gia_cu']);
                    $product_data['ctv_price'] = intval($product['gia_ctv']);
                    $product_data['discount_percent'] = 0;
                    
                    // Tính % giảm giá
                    if ($product['gia_cu'] > 0 && $product['gia_moi'] < $product['gia_cu']) {
                        $product_data['discount_percent'] = round((($product['gia_cu'] - $product['gia_moi']) / $product['gia_cu']) * 100);
                    }
                    
                    $product_data['category_ids'] = explode(',', $product['cat']);
                    $product_data['category_ids'] = array_filter(array_map('intval', $product_data['category_ids']));
                    $product_data['brand_id'] = intval($product['thuong_hieu']);
                    $product_data['stock'] = intval($product['kho']);
                    $product_data['sold'] = intval($product['ban']);
                    $product_data['views'] = intval($product['view']);
                    
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
                    
                    // Logic voucher
                    $voucher_icon = '';
                    $id_sp = $product_data['id'];
                    $deal_shop = $shop_id;
                    
                    // Check voucher sản phẩm cụ thể
                    $check_coupon = mysqli_query($conn, "SELECT id FROM coupon WHERE FIND_IN_SET('$id_sp', sanpham) AND shop = '$deal_shop' AND kieu = 'sanpham' AND status = '2' AND '$current_time' BETWEEN start AND expired LIMIT 1");
                    if (mysqli_num_rows($check_coupon) > 0) {
                        $voucher_icon = 'Voucher';
                    } else {
                        // Check voucher shop
                        $check_coupon_all = mysqli_query($conn, "SELECT id FROM coupon WHERE shop = '$deal_shop' AND kieu = 'all' AND status = '2' AND '$current_time' BETWEEN start AND expired LIMIT 1");
                        if (mysqli_num_rows($check_coupon_all) > 0) {
                            $voucher_icon = 'Voucher';
                        }
                    }
                    
                    // Logic freeship chi tiết với 4 mode
                    $freeship_icon = '';
                    $mode = intval($product['free_ship_all'] ?? 0);
                    $discount = intval($product['free_ship_discount'] ?? 0);
                    $minOrder = intval($product['free_ship_min_order'] ?? 0);
                    $base_price = $product_data['price'];
                    
                    if ($mode === 1) {
                        $freeship_icon = 'Freeship 100%';
                    } elseif ($mode === 0 && $discount > 0 && $base_price >= $minOrder) {
                        $freeship_icon = 'Giảm ' . number_format($discount) . 'đ';
                    } elseif ($mode === 2 && $discount > 0 && $base_price >= $minOrder) {
                        $freeship_icon = 'Giảm ' . $discount . '%';
                    } elseif ($mode === 3) {
                        $freeship_icon = 'Ưu đãi ship';
                    } elseif ($mode === 0 && $discount == 0) {
                        $freeship_icon = 'Freeship';
                    }
                    
                    // Logic chính hãng
                    $chinhhang_icon = '';
                    if ($product['chinhhang'] == 1) {
                        $chinhhang_icon = 'Chính hãng';
                    }
                    
                    // Thông tin kho
                    $warehouse_name = $product['warehouse_name'] ?? '';
                    $province_name = $product['province_name'] ?? '';
                    
                    // Badges
                    $badges = array();
                    if ($product['box_banchay'] == 1) $badges[] = 'Bán chạy';
                    if ($product['box_noibat'] == 1) $badges[] = 'Nổi bật';
                    if ($product['box_flash'] == 1) $badges[] = 'Flash sale';
                    if ($product_data['discount_percent'] > 0) $badges[] = 'Giảm ' . $product_data['discount_percent'] . '%';
                    $product_data['badges'] = $badges;
                    
                    // Thêm các icon mới
                    $product_data['voucher_icon'] = $voucher_icon;
                    $product_data['freeship_icon'] = $freeship_icon;
                    $product_data['chinhhang_icon'] = $chinhhang_icon;
                    $product_data['warehouse_name'] = $warehouse_name;
                    $product_data['province_name'] = $province_name;
                    
                    // Thông tin bổ sung
                    $product_data['is_bestseller'] = intval($product['box_banchay']);
                    $product_data['is_featured'] = intval($product['box_noibat']);
                    $product_data['is_flash_sale'] = intval($product['box_flash']);
                    $product_data['created_at'] = intval($product['date_post']);
                    
                    // Format giá
                    $product_data['price_formatted'] = number_format($product_data['price'], 0, ',', '.') . ' ₫';
                    $product_data['old_price_formatted'] = $product_data['old_price'] > 0 ? number_format($product_data['old_price'], 0, ',', '.') . ' ₫' : '';
                    $product_data['ctv_price_formatted'] = number_format($product_data['ctv_price'], 0, ',', '.') . ' ₫';
                    
                    $products[] = $product_data;
                }
            }
        }
        
        // Lấy flash sale shop
        $flash_sales = array();
        if ($include_flash_sale) {
            $flash_sale_query = "SELECT id, tieu_de, main_product, sub_product, date_start, date_end, 
                                        loai, date_post, status, timeline
                                 FROM deal 
                                 WHERE shop = '$shop_id' AND loai = 'flash_sale' 
                                 AND '$current_time' BETWEEN date_start AND date_end
                                 ORDER BY date_post DESC";
            
            $flash_sale_result = mysqli_query($conn, $flash_sale_query);
            
            if ($flash_sale_result) {
                while ($flash_sale = mysqli_fetch_assoc($flash_sale_result)) {
                    $flash_sale_data = array();
                    $flash_sale_data['id'] = intval($flash_sale['id']);
                    $flash_sale_data['title'] = $flash_sale['tieu_de'];
                    $flash_sale_data['main_products'] = explode(',', $flash_sale['main_product']);
                    $flash_sale_data['main_products'] = array_filter(array_map('intval', $flash_sale_data['main_products']));
                    $flash_sale_data['sub_products'] = json_decode($flash_sale['sub_product'], true);
                    $flash_sale_data['start_time'] = intval($flash_sale['date_start']);
                    $flash_sale_data['end_time'] = intval($flash_sale['date_end']);
                    $flash_sale_data['timeline'] = $flash_sale['timeline'];
                    $flash_sale_data['created_at'] = intval($flash_sale['date_post']);
                    
                    // Tính thời gian còn lại
                    $time_left = $flash_sale_data['end_time'] - $current_time;
                    $flash_sale_data['time_left'] = max(0, $time_left);
                    $flash_sale_data['is_active'] = $time_left > 0 ? true : false;
                    
                    $flash_sales[] = $flash_sale_data;
                }
            }
        }
        
        // Lấy voucher shop
        $vouchers = array();
        if ($include_vouchers) {
            $voucher_query = "SELECT id, ma, giam, giam_toi_da, loai, kieu, sanpham, dieu_kien,
                                     start, expired, status, mota, img_loai, min_price, max_price,
                                     allow_combination, max_uses_per_user, max_global_uses, 
                                     current_uses, date_post
                              FROM coupon 
                              WHERE shop = '$shop_id' AND status = '2'
                              AND '$current_time' BETWEEN start AND expired
                              ORDER BY date_post DESC";
            
            $voucher_result = mysqli_query($conn, $voucher_query);
            
            if ($voucher_result) {
                while ($voucher = mysqli_fetch_assoc($voucher_result)) {
                    $voucher_data = array();
                    $voucher_data['id'] = intval($voucher['id']);
                    $voucher_data['code'] = $voucher['ma'];
                    $voucher_data['discount_value'] = intval($voucher['giam']);
                    $voucher_data['max_discount'] = intval($voucher['giam_toi_da']);
                    $voucher_data['discount_type'] = $voucher['loai']; // 'phantram' hoặc 'tru'
                    $voucher_data['apply_type'] = $voucher['kieu']; // 'all' hoặc 'sanpham'
                    $voucher_data['product_ids'] = explode(',', $voucher['sanpham']);
                    $voucher_data['product_ids'] = array_filter(array_map('intval', $voucher_data['product_ids']));
                    $voucher_data['min_order_value'] = intval($voucher['dieu_kien']);
                    $voucher_data['start_time'] = intval($voucher['start']);
                    $voucher_data['end_time'] = intval($voucher['expired']);
                    $voucher_data['description'] = $voucher['mota'];
                    $voucher_data['image_url'] = !empty($voucher['img_loai']) ? 'https://socdo.vn/' . $voucher['img_loai'] : '';
                    $voucher_data['min_price'] = intval($voucher['min_price']);
                    $voucher_data['max_price'] = intval($voucher['max_price']);
                    $voucher_data['allow_combination'] = intval($voucher['allow_combination']);
                    $voucher_data['max_uses_per_user'] = intval($voucher['max_uses_per_user']);
                    $voucher_data['max_global_uses'] = intval($voucher['max_global_uses']);
                    $voucher_data['current_uses'] = intval($voucher['current_uses']);
                    $voucher_data['created_at'] = intval($voucher['date_post']);
                    
                    // Tính thời gian còn lại
                    $time_left = $voucher_data['end_time'] - $current_time;
                    $voucher_data['time_left'] = max(0, $time_left);
                    $voucher_data['is_active'] = $time_left > 0 ? true : false;
                    
                    // Format mô tả giảm giá
                    if ($voucher_data['discount_type'] == 'phantram') {
                        $voucher_data['discount_description'] = 'Giảm ' . $voucher_data['discount_value'] . '%';
                        if ($voucher_data['max_discount'] > 0) {
                            $voucher_data['discount_description'] .= ' (tối đa ' . number_format($voucher_data['max_discount']) . 'đ)';
                        }
                    } else {
                        $voucher_data['discount_description'] = 'Giảm ' . number_format($voucher_data['discount_value']) . 'đ';
                    }
                    
                    $vouchers[] = $voucher_data;
                }
            }
        }
        
        // Lấy địa chỉ kho
        $warehouses = array();
        if ($include_warehouses) {
            $warehouse_query = "SELECT t.id, t.ma_kho, t.ten_kho, t.username, t.fullname, t.mobile,
                                       t.province, t.district, t.ward, t.address_detail, t.is_default,
                                       t.is_pickup, t.is_return, t.latitude, t.longitude,
                                       t.free_ship_all, t.free_ship_min_order, t.free_ship_discount,
                                       tm.tieu_de as province_name,
                                       hm.tieu_de as district_name,
                                       xm.tieu_de as ward_name
                                FROM transport t
                                LEFT JOIN tinh_moi tm ON t.province = tm.id
                                LEFT JOIN huyen_moi hm ON t.district = hm.id
                                LEFT JOIN xa_moi xm ON t.ward = xm.id
                                WHERE t.user_id = '$shop_id'
                                ORDER BY t.is_default DESC, t.id ASC";
            
            $warehouse_result = mysqli_query($conn, $warehouse_query);
            
            if ($warehouse_result) {
                while ($warehouse = mysqli_fetch_assoc($warehouse_result)) {
                    $warehouse_data = array();
                    $warehouse_data['id'] = intval($warehouse['id']);
                    $warehouse_data['warehouse_code'] = $warehouse['ma_kho'];
                    $warehouse_data['warehouse_name'] = $warehouse['ten_kho'];
                    $warehouse_data['contact_name'] = $warehouse['fullname'];
                    $warehouse_data['contact_phone'] = $warehouse['mobile'];
                    $warehouse_data['is_default'] = intval($warehouse['is_default']);
                    $warehouse_data['is_pickup'] = intval($warehouse['is_pickup']);
                    $warehouse_data['is_return'] = intval($warehouse['is_return']);
                    $warehouse_data['latitude'] = floatval($warehouse['latitude']);
                    $warehouse_data['longitude'] = floatval($warehouse['longitude']);
                    
                    // Địa chỉ
                    $warehouse_data['address_detail'] = $warehouse['address_detail'];
                    $warehouse_data['province_id'] = intval($warehouse['province']);
                    $warehouse_data['district_id'] = intval($warehouse['district']);
                    $warehouse_data['ward_id'] = intval($warehouse['ward']);
                    $warehouse_data['province_name'] = $warehouse['province_name'];
                    $warehouse_data['district_name'] = $warehouse['district_name'];
                    $warehouse_data['ward_name'] = $warehouse['ward_name'];
                    
                    // Tạo địa chỉ đầy đủ
                    $full_address = $warehouse['address_detail'];
                    if (!empty($warehouse['ward_name'])) $full_address .= ', ' . $warehouse['ward_name'];
                    if (!empty($warehouse['district_name'])) $full_address .= ', ' . $warehouse['district_name'];
                    if (!empty($warehouse['province_name'])) $full_address .= ', ' . $warehouse['province_name'];
                    $warehouse_data['full_address'] = $full_address;
                    
                    // Thông tin freeship
                    $warehouse_data['free_ship_mode'] = intval($warehouse['free_ship_all']);
                    $warehouse_data['free_ship_min_order'] = intval($warehouse['free_ship_min_order']);
                    $warehouse_data['free_ship_discount'] = intval($warehouse['free_ship_discount']);
                    
                    // Mô tả freeship
                    $freeship_description = '';
                    if ($warehouse['free_ship_all'] == 0 && $warehouse['free_ship_discount'] > 0) {
                        $freeship_description = 'Giảm ' . number_format($warehouse['free_ship_discount']) . 'đ ship';
                    } elseif ($warehouse['free_ship_all'] == 1) {
                        $freeship_description = 'Freeship 100%';
                    } elseif ($warehouse['free_ship_all'] == 2 && $warehouse['free_ship_discount'] > 0) {
                        $freeship_description = 'Giảm ' . $warehouse['free_ship_discount'] . '% ship';
                    } elseif ($warehouse['free_ship_all'] == 3) {
                        $freeship_description = 'Ưu đãi ship theo sản phẩm';
                    }
                    $warehouse_data['freeship_description'] = $freeship_description;
                    
                    $warehouses[] = $warehouse_data;
                }
            }
        }
        
        // Lấy danh mục sản phẩm shop
        $categories = array();
        if ($include_categories) {
            $category_query = "SELECT cs.cat_id, cs.cat_icon, cs.cat_tieude, cs.cat_noidung, 
                                      cs.cat_main, cs.cat_index, cs.cat_link, cs.cat_img, 
                                      cs.cat_img_banner, cs.cat_img_left, cs.cat_title, 
                                      cs.cat_description, cs.cat_thutu, cs.cat_id_socdo,
                                      c.cat_tieude as socdo_cat_name
                               FROM category_sanpham_shop cs
                               LEFT JOIN category_sanpham c ON FIND_IN_SET(c.cat_id, cs.cat_id_socdo) > 0
                               WHERE cs.shop = '$shop_id'
                               ORDER BY cs.cat_thutu ASC";
            
            $category_result = mysqli_query($conn, $category_query);
            
            if ($category_result) {
                while ($category = mysqli_fetch_assoc($category_result)) {
                    $category_data = array();
                    $category_data['id'] = intval($category['cat_id']);
                    $category_data['icon'] = $category['cat_icon'];
                    $category_data['title'] = $category['cat_tieude'];
                    $category_data['description'] = $category['cat_noidung'];
                    $category_data['parent_id'] = intval($category['cat_main']);
                    $category_data['is_index'] = intval($category['cat_index']);
                    $category_data['link'] = $category['cat_link'];
                    $category_data['image'] = !empty($category['cat_img']) ? 'https://socdo.vn/' . $category['cat_img'] : '';
                    $category_data['banner_image'] = !empty($category['cat_img_banner']) ? 'https://socdo.vn/' . $category['cat_img_banner'] : '';
                    $category_data['left_image'] = !empty($category['cat_img_left']) ? 'https://socdo.vn/' . $category['cat_img_left'] : '';
                    $category_data['seo_title'] = $category['cat_title'];
                    $category_data['seo_description'] = $category['cat_description'];
                    $category_data['order'] = intval($category['cat_thutu']);
                    $category_data['socdo_category_ids'] = explode(',', $category['cat_id_socdo']);
                    $category_data['socdo_category_ids'] = array_filter(array_map('intval', $category_data['socdo_category_ids']));
                    $category_data['socdo_category_name'] = $category['socdo_cat_name'];
                    
                    // Tạo URL danh mục
                    $category_data['category_url'] = 'https://socdo.vn/shop/' . $shop_data['username'] . '/danh-muc/' . $category_data['id'] . '.html';
                    
                    $categories[] = $category_data;
                }
            }
        }
        
        $response = [
            "success" => true,
            "message" => "Lấy thông tin shop thành công",
            "data" => [
                "shop_info" => $shop_info,
                "products" => $products,
                "flash_sales" => $flash_sales,
                "vouchers" => $vouchers,
                "warehouses" => $warehouses,
                "categories" => $categories,
                "statistics" => [
                    "total_products" => $product_count,
                    "total_flash_sales" => count($flash_sales),
                    "total_vouchers" => count($vouchers),
                    "total_warehouses" => count($warehouses),
                    "total_categories" => count($categories)
                ],
                "parameters" => [
                    "shop_id" => $shop_id,
                    "username" => $username,
                    "include_products" => $include_products,
                    "include_flash_sale" => $include_flash_sale,
                    "include_vouchers" => $include_vouchers,
                    "include_warehouses" => $include_warehouses,
                    "include_categories" => $include_categories,
                    "products_limit" => $products_limit
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
