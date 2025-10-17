import 'package:flutter/material.dart';
import '../../account/account_screen.dart';
import '../../auth/login_screen.dart';
import '../../search/search_screen.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/models/user.dart';
import '../../../core/services/api_service.dart';

class HomeAppBar extends StatefulWidget {
  const HomeAppBar({super.key});

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar> {
  final _authService = AuthService();
  final _api = ApiService();
  User? _currentUser;
  bool _isLoading = true;
  int _unread = 0;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    
    // Thêm listener để cập nhật khi trạng thái đăng nhập thay đổi
    _authService.addAuthStateListener(_checkLoginStatus);
  }

  @override
  void dispose() {
    // Xóa listener khi dispose
    _authService.removeAuthStateListener(_checkLoginStatus);
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        final user = await _authService.getCurrentUser();
        setState(() {
          _currentUser = user;
          _isLoading = false;
        });
        _loadUnread();
      } else {
        setState(() {
          _currentUser = null;
          _isLoading = false;
        });
        setState(() => _unread = 0);
      }
    } catch (e) {
      setState(() {
        _currentUser = null;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUnread() async {
    if (_currentUser == null) return;
    final res = await _api.getNotifications(userId: _currentUser!.userId, page: 1, limit: 1, unreadOnly: true);
    if (!mounted) return;
    setState(() {
      _unread = (res?['data']?['unread_count'] as int?) ?? 0;
    });
  }

  void _handleSearchTap() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SearchScreen()),
    );
  }

  Future<void> _handleAvatarTap() async {
    if (_currentUser != null) {
      // Đã đăng nhập - vào trang tài khoản
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AccountScreen()),
      );
    } else {
      // Chưa đăng nhập - vào trang đăng nhập
      final result = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      
      // Nếu đăng nhập thành công, refresh trạng thái
      if (result == true) {
        _checkLoginStatus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _handleSearchTap,
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F3F7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.search, color: Colors.grey),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tìm kiếm sản phẩm, nhà bán hàng...',
                          style: TextStyle(color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Bell icon with unread badge
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/notifications').then((_) => _loadUnread()),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.notifications_none, color: Colors.black87),
                  ),
                  if (_unread > 0)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _unread > 99 ? '99+' : '$_unread',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Avatar hoặc nút đăng nhập
            GestureDetector(
              onTap: _handleAvatarTap,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _currentUser != null ? Colors.red[300]! : Colors.grey[300]!,
                    width: 2,
                  ),
                ),
                child: _isLoading
                    ? const Center(
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : _currentUser != null
                        ? CircleAvatar(
                            backgroundImage: _currentUser!.avatar != null && _currentUser!.avatar!.isNotEmpty
                                ? NetworkImage(_authService.getAvatarUrl(_currentUser!.avatar))
                                : const AssetImage('lib/src/core/assets/images/user_default.png') as ImageProvider,
                            backgroundColor: Colors.grey[200],
                            onBackgroundImageError: (exception, stackTrace) {
                              // Fallback to default image if network image fails
                            },
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Icon(
                              Icons.person_add,
                              color: Colors.red[600],
                              size: 20,
                            ),
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
