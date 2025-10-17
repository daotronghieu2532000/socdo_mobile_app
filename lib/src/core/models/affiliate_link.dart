import 'affiliate_product.dart';

class AffiliateLink {
  final int id;
  final int spId;
  final String productTitle;
  final String productImage;
  final double productPrice;
  final double oldPrice;
  final int discountPercent;
  final int shopId;
  final String shortLink;
  final String fullLink;
  final int clicks;
  final int orders;
  final double commission;
  final String createdAt;
  final List<CommissionInfo> commissionInfo;

  AffiliateLink({
    required this.id,
    required this.spId,
    required this.productTitle,
    required this.productImage,
    required this.productPrice,
    required this.oldPrice,
    required this.discountPercent,
    required this.shopId,
    required this.shortLink,
    required this.fullLink,
    required this.clicks,
    required this.orders,
    required this.commission,
    required this.createdAt,
    required this.commissionInfo,
  });

  factory AffiliateLink.fromJson(Map<String, dynamic> json) {
    // Fix image URL if needed
    String imageUrl = json['product_image'] ?? '';
    if (imageUrl.isNotEmpty) {
      if (!imageUrl.startsWith('http')) {
        imageUrl = 'https://socdo.vn$imageUrl';
      } else if (imageUrl.contains('api.socdo.vn')) {
        imageUrl = imageUrl.replaceAll('api.socdo.vn', 'socdo.vn');
      }
    }

    final commissionList = json['commission_info'] as List? ?? [];

    return AffiliateLink(
      id: json['id'] ?? 0,
      spId: json['sp_id'] ?? 0,
      productTitle: json['product_title'] ?? '',
      productImage: imageUrl,
      productPrice: (json['product_price'] ?? 0).toDouble(),
      oldPrice: (json['old_price'] ?? 0).toDouble(),
      discountPercent: json['discount_percent'] ?? 0,
      shopId: json['shop_id'] ?? 0,
      shortLink: json['short_link'] ?? '',
      fullLink: json['full_link'] ?? '',
      clicks: json['clicks'] ?? 0,
      orders: json['orders'] ?? 0,
      commission: (json['commission'] ?? 0).toDouble(),
      createdAt: json['created_at'] ?? json['followed_at'] ?? '',
      commissionInfo: commissionList
          .map((item) => CommissionInfo.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  double get conversionRate {
    if (clicks == 0) return 0;
    return (orders / clicks * 100);
  }

  String get conversionRateText {
    return '${conversionRate.toStringAsFixed(1)}%';
  }

  // Getter for backward compatibility
  int get productId => spId;
}

