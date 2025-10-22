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

error_log('[SSE Test] Connection attempt: action=' . $action . ', phien=' . $phien . ', session_id=' . $session_id);

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

error_log('[SSE Test] Connection confirmation sent, starting SSE loop');

// Set up SSE loop
$counter = 0;
$heartbeat_interval = 10; // 10 seconds
$last_heartbeat = time();

while (true) {
    // Check if client disconnected
    if (connection_aborted()) {
        error_log('[SSE Test] Client disconnected');
        break;
    }
    
    // Send heartbeat
    if (time() - $last_heartbeat >= $heartbeat_interval) {
        echo "data: " . json_encode([
            'type' => 'heartbeat',
            'counter' => $counter,
            'timestamp' => time()
        ]) . "\n\n";
        
        if (ob_get_level()) {
            ob_flush();
        }
        flush();
        
        $last_heartbeat = time();
        $counter++;
        
        error_log('[SSE Test] Heartbeat sent: counter=' . $counter);
    }
    
    // Sleep for 1 second before next check
    sleep(1);
}

error_log('[SSE Test] SSE loop ended');
?>
