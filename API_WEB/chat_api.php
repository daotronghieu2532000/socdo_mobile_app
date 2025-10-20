<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Xử lý preflight request
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once __DIR__ . '/../../includes/config.php';
require_once __DIR__ . '/../../includes/tlca_world.php';

// Polyfill getallheaders for non-Apache environments (e.g., Nginx + PHP-FPM)
if (!function_exists('getallheaders')) {
    function getallheaders() {
        $headers = [];
        foreach ($_SERVER as $name => $value) {
            if (substr($name, 0, 5) === 'HTTP_') {
                $key = str_replace(' ', '-', ucwords(strtolower(str_replace('_', ' ', substr($name, 5)))));
                $headers[$key] = $value;
            }
        }
        return $headers;
    }
}

// JWT Authentication
function verifyJWT($token) {
    $key = 'Socdo123@2025';
    $issuer = 'api.socdo.vn';
    
    try {
        $decoded = json_decode(base64_decode(str_replace(['-', '_'], ['+', '/'], explode('.', $token)[1])), true);
        
        if ($decoded['iss'] !== $issuer) {
            return false;
        }
        
        if ($decoded['exp'] < time()) {
            return false;
        }
        
        return $decoded;
    } catch (Exception $e) {
        return false;
    }
}

// Lấy action từ request
$action = $_POST['action'] ?? $_GET['action'] ?? '';

// Debug: ghi log request đến để truy vết lỗi 500
error_log('[CHAT_API] action=' . $action);
error_log('[CHAT_API] headers=' . json_encode(getallheaders()));
error_log('[CHAT_API] _POST=' . json_encode($_POST));
error_log('[CHAT_API] _GET=' . json_encode($_GET));

// Kiểm tra JWT token
$headers = getallheaders();
$token = null;

if (isset($headers['Authorization'])) {
    $token = str_replace('Bearer ', '', $headers['Authorization']);
} elseif (isset($_POST['token'])) {
    $token = $_POST['token'];
} elseif (isset($_GET['token'])) {
    $token = $_GET['token'];
}

if (!$token) {
    http_response_code(401);
    echo json_encode([
        'success' => false,
        'message' => 'Token không được cung cấp'
    ]);
    exit;
}

$user_data = verifyJWT($token);
if (!$user_data) {
    http_response_code(401);
    echo json_encode([
        'success' => false,
        'message' => 'Token không hợp lệ hoặc đã hết hạn'
    ]);
    exit;
}

$user_id = $user_data['user_id'];
$user_type = $user_data['user_type'] ?? 'customer'; // customer hoặc ncc

// === TẠO PHIÊN CHAT ===
if ($action === 'create_session') {
    $shop_id = intval($_POST['shop_id'] ?? 0);
    
    if (!$shop_id) {
        echo json_encode([
            'success' => false,
            'message' => 'Thiếu shop_id'
        ]);
        exit;
    }
    
    // Kiểm tra shop có tồn tại không
    $check_shop = mysqli_query($conn, "SELECT user_id, name, avatar FROM user_info WHERE user_id = $shop_id AND active = 1 LIMIT 1");
    if (!$check_shop || mysqli_num_rows($check_shop) == 0) {
        echo json_encode([
            'success' => false,
            'message' => 'Shop không tồn tại'
        ]);
        exit;
    }
    
    $shop_info = mysqli_fetch_assoc($check_shop);
    
    // Kiểm tra phiên chat đã tồn tại chưa
    $check_session = mysqli_query($conn, "SELECT id, phien FROM chat_sessions_ncc WHERE shop_id = $shop_id AND customer_id = $user_id AND status = 'active' LIMIT 1");
    
    if ($check_session && mysqli_num_rows($check_session) > 0) {
        $session = mysqli_fetch_assoc($check_session);
        echo json_encode([
            'success' => true,
            'session_id' => $session['id'],
            'phien' => $session['phien'],
            'shop_info' => [
                'shop_id' => $shop_info['user_id'],
                'shop_name' => $shop_info['name'],
                'shop_avatar' => $shop_info['avatar'] ?: '/images/user.png'
            ]
        ]);
        exit;
    }
    
    // Tạo phiên chat mới
    $phien = md5($shop_id . '_' . $user_id . '_' . time() . '_' . rand(1000, 9999));
    $now = time();
    
    $create_session = mysqli_query($conn, "INSERT INTO chat_sessions_ncc (phien, shop_id, customer_id, last_message_time, created_at) VALUES ('$phien', $shop_id, $user_id, $now, $now)");
    
    if ($create_session) {
        $session_id = mysqli_insert_id($conn);
        echo json_encode([
            'success' => true,
            'session_id' => $session_id,
            'phien' => $phien,
            'shop_info' => [
                'shop_id' => $shop_info['user_id'],
                'shop_name' => $shop_info['name'],
                'shop_avatar' => $shop_info['avatar'] ?: '/images/user.png'
            ]
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'Không thể tạo phiên chat'
        ]);
    }
    exit;
}

