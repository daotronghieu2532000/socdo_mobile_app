import 'package:flutter/material.dart';
import 'widgets/header_card.dart';
import 'widgets/section_header.dart';
import 'widgets/action_list.dart';
import 'models/action_item.dart';
import '../../core/services/auth_service.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text('Tài khoản của tôi'),
      ),
      body: ListView(
        children: [
          const HeaderCard(),
          const SizedBox(height: 12),
          const SectionHeader(title: 'Đơn hàng/ Sản phẩm'),
          ActionList(items: const [
            ActionItem(Icons.receipt_long_outlined, 'Tất cả đơn hàng'),
            ActionItem(Icons.shopping_bag_outlined, 'Sản phẩm đã mua'),
            ActionItem(Icons.visibility_outlined, 'Sản phẩm đã xem'),
            ActionItem(Icons.favorite_border, 'Sản phẩm yêu thích'),
          ]),
          const SizedBox(height: 12),
          const SectionHeader(title: 'Cá nhân'),
          ActionList(items: const [
            ActionItem(Icons.location_on_outlined, 'Sổ địa chỉ'),
            ActionItem(Icons.sell_outlined, 'Mã giảm giá'),
            ActionItem(Icons.star_border, 'Lịch sử đánh giá'),
            ActionItem(Icons.notifications_outlined, 'Thông báo'),
          ]),
          const SizedBox(height: 12),
          const SectionHeader(title: 'Hỗ trợ'),
          ActionList(items: const [
            ActionItem(Icons.headset_mic_outlined, 'Trung tâm trợ giúp'),
            ActionItem(Icons.bug_report_outlined, 'Báo lỗi cho chúng tôi'),
            ActionItem(Icons.star_outline, 'Đánh giá ứng dụng'),
          ]),
          const SizedBox(height: 24),
          // Logout Button
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () async {
                final authService = AuthService();
                final isLoggedIn = await authService.isLoggedIn();
                
                if (isLoggedIn) {
                  // Show confirmation dialog
                  final shouldLogout = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Đăng xuất'),
                        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Hủy'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text(
                              'Đăng xuất',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                  
                  if (shouldLogout == true) {
                    await authService.logout();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Đã đăng xuất thành công'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );
                      Navigator.of(context).pop();
                    }
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Bạn chưa đăng nhập'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.logout, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Đăng xuất',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // App Version Info
          Center(
            child: Column(
              children: [
                Text(
                  'App version V3.4.34',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Last updated 10.08.2025',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}



