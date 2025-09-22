class FavoriteProduct {
  final String id;
  final String name;
  final String brand;
  final String store;
  final String image;
  final int price;
  final double rating;
  final int reviewCount;
  final bool isInStock;
  final String? productCode;

  const FavoriteProduct({
    required this.id,
    required this.name,
    required this.brand,
    required this.store,
    required this.image,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.isInStock,
    this.productCode,
  });

  static List<FavoriteProduct> get sampleProducts => [
    FavoriteProduct(
      id: '1',
      name: 'Viên uống Collagen Youtheory Type 1 2 & 3 của Mỹ 126477',
      brand: 'Youtheory',
      store: 'Xuân Xuân Minh Pharma',
      image: 'lib/src/core/assets/images/product_1.png',
      price: 620000,
      rating: 4.8,
      reviewCount: 33,
      isInStock: true,
      productCode: '126477',
    ),
    FavoriteProduct(
      id: '2',
      name: 'Viên uống Collagen Youtheory Type 1 2 & 3 của Mỹ, 390 viên 278052',
      brand: 'Youtheory',
      store: 'Huệ Store',
      image: 'lib/src/core/assets/images/product_2.png',
      price: 570000,
      rating: 4.6,
      reviewCount: 9,
      isInStock: false,
      productCode: '278052',
    ),
  ];
}
