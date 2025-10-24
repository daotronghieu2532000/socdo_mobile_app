<?php
header("Access-Control-Allow-Methods: GET, POST");

// Bật bắt lỗi để trả JSON thay vì HTTP 500 trắng
error_reporting(E_ALL);
ini_set('display_errors', '0');
set_error_handler(function ($severity, $message, $file, $line) {
    throw new ErrorException($message, 0, $severity, $file, $line);
});
function json_fatal($msg, $debug = [])
{
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => $msg, 'debug' => $debug], JSON_UNESCAPED_UNICODE);
    exit;
}

// Database connection (inherit from global scope or create new)
if (!isset($conn) || !$conn) {
    $conn = mysqli_connect("localhost", "socdo", "Viettel@123", "socdo");
    if (!$conn) {
        json_fatal('Database connection failed: ' . mysqli_connect_error());
    }
    mysqli_set_charset($conn, "utf8mb4");
}

// Tải autoload an toàn (đường dẫn linh hoạt)
$autoload_paths = [__DIR__ . '/vendor/autoload.php', __DIR__ . '/../vendor/autoload.php', __DIR__ . '/../../vendor/autoload.php'];
$autoload_loaded = false;
foreach ($autoload_paths as $p) {
    if (file_exists($p)) {
        require_once $p;
        $autoload_loaded = true;
        break;
    }
}
// Nếu không có vendor, tiếp tục chạy với fallback HS256 thủ công (không dừng)
use \Firebase\JWT\JWT;
use \Firebase\JWT\Key;

// JWT config
$key = "Socdo123@2025";
$issuer = "api.socdo.vn";

// Authorization header (fallback getallheaders/$_SERVER)
if (!function_exists('apache_request_headers')) {
    function apache_request_headers()
    {
        return function_exists('getallheaders') ? getallheaders() : [];
    }
}
$headers = apache_request_headers();
$authHeader = isset($headers['Authorization']) ? $headers['Authorization'] : '';
if (!$authHeader || !preg_match('/Bearer\s(\S+)/', $authHeader, $matches)) {
    http_response_code(401);
    echo json_encode(array("message" => "Không tìm thấy token"));
    exit;
}

$jwt = $matches[1];

