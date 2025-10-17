// Image URL normalizer
String? _fixImageUrl(String? rawUrl) {
  if (rawUrl == null) return null;
  String url = rawUrl.trim();
  if (url.isEmpty) return null;
  if (url.startsWith('@')) url = url.substring(1);
  if (url.startsWith('/uploads/') || url.startsWith('uploads/')) {
    url = url.replaceFirst(RegExp(r'^/'), '');
    return 'https://socdo.vn/$url';
  }
  if (url.startsWith('http://') || url.startsWith('https://')) {
    url = url.replaceFirst('://api.socdo.vn', '://socdo.vn');
    url = url.replaceFirst('://www.api.socdo.vn', '://socdo.vn');
    url = url.replaceFirst('://www.socdo.vn', '://socdo.vn');
    if (url.startsWith('http://')) url = url.replaceFirst('http://', 'https://');
    return url;
  }
  url = url.replaceFirst(RegExp(r'^/'), '');
  return 'https://socdo.vn/$url';
}

class FreeShipProduct {
  final int id;
  final String name;
  final String? image;
  final int price;
  final int? oldPrice;
  final double? rating;
  final int? sold;
  final String? description;
  final String? brand;
  final bool isFreeship;
  final String? category;
  final int? shopId;
  final String? shopName;
  
  // Thông tin freeship chi tiết
  final int freeShipMode; // 0, 1, 2, 3
  final String freeShipType; // 'full', 'fixed', 'percent', 'per_product'
  final String freeShipLabel; // 'Freeship 100%', 'Giảm 15,000đ', etc.
  final String freeShipDetails; // Chi tiết điều kiện
  final String freeShipBadgeColor; // Màu badge
  final int? minOrderValue; // Giá trị đơn tối thiểu
  final int? freeShipDiscountValue; // Giá trị giảm

  const FreeShipProduct({
    required this.id,
    required this.name,
    this.image,
    required this.price,
    this.oldPrice,
    this.rating,
    this.sold,
    this.description,
    this.brand,
    this.isFreeship = true,
    this.category,
    this.shopId,
    this.shopName,
    this.freeShipMode = 0,
    this.freeShipType = 'unknown',
    this.freeShipLabel = '',
    this.freeShipDetails = '',
    this.freeShipBadgeColor = '#4CAF50',
    this.minOrderValue,
    this.freeShipDiscountValue,
  });

  factory FreeShipProduct.fromJson(Map<String, dynamic> json) {
    // Parse shipping_info
    final shippingInfo = json['shipping_info'] as Map<String, dynamic>?;
    
    return FreeShipProduct(
      id: json['id'] as int? ?? json['product_id'] as int? ?? 0,
      name: json['name'] as String? ?? json['title'] as String? ?? json['product_name'] as String? ?? 'Sản phẩm',
      image: json['image'] as String? ?? json['image_url'] as String? ?? json['thumbnail'] as String?,
      price: json['price'] as int? ?? json['current_price'] as int? ?? json['sale_price'] as int? ?? 0,
      oldPrice: json['old_price'] as int? ?? json['original_price'] as int? ?? json['list_price'] as int?,
      rating: (json['rating'] as num?)?.toDouble() ?? (json['average_rating'] as num?)?.toDouble(),
      sold: json['sold'] as int? ?? json['sold_count'] as int? ?? json['quantity_sold'] as int?,
      description: json['description'] as String? ?? json['desc'] as String?,
      brand: json['brand'] as String? ?? json['manufacturer'] as String?,
      isFreeship: json['is_freeship'] as bool? ?? json['free_shipping'] as bool? ?? (shippingInfo?['has_free_shipping'] as bool? ?? true),
      category: json['category'] as String? ?? json['category_name'] as String?,
      shopId: (json['shop_id'] ?? json['shop']) != null ? int.tryParse((json['shop_id'] ?? json['shop']).toString()) : null,
      shopName: json['shop_name'] as String? ?? json['ten_shop'] as String? ?? shippingInfo?['shop_name'] as String?,
      // Parse freeship details
      freeShipMode: shippingInfo?['free_ship_mode'] as int? ?? 0,
      freeShipType: shippingInfo?['free_ship_type'] as String? ?? 'unknown',
      freeShipLabel: shippingInfo?['free_ship_label'] as String? ?? '',
      freeShipDetails: shippingInfo?['free_ship_details'] as String? ?? '',
      freeShipBadgeColor: shippingInfo?['free_ship_badge_color'] as String? ?? '#4CAF50',
      minOrderValue: shippingInfo?['min_order_value'] as int?,
      freeShipDiscountValue: shippingInfo?['free_ship_discount_value'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'price': price,
      'old_price': oldPrice,
      'rating': rating,
      'sold': sold,
      'description': description,
      'brand': brand,
      'is_freeship': isFreeship,
      'category': category,
      'shop_id': shopId,
      'shop_name': shopName,
    };
  }

  FreeShipProduct copyWith({
    int? id,
    String? name,
    String? image,
    int? price,
    int? oldPrice,
    double? rating,
    int? sold,
    String? description,
    String? brand,
    bool? isFreeship,
    String? category,
  }) {
    return FreeShipProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      price: price ?? this.price,
      oldPrice: oldPrice ?? this.oldPrice,
      rating: rating ?? this.rating,
      sold: sold ?? this.sold,
      description: description ?? this.description,
      brand: brand ?? this.brand,
      isFreeship: isFreeship ?? this.isFreeship,
      category: category ?? this.category,
    );
  }

  /// Lấy URL hình ảnh ưu tiên với domain đúng
  String? get imageUrl {
    return _fixImageUrl(image);
  }

  @override
  String toString() {
    return 'FreeShipProduct(id: $id, name: $name, price: $price, isFreeship: $isFreeship)';
  }
}
