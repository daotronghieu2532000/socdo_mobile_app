import 'package:flutter/material.dart';
import 'widgets/header_card.dart';
import 'widgets/section_header.dart';
import 'widgets/action_list.dart';
import 'widgets/logout_confirmation_dialog.dart';
import 'models/action_item.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/app_initialization_service.dart';
import '../root_shell.dart';

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
          const SectionHeader(title: 'Tài khoản'),
          ActionList(items: const [
            ActionItem(Icons.manage_accounts_outlined, 'Thông tin cá nhân'),
            ActionItem(Icons.receipt_long_outlined, 'Tất cả đơn hàng'),
            ActionItem(Icons.shopping_bag_outlined, 'Sản phẩm đã mua'),
            ActionItem(Icons.favorite_border, 'Sản phẩm yêu thích'),
          ]),
          const SizedBox(height: 12),
          const SectionHeader(title: 'Cá nhân'),
          ActionList(items: const [
            ActionItem(Icons.location_on_outlined, 'Sổ địa chỉ'),
            ActionItem(Icons.sell_outlined, 'Mã giảm giá'),
            ActionItem(Icons.star_border, 'Lịch sử đánh giá'),
            ActionItem(Icons.inventory_2_outlined, 'Đã huỷ & Trả lại'),
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
                  final shouldLogout = await LogoutConfirmationDialog.show(context);
                  
                  if (shouldLogout == true) {
                    print('🚪 [DEBUG] Bắt đầu quá trình đăng xuất...');
                    
                    // Kiểm tra trạng thái trước khi logout
                    final beforeLogout = await authService.isLoggedIn();
                    print('🚪 [DEBUG] Trạng thái trước logout: $beforeLogout');
                    
                    await authService.logout();
                    print('🚪 [DEBUG] Đã gọi authService.logout()');
                    
                    // CRITICAL: Force clear AuthService để đảm bảo logout hoàn toàn
                    await Future.delayed(const Duration(milliseconds: 100));
                    authService.forceClear(); // Force clear để đảm bảo
                    print('🚪 [DEBUG] Đã force clear AuthService');
                    
                    // Kiểm tra trạng thái sau khi logout
                    final afterLogout = await authService.isLoggedIn();
                    print('🚪 [DEBUG] Trạng thái sau logout: $afterLogout');
                    
                    // Reset app initialization state
                    AppInitializationService().resetInitialization();
                    print('🚪 [DEBUG] Đã reset AppInitializationService');
                    
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Đã đăng xuất thành công'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );
                      print('🚪 [DEBUG] Đã hiển thị thông báo thành công');
                      
                      // Quay về trang chủ và refresh toàn bộ navigation stack
                      print('🚪 [DEBUG] Bắt đầu navigation về trang chủ...');
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const RootShell(initialIndex: 0),
                        ),
                        (route) => false,
                      );
                      print('🚪 [DEBUG] Đã hoàn thành navigation');
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
      bottomNavigationBar: const RootShellBottomBar(),
    );
  }
}



