import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/services/chat_service.dart';
import '../../core/models/chat.dart';

class ChatScreen extends StatefulWidget {
  final int shopId;
  final String shopName;
  final String? shopAvatar;
  final int? productId;

  const ChatScreen({
    super.key,
    required this.shopId,
    required this.shopName,
    this.shopAvatar,
    this.productId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<ChatMessage> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  String? _error;
  String? _phien;
  int? _sessionId;
  bool _isConnected = false;
  
  // SSE
  HttpClient? _httpClient;
  StreamSubscription? _sseSubscription;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _disconnectSSE();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      print('🚀 [DEBUG] Initializing chat:');
      print('   Shop ID: ${widget.shopId}');
      print('   Shop Name: ${widget.shopName}');
      print('   Shop Avatar: ${widget.shopAvatar}');
      print('   Product ID: ${widget.productId}');

      // Tạo phiên chat
      final sessionResponse = await _chatService.createSession(widget.shopId);
      
      if (sessionResponse.success) {
        setState(() {
          _sessionId = sessionResponse.sessionId;
          _phien = sessionResponse.phien;
        });

        // Load tin nhắn
        await _loadMessages();
        
        // Kết nối SSE
        _connectSSE();
      } else {
        setState(() {
          _error = 'Không thể tạo phiên chat';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Lỗi khởi tạo chat: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMessages() async {
    try {
      final response = await _chatService.getMessages(
        sessionId: _sessionId,
        phien: _phien,
        limit: 50,
      );

      if (response.success) {
        setState(() {
          _messages = response.messages;
          _isLoading = false;
        });
        
        // Scroll xuống cuối
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      } else {
        setState(() {
          _error = 'Không thể tải tin nhắn';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Lỗi tải tin nhắn: $e';
        _isLoading = false;
      });
    }
  }

  void _connectSSE() async {
    if (_phien == null) return;

    try {
      final sseUrl = await _chatService.getSseUrl(phien: _phien!, sessionId: _sessionId);
      
      _httpClient = HttpClient();
      final request = await _httpClient!.getUrl(Uri.parse(sseUrl));
      
      request.headers.set('Accept', 'text/event-stream');
      request.headers.set('Cache-Control', 'no-cache');
      
      request.close().then((response) {
        if (response.statusCode == 200) {
          setState(() {
            _isConnected = true;
          });
          
          _sseSubscription = response.transform(utf8.decoder).listen(
            _handleSSEData,
            onError: (error) {
              print('SSE Error: $error');
              _reconnectSSE();
            },
            onDone: () {
              print('SSE Connection closed');
              _reconnectSSE();
            },
          );
        } else {
          print('SSE Connection failed: ${response.statusCode}');
          _reconnectSSE();
        }
      }).catchError((error) {
        print('SSE Request error: $error');
        _reconnectSSE();
      });
    } catch (e) {
      print('SSE Connection error: $e');
      _reconnectSSE();
    }
  }

  void _disconnectSSE() {
    _sseSubscription?.cancel();
    _httpClient?.close();
    _sseSubscription = null;
    _httpClient = null;
    setState(() {
      _isConnected = false;
    });
  }

  void _reconnectSSE() {
    _disconnectSSE();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _phien != null) {
        _connectSSE();
      }
    });
  }

  void _handleSSEData(String data) {
    try {
      final lines = data.split('\n');
      
      for (final line in lines) {
        if (line.startsWith('data: ')) {
          final jsonData = line.substring(6);
          if (jsonData.trim().isEmpty) continue;
          
          final eventData = json.decode(jsonData);
          _handleSSEEvent(eventData);
        }
      }
    } catch (e) {
      print('SSE Data parsing error: $e');
    }
  }

  void _handleSSEEvent(Map<String, dynamic> eventData) {
    switch (eventData['type']) {
      case 'connected':
        print('SSE Connected');
        setState(() {
          _isConnected = true;
        });
        break;
        
      case 'new_message':
        final messageData = eventData['message'];
        if (messageData != null) {
          final message = ChatMessage.fromJson(messageData);
          setState(() {
            _messages.add(message);
          });
          
          // Scroll xuống cuối
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        }
        break;
        
      case 'message_read':
        final messageId = eventData['message_id'];
        if (messageId != null) {
          setState(() {
            for (int i = 0; i < _messages.length; i++) {
              if (_messages[i].id == messageId) {
                _messages[i] = ChatMessage(
                  id: _messages[i].id,
                  senderId: _messages[i].senderId,
                  senderType: _messages[i].senderType,
                  senderName: _messages[i].senderName,
                  senderAvatar: _messages[i].senderAvatar,
                  message: _messages[i].message,
                  datePost: _messages[i].datePost,
                  dateFormatted: _messages[i].dateFormatted,
                  isRead: true,
                  isOwn: _messages[i].isOwn,
                );
                break;
              }
            }
          });
        }
        break;
        
      case 'ping':
        // Giữ kết nối
        break;
        
      case 'error':
        print('SSE Error: ${eventData['message']}');
        break;
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
    });

    try {
      final response = await _chatService.sendMessage(
        sessionId: _sessionId,
        phien: _phien,
        message: message,
        productId: widget.productId ?? 0,
      );

      if (response.success && response.message != null) {
        _messageController.clear();
        
        // Tin nhắn sẽ được thêm qua SSE, không cần thêm thủ công
        HapticFeedback.lightImpact();
      } else {
        _showSnackBar('Không thể gửi tin nhắn');
      }
    } catch (e) {
      _showSnackBar('Lỗi gửi tin nhắn: $e');
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  Future<void> _markAsRead() async {
    try {
      await _chatService.markAsRead(
        sessionId: _sessionId,
        phien: _phien,
      );
    } catch (e) {
      print('Error marking as read: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String? safeAvatar = (widget.shopAvatar != null &&
            widget.shopAvatar!.trim().isNotEmpty &&
            (widget.shopAvatar!.startsWith('http://') || widget.shopAvatar!.startsWith('https://')))
        ? widget.shopAvatar
        : null;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: safeAvatar != null
                  ? NetworkImage(safeAvatar)
                  : null,
              child: safeAvatar == null
                  ? const Icon(Icons.store, size: 16)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.shopName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Row(
                    children: [
                      Icon(
                        _isConnected ? Icons.circle : Icons.circle_outlined,
                        size: 8,
                        color: _isConnected ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isConnected ? 'Đang hoạt động' : 'Đang kết nối...',
                        style: TextStyle(
                          fontSize: 12,
                          color: _isConnected ? Colors.green : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _markAsRead,
            icon: const Icon(Icons.done_all),
            tooltip: 'Đánh dấu đã đọc',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(_error!, style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _initializeChat,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          return _buildMessageBubble(message);
                        },
                      ),
                    ),
                    _buildMessageInput(),
                  ],
                ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isOwn ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: message.isOwn ? const Color(0xFF0FC6FF) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.message,
              style: TextStyle(
                color: message.isOwn ? Colors.white : Colors.black87,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message.dateFormatted,
                  style: TextStyle(
                    color: message.isOwn ? Colors.white70 : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                if (message.isOwn) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.isRead ? Icons.done_all : Icons.done,
                    size: 12,
                    color: message.isRead ? Colors.white70 : Colors.white70,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Nhập tin nhắn...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _isSending ? null : _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isSending ? Colors.grey : const Color(0xFF0FC6FF),
                shape: BoxShape.circle,
              ),
              child: _isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
