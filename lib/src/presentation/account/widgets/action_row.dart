import 'package:flutter/material.dart';
import '../../favorite_products/favorite_products_screen.dart';
import '../../orders/orders_screen.dart';

class ActionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  const ActionRow({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _handleNavigation(context),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      dense: true,
    );
  }

  void _handleNavigation(BuildContext context) {
    switch (title) {
      case 'Tất cả đơn hàng':
        Navigator.pushNamed(context, '/orders');
        break;
      case 'Thông tin cá nhân':
        Navigator.pushNamed(context, '/profile/edit');
        break;
      case 'Sản phẩm yêu thích':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const FavoriteProductsScreen(),
          ),
        );
        break;
      case 'Thông báo':
        Navigator.pushNamed(context, '/notifications');
        break;
      case 'Đã huỷ & Trả lại':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const OrdersScreen(initialIndex: 4),
          ),
        );
        break;
      default:
        // Handle other navigation cases
        break;
    }
  }
}