// === DANH SÁCH PHIÊN CHAT ===
if ($action === 'list_sessions') {
    $page = intval($_POST['page'] ?? $_GET['page'] ?? 1);
    $limit = intval($_POST['limit'] ?? $_GET['limit'] ?? 20);
    $offset = ($page - 1) * $limit;
    
    if ($user_type === 'ncc') {
        // NCC xem danh sách chat với khách hàng
        $sql = "SELECT 
                    s.id as session_id,
                    s.phien,
                    s.customer_id,
                    s.unread_count_ncc,
                    s.last_message_time,
                    ui.name as customer_name,
                    ui.avatar as customer_avatar,
                    c.noi_dung as last_message,
                    c.date_post as last_message_time_detail
                FROM chat_sessions_ncc s
                LEFT JOIN user_info ui ON s.customer_id = ui.user_id
                LEFT JOIN chat_ncc c ON s.phien = c.phien AND c.id = (
                    SELECT MAX(id) FROM chat_ncc WHERE phien = s.phien
                )
                WHERE s.shop_id = $user_id AND s.status = 'active'
                ORDER BY s.last_message_time DESC
                LIMIT $limit OFFSET $offset";
    } else {
        // Customer xem danh sách chat với NCC
        $sql = "SELECT 
                    s.id as session_id,
                    s.phien,
                    s.shop_id,
                    s.unread_count_customer,
                    s.last_message_time,
                    ui.name as shop_name,
                    ui.avatar as shop_avatar,
                    c.noi_dung as last_message,
                    c.date_post as last_message_time_detail
                FROM chat_sessions_ncc s
                LEFT JOIN user_info ui ON s.shop_id = ui.user_id
                LEFT JOIN chat_ncc c ON s.phien = c.phien AND c.id = (
                    SELECT MAX(id) FROM chat_ncc WHERE phien = s.phien
                )
                WHERE s.customer_id = $user_id AND s.status = 'active'
                ORDER BY s.last_message_time DESC
                LIMIT $limit OFFSET $offset";
    }
    
    $result = mysqli_query($conn, $sql);
    $sessions = [];
    
    while ($row = mysqli_fetch_assoc($result)) {
        if ($user_type === 'ncc') {
            $sessions[] = [
                'session_id' => intval($row['session_id']),
                'phien' => $row['phien'],
                'customer_id' => intval($row['customer_id']),
                'customer_name' => $row['customer_name'] ?: 'Khách #' . $row['customer_id'],
                'customer_avatar' => $row['customer_avatar'] ?: '/images/user.png',
                'last_message' => $row['last_message'] ?: '',
                'last_message_time' => intval($row['last_message_time']),
                'last_message_formatted' => $row['last_message_time_detail'] ? date('H:i d/m/Y', $row['last_message_time_detail']) : '',
                'unread_count' => intval($row['unread_count_ncc'])
            ];
        } else {
            $sessions[] = [
                'session_id' => intval($row['session_id']),
                'phien' => $row['phien'],
                'shop_id' => intval($row['shop_id']),
                'shop_name' => $row['shop_name'] ?: 'Shop #' . $row['shop_id'],
                'shop_avatar' => $row['shop_avatar'] ?: '/images/user.png',
                'last_message' => $row['last_message'] ?: '',
                'last_message_time' => intval($row['last_message_time']),
                'last_message_formatted' => $row['last_message_time_detail'] ? date('H:i d/m/Y', $row['last_message_time_detail']) : '',
                'unread_count' => intval($row['unread_count_customer'])
            ];
        }
    }
    
    // Đếm tổng số phiên
    $count_sql = $user_type === 'ncc' 
        ? "SELECT COUNT(*) as total FROM chat_sessions_ncc WHERE shop_id = $user_id AND status = 'active'"
        : "SELECT COUNT(*) as total FROM chat_sessions_ncc WHERE customer_id = $user_id AND status = 'active'";
    
    $count_result = mysqli_query($conn, $count_sql);
    $total = mysqli_fetch_assoc($count_result)['total'];
    
    echo json_encode([
        'success' => true,
        'sessions' => $sessions,
        'pagination' => [
            'current_page' => $page,
            'per_page' => $limit,
            'total' => intval($total),
            'total_pages' => ceil($total / $limit)
        ]
    ]);
    exit;
}

