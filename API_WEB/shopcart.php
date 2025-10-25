<?php
session_start();

$web = $_SERVER['HTTP_HOST'];
$web = str_replace('www.', '', $web);
$web_root = ['congmuasam.com', 'vuvo.socdo.vn', 'winvu.vn', 'hoinhau.com', 'socdo.vn', 'winvu.vn', 'socmoi.vn', 'soc.vn', 'viettel.socdo.vn', 'beta.vn', 'vuvo.socdo.vn', 'winvu.vn', 'hoinhau.com', 'tongkho.vn'];
if (!in_array($web, $web_root)) {
    include('./shop/shopcart.php');
    exit();
}
// Load core system classes.
include('./includes/tlca_world.php');
$check = $tlca_do->load('class_check');
$class_index = $tlca_do->load('class_index');
$class_ghn = $tlca_do->load('class_ghn');
$class_ghtk = $tlca_do->load('class_ghtk');
$class_superai = $tlca_do->load('class_superai');
// Parse URL query parameters.
$param_url = parse_url($_SERVER['REQUEST_URI']);
parse_str($param_url['query'] ?? '', $url_query);

// Handle pagination page number.
$page = intval($url_query['page'] ?? 1);
$page = max(1, $page);
$title_page = ($page > 1) ? ' - Page ' . $page : '';

// Get sort parameter (if any).
$sort = addslashes($url_query['sort'] ?? '');

// Fetch global site settings.
$setting_result = mysqli_query($conn, "SELECT * FROM index_setting ORDER BY name ASC");
$index_setting = [];
if ($setting_result) {
    while ($r_s = mysqli_fetch_assoc($setting_result)) {
        $index_setting[$r_s['name']] = $r_s['value'];
    }
}

// User login status and related information.
$user_id = 0;
$user_info = [];
$box_header = $skin->skin_normal('skin/box_header');
$mobile_menu = $skin->skin_normal('skin/mobile_menu');

if (isset($_COOKIE['user_id'])) {
    $class_member = $tlca_do->load('class_member');
    $tach_token = json_decode($check->token_login_decode($_COOKIE['user_id']), true);
    $user_id = $tach_token['user_id'] ?? 0;
    $user_info = $class_member->user_info($conn, $_COOKIE['user_id']);
    $box_header = $skin->skin_normal('skin/box_header_login');
    $mobile_menu = $skin->skin_normal('skin/mobile_menu_login');
    $_SESSION['user_id'] = $user_id; // Store user ID in session for later use.
    $is_logged_in = 1;
}

