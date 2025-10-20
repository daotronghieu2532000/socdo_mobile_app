<?php
header('Content-Type: text/event-stream');
header('Cache-Control: no-cache');
header('Connection: keep-alive');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Cache-Control, Authorization');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');

// Xử lý preflight request
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once __DIR__ . '/../../includes/config.php';
require_once __DIR__ . '/../../includes/tlca_world.php';

// JWT Authentication
// Polyfill getallheaders for non-Apache environments
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

// Lấy token từ query string hoặc header
$token = $_GET['token'] ?? '';
$headers = getallheaders();
if (!$token && isset($headers['Authorization'])) {
    $token = str_replace('Bearer ', '', $headers['Authorization']);
}

if (!$token) {
    echo "data: " . json_encode(['type' => 'error', 'message' => 'Token không được cung cấp']) . "\n\n";
    flush();
    exit;
}

$user_data = verifyJWT($token);
if (!$user_data) {
    echo "data: " . json_encode(['type' => 'error', 'message' => 'Token không hợp lệ']) . "\n\n";
    flush();
    exit;
}

$user_id = $user_data['user_id'];
$user_type = $user_data['user_type'] ?? 'customer';

// Lấy tham số
$phien = $_GET['phien'] ?? '';
$session_id = intval($_GET['session_id'] ?? 0);

// Lấy phien từ session_id nếu chưa có
if (!$phien && $session_id) {
    $session_query = mysqli_query($conn, "SELECT phien FROM chat_sessions_ncc WHERE id = $session_id LIMIT 1");
    if ($session_query && mysqli_num_rows($session_query) > 0) {
        $session = mysqli_fetch_assoc($session_query);
        $phien = $session['phien'];
    }
}

if (!$phien) {
    echo "data: " . json_encode(['type' => 'error', 'message' => 'Thiếu phien']) . "\n\n";
    flush();
    exit;
}

// Kiểm tra quyền truy cập
$check_access = mysqli_query($conn, "SELECT * FROM chat_sessions_ncc WHERE phien = '$phien' AND (shop_id = $user_id OR customer_id = $user_id) LIMIT 1");
if (!$check_access || mysqli_num_rows($check_access) == 0) {
    echo "data: " . json_encode(['type' => 'error', 'message' => 'Không có quyền truy cập']) . "\n\n";
    flush();
    exit;
}

// Tắt output buffering
if (ob_get_level()) ob_end_clean();

// Gửi thông báo kết nối thành công
echo "data: " . json_encode([
    'type' => 'connected',
    'message' => 'Kết nối SSE thành công',
    'phien' => $phien,
    'user_id' => $user_id,
    'user_type' => $user_type
]) . "\n\n";
flush();

// Lưu connection để track
$connection_id = uniqid();
$connection_file = sys_get_temp_dir() . "/chat_sse_connection_{$connection_id}.txt";
file_put_contents($connection_file, json_encode([
    'phien' => $phien,
    'user_id' => $user_id,
    'user_type' => $user_type,
    'timestamp' => time()
]));

// Biến để track tin nhắn đã gửi
$last_message_id = 0;
$last_check = time();

// Polling loop
while (true) {
    // Kiểm tra connection mỗi 30 giây
    if (time() - $last_check > 30) {
        echo "data: " . json_encode([
            'type' => 'ping',
            'timestamp' => time()
        ]) . "\n\n";
        flush();
        $last_check = time();
    }
    
    // Kiểm tra tin nhắn mới
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
            AND c.id > $last_message_id
            ORDER BY c.id ASC";
    
    $result = mysqli_query($conn, $sql);
    
    while ($row = mysqli_fetch_assoc($result)) {
        $last_message_id = $row['id'];
        
        $message_data = [
            'type' => 'new_message',
            'message' => [
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
            ]
        ];
        
        echo "data: " . json_encode($message_data) . "\n\n";
        flush();
    }
    
    // Kiểm tra tin nhắn đã được đọc
    $read_sql = "SELECT id FROM chat_ncc 
                 WHERE phien = '$phien' 
                 AND active = 1 
                 AND doc = 1 
                 AND sender_id = $user_id 
                 AND id > $last_message_id";
    
    $read_result = mysqli_query($conn, $read_sql);
    while ($read_row = mysqli_fetch_assoc($read_result)) {
        echo "data: " . json_encode([
            'type' => 'message_read',
            'message_id' => intval($read_row['id'])
        ]) . "\n\n";
        flush();
    }
    
    // Kiểm tra connection file có bị xóa không (client disconnect)
    if (!file_exists($connection_file)) {
        break;
    }
    
    // Sleep 1 giây
    usleep(1000000);
}

// Cleanup
if (file_exists($connection_file)) {
    unlink($connection_file);
}
?>
