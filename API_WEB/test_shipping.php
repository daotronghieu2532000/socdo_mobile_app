<?php
// Test file để kiểm tra shipping_quote.php
require_once 'shipping_quote.php';

// Mock JWT token và test data
$_SERVER['REQUEST_METHOD'] = 'POST';
$_SERVER['HTTP_AUTHORIZATION'] = 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJhcGkuc29jZG8udm4iLCJ1c2VyX2lkIjo4MDUwLCJleHAiOjE3NTQ3MzQ2OTJ9.test';

// Mock input data
$input = '{"user_id":8050,"items":[{"product_id":4299,"quantity":1}]}';
file_put_contents('php://input', $input);

echo "Testing shipping_quote.php...\n";
echo "Input: $input\n";
echo "Authorization: " . $_SERVER['HTTP_AUTHORIZATION'] . "\n";
?>
