<?php
/**
 * Simple SSE Test Endpoint
 * Test Server-Sent Events functionality
 */

// Set SSE headers
header('Content-Type: text/event-stream');
header('Cache-Control: no-cache');
header('Connection: keep-alive');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Get parameters
$phien = $_GET['phien'] ?? '';
$session_id = $_GET['session_id'] ?? '';
$action = $_GET['action'] ?? 'sse_test';

// Simple validation
if (empty($phien)) {
    echo "data: " . json_encode(['error' => 'Phien không được cung cấp']) . "\n\n";
    exit();
}

// Send initial connection confirmation
echo "data: " . json_encode([
    'type' => 'connection',
    'status' => 'connected',
    'session_id' => $session_id,
    'phien' => $phien,
    'timestamp' => time()
]) . "\n\n";

// Flush output
if (ob_get_level()) {
    ob_flush();
}
flush();

// Simple SSE loop
$counter = 0;
while (true) {
    // Check if client disconnected
    if (connection_aborted()) {
        break;
    }
    
    // Send test message after 2 seconds
    if ($counter == 2) {
        echo "data: " . json_encode([
            'type' => 'new_message',
            'message' => [
                'id' => 999,
                'sender_id' => 23933,
                'sender_type' => 'shop',
                'sender_name' => 'Shop',
                'sender_avatar' => '/images/shop.png',
                'content' => 'Test message from SSE endpoint',
                'date_post' => time(),
                'date_formatted' => date('H:i'),
                'is_read' => false
            ],
            'timestamp' => time()
        ]) . "\n\n";
        
        if (ob_get_level()) {
            ob_flush();
        }
        flush();
    }
    
    // Send heartbeat every 10 seconds
    if ($counter % 10 == 0) {
        echo "data: " . json_encode([
            'type' => 'heartbeat',
            'counter' => $counter,
            'timestamp' => time()
        ]) . "\n\n";
        
        if (ob_get_level()) {
            ob_flush();
        }
        flush();
    }
    
    // Sleep for 1 second
    sleep(1);
    $counter++;
    
    // Limit loop to prevent infinite running
    if ($counter > 30) { // 30 seconds max
        break;
    }
}

echo "data: " . json_encode([
    'type' => 'session_closed',
    'reason' => 'timeout',
    'timestamp' => time()
]) . "\n\n";
?>
