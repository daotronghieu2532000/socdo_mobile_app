import 'package:flutter/material.dart';
import 'status_item.dart';
import 'dart:async';
import '../../../core/services/auth_service.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/user.dart';
import '../../orders/orders_screen.dart';

class HeaderCard extends StatefulWidget {
  const HeaderCard({super.key});

  @override
  State<HeaderCard> createState() => _HeaderCardState();
}

class _HeaderCardState extends State<HeaderCard> {
  final _authService = AuthService();
  final _apiService = ApiService();
  User? _currentUser;
  bool _isLoading = true;
  Map<String, int> _counts = const {
    'cho_xac_nhan': 0,
    'cho_lay_hang': 0,
    'cho_giao_hang': 0,
    'da_huy_tra': 0,
    'da_huy_don': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    
    // Thêm listener để cập nhật khi trạng thái đăng nhập thay đổi
    _authService.addAuthStateListener(_loadUserInfo);
    // Poll counts every 30s similar to Orders badges
    _startPolling();
  }

  @override
  void dispose() {
    // Xóa listener khi dispose
    _authService.removeAuthStateListener(_loadUserInfo);
    _pollTimer?.cancel();
    super.dispose();
  }

  Timer? _pollTimer;
  void _startPolling(){
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) => _loadCounts());
  }

  Future<void> _loadUserInfo() async {
    print('👤 [DEBUG] HeaderCard: Bắt đầu load user info...');
    try {
      final user = await _authService.getCurrentUser();
      print('👤 [DEBUG] HeaderCard: getCurrentUser() = ${user?.name ?? "null"}');
      
      // CRITICAL: Kiểm tra mounted trước khi setState
      if (!mounted) {
        print('👤 [DEBUG] HeaderCard: Widget đã dispose, bỏ qua setState');
        return;
      }
      
      if (user != null) {
        // Thử lấy thông tin mới nhất từ API user_profile
        try {
          final profile = await _apiService.getUserProfile(userId: user.userId);
          if (profile != null && profile['user'] != null) {
            final u = profile['user'] as Map<String, dynamic>;
            int parseInt(dynamic v) {
              if (v == null) return 0;
              if (v is int) return v;
              if (v is String) return int.tryParse(v) ?? 0;
              if (v is num) return v.toInt();
              return 0;
            }
            final updated = user.copyWith(
              name: (u['name']?.toString() ?? user.name),
              username: (u['username']?.toString() ?? user.username),
              email: (u['email']?.toString() ?? user.email),
              mobile: (u['mobile']?.toString() ?? user.mobile),
              avatar: (u['avatar']?.toString().isNotEmpty == true ? u['avatar'].toString() : user.avatar),
              userMoney: parseInt(u['user_money']),
              userMoney2: parseInt(u['user_money2']),
            );
            await _authService.updateUser(updated);
            setState(() {
              _currentUser = updated;
              _isLoading = false;
            });
            // Sau khi có user -> tải badge
            _loadCounts();
            _startPolling();
            return;
          }
        } catch (_) {}
      }
      if (mounted) {
        setState(() {
          _currentUser = user;
          _isLoading = false;
        });
        print('👤 [DEBUG] HeaderCard: Set _currentUser = ${user?.name ?? "null"}');
        _loadCounts();
        _startPolling();
      }
    } catch (e) {
      print('👤 [DEBUG] HeaderCard: Lỗi khi load user info: $e');
      if (mounted) {
        setState(() {
          _currentUser = null;
          _isLoading = false;
        });
      }
    }
    print('👤 [DEBUG] HeaderCard: Hoàn thành load user info');
  }

  Future<void> _loadCounts() async {
    if (_currentUser == null) return;
    final uid = _currentUser!.userId;
    // Use grouped logic to mirror Orders tabs
    final all = await _apiService.getOrdersList(userId: uid, page: 1, limit: 100, status: null);
    final list = (all?['data']?['orders'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    int toInt(dynamic v){ if(v is int) return v; if(v is String) return int.tryParse(v)??0; if(v is num) return v.toInt(); return 0; }
    int c0=0,c1=0,c2=0,c3=0,c4=0;
    for(final o in list){
      final s = toInt(o['status'] ?? o['trangthai']);
      if ([0,1].contains(s)) {
        c0++;
      } else if ([11,10,12].contains(s)) c1++;
      else if ([2,8,9,7,14].contains(s)) c2++;
      else if ([5].contains(s)) c3++;
      else if ([3,4,6].contains(s)) c4++; // Đơn hàng hủy: 3=yêu cầu hủy, 4=đã hủy, 6=đã hoàn đơn
    }
    if (!mounted) return;
    setState(() {
      _counts = {
        'cho_xac_nhan': c0,
        'cho_lay_hang': c1,
        'cho_giao_hang': c2,
        'da_huy_tra': c3,
        'da_huy_don': c4,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0xFFD9E3F0),
                    backgroundImage: _currentUser?.avatar != null && _currentUser!.avatar!.isNotEmpty
                        ? NetworkImage(_authService.getAvatarUrl(_currentUser!.avatar))
                        : const AssetImage('lib/src/core/assets/images/user_default.png') as ImageProvider,
                    onBackgroundImageError: (exception, stackTrace) {
                      // Fallback to default image if network image fails
                    },
                  ),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: GestureDetector(
                      onTap: () async {
                        // Điều hướng tới màn hình sửa avatar (sẽ thêm sau)
                        Navigator.of(context).pushNamed('/profile/edit');
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
                          ],
                        ),
                        child: const Icon(Icons.edit, size: 16, color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_isLoading)
                      Container(
                        height: 20,
                        width: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      )
                    else if (_currentUser != null)
                      Text(
                        _authService.getDisplayName(_currentUser!),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      )
                    else
                      const Text(
                        'Chưa đăng nhập',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.grey),
                      ),
                    const SizedBox(height: 4),
                    if (_isLoading)
                      Container(
                        height: 16,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      )
                    else if (_currentUser != null)
                      Text(
                        'Số dư: ${_authService.getFormattedBalance(_currentUser!)}',
                        style: const TextStyle(color: Colors.grey),
                      )
                    else
                      const Text(
                        'Đăng nhập để xem thông tin',
                        style: TextStyle(color: Colors.grey),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Container(
          //   decoration: BoxDecoration(
          //     color: const Color(0xFFF6F7FB),
          //     borderRadius: BorderRadius.circular(12),
          //   ),
          //   padding: const EdgeInsets.all(12),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: const [
          //       Text('Điểm tích luỹ của bạn là:'),
          //       Text('0', style: TextStyle(fontWeight: FontWeight.w700)),
          //     ],
          //   ),
          // ),
          // const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              StatusItem(
                icon: Icons.receipt_long,
                label: 'Chờ xác nhận',
                count: _counts['cho_xac_nhan'] ?? 0,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const _OrdersShortcut(index: 0))),
              ),
              StatusItem(
                icon: Icons.store_mall_directory,
                label: 'Chờ lấy hàng',
                count: _counts['cho_lay_hang'] ?? 0,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const _OrdersShortcut(index: 1))),
              ),
              StatusItem(
                icon: Icons.local_shipping,
                label: 'Chờ giao hàng',
                count: _counts['cho_giao_hang'] ?? 0,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const _OrdersShortcut(index: 2))),
              ),
              StatusItem(
                icon: Icons.reviews,
                label: 'Đánh giá',
                count: _counts['da_huy_tra'] ?? 0,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const _OrdersShortcut(index: 3))),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _OrdersShortcut extends StatelessWidget {
  final int index;
  const _OrdersShortcut({required this.index});

  @override
  Widget build(BuildContext context) {
    return OrdersScreen(initialIndex: index);
  }
}

