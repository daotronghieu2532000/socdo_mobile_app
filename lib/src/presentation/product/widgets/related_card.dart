import 'package:flutter/material.dart';

class RelatedCard extends StatelessWidget {
  final int index;
  final Map<String, dynamic>? product;
  final VoidCallback? onTap;

  const RelatedCard({
    super.key,
    required this.index,
    this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final products = [
      {
        'name': 'Kem tẩy lông Balea 125ml',
        'currentPrice': '190.000₫',
        'originalPrice': '239.000₫',
        'discount': '-21%',
        'rating': '4.8',
        'sold': '5',
        'image': 'lib/src/core/assets/images/product_1.png',
      },
      {
        'name': 'Kem Chống Nắng TABAHA Sunscreen 60ml SPF50+ P...',
        'currentPrice': '139.000₫',
        'originalPrice': '219.000₫',
        'discount': '-37%',
        'rating': '5',
        'sold': '3',
        'image': 'lib/src/core/assets/images/product_2.png',
      },
      {
        'name': 'Sữa Neut',
        'currentPrice': '310.000₫',
        'originalPrice': '340.000₫',
        'discount': '-9%',
        'rating': '5',
        'sold': '2',
        'image': 'lib/src/core/assets/images/product_3.png',
      },
    ];
    
    final productData = product ?? products[index % products.length];
    
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 180,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F7FB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        productData['image']!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(Icons.image, color: Colors.grey, size: 40),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        productData['discount']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              productData['name']!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  productData['currentPrice']!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  productData['originalPrice']!,
                  style: const TextStyle(
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 12),
                const SizedBox(width: 2),
                Text(
                  '${productData['rating']} | Đã bán ${productData['sold']}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
