class ViewedProduct {
  final String id;
  final String name;
  final String brand;
  final String image;
  final int price;
  final int? oldPrice;
  final double rating;
  final int reviewCount;
  final String? badge; // "BÁN CHẠY", "MỚI", etc.

  const ViewedProduct({
    required this.id,
    required this.name,
    required this.brand,
    required this.image,
    required this.price,
    this.oldPrice,
    required this.rating,
    required this.reviewCount,
    this.badge,
  });

  static List<ViewedProduct> get sampleProducts => [
    ViewedProduct(
      id: '1',
      name: 'Viên uống chống lão hoá, đẹp da Collagen Youtheory Type 1-2-3 - 390 viên',
      brand: 'Youtheory',
      image: 'lib/src/core/assets/images/product_1.png',
      price: 880000,
      oldPrice: 1200000,
      rating: 4.8,
      reviewCount: 97,
    ),
    ViewedProduct(
      id: '2',
      name: 'Okinawa Fucoidan của Nhật - Fucoidan xanh 180 viên',
      brand: 'Kanehide Bio',
      image: 'lib/src/core/assets/images/product_2.png',
      price: 1799000,
      rating: 4.9,
      reviewCount: 71,
      badge: 'BÁN CHẠY',
    ),
    ViewedProduct(
      id: '3',
      name: 'Viên uống Transino White C Clear hỗ trợ trắng da, cải thiện nám',
      brand: 'Transino',
      image: 'lib/src/core/assets/images/product_3.png',
      price: 530000,
      rating: 4.7,
      reviewCount: 215,
    ),
    ViewedProduct(
      id: '4',
      name: '[Mẫu mới] Viên Uống Collagen + Biotin Youtheory 390 viên của Mỹ',
      brand: 'Youtheory',
      image: 'lib/src/core/assets/images/product_4.png',
      price: 750000,
      rating: 4.9,
      reviewCount: 439,
    ),
    ViewedProduct(
      id: '5',
      name: 'Viên Uống Collagen Youtheory của Mỹ',
      brand: 'Youtheory',
      image: 'lib/src/core/assets/images/product_5.png',
      price: 645000,
      rating: 4.6,
      reviewCount: 32,
    ),
  ];
}
