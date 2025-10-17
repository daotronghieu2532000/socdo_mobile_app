import 'package:flutter/material.dart';

class ShopBar extends StatelessWidget {
  final String? shopName;
  final String? shopLogo;
  final String? shopAvatar;
  final String? shopAddress;
  final String? shopUrl;
  final double rating;
  final int reviewCount;
  final VoidCallback? onViewShop;

  const ShopBar({
    super.key,
    this.shopName,
    this.shopLogo,
    this.shopAvatar,
    this.shopAddress,
    this.shopUrl,
    this.rating = 4.46,
    this.reviewCount = 24,
    this.onViewShop,
  });

  @override
  Widget build(BuildContext context) {
    String firstLetter() {
      final base = (shopLogo?.trim().isNotEmpty == true)
          ? shopLogo!.trim()
          : (shopName?.trim().isNotEmpty == true)
              ? shopName!.trim()
              : 'S';
      return base.isNotEmpty ? base.characters.first.toUpperCase() : 'S';
    }

    return SliverToBoxAdapter(
      child: GestureDetector(
        onTap: onViewShop,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12), // Giảm padding từ 20 xuống 12
          decoration: const BoxDecoration(
            color: Color(0xFFF8F9FA), // Màu nền nhẹ nhàng, đơn giản hơn
          ),
          child: Row(
            children: [
              Container(
                width: 59, // Tăng kích thước ảnh shop
                height: 59,
                decoration: BoxDecoration(
                  color: const Color(0xFF0FC6FF),
                  borderRadius: BorderRadius.circular(12), // Bo góc nhiều hơn
                ),
                child: shopAvatar?.isNotEmpty == true
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12), // Bo góc nhiều hơn
                        child: Image.network(
                          shopAvatar!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Text(
                              firstLetter(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16, // Tăng kích thước chữ
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          firstLetter(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16, // Tăng kích thước chữ
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 16), // Tăng khoảng cách
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      shopName ?? 'Shop',
                      style: const TextStyle(
                        fontSize: 14, // Tăng kích thước tên shop
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4), // Tăng khoảng cách
                    Text(
                      shopAddress?.isNotEmpty == true 
                          ? shopAddress!
                          : '$rating | $reviewCount đánh giá',
                      style: const TextStyle(
                        fontSize: 14, // Tăng kích thước địa chỉ
                        color: Colors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Tăng padding
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12), // Bo góc nhiều hơn
                ),
                child: const Text(
                  'Xem Shop',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16, // Tăng kích thước chữ
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
