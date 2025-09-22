import 'package:flutter/material.dart';
import '../../../core/assets/app_images.dart';
import '../../../core/utils/format_utils.dart';

class FlashSaleProductCard extends StatelessWidget {
  final int index;

  const FlashSaleProductCard({
    super.key,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final products = [
      {
        'name': 'Sữa tắm kháng khuẩn ASEPSO sạch sâu tươi mát Chiết Xuất Thiên Nhiên 1000 ml',
        'brand': 'Asepso',
        'originalPrice': 239000,
        'discount': 25,
        'rating': 4.5,
        'reviews': 15,
        'sold': 137,
        'image': AppImages.products[0],
      },
      {
        'name': 'Gennie Little Red Dress nước hoa nữ shower gel 450ml',
        'brand': 'Gennie',
        'originalPrice': 159000,
        'discount': 20,
        'rating': 4.2,
        'reviews': 5,
        'sold': 138,
        'image': AppImages.products[1],
      },
      {
        'name': 'Gota Iconic 2in1 nước hoa shower gel 480g',
        'brand': 'Gota',
        'originalPrice': 179000,
        'discount': 20,
        'rating': 4.3,
        'reviews': 23,
        'sold': 297,
        'image': AppImages.products[2],
      },
    ];

    final product = products[index % products.length];
    final newPrice = (product['originalPrice'] as int) * (100 - (product['discount'] as int)) / 100;

    String formatSold(int sold) {
      if (sold >= 1000) {
        final double inK = sold / 1000.0;
        String s = inK.toStringAsFixed(inK.truncateToDouble() == inK ? 0 : 1);
        return '$s+';
      }
      return '$sold';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Product image
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F6FB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    product['image'] as String,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => const Center(
                      child: Icon(Icons.image_not_supported, size: 32, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: Icon(
                  Icons.favorite_border,
                  color: Colors.grey[400],
                  size: 20,
                ),
              ),
              Positioned(
                bottom: 4,
                left: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '-${product['discount']}%',
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
          
          const SizedBox(width: 12),
          
          // Product details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brand
                Text(
                  product['brand'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                
                // Product name
                Text(
                  product['name'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                
                // Price section (new price first, then old price)
                Row(
                  children: [
                    Text(
                      FormatUtils.formatCurrency(newPrice.round()),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      FormatUtils.formatCurrency(product['originalPrice'] as int),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Rating and sold row under price
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      '${product['rating']} | Đã bán ${formatSold(product['sold'] as int)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Hot deal badge and action buttons
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red[600],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.local_fire_department, size: 12, color: Colors.white),
                          const SizedBox(width: 2),
                          const Text(
                            'BÁN CHẠY',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.red, width: 1.5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.shopping_cart,
                        color: Colors.red,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Center(
                          child: Text(
                            'Mua ngay',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
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
