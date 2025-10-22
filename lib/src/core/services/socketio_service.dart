import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'token_manager.dart';
import 'auth_service.dart';

class SocketIOService {
  IO.Socket? _socket;
  bool _isConnected = false;
  String? _phien;
  final TokenManager _tokenManager = TokenManager();
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
      
      // Socket.io URL - sử dụng server có sẵn
      final socketUrl = 'https://chat.socdo.vn';
      
      _socket = IO.io(socketUrl, IO.OptionBuilder()
        .setTransports(['websocket'])
        .enableAutoConnect()
        .build()
      );

      // Listen to events
      _socket!.onConnect((_) {
        _isConnected = true;
        if (onConnected != null) {
          onConnected!();
        }
        
        // Join chat room with user_id
        _authService.getCurrentUser().then((user) {
          if (user != null) {
            final joinData = {
              'phien': phien,
              'user_id': user.userId,
            };
            print('🚪 [SocketIOService] Joining room with data: $joinData');
            _socket!.emit('join_chat', joinData);
          } else {
            print('❌ [SocketIOService] Cannot join room - user not found');
          }
        });
      });

      _socket!.onDisconnect((_) {
        _isConnected = false;
        if (onDisconnected != null) {
          onDisconnected!();
        }
      });

      _socket!.onConnectError((error) {
        _isConnected = false;
        if (onError != null) {
          onError!(error.toString());
        }
      });

      // Test connection with ping
      _socket!.on('pong', (data) {
        print('🏓 [SocketIOService] Received pong: $data');
      });

      // Listen for new messages
      _socket!.on('new_message', (data) {
        print('📨 [SocketIOService] Received new_message event: $data');
        if (onMessage != null) {
          onMessage!(data);
        }
      });

      // Listen for message sent confirmation
      _socket!.on('message_sent', (data) {
        print('✅ [SocketIOService] Message sent confirmation: $data');
        // Handle message sent confirmation
      });

      // Listen for server_send_message (from web code)
      _socket!.on('server_send_message', (data) {
        print('📨 [SocketIOService] Received server_send_message event: $data');
        if (onMessage != null) {
          onMessage!(data);
        }
      });

      // Listen for any message event
      _socket!.on('message', (data) {
        print('📨 [SocketIOService] Received message event: $data');
        if (onMessage != null) {
          onMessage!(data);
        }
      });

      // Listen for client_send_message (from web code)
      _socket!.on('client_send_message', (data) {
        print('📨 [SocketIOService] Received client_send_message event: $data');
        if (onMessage != null) {
          onMessage!(data);
        }
      });

      // Listen for ncc_send_message (from web code)
      _socket!.on('ncc_send_message', (data) {
        print('📨 [SocketIOService] Received ncc_send_message event: $data');
        if (onMessage != null) {
          onMessage!(data);
        }
      });

      // Send ping to test connection
      _socket!.emit('ping', {'test': 'connection'});
      print('🏓 [SocketIOService] Sent ping to test connection');

    } catch (e) {
      _isConnected = false;
      if (onError != null) {
        onError!(e.toString());
      }
    }
  }

  Future<void> sendMessage(String message, {String senderType = 'customer'}) async {
    if (!_isConnected || _socket == null) {
      print('❌ [SocketIOService] Cannot send message - not connected');
      return;
    }

    final user = await _authService.getCurrentUser();
    if (user == null) {
      print('❌ [SocketIOService] Cannot send message - user not found');
      return;
    }

    final data = {
      'phien': _phien,
      'message': message,
      'sender_type': senderType,
      'user_id': user.userId,
      'timestamp': DateTime.now().millisecondsSinceEpoch ~/ 1000,
    };

    print('📤 [SocketIOService] Sending message: $data');
    _socket!.emit('send_message', data);
  }

  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket = null;
    }
    _isConnected = false;
  }
}