import 'package:flutter/material.dart';
import '../../../core/assets/app_images.dart';
import '../../../core/utils/format_utils.dart';

class SuggestCard extends StatelessWidget {
  final int index;
  const SuggestCard({super.key, required this.index});

  final List<Map<String, dynamic>> _suggestProducts = const [
    {
      'title': 'Viên uống Collagen Youtheory Type 1 2 & 3 của Mỹ, 390 viên',
      'currentPrice': 615000,
      'oldPrice': 670000,
      'discount': 8,
      'rating': 4.9,
      'sales': '15.2k+',
      'isBestSeller': true,
    },
    {
      'title': 'Okinawa Fucoidan của Nhật - Fucoidan xanh 180 viên',
      'currentPrice': 1799000,
      'oldPrice': 2100000,
      'discount': 14,
      'rating': 5.0,
      'sales': '6.2k+',
      'isBestSeller': true,
    },
    {
      'title': 'Viên Uống Collagen Youtheory của Mỹ',
      'currentPrice': 642700,
      'oldPrice': 747300,
      'discount': 14,
      'rating': 5.0,
      'sales': '25',
      'isBestSeller': false,
    },
    {
      'title': '[Mẫu mới] Viên Uống Collagen + Biotin Youtheory...',
      'currentPrice': 750000,
      'oldPrice': 800000,
      'discount': 6,
      'rating': 5.0,
      'sales': '217',
      'isBestSeller': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final product = _suggestProducts[index % _suggestProducts.length];
    
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  color: const Color(0xFFF4F6FB),
                  child: Image.asset(
                    AppImages.products[index % AppImages.products.length],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (c, e, s) => const Center(child: Icon(Icons.image, size: 48, color: Colors.grey)),
                  ),
                ),
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '-${product['discount']}%',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['title'] as String,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      FormatUtils.formatCurrency(product['currentPrice'] as int),
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      FormatUtils.formatCurrency(product['oldPrice'] as int),
                      style: const TextStyle(
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 12, color: Colors.amber),
                    const SizedBox(width: 2),
                    Text(
                      '${product['rating']}',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Đã bán ${product['sales']}',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
