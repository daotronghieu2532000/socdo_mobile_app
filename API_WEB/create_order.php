<?php
header("Access-Control-Allow-Methods: POST, OPTIONS");
require_once './vendor/autoload.php';
require_once './includes/config.php';
use \Firebase\JWT\JWT;
use \Firebase\JWT\Key;

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
	http_response_code(200);
	exit;
}

$key = "Socdo123@2025";
$issuer = "api.socdo.vn";

$headers = function_exists('apache_request_headers') ? apache_request_headers() : [];
$authHeader = isset($headers['Authorization']) ? $headers['Authorization'] : '';
$jwt = null;
if ($authHeader && preg_match('/Bearer\s(\S+)/', $authHeader, $matches)) {
	$jwt = $matches[1];
}

$user_id = isset($_POST['user_id']) ? intval($_POST['user_id']) : (isset($_GET['user_id']) ? intval($_GET['user_id']) : 0);

try {
	if (!$user_id && $jwt) {
		$decoded = JWT::decode($jwt, new Key($key, 'HS256'));
		if (!isset($decoded->iss) || $decoded->iss !== $issuer) {
			http_response_code(401);
			echo json_encode(["success" => false, "message" => "Issuer không hợp lệ"]);
			exit;
		}
		$user_id = isset($decoded->user_id) ? intval($decoded->user_id) : 0;
	}
	if ($user_id <= 0) {
		http_response_code(401);
		echo json_encode(["success" => false, "message" => "Thông tin người dùng không hợp lệ"]);
		exit;
	}

	if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
		http_response_code(405);
		echo json_encode(["success" => false, "message" => "Chỉ hỗ trợ phương thức POST"]);
		exit;
	}

	// Input
	$ho_ten = addslashes(trim($_POST['ho_ten'] ?? ''));
	$email = addslashes(trim($_POST['email'] ?? ''));
	$dien_thoai = addslashes(trim($_POST['dien_thoai'] ?? ''));
	$dia_chi = addslashes(trim($_POST['dia_chi'] ?? ''));
	$tinh = intval($_POST['tinh'] ?? 0);
	$huyen = intval($_POST['huyen'] ?? 0);
	$xa = intval($_POST['xa'] ?? 0);
	$sanpham = $_POST['sanpham'] ?? '[]'; // JSON string
	$thanhtoan = addslashes(trim($_POST['thanhtoan'] ?? 'COD'));
	$ghi_chu = addslashes(trim($_POST['ghi_chu'] ?? ''));
	$coupon = addslashes(trim($_POST['coupon'] ?? ''));
	$giam = intval($_POST['giam'] ?? 0);
	$voucher_tmdt = intval($_POST['voucher_tmdt'] ?? 0);
	$phi_ship = intval($_POST['phi_ship'] ?? 0);
	$ship_support = intval($_POST['ship_support'] ?? 0);
	$shipping_provider = addslashes(trim($_POST['shipping_provider'] ?? ''));
	$utm_source = addslashes(trim($_POST['utm_source'] ?? ''));
	$utm_campaign = addslashes(trim($_POST['utm_campaign'] ?? ''));

	// Basic validation
	if (!$ho_ten || !$dien_thoai || !$dia_chi || !$tinh || !$huyen) {
		http_response_code(400);
		echo json_encode(["success" => false, "message" => "Thiếu thông tin giao hàng bắt buộc"]);
		exit;
	}

	// Parse products and compute sums if not provided
	$items = json_decode($sanpham, true);
	if (!is_array($items)) $items = [];
	$tamtinh = 0;
	foreach ($items as $it) {
		$line_total = intval($it['thanh_tien'] ?? 0);
		if ($line_total <= 0) {
			$gia_moi = intval($it['gia_moi'] ?? 0);
			$qty = max(1, intval($it['quantity'] ?? 1));
			$line_total = $gia_moi * $qty;
		}
		$tamtinh += $line_total;
	}
	// Total
	$tongtien = max(0, $tamtinh - $giam - $voucher_tmdt + $phi_ship - $ship_support);

	// Generate order code
	$ma_don = 'DH' . date('ymdHis') . rand(100, 999);
	$hientai = time();

	// Insert
	$sanpham_sql = mysqli_real_escape_string($conn, is_string($sanpham) ? $sanpham : json_encode($items, JSON_UNESCAPED_UNICODE));
	$query = "INSERT INTO donhang (
		ma_don,minh_hoa,minh_hoa2,user_id,ho_ten,email,dien_thoai,dia_chi,tinh,huyen,xa,dropship,
		sanpham,tamtinh,coupon,giam,voucher_tmdt,phi_ship,tongtien,kho,status,thanhtoan,ghi_chu,
		utm_source,utm_campaign,date_update,date_post,shop_id,shipping_provider,ninja_response,ship_support
	) VALUES (
		'$ma_don','','','$user_id','$ho_ten','$email','$dien_thoai','$dia_chi','$tinh','$huyen','$xa','0',
		'$sanpham_sql','$tamtinh','$coupon','$giam','$voucher_tmdt','$phi_ship','$tongtien','',0,'$thanhtoan','$ghi_chu',
		'$utm_source','$utm_campaign','$hientai','$hientai','','$shipping_provider','','$ship_support'
	)";
	$ok = mysqli_query($conn, $query);
	if (!$ok) {
		http_response_code(500);
		echo json_encode(["success" => false, "message" => "Lỗi tạo đơn hàng", "error" => mysqli_error($conn)]);
		exit;
	}

	// Notification for shop if can derive shop_id from first item
	$first_shop = intval($items[0]['shop'] ?? 0);
	if ($first_shop > 0) {
		$noidung_notification = "Bạn có đơn hàng sàn TMĐT: #$ma_don - $ho_ten - $dien_thoai";
		mysqli_query($conn, "INSERT INTO notification (user_id, sp_id, noi_dung, doc, bo_phan, admin, date_post) VALUES ('$first_shop','0','$noidung_notification','','donhang','0','$hientai')");
	}

	// Tạo thông báo cho user đặt hàng (Mobile App)
	require_once './notification_mobile_helper.php';
	$notificationHelper = new NotificationMobileHelper($conn);
	$order_id = mysqli_insert_id($conn); // Lấy ID đơn hàng vừa tạo
	
	$notificationHelper->notifyNewOrder(
		$user_id, 
		$order_id, 
		$ma_don, 
		$tongtien
	);

	$response = [
		'success' => true,
		'message' => 'Tạo đơn hàng thành công',
		'data' => [
			'ma_don' => $ma_don,
			'order' => [
				'user_id' => $user_id,
				'tamtinh' => $tamtinh,
				'giam' => $giam,
				'voucher_tmdt' => $voucher_tmdt,
				'phi_ship' => $phi_ship,
				'ship_support' => $ship_support,
				'tongtien' => $tongtien,
				'status' => 0,
				'date_post' => $hientai
			]
		]
	];
	http_response_code(200);
	echo json_encode($response, JSON_UNESCAPED_UNICODE);

} catch (Exception $e) {
	http_response_code(401);
	echo json_encode(["success" => false, "message" => "Token không hợp lệ", "error" => $e->getMessage()]);
}
?>
