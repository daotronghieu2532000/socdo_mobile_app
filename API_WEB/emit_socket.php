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

// Đọc input JSON
$input = file_get_contents('php://input');
$data = json_decode($input, true);

if (!$data) {
    echo json_encode(['success' => false, 'message' => 'Dữ liệu không hợp lệ']);
    exit;
}

$event = $data['event'] ?? '';
$shop_id = intval($data['shop_id'] ?? 0);
$customer_id = intval($data['customer_id'] ?? 0);
$phien = $data['phien'] ?? '';
$message = $data['message'] ?? null;
$total = intval($data['total'] ?? 0);

// Log để debug
error_log("[EMIT_SOCKET] Event: $event, Shop: $shop_id, Customer: $customer_id, Phien: $phien\n", 3, "/tmp/chat_socket.log");

// Xử lý các loại event
switch ($event) {
    case 'ncc_new_message':
        // NCC gửi tin nhắn mới
        if ($message && $shop_id && $customer_id) {
            // Emit cho customer
            $socket_data = [
                'type' => 'chat_ncc_receive',
                'shop_id' => $shop_id,
                'customer_id' => $customer_id,
                'phien' => $phien,
                'message' => $message
            ];
            
            // Gửi qua socket server (nếu có)
            sendToSocketServer($socket_data);
            
            echo json_encode(['success' => true, 'message' => 'Emit NCC message thành công']);
        } else {
            echo json_encode(['success' => false, 'message' => 'Thiếu dữ liệu tin nhắn']);
        }
        break;
        
    case 'customer_new_message':
        // Customer gửi tin nhắn mới
        if ($message && $shop_id && $customer_id) {
            // Emit cho NCC
            $socket_data = [
                'type' => 'ncc_receive_message',
                'shop_id' => $shop_id,
                'customer_id' => $customer_id,
                'phien' => $phien,
                'message' => $message
            ];
            
            sendToSocketServer($socket_data);
            
            echo json_encode(['success' => true, 'message' => 'Emit customer message thành công']);
        } else {
            echo json_encode(['success' => false, 'message' => 'Thiếu dữ liệu tin nhắn']);
        }
        break;
        
    case 'update_total_chat_ncc':
        // Cập nhật badge chat NCC
        if ($shop_id) {
            $socket_data = [
                'type' => 'update_total_chat_ncc',
                'shop_id' => $shop_id,
                'total' => $total
            ];
            
            sendToSocketServer($socket_data);
            
            echo json_encode(['success' => true, 'message' => 'Emit update badge thành công']);
        } else {
            echo json_encode(['success' => false, 'message' => 'Thiếu shop_id']);
        }
        break;
        
    case 'ncc_message_seen':
        // NCC đã đọc tin nhắn
        $message_id = intval($data['message_id'] ?? 0);
        if ($shop_id && $customer_id && $message_id) {
            $socket_data = [
                'type' => 'ncc_message_seen',
                'shop_id' => $shop_id,
                'customer_id' => $customer_id,
                'message_id' => $message_id
            ];
            
            sendToSocketServer($socket_data);
            
            echo json_encode(['success' => true, 'message' => 'Emit message seen thành công']);
        } else {
            echo json_encode(['success' => false, 'message' => 'Thiếu dữ liệu']);
        }
        break;
        
    case 'customer_message_seen':
        // Customer đã đọc tin nhắn
        $message_id = intval($data['message_id'] ?? 0);
        if ($shop_id && $customer_id && $message_id) {
            $socket_data = [
                'type' => 'customer_message_seen',
                'shop_id' => $shop_id,
                'customer_id' => $customer_id,
                'message_id' => $message_id
            ];
            
            sendToSocketServer($socket_data);
            
            echo json_encode(['success' => true, 'message' => 'Emit message seen thành công']);
        } else {
            echo json_encode(['success' => false, 'message' => 'Thiếu dữ liệu']);
        }
        break;
        
    default:
        echo json_encode(['success' => false, 'message' => 'Event không được hỗ trợ']);
        break;
}

// Hàm gửi dữ liệu đến socket server
function sendToSocketServer($data) {
    // Nếu có socket server chạy trên port khác
    $socket_server_url = 'http://localhost:3000/emit'; // Thay đổi URL theo socket server thực tế
    
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $socket_server_url);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
    curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_TIMEOUT, 5);
    curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 5);
    
    $response = curl_exec($ch);
    $http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $curl_error = curl_error($ch);
    
    error_log("[EMIT_SOCKET] Response code: $http_code, Response: $response, Error: $curl_error\n", 3, "/tmp/chat_socket.log");
    
    curl_close($ch);
    
    return $http_code === 200;
}
?>
