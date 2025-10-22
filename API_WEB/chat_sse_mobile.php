<?php
/**
 * Chat SSE Mobile API
 * Server-Sent Events endpoint for real-time chat on mobile
 * 
 * @author Socdo Team
 * @version 1.0
 * @date 2025-10-22
 */

// Polyfill for getallheaders() if not available
if (!function_exists('getallheaders')) {
    function getallheaders() {
        $headers = [];
        foreach ($_SERVER as $name => $value) {
            if (substr($name, 0, 5) == 'HTTP_') {
                $headers[str_replace(' ', '-', ucwords(strtolower(str_replace('_', ' ', substr($name, 5)))))] = $value;
            }
        }
        return $headers;
    }
}

// Set headers for authentication (same as chat_api_correct.php)
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Include database connection
$config_path = '/home/api.socdo.vn/public_html/includes/config.php';
$tlca_path = '/home/api.socdo.vn/public_html/includes/tlca_world.php';
$vendor_path = '/home/api.socdo.vn/public_html/vendor/autoload.php';

// Error handling for includes
try {
    require_once $config_path;
} catch (Exception $e) {
    error_log('[SSE Mobile] Config include error: ' . $e->getMessage());
    echo "data: " . json_encode(['error' => 'Config error: ' . $e->getMessage()]) . "\n\n";
    exit();
}

try {
    require_once $tlca_path;
} catch (Exception $e) {
    error_log('[SSE Mobile] TLCA include error: ' . $e->getMessage());
    echo "data: " . json_encode(['error' => 'TLCA error: ' . $e->getMessage()]) . "\n\n";
    exit();
}

try {
    require_once $vendor_path;
} catch (Exception $e) {
    error_log('[SSE Mobile] Vendor include error: ' . $e->getMessage());
    echo "data: " . json_encode(['error' => 'Vendor error: ' . $e->getMessage()]) . "\n\n";
    exit();
}

use \Firebase\JWT\JWT;
use \Firebase\JWT\Key;

// Kết nối database
$conn = new mysqli($tlca_data['server'], $tlca_data['dbuser'], $tlca_data['dbpassword'], $tlca_data['dbname']);
if ($conn->connect_error) {
    echo "data: " . json_encode(['error' => 'Database connection failed']) . "\n\n";
    exit();
}

// JWT Configuration (same as chat_api_correct.php)
$key = 'Socdo123@2025';
$issuer = 'api.socdo.vn';

// Lấy token từ header Authorization (same as chat_api_correct.php)
$headers = apache_request_headers();
$authHeader = isset($headers['Authorization']) ? $headers['Authorization'] : '';
if (!$authHeader || !preg_match('/Bearer\s(\S+)/', $authHeader, $matches)) {
    http_response_code(401);
    echo "data: " . json_encode(['error' => 'Không tìm thấy token']) . "\n\n";
    exit();
}

$jwt = $matches[1]; // Lấy token từ Bearer

try {
    // Giải mã JWT (same as chat_api_correct.php)
    $decoded = JWT::decode($jwt, new Key($key, 'HS256'));
    
    // Kiểm tra issuer
    if ($decoded->iss !== $issuer) {
        http_response_code(401);
        echo "data: " . json_encode(['error' => 'Issuer không hợp lệ']) . "\n\n";
        exit();
    }
    
    // Token hợp lệ, tiếp tục xử lý request
    error_log('[SSE Mobile] JWT verified successfully');
    
    // Set SSE headers after authentication
    header('Content-Type: text/event-stream');
    header('Cache-Control: no-cache');
    header('Connection: keep-alive');
    
} catch (Exception $e) {
    http_response_code(401);
    echo "data: " . json_encode(['error' => 'Token không hợp lệ: ' . $e->getMessage()]) . "\n\n";
    exit();
}

