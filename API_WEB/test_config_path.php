<?php
// Test file để kiểm tra đường dẫn config trên server thực tế
header('Content-Type: application/json');

echo "=== KIỂM TRA ĐƯỜNG DẪN CONFIG ===\n";

// Test các đường dẫn config
$config_paths = [
    '/home/api.socdo.vn/public_html/includes/config.php',
    '../../../../../includes/config.php',
    './includes/config.php'
];

foreach ($config_paths as $path) {
    echo "Kiểm tra: $path - " . (file_exists($path) ? "EXISTS" : "NOT FOUND") . "\n";
}

// Test load config
$config_path = '/home/api.socdo.vn/public_html/includes/config.php';
if (!file_exists($config_path)) {
    $config_path = '../../../../../includes/config.php';
}
if (!file_exists($config_path)) {
    $config_path = './includes/config.php';
}

if (file_exists($config_path)) {
    echo "\nĐang load config từ: $config_path\n";
    require_once $config_path;
    
    if (isset($conn) && $conn) {
        echo "✅ Database connection: SUCCESS\n";
        echo "Database info: " . mysqli_get_server_info($conn) . "\n";
        
        // Test query
        $result = mysqli_query($conn, "SELECT 1 as test");
        if ($result) {
            echo "✅ Database query: SUCCESS\n";
        } else {
            echo "❌ Database query: FAILED - " . mysqli_error($conn) . "\n";
        }
    } else {
        echo "❌ Database connection: FAILED - " . mysqli_connect_error() . "\n";
    }
} else {
    echo "❌ Không tìm thấy file config.php\n";
}

echo "\n=== KẾT QUẢ ===\n";
echo "Đường dẫn config chính xác cho server: /home/api.socdo.vn/public_html/includes/config.php\n";
echo "Đường dẫn fallback cho local: ../../../../../includes/config.php\n";
?>
