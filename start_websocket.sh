#!/bin/bash
# WebSocket Server Startup Script

echo "🚀 Starting WebSocket Server..."

# Check if composer is installed
if ! command -v composer &> /dev/null; then
    echo "❌ Composer not found. Installing..."
    curl -sS https://getcomposer.org/installer | php
    mv composer.phar /usr/local/bin/composer
fi

# Install Ratchet WebSocket library
echo "📦 Installing Ratchet WebSocket library..."
composer require cboden/ratchet

# Start WebSocket server
echo "🔌 Starting WebSocket server on port 8080..."
php API_WEB/websocket_server.php
