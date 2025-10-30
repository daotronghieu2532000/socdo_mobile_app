import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'auth_service.dart';

/// SocketIOService - Quản lý kết nối Socket.IO cho chat realtime
class SocketIOService {
  IO.Socket? _socket;
  bool _isConnected = false;
  String? _phien;
  final AuthService _authService = AuthService();
  
  // Callbacks
  Function(Map<String, dynamic>)? onMessage;
  Function()? onConnected;
  Function()? onDisconnected;
  Function(String)? onError;

  bool get isConnected => _isConnected;

  Future<void> connect(String phien) async {
    try {
      _phien = phien;
      
      // ✅ ĐƠN GIẢN NHẤT: KHÔNG CONFIG GÌ CẢ
      final socketUrl = 'https://chat.socdo.vn';
      print('🔌 [SocketIO] Connecting to $socketUrl with phien: $phien');
      
      // ✅ CHỈ CONNECT, KHÔNG CONFIG GÌ
      _socket = IO.io(socketUrl);

      print('✅ [SocketIO] Socket created');
      
      // ✅ Setup event listeners
      _setupEventListeners();
      
      print('✅ [SocketIO] Socket setup complete');
      
      // ✅ DEBUG: Wait 5s và check xem có connect không
      await Future.delayed(const Duration(seconds: 5));
      print('🔍 [SocketIO] After 5s - Connected: ${_socket?.connected}, ID: ${_socket?.id}');
      
    } catch (e) {
      print('❌ [SocketIO] Setup error: $e');
      _isConnected = false;
      if (onError != null) onError!(e.toString());
    }
  }

  void _setupEventListeners() {
    if (_socket == null) return;

    // ✅ Connect event
    _socket!.onConnect((_) {
      _isConnected = true;
      print('✅✅✅ [SocketIO] CONNECTED! ID: ${_socket!.id}');
      if (onConnected != null) onConnected!();
    });

    // ✅ Disconnect event
    _socket!.onDisconnect((reason) {
      _isConnected = false;
      print('🔌 [SocketIO] Disconnected: $reason');
      if (onDisconnected != null) onDisconnected!();
    });

    // ✅ Connect error event
    _socket!.onConnectError((error) {
      _isConnected = false;
      print('❌ [SocketIO] Connect error: $error');
      if (onError != null) onError!(error.toString());
    });

    // ✅ Generic error event
    _socket!.on('error', (error) {
      print('❌ [SocketIO] Error: $error');
    });

    // ✅ Reconnect event
    _socket!.onReconnect((attempt) {
      _isConnected = true;
      print('🔄 [SocketIO] Reconnected after $attempt attempts');
      if (onConnected != null) onConnected!();
    });

    // ✅ Business logic: Listen for messages
    _socket!.on('server_send_message', (data) {
      print('📨 [SocketIO] Received server_send_message: $data');
      if (onMessage != null) onMessage!(data);
    });

    print('📝 [SocketIO] Event listeners setup complete');
  }

  Future<void> sendMessage(String message, {String senderType = 'customer'}) async {
    if (!_isConnected || _socket == null) {
      print('❌ [SocketIO] Cannot send - not connected');
      return;
    }

    final user = await _authService.getCurrentUser();
    if (user == null) {
      print('❌ [SocketIO] User not found');
      return;
    }

    final data = {
      'session_id': _phien,
      'customer_id': user.userId,
      'ncc_id': 0,
      'message': message,
    };

    print('📤 [SocketIO] Emitting client_send_message: $data');
    _socket!.emit('client_send_message', data);
    print('✅ [SocketIO] Message emitted');
  }

  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket = null;
    }
    _isConnected = false;
    print('🔌 [SocketIO] Disconnected');
  }
}
