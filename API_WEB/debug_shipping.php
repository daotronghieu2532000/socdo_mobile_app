<?php
header("Access-Control-Allow-Methods: POST");
header("Content-Type: application/json; charset=utf-8");

// Database connection
$conn = mysqli_connect("localhost", "socdo", "Viettel@123", "socdo");
if (!$conn) {
    die(json_encode(['error' => 'DB connection failed: ' . mysqli_connect_error()]));
}
mysqli_set_charset($conn, "utf8mb4");

// Get POST data
$raw = file_get_contents('php://input');
$params = json_decode($raw, true);

$user_id = intval($params['user_id'] ?? 0);
$items = $params['items'] ?? [];

$result = [
    'user_id' => $user_id,
    'items_input' => $items,
    'item_details' => [],
    'shop_totals' => [],
    'transport_configs' => []
];

// Get product details
foreach ($items as $it) {
    $pid = intval($it['product_id'] ?? 0);
    $qty = intval($it['quantity'] ?? 1);
    
    if ($pid <= 0) continue;
    
    $q = mysqli_query($conn, "SELECT id, tieu_de, shop, gia_moi, can_nang_tinhship FROM sanpham WHERE id='$pid' LIMIT 1");
    
    if ($q && mysqli_num_rows($q) > 0) {
        $r = mysqli_fetch_assoc($q);
        $shopId = intval($r['shop']);
        $price = intval($r['gia_moi']);
        $weight = intval($r['can_nang_tinhship'] ?: 500);
        
        $result['item_details'][] = [
            'product_id' => $pid,
            'title' => $r['tieu_de'],
            'shop' => $shopId,
            'price' => $price,
            'weight_per_item' => $weight,
            'quantity' => $qty,
            'line_value' => $price * $qty,
            'line_weight' => $weight * $qty
        ];
        
        // Sum by shop
        if (!isset($result['shop_totals'][$shopId])) {
            $result['shop_totals'][$shopId] = [
                'total_value' => 0,
                'total_weight' => 0,
                'items' => []
            ];
        }
        $result['shop_totals'][$shopId]['total_value'] += $price * $qty;
        $result['shop_totals'][$shopId]['total_weight'] += $weight * $qty;
        $result['shop_totals'][$shopId]['items'][] = $pid;
    }
}

// Get transport config for each shop
foreach (array_keys($result['shop_totals']) as $shopId) {
    $tq = mysqli_query($conn, "SELECT user_id, free_ship_all, free_ship_min_order, free_ship_discount, fee_ship_products FROM transport WHERE user_id='$shopId' LIMIT 1");
    
    if ($tq && mysqli_num_rows($tq) > 0) {
        $t = mysqli_fetch_assoc($tq);
        $result['transport_configs'][$shopId] = [
            'user_id' => $t['user_id'],
            'free_ship_all' => intval($t['free_ship_all']),
            'free_ship_min_order' => intval($t['free_ship_min_order']),
            'free_ship_discount' => floatval($t['free_ship_discount']),
            'fee_ship_products' => $t['fee_ship_products'],
            'shop_subtotal' => $result['shop_totals'][$shopId]['total_value'],
            'can_apply_freeship' => true // Will check logic
        ];
    } else {
        $result['transport_configs'][$shopId] = [
            'error' => 'No transport config found for shop ' . $shopId
        ];
    }
}

echo json_encode($result, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);