// === LẤY TIN NHẮN ===
if ($action === 'get_messages') {
    $session_id = intval($_POST['session_id'] ?? $_GET['session_id'] ?? 0);
    $phien = $_POST['phien'] ?? $_GET['phien'] ?? '';
    $page = intval($_POST['page'] ?? $_GET['page'] ?? 1);
    $limit = intval($_POST['limit'] ?? $_GET['limit'] ?? 50);
    $offset = ($page - 1) * $limit;
    
    if (!$session_id && !$phien) {
        echo json_encode([
            'success' => false,
            'message' => 'Thiếu session_id hoặc phien'
        ]);
        exit;
    }
    
    // Lấy phien từ session_id nếu chưa có
    if (!$phien && $session_id) {
        $session_query = mysqli_query($conn, "SELECT phien FROM chat_sessions_ncc WHERE id = $session_id LIMIT 1");
        if ($session_query && mysqli_num_rows($session_query) > 0) {
            $session = mysqli_fetch_assoc($session_query);
            $phien = $session['phien'];
        }
    }
    
    if (!$phien) {
        echo json_encode([
            'success' => false,
            'message' => 'Không tìm thấy phiên chat'
        ]);
        exit;
    }
    
    // Kiểm tra quyền truy cập
    $check_access = mysqli_query($conn, "SELECT * FROM chat_sessions_ncc WHERE phien = '$phien' AND (shop_id = $user_id OR customer_id = $user_id) LIMIT 1");
    if (!$check_access || mysqli_num_rows($check_access) == 0) {
        echo json_encode([
            'success' => false,
            'message' => 'Không có quyền truy cập phiên chat này'
        ]);
        exit;
    }
    
    // Lấy tin nhắn
    $sql = "SELECT 
                c.id,
                c.sender_id,
                c.sender_type,
                c.noi_dung,
                c.date_post,
                c.doc,
                ui.name as sender_name,
                ui.avatar as sender_avatar
            FROM chat_ncc c
            LEFT JOIN user_info ui ON c.sender_id = ui.user_id
            WHERE c.phien = '$phien' AND c.active = 1
            ORDER BY c.date_post DESC
            LIMIT $limit OFFSET $offset";
    
    $result = mysqli_query($conn, $sql);
    $messages = [];
    
    while ($row = mysqli_fetch_assoc($result)) {
        $messages[] = [
            'id' => intval($row['id']),
            'sender_id' => intval($row['sender_id']),
            'sender_type' => $row['sender_type'],
            'sender_name' => $row['sender_name'] ?: ($row['sender_type'] === 'ncc' ? 'Nhà bán' : 'Khách hàng'),
            'sender_avatar' => $row['sender_avatar'] ?: '/images/user.png',
            'message' => $row['noi_dung'],
            'date_post' => intval($row['date_post']),
            'date_formatted' => date('H:i d/m/Y', $row['date_post']),
            'is_read' => intval($row['doc']),
            'is_own' => ($row['sender_id'] == $user_id)
        ];
    }
    
    // Đảo ngược để hiển thị tin nhắn cũ trước
    $messages = array_reverse($messages);
    
    // Đếm tổng số tin nhắn
    $count_sql = "SELECT COUNT(*) as total FROM chat_ncc WHERE phien = '$phien' AND active = 1";
    $count_result = mysqli_query($conn, $count_sql);
    $total = mysqli_fetch_assoc($count_result)['total'];
    
    echo json_encode([
        'success' => true,
        'messages' => $messages,
        'phien' => $phien,
        'pagination' => [
            'current_page' => $page,
            'per_page' => $limit,
            'total' => intval($total),
            'total_pages' => ceil($total / $limit)
        ]
    ]);
    exit;
}

