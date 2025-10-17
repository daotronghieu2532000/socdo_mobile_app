import 'package:flutter/material.dart';
import '../../flash_sale/flash_sale_screen.dart';
import '../../freeship/freeship_products_screen.dart';
import '../../voucher/voucher_screen.dart';
import '../../orders/orders_screen.dart';

class QuickActions extends StatelessWidget {
  final List<QAItem> items = const [
    QAItem(Icons.flash_on, 'Flash Sale'),
    QAItem(Icons.local_shipping, 'Freeship'),
    QAItem(Icons.confirmation_number_outlined, 'Voucher'),
    QAItem(Icons.receipt_long_outlined, 'Đơn hàng'),
  ];

  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (int i = 0; i < items.length; i++)
            GestureDetector(
              onTap: () {
                if (i == 0) { // Flash Sale item
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const FlashSaleScreen(),
                    ),
                  );
                } else if (i == 1) { // Ship 0 đồng item
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const FreeShipProductsScreen(),
                    ),
                  );
                } else if (i == 2) { // Voucher item
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const VoucherScreen(),
                    ),
                  );
                } else if (i == 3) { // Đơn hàng
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const OrdersScreen(),
                    ),
                  );
                }
                // Add other navigation logic for other items if needed
              },
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    child: Icon(items[i].icon, color: Colors.red),
                  ),
                  const SizedBox(height: 6),
                  Text(items[i].label, style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class QAItem {
  final IconData icon;
  final String label;
  const QAItem(this.icon, this.label);
}
