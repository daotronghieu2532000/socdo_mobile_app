<?php
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
require_once './vendor/autoload.php';
use \Firebase\JWT\JWT;
use \Firebase\JWT\Key;

// Cấu hình thông tin JWT
$key = "Socdo123@2025";
$issuer = "api.socdo.vn";

// Lấy token từ header Authorization
$headers = apache_request_headers();
$authHeader = isset($headers['Authorization']) ? $headers['Authorization'] : '';
if (!$authHeader || !preg_match('/Bearer\s(\S+)/', $authHeader, $matches)) {
    http_response_code(401);
    echo json_encode(array("success" => false, "message" => "Không tìm thấy token"));
    exit;
}

$jwt = $matches[1];

try {
    // Giải mã JWT
    $decoded = JWT::decode($jwt, new Key($key, 'HS256'));
    
    // Kiểm tra issuer
    if ($decoded->iss !== $issuer) {
        http_response_code(401);
        echo json_encode(array("success" => false, "message" => "Issuer không hợp lệ"));
        exit;
    }
    
    $method = $_SERVER['REQUEST_METHOD'];
    
    if ($method === 'POST') {
        // Đọc JSON body
        $json = file_get_contents('php://input');
        $data = json_decode($json, true);
        
        // Validate input
        if (!isset($data['user_id']) || !isset($data['rating'])) {
            http_response_code(400);
            echo json_encode([
                "success" => false,
                "message" => "Thiếu thông tin bắt buộc"
            ]);
            exit;
        }
        
        // Lấy user_id từ request body
        $user_id = intval($data['user_id']);
        
        if ($user_id <= 0) {
            http_response_code(401);
            echo json_encode([
                "success" => false,
                "message" => "Thông tin người dùng không hợp lệ"
            ]);
            exit;
        }
        
        $rating = floatval($data['rating']);
        $comment = isset($data['comment']) ? trim($data['comment']) : '';
        $device_info = isset($data['device_info']) ? trim($data['device_info']) : '';
        $app_version = isset($data['app_version']) ? trim($data['app_version']) : '';
        
        // Validate rating (0.5 - 5.0)
        if ($rating < 0.5 || $rating > 5.0) {
            http_response_code(400);
            echo json_encode([
                "success" => false,
                "message" => "Đánh giá phải từ 0.5 đến 5.0 sao"
            ]);
            exit;
        }
        
        // Kiểm tra xem user đã đánh giá chưa
        $check_query = "SELECT id FROM app_ratings WHERE user_id = '$user_id' ORDER BY created_at DESC LIMIT 1";
        $check_result = mysqli_query($conn, $check_query);
        
        $current_time = time();
        $rating_status = 1; // Mặc định hiển thị
        
        if (mysqli_num_rows($check_result) > 0) {
            // User đã đánh giá, cập nhật đánh giá cũ nhất
            $existing = mysqli_fetch_assoc($check_result);
            $update_query = "
                UPDATE app_ratings 
                SET rating = '$rating',
                    comment = '" . mysqli_real_escape_string($conn, $comment) . "',
                    device_info = '" . mysqli_real_escape_string($conn, $device_info) . "',
                    app_version = '" . mysqli_real_escape_string($conn, $app_version) . "',
                    updated_at = '$current_time',
                    status = '$rating_status'
                WHERE id = '" . $existing['id'] . "'
            ";
            
            $result = mysqli_query($conn, $update_query);
            
            if ($result) {
                $rating_id = $existing['id'];
            } else {
                http_response_code(500);
                echo json_encode([
                    "success" => false,
                    "message" => "Lỗi cập nhật đánh giá"
                ]);
                exit;
            }
        } else {
            // User chưa đánh giá, tạo mới
            $insert_query = "
                INSERT INTO app_ratings (user_id, rating, comment, device_info, app_version, status, created_at, updated_at)
                VALUES ('$user_id', '$rating', '" . mysqli_real_escape_string($conn, $comment) . "', 
                        '" . mysqli_real_escape_string($conn, $device_info) . "', 
                        '" . mysqli_real_escape_string($conn, $app_version) . "', 
                        '$rating_status', '$current_time', '$current_time')
            ";
            
            $result = mysqli_query($conn, $insert_query);
            
            if ($result) {
                $rating_id = mysqli_insert_id($conn);
            } else {
                http_response_code(500);
                echo json_encode([
                    "success" => false,
                    "message" => "Lỗi tạo đánh giá"
                ]);
                exit;
            }
        }
        
        // Response thành công
        http_response_code(200);
        echo json_encode([
            "success" => true,
            "message" => "Cảm ơn bạn đã đánh giá ứng dụng!",
            "data" => [
                "rating_id" => $rating_id,
                "rating" => $rating,
                "comment" => $comment,
                "created_at" => $current_time
            ]
        ], JSON_UNESCAPED_UNICODE);
        
    } else {
        http_response_code(405);
        echo json_encode([
            "success" => false,
            "message" => "Chỉ hỗ trợ phương thức POST"
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