try {
    // Get parameters
    $phien = $_GET['phien'] ?? '';
    $session_id = $_GET['session_id'] ?? '';
    $action = $_GET['action'] ?? 'sse_connect';
    
    // Debug logging (chỉ log quan trọng)
    error_log('[SSE Mobile] Connection attempt: action=' . $action . ', phien=' . $phien);
    
    // Validate session
    if (empty($phien)) {
        http_response_code(400);
        echo "data: " . json_encode(['error' => 'Phien không được cung cấp']) . "\n\n";
        exit();
    }
    
    // Verify session exists and user has access (using mysqli like chat_api_correct.php)
    $check_session = $conn->query("SELECT id, phien, shop_id, customer_id, status FROM chat_sessions_ncc WHERE phien = '$phien' AND status = 'active' LIMIT 1");
    if (!$check_session || $check_session->num_rows == 0) {
        http_response_code(404);
        echo "data: " . json_encode(['error' => 'Phiên chat không tồn tại']) . "\n\n";
        exit();
    }
    
    $session = $check_session->fetch_assoc();
    
    if (!$session) {
        http_response_code(404);
        echo "data: " . json_encode(['error' => 'Phiên chat không tồn tại']) . "\n\n";
        exit();
    }
    
    // Session đã được verify ở trên, không cần check user_role
    
    // Send initial connection confirmation
    error_log('[SSE Mobile] Sending connection confirmation');
    echo "data: " . json_encode([
        'type' => 'connection',
        'status' => 'connected',
        'session_id' => $session['id'],
        'phien' => $phien,
        'timestamp' => time()
    ]) . "\n\n";
    
    // Flush output
    if (ob_get_level()) {
        ob_flush();
    }
    flush();
    
    error_log('[SSE Mobile] Connection confirmation sent, starting SSE loop');
    
    // Set up SSE loop
    $last_message_id = 0;
    $heartbeat_interval = 30; // 30 seconds
    $last_heartbeat = time();
    
    while (true) {
        // Check if client disconnected
        if (connection_aborted()) {
            break;
        }
        
        // Send heartbeat
        if (time() - $last_heartbeat >= $heartbeat_interval) {
            echo "data: " . json_encode([
                'type' => 'heartbeat',
                'timestamp' => time()
            ]) . "\n\n";
            
            if (ob_get_level()) {
                ob_flush();
            }
            flush();
            
            $last_heartbeat = time();
        }
        
        // Check for new messages (using mysqli like chat_api_correct.php)
        $messages_query = "SELECT * FROM chat_messages_ncc WHERE phien = '$phien' AND id > $last_message_id AND status = 'active' ORDER BY id ASC LIMIT 10";
        $messages_result = $conn->query($messages_query);
        
        if ($messages_result && $messages_result->num_rows > 0) {
            while ($message = $messages_result->fetch_assoc()) {
                echo "data: " . json_encode([
                    'type' => 'new_message',
                    'message' => [
                        'id' => $message['id'],
                        'sender_id' => $message['sender_id'],
                        'sender_type' => $message['sender_type'],
                        'sender_name' => $message['sender_type'] == 'customer' ? 'Bạn' : 'Shop',
                        'sender_avatar' => $message['sender_type'] == 'customer' ? '/images/user.png' : '/images/shop.png',
                        'content' => $message['content'],
                        'date_post' => $message['date_post'],
                        'date_formatted' => date('H:i', $message['date_post']),
                        'is_read' => $message['is_read']
                    ],
                    'timestamp' => time()
                ]) . "\n\n";
                
                $last_message_id = $message['id'];
            }
            
            if (ob_get_level()) {
                ob_flush();
            }
            flush();
        }
        
        // Check for message read status updates (using mysqli)
        $read_query = "SELECT id, is_read FROM chat_messages_ncc WHERE phien = '$phien' AND id > $last_message_id AND status = 'active' ORDER BY id ASC LIMIT 10";
        $read_result = $conn->query($read_query);
        
        if ($read_result && $read_result->num_rows > 0) {
            while ($update = $read_result->fetch_assoc()) {
                echo "data: " . json_encode([
                    'type' => 'message_read',
                    'message_id' => $update['id'],
                    'is_read' => $update['is_read'],
                    'timestamp' => time()
                ]) . "\n\n";
            }
        }
        
        // Check for session status changes (using mysqli)
        $session_check = $conn->query("SELECT status FROM chat_sessions_ncc WHERE phien = '$phien' LIMIT 1");
        if ($session_check && $session_check->num_rows > 0) {
            $session_status = $session_check->fetch_assoc();
            if ($session_status['status'] !== 'active') {
                echo "data: " . json_encode([
                    'type' => 'session_closed',
                    'status' => $session_status['status'],
                    'timestamp' => time()
                ]) . "\n\n";
                break;
            }
        }
        
        // Flush output
        if (ob_get_level()) {
            ob_flush();
        }
        flush();
        
        // Sleep for 1 second before next check
        sleep(1);
        
        // Debug log chỉ mỗi 10 giây để tránh spam
        if (time() % 10 == 0) {
            error_log('[SSE Mobile] Loop running - phien: ' . $phien . ', last_message_id: ' . $last_message_id);
        }
    }
    
} catch (Exception $e) {
    error_log('[SSE Mobile] Error: ' . $e->getMessage());
    
    http_response_code(500);
    echo "data: " . json_encode([
        'type' => 'error',
        'message' => 'Lỗi server: ' . $e->getMessage(),
        'timestamp' => time()
    ]) . "\n\n";
}

// Clean up
if (ob_get_level()) {
    ob_end_flush();
}
?>
