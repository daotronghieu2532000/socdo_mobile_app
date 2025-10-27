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
        // Check if this is file upload request
        if (isset($_POST['action']) && $_POST['action'] === 'upload_image') {
            handle_upload_image();
            exit;
        }
        
        // Đọc JSON body
        $json = file_get_contents('php://input');
        $data = json_decode($json, true);
        
        // Validate input
        if (!isset($data['user_id']) || !isset($data['description']) || empty(trim($data['description']))) {
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
        
        $description = trim($data['description']);
        $image_urls = isset($data['image_urls']) ? $data['image_urls'] : [];
        $device_info = isset($data['device_info']) ? trim($data['device_info']) : '';
        $app_version = isset($data['app_version']) ? trim($data['app_version']) : '';
        
        // Convert array to JSON string
        $image_urls_json = is_array($image_urls) ? json_encode($image_urls, JSON_UNESCAPED_UNICODE) : '';
        
        $current_time = time();
        $status = 'pending';
        
        // Insert vào database
        $insert_query = "
            INSERT INTO app_reports (user_id, image_urls, description, device_info, app_version, status, created_at, updated_at)
            VALUES ('$user_id', '" . mysqli_real_escape_string($conn, $image_urls_json) . "', 
                    '" . mysqli_real_escape_string($conn, $description) . "', 
                    '" . mysqli_real_escape_string($conn, $device_info) . "', 
                    '" . mysqli_real_escape_string($conn, $app_version) . "', 
                    '$status', '$current_time', '$current_time')
        ";
        
        $result = mysqli_query($conn, $insert_query);
        
        if ($result) {
            $report_id = mysqli_insert_id($conn);
            
            // Response thành công
            http_response_code(200);
            echo json_encode([
                "success" => true,
                "message" => "Cảm ơn bạn đã báo lỗi! Chúng tôi sẽ xem xét và khắc phục sớm nhất.",
                "data" => [
                    "report_id" => $report_id,
                    "description" => $description,
                    "image_urls" => $image_urls,
                    "status" => $status,
                    "created_at" => $current_time
                ]
            ], JSON_UNESCAPED_UNICODE);
        } else {
            http_response_code(500);
            echo json_encode([
                "success" => false,
                "message" => "Lỗi lưu báo lỗi"
            ]);
        }
        
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

function handle_upload_image() {
    global $conn;
    
    if (!isset($_FILES['image']) || $_FILES['image']['error'] !== UPLOAD_ERR_OK) {
        http_response_code(400);
        echo json_encode(["success" => false, "message" => "Không có file ảnh hợp lệ"]);
        return;
    }
    
    $file = $_FILES['image'];
    $allowed_ext = ['jpg', 'jpeg', 'png', 'webp', 'gif'];
    
    // Lấy extension từ tên file
    $filename = $file['name'];
    $ext = strtolower(pathinfo($filename, PATHINFO_EXTENSION));
    
    // Validate extension
    if (!in_array($ext, $allowed_ext)) {
        http_response_code(400);
        echo json_encode(["success" => false, "message" => "Định dạng ảnh không hỗ trợ. Chỉ hỗ trợ: jpg, jpeg, png, webp, gif"]);
        return;
    }
    
    // Normalize extension
    if ($ext === 'jpeg') $ext = 'jpg';
    
    // Upload vào thư mục reports
    $uploadDir = '/home/socdo.vn/public_html/uploads/reports/';
    
    if (!is_dir($uploadDir)) {
        if (!mkdir($uploadDir, 0755, true)) {
            http_response_code(500);
            echo json_encode(["success" => false, "message" => "Không thể tạo thư mục upload"]);
            return;
        }
    }
    
    // Tạo tên file unique
    $filename = 'report_' . time() . '_' . rand(1000, 9999) . '.' . $ext;
    $target = $uploadDir . $filename;
    
    if (!move_uploaded_file($file['tmp_name'], $target)) {
        http_response_code(500);
        echo json_encode(["success" => false, "message" => "Lưu file thất bại"]);
        return;
    }
    
    $relativePath = '/uploads/reports/' . $filename;
    
    http_response_code(200);
    echo json_encode([
        'success' => true,
        'message' => 'Upload ảnh thành công',
        'data' => ['image_url' => $relativePath]
    ]);
}
?>

