import 'package:flutter/material.dart';
import '../../viewed_products/viewed_products_screen.dart';
import '../../favorite_products/favorite_products_screen.dart';
import '../../notifications/notifications_screen.dart';

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
      case 'Sản phẩm đã xem':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ViewedProductsScreen(),
          ),
        );
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const NotificationsScreen(),
          ),
        );
        break;
      default:
        // Handle other navigation cases
        break;
    }
  }
}
