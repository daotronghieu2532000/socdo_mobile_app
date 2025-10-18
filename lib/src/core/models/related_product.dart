class RelatedProduct {
  final int id;
  final String name;
  final String slug;
  final int price;
  final int oldPrice;
  final int discountPercent;
  final String image;
  final int shopId;
  final String shopName;
  final int brandId;
  final String brandName;
  final List<int> categoryIds;
  final int totalReviews;
  final double avgRating;
  final int totalSold;
  final int totalViews;
  final bool isFlashSale;
  final bool hasFreeShipping;
  final List<String> badges;
  final String productUrl;
  final String priceFormatted;
  final String oldPriceFormatted;
  
  // Thông tin badges từ API (giống ProductSuggest)
  final String? voucherIcon;
  final String? freeshipIcon;
  final String? chinhhangIcon;
  final String? warehouseName;
  final String? provinceName;

  RelatedProduct({
    required this.id,
    required this.name,
    required this.slug,
    required this.price,
    required this.oldPrice,
    required this.discountPercent,
    required this.image,
    required this.shopId,
    required this.shopName,
    required this.brandId,
    required this.brandName,
    required this.categoryIds,
    required this.totalReviews,
    required this.avgRating,
    required this.totalSold,
    required this.totalViews,
    required this.isFlashSale,
    required this.hasFreeShipping,
    required this.badges,
    required this.productUrl,
    required this.priceFormatted,
    required this.oldPriceFormatted,
    this.voucherIcon,
    this.freeshipIcon,
    this.chinhhangIcon,
    this.warehouseName,
    this.provinceName,
  });

  factory RelatedProduct.fromJson(Map<String, dynamic> json) {
    return RelatedProduct(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      price: json['price'] ?? 0,
      oldPrice: json['old_price'] ?? 0,
      discountPercent: json['discount_percent'] ?? 0,
      image: json['image'] ?? '',
      shopId: json['shop_id'] ?? 0,
      shopName: json['shop_name'] ?? '',
      brandId: json['brand_id'] ?? 0,
      brandName: json['brand_name'] ?? '',
      categoryIds: (json['category_ids'] as List<dynamic>?)?.map((e) => e as int).toList() ?? [],
      totalReviews: json['total_reviews'] ?? 0,
      avgRating: (json['avg_rating'] ?? 0.0).toDouble(),
      totalSold: json['total_sold'] ?? 0,
      totalViews: json['total_views'] ?? 0,
      isFlashSale: json['is_flash_sale'] ?? false,
      hasFreeShipping: json['has_free_shipping'] ?? false,
      badges: (json['badges'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      productUrl: json['product_url'] ?? '',
      priceFormatted: json['price_formatted'] ?? '',
      oldPriceFormatted: json['old_price_formatted'] ?? '',
      // Parse badges từ API
      voucherIcon: json['voucher_icon'] as String?,
      freeshipIcon: json['freeship_icon'] as String?,
      chinhhangIcon: json['chinhhang_icon'] as String?,
      warehouseName: json['warehouse_name'] as String?,
      provinceName: json['province_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'price': price,
      'old_price': oldPrice,
      'discount_percent': discountPercent,
      'image': image,
      'shop_id': shopId,
      'shop_name': shopName,
      'brand_id': brandId,
      'brand_name': brandName,
      'category_ids': categoryIds,
      'total_reviews': totalReviews,
      'avg_rating': avgRating,
      'total_sold': totalSold,
      'total_views': totalViews,
      'is_flash_sale': isFlashSale,
      'has_free_shipping': hasFreeShipping,
      'badges': badges,
      'product_url': productUrl,
      'price_formatted': priceFormatted,
      'old_price_formatted': oldPriceFormatted,
      'voucher_icon': voucherIcon,
      'freeship_icon': freeshipIcon,
      'chinhhang_icon': chinhhangIcon,
      'warehouse_name': warehouseName,
      'province_name': provinceName,
    };
  }
}