// === GỬI TIN NHẮN ===
if ($action === 'send_message') {
    $session_id = intval($_POST['session_id'] ?? 0);
    $phien = $_POST['phien'] ?? '';
    $message = trim($_POST['message'] ?? '');
    $product_id = intval($_POST['product_id'] ?? 0);
    $variant_id = intval($_POST['variant_id'] ?? 0);
    
    if (!$message) {
        echo json_encode([
            'success' => false,
            'message' => 'Nội dung tin nhắn không được để trống'
        ]);
        exit;
    }
    
    if (!$session_id && !$phien) {
        echo json_encode([
            'success' => false,
            'message' => 'Thiếu session_id hoặc phien'
        ]);
        exit;
    }
    
    // Lấy thông tin phiên chat
    if ($phien) {
        $session_query = mysqli_query($conn, "SELECT * FROM chat_sessions_ncc WHERE phien = '$phien' LIMIT 1");
    } else {
        $session_query = mysqli_query($conn, "SELECT * FROM chat_sessions_ncc WHERE id = $session_id LIMIT 1");
    }
    
    if (!$session_query || mysqli_num_rows($session_query) == 0) {
        echo json_encode([
            'success' => false,
            'message' => 'Phiên chat không tồn tại'
        ]);
        exit;
    }
    
    $session = mysqli_fetch_assoc($session_query);
    $phien = $session['phien'];
    $shop_id = $session['shop_id'];
    $customer_id = $session['customer_id'];
    
    // Kiểm tra quyền gửi tin nhắn
    if ($user_type === 'ncc' && $user_id != $shop_id) {
        echo json_encode([
            'success' => false,
            'message' => 'Không có quyền gửi tin nhắn'
        ]);
        exit;
    }
    
    if ($user_type === 'customer' && $user_id != $customer_id) {
        echo json_encode([
            'success' => false,
            'message' => 'Không có quyền gửi tin nhắn'
        ]);
        exit;
    }
    
    // Xác định sender_type
    $sender_type = $user_type === 'ncc' ? 'ncc' : 'customer';
    $sender_id = $user_id;
    $date_post = time();
    
    // Lưu tin nhắn
    $insert_sql = "INSERT INTO chat_ncc (phien, shop_id, customer_id, sender_id, sender_type, noi_dung, doc, active, date_post, product_id, variant_id) 
                   VALUES ('$phien', $shop_id, $customer_id, $sender_id, '$sender_type', '" . mysqli_real_escape_string($conn, $message) . "', 0, 1, $date_post, $product_id, $variant_id)";
    
    $insert_result = mysqli_query($conn, $insert_sql);
    
    if ($insert_result) {
        $message_id = mysqli_insert_id($conn);
        
        // Cập nhật last_message_time
        mysqli_query($conn, "UPDATE chat_sessions_ncc SET last_message_time = $date_post WHERE phien = '$phien'");
        
        // Cập nhật unread_count
        if ($sender_type === 'customer') {
            mysqli_query($conn, "UPDATE chat_sessions_ncc SET unread_count_ncc = unread_count_ncc + 1 WHERE phien = '$phien'");
        } else {
            mysqli_query($conn, "UPDATE chat_sessions_ncc SET unread_count_customer = unread_count_customer + 1 WHERE phien = '$phien'");
        }
        
        // Lấy thông tin tin nhắn vừa gửi
        $message_query = mysqli_query($conn, "SELECT 
            c.*, 
            ui.name as sender_name, 
            ui.avatar as sender_avatar 
            FROM chat_ncc c 
            LEFT JOIN user_info ui ON c.sender_id = ui.user_id 
            WHERE c.id = $message_id LIMIT 1");
        
        $message_data = mysqli_fetch_assoc($message_query);
        
        echo json_encode([
            'success' => true,
            'message' => [
                'id' => intval($message_data['id']),
                'sender_id' => intval($message_data['sender_id']),
                'sender_type' => $message_data['sender_type'],
                'sender_name' => $message_data['sender_name'] ?: ($message_data['sender_type'] === 'ncc' ? 'Nhà bán' : 'Khách hàng'),
                'sender_avatar' => $message_data['sender_avatar'] ?: '/images/user.png',
                'message' => $message_data['noi_dung'],
                'date_post' => intval($message_data['date_post']),
                'date_formatted' => date('H:i d/m/Y', $message_data['date_post']),
                'is_read' => 0,
                'is_own' => true
            ]
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'Không thể gửi tin nhắn'
        ]);
    }
    exit;
}

// === ĐÁNH DẤU ĐÃ ĐỌC ===
if ($action === 'mark_read') {
    $session_id = intval($_POST['session_id'] ?? 0);
    $phien = $_POST['phien'] ?? '';
    
    if (!$session_id && !$phien) {
        echo json_encode([
            'success' => false,
            'message' => 'Thiếu session_id hoặc phien'
        ]);
        exit;
    }
    
    // Lấy thông tin phiên chat
    if ($phien) {
        $session_query = mysqli_query($conn, "SELECT * FROM chat_sessions_ncc WHERE phien = '$phien' LIMIT 1");
    } else {
        $session_query = mysqli_query($conn, "SELECT * FROM chat_sessions_ncc WHERE id = $session_id LIMIT 1");
    }
    
    if (!$session_query || mysqli_num_rows($session_query) == 0) {
        echo json_encode([
            'success' => false,
            'message' => 'Phiên chat không tồn tại'
        ]);
        exit;
    }
    
    $session = mysqli_fetch_assoc($session_query);
    $phien = $session['phien'];
    
    // Kiểm tra quyền truy cập
    if ($user_id != $session['shop_id'] && $user_id != $session['customer_id']) {
        echo json_encode([
            'success' => false,
            'message' => 'Không có quyền truy cập phiên chat này'
        ]);
        exit;
    }
    
    // Đánh dấu đã đọc
    if ($user_type === 'ncc') {
        mysqli_query($conn, "UPDATE chat_ncc SET doc = 1 WHERE phien = '$phien' AND sender_type = 'customer' AND doc = 0");
        mysqli_query($conn, "UPDATE chat_sessions_ncc SET unread_count_ncc = 0 WHERE phien = '$phien'");
    } else {
        mysqli_query($conn, "UPDATE chat_ncc SET doc = 1 WHERE phien = '$phien' AND sender_type = 'ncc' AND doc = 0");
        mysqli_query($conn, "UPDATE chat_sessions_ncc SET unread_count_customer = 0 WHERE phien = '$phien'");
    }
    
    echo json_encode([
        'success' => true,
        'message' => 'Đã đánh dấu đọc'
    ]);
    exit;
}

// === ĐẾM TIN NHẮN CHƯA ĐỌC ===
if ($action === 'get_unread_count') {
    if ($user_type === 'ncc') {
        $sql = "SELECT SUM(unread_count_ncc) as total FROM chat_sessions_ncc WHERE shop_id = $user_id AND status = 'active'";
    } else {
        $sql = "SELECT SUM(unread_count_customer) as total FROM chat_sessions_ncc WHERE customer_id = $user_id AND status = 'active'";
    }
    
    $result = mysqli_query($conn, $sql);
    $row = mysqli_fetch_assoc($result);
    $total = intval($row['total'] ?? 0);
    
    echo json_encode([
        'success' => true,
        'unread_count' => $total
    ]);
    exit;
}

// === ĐÓNG PHIÊN CHAT ===
if ($action === 'close_session') {
    $session_id = intval($_POST['session_id'] ?? 0);
    $phien = $_POST['phien'] ?? '';
    
    if (!$session_id && !$phien) {
        echo json_encode([
            'success' => false,
            'message' => 'Thiếu session_id hoặc phien'
        ]);
        exit;
    }
    
    // Lấy thông tin phiên chat
    if ($phien) {
        $session_query = mysqli_query($conn, "SELECT * FROM chat_sessions_ncc WHERE phien = '$phien' LIMIT 1");
    } else {
        $session_query = mysqli_query($conn, "SELECT * FROM chat_sessions_ncc WHERE id = $session_id LIMIT 1");
    }
    
    if (!$session_query || mysqli_num_rows($session_query) == 0) {
        echo json_encode([
            'success' => false,
            'message' => 'Phiên chat không tồn tại'
        ]);
        exit;
    }
    
    $session = mysqli_fetch_assoc($session_query);
    $phien = $session['phien'];
    
    // Kiểm tra quyền truy cập
    if ($user_id != $session['shop_id'] && $user_id != $session['customer_id']) {
        echo json_encode([
            'success' => false,
            'message' => 'Không có quyền đóng phiên chat này'
        ]);
        exit;
    }
    
    // Đóng phiên chat
    $close_result = mysqli_query($conn, "UPDATE chat_sessions_ncc SET status = 'closed' WHERE phien = '$phien'");
    
    if ($close_result) {
        echo json_encode([
            'success' => true,
            'message' => 'Đã đóng phiên chat'
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'Không thể đóng phiên chat'
        ]);
    }
    exit;
}

// === TÌM KIẾM TIN NHẮN ===
if ($action === 'search_messages') {
    $session_id = intval($_POST['session_id'] ?? $_GET['session_id'] ?? 0);
    $phien = $_POST['phien'] ?? $_GET['phien'] ?? '';
    $keyword = trim($_POST['keyword'] ?? $_GET['keyword'] ?? '');
    $page = intval($_POST['page'] ?? $_GET['page'] ?? 1);
    $limit = intval($_POST['limit'] ?? $_GET['limit'] ?? 20);
    $offset = ($page - 1) * $limit;
    
    if (!$keyword) {
        echo json_encode([
            'success' => false,
            'message' => 'Thiếu từ khóa tìm kiếm'
        ]);
        exit;
    }
    
    if (!$session_id && !$phien) {
        echo json_encode([
            'success' => false,
            'message' => 'Thiếu session_id hoặc phien'
        ]);
        exit;
    }
    
    // Lấy phien từ session_id nếu chưa có
    if (!$phien && $session_id) {
        $session_query = mysqli_query($conn, "SELECT phien FROM chat_sessions_ncc WHERE id = $session_id LIMIT 1");
        if ($session_query && mysqli_num_rows($session_query) > 0) {
            $session = mysqli_fetch_assoc($session_query);
            $phien = $session['phien'];
        }
    }
    
    if (!$phien) {
        echo json_encode([
            'success' => false,
            'message' => 'Không tìm thấy phiên chat'
        ]);
        exit;
    }
    
    // Kiểm tra quyền truy cập
    $check_access = mysqli_query($conn, "SELECT * FROM chat_sessions_ncc WHERE phien = '$phien' AND (shop_id = $user_id OR customer_id = $user_id) LIMIT 1");
    if (!$check_access || mysqli_num_rows($check_access) == 0) {
        echo json_encode([
            'success' => false,
            'message' => 'Không có quyền truy cập phiên chat này'
        ]);
        exit;
    }
    
    // Tìm kiếm tin nhắn
    $keyword_escaped = mysqli_real_escape_string($conn, $keyword);
    $sql = "SELECT 
                c.id,
                c.sender_id,
                c.sender_type,
                c.noi_dung,
                c.date_post,
                c.doc,
                ui.name as sender_name,
                ui.avatar as sender_avatar
            FROM chat_ncc c
            LEFT JOIN user_info ui ON c.sender_id = ui.user_id
            WHERE c.phien = '$phien' 
            AND c.active = 1 
            AND c.noi_dung LIKE '%$keyword_escaped%'
            ORDER BY c.date_post DESC
            LIMIT $limit OFFSET $offset";
    
    $result = mysqli_query($conn, $sql);
    $messages = [];
    
    while ($row = mysqli_fetch_assoc($result)) {
        $messages[] = [
            'id' => intval($row['id']),
            'sender_id' => intval($row['sender_id']),
            'sender_type' => $row['sender_type'],
            'sender_name' => $row['sender_name'] ?: ($row['sender_type'] === 'ncc' ? 'Nhà bán' : 'Khách hàng'),
            'sender_avatar' => $row['sender_avatar'] ?: '/images/user.png',
            'message' => $row['noi_dung'],
            'date_post' => intval($row['date_post']),
            'date_formatted' => date('H:i d/m/Y', $row['date_post']),
            'is_read' => intval($row['doc']),
            'is_own' => ($row['sender_id'] == $user_id)
        ];
    }
    
    // Đếm tổng số kết quả
    $count_sql = "SELECT COUNT(*) as total FROM chat_ncc WHERE phien = '$phien' AND active = 1 AND noi_dung LIKE '%$keyword_escaped%'";
    $count_result = mysqli_query($conn, $count_sql);
    $total = mysqli_fetch_assoc($count_result)['total'];
    
    echo json_encode([
        'success' => true,
        'messages' => $messages,
        'keyword' => $keyword,
        'pagination' => [
            'current_page' => $page,
            'per_page' => $limit,
            'total' => intval($total),
            'total_pages' => ceil($total / $limit)
        ]
    ]);
    exit;
}

// Action không hợp lệ
echo json_encode([
    'success' => false,
    'message' => 'Action không hợp lệ',
    'available_actions' => [
        'create_session',
        'list_sessions', 
        'get_messages',
        'send_message',
        'mark_read',
        'get_unread_count',
        'close_session',
        'search_messages'
    ]
]);
?>
