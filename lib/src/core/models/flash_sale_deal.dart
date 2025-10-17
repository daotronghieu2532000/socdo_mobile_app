import 'flash_sale_product.dart';

class FlashSaleDeal {
  final int id;
  final int shop;
  final String title;
  final String mainProduct;
  final String subProduct;
  final String subId;
  final int dateStart;
  final int dateEnd;
  final String type;
  final int datePost;
  final int status;
  final String? timeline;
  final String? dateStartFormatted;
  final String? dateEndFormatted;
  final String? datePostFormatted;
  final List<FlashSaleProduct> mainProducts;
  final List<FlashSaleProduct> subProducts;
  final String dealStatus;
  final bool isTimelineActive;
  final int timeRemaining;
  final String timeRemainingFormatted;
  final Map<String, dynamic>? timelineInfo;

  const FlashSaleDeal({
    required this.id,
    required this.shop,
    required this.title,
    required this.mainProduct,
    required this.subProduct,
    required this.subId,
    required this.dateStart,
    required this.dateEnd,
    required this.type,
    required this.datePost,
    required this.status,
    this.timeline,
    this.dateStartFormatted,
    this.dateEndFormatted,
    this.datePostFormatted,
    required this.mainProducts,
    required this.subProducts,
    required this.dealStatus,
    required this.isTimelineActive,
    required this.timeRemaining,
    required this.timeRemainingFormatted,
    this.timelineInfo,
  });

  factory FlashSaleDeal.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse int
    int? safeParseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      if (value is double) return value.toInt();
      return null;
    }

    // Parse main_products
    List<FlashSaleProduct> mainProducts = [];
    if (json['main_products'] is List) {
      mainProducts = (json['main_products'] as List)
          .map((product) => FlashSaleProduct.fromJson(product as Map<String, dynamic>))
          .toList();
    }

    // Parse sub_products
    List<FlashSaleProduct> subProducts = [];
    if (json['sub_products'] is List) {
      subProducts = (json['sub_products'] as List)
          .map((product) => FlashSaleProduct.fromJson(product as Map<String, dynamic>))
          .toList();
    }

    // Parse timeline_info
    Map<String, dynamic>? timelineInfo;
    if (json['timeline_info'] is Map) {
      timelineInfo = Map<String, dynamic>.from(json['timeline_info']);
    }

    return FlashSaleDeal(
      id: safeParseInt(json['id']) ?? 0,
      shop: safeParseInt(json['shop']) ?? 0,
      title: json['tieu_de'] as String? ?? '',
      mainProduct: json['main_product'] as String? ?? '',
      subProduct: json['sub_product'] as String? ?? '',
      subId: json['sub_id'] as String? ?? '',
      dateStart: safeParseInt(json['date_start']) ?? 0,
      dateEnd: safeParseInt(json['date_end']) ?? 0,
      type: json['loai'] as String? ?? '',
      datePost: safeParseInt(json['date_post']) ?? 0,
      status: safeParseInt(json['status']) ?? 0,
      timeline: json['timeline'] as String?,
      dateStartFormatted: json['date_start_formatted'] as String?,
      dateEndFormatted: json['date_end_formatted'] as String?,
      datePostFormatted: json['date_post_formatted'] as String?,
      mainProducts: mainProducts,
      subProducts: subProducts,
      dealStatus: json['deal_status'] as String? ?? 'inactive',
      isTimelineActive: json['is_timeline_active'] as bool? ?? false,
      timeRemaining: safeParseInt(json['time_remaining']) ?? 0,
      timeRemainingFormatted: json['time_remaining_formatted'] as String? ?? '00:00:00',
      timelineInfo: timelineInfo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop': shop,
      'tieu_de': title,
      'main_product': mainProduct,
      'sub_product': subProduct,
      'sub_id': subId,
      'date_start': dateStart,
      'date_end': dateEnd,
      'loai': type,
      'date_post': datePost,
      'status': status,
      'timeline': timeline,
      'date_start_formatted': dateStartFormatted,
      'date_end_formatted': dateEndFormatted,
      'date_post_formatted': datePostFormatted,
      'main_products': mainProducts.map((p) => p.toJson()).toList(),
      'sub_products': subProducts.map((p) => p.toJson()).toList(),
      'deal_status': dealStatus,
      'is_timeline_active': isTimelineActive,
      'time_remaining': timeRemaining,
      'time_remaining_formatted': timeRemainingFormatted,
      'timeline_info': timelineInfo,
    };
  }

  /// Lấy tất cả sản phẩm từ deal (main + sub)
  List<FlashSaleProduct> get allProducts {
    final List<FlashSaleProduct> all = [];
    all.addAll(mainProducts);
    all.addAll(subProducts);
    return all;
  }

  /// Kiểm tra deal có đang active không
  bool get isActive {
    return dealStatus == 'active' && isTimelineActive;
  }

  /// Kiểm tra deal có sắp diễn ra không
  bool get isUpcoming {
    return dealStatus == 'upcoming';
  }

  /// Kiểm tra deal đã hết hạn chưa
  bool get isExpired {
    return dealStatus == 'expired';
  }

  /// Lấy thời gian bắt đầu dưới dạng DateTime
  DateTime? get startDateTime {
    if (dateStart == 0) return null;
    return DateTime.fromMillisecondsSinceEpoch(dateStart * 1000);
  }

  /// Lấy thời gian kết thúc dưới dạng DateTime
  DateTime? get endDateTime {
    if (dateEnd == 0) return null;
    return DateTime.fromMillisecondsSinceEpoch(dateEnd * 1000);
  }

  /// Tính thời gian còn lại (seconds)
  int get timeRemainingSeconds {
    if (timeRemaining > 0) return timeRemaining;
    
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final remaining = dateEnd - now;
    return remaining > 0 ? remaining : 0;
  }

  /// Format thời gian còn lại
  String get formattedTimeRemaining {
    final remaining = timeRemainingSeconds;
    if (remaining <= 0) return 'Đã kết thúc';
    
    final hours = remaining ~/ 3600;
    final minutes = (remaining % 3600) ~/ 60;
    final seconds = remaining % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  @override
  String toString() {
    return 'FlashSaleDeal(id: $id, title: $title, status: $dealStatus, timeline: $timeline)';
  }
}
