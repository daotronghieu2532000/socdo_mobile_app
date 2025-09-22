import 'package:flutter/material.dart';
import '../../../core/assets/app_images.dart';
import '../../../core/utils/format_utils.dart';

class ProductSection extends StatelessWidget {
  const ProductSection({super.key});

  final List<Map<String, dynamic>> _products = const [
    {
      'title': 'Viên uống Collagen Youtheory Type 1 2 & 3 của Mỹ, 390 viên',
      'currentPrice': 615000,
      'oldPrice': 670000,
      'quantity': 1,
      'image': 1,
    },
    {
      'title': 'Viên uống chống lão hoá, đẹp da Collagen Youtheory Type 1-2-3 - 390 viên của Mỹ',
      'currentPrice': 880000,
      'oldPrice': 900000,
      'quantity': 1,
      'image': 0,
    },
    {
      'title': 'Okinawa Fucoidan của Nhật - Fucoidan xanh 180 viên',
      'currentPrice': 1799000,
      'oldPrice': 2100000,
      'quantity': 1,
      'image': 2,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.store, color: Colors.grey),
              const SizedBox(width: 8),
              const Text('VitaGlow', style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          const Divider(height: 20),
          for (int i = 0; i < _products.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 60,
                    height: 60,
                    color: const Color(0xFFF4F6FB),
                    child: Image.asset(
                      AppImages.products[_products[i]['image'] as int],
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => const Icon(Icons.image, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _products[i]['title'] as String,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            FormatUtils.formatCurrency(_products[i]['currentPrice'] as int),
                            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            FormatUtils.formatCurrency(_products[i]['oldPrice'] as int),
                            style: const TextStyle(
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Text('x${_products[i]['quantity']}', style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