// Common template data.
$list_danhmuc_top = json_decode($class_index->list_category_danhmuc_top($conn), true);
$tach_menu = json_decode($class_index->list_menu($conn), true);
$tach_banner = json_decode($class_index->list_banner($conn), true);
$tach_list_category = json_decode($class_index->list_category($conn), true);
$link_xem = (isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on' ? "https" : "http") . "://$_SERVER[HTTP_HOST]$_SERVER[REQUEST_URI]";

// Last removed item for potential "undo" feature.
$last_removed_sp_id = $_SESSION['last_removed']['sp_id'] ?? null;
$last_removed_pl = $_SESSION['last_removed']['pl'] ?? null;

// NHATUPDATE25/09/2025: Thêm function tính giá cuối cùng với voucher và ship (từ view.php)
function calculateFinalPrice($original_price, $sp_id, $shop_id, $conn, $hientai, $user_id = 0)
{
    $final_price = (float)$original_price;
    $coupon_discount = 0;
    $ship_discount = 0;
    $coupon_info = null;
    $ship_info = null;

    // NHATUPDATE25/09/2025: Cải thiện logic tìm coupon tốt nhất (dựa trên checkout.php)
    $best_coupon = null;
    $best_discount = 0;
    $coupon_selected_type = 'none';

    // Tìm tất cả coupon có thể áp dụng cho sản phẩm này
    $coupon_query = "SELECT * FROM coupon 
        WHERE ((shop = '{$shop_id}' AND status = '2') OR (shop = '0' AND status = '2'))
        AND '{$hientai}' >= start 
        AND '{$hientai}' <= expired 
        ORDER BY giam DESC, giam_toi_da DESC";

    $coupon_result = mysqli_query($conn, $coupon_query);
    while ($coupon = mysqli_fetch_assoc($coupon_result)) {
        $valid_coupon = true;
        $applicable_subtotal = 0;

        // NHATUPDATE25/09/2025: Tính subtotal áp dụng dựa trên kiểu coupon
        if ($coupon['kieu'] == 'sanpham' && !empty($coupon['sanpham'])) {
            // Chỉ áp dụng cho sản phẩm cụ thể
            $coupon_sp_ids = array_map('trim', explode(',', $coupon['sanpham']));
            if (!in_array($sp_id, $coupon_sp_ids)) {
                $valid_coupon = false;
            } else {
                $applicable_subtotal = $original_price;
            }
        } else {
            // Áp dụng cho toàn bộ đơn hàng
            $applicable_subtotal = $original_price;
        }

        // NHATUPDATE25/09/2025: Kiểm tra các điều kiện áp dụng (từ checkout.php)
        if ($valid_coupon && ($coupon['min_price'] ?? 0) > 0 && $applicable_subtotal < $coupon['min_price']) {
            $valid_coupon = false;
        }
        if ($valid_coupon && ($coupon['max_price'] ?? 0) > 0 && $applicable_subtotal > $coupon['max_price']) {
            $valid_coupon = false;
        }
        if ($valid_coupon && ($coupon['max_global_uses'] ?? 0) > 0 && ($coupon['current_uses'] ?? 0) >= $coupon['max_global_uses']) {
            $valid_coupon = false;
        }
        if ($valid_coupon && $user_id && ($coupon['max_uses_per_user'] ?? 0) > 0) {
            $used_count_query = mysqli_query($conn, "SELECT COUNT(*) AS count FROM donhang WHERE user_id='$user_id' AND coupon='{$coupon['ma']}'");
            $used_count_row = mysqli_fetch_assoc($used_count_query);
            if (($used_count_row['count'] ?? 0) >= $coupon['max_uses_per_user']) {
                $valid_coupon = false;
            }
        }

        // NHATUPDATE25/09/2025: Tính giảm giá nếu coupon hợp lệ
        if ($valid_coupon && $applicable_subtotal > 0) {
            $discount_value = ($coupon['loai'] == 'phantram')
                ? ceil(($applicable_subtotal / 100) * min($coupon['giam'], 100))
                : $coupon['giam'];

            // Áp dụng giới hạn giảm tối đa
            if (($coupon['giam_toi_da'] ?? 0) > 0 && $discount_value > $coupon['giam_toi_da']) {
                $discount_value = $coupon['giam_toi_da'];
            }

            // So sánh với coupon tốt nhất hiện tại
            if ($discount_value > $best_discount) {
                $best_discount = $discount_value;
                $best_coupon = $coupon;
                $coupon_selected_type = $coupon['kieu'];
            }
        }
    }

    // NHATUPDATE25/09/2025: Áp dụng coupon tốt nhất
    if ($best_coupon) {
        $coupon_info = $best_coupon;
        $coupon_discount = $best_discount;
    }

    // NHATUPDATE26/09/2025: Xử lý ship discount - cải thiện logic dựa trên view.php
    $transport_query = mysqli_query($conn, "SELECT free_ship_all, free_ship_min_order, free_ship_discount, fee_ship_products FROM transport 
        WHERE user_id = '{$shop_id}' AND is_default = '1' 
        LIMIT 1");

    if ($transport_query && $transport_row = mysqli_fetch_assoc($transport_query)) {
        $free_ship_all = $transport_row['free_ship_all'] ?? 0;
        $free_ship_min_order = $transport_row['free_ship_min_order'] ?? 0;
        $free_ship_discount = $transport_row['free_ship_discount'] ?? 0;
        $fee_ship_products = $transport_row['fee_ship_products'] ?? '';

        // NHATUPDATE26/09/2025: Xử lý theo các trường hợp free_ship_all như view.php
        if ($free_ship_all == 0) {
            // free_ship_all = 0: Hỗ trợ phí ship theo số tiền cố định (cần kiểm tra min_order)
            if ($original_price >= $free_ship_min_order && $free_ship_discount > 0) {
                $ship_discount = (float)$free_ship_discount;
                $ship_info = [
                    'ship_type' => 'vnd',
                    'ship_support' => $free_ship_discount,
                    'free_ship_all' => 0
                ];
            }
        } elseif ($free_ship_all == 1) {
            // NHATUPDATE26/09/2025: free_ship_all = 1: Miễn phí ship cho toàn bộ đơn hàng
            // Trong giỏ hàng, không tính phí ship vì đây không phải trang checkout
            $ship_discount = 0; // Không giảm giá sản phẩm, chỉ miễn phí ship khi checkout
            $ship_info = [
                'ship_type' => 'freeship',
                'ship_support' => 0,
                'free_ship_all' => 1,
                'is_freeship' => true
            ];
        } elseif ($free_ship_all == 2) {
            // free_ship_all = 2: Hỗ trợ phí ship theo % của đơn hàng (cần kiểm tra min_order)
            if ($original_price >= $free_ship_min_order && $free_ship_discount > 0) {
                $ship_discount = ($original_price * (float)$free_ship_discount) / 100;
                $ship_info = [
                    'ship_type' => 'percent',
                    'ship_support' => $free_ship_discount,
                    'free_ship_all' => 2
                ];
            }
        } elseif ($free_ship_all == 3 && !empty($fee_ship_products)) {
            // free_ship_all = 3: Hỗ trợ phí ship theo sản phẩm cụ thể
            $fee_ship_products_array = json_decode($fee_ship_products, true);

            if (is_array($fee_ship_products_array)) {
                foreach ($fee_ship_products_array as $ship_item) {
                    if (isset($ship_item['sp_id']) && $ship_item['sp_id'] == $sp_id) {
                        $ship_info = $ship_item;

                        if (isset($ship_item['ship_type']) && isset($ship_item['ship_support'])) {
                            if ($ship_item['ship_type'] == 'vnd') {
                                $ship_discount = (float)$ship_item['ship_support'];
                            } elseif ($ship_item['ship_type'] == 'percent') {
                                $ship_discount = ($original_price * (float)$ship_item['ship_support']) / 100;
                            }
                        }
                        break;
                    }
                }
            }
        }
    }

    $final_price = max(0, $original_price - $coupon_discount - $ship_discount);
    $total_discount = $coupon_discount + $ship_discount;

    return [
        'final_price' => $final_price,
        'coupon_discount' => $coupon_discount,
        'ship_discount' => $ship_discount,
        'total_discount' => $total_discount,
        'coupon_info' => $coupon_info,
        'ship_info' => $ship_info,
        'coupon_selected_type' => $coupon_selected_type
    ];
}


if (empty($_SESSION['cart'])) {
    // --- Logic for Empty Cart (Display Flash Sale products) ---
    $thongbao = "Giỏ hàng trống.";
    $box_daxem_empty = '';
    $box_daxem_normal = '';

    if (isset($_SESSION['daxem'])) {
        $list_id = implode(",", array_unique($_SESSION['daxem']));
        $list_daxem = $class_index->list_sanpham_daxem($conn, $list_id, 10);
        $tt['list_daxem'] = $list_daxem;
        $box_daxem_empty = $skin->skin_replace('skin/box_li/box_daxem_cart_emty', $tt);
        $box_daxem_normal = $skin->skin_replace('skin/box_li/box_daxem', $tt);
    }

    // Flash Sale Data for Empty Cart Page
    $hientai = time();
    $now_flashsale = new DateTime('now', new DateTimeZone('Asia/Ho_Chi_Minh'));
    $hour = (int) $now_flashsale->format('H');
    $minute = (int) $now_flashsale->format('i');
    $second = (int) $now_flashsale->format('s');
    $ngay = (int) $now_flashsale->format('d');
    $thang = (int) $now_flashsale->format('m');
    $nam = (int) $now_flashsale->format('Y');

    $time_00 = mktime(8, 59, 59, $thang, $ngay, $nam);
    $time_09 = mktime(15, 59, 59, $thang, $ngay, $nam);
    $time_16 = mktime(23, 59, 59, $thang, $ngay, $nam);

    if ($hour >= 0 && $hour < 9) {
        $active_00 = 'active';
        $active_09 = '';
        $active_16 = '';
        $text_00 = 'Đang diễn ra';
        $text_09 = 'Sắp diễn ra';
        $text_16 = 'Sắp diễn ra';
        $time_start = $time_00 - $hientai;
        $timeline = "00:00";
    } elseif ($hour >= 9 && $hour < 16) {
        $active_00 = '';
        $active_09 = 'active';
        $active_16 = '';
        $text_00 = 'Đã hết hạn';
        $text_09 = 'Đang diễn ra';
        $text_16 = 'Sắp diễn ra';
        $time_start = $time_09 - $hientai;
        $timeline = "09:00";
    } else {
        $active_00 = '';
        $active_09 = '';
        $active_16 = 'active';
        $text_00 = 'Đã hết hạn';
        $text_09 = 'Đã hết hạn';
        $text_16 = 'Đang diễn ra';
        $time_start = $time_16 - $hientai;
        $timeline = "16:00";
    }

    $thongtin_deal = mysqli_query($conn, "SELECT * FROM deal WHERE date_start <= '$hientai' AND date_end >= '$hientai' AND status = 2 AND timeline IS NOT NULL AND timeline ='$timeline' ORDER BY id DESC");
    $total_deal = mysqli_num_rows($thongtin_deal);
    $list_flashsale_id = '';
    $list_muakem_id = '';
    $list_tang_id = '';
    $list_check_product = [];
    $list_c = [];

    while ($r_d = mysqli_fetch_assoc($thongtin_deal)) {
        if ($r_d['loai'] == 'flash_sale') {
            $list_flashsale_id .= $r_d['main_product'] . ',';
            $tach_m = explode(',', $r_d['main_product']);
            $tach_s = json_decode($r_d['sub_product'], true);

            foreach ($tach_m as $value) {
                $max_gia_cu = null;
                $min_gia = null;
                if (isset($tach_s[$value]) && is_array($tach_s[$value])) {
                    foreach ($tach_s[$value] as $variant) {
                        if (isset($variant['gia_cu'])) {
                            $gia_cu = (int) str_replace(',', '', $variant['gia_cu']);
                            $max_gia_cu = $max_gia_cu === null || $gia_cu > $max_gia_cu ? $gia_cu : $max_gia_cu;
                        }
                        if (isset($variant['gia'])) {
                            $gia = (int) str_replace(',', '', $variant['gia']);
                            $min_gia = $min_gia === null || $gia < $min_gia ? $gia : $min_gia;
                        }
                    }
                }
                if (!isset($list_check_product[$value])) {
                    $list_check_product[$value][] = [
                        'gia_cu_max' => $max_gia_cu,
                        'gia' => $min_gia,
                        'expired' => $r_d['date_end']
                    ];
                }
            }
        } elseif ($r_d['loai'] == 'muakem') {
            $list_muakem_id .= $r_d['main_product'] . ',';
        } elseif ($r_d['loai'] == 'tang') {
            $list_tang_id .= $r_d['main_product'] . ',';
        }
    }

    foreach ($list_check_product as $product_id => $deals) {
        $latest_deal = null;
        foreach ($deals as $deal) {
            if (isset($deal['expired']) && $deal['expired'] > $hientai && (!$latest_deal || $deal['expired'] > $latest_deal['expired'])) {
                $latest_deal = $deal;
            }
        }
        if ($latest_deal) {
            $list_c[$product_id] = $latest_deal;
        }
    }

    $list_muakem_id = rtrim($list_muakem_id, ',');
    $list_flashsale_id = rtrim($list_flashsale_id, ',');
    $list_tang_id = rtrim($list_tang_id, ',');

    $hientai = time();
    $hour = (int) date('H');
    $ngay = (int) date('d');
    $thang = (int) date('m');
    $nam = (int) date('Y');
    $limit = 10;
    $offset = ($page - 1) * $limit;

    // Xác định slot flash sale hiện tại
    if ($hour >= 0 && $hour < 9) {
        $time_start = mktime(0, 0, 0, $thang, $ngay, $nam);
        $time_end = mktime(9, 59, 59, $thang, $ngay, $nam);
    } elseif ($hour >= 9 && $hour < 16) {
        $time_start = mktime(9, 0, 0, $thang, $ngay, $nam);
        $time_end = mktime(16, 0, 0, $thang, $ngay, $nam);
    } else {
        $time_start = mktime(16, 0, 0, $thang, $ngay, $nam);
        $time_end = mktime(23, 59, 59, $thang, $ngay, $nam);
    }


    $flash_sale_data = $class_index->list_sanpham_flash_sale($conn, $list_muakem_id, $list_tang_id, $list_flashsale_id, $list_c, $time_start, $time_end, $offset, $limit);
    $tach_list = json_decode($flash_sale_data, true);

    $total_page = ceil($total_deal / 10);
    $phantrang = $class_index->phantrang_sanpham($page, $total_page, '/flash-sale.html');

    $banner_page_result = $class_index->list_banner_page($conn, 'banner_flash_sale');
    $thongtin_tieude = mysqli_query($conn, "SELECT * FROM banner WHERE link='/flash-sale.html' ORDER BY thu_tu ASC LIMIT 1");
    $r_tieude = mysqli_fetch_assoc($thongtin_tieude);
    if (isset($user_info['avatar']) && !empty($user_info['avatar'])) {
        $display_avatar_img = "style='display: inline-block;'";
        $display_avatar_icon = "style='display: none;'";
    } else {
        $display_avatar_img = "style='display: none;'";
        $display_avatar_icon = "style='display: inline-block;'";
    }
    $replace = array(
        'header' => $skin->skin_normal('skin/header'),
        'box_header' => $box_header,
        'title' => 'Giỏ hàng',
        'thongbao' => $thongbao,
        'footer' => $skin->skin_normal('skin/footer'),
        'script_footer' => $skin->skin_normal('skin/script_footer'),
        'mobile_menu' => $mobile_menu,
        'box_deal' => $skin->skin_normal('skin/box_deal_shopcart_emty'),
        'description' => $index_setting['description'] ?? '',
        'site_name' => $index_setting['site_name'] ?? '',
        'limit' => 10,
        'logo' => $index_setting['logo'] ?? '',
        'list_danhmuc_noibat_timkiem' => $class_index->list_category_noibat_timkiem($conn) ?? '',
        'text_footer' => $index_setting['text_footer'] ?? '',
        'text_contact_footer' => $index_setting['text_contact_footer'] ?? '',
        'text_about' => $index_setting['text_about'] ?? '',
        'link_xem' => $link_xem,
        'link_facebook' => $index_setting['link_facebook'] ?? '',
        'link_youtube' => $index_setting['link_youtube'] ?? '',
        'link_twitter' => $index_setting['link_twitter'] ?? '',
        'link_instagram' => $index_setting['link_instagram'] ?? '',
        'text_hotline' => $index_setting['text_hotline'] ?? '',
        'hotline' => $index_setting['hotline'] ?? '',
        'hotline_number' => preg_replace('/[^0-9]/', '', $index_setting['hotline'] ?? ''),
        'menu_chinhsach' => $tach_menu['chinhsach'] ?? '',
        'menu_huongdan' => $tach_menu['huongdan'] ?? '',
        'menu_left' => $tach_menu['left'] ?? '',
        'list_category' => $tach_list_category['list'] ?? '',
        'list_category_top' => $tach_list_category['list_top'] ?? '',
        'list_category_mobile' => $tach_list_category['list_mobile'] ?? '',
        'lienhe' => $index_setting['lienhe'] ?? '',
        'photo' => $index_setting['photo'] ?? '',
        'phantrang' => $phantrang,
        'name' => $user_info['name'] ?? '',
        'avatar' => $user_info['avatar'] ?? '',
        'display_avatar_img' => $display_avatar_img,
        'display_avatar_icon' => $display_avatar_icon,
        'fanpage' => $index_setting['fanpage'] ?? '',
        'gioithieu' => $index_setting['gioithieu'] ?? '',
        'banner_top' => $tach_banner['top'] ?? '',
        'list_danhmuc' => $list_danhmuc_top['list_parent'] ?? '',
        'list_danhmuc_sub' => $list_danhmuc_top['list_sub'] ?? '',
        'box_daxem' => $box_daxem_empty,
        'link_contact' => $index_setting['link_contact'] ?? '',
        'banner_bottom_slide' => $tach_banner['bottom_slide'] ?? '',
        'banner_sanpham_banchay' => $tach_banner['sanpham_banchay'] ?? '',
        'banner_sanpham_noibat' => $tach_banner['sanpham_noibat'] ?? '',
        'banner_page' => $r_tieude['minh_hoa'] ?? '',
        'tieu_de' => $r_tieude['tieu_de'] ?? 'Flash Sale',
        'list_sieu_sale' => $tach_list['list'] ?? '',
        'dropship' => $user_info['dropship'] ?? '',
        'active_00' => $active_00,
        'active_09' => $active_09,
        'active_16' => $active_16,
        'text_00' => $text_00,
        'text_09' => $text_09,
        'text_16' => $text_16,
        'list_deal' => $tach_list['list'] ?? '',
        'time_start' => $time_start,
        'session_user_id' => $_SESSION['user_id'] ?? 0,
        'is_logged_in' => $is_logged_in,
        'favicon' => $index_setting['favicon'],
        'text_copyright_chantrang' => $index_setting['text_copyright_chantrang'],

    );
    echo $skin->skin_replace('skin/shopcart_emty', $replace);
    exit();
} else {
    $hientai = time();

    $list_sp_id = '';
    $list_pl = '';
    foreach ($_SESSION['cart'] as $key => $value) {
        list($sp_id, $pl) = explode('_', $key);
        $list_sp_id .= $sp_id . ',';
        $list_pl .= $pl . ',';
    }
    $list_sp_id = rtrim($list_sp_id, ',');
    $list_pl = rtrim($list_pl, ',');

    $product_pl = [];
    if ($list_pl) {
        $thongtin_pl = mysqli_query($conn, "SELECT * FROM phanloai_sanpham WHERE id IN ($list_pl)");
        while ($r_pl = mysqli_fetch_assoc($thongtin_pl)) {
            $sp_id_pl = $r_pl['sp_id'] . '_' . $r_pl['id'];
            $product_pl[$sp_id_pl] = $r_pl;
        }
    }

    $tamtinh = 0;
    $total_giam = 0;
    $list_shopcart = '';
    $shops = [];
    $shop_coupons = $_SESSION['shop_coupons'] ?? [];
    $total_sp = '';

    // Simplified - removed address and shipping logic

    $thongtin_cart = mysqli_query($conn, "SELECT * FROM sanpham WHERE id IN ($list_sp_id) ORDER BY FIELD(id, $list_sp_id)");
    while ($r_cart = mysqli_fetch_assoc($thongtin_cart)) {
        $id_sp = $r_cart['id'];
        foreach ($_SESSION['cart'] as $key => $value) {
            list($cart_sp_id, $cart_pl) = explode('_', $key);
            if ($cart_sp_id == $id_sp) {
                $shop_id = $r_cart['shop'];
                $query = "SELECT name FROM user_info WHERE user_id = '$shop_id'";
                $result = mysqli_query($conn, $query);
                if ($result && mysqli_num_rows($result) > 0) {
                    $row_name = mysqli_fetch_assoc($result);
                    $shop_name = $row_name['name'];
                } else {
                    $shop_name = "Sàn TMĐT";
                }

                // Simplified - removed shipping logic

                $pl_key = $id_sp . '_' . $cart_pl;
                $r_cart['ten_sanpham'] = $r_cart['tieu_de'];

                // NHATUPDATE25/09/2025: Tính giá cuối cùng với voucher và ship
                $price_calculation = calculateFinalPrice($value['gia_moi'], $cart_sp_id, $shop_id, $conn, $hientai, $user_id);
                $gia_cuoi_cung = $price_calculation['final_price'];
                $coupon_discount = $price_calculation['coupon_discount'];
                $ship_discount = $price_calculation['ship_discount'];
                $total_discount = $price_calculation['total_discount'];
                $coupon_info = $price_calculation['coupon_info'];
                $ship_info = $price_calculation['ship_info'];

                // NHATUPDATE26/09/2025: Xử lý logic hiển thị giá - cải thiện như view.php
                $has_coupon = ($coupon_info && $coupon_discount > 0);
                $has_ship = ($ship_info && ($ship_discount > 0 || $ship_info['free_ship_all'] == 1));
                $has_discount = ($has_coupon || $has_ship);

                // NHATUPDATE25/09/2025: Chuẩn bị text/style hiển thị giá cho template
                $r_cart['gia_moi'] = number_format($value['gia_moi'], 0, ',', '.');
                $r_cart['gia_cu'] = number_format($value['gia_cu'], 0, ',', '.');
                $r_cart['gia_cuoi_cung'] = number_format($gia_cuoi_cung, 0, ',', '.');
                $r_cart['quantity'] = $value['quantity'];

                // NHATUPDATE25/09/2025: Quyết định hiển thị theo trạng thái giảm giá
                if ($has_discount) {
                    $r_cart['current_price_style'] = 'style="display: none;"';
                    $r_cart['current_price_text'] = $r_cart['gia_moi'] . ' ₫';
                    $r_cart['final_price_style'] = 'style="display: block; color: #dc3545; font-weight: bold;"';
                    $r_cart['final_price_text'] = $r_cart['gia_cuoi_cung'] . ' ₫';
                    $r_cart['original_price_style'] = 'style="display: block; text-decoration: line-through; color: #666; font-size: 12px;"';
                    $r_cart['original_price_text'] = $r_cart['gia_moi'] . ' ₫';
                } else {
                    $r_cart['current_price_style'] = '';
                    $r_cart['current_price_text'] = $r_cart['gia_moi'] . ' ₫';
                    $r_cart['final_price_style'] = 'style="display: none;"';
                    $r_cart['final_price_text'] = '';
                    $r_cart['original_price_style'] = 'style="display: none;"';
                    $r_cart['original_price_text'] = '';
                }

                // Tính thành tiền dựa trên giá cuối cùng
                $thanhtien_cuoi_cung = $gia_cuoi_cung * $value['quantity'];
                $r_cart['thanhtien'] = number_format($thanhtien_cuoi_cung, 0, ',', '.') . ' ₫';
                $r_cart['thanhtien_goc'] = number_format($value['gia_moi'] * $value['quantity'], 0, ',', '.') . ' ₫';

                // NHATUPDATE25/09/2025: Hiển thị thành tiền theo trạng thái giảm
                if ($has_discount) {
                    $r_cart['total_final_style'] = 'style="display: block; color: #dc3545; font-weight: bold;"';
                    $r_cart['total_final_text'] = $r_cart['thanhtien'];
                    $r_cart['total_original_style'] = 'style="display: block; text-decoration: line-through; color: #666; font-size: 12px;"';
                    $r_cart['total_original_text'] = $r_cart['thanhtien_goc'];
                    $r_cart['total_normal_style'] = 'style="display: none;"';
                    $r_cart['total_normal_text'] = '';
                } else {
                    $r_cart['total_final_style'] = 'style="display: none;"';
                    $r_cart['total_final_text'] = '';
                    $r_cart['total_original_style'] = 'style="display: none;"';
                    $r_cart['total_original_text'] = '';
                    $r_cart['total_normal_style'] = 'style="display: block;"';
                    $r_cart['total_normal_text'] = $r_cart['thanhtien'];
                }

                // Cộng vào tổng tiền dựa trên giá cuối cùng
                $tamtinh += $thanhtien_cuoi_cung;
                $r_cart['sp_id'] = $cart_sp_id;
                $r_cart['pl'] = $cart_pl;
                $r_cart['shop'] = $value['shop'];
                $r_cart['total_sp_shop'] = $thanhtien_cuoi_cung;
                $r_cart['minh_hoa'] = !empty($r_cart['minh_hoa']) ? $r_cart['minh_hoa'] : '/images/no-image.jpg';
                // Set is_active status for checkbox
                $r_cart['is_active'] = isset($value['is_active']) && $value['is_active'] ? 'checked' : '';

                // NHATUPDATE25/09/2025: Truyền số liệu phục vụ tính tổng trên client
                $r_cart['row_unit_final_price'] = $gia_cuoi_cung; // number
                $r_cart['row_total_amount'] = $thanhtien_cuoi_cung; // number

                // NHATUPDATE25/09/2025: Thêm thông tin discount (chỉ truyền string, không truyền array)
                $r_cart['has_discount'] = $has_discount ? 'true' : 'false';
                $r_cart['has_coupon'] = $has_coupon ? 'true' : 'false';
                $r_cart['has_ship'] = $has_ship ? 'true' : 'false';
                $r_cart['coupon_discount'] = number_format($coupon_discount, 0, ',', '.');
                $r_cart['ship_discount'] = number_format($ship_discount, 0, ',', '.');
                $r_cart['total_discount'] = number_format($total_discount, 0, ',', '.');
                $r_cart['coupon_ma'] = $coupon_info ? $coupon_info['ma'] : '';
                $r_cart['coupon_kieu'] = $coupon_info ? $coupon_info['kieu'] : '';
                $attribute_display = '';
                $sql_attr = "SELECT
                                av_color.value_name AS color_value,
                                attr_color.attribute_name AS color_name,
                                av_size.value_name AS size_value,
                                attr_size.attribute_name AS size_name,
                                pls.ten_color,
                                pls.ten_size
                            FROM phanloai_sanpham pls
                            LEFT JOIN attribute_values av_color ON pls.color = av_color.id
                            LEFT JOIN attributes attr_color ON av_color.attribute_id = attr_color.id
                            LEFT JOIN attribute_values av_size ON pls.size = av_size.id
                            LEFT JOIN attributes attr_size ON av_size.attribute_id = attr_size.id
                            WHERE pls.id = '$cart_pl' LIMIT 1";
                $res_attr = mysqli_query($conn, $sql_attr);
                if ($row_attr = mysqli_fetch_assoc($res_attr)) {
                    $color_name = $row_attr['color_name'] ?? 'Màu';
                    $color_value = $row_attr['color_value'] ?: ($row_attr['ten_color'] ?? '');
                    $size_name = $row_attr['size_name'] ?? 'Kích thước';
                    $size_value = $row_attr['size_value'] ?: ($row_attr['ten_size'] ?? '');

                    if ($color_value) {
                        $attribute_display .= '<span class="cart-attribute">' . htmlspecialchars($color_name) . ': <b>' . htmlspecialchars($color_value) . '</b></span> ';
                    }
                    if ($size_value && $size_value != '+') {
                        $attribute_display .= '<span class="cart-attribute">' . htmlspecialchars($size_name) . ': <b>' . htmlspecialchars($size_value) . '</b></span>';
                    }
                } else {
                    $color_value = $value['color'] ?? '';
                    $size_value = $value['size'] ?? '';
                    if ($color_value) {
                        $attribute_display .= '<span class="cart-attribute">Màu: <b>' . htmlspecialchars($color_value) . '</b></span> ';
                    }
                    if ($size_value && $size_value != '+') {
                        $attribute_display .= '<span class="cart-attribute">Kích thước: <b>' . htmlspecialchars($size_value) . '</b></span>';
                    }
                }
                $r_cart['attribute_display'] = $attribute_display;

                // NHATUPDATE26/09/2025: Tạo thông tin discount để hiển thị - cải thiện như view.php
                $discount_info = '';
                if ($coupon_info && $coupon_discount > 0) {
                    $coupon_type_text = ($coupon_info['kieu'] == 'sanpham') ? ' (SP)' : ' (Shop)';
                    // $discount_info .= '<span class="discount-badge coupon-badge">🎫 ' . htmlspecialchars($coupon_info['ma']) . $coupon_type_text . ': -' . number_format((float)$coupon_discount, 0, ',', '.') . '₫</span>';
                    $discount_info .= '<span class="discount-badge coupon-badge"> ' . "Ưu đãi sản phẩm" . ': -' . number_format((float)$coupon_discount, 0, ',', '.') . '₫</span>';
                }
                if ($ship_info && ($ship_discount > 0 || $ship_info['free_ship_all'] == 1)) {
                    // NHATUPDATE26/09/2025: Cải thiện hiển thị ship support theo loại
                    $ship_text = '';
                    if ($ship_info['free_ship_all'] == 1) {
                        $ship_text = ' Miễn phí ship';
                    } elseif ($ship_info['free_ship_all'] == 2) {
                        $ship_text = ' Hỗ trợ vận chuyển ' . $ship_info['ship_support'] . '%: -' . number_format((float)$ship_discount, 0, ',', '.') . '₫';
                    } elseif ($ship_info['free_ship_all'] == 3) {
                        $ship_text = ' Hỗ trợ vận chuyển SP: -' . number_format((float)$ship_discount, 0, ',', '.') . '₫';
                    } else {
                        $ship_text = ' Hỗ trợ vận chuyển: -' . number_format((float)$ship_discount, 0, ',', '.') . '₫';
                    }
                    $discount_info .= '<span class="discount-badge ship-badge">' . $ship_text . '</span>';
                }
                $r_cart['discount_info'] = $discount_info;

                if (isset($product_pl[$pl_key])) {
                    $r_cart['ten_color'] = $product_pl[$pl_key]['ten_color']
                        ? '<div class="color_content"><div class="text">' . $product_pl[$pl_key]['ten_color'] . '</div></div>'
                        : '';
                    $r_cart['ten_size'] = $product_pl[$pl_key]['ten_size']
                        ? '<div class="color_content"><div class="text">' . $product_pl[$pl_key]['ten_size'] . '</div></div>'
                        : '';
                } else {
                    $r_cart['ten_color'] = '';
                    $r_cart['ten_size'] = '';
                }

                // Check if product is in flash sale
                $r_cart['flash_sale_badge'] = '';
                $current_time = time();

                // Query to check if this product is in any active flash sale
                $flash_query = "SELECT * FROM deal 
                               WHERE FIND_IN_SET('$id_sp', main_product) > 0 
                               AND date_start <= '$current_time' 
                               AND date_end >= '$current_time' 
                               AND loai = 'flash_sale' 
                               AND status = 2 
                               ORDER BY id DESC LIMIT 1";

                $flash_result = mysqli_query($conn, $flash_query);
                if ($flash_result && mysqli_num_rows($flash_result) > 0) {
                    $flash_deal = mysqli_fetch_assoc($flash_result);
                    $timeline = $flash_deal['timeline'] ?? null;
                    $flash_active = false;

                    // Check timeline like in process.php
                    if ($timeline === '0' || $timeline === null || empty(trim($timeline))) {
                        $flash_active = true;
                    } else {
                        $time_ranges = [
                            '00:00' => ['start' => '00:00', 'end' => '09:00'],
                            '09:00' => ['start' => '09:00', 'end' => '16:00'],
                            '16:00' => ['start' => '16:00', 'end' => '23:59']
                        ];

                        $current_time_format = date('H:i');

                        if (isset($time_ranges[$timeline])) {
                            $start_time = $time_ranges[$timeline]['start'];
                            $end_time = $time_ranges[$timeline]['end'];

                            if ($timeline === '16:00') {
                                if ($current_time_format >= '16:00' || $current_time_format < '09:00') {
                                    $flash_active = true;
                                }
                            } else {
                                if ($current_time_format >= $start_time && $current_time_format < $end_time) {
                                    $flash_active = true;
                                }
                            }
                        }
                    }

                    if ($flash_active) {
                        // Determine end time based on timeline
                        $end_time_text = '';
                        $current_hour = (int) date('H');

                        if ($timeline === '00:00' || ($current_hour >= 0 && $current_hour < 9)) {
                            $end_time_text = '09:00:00';
                        } elseif ($timeline === '09:00' || ($current_hour >= 9 && $current_hour < 16)) {
                            $end_time_text = '16:00:00';
                        } else {
                            $end_time_text = '00:00:00';
                        }

                        $r_cart['flash_sale_badge'] = '<div class="flash-sale-badge">Flash Sale kết thúc lúc ' . $end_time_text . '</div>';
                    }
                }

                // Simplified - removed all shipping calculations

                $shops[$shop_id]['shop_name'] = $shop_name;
                $tamtinh_sanpham = number_format($value['gia_moi'] * $value['quantity'], 0, ',', '.');
                $r_cart['tamtinh_sanpham'] = $tamtinh_sanpham;

                // Add product to shop
                $shops[$shop_id]['products'][] = $skin->skin_replace('skin/box_li/li_shopcart_new', $r_cart);
                // NHATUPDATE25/09/2025: Sử dụng giá cuối cùng để tính subtotal
                $shops[$shop_id]['subtotal'] = ($shops[$shop_id]['subtotal'] ?? 0) + $thanhtien_cuoi_cung;
                $shops[$shop_id]['shop_id'] = $shop_id;
            }
        }
    }

    // Simplified shop processing - removed shipping calculations
    foreach ($shops as $shop_id => &$shop) {
        $shop['giam'] = 0; // No discounts in simplified version

        // Simplified - removed coupon logic

        // Simplified - calculate only shop total without shipping
        $shop['shop_total'] = $shop['subtotal'] ?? 0;

        $shop_html = [
            'shop_name' => $shop['shop_name'],
            'shop_id' => $shop['shop_id'],
            'shop_subtotal' => number_format($shop['subtotal'], 0, ',', '.'),
            'list_products' => implode('', $shop['products']),
            'giam' => '0',
            'shop_total' => number_format($shop['shop_total'], 0, ',', '.') . ' ₫'
        ];
        $list_shopcart .= $skin->skin_replace('skin/box_li/li_shopcart_shop_new', $shop_html);
    }
    $ho_ten = $dien_thoai = $dia_chi = $email = '';
    $tinh = 0;
    $huyen = 0;
    $xa = 0;
    $ten_tinh = $ten_huyen = $ten_xa = '';
    $option_tinh = $class_index->list_option_tinh($conn, 0);
    $option_huyen = $class_index->list_option_huyen($conn, 0, 0);
    $option_xa = $class_index->list_option_xa($conn, 0, 0);

    if ($user_id > 0) {
        $thongtin_diachi = mysqli_query($conn, "SELECT * FROM dia_chi WHERE user_id='$user_id' AND active='1'");
        if (mysqli_num_rows($thongtin_diachi) > 0) {
            $r_dc = mysqli_fetch_assoc($thongtin_diachi);
            $ho_ten = $r_dc['ho_ten'];
            $dia_chi = $r_dc['dia_chi'];
            $dien_thoai = $r_dc['dien_thoai'];
            $email = $r_dc['email'];
            $tinh = $r_dc['tinh'] ?? 0;
            $huyen = $r_dc['huyen'] ?? 0;
            $xa = $r_dc['xa'] ?? 0;
            $ten_tinh = $r_dc['ten_tinh'] ?? '';
            $ten_huyen = $r_dc['ten_huyen'] ?? '';
            $ten_xa = $r_dc['ten_xa'] ?? '';
            $option_tinh = $class_index->list_option_tinh($conn, $tinh);
            $option_huyen = $class_index->list_option_huyen($conn, $tinh, $huyen);
            $option_xa = $class_index->list_option_xa($conn, $huyen, $xa);
        }
    } else {
        // Kiểm tra session address_cus nếu không có user_id
        if (isset($_SESSION['address_cus']) && !empty($_SESSION['address_cus'])) {
            $address_cus = $_SESSION['address_cus'];
            $ho_ten = $address_cus['ho_ten'] ?? '';
            $dia_chi = $address_cus['dia_chi'] ?? '';
            $dien_thoai = $address_cus['dien_thoai'] ?? '';
            $email = $address_cus['email'] ?? '';
            $tinh = $address_cus['tinh'] ?? 0;
            $huyen = $address_cus['huyen'] ?? 0;
            $xa = $address_cus['xa'] ?? 0;
            $ten_tinh = $address_cus['ten_tinh'] ?? '';
            $ten_huyen = $address_cus['ten_huyen'] ?? '';
            $ten_xa = $address_cus['ten_xa'] ?? '';
            $option_tinh = $class_index->list_option_tinh($conn, $tinh);
            $option_huyen = $class_index->list_option_huyen($conn, $tinh, $huyen);
            $option_xa = $class_index->list_option_xa($conn, $huyen, $xa);
        }
    }
    $voucher_button_html = !empty($user_id) ? '' : 'style="display: none;"';
    $voucher_button_html_messge = !empty($user_id) ? 'style="display: none;"' : '';
    $box_show_address = (!empty($user_id) || !empty($_SESSION['address_cus'])) ? 0 : 1;
    // Tạo HTML cho địa chỉ mặc định
    $default_address_html = '';
    if (!empty($ho_ten)) {
        $default_address_html = '
            <div class="checkout-address-name">' . htmlspecialchars($ho_ten) . ' (+84) ' . htmlspecialchars($dien_thoai) . '</div>
            <div class="checkout-address-text">' . htmlspecialchars($dia_chi) . ', ' . htmlspecialchars($ten_xa) . ', ' . htmlspecialchars($ten_huyen) . ', ' . htmlspecialchars($ten_tinh) . '</div>
            <span style="background: #ee4d2d; color: white; padding: 2px 6px; border-radius: 2px; font-size: 10px;">Mặc Định</span>';
    } else {
        $default_address_html = '
            <div class="checkout-address-name">Chưa có địa chỉ mặc định</div>
             <div class="checkout-address-text"><em>Vui lòng thêm địa chỉ nhận hàng để thanh toán</em></div>';
    }

    // Đảm bảo có giá trị mặc định cho form nếu user đã có địa chỉ
    if (empty($ho_ten) && $user_id > 0) {
        $ho_ten = '';
        $dien_thoai = '';
        $dia_chi = '';
        $tinh = 0;
        $huyen = 0;
        $xa = 0;
        $ten_tinh = '';
        $ten_huyen = '';
        $ten_xa = '';
    }
    if ($user_id > 0) {
        $diem_result = mysqli_query($conn, "SELECT diem FROM diem WHERE user_id='$user_id'");
        $diem_row = mysqli_fetch_assoc($diem_result);
        $hatde_conlai = $diem_row['diem'] ?? 0;
    }

    // Flash Sale Data for Empty Cart Page
    $hientai = time();
    $now_flashsale = new DateTime('now', new DateTimeZone('Asia/Ho_Chi_Minh'));
    $hour = (int) $now_flashsale->format('H');
    $minute = (int) $now_flashsale->format('i');
    $second = (int) $now_flashsale->format('s');
    $ngay = (int) $now_flashsale->format('d');
    $thang = (int) $now_flashsale->format('m');
    $nam = (int) $now_flashsale->format('Y');

    $time_00 = mktime(8, 59, 59, $thang, $ngay, $nam);
    $time_09 = mktime(15, 59, 59, $thang, $ngay, $nam);
    $time_16 = mktime(23, 59, 59, $thang, $ngay, $nam);

    if ($hour >= 0 && $hour < 9) {
        $active_00 = 'active';
        $active_09 = '';
        $active_16 = '';
        $text_00 = 'Đang diễn ra';
        $text_09 = 'Sắp diễn ra';
        $text_16 = 'Sắp diễn ra';
        $time_start = $time_00 - $hientai;
        $timeline = "00:00";
    } elseif ($hour >= 9 && $hour < 16) {
        $active_00 = '';
        $active_09 = 'active';
        $active_16 = '';
        $text_00 = 'Đã hết hạn';
        $text_09 = 'Đang diễn ra';
        $text_16 = 'Sắp diễn ra';
        $time_start = $time_09 - $hientai;
        $timeline = "09:00";
    } else {
        $active_00 = '';
        $active_09 = '';
        $active_16 = 'active';
        $text_00 = 'Đã hết hạn';
        $text_09 = 'Đã hết hạn';
        $text_16 = 'Đang diễn ra';
        $time_start = $time_16 - $hientai;
        $timeline = "16:00";
    }

    $thongtin_deal = mysqli_query($conn, "SELECT * FROM deal WHERE date_start <= '$hientai' AND date_end >= '$hientai' AND status = 2 AND timeline IS NOT NULL AND timeline ='$timeline' ORDER BY id DESC");
    $total_deal = mysqli_num_rows($thongtin_deal);
    $list_flashsale_id = '';
    $list_muakem_id = '';
    $list_tang_id = '';
    $list_check_product = [];
    $list_c = [];

    while ($r_d = mysqli_fetch_assoc($thongtin_deal)) {
        if ($r_d['loai'] == 'flash_sale') {
            $list_flashsale_id .= $r_d['main_product'] . ',';
            $tach_m = explode(',', $r_d['main_product']);
            $tach_s = json_decode($r_d['sub_product'], true);

            foreach ($tach_m as $value) {
                $max_gia_cu = null;
                $min_gia = null;
                if (isset($tach_s[$value]) && is_array($tach_s[$value])) {
                    foreach ($tach_s[$value] as $variant) {
                        if (isset($variant['gia_cu'])) {
                            $gia_cu = (int) str_replace(',', '', $variant['gia_cu']);
                            $max_gia_cu = $max_gia_cu === null || $gia_cu > $max_gia_cu ? $gia_cu : $max_gia_cu;
                        }
                        if (isset($variant['gia'])) {
                            $gia = (int) str_replace(',', '', $variant['gia']);
                            $min_gia = $min_gia === null || $gia < $min_gia ? $gia : $min_gia;
                        }
                    }
                }
                if (!isset($list_check_product[$value])) {
                    $list_check_product[$value][] = [
                        'gia_cu_max' => $max_gia_cu,
                        'gia' => $min_gia,
                        'expired' => $r_d['date_end']
                    ];
                }
            }
        } elseif ($r_d['loai'] == 'muakem') {
            $list_muakem_id .= $r_d['main_product'] . ',';
        } elseif ($r_d['loai'] == 'tang') {
            $list_tang_id .= $r_d['main_product'] . ',';
        }
    }

    foreach ($list_check_product as $product_id => $deals) {
        $latest_deal = null;
        foreach ($deals as $deal) {
            if (isset($deal['expired']) && $deal['expired'] > $hientai && (!$latest_deal || $deal['expired'] > $latest_deal['expired'])) {
                $latest_deal = $deal;
            }
        }
        if ($latest_deal) {
            $list_c[$product_id] = $latest_deal;
        }
    }

    $list_muakem_id = rtrim($list_muakem_id, ',');
    $list_flashsale_id = rtrim($list_flashsale_id, ',');
    $list_tang_id = rtrim($list_tang_id, ',');

    $hientai = time();
    $hour = (int) date('H');
    $ngay = (int) date('d');
    $thang = (int) date('m');
    $nam = (int) date('Y');
    $limit = 10;
    $offset = ($page - 1) * $limit;

    // Xác định slot flash sale hiện tại
    if ($hour >= 0 && $hour < 9) {
        $time_start = mktime(0, 0, 0, $thang, $ngay, $nam);
        $time_end = mktime(9, 59, 59, $thang, $ngay, $nam);
    } elseif ($hour >= 9 && $hour < 16) {
        $time_start = mktime(9, 0, 0, $thang, $ngay, $nam);
        $time_end = mktime(16, 0, 0, $thang, $ngay, $nam);
    } else {
        $time_start = mktime(16, 0, 0, $thang, $ngay, $nam);
        $time_end = mktime(23, 59, 59, $thang, $ngay, $nam);
    }
    $banner_page_result = $class_index->list_banner_page($conn, 'banner_flash_sale');
    $thongtin_tieude = mysqli_query($conn, "SELECT * FROM banner WHERE link='/flash-sale.html' ORDER BY thu_tu ASC LIMIT 1");
    $r_tieude = mysqli_fetch_assoc($thongtin_tieude);
    if (isset($user_info['avatar']) && !empty($user_info['avatar'])) {
        $display_avatar_img = "style='display: inline-block;'";
        $display_avatar_icon = "style='display: none;'";
    } else {
        $display_avatar_img = "style='display: none;'";
        $display_avatar_icon = "style='display: inline-block;'";
    }
    $replace = array(
        'header' => $skin->skin_normal('skin/header'),
        'box_header' => $box_header,
        'footer' => $skin->skin_normal('skin/footer'),
        'script_footer' => $skin->skin_normal('skin/script_footer'),
        'mobile_menu' => $mobile_menu,
        'title' => 'Giỏ hàng',
        'description' => $index_setting['description'] ?? '',
        'site_name' => $index_setting['site_name'] ?? '',
        'limit' => 10,
        'logo' => $index_setting['logo'] ?? '',
        'text_footer' => $index_setting['text_footer'] ?? '',
        'text_contact_footer' => $index_setting['text_contact_footer'] ?? '',
        'text_about' => $index_setting['text_about'] ?? '',
        'link_xem' => $link_xem,
        'link_facebook' => $index_setting['link_facebook'] ?? '',
        'link_youtube' => $index_setting['link_youtube'] ?? '',
        'link_twitter' => $index_setting['link_twitter'] ?? '',
        'link_instagram' => $index_setting['link_instagram'] ?? '',
        'text_hotline' => $index_setting['text_hotline'] ?? '',
        'hotline' => $index_setting['hotline'] ?? '',
        'hotline_number' => preg_replace('/[^0-9]/', '', $index_setting['hotline'] ?? ''),
        'menu_chinhsach' => $tach_menu['chinhsach'] ?? '',
        'menu_huongdan' => $tach_menu['huongdan'] ?? '',
        'menu_left' => $tach_menu['left'] ?? '',
        'list_category' => $tach_list_category['list'] ?? '',
        'list_category_top' => $tach_list_category['list_top'] ?? '',
        'list_category_mobile' => $tach_list_category['list_mobile'] ?? '',
        'lienhe' => $index_setting['lienhe'] ?? '',
        'photo' => $index_setting['photo'] ?? '',
        'list_danhmuc_noibat_timkiem' => $class_index->list_category_noibat_timkiem($conn) ?? '',
        'list_danhmuc' => $list_danhmuc_top['list_parent'] ?? '',
        'phantrang' => '',
        'fanpage' => $index_setting['fanpage'] ?? '',
        'name' => $user_info['name'] ?? '',
        'avatar' => $user_info['avatar'] ?? '',
        'display_avatar_img' => $display_avatar_img,
        'display_avatar_icon' => $display_avatar_icon,
        'gioithieu' => $index_setting['gioithieu'] ?? '',
        'list_shopcart' => $list_shopcart,
        'list_shopcart_mobile' => $list_shopcart,
        'total_cart' => count($_SESSION['cart']),
        'tamtinh' => number_format($tamtinh, 0, ',', '.'),
        'total_phi_ship' => '0 ₫',
        'ship_support_display' => '0 ₫',
        'hat_de' => '0',
        'hatde_conlai' => '0',
        'giam' => '0',
        'san_coupon_code' => '',
        'san_coupon_display' => '0',
        // NHATUPDATE25/09/2025: Thêm thông tin discount cho template
        'has_discount' => 'false',
        'discount_info' => '',
        'banner_top' => $tach_banner['top'] ?? '',
        'ho_ten' => $ho_ten,
        'dia_chi' => $dia_chi,
        'dien_thoai' => $dien_thoai,
        'email' => $email,
        'option_tinh' => $option_tinh,
        'option_huyen' => $option_huyen,
        'option_xa' => $option_xa,
        'last_removed_sp_id' => $last_removed_sp_id,
        'last_removed_pl' => $last_removed_pl,
        'tinh' => $user_info['tinh'] ?? '',
        'huyen' => $user_info['huyen'] ?? '',
        'voucher_button_html' => '',
        'voucher_button_html_messge' => '',
        'is_logged_in' => $is_logged_in,
        'ten_tinh' => $ten_tinh,
        'ten_huyen' => $ten_huyen,
        'ten_xa' => $ten_xa,
        'default_address_html' => '',
        'active_00' => $active_00,
        'active_09' => $active_09,
        'active_16' => $active_16,
        'text_00' => $text_00,
        'text_09' => $text_09,
        'text_16' => $text_16,
        'list_deal' => $tach_list['list'] ?? '',
        'time_start' => $time_start,
        'box_show_address' => 1,
        'favicon' => $index_setting['favicon'],
        'banner_page' => $r_tieude['minh_hoa'] ?? '',
        'tieu_de' => $r_tieude['tieu_de'] ?? 'Flash Sale',
        'text_copyright_chantrang' => $index_setting['text_copyright_chantrang'],

    );
    echo $skin->skin_replace('skin/shopcart', $replace);
}
