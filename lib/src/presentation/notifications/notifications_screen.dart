import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../core/services/auth_service.dart';
import '../root_shell.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ApiService _api = ApiService();
  final AuthService _auth = AuthService();
  bool _loading = true;
  int _unread = 0;
  List<dynamic> _items = [];
  int? _userId;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final logged = await _auth.isLoggedIn();
    if (!mounted) return;
    if (!logged) {
      setState(() {
        _userId = null;
        _loading = false;
      });
      return;
    }
    final user = await _auth.getCurrentUser();
    _userId = user?.userId;
    await _load();
  }

  Future<void> _load() async {
    if (_userId == null) return;
    setState(() => _loading = true);
    final data = await _api.getNotifications(userId: _userId!, page: 1, limit: 20);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _items = (data?['data']?['notifications'] as List?) ?? [];
      _unread = (data?['data']?['unread_count'] as int?) ?? 0;
    });
  }

  Future<void> _markAllRead() async {
    if (_userId == null) return;
    final ok = await _api.markAllNotificationsRead(userId: _userId!);
    if (ok) await _load();
  }

  Future<void> _markRead(int id) async {
    if (_userId == null) return;
    final ok = await _api.markNotificationRead(userId: _userId!, notificationId: id);
    if (ok) await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text('Thông báo'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Builder(
        builder: (context) {
          if (_loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_userId == null) {
            return _LoggedOutView();
          }
          return RefreshIndicator(
            onRefresh: _load,
            child: ListView(
              children: [
          // Header với số lượng thông báo
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.notifications_active,
                    color: Colors.red[600],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _unread > 0
                            ? 'Bạn có $_unread thông báo mới'
                            : 'Không có thông báo mới',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Cập nhật lần cuối: Hôm nay',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: _unread > 0 ? _markAllRead : null,
                  child: const Text(
                    'Đánh dấu tất cả đã đọc',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Danh sách thông báo
          Container(
            color: Colors.white,
            child: _items.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Text('Chưa có thông báo'),
                    ),
                  )
                : Column(
                    children: [
                      for (int i = 0; i < _items.length; i++) ...[
                        _buildNotificationItem(
                          id: _items[i]['id'] ?? 0,
                          icon: Icons.notifications,
                          iconColor: Colors.blueGrey,
                          title: _items[i]['title']?.toString() ?? 'Thông báo',
                          subtitle: _items[i]['content']?.toString() ?? '',
                          time: _items[i]['time_ago']?.toString() ?? '',
                          isRead: (_items[i]['is_read'] as bool?) ?? false,
                        ),
                        if (i < _items.length - 1) const Divider(height: 1),
                      ],
                    ],
                  ),
          ),
          
          const SizedBox(height: 12),
          
          // Nút xóa tất cả thông báo
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () {
                _showDeleteConfirmDialog(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[50],
                foregroundColor: Colors.red[600],
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.delete_outline, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Xóa tất cả thông báo',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const RootShellBottomBar(),
    );
  }

  Widget _buildNotificationItem({
    required int id,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String time,
    required bool isRead,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isRead ? FontWeight.w500 : FontWeight.w600,
          color: isRead ? Colors.grey[600] : Colors.black87,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
      trailing: isRead 
          ? null 
          : Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
      onTap: () => _markRead(id),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xóa tất cả thông báo'),
          content: const Text('Bạn có chắc chắn muốn xóa tất cả thông báo? Hành động này không thể hoàn tác.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Xóa tất cả thông báo
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã xóa tất cả thông báo'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text(
                'Xóa',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LoggedOutView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Bạn chưa đăng nhập'),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/login'),
            child: const Text('Đăng nhập'),
          ),
        ],
      ),
    );
  }
}