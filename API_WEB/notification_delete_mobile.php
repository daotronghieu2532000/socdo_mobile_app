<?php
// API để xóa tất cả thông báo của user
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
    exit;
}

require_once './vendor/autoload.php';
require_once './includes/config.php';
use \Firebase\JWT\JWT;
use \Firebase\JWT\Key;

// Cấu hình thông tin JWT
$key = "Socdo123@2025"; // Key bí mật dùng để ký JWT
$issuer = "api.socdo.vn"; // Tên ứng dụng phát hành token

try {
    // Lấy token từ header
    $headers = apache_request_headers();
    $authHeader = isset($headers['Authorization']) ? $headers['Authorization'] : '';
    if (!$authHeader || !preg_match('/Bearer\s(\S+)/', $authHeader, $matches)) {
        http_response_code(401);
        echo json_encode(array("message" => "Không tìm thấy token"));
        exit;
    }

    $jwt = $matches[1]; // Lấy token từ Bearer

    // Giải mã JWT
    $decoded = JWT::decode($jwt, new Key($key, 'HS256'));
    
    // Kiểm tra issuer
    if ($decoded->iss !== $issuer) {
        http_response_code(401);
        echo json_encode(array("message" => "Issuer không hợp lệ"));
        exit;
    }
    
    // Lấy dữ liệu từ POST fields (MultipartRequest)
    $delete_all = isset($_POST['delete_all']) && $_POST['delete_all'] === 'true';
    $notification_id = isset($_POST['notification_id']) ? intval($_POST['notification_id']) : null;
    $user_id = isset($_POST['user_id']) ? intval($_POST['user_id']) : 0;
    
    // Nếu không có user_id từ POST, lấy từ token
    if ($user_id <= 0 && $jwt) {
        $user_id = isset($decoded->user_id) ? intval($decoded->user_id) : 0;
    }
    
    if ($user_id <= 0) {
        http_response_code(401);
        echo json_encode(['error' => 'Invalid user']);
        exit;
    }
    
    if (!$delete_all && !$notification_id) {
        http_response_code(400);
        echo json_encode(['error' => 'Missing parameters']);
        exit;
    }
    
    if ($delete_all) {
        // Xóa tất cả thông báo của user
        $stmt = $conn->prepare("DELETE FROM notification_mobile WHERE user_id = ?");
        if (!$stmt) {
            http_response_code(500);
            echo json_encode(['error' => 'Prepare failed: ' . $conn->error]);
            exit;
        }
        
        $stmt->bind_param("i", $user_id);
        
        if ($stmt->execute()) {
            $deleted_count = $stmt->affected_rows;
            echo json_encode([
                'success' => true,
                'message' => "Đã xóa $deleted_count thông báo",
                'deleted_count' => $deleted_count
            ]);
        } else {
            http_response_code(500);
            echo json_encode(['error' => 'Failed to delete notifications: ' . $stmt->error]);
        }
        
        $stmt->close();
    } else {
        // Xóa thông báo cụ thể
        $stmt = $conn->prepare("DELETE FROM notification_mobile WHERE id = ? AND user_id = ?");
        if (!$stmt) {
            http_response_code(500);
            echo json_encode(['error' => 'Prepare failed: ' . $conn->error]);
            exit;
        }
        
        $stmt->bind_param("ii", $notification_id, $user_id);
        
        if ($stmt->execute()) {
            if ($stmt->affected_rows > 0) {
                echo json_encode([
                    'success' => true,
                    'message' => 'Đã xóa thông báo'
                ]);
            } else {
                http_response_code(404);
                echo json_encode(['error' => 'Notification not found']);
            }
        } else {
            http_response_code(500);
            echo json_encode(['error' => 'Failed to delete notification: ' . $stmt->error]);
        }
        
        $stmt->close();
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
