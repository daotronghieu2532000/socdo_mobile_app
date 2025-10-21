import 'package:flutter/material.dart';
import '../../core/services/chat_service.dart';
import '../../core/services/token_manager.dart';
import '../../core/models/chat.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ChatService _chatService = ChatService();
  final TokenManager _tokenManager = TokenManager();
  
  List<ChatSession> _sessions = [];
  bool _isLoading = true;
  String? _error;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    try {
      final token = await _tokenManager.getToken();
      if (token == null) {
        setState(() {
          _error = 'Không có token';
          _isLoading = false;
        });
        return;
      }
      
      final payload = _tokenManager.getTokenPayload(token);
      if (payload == null || payload['user_id'] == null) {
        setState(() {
          _error = 'Token không hợp lệ';
          _isLoading = false;
        });
        return;
      }
      
      _userId = int.parse(payload['user_id'].toString());
      await _loadSessions();
    } catch (e) {
      setState(() {
        _error = 'Lỗi tải thông tin user: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadSessions() async {
    if (_userId == null) return;
    
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await _chatService.getSessions(
        userId: _userId!,
        userType: 'customer',
        limit: 50,
      );

      if (response.success) {
        setState(() {
          _sessions = response.sessions;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Không thể tải danh sách chat';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Lỗi tải danh sách chat: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshSessions() async {
    await _loadSessions();
  }

  void _navigateToChat(ChatSession session) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          shopId: session.shopId,
          shopName: session.shopName,
          shopAvatar: session.shopAvatar,
        ),
      ),
    ).then((_) {
      // Refresh danh sách khi quay lại
      _refreshSessions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tin nhắn'),
        actions: [
          IconButton(
            onPressed: _refreshSessions,
            icon: const Icon(Icons.refresh),
            tooltip: 'Làm mới',
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
                        onPressed: _refreshSessions,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : _sessions.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Chưa có tin nhắn nào',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Hãy bắt đầu chat với nhà bán từ trang sản phẩm',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _refreshSessions,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _sessions.length,
                        itemBuilder: (context, index) {
                          final session = _sessions[index];
                          return _buildSessionCard(session);
                        },
                      ),
                    ),
    );
  }

  Widget _buildSessionCard(ChatSession session) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          radius: 24,
          backgroundImage: session.shopAvatar.isNotEmpty && 
              (session.shopAvatar.startsWith('http://') || session.shopAvatar.startsWith('https://'))
              ? NetworkImage(session.shopAvatar)
              : null,
          child: session.shopAvatar.isEmpty || 
              (!session.shopAvatar.startsWith('http://') && !session.shopAvatar.startsWith('https://'))
              ? const Icon(Icons.store, size: 20)
              : null,
        ),
        title: Text(
          session.shopName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (session.lastMessage != null && session.lastMessage!.isNotEmpty)
              Text(
                session.lastMessage!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              session.lastMessageFormatted,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: session.unreadCount > 0
            ? Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                constraints: const BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
                child: Text(
                  session.unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            : null,
        onTap: () => _navigateToChat(session),
      ),
    );
  }
}
