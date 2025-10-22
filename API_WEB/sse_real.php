<?php
/**
 * Real SSE Endpoint for Mobile Chat
 * Checks database for real-time messages
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
$action = $_GET['action'] ?? 'sse_real';

// Simple validation
if (empty($phien)) {
    echo "data: " . json_encode(['error' => 'Phien không được cung cấp']) . "\n\n";
    exit();
}

// Include database connection
$config_path = '/home/api.socdo.vn/public_html/includes/config.php';
$tlca_path = '/home/api.socdo.vn/public_html/includes/tlca_world.php';
require_once $config_path;
require_once $tlca_path;
$conn = new mysqli($tlca_data['server'], $tlca_data['dbuser'], $tlca_data['dbpassword'], $tlca_data['dbname']);

if ($conn->connect_error) {
    echo "data: " . json_encode(['type' => 'error', 'message' => 'Database connection failed']) . "\n\n";
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

// SSE loop with database check
$counter = 0;
$last_message_id = 0;

while (true) {
    // Check if client disconnected
    if (connection_aborted()) {
        break;
    }
    
    // Check for new messages every 2 seconds
    if ($counter % 2 == 0) {
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
    if ($counter > 30) { // 30 seconds max for testing
        break;
    }
}

echo "data: " . json_encode([
    'type' => 'session_closed',
    'reason' => 'timeout',
    'timestamp' => time()
]) . "\n\n";
?>