try {
    // Decode JWT
    if ($autoload_loaded) {
        $decoded = JWT::decode($jwt, new Key($key, 'HS256'));
        if ($decoded->iss !== $issuer) {
            http_response_code(401);
            echo json_encode(array("message" => "Issuer không hợp lệ"));
            exit;
        }
    } else {
        // Fallback xác thực HS256 thủ công nếu thiếu vendor
        $parts = explode('.', $jwt);
        if (count($parts) !== 3) json_fatal('JWT không hợp lệ (parts)', ['paths_tried' => $autoload_paths]);
        list($h64, $p64, $s64) = $parts;
        $header = json_decode(base64_decode(strtr($h64, '-_', '+/')), true);
        $payload = json_decode(base64_decode(strtr($p64, '-_', '+/')), true);
        if (!$header || !$payload || ($header['alg'] ?? '') !== 'HS256') json_fatal('JWT không hợp lệ (alg)', ['paths_tried' => $autoload_paths]);
        $sig = base64_decode(strtr($s64, '-_', '+/'));
        $expect = hash_hmac('sha256', $h64 . '.' . $p64, $key, true);
        if (!hash_equals($expect, $sig)) json_fatal('JWT signature sai', ['paths_tried' => $autoload_paths]);
        if (($payload['iss'] ?? '') !== $issuer) json_fatal('Issuer không hợp lệ', ['paths_tried' => $autoload_paths]);
        if (isset($payload['exp']) && time() >= intval($payload['exp'])) json_fatal('JWT đã hết hạn', ['paths_tried' => $autoload_paths]);
        $decoded = (object)$payload;
    }

    // Helper: get 'mien' of a province name from tinh_moi
    function get_mien_by_province_name($conn, $provinceName)
    {
        if (empty($provinceName)) return 'mien-nam';
        // Nếu không có kết nối DB thì fallback đơn giản theo tên tỉnh
        if (!$conn) {
            $name = mb_strtolower($provinceName, 'UTF-8');
            // Bắc: Hà Nội, Hải Phòng, Quảng Ninh, Bắc Ninh, Bắc Giang, Nam Định, Thái Nguyên, Hải Dương, Thái Bình, Ninh Bình, Hòa Bình, Phú Thọ...
            $is_mien_bac = preg_match('/hà nội|hai phong|hải phòng|quảng ninh|bac ninh|bắc ninh|bắc giang|bac giang|nam định|thái nguyên|thai nguyen|hải dương|hai duong|thái bình|thai binh|ninh bình|ninh binh|phú thọ|phu tho|hoà bình|hòa bình|hoa binh/i', $name);
            return $is_mien_bac ? 'mien-bac' : 'mien-nam';
        }
        $kw = mysqli_real_escape_string($conn, $provinceName);
        $sql = "SELECT mien FROM tinh_moi WHERE tieu_de LIKE '%$kw%' LIMIT 1";
        $res = mysqli_query($conn, $sql);
        if ($res && ($row = mysqli_fetch_assoc($res))) {
            return $row['mien'] ?: 'mien-nam';
        }
        return 'mien-nam';
    }

    // Khởi tạo mảng debug
    $debug = [
        'mode' => '',
        'item_weights' => [],
        'shop_freeship_details' => [],
        'freeship_excluded' => []
    ];

    // Load class files: ƯU TIÊN include trực tiếp từ cùng thư mục với API
    $class_ghtk = null;
    $class_superai = null;
    $candidate_paths = [
        __DIR__ . '/class_ghtk.php' => 'class_ghtk',
        __DIR__ . '/class_superai.php' => 'class_superai',
        '/home/socdo.vn/public_html/includes/class_ghtk.php' => 'class_ghtk',
        '/home/socdo.vn/public_html/includes/class_superai.php' => 'class_superai',
    ];
    foreach ($candidate_paths as $path => $className) {
        if (!class_exists($className) && file_exists($path)) {
            // dùng include thay vì loader để tránh phụ thuộc môi trường
            include_once $path;
            $debug['paths_checked'][] = ['path' => $path, 'exists' => 1, 'class' => $className, 'class_exists' => class_exists($className) ? 1 : 0, 'how' => 'include_once'];
        } else {
            $debug['paths_checked'][] = ['path' => $path, 'exists' => file_exists($path) ? 1 : 0, 'class' => $className, 'class_exists' => class_exists($className) ? 1 : 0, 'how' => 'skip'];
        }
    }
    // Sau khi include thủ công, nếu vẫn chưa có class, thử qua loader nếu có
    if ((!class_exists('class_ghtk') || !class_exists('class_superai')) && isset($tlca_do)) {
        try {
            if (!class_exists('class_ghtk')) {
                $class_ghtk = $tlca_do->load('class_ghtk');
                $debug['loader_used_ghtk'] = true;
            }
        } catch (Throwable $e) {
            $debug['loader_err_ghtk'] = $e->getMessage();
        }
        try {
            if (!class_exists('class_superai')) {
                $class_superai = $tlca_do->load('class_superai');
                $debug['loader_used_superai'] = true;
            }
        } catch (Throwable $e) {
            $debug['loader_err_superai'] = $e->getMessage();
        }
    }
    // Instantiate if classes are available
    if (!$class_ghtk && class_exists('class_ghtk')) {
        $class_ghtk = new class_ghtk();
    }
    if (!$class_superai && class_exists('class_superai')) {
        $class_superai = new class_superai();
    }
    $debug['class_status']['class_ghtk'] = $class_ghtk ? true : false;
    $debug['class_status']['class_superai'] = $class_superai ? true : false;

    if (!$class_ghtk || !$class_superai) {
        http_response_code(500);
        echo json_encode([
            "success" => false,
            "message" => "Thiếu file class vận chuyển. Hãy tải lên class_ghtk.php và class_superai.php vào thư mục: /home/themes/socdo/action/process",
            "hint" => __DIR__
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }

    $method = $_SERVER['REQUEST_METHOD'];
    // Accept both GET (query) and POST (JSON)
    $params = [];
    if ($method === 'POST') {
        $raw = file_get_contents('php://input');
        $decodedBody = json_decode($raw, true);
        if (is_array($decodedBody)) $params = $decodedBody;
    }
    if ($method === 'GET') {
        $params = $_GET;
    }

    // Input params (mode 1: explicit address + totals)
    $sender_province   = trim($params['sender_province'] ?? '');
    $sender_district   = trim($params['sender_district'] ?? '');
    $sender_ward       = trim($params['sender_ward'] ?? '');
    $receiver_province = trim($params['receiver_province'] ?? '');
    $receiver_district = trim($params['receiver_district'] ?? '');
    $receiver_ward     = trim($params['receiver_ward'] ?? '');
    $weight            = intval($params['weight'] ?? 0); // gram
    $value             = intval($params['value'] ?? 0);  // VND
    $length            = floatval($params['length'] ?? 0); // cm (reserved)
    $width             = floatval($params['width'] ?? 0);  // cm (reserved)
    $height            = floatval($params['height'] ?? 0); // cm (reserved)

    // Input params (mode 2: user_id + items -> server tự tính tổng + địa chỉ mặc định)
    $user_id = intval($params['user_id'] ?? 0);
    $items = $params['items'] ?? [];
    if (!empty($items)) {
        $debug['mode'] = 'user_id+items';
        $debug['items_input'] = $items; // Log input items
        // Tính tổng từ DB sanpham
        $total_weight = 0; // gram
        $total_value = 0;  // VND
        $debug['item_weights'] = [];
        foreach ($items as $it) {
            $pid = intval($it['product_id'] ?? 0);
            $qty = max(1, intval($it['quantity'] ?? 1));
            if ($pid <= 0) continue;
            if (isset($conn) && $conn) {
                $q = mysqli_query($conn, "SELECT gia_moi, can_nang_tinhship, shop FROM sanpham WHERE id='$pid' LIMIT 1");
                $debug['query_executed'] = "SELECT gia_moi, can_nang_tinhship, shop FROM sanpham WHERE id='$pid' LIMIT 1";
                if (!$q) {
                    $debug['query_error'] = mysqli_error($conn);
                }
                if ($q && mysqli_num_rows($q) > 0) {
                    $r = mysqli_fetch_assoc($q);
                    $price = intval($r['gia_moi'] ?? 0);
                    $shopOfItem = intval($r['shop'] ?? 0);

                    // can_nang_tinhship trong DB là INT (gram), không có đơn vị
                    $w_gram_per_item = intval($r['can_nang_tinhship'] ?? 0);

                    // Nếu không có hoặc = 0, dùng mặc định 500g
                    if ($w_gram_per_item <= 0) {
                        $w_gram_per_item = 500;
                    }

                    // Giới hạn an toàn: 30g - 5000g (0.03kg - 5kg)
                    if ($w_gram_per_item < 30) $w_gram_per_item = 30;
                    if ($w_gram_per_item > 5000) $w_gram_per_item = 5000;
                    $line_value = $price * $qty;
                    $line_weight = $w_gram_per_item * $qty;
                    $total_value += $line_value;
                    $total_weight += $line_weight;
                    $debug['item_weights'][] = [
                        'product_id' => $pid,
                        'qty' => $qty,
                        'w_gram_per_item' => $w_gram_per_item,
                        'price' => $price,
                        'line_value' => $line_value,
                        'line_weight' => $line_weight,
                        'shop' => $shopOfItem
                    ];
                } else {
                    $debug['db_error'] = isset($conn) ? mysqli_error($conn) : 'no conn';
                }
            } else {
                $debug['db_error'] = 'no mysqli $conn available to read sanpham';
            }
        }
        if ($total_weight > 0) $weight = $total_weight;
        if ($total_value  > 0) $value  = $total_value;
        $debug['totals'] = ['weight' => $weight, 'value' => $value];
        // Debug chi tiết cân nặng từng sản phẩm
        $debug['weight_breakdown'] = [
            'total_items' => count($items),
            'total_weight_grams' => $weight,
            'total_weight_kg' => round($weight / 1000, 3),
            'items_detail' => $debug['item_weights'] ?? []
        ];

        // Lấy địa chỉ mặc định của user làm receiver nếu chưa truyền vào
        if ($user_id > 0 && (empty($receiver_province) || empty($receiver_district))) {
            if (isset($conn) && $conn) {
                $rs = mysqli_query($conn, "SELECT ten_tinh, ten_huyen, ten_xa FROM dia_chi WHERE user_id='$user_id' AND active='1' LIMIT 1");
                if ($rs && mysqli_num_rows($rs) > 0) {
                    $addr = mysqli_fetch_assoc($rs);
                    $receiver_province = $addr['ten_tinh'] ?? $receiver_province;
                    $receiver_district = $addr['ten_huyen'] ?? $receiver_district;
                    $receiver_ward     = $addr['ten_xa'] ?? $receiver_ward;
                } else {
                    $debug['db_error'] = isset($conn) ? mysqli_error($conn) : 'no conn';
                }
            } else {
                $debug['db_error'] = 'no mysqli $conn available to read dia_chi';
            }
        }
        // Địa chỉ gửi mặc định nếu thiếu
        if (empty($sender_province)) $sender_province = 'Thành phố Hà Nội';
        if (empty($sender_district)) $sender_district = 'Nam Từ Liêm';
    }

    // Basic validations
    if (empty($sender_province) || empty($sender_district) || empty($receiver_province) || empty($receiver_district)) {
        http_response_code(400);
        echo json_encode(["success" => false, "message" => "Thiếu địa chỉ gửi/nhận (province, district)", "debug" => $debug], JSON_UNESCAPED_UNICODE);
        exit;
    }
    if ($weight <= 0) {
        http_response_code(400);
        echo json_encode(["success" => false, "message" => "Thiếu hoặc sai trọng lượng (weight, gram)", "debug" => $debug], JSON_UNESCAPED_UNICODE);
        exit;
    }

    // Freeship: chuẩn bị loại trừ trọng lượng và hỗ trợ tiền ship theo cấu hình transport
    $exclude_weight = 0; // loại trừ trọng lượng (gram) cho item được freeship theo shop=1 hoặc per-product
    $exclude_value  = 0; // loại trừ giá trị (VND)
    $ship_fixed_support = 0; // giảm cố định theo mode 0
    $ship_percent_support = 0; // giảm theo % theo mode 2 (cộng dồn, tối đa 100)
    $debug['shop_freeship_details'] = [];
    $product_freeship_info = []; // Thông tin freeship cho từng sản phẩm

    error_log('🚢 DEBUG: items=' . json_encode($items) . ', has_conn=' . (isset($conn) && $conn ? 'YES' : 'NO'));

    if (!empty($items) && isset($conn) && $conn) {
        error_log('🚢 FREESHIP LOGIC START - Processing ' . count($items) . ' items');

        // Gom theo shop và subtotal
        $shop_totals = [];
        $shop_items = [];
        error_log('🚢 item_weights count: ' . count($debug['item_weights'] ?? []));
        foreach (($debug['item_weights'] ?? []) as $row) {
            $shop = intval($row['shop'] ?? 0);
            $shop_totals[$shop] = ($shop_totals[$shop] ?? 0) + intval($row['line_value'] ?? 0);
            $shop_items[$shop][] = ['sp_id' => intval($row['product_id'] ?? 0), 'line_weight' => intval($row['line_weight'] ?? 0), 'line_value' => intval($row['line_value'] ?? 0)];
        }

        error_log('🚢 Found ' . count($shop_totals) . ' shops: ' . json_encode(array_keys($shop_totals)));
        foreach ($shop_totals as $sid => $total) {
            error_log("🚢 Shop $sid: total = $total VND");
        }
        foreach ($shop_totals as $shopId => $subtotal) {
            // Check ALL transport records for this shop (not just LIMIT 1)
            $tq = mysqli_query($conn, "SELECT free_ship_all, free_ship_min_order, free_ship_discount, fee_ship_products FROM transport WHERE user_id='$shopId'");

            error_log("🚢 Checking shop $shopId for freeship config...");

            if ($tq && mysqli_num_rows($tq) > 0) {
                $debug['shop_freeship_details'][$shopId] = [
                    'mode' => 0,
                    'subtotal' => $subtotal,
                    'min_order' => 0,
                    'discount' => 0,
                    'applied' => false
                ];
                
                // Process ALL records for this shop
                while ($t = mysqli_fetch_assoc($tq)) {
                    $mode = intval($t['free_ship_all'] ?? 0);
                    $minOrder = intval($t['free_ship_min_order'] ?? 0);
                    $discount = floatval($t['free_ship_discount'] ?? 0);
                    $feeShipProducts = $t['fee_ship_products'] ?? '';

                    error_log("🚢 Shop $shopId record: mode=$mode, minOrder=$minOrder, discount=$discount, fee_ship_products=" . (empty($feeShipProducts) ? 'EMPTY' : 'HAS_DATA'));

                    // Update debug with the first (primary) record
                    if (!$debug['shop_freeship_details'][$shopId]['applied']) {
                        $debug['shop_freeship_details'][$shopId]['mode'] = $mode;
                        $debug['shop_freeship_details'][$shopId]['min_order'] = $minOrder;
                        $debug['shop_freeship_details'][$shopId]['discount'] = $discount;
                    }

                    // Check fee_ship_products FIRST (highest priority)
                    if (!empty($feeShipProducts)) {
                        $arr = json_decode($feeShipProducts, true);
                        if (is_array($arr)) {
                            if (!isset($debug['shop_freeship_details'][$shopId]['products'])) {
                                $debug['shop_freeship_details'][$shopId]['products'] = [];
                            }
                            error_log("🚢 Shop $shopId: MODE $mode - Checking fee_ship_products, found " . count($arr) . " product configs");
                            foreach ($arr as $cfg) {
                                $spId = intval($cfg['sp_id'] ?? 0);
                                $stype = ($cfg['ship_type'] ?? 'vnd'); // 'vnd' | 'percent'
                                $val = floatval($cfg['ship_support'] ?? 0);
                                
                                foreach (($shop_items[$shopId] ?? []) as $si) {
                                    if ($si['sp_id'] == $spId && $val > 0) {
                                        if ($stype === 'percent') {
                                            $ship_percent_support += $val;
                                            $debug['shop_freeship_details'][$shopId]['products'][$spId] = ['type' => 'percent', 'value' => $val];
                                            error_log("🚢 ✅ Shop $shopId: PRODUCT-SPECIFIC - Product $spId - Percent discount = $val%");
                                            
                                            // Lưu thông tin freeship cho sản phẩm
                                            $product_freeship_info[$spId] = [
                                                'freeship_type' => 'percent',
                                                'freeship_label' => 'Giảm ' . intval($val) . '% ship',
                                                'freeship_amount' => $val,
                                                'shop_id' => $shopId
                                            ];
                                        } else {
                                            $ship_fixed_support += intval($val);
                                            $debug['shop_freeship_details'][$shopId]['products'][$spId] = ['type' => 'fixed', 'value' => $val];
                                            error_log("🚢 ✅ Shop $shopId: PRODUCT-SPECIFIC - Product $spId - Fixed discount = " . intval($val) . " VND");
                                            
                                            // Lưu thông tin freeship cho sản phẩm
                                            $product_freeship_info[$spId] = [
                                                'freeship_type' => 'fixed',
                                                'freeship_label' => 'Hỗ trợ ship ' . number_format($val) . '₫',
                                                'freeship_amount' => intval($val),
                                                'shop_id' => $shopId
                                            ];
                                        }
                                        // Loại trừ weight/value cho sản phẩm này
                                        $exclude_weight += $si['line_weight']; 
                                        $exclude_value += $si['line_value'];
                                        $debug['shop_freeship_details'][$shopId]['applied'] = true;
                                        $debug['shop_freeship_details'][$shopId]['type'] = 'per_product';
                                    }
                                }
                            }
                        }
                    }
                    
                    // Then check mode-based freeship (only if no product-specific freeship applied)
                    if (!$debug['shop_freeship_details'][$shopId]['applied']) {
                        if ($mode === 1) {
                            // Miễn toàn bộ ship cho shop này → loại trừ trọng lượng/value shop này
                            $excluded_w = 0;
                            $excluded_v = 0;
                            foreach (($shop_items[$shopId] ?? []) as $si) {
                                $exclude_weight += $si['line_weight'];
                                $exclude_value += $si['line_value'];
                                $excluded_w += $si['line_weight'];
                                $excluded_v += $si['line_value'];
                            }
                            $debug['shop_freeship_details'][$shopId]['applied'] = true;
                            $debug['shop_freeship_details'][$shopId]['type'] = 'full_exclusion';
                            $debug['shop_freeship_details'][$shopId]['excluded_weight'] = $excluded_w;
                            $debug['shop_freeship_details'][$shopId]['excluded_value'] = $excluded_v;
                            error_log("🚢 ✅ Shop $shopId: MODE 1 - Freeship 100% - Excluded weight=$excluded_w, value=$excluded_v");
                        } else if ($mode === 0) {
                            // Giảm cố định
                            if ($subtotal >= $minOrder && $discount > 0) {
                                $ship_fixed_support += intval($discount);
                                $debug['shop_freeship_details'][$shopId]['applied'] = true;
                                $debug['shop_freeship_details'][$shopId]['type'] = 'fixed_discount';
                                $debug['shop_freeship_details'][$shopId]['applied_amount'] = intval($discount);
                                error_log("🚢 ✅ Shop $shopId: MODE 0 - Fixed discount = " . intval($discount) . " VND");
                            } else {
                                error_log("🚢 ❌ Shop $shopId: MODE 0 - NOT APPLIED (subtotal=$subtotal < minOrder=$minOrder OR discount=$discount <= 0)");
                            }
                        } else if ($mode === 2) {
                            // Giảm theo %
                            if ($subtotal >= $minOrder && $discount > 0) {
                                $ship_percent_support += $discount;
                                $debug['shop_freeship_details'][$shopId]['applied'] = true;
                                $debug['shop_freeship_details'][$shopId]['type'] = 'percent_discount';
                                $debug['shop_freeship_details'][$shopId]['applied_percent'] = $discount;
                                error_log("🚢 ✅ Shop $shopId: MODE 2 - Percent discount = $discount%");
                            } else {
                                error_log("🚢 ❌ Shop $shopId: MODE 2 - NOT APPLIED (subtotal=$subtotal < minOrder=$minOrder OR discount=$discount <= 0)");
                            }
                        } else {
                            error_log("🚢 ❌ Shop $shopId: No freeship config OR mode not recognized (mode=$mode)");
                        }
                    }
                }
            } else {
                error_log("🚢 ❌ Shop $shopId: No transport record found in database");
            }
        }

        error_log("🚢 FREESHIP SUMMARY: exclude_weight=$exclude_weight, exclude_value=$exclude_value, ship_fixed_support=$ship_fixed_support, ship_percent_support=$ship_percent_support");
    }

    $weight_to_quote = max(30, $weight - $exclude_weight);
    $value_to_quote  = max(0, $value  - $exclude_value);

    error_log("🚢 WEIGHT CALCULATION: total_weight=$weight - exclude_weight=$exclude_weight = weight_to_quote=$weight_to_quote");
    error_log("🚢 VALUE CALCULATION: total_value=$value - exclude_value=$exclude_value = value_to_quote=$value_to_quote");

    $debug['freeship_excluded'] = [
        'weight' => $exclude_weight,
        'value' => $exclude_value,
        'weight_to_quote' => $weight_to_quote,
        'value_to_quote' => $value_to_quote,
        'ship_fixed_support' => $ship_fixed_support,
        'ship_percent_support' => $ship_percent_support
    ];

    // 1) Quote from SUPERAI (returns multiple carriers), pick min
    $quotes = [];
    $best_overall = null;
    $best_fee = PHP_INT_MAX;

    try {
        $superai_res = $class_superai->get_fee($sender_province, $sender_district, $receiver_province, $receiver_district, $weight_to_quote, $value_to_quote);
        $debug['superai_raw'] = $superai_res;
        $superai_json = json_decode($superai_res, true);
        if (isset($superai_json['error']) && $superai_json['error'] === false && !empty($superai_json['data']['services'])) {
            foreach ($superai_json['data']['services'] as $svc) {
                if (isset($svc['carrier_id']) && $svc['carrier_id'] == 7) continue; // skip Ninja Van
                $carrier_name = $svc['carrier_name'] ?? 'Unknown';
                $fee = intval(($svc['shipment_fee'] ?? 0) + ($svc['insurance_fee'] ?? 0));
                $q = [
                    'provider' => 'SUPERAI',
                    'carrier_name' => $carrier_name,
                    'carrier_id' => $svc['carrier_id'] ?? 0,
                    'fee' => $fee,
                    'eta_text' => ($svc['estimated_delivery'] ?? ''),
                    'raw' => $svc
                ];
                $quotes[] = $q;
                if ($fee > 0 && $fee < $best_fee) {
                    $best_fee = $fee;
                    $best_overall = $q;
                }
            }
        }
    } catch (Exception $e) {
        // ignore
    }


    // 2) Quote from GHTK (using local tariff via get_tax)
    try {
        $sender_mien   = get_mien_by_province_name(isset($conn) ? $conn : null, $sender_province);
        $receiver_mien = get_mien_by_province_name(isset($conn) ? $conn : null, $receiver_province);
        $ghtk_res = $class_ghtk->get_tax($weight_to_quote, $value_to_quote, $sender_province, $sender_mien, $receiver_province, $receiver_mien, false, false);
        $debug['ghtk_raw'] = $ghtk_res;
        $ghtk_json = json_decode($ghtk_res, true);
        if (is_array($ghtk_json)) {
            $fee = intval($ghtk_json['phi_tong'] ?? 0);
            $q = [
                'provider' => 'GHTK',
                'carrier_name' => 'Giao Hang Tiet Kiem',
                'carrier_id' => 0,
                'fee' => $fee,
                'raw' => $ghtk_json
            ];
            $quotes[] = $q;
            if ($fee > 0 && $fee < $best_fee) {
                $best_fee = $fee;
                $best_overall = $q;
            }
        }
    } catch (Exception $e) {
        // ignore
    }

    // Sort quotes asc by fee
    usort($quotes, function ($a, $b) {
        return ($a['fee'] <=> $b['fee']);
    });

    $best_simple = $best_overall ? [
        'fee' => $best_overall['fee'] ?? 0,
        'provider' => ($best_overall['provider'] ?? '') . (isset($best_overall['carrier_name']) && $best_overall['carrier_name'] ? (' (' . $best_overall['carrier_name'] . ')') : ''),
        // ETA: ưu tiên ETA thật từ SUPERAI nếu có, nếu không thì dùng heuristic
        'eta_text' => (!empty($best_overall['eta_text']))
            ? $best_overall['eta_text']
            : ((stripos($sender_province, $receiver_province) !== false)
                ? ('Dự kiến từ ' . date('d/m', strtotime('+1 days')) . ' - ' . date('d/m', strtotime('+2 days')))
                : ('Dự kiến từ ' . date('d/m', strtotime('+2 days')) . ' - ' . date('d/m', strtotime('+4 days')))),
    ] : ['fee' => 0, 'provider' => '', 'eta_text' => ''];

    // Sau khi có best_overall, áp hỗ trợ freeship
    $fee_before_support = 0;
    $total_support = 0;
    if ($best_overall) {
        $fee_before_support = intval($best_overall['fee'] ?? 0);

        // Nếu đã loại trừ 100% weight/value (MODE 1 hoặc MODE 3 full), fee = 0
        if ($exclude_weight > 0 && $exclude_weight >= $weight) {
            $final_fee = 0;
            $total_support = $fee_before_support;
            error_log("🚢 FREESHIP 100% APPLIED - Fee reduced from $fee_before_support to 0");
        } else {
            // Áp dụng fixed support và percent support
            $support_fee = $ship_fixed_support;
            if ($ship_percent_support > 0) {
                $support_fee += intval(round($fee_before_support * ($ship_percent_support / 100.0)));
            }
            $total_support = $support_fee;
            $final_fee = max(0, $fee_before_support - $support_fee);

            error_log("🚢 PARTIAL FREESHIP APPLIED:");
            error_log("🚢   fee_before_support = $fee_before_support VND");
            error_log("🚢   ship_fixed_support = $ship_fixed_support VND");
            error_log("🚢   ship_percent_support = $ship_percent_support%");
            error_log("🚢   total_support = $total_support VND");
            error_log("🚢   FINAL FEE = $final_fee VND");
        }

        $best_overall['fee'] = $final_fee;
        $best_simple['fee'] = $final_fee;

        // Update all quotes
        foreach ($quotes as &$q) {
            if ($exclude_weight > 0 && $exclude_weight >= $weight) {
                $q['fee'] = 0;
            } else if ($total_support > 0) {
                $q['fee'] = max(0, $q['fee'] - $total_support);
            }
        }

        $debug['final_fee_calculation'] = [
            'fee_before_support' => $fee_before_support,
            'exclude_weight' => $exclude_weight,
            'total_weight' => $weight,
            'freeship_100_applied' => ($exclude_weight > 0 && $exclude_weight >= $weight),
            'ship_fixed_support' => $ship_fixed_support,
            'ship_percent_support' => $ship_percent_support,
            'total_support' => $total_support,
            'final_fee' => $final_fee
        ];
    }

    $response = [
        'success' => true,
        'message' => 'Lấy báo giá vận chuyển thành công',
        'data' => [
            'input' => [
                'sender_province' => $sender_province,
                'sender_district' => $sender_district,
                'sender_ward' => $sender_ward,
                'receiver_province' => $receiver_province,
                'receiver_district' => $receiver_district,
                'receiver_ward' => $receiver_ward,
                'weight' => $weight,
                'value' => $value,
                'length' => $length,
                'width' => $width,
                'height' => $height
            ],
            'quotes' => $quotes,
            'best' => $best_overall ?: ['provider' => '', 'carrier_name' => '', 'fee' => 0],
            'best_simple' => $best_simple,
            'freeship_info' => [
                'product_freeship' => $product_freeship_info,
                'total_fixed_support' => $ship_fixed_support,
                'total_percent_support' => $ship_percent_support,
                'excluded_weight' => $exclude_weight,
                'excluded_value' => $exclude_value
            ],
            'debug' => $debug,
        ]
    ];


    http_response_code(200);
    echo json_encode($response, JSON_UNESCAPED_UNICODE);
} catch (Throwable $e) {
    // Trả 500 với thông tin lỗi rõ ràng để debug thay vì 401
    http_response_code(500);
    echo json_encode(array(
        "success" => false,
        "message" => "Lỗi xử lý shipping_quote",
        "error" => $e->getMessage()
    ), JSON_UNESCAPED_UNICODE);
}
