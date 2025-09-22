import 'package:flutter/material.dart';
import 'status_item.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/models/user.dart';

class HeaderCard extends StatefulWidget {
  const HeaderCard({super.key});

  @override
  State<HeaderCard> createState() => _HeaderCardState();
}

class _HeaderCardState extends State<HeaderCard> {
  final _authService = AuthService();
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    
    // Thêm listener để cập nhật khi trạng thái đăng nhập thay đổi
    _authService.addAuthStateListener(_loadUserInfo);
  }

  @override
  void dispose() {
    // Xóa listener khi dispose
    _authService.removeAuthStateListener(_loadUserInfo);
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    try {
      final user = await _authService.getCurrentUser();
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _currentUser = null;
        _isLoading = false;
      });
    }
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
            children: const [
              StatusItem(icon: Icons.move_to_inbox_outlined, label: 'Đã tiếp nhận'),
              StatusItem(icon: Icons.local_shipping_outlined, label: 'Đang giao'),
              StatusItem(icon: Icons.shopping_cart_checkout_outlined, label: 'Thành công'),
              StatusItem(icon: Icons.inventory_2_outlined, label: 'Đã huỷ & Trả lại'),
            ],
          )
        ],
      ),
    );
  }
}
