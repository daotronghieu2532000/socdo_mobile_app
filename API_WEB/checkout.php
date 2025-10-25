<?php
session_start();
$web = $_SERVER['HTTP_HOST'];
$web = str_replace('www.', '', $web);
$web_root = ['tongkho.vn', 'congmuasam.com', 'vuvo.socdo.vn', 'winvu.vn', 'hoinhau.com', 'socdo.vn', 'winvu.vn', 'socmoi.vn', 'soc.vn', 'viettel.socdo.vn', 'beta.vn', 'vuvo.socdo.vn', 'winvu.vn', 'hoinhau.com'];
if (!in_array($web, $web_root)) {
    include('./shop/checkout.php');
    exit();
}
// Load core system classes.
include('./includes/tlca_world.php');
$check = $tlca_do->load('class_check');
$class_index = $tlca_do->load('class_index');
$class_ghn = $tlca_do->load('class_ghn');
$class_ghtk = $tlca_do->load('class_ghtk');
$class_superai = $tlca_do->load('class_superai');
$class_best = $tlca_do->load('class_best');
$class_spx = $tlca_do->load('class_spx');
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
// else {
//     $thongbao = "Bạn chưa có tài khoản, vui lòng đăng nhập để tiếp tục mua hàng...";
//     $replace = array(
//         'title' => 'Bạn chưa có tài khoản, vui lòng đăng nhập để tiếp tục mua hàng...',
//         'description' => $index_setting['description'],
//         'thongbao' => $thongbao,
//         'link_chuyen' => '/dang-nhap.html',
//     );
//     echo $skin->skin_replace('skin_ncc/chuyenhuong', $replace);
//     exit();
// }
// Common template data.
$list_danhmuc_top = json_decode($class_index->list_category_danhmuc_top($conn), true);
$tach_menu = json_decode($class_index->list_menu($conn), true);
$tach_banner = json_decode($class_index->list_banner($conn), true);
$tach_list_category = json_decode($class_index->list_category($conn), true);
$link_xem = (isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on' ? "https" : "http") . "://$_SERVER[HTTP_HOST]$_SERVER[REQUEST_URI]";
// Last removed item for potential "undo" feature.
$last_removed_sp_id = $_SESSION['last_removed']['sp_id'] ?? null;
$last_removed_pl = $_SESSION['last_removed']['pl'] ?? null;
function getCtvProvinceDistrict($conn, $shop_id)
{
    $stmt = mysqli_prepare($conn, "
        SELECT
            transport.province,
            transport.district,
            tinh_moi.tieu_de AS tinh_ten,
            huyen_moi.tieu_de AS huyen_ten,
            xa_moi.tieu_de AS xa_ten,
            transport.free_ship_all,
            transport.free_ship_min_order,
            transport.free_ship_discount,
            transport.fee_ship_products
        FROM transport
        INNER JOIN tinh_moi ON transport.province = tinh_moi.id
        INNER JOIN huyen_moi ON transport.district = huyen_moi.id
        INNER JOIN xa_moi ON transport.ward = xa_moi.id
        WHERE transport.id = ?
    ");
    if (!$stmt) {
        return null;
    }
    mysqli_stmt_bind_param($stmt, "i", $shop_id);
    mysqli_stmt_execute($stmt);
    $result = mysqli_stmt_get_result($stmt);
    $row = mysqli_fetch_assoc($result);
    mysqli_stmt_close($stmt);
    if ($row) {
        return [
            'tinh' => $row['tinh_ten'],
            'huyen' => $row['huyen_ten'],
            'xa' => $row['xa_ten'],
            'free_ship_all' => $row['free_ship_all'],
            'free_ship_min_order' => $row['free_ship_min_order'],
            'free_ship_discount' => $row['free_ship_discount'],
            'fee_ship_products' => $row['fee_ship_products']
        ];
    }
    return null;
}
// hàm lấy id của transport (lấy hỗ trợ tính phí nếu có)
function getIdTransportShop($conn, $shop)
{
    $stmt = mysqli_prepare($conn, "SELECT id FROM transport WHERE user_id = ? AND is_default = 1");
    if (!$stmt) {
        return null;
    }
    mysqli_stmt_bind_param($stmt, "i", $shop);
    mysqli_stmt_execute($stmt);
    mysqli_stmt_bind_result($stmt, $transport_id);
    if (mysqli_stmt_fetch($stmt)) {
        return $transport_id;
    }
    return null;
}
function getShippingProviderCodes($conn, $shop_id)
{
    $sql = "SELECT sp.code 
            FROM shop_shipping_providers ssp
            JOIN shipping_providers sp 
              ON sp.id = ssp.shipping_provider_id
            WHERE ssp.shop_id = ? AND ssp.is_enabled = 1";
    $stmt = mysqli_prepare($conn, $sql);
    mysqli_stmt_bind_param($stmt, "i", $shop_id);
    mysqli_stmt_execute($stmt);
    $result = mysqli_stmt_get_result($stmt);
    $codes = [];
    while ($row = mysqli_fetch_assoc($result)) {
        $codes[] = $row['code'];
    }
    return $codes;
}
function calculateDeliveryTime($sender_province, $receiver_province, $delivery_type = 'standard')
{
    // Tính thời gian giao hàng dự kiến dựa trên khoảng cách và loại dịch vụ
    $base_days = 0;
    $delivery_type_days = 0;
    // Xác định khoảng cách
    if ($sender_province === $receiver_province) {
        // Cùng tỉnh/thành phố
        $base_days = 1;
    } else {
        // Khác tỉnh/thành phố
        $base_days = 3;
    }
    // Xác định loại dịch vụ
    switch ($delivery_type) {
        case 'standard':
            $delivery_type_days = 0; // Không thêm ngày
            break;
        case 'express':
            $delivery_type_days = -1; // Nhanh hơn 1 ngày
            break;
        case 'economy':
            $delivery_type_days = 1; // Chậm hơn 1 ngày
            break;
        default:
            $delivery_type_days = 0;
    }
    $total_days = max(1, $base_days + $delivery_type_days); // Tối thiểu 1 ngày
    // Tính khoảng thời gian giao hàng (từ ngày sớm nhất đến ngày muộn nhất)
    $min_days = max(1, $total_days - 1); // Ngày sớm nhất
    $max_days = $total_days + 1; // Ngày muộn nhất
    $min_date = date('Y-m-d', strtotime("+$min_days days"));
    $max_date = date('Y-m-d', strtotime("+$max_days days"));
    // Format ngày theo định dạng "DD Tháng MM"
    $min_date_formatted = date('j', strtotime($min_date)) . ' Tháng ' . date('n', strtotime($min_date));
    $max_date_formatted = date('j', strtotime($max_date)) . ' Tháng ' . date('n', strtotime($max_date));
    // Tạo text khoảng thời gian
    $delivery_range = "Đảm bảo dự kiến nhận hàng từ $min_date_formatted - $max_date_formatted";
    // Tính ngày giao hàng dự kiến (ngày giữa)
    $delivery_date = date('Y-m-d', strtotime("+$total_days days"));
    $delivery_date_formatted = date('d/m/Y', strtotime($delivery_date));
    return [
        'days' => $total_days,
        'date' => $delivery_date,
        'date_formatted' => $delivery_date_formatted,
        'description' => getDeliveryDescription($total_days),
        'delivery_range' => $delivery_range,
        'min_date' => $min_date,
        'max_date' => $max_date
    ];
}
function getDeliveryDescription($days)
{
    switch ($days) {
        case 1:
            return "Giao hàng trong ngày";
        case 2:
            return "Giao hàng trong 2 ngày";
        case 3:
            return "Giao hàng trong 3 ngày";
        case 4:
            return "Giao hàng trong 4 ngày";
        case 5:
            return "Giao hàng trong 5 ngày";
        default:
            return "Giao hàng trong $days ngày";
    }
}
function get_id_by_tieude($conn, $tieu_de, $loai)
{
    // Xác định bảng và cột
    switch ($loai) {
        case 'tinh':
            $table = 'tinh_moi';
            $id_col = 'id';
            break;
        case 'huyen':
            $table = 'huyen_moi';
            $id_col = 'id';
            break;
        case 'xa':
            $table = 'xa_moi';
            $id_col = 'id';
            break;
        case 'huyen_ghn':
            $table = 'huyen_ghn';
            $id_col = 'id';
            break;
        case 'xa_ghn':
            $table = 'xa_ghn';
            $id_col = 'id_ghn';
            break;
        default:
            return null; // loại không hợp lệ
    }
    // Chuẩn bị query với LIKE
    $stmt = mysqli_prepare($conn, "SELECT $id_col FROM $table WHERE tieu_de LIKE ? LIMIT 1");
    if (!$stmt) {
        return null;
    }
    // Thêm % để tìm kiếm gần đúng
    $keyword = "%" . $tieu_de . "%";
    mysqli_stmt_bind_param($stmt, "s", $keyword);
    mysqli_stmt_execute($stmt);
    mysqli_stmt_bind_result($stmt, $id);
    if ($stmt->fetch()) {
        $stmt->close();
        return $id;
    }
    $stmt->close();
    return null; // không tìm thấy
}

function get_mien_by_province($conn, $province_name)
{
    $stmt = mysqli_prepare($conn, "SELECT mien FROM tinh_moi WHERE tieu_de LIKE ? LIMIT 1");
    if (!$stmt) {
        return 'mien-nam'; // default fallback
    }
    $keyword = "%" . $province_name . "%";
    mysqli_stmt_bind_param($stmt, "s", $keyword);
    mysqli_stmt_execute($stmt);
    mysqli_stmt_bind_result($stmt, $mien);
    if ($stmt->fetch()) {
        $stmt->close();
        return $mien;
    }
    $stmt->close();
    return 'mien-nam'; // default fallback
}
function calculateShippingFee($provider, $sender_province, $sender_district, $receiver_province, $receiver_district, $sender_ward, $receiver_ward, $weight, $amount, $class_ghn, $class_ghtk, $class_superai, $class_best,$class_spx,$index_setting)
{
    global $conn;
    
    // Kiểm tra địa chỉ nhận hàng trước khi tính phí
    if (empty($receiver_province) || empty($receiver_district)) {
        return [
            'fee' => 0,
            'provider' => 'Chưa có địa chỉ',
            'provider_code' => 'NO_ADDRESS'
        ];
    }
    
    $shipping_fee = 0;
    $provider_name = '';
    switch (strtoupper($provider)) {
        // case 'GHN':
        //     $from_district_id = get_id_by_tieude($conn, $sender_district, 'huyen_ghn');
        //     $to_district_id = get_id_by_tieude($conn, $receiver_district, 'huyen_ghn');
        //     $from_ward_code = $sender_ward ? get_id_by_tieude($conn, $sender_ward, 'xa_ghn') : null;
        //     $to_ward_code = $receiver_ward ? get_id_by_tieude($conn, $receiver_ward, 'xa_ghn') : null;
        //     if ($from_district_id && $to_district_id) {
        //         // Prefer existing variables if provided, else optional settings, else null
        //         $ghn_fee_data = array(
        //             "from_district_id" => intval($from_district_id),
        //             "from_ward_code" => ($from_ward_code !== null ? strval($from_ward_code) : null),
        //             "service_type_id" => 2,
        //             "to_district_id" => intval($to_district_id),
        //             "to_ward_code" => ($to_ward_code !== null ? strval($to_ward_code) : null),
        //             "weight" => intval($weight), // gram
        //             "insurance_value" => intval($amount),
        //             "coupon" => null,
        //         );
        //         // Log full request payload for debugging
        //         $ghn_response = $class_ghn->get_shipping_fee($ghn_fee_data);
        //         $ghn_result = json_decode($ghn_response, true);
        //         if (isset($ghn_result['code']) && $ghn_result['code'] == 200 && isset($ghn_result['data']['total'])) {
        //             $shipping_fee = intval($ghn_result['data']['total']);
        //         } else {
        //             $shipping_fee = 0;
        //         }
        //         $provider_name = 'GHN';
        //         break;
        //     }
        case 'GHTK':
            // GHTK sử dụng bảng giá cố định thay vì API
            try {
                // Xác định miền gửi và nhận
                $sender_mien = get_mien_by_province($conn, $sender_province);
                $receiver_mien = get_mien_by_province($conn, $receiver_province);
                
                // Gọi hàm get_tax với các tham số cần thiết
                $ghtk_response = $class_ghtk->get_tax(
                    $weight,              // Cân nặng (gram)
                    $amount,              // Tiền hàng
                    $sender_province,     // Tỉnh gửi
                    $sender_mien,         // Miền gửi
                    $receiver_province,   // Tỉnh nhận
                    $receiver_mien,       // Miền nhận
                    false,                // COD (mặc định false)
                    false                 // Giao lại (mặc định false)
                );
                
                $ghtk_result = json_decode($ghtk_response, true);
                if (isset($ghtk_result['phi_tong']) && $ghtk_result['phi_tong'] > 0) {
                    $shipping_fee = $ghtk_result['phi_tong'];
                } else {
                    $shipping_fee = 0;
                }
            } catch (Exception $e) {
                // Exception - không tính phí ship
                $shipping_fee = 0;
            }
            
            /* OLD GHTK API CODE - COMMENTED FOR REFERENCE
            // GHTK API call - weight phải là gram - sử dụng vận chuyển thường
            $ghtk_data = array(
                "pick_province" => $sender_province,
                "pick_district" => $sender_district,
                "province" => $receiver_province,
                "district" => $receiver_district,
                "address" => "", // Có thể để trống hoặc lấy từ địa chỉ người nhận
                "weight" => $weight, // GHTK yêu cầu weight theo gram
                "value" => $amount,
                "transport" => "road", // Sử dụng đường bộ
                "deliver_option" => "standard", // Vận chuyển thường
                "tags" => [] // Không dùng tag nào để sử dụng dịch vụ cơ bản nhất
            );
            try {
                $ghtk_response = $class_ghtk->ship_fee($ghtk_data, true);
                $ghtk_result = json_decode($ghtk_response, true);
                // Debug log GHTK response
                if (isset($ghtk_result['success']) && $ghtk_result['success'] === true) {
                    $shipping_fee = $ghtk_result['fee']['fee'] ?? 0;
                    // Log chi tiết phí ship từ GHTK
                    $fee_detail = $ghtk_result['fee'] ?? [];
                    // Debug log phí ship sau khi xử lý
                } else {
                    // API lỗi - không tính phí ship
                    $shipping_fee = 0;
                }
            } catch (Exception $e) {
                // Exception - không tính phí ship
                $shipping_fee = 0;
            }
            */
            
            $provider_name = 'GHTK';
            break;
        case 'BEST':
            // BEST sử dụng bảng giá cố định
            try {
                // Xác định miền gửi và nhận
                $sender_mien = get_mien_by_province($conn, $sender_province);
                $receiver_mien = get_mien_by_province($conn, $receiver_province);
                
                // Gọi hàm get_tax với các tham số cần thiết
                $best_response = $class_best->get_tax(
                    $weight,              // Cân nặng (gram)
                    $amount,              // Tiền hàng
                    $sender_province,     // Tỉnh gửi
                    $sender_mien,         // Miền gửi
                    $receiver_province,   // Tỉnh nhận
                    $receiver_mien,       // Miền nhận
                    false,                // COD (mặc định false)
                    false                 // Giao lại (mặc định false)
                );
                
                $best_result = json_decode($best_response, true);
                if (isset($best_result['phi_tong']) && $best_result['phi_tong'] > 0) {
                    $shipping_fee = $best_result['phi_tong'];
                } else {
                    $shipping_fee = 0;
                }
            } catch (Exception $e) {
                // Exception - không tính phí ship
                $shipping_fee = 0;
            }
            
            $provider_name = 'BEST';
            break;
        // case 'SPX':
        //     // SPX sử dụng bảng giá cố định
        //     try {
        //         // Xác định miền gửi và nhận
        //         $sender_mien = get_mien_by_province($conn, $sender_province);
        //         $receiver_mien = get_mien_by_province($conn, $receiver_province);
                
        //         // Gọi hàm get_tax với các tham số cần thiết
        //         $spx_response = $class_spx->get_tax(
        //             $weight,              // Cân nặng (gram)
        //             $amount,              // Tiền hàng
        //             $sender_province,     // Tỉnh gửi
        //             $sender_mien,         // Miền gửi
        //             $receiver_province,   // Tỉnh nhận
        //             $receiver_mien,       // Miền nhận
        //             false,                // COD (mặc định false)
        //             false                 // Giao lại (mặc định false)
        //         );
        //         $spx_result = json_decode($spx_response, true);
        //         if (isset($spx_result['phi_tong']) && $spx_result['phi_tong'] > 0) {
        //             $shipping_fee = $spx_result['phi_tong'];
        //         } else {
        //             $shipping_fee = 0;
        //         }
        //     } catch (Exception $e) {
        //         // Exception - không tính phí ship
        //         $shipping_fee = 0;
        //     }
            
        //     $provider_name = 'SPX-EXPRESS';
        //     break;
        case 'SUPERAI':
		default:
            // SUPERAI API call - weight phải là gram
            $superai_data = array(
                "sender_province" => $sender_province,
                "sender_district" => $sender_district,
                "receiver_province" => $receiver_province,
                "receiver_district" => $receiver_district,
                "weight" => $weight, // SUPERAI yêu cầu weight theo gram
                "value" => $amount
            );
            try {
                $superai_response = $class_superai->get_fee(
                    $sender_province,
                    $sender_district,
                    $receiver_province,
                    $receiver_district,
                    $weight,
                    $amount
                );
                $superai_result = json_decode($superai_response, true);
                // Debug log SUPERAI response
                if (isset($superai_result['error']) && $superai_result['error'] === false && isset($superai_result['data']['services'])) {
                    // Tìm carrier có phí ship thấp nhất
                    $best_service = null;
                    $lowest_total_fee = PHP_INT_MAX;
                    // Danh sách ưu tiên carrier (càng thấp càng ưu tiên)
                    $carrier_priority = [
                        10 => 1,  // SPX Express - ưu tiên cao nhất
                        6  => 2,  // BEST Express
                        3  => 3,  // J&T Express  
                        13 => 4,  // VietNamPost
                        2  => 5,  // GHN
                        4  => 6,  // Viettel Post
                        14 => 7,  // Lazada Express
                        // Ninja Van (carrier_id: 7) đã bị loại bỏ
                    ];
                    foreach ($superai_result['data']['services'] as $service) {
                        // Loại bỏ Ninja Van vì không hoạt động nữa
                        if (isset($service['carrier_id']) && $service['carrier_id'] == 7) {
                            continue;
                        }
                        $total_fee = ($service['shipment_fee'] ?? 0) + ($service['insurance_fee'] ?? 0);
                        $carrier_id = $service['carrier_id'] ?? 0;
                        $current_priority = $carrier_priority[$carrier_id] ?? 999; // 999 = lowest priority for unknown carriers
                        // Chọn service tốt hơn nếu:
                        // 1. Phí thấp hơn, HOẶC
                        // 2. Phí bằng nhau nhưng priority cao hơn (số nhỏ hơn)
                        $should_select = false;
                        if ($total_fee < $lowest_total_fee) {
                            $should_select = true;
                        } elseif ($total_fee == $lowest_total_fee && $best_service) {
                            $best_priority = $carrier_priority[$best_service['carrier_id'] ?? 0] ?? 999;
                            if ($current_priority < $best_priority) {
                                $should_select = true;
                            }
                        }
                        if ($should_select) {
                            $lowest_total_fee = $total_fee;
                            $best_service = $service;
                        }
                    }
                    if ($best_service) {
                        $shipping_fee = $lowest_total_fee;
                        $provider_name = 'SUPERAI (' . ($best_service['carrier_name'] ?? 'Unknown') . ')';
                        // Tạo provider_code với format SUPERAI-carrier_id-carrier_name
                        $carrier_id = $best_service['carrier_id'] ?? 0;
                        $carrier_name = $best_service['carrier_name'] ?? 'Unknown';
                        $provider_code_superai = 'SUPERAI-' . $carrier_id . '-' . $carrier_name;
                        // Log chi tiết carrier được chọn
                        $selected_priority = $carrier_priority[$carrier_id] ?? 999;
                        // Log tất cả các options có sẵn
                    } else {
                        $shipping_fee = 0;
                        $provider_name = 'SUPERAI';
                        $provider_code_superai = 'SUPERAI';
                        // Log khi không tìm được service khả dụng
                    }
                } else {
                    // API lỗi - không tính phí ship
                    $shipping_fee = 0;
                    $provider_name = 'SUPERAI';
                    $provider_code_superai = 'SUPERAI';
                }
            } catch (Exception $e) {
                // Exception - không tính phí ship
                $shipping_fee = 0;
                $provider_name = 'SUPERAI';
                $provider_code_superai = 'SUPERAI';
            }
            break;
    }
    // Debug log kết quả cuối cùng
    // Sử dụng provider_code_superai nếu là SUPERAI, otherwise dùng $provider
    $final_provider_code = (strtoupper($provider) === 'SUPERAI' && isset($provider_code_superai))
        ? $provider_code_superai
        : $provider;
    return [
        'fee' => $shipping_fee,
        'provider' => $provider_name,
        'provider_code' => $final_provider_code
    ];
}
function getBestShippingProvider($shipping_providers, $sender_province, $sender_district, $receiver_province, $receiver_district, $sender_ward, $receiver_ward, $weight, $amount, $class_ghn, $class_ghtk, $class_superai, $class_best,$class_spx,$index_setting)
{
    $best_provider = null;
    $lowest_fee = PHP_INT_MAX;
    $all_providers_data = [];
    // Tính phí cho tất cả providers
    foreach ($shipping_providers as $provider) {
        $shipping_data = calculateShippingFee(
            $provider,
            $sender_province,
            $sender_district,
            $receiver_province,
            $receiver_district,
            $sender_ward,
            $receiver_ward,
            $weight,
            $amount,
            $class_ghn,
            $class_ghtk,
            $class_superai,
            $class_best,
            $class_spx,
            $index_setting
        );
        $all_providers_data[] = $shipping_data;
        // Chỉ chọn provider có phí > 0 và thấp nhất
        if ($shipping_data['fee'] > 0 && $shipping_data['fee'] < $lowest_fee) {
            $lowest_fee = $shipping_data['fee'];
            $best_provider = $shipping_data;
        }
    }
    // Nếu không có provider nào trả về phí > 0, thử fallback GHTK
    if (!$best_provider || $lowest_fee === PHP_INT_MAX) {
        $ghtk_fallback = calculateShippingFee(
            'GHTK',
            $sender_province,
            $sender_district,
            $receiver_province,
            $receiver_district,
            $sender_ward,
            $receiver_ward,
            $weight,
            $amount,
            $class_ghn,
            $class_ghtk,
            $class_superai,
            $class_best,
            $class_spx,
            $index_setting
        );
        if ($ghtk_fallback['fee'] > 0) {
            $best_provider = $ghtk_fallback;
        }
    }
    $result = $best_provider ?: [
        'fee' => 0,
        'provider' => 'Không có',
        'provider_code' => ''
    ];
    // Debug log tất cả providers và provider được chọn
    return $result;
}
$hientai = time();
$list_sp_id = '';
$list_pl = '';
$active_cart = [];
// Chỉ lấy những sản phẩm có is_active = true
foreach ($_SESSION['cart'] as $key => $value) {
    if (isset($value['is_active']) && $value['is_active'] === true) {
        list($sp_id, $pl) = explode('_', $key);
        $list_sp_id .= $sp_id . ',';
        $list_pl .= $pl . ',';
        $active_cart[$key] = $value;
    }
}
$list_sp_id = rtrim($list_sp_id, ',');
$list_pl = rtrim($list_pl, ',');
// Kiểm tra nếu không có sản phẩm nào được chọn
if (empty($active_cart)) {
    // Redirect về trang giỏ hàng với thông báo
    header('Location: /gio-hang.html?error=no_products_selected');
    exit();
}
// Tự động áp dụng voucher tốt nhất ngay khi load checkout
$auto_voucher_applied = false;
$hientai = time();
// Auto apply best vouchers logic here (integrated directly)
$user_id = 0;
if (isset($_COOKIE['user_id'])) {
    $check = $tlca_do->load('class_check');
    $tach_token = json_decode($check->token_login_decode($_COOKIE['user_id']), true);
    $user_id = $tach_token['user_id'];
}
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
// Lấy địa chỉ người nhận từ user info
$receiver_province = '';
$receiver_district = '';
$receiver_ward = '';
if ($user_id > 0) {
    $thongtin_diachi = mysqli_query($conn, "SELECT * FROM dia_chi WHERE user_id='$user_id' AND active='1'");
    if (mysqli_num_rows($thongtin_diachi) > 0) {
        $r_dc = mysqli_fetch_assoc($thongtin_diachi);
        $receiver_province = $r_dc['ten_tinh'] ?? '';
        $receiver_district = $r_dc['ten_huyen'] ?? '';
        $receiver_ward = $r_dc['ten_xa'] ?? '';
        error_log("User $user_id has address: $receiver_province, $receiver_district, $receiver_ward");
    } else {
        error_log("User $user_id has no default address - shipping fee will be 0");
    }
} else {
    // Kiểm tra session address_cus nếu không có user_id
    if (isset($_SESSION['address_cus']) && !empty($_SESSION['address_cus'])) {
        $receiver_province = $_SESSION['address_cus']['ten_tinh'] ?? '';
        $receiver_district = $_SESSION['address_cus']['ten_huyen'] ?? '';
        $receiver_ward = $_SESSION['address_cus']['ten_xa'] ?? '';
        error_log("Guest user has session address: $receiver_province, $receiver_district, $receiver_ward");
    } else {
        error_log("Guest user has no address in session - shipping fee will be 0");
    }
}
$shop_totals = [];
foreach ($active_cart as $cart_key => $cart_value) {
    list($cart_sp_id, $cart_pl) = explode('_', $cart_key);
    $cart_product = mysqli_query($conn, "SELECT shop FROM sanpham WHERE id = '$cart_sp_id' LIMIT 1");
    if ($cart_product && mysqli_num_rows($cart_product) > 0) {
        $cart_shop = mysqli_fetch_assoc($cart_product);
        $shop_id = $cart_shop['shop'];
        if (!isset($shop_totals[$shop_id])) {
            $shop_totals[$shop_id] = 0;
        }
        $product_total = $cart_value['gia_moi'] * $cart_value['quantity'];
        $shop_totals[$shop_id] += $product_total;
        // Debug log để kiểm tra tính toán
    }
}
// Log tổng kết shop totals
foreach ($shop_totals as $shop_id => $total) {
    $summary_msg = date('Y-m-d H:i:s') . " - Shop Total Summary: Shop ID=$shop_id, Total=$total\n";
}
$thongtin_cart = mysqli_query($conn, "SELECT * FROM sanpham WHERE id IN ($list_sp_id) ORDER BY FIELD(id, $list_sp_id)");
while ($r_cart = mysqli_fetch_assoc($thongtin_cart)) {
    $id_sp = $r_cart['id'];
    foreach ($active_cart as $key => $value) {
        list($cart_sp_id, $cart_pl) = explode('_', $key);
        if ($cart_sp_id == $id_sp) {
            $shop_id = $r_cart['shop'];
            $query = "SELECT name FROM user_info WHERE user_id = '$shop_id'";
            $result = mysqli_query($conn, $query);
            $shop_name = ($result && mysqli_num_rows($result) > 0) ? mysqli_fetch_assoc($result)['name'] : "Sàn TMĐT";
            if ($shop_id != 0) {
                $data = getCtvProvinceDistrict($conn, $r_cart['kho_id']);
                $id_transport_default = getIdTransportShop($conn, $shop_id);
                // Xem shop có hỗ trợ phí ship không
                if ($id_transport_default) {
                    $shop_transport = getCtvProvinceDistrict($conn, $id_transport_default);
                    if ($shop_transport) {
                        $r_cart['free_ship_all'] = $shop_transport['free_ship_all'];
                        $r_cart['free_ship_min_order'] = $shop_transport['free_ship_min_order'];
                        $r_cart['free_ship_discount'] = $shop_transport['free_ship_discount'];
                        // Lấy tổng đơn hàng của shop này để kiểm tra free_ship_min_order
                        $r_cart['free_ship_discount_product'] = 0;
                        // Lấy tổng đơn hàng của shop này để kiểm tra free_ship_min_order
                        $shop_order_total = $shop_totals[$shop_id] ?? 0;
                        // Log debug tổng đơn hàng shop
                        // Xử lý logic hỗ trợ phí ship theo free_ship_all
                        if ($shop_transport['free_ship_all'] == 0) {
                            // free_ship_all = 0: Hỗ trợ phí ship theo số tiền cố định (cần kiểm tra min_order)
                            if ($shop_order_total >= $shop_transport['free_ship_min_order']) {
                                $r_cart['free_ship_discount_product'] = intval($shop_transport['free_ship_discount']);
                                // Log debug hỗ trợ phí ship cố định
                            } else {
                                // Log debug không đạt min_order
                            }
                        } elseif ($shop_transport['free_ship_all'] == 1) {
                            // free_ship_all = 1: Miễn phí ship cho toàn bộ đơn hàng (không cần kiểm tra min_order)
                            $r_cart['free_ship_discount_product'] = 999999; // Giá trị lớn để miễn phí hoàn toàn
                            // Log debug miễn phí ship
                        } elseif ($shop_transport['free_ship_all'] == 2) {
                            // free_ship_all = 2: Hỗ trợ phí ship theo % của đơn hàng (cần kiểm tra min_order)
                            // Đối với free_ship_all = 2, hỗ trợ được tính theo % của tổng đơn hàng, không phải từng sản phẩm
                            // Chúng ta sẽ tính hỗ trợ ở cấp shop, không phải cấp sản phẩm
                            $r_cart['free_ship_discount_product'] = 0; // Đặt = 0 vì sẽ tính ở cấp shop
                            // Log debug cho free_ship_all = 2
                        } elseif ($shop_transport['free_ship_all'] == 3 && $shop_transport['fee_ship_products'] !== null && !empty($shop_transport['fee_ship_products'])) {
                            // free_ship_all = 3: Hỗ trợ phí ship theo sản phẩm cụ thể
                            $fee_ship_products = json_decode($shop_transport['fee_ship_products'], true);
                            // Log debug JSON fee_ship_products
                            if (is_array($fee_ship_products)) {
                                // Tìm sản phẩm theo sp_id trong danh sách fee_ship_products
                                foreach ($fee_ship_products as $product) {
                                    if (isset($product['sp_id']) && $product['sp_id'] == $id_sp) {
                                        if (isset($product['ship_amount_vnd'])) {
                                            // Lấy ship_amount_vnd làm hỗ trợ phí ship cho sản phẩm
                                            $r_cart['free_ship_discount_product'] = intval($product['ship_amount_vnd']);
                                            // Log debug hỗ trợ phí ship
                                            break;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                $shop_province = $data['tinh'];
                $shop_district = $data['huyen'];
                $shop_ward = $data['xa'];
            } else {
                $shop_province = 'Thành phố Hà Nội';
                $shop_district = 'Nam Từ Liêm';
                $shop_district = 'Mĩ Đình';
            }
            $pl_key = $id_sp . '_' . $cart_pl;
            $r_cart['ten_sanpham'] = $r_cart['tieu_de'];
            $r_cart['gia_moi'] = number_format($value['gia_moi'], 0, ',', '.');
            $r_cart['gia_cu'] = number_format($value['gia_cu'], 0, ',', '.');
            $r_cart['quantity'] = $value['quantity'];
            $r_cart['thanhtien'] = number_format($value['gia_moi'] * $value['quantity'], 0, ',', '.') . ' đ';
            $tamtinh += $value['gia_moi'] * $value['quantity'];
            $r_cart['sp_id'] = $cart_sp_id;
            $r_cart['pl'] = $cart_pl;
            $r_cart['shop'] = $value['shop'];
            $r_cart['total_sp_shop'] = $value['gia_moi'] * $value['quantity'];
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
            if (isset($product_pl[$pl_key])) {
                $r_cart['ten_color'] = $product_pl[$pl_key]['ten_color']
                    ? '<div class="color_content"><div class="text">' . $product_pl[$pl_key]['ten_color'] . '</div></div>'
                    : '';
                $r_cart['ten_size'] = $product_pl[$pl_key]['ten_size']
                    ? '<div class="color_content"><div class="text">' . $product_pl[$pl_key]['ten_size'] . '</div></div>'
                    : '';
                $ten_color = $product_pl[$pl_key]['ten_color'];
                $ten_size = $product_pl[$pl_key]['ten_size'];
                // Log SQL query để debug
                $sql_variant_weight = "SELECT can_nang_tinhship FROM phanloai_sanpham WHERE sp_id = '$id_sp' AND ten_size = '$ten_size' AND ten_color = '$ten_color' LIMIT 1";
                $res_variant_weight = mysqli_query($conn, $sql_variant_weight);
                $r_variant_weight = mysqli_fetch_assoc($res_variant_weight);
                $weight = floatval(str_replace(',', '.', $r_variant_weight['can_nang_tinhship'] ?? 0));
                // Log kết quả từ database
                $r_cart['trongluong'] = $shops[$shop_id]['trongluong'] ?? $weight * $value['quantity'];
            } else {
                $r_cart['ten_color'] = '';
                $r_cart['ten_size'] = '';
                $weight = floatval(str_replace(',', '.', $r_cart['can_nang_tinhship'] ?? 0));
                // Log trọng lượng từ sản phẩm chính
                $r_cart['trongluong'] = $shops[$shop_id]['trongluong'] ?? $weight * $value['quantity'];
            }
            $shops[$shop_id]['tinh'] = $shop_province;
            $shops[$shop_id]['huyen'] = $shop_district;
            // lấy địa chỉ kho của từng sản phẩm 
            $r_cart['tinh'] = $shop_province;
            $r_cart['huyen'] = $shop_district;
            $r_cart['trongluong'] = $shops[$shop_id]['trongluong'] ?? $weight * $value['quantity'];
            $r_cart['tamtinh'] = $tamtinh;
            // Tính phí ship cho sản phẩm này dựa trên kho của nó
            $product_shipping_providers = getShippingProviderCodes($conn, $shop_id);
            // Log chi tiết trọng lượng của từng sản phẩm
            // Log thông tin variant nếu có
            if (isset($product_pl[$pl_key])) {
                $variant_info = $product_pl[$pl_key];
            } else {
            }
            // Trọng lượng đã được tính theo gram, không cần nhân thêm
            $product_weight = $weight * $value['quantity'];
            $product_amount = $value['gia_moi'] * $value['quantity'];
            // Log chi tiết tính toán cuối cùng
            // Debug log để kiểm tra thông tin
            // Kiểm tra có địa chỉ nhận hàng không trước khi tính phí ship
            if (!empty($receiver_province) && !empty($receiver_district) && !empty($product_shipping_providers)) {
                $best_product_shipping = getBestShippingProvider(
                    $product_shipping_providers,
                    $shop_province,
                    $shop_district,
                    $receiver_province,
                    $receiver_district,
                    $shop_ward,
                    $receiver_ward,
                    $product_weight,
                    $product_amount,
                    $class_ghn,
                    $class_ghtk,
                    $class_superai,
                    $class_best,
                    $class_spx,
                    $index_setting
                );
                // Nếu getBestShippingProvider trả về phí = 0, thử fallback GHTK
                if ($best_product_shipping['fee'] == 0) {
                    try {
                        // Xác định miền gửi và nhận
                        $sender_mien = get_mien_by_province($conn, $shop_province);
                        $receiver_mien = get_mien_by_province($conn, $receiver_province);
                        
                        // Gọi hàm get_tax thay vì ship_fee
                        $ghtk_response = $class_ghtk->get_tax(
                            $product_weight,      // Cân nặng (gram)
                            $product_amount,      // Tiền hàng
                            $shop_province,       // Tỉnh gửi
                            $sender_mien,         // Miền gửi
                            $receiver_province,   // Tỉnh nhận
                            $receiver_mien,       // Miền nhận
                            false,                // COD
                            false                 // Giao lại
                        );
                        
                        $ghtk_result = json_decode($ghtk_response, true);
                        if (isset($ghtk_result['phi_tong']) && $ghtk_result['phi_tong'] > 0) {
                            $r_cart['phi_ship_goc'] = $ghtk_result['phi_tong'];
                            $r_cart['shipping_provider'] = 'GHTK (Fallback)';
                            $r_cart['shipping_provider_code'] = 'GHTK';
                        } else {
                            // Cả fallback cũng thất bại, sử dụng kết quả gốc
                            $r_cart['phi_ship_goc'] = $best_product_shipping['fee'];
                            $r_cart['shipping_provider'] = $best_product_shipping['provider'];
                            $r_cart['shipping_provider_code'] = $best_product_shipping['provider_code'];
                        }
                    } catch (Exception $e) {
                        // Exception - sử dụng kết quả gốc
                        $r_cart['phi_ship_goc'] = $best_product_shipping['fee'];
                        $r_cart['shipping_provider'] = $best_product_shipping['provider'];
                        $r_cart['shipping_provider_code'] = $best_product_shipping['provider_code'];
                    }
                    
                    /* OLD GHTK FALLBACK CODE - COMMENTED FOR REFERENCE
                    $ghtk_data = array(
                        "pick_province" => $shop_province,
                        "pick_district" => $shop_district,
                        "province" => $receiver_province,
                        "district" => $receiver_district,
                        "address" => "",
                        "weight" => $product_weight,
                        "value" => $product_amount,
                        "transport" => "road",
                        "deliver_option" => "standard",
                        "tags" => []
                    );
                    $ghtk_response = $class_ghtk->ship_fee($ghtk_data, true);
                    $ghtk_result = json_decode($ghtk_response, true);
                    if (isset($ghtk_result['success']) && $ghtk_result['success'] === true && ($ghtk_result['fee']['fee'] ?? 0) > 0) {
                        $r_cart['phi_ship_goc'] = $ghtk_result['fee']['fee'];
                        $r_cart['shipping_provider'] = 'GHTK (Fallback)';
                        $r_cart['shipping_provider_code'] = 'GHTK';
                    } else {
                        // Cả fallback cũng thất bại, sử dụng kết quả gốc
                        $r_cart['phi_ship_goc'] = $best_product_shipping['fee'];
                        $r_cart['shipping_provider'] = $best_product_shipping['provider'];
                        $r_cart['shipping_provider_code'] = $best_product_shipping['provider_code'];
                    }
                    */
                } else {
                    // Sử dụng kết quả từ getBestShippingProvider
                    $r_cart['phi_ship_goc'] = $best_product_shipping['fee'];
                    $r_cart['shipping_provider'] = $best_product_shipping['provider'];
                    $r_cart['shipping_provider_code'] = $best_product_shipping['provider_code'];
                }
            } elseif (!empty($receiver_province) && !empty($receiver_district)) {
                // Fallback to GHTK if no providers configured but have address
                try {
                    // Xác định miền gửi và nhận
                    $sender_mien = get_mien_by_province($conn, $shop_province);
                    $receiver_mien = get_mien_by_province($conn, $receiver_province);
                    
                    // Gọi hàm get_tax thay vì ship_fee
                    $ghtk_response = $class_ghtk->get_tax(
                        $product_weight,      // Cân nặng (gram)
                        $product_amount,      // Tiền hàng
                        $shop_province,       // Tỉnh gửi
                        $sender_mien,         // Miền gửi
                        $receiver_province,   // Tỉnh nhận
                        $receiver_mien,       // Miền nhận
                        false,                // COD
                        false                 // Giao lại
                    );
                    
                    $ghtk_result = json_decode($ghtk_response, true);
                    $r_cart['phi_ship_goc'] = isset($ghtk_result['phi_tong']) ? $ghtk_result['phi_tong'] : 0;
                } catch (Exception $e) {
                    $r_cart['phi_ship_goc'] = 0;
                }
                
                /* OLD GHTK FALLBACK CODE - COMMENTED FOR REFERENCE
                $ghtk_data = array(
                    "pick_province" => $shop_province,
                    "pick_district" => $shop_district,
                    "province" => $receiver_province,
                    "district" => $receiver_district,
                    "address" => "",
                    "weight" => $product_weight,
                    "value" => $product_amount,
                    "transport" => "road",
                    "deliver_option" => "standard",
                    "tags" => []
                );
                $ghtk_response = $class_ghtk->ship_fee($ghtk_data, true);
                $ghtk_result = json_decode($ghtk_response, true);
                $r_cart['phi_ship_goc'] = (isset($ghtk_result['success']) && $ghtk_result['success'] === true) ? ($ghtk_result['fee']['fee'] ?? 0) : 0;
                */
                
                $r_cart['shipping_provider'] = 'GHTK';
                $r_cart['shipping_provider_code'] = 'GHTK';
            } else {
                // Không có địa chỉ nhận hàng - không tính phí ship
                $r_cart['phi_ship_goc'] = 0;
                $r_cart['shipping_provider'] = 'Chưa có địa chỉ';
                $r_cart['shipping_provider_code'] = 'NO_ADDRESS';
                error_log("No shipping address provided - shipping fee set to 0");
            }
            $shops[$shop_id]['shop_name'] = $shop_name;
            $tamtinh_sanpham = number_format($value['gia_moi'] * $value['quantity'], 0, ',', '.');
            $r_cart['tamtinh_sanpham'] = $tamtinh_sanpham;
            // Thêm các biến cần thiết cho template
            $r_cart['phi_ship_goc'] = $r_cart['phi_ship_goc'] ?? 0;
            $r_cart['shipping_provider_code'] = $r_cart['shipping_provider_code'] ?? 'SUPERAI';
            $r_cart['free_ship_discount_product'] = $r_cart['free_ship_discount_product'] ?? 0;
            $shops[$shop_id]['products'][] = $skin->skin_replace('skin/box_li/li_shopcart', $r_cart);
            $shops[$shop_id]['subtotal'] = ($shops[$shop_id]['subtotal'] ?? 0) + ($value['gia_moi'] * $value['quantity']);
            $shops[$shop_id]['shop_id'] = $shop_id;
            $shops[$shop_id]['sp_ids'][] = $id_sp;
            $shops[$shop_id]['kho_id'] = $r_cart['kho_id'];
            // Cộng phí ship của sản phẩm này vào tổng phí ship của shop
            $product_shipping_fee = $r_cart['phi_ship_goc'] ?? 0;
            $shops[$shop_id]['total_phi_ship'] = ($shops[$shop_id]['total_phi_ship'] ?? 0) + $product_shipping_fee;
            // Tính hỗ trợ phí ship cho sản phẩm này (nếu có)
            $product_ship_support = 0;
            if (isset($r_cart['free_ship_discount_product']) && $r_cart['free_ship_discount_product'] > 0) {
                $product_ship_support = $r_cart['free_ship_discount_product'] * $value['quantity'];
                $shops[$shop_id]['total_ship_support'] = ($shops[$shop_id]['total_ship_support'] ?? 0) + $product_ship_support;
            }
            // Log phí ship của từng sản phẩm
            $log_message = date('Y-m-d H:i:s') . " - Shop: $shop_id, Product: $id_sp, Provider: " . ($r_cart['shipping_provider'] ?? 'N/A') . ", Fee: " . number_format($product_shipping_fee, 0, ',', '.') . " VND, Ship Support: " . number_format($product_ship_support, 0, ',', '.') . " VND, Total Shop Fee: " . number_format($shops[$shop_id]['total_phi_ship'], 0, ',', '.') . " VND\n";
            // Log chi tiết phí ship của sản phẩm
            // Lưu thông tin provider của sản phẩm này
            $shops[$shop_id]['product_shipping_providers'][] = [
                'provider' => $r_cart['shipping_provider'] ?? 'Supership',
                'provider_code' => $r_cart['shipping_provider_code'] ?? 'SUPERSHIP',
                'fee' => $r_cart['phi_ship_goc'] ?? 0
            ];
        }
    }
}
$total_phi_ship = 0;
$total_ship_support = 0;
foreach ($shops as $shop_id => &$shop) {
    // Tìm provider có phí ship thấp nhất cho shop này
    if (isset($shop['product_shipping_providers']) && !empty($shop['product_shipping_providers'])) {
        $provider_fees = [];
        foreach ($shop['product_shipping_providers'] as $provider_info) {
            $provider = $provider_info['provider'];
            if (!isset($provider_fees[$provider])) {
                $provider_fees[$provider] = [
                    'provider' => $provider,
                    'provider_code' => $provider_info['provider_code'],
                    'total_fee' => 0
                ];
            }
            $provider_fees[$provider]['total_fee'] += $provider_info['fee'];
        }
        // Tìm provider có tổng phí ship thấp nhất
        $best_provider = null;
        $lowest_fee = PHP_INT_MAX;
        foreach ($provider_fees as $provider_data) {
            if ($provider_data['total_fee'] < $lowest_fee) {
                $lowest_fee = $provider_data['total_fee'];
                $best_provider = $provider_data;
            }
        }
        if ($best_provider) {
            $shop['best_shipping_provider'] = $best_provider['provider'];
            $shop['best_shipping_provider_code'] = $best_provider['provider_code'];
        }
    }
    $shop['giam'] = 0;
    $shop['coupon_code'] = '';
    $shop['remove_coupon_display'] = 'none';
    // Recalculate weight and subtotal for accuracy BEFORE coupon calculation (Active products only)
    $shop['trongluong'] = 0;
    $shop['subtotal'] = 0;
    foreach ($active_cart as $key => $value) {
        list($cart_sp_id, $cart_pl) = explode('_', $key);
        $product_query = mysqli_query($conn, "SELECT shop, can_nang_tinhship FROM sanpham WHERE id = '$cart_sp_id' LIMIT 1");
        $r_product = mysqli_fetch_assoc($product_query);
        if ($r_product['shop'] == $shop_id) {
            $pl_key = $cart_sp_id . '_' . $cart_pl;
            $weight = isset($product_pl[$pl_key]) ? floatval(str_replace(',', '.', $product_pl[$pl_key]['can_nang_tinhship'] ?? 0)) : floatval(str_replace(',', '.', $r_product['can_nang_tinhship'] ?? 0));
            $shop['trongluong'] += $weight * $value['quantity'];
            $shop['subtotal'] += $value['gia_moi'] * $value['quantity'];
        }
    }
    // Tự động tìm voucher shop tốt nhất (chỉ khi user đã đăng nhập)
    $best_shop_coupon = null;
    $best_shop_discount = 0;
    
    if ($user_id > 0) {
        // Lấy tất cả voucher shop có thể áp dụng
        $shop_coupon_query = "SELECT * FROM coupon 
                             WHERE shop='$shop_id' AND status='2'
                             AND start <= '$hientai' 
                             AND expired >= '$hientai'
                             ORDER BY giam DESC, giam_toi_da DESC";
        $shop_coupon_result = mysqli_query($conn, $shop_coupon_query);
        while ($coupon = mysqli_fetch_assoc($shop_coupon_result)) {
        $valid_coupon = true;
        $applicable_subtotal = 0;
        // Tính applicable_subtotal dựa trên kiểu coupon
        if ($coupon['kieu'] == 'sanpham' && !empty($coupon['sanpham'])) {
            $coupon_sp_ids = array_map('trim', explode(',', $coupon['sanpham']));
            $intersect = array_intersect($coupon_sp_ids, array_map('strval', $shop['sp_ids']));
            if (empty($intersect)) {
                $valid_coupon = false;
                error_log("Shop coupon '{$coupon['ma']}' - No matching products in shop $shop_id");
            } else {
                $matched_shop_products = [];
                foreach ($active_cart as $key => $value) {
                    list($cart_sp_id, $cart_pl) = explode('_', $key);
                    $product_query = mysqli_query($conn, "SELECT shop FROM sanpham WHERE id = '$cart_sp_id' LIMIT 1");
                    $r_product = mysqli_fetch_assoc($product_query);
                    if ($r_product['shop'] == $shop_id && in_array($cart_sp_id, $intersect)) {
                        $product_total = $value['gia_moi'] * $value['quantity'];
                        $applicable_subtotal += $product_total;
                        $matched_shop_products[] = "SP_ID: $cart_sp_id, Total: $product_total";
                    }
                }
                error_log("Shop coupon '{$coupon['ma']}' for shop $shop_id:");
                error_log("  - Matched products: " . count($matched_shop_products));
                error_log("  - Total applicable: " . number_format($applicable_subtotal) . " VND");
            }
        } else {
            $applicable_subtotal = $shop['subtotal'];
            error_log("Shop coupon '{$coupon['ma']}' for shop $shop_id - Order-wide: " . number_format($applicable_subtotal) . " VND");
        }
        // Kiểm tra các điều kiện
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
        if ($valid_coupon && $applicable_subtotal > 0) {
            // Tính giảm giá
            $discount_value = ($coupon['loai'] == 'phantram')
                ? ceil(($applicable_subtotal / 100) * min($coupon['giam'], 100))
                : $coupon['giam'];
            // Áp dụng giới hạn giảm tối đa
            if (($coupon['giam_toi_da'] ?? 0) > 0 && $discount_value > $coupon['giam_toi_da']) {
                $discount_value = $coupon['giam_toi_da'];
            }
            // So sánh với voucher tốt nhất hiện tại
            if ($discount_value > $best_shop_discount) {
                $best_shop_discount = $discount_value;
                $best_shop_coupon = $coupon;
            }
        }
        }
    }
    // Áp dụng voucher shop tốt nhất (nếu có)
    if ($best_shop_coupon) {
        $shop['giam'] = $best_shop_discount;
        $shop['coupon_code'] = $best_shop_coupon['ma'];
        $shop['remove_coupon_display'] = 'inline-block';
        // Lưu vào session để sử dụng khi thanh toán
        $_SESSION['shop_coupons'][$shop_id] = $best_shop_coupon['ma'];
    }
    $total_giam += $shop['giam'];
    // Calculate shipping fees
    $id_transport_default = getIdTransportShop($conn, $shop['shop_id']);
    $shop_transport = getCtvProvinceDistrict($conn, $id_transport_default);
    // Không ghi đè lại receiver_province và receiver_district đã lấy ở trên
    $sender_province = $shop['tinh'] ?? 'Thành phố Hà Nội';
    $sender_district = $shop['huyen'] ?? 'Nam Từ Liêm';
    // Sử dụng tổng phí ship đã cộng từ tất cả sản phẩm trong shop
    $shop['phi_ship_goc'] = $shop['total_phi_ship'] ?? 0;
    $shop['shipping_provider'] = $shop['best_shipping_provider'] ?? 'Supership';
    $shop['shipping_provider_code'] = $shop['best_shipping_provider_code'] ?? 'SUPERSHIP';
    // Tính thời gian giao hàng dự kiến cho shop
    $delivery_time = calculateDeliveryTime($sender_province, $receiver_province, 'standard');
    $shop['delivery_days'] = $delivery_time['days'];
    $shop['delivery_date'] = $delivery_time['date_formatted'];
    $shop['delivery_description'] = $delivery_time['description'];
    $shop['delivery_range'] = $delivery_time['delivery_range'];
    // Log tổng phí ship cuối cùng của shop
    $final_log_message = date('Y-m-d H:i:s') . " - FINAL Shop: $shop_id, Best Provider: " . ($shop['shipping_provider'] ?? 'N/A') . ", Final Fee: " . number_format($shop['phi_ship_goc'], 0, ',', '.') . " VND\n";
    $shop['ship_support'] = 0;
    $shop['ship_support_display'] = '';
    // Luôn hiển thị phí ship gốc cho từng shop (không trừ hỗ trợ)
    $shop['phi_ship'] = $shop['phi_ship_goc'];
    $shop['phi_ship_text'] = number_format($shop['phi_ship_goc'], 0, ',', '.') . ' ₫';
    $shop_transport = null;
    if ($shop_id != 0) {
        $id_transport_default = getIdTransportShop($conn, $shop_id);
        if ($id_transport_default) {
            $shop_transport = getCtvProvinceDistrict($conn, $id_transport_default);
            // Log debug thông tin transport của shop
        }
    }
    if ($shop_transport) {
        if ($shop_transport['free_ship_all'] == 1) {
            $shop['ship_support'] = $shop['phi_ship_goc'];
            $shop['ship_support_display'] = number_format($shop['phi_ship_goc'], 0, ',', '.') . ' ₫';
            $shop['tinh'] = '';
            $shop['huyen'] = '';
        } elseif ($shop_transport['free_ship_all'] == 3) {
            // Hỗ trợ phí ship cho từng sản phẩm
            $shop_ship_support = $shop['total_ship_support'] ?? 0;
            $shop['ship_support'] = $shop_ship_support;
            $shop['ship_support_display'] = number_format($shop_ship_support, 0, ',', '.') . ' ₫';
        } elseif ($shop_transport['free_ship_all'] == 2) {
            // free_ship_all = 2: Tính hỗ trợ theo % của tổng đơn hàng shop
            $subtotal = (int) ($shop['subtotal'] ?? 0);
            $min_order = (int) ($shop_transport['free_ship_min_order'] ?? 0);
            $discount_percentage = (int) ($shop_transport['free_ship_discount'] ?? 0);
            // Log debug trước khi tính toán
            if ($subtotal >= $min_order && $discount_percentage > 0) {
                $shop_ship_support = ($subtotal * $discount_percentage) / 100;
                // Log debug hỗ trợ phí ship theo %
            } else {
                $shop_ship_support = 0;
                // Log debug không đạt điều kiện
            }
            $shop['ship_support'] = intval($shop_ship_support);
            $shop['ship_support_display'] = number_format($shop['ship_support'], 0, ',', '.') . ' ₫';
            // Log debug hỗ trợ phí ship cuối cùng
        } else {
            // Tính hỗ trợ phí ship cho free_ship_all = 0 (các trường hợp khác)
            $shop_ship_support = $shop['total_ship_support'] ?? 0;
            $shop['ship_support'] = intval($shop_ship_support);
            $shop['ship_support_display'] = number_format($shop['ship_support'], 0, ',', '.') . ' ₫';
            // Log debug hỗ trợ phí ship cuối cùng
        }
    } else {
        $shop['ship_support'] = 0;
        $shop['ship_support_display'] = '0 ₫';
    }
    // Tính tổng tiền thực tế phải trả (phí ship gốc - hỗ trợ phí ship)
    $actual_shipping_fee = max(0, $shop['phi_ship_goc'] - $shop['ship_support']);
    $shop['shop_total'] = ($shop['subtotal'] ?? 0) - ($shop['giam'] ?? 0) + $actual_shipping_fee;
    $shop_html = [
        'shop_name' => $shop['shop_name'],
        'shop_tinh' => $shop['tinh'],
        'shop_huyen' => $shop['huyen'],
        'shop_id' => $shop['shop_id'],
        'shop_subtotal' => number_format($shop['subtotal'], 0, ',', '.'),
        'trongluong' => $shop['trongluong'] ?? 0,
        'list_products' => implode('', $shop['products']),
        'giam' => number_format($shop['giam'], 0, ',', '.'),
        'coupon_code' => $shop['coupon_code'],
        'remove_coupon_display' => $shop['remove_coupon_display'],
        'phi_ship_text' => $shop['phi_ship_text'],
        'ship_support_display' => $shop['ship_support_display'] ?? '0 ₫',
        'shop_total' => number_format($shop['shop_total'], 0, ',', '.') . ' ₫',
        'shipping_provider' => $shop['shipping_provider'] ?? 'Supership',
        'shipping_provider_code' => $shop['shipping_provider_code'] ?? 'SUPERSHIP',
        'delivery_days' => $shop['delivery_days'] ?? 3,
        'delivery_date' => $shop['delivery_date'] ?? date('d/m/Y', strtotime('+3 days')),
        'delivery_description' => $shop['delivery_description'] ?? 'Giao hàng trong 3 ngày',
        'delivery_range' => $shop['delivery_range'] ?? 'Đảm bảo nhận hàng từ 2 Tháng 9 - 4 Tháng 9',
        'shop_tamtinh' => number_format($shop['shop_total'], 0, ',', '.') . ' ₫'
    ];
    $list_shopcart .= $skin->skin_replace('skin/box_li/li_shopcart_shop', $shop_html);
    $total_phi_ship += $shop['phi_ship_goc']; // Tổng phí ship gốc
    $total_ship_support += $shop['ship_support']; // Tổng hỗ trợ phí ship
}
// Hiển thị phí ship gốc (không trừ hỗ trợ)
$total_phi_ship_display = number_format($total_phi_ship, 0, ',', '.') . ' ₫';
// Tính tổng tiền thực tế phải trả (phí ship gốc - hỗ trợ phí ship)
$total_actual_shipping = $total_phi_ship - $total_ship_support;
// Tự động tìm và áp dụng voucher sàn tốt nhất (chỉ khi user đã đăng nhập)
$san_coupon_discount = 0;
$san_coupon_code = '';
$san_coupon_display = '0';
$best_san_coupon = null;
$best_san_discount = 0;

if ($user_id > 0) {
    // Lấy tất cả voucher sàn có thể áp dụng
    $san_coupon_query = "SELECT * FROM coupon 
                        WHERE shop='0' 
                        AND start <= '$hientai' 
                        AND expired >= '$hientai'
                        ORDER BY giam DESC, giam_toi_da DESC";
    $san_coupon_result = mysqli_query($conn, $san_coupon_query);
    while ($coupon = mysqli_fetch_assoc($san_coupon_result)) {
    $valid_coupon = true;
    $applicable_subtotal = 0;
    // Tính subtotal áp dụng cho voucher sàn
    if ($coupon['kieu'] == 'sanpham' && !empty($coupon['sanpham'])) {
        // Chỉ áp dụng cho sản phẩm cụ thể (Active products only)
        $voucher_sp_ids = array_map('trim', explode(',', $coupon['sanpham']));
        $matched_products = [];
        foreach ($active_cart as $key => $value) {
            list($sp_id, $pl) = explode('_', $key);
            if (in_array($sp_id, $voucher_sp_ids)) {
                $product_total = $value['gia_moi'] * $value['quantity'];
                $applicable_subtotal += $product_total;
                $matched_products[] = "SP_ID: $sp_id, Quantity: {$value['quantity']}, Price: {$value['gia_moi']}, Total: $product_total";
            }
        }
        // Debug log cho voucher sàn theo sản phẩm
        error_log("San coupon '{$coupon['ma']}' - Product-specific voucher:");
        error_log("Voucher applies to SP_IDs: " . implode(', ', $voucher_sp_ids));
        error_log("Matched products in cart: " . count($matched_products));
        foreach ($matched_products as $product_info) {
            error_log("  - $product_info");
        }
        error_log("Total applicable amount: " . number_format($applicable_subtotal) . " VND");
    } else {
        // Áp dụng cho toàn bộ đơn hàng
        $applicable_subtotal = $tamtinh;
        error_log("San coupon '{$coupon['ma']}' - Order-wide voucher: " . number_format($applicable_subtotal) . " VND");
    }
    // Kiểm tra điều kiện áp dụng
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
    if ($valid_coupon && $applicable_subtotal > 0) {
        // Tính giảm giá
        $discount_value = ($coupon['loai'] == 'phantram')
            ? ceil(($applicable_subtotal / 100) * min($coupon['giam'], 100))
            : $coupon['giam'];
        // Áp dụng giới hạn giảm tối đa
        if (($coupon['giam_toi_da'] ?? 0) > 0 && $discount_value > $coupon['giam_toi_da']) {
            $discount_value = $coupon['giam_toi_da'];
        }
        
        // Debug log tính toán giảm giá
        error_log("San coupon '{$coupon['ma']}' discount calculation:");
        error_log("  - Type: {$coupon['loai']}, Rate: {$coupon['giam']}");
        error_log("  - Applicable amount: " . number_format($applicable_subtotal) . " VND");
        error_log("  - Calculated discount: " . number_format($discount_value) . " VND");
        error_log("  - Max discount limit: " . number_format($coupon['giam_toi_da'] ?? 0) . " VND");
        
        // So sánh với voucher tốt nhất hiện tại
        if ($discount_value > $best_san_discount) {
            $best_san_discount = $discount_value;
            $best_san_coupon = $coupon;
            error_log("  - NEW BEST san coupon: {$coupon['ma']} with discount: " . number_format($discount_value) . " VND");
        } else {
            error_log("  - Not better than current best: " . number_format($best_san_discount) . " VND");
        }
    }
    }
}
// Áp dụng voucher sàn tốt nhất (nếu có)
if ($best_san_coupon) {
    $san_coupon_discount = $best_san_discount;
    $san_coupon_code = $best_san_coupon['ma'];
    $san_coupon_display = number_format($san_coupon_discount, 0, ',', '.');
    // Lưu vào session để sử dụng khi thanh toán
    $_SESSION['san_coupon'] = $best_san_coupon['ma'];
    
    // Debug log voucher sàn được áp dụng
    error_log("=== FINAL SAN COUPON APPLIED ===");
    error_log("Coupon Code: {$san_coupon_code}");
    error_log("Discount Amount: " . number_format($san_coupon_discount) . " VND");
    error_log("Coupon Type: {$best_san_coupon['kieu']}");
    if ($best_san_coupon['kieu'] == 'sanpham') {
        error_log("Applies to products: {$best_san_coupon['sanpham']}");
    }
    error_log("================================");
} else {
    error_log("No san coupon applied - no valid coupons found");
}

// NHATUPDATE19/9/2025: Xử lý hiển thị nút xóa voucher sàn
$san_coupon_btn_style = !empty($san_coupon_code) ? 'inline-block' : 'none';
$tongtien = $tamtinh - $total_giam - $san_coupon_discount + $total_actual_shipping;
$thongtin_caidat_tichdiem = mysqli_query($conn, "SELECT diem FROM caidat_tichdiem WHERE shop='0'");
$hat_de = 0;
if ($r_caidat = mysqli_fetch_assoc($thongtin_caidat_tichdiem)) {
    $hat_de = round(($tongtien / 100) * ($r_caidat['diem'] ?? 0));
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
$box_show_address = (!empty($user_id) || !empty($_SESSION['address_cus'])) ? 0 : 0;
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
    'title' => 'Thanh Toán',
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
    'total_cart' => count($active_cart),
    'tongtien' => number_format($tongtien, 0, ',', '.'),
    'tamtinh' => number_format($tamtinh, 0, ',', '.'),
    'total_phi_ship' => $total_phi_ship_display,
    'ship_support_display' => number_format($total_ship_support, 0, ',', '.') . ' ₫',
    'hat_de' => number_format($hat_de, 0, ',', '.'),
    'hatde_conlai' => number_format($hatde_conlai, 0, ',', '.'),
    'giam' => number_format($total_giam, 0, ',', '.'),
    'san_coupon_code' => $san_coupon_code,
    'san_coupon_display' => $san_coupon_display,
    'san_coupon_btn_style' => $san_coupon_btn_style, // NHATUPDATE19/9/2025: Thêm biến điều khiển hiển thị nút xóa
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
    'voucher_button_html' => $voucher_button_html,
    'voucher_button_html_messge' => $voucher_button_html_messge,
    'is_logged_in' => $is_logged_in,
    'ten_tinh' => $ten_tinh,
    'ten_huyen' => $ten_huyen,
    'ten_xa' => $ten_xa,
    'default_address_html' => $default_address_html,
    'box_show_address' => $box_show_address ?? '',
    'favicon' => $index_setting['favicon'],
    'text_copyright_chantrang' => $index_setting['text_copyright_chantrang'],
);
echo $skin->skin_replace('skin/checkout_step_1', $replace);

