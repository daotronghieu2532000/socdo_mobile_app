class BannerModel {
  final int id;
  final String title;
  final String image;
  final String link;
  final String position;
  final int order;
  final int shopId;
  final String type;
  final bool isActive;

  BannerModel({
    required this.id,
    required this.title,
    required this.image,
    required this.link,
    required this.position,
    required this.order,
    required this.shopId,
    required this.type,
    required this.isActive,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      image: json['image'] ?? '',
      link: json['link'] ?? '',
      position: json['position'] ?? '',
      order: json['order'] ?? 0,
      shopId: json['shop_id'] ?? 0,
      type: json['type'] ?? 'image',
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image': image,
      'link': link,
      'position': position,
      'order': order,
      'shop_id': shopId,
      'type': type,
      'is_active': isActive,
    };
  }
}

