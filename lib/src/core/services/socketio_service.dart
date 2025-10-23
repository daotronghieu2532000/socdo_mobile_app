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
        print('🔌 [SocketIOService] Socket connected to server');
        
        // Join chat room with user_id
        _authService.getCurrentUser().then((user) {
          if (user != null) {
            // Try to join room like web does
            print('🚪 [SocketIOService] Attempting to join room: $phien');
            print('👤 [SocketIOService] User ID: ${user.userId}');
            
            // Try different join methods
            _socket!.emit('join', {'room': phien, 'user_id': user.userId});
            _socket!.emit('join_room', {'session_id': phien, 'customer_id': user.userId});
            _socket!.emit('subscribe', {'channel': phien});
            
            // Call onConnected callback AFTER getting user info
            if (onConnected != null) {
              onConnected!();
            }
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

      // Listen for server_send_message (main event from web)
      _socket!.on('server_send_message', (data) {
        print('📨 [SocketIOService] Received server_send_message event: $data');
        if (onMessage != null) {
          onMessage!(data);
        }
      });

      // Debug: Listen for any message-related events
      _socket!.on('message_received', (data) {
        print('📨 [SocketIOService] Received message_received event: $data');
        if (onMessage != null) {
          onMessage!(data);
        }
      });

      _socket!.on('chat_message', (data) {
        print('📨 [SocketIOService] Received chat_message event: $data');
        if (onMessage != null) {
          onMessage!(data);
        }
      });

      // Send ping to test connection
      _socket!.emit('ping', {'test': 'connection'});
      print('🏓 [SocketIOService] Sent ping to test connection');

      // Debug: Test if we can receive any events
      print('🔍 [SocketIOService] Listening for events...');

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

    // Use same event as web: client_send_message
    final data = {
      'session_id': _phien,
      'customer_id': user.userId,
      'message': message,
    };

    print('📤 [SocketIOService] Sending message: $data');
    _socket!.emit('client_send_message', data);
    
    // Debug: Test if server responds
    _socket!.on('message_sent', (data) {
      print('✅ [SocketIOService] Server confirmed message sent: $data');
    });
  }

  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket = null;
    }
    _isConnected = false;
  }
}