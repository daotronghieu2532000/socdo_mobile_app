class ShopDetail {
  final ShopInfo shopInfo;
  final List<ShopProduct> products;
  final List<ShopFlashSale> flashSales;
  final List<ShopVoucher> vouchers;
  final List<ShopWarehouse> warehouses;
  final List<ShopCategory> categories;
  final ShopStatistics statistics;
  final ShopParameters parameters;

  const ShopDetail({
    required this.shopInfo,
    required this.products,
    required this.flashSales,
    required this.vouchers,
    required this.warehouses,
    required this.categories,
    required this.statistics,
    required this.parameters,
  });

  factory ShopDetail.fromJson(Map<String, dynamic> json) {
    print('🔍 Debug ShopDetail.fromJson: ${json.keys}');

    try {
      // Debug từng field
      print('🔍 shop_info type: ${json['shop_info'].runtimeType}');
      print('🔍 products type: ${json['products'].runtimeType}');
      print('🔍 flash_sales type: ${json['flash_sales'].runtimeType}');
      print('🔍 vouchers type: ${json['vouchers'].runtimeType}');
      print('🔍 warehouses type: ${json['warehouses'].runtimeType}');
      print('🔍 categories type: ${json['categories'].runtimeType}');
      print('🔍 statistics type: ${json['statistics']?.runtimeType}');
      print('🔍 parameters type: ${json['parameters']?.runtimeType}');

      print('🔍 Bắt đầu parse shopInfo...');
      final shopInfo = ShopInfo.fromJson(json['shop_info'] as Map<String, dynamic>);
      print('✅ shopInfo parse thành công');
      
      print('🔍 Bắt đầu parse products...');
      final List<ShopProduct> products = (json['products'] as List?)
          ?.map((product) => ShopProduct.fromJson(product as Map<String, dynamic>))
          .toList() ?? <ShopProduct>[];
      print('✅ products parse thành công: ${products.length} sản phẩm');
      
      print('🔍 Bắt đầu parse flashSales...');
      final List<ShopFlashSale> flashSales = json.containsKey('flash_sales') && json['flash_sales'] is List
          ? (json['flash_sales'] as List)
              .map((flashSale) => ShopFlashSale.fromJson(flashSale as Map<String, dynamic>))
              .toList()
          : <ShopFlashSale>[];
      print('✅ flashSales parse thành công: ${flashSales.length} flash sales');
      
      print('🔍 Bắt đầu parse vouchers...');
      final List<ShopVoucher> vouchers = json.containsKey('vouchers') && json['vouchers'] is List
          ? (json['vouchers'] as List)
              .map((voucher) => ShopVoucher.fromJson(voucher as Map<String, dynamic>))
              .toList()
          : <ShopVoucher>[];
      print('✅ vouchers parse thành công: ${vouchers.length} vouchers');
      
      print('🔍 Bắt đầu parse warehouses...');
      final List<ShopWarehouse> warehouses = json.containsKey('warehouses') && json['warehouses'] is List
          ? (json['warehouses'] as List)
              .map((warehouse) => ShopWarehouse.fromJson(warehouse as Map<String, dynamic>))
              .toList()
          : <ShopWarehouse>[];
      print('✅ warehouses parse thành công: ${warehouses.length} warehouses');
      
      print('🔍 Bắt đầu parse categories...');
      final List<ShopCategory> categories = json.containsKey('categories') && json['categories'] is List
          ? (json['categories'] as List)
              .map((category) => ShopCategory.fromJson(category as Map<String, dynamic>))
              .toList()
          : <ShopCategory>[];
      print('✅ categories parse thành công: ${categories.length} categories');
      
      print('🔍 Tạo ShopDetail object...');
      return ShopDetail(
        shopInfo: shopInfo,
        products: products,
        flashSales: flashSales,
        vouchers: vouchers,
        warehouses: warehouses,
        categories: categories,
        statistics: ShopStatistics.empty(),
        parameters: ShopParameters.empty(),
      );
    } catch (e) {
      print('❌ Lỗi ShopDetail.fromJson: $e');
      print('❌ JSON data: $json');
      rethrow;
    }
  }
}

class ShopInfo {
  final int shopId;
  final int parentShopId;
  final String username;
  final String name;
  final String email;
  final String mobile;
  final String address;
  final String about;
  final String avatarUrl;
  final String shopUrl;
  final int isCtv;
  final int isDropship;
  final int isLeader;
  final int createdAt;
  final String createdAtFormatted;
  final int updatedAt;
  final int lastLogin;
  final int lastOnline;
  final int totalProducts;

  const ShopInfo({
    required this.shopId,
    required this.parentShopId,
    required this.username,
    required this.name,
    required this.email,
    required this.mobile,
    required this.address,
    required this.about,
    required this.avatarUrl,
    required this.shopUrl,
    required this.isCtv,
    required this.isDropship,
    required this.isLeader,
    required this.createdAt,
    required this.createdAtFormatted,
    required this.updatedAt,
    required this.lastLogin,
    required this.lastOnline,
    required this.totalProducts,
  });

  factory ShopInfo.fromJson(Map<String, dynamic> json) {
    return ShopInfo(
      shopId: json['shop_id'] as int? ?? 0,
      parentShopId: json['parent_shop_id'] as int? ?? 0,
      username: json['username'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      mobile: json['mobile'] as String? ?? '',
      address: json['address'] as String? ?? '',
      about: json['about'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String? ?? '',
      shopUrl: json['shop_url'] as String? ?? '',
      isCtv: json['is_ctv'] as int? ?? 0,
      isDropship: json['is_dropship'] as int? ?? 0,
      isLeader: json['is_leader'] as int? ?? 0,
      createdAt: json['created_at'] as int? ?? 0,
      createdAtFormatted: json['created_at_formatted'] as String? ?? '',
      updatedAt: json['updated_at'] as int? ?? 0,
      lastLogin: json['last_login'] as int? ?? 0,
      lastOnline: json['last_online'] as int? ?? 0,
      totalProducts: json['total_products'] as int? ?? 0,
    );
  }
}

class ShopProduct {
  final int id;
  final String name;
  final String slug;
  final int price;
  final int oldPrice;
  final int ctvPrice;
  final int discountPercent;
  final List<int> categoryIds;
  final int brandId;
  final int stock;
  final int sold;
  final int views;
  final String image;
  final String thumb;
  final String productUrl;
  final List<String> badges;
  final int isBestseller;
  final int isFeatured;
  final int isFlashSale;
  final int createdAt;
  final String priceFormatted;
  final String oldPriceFormatted;
  final String ctvPriceFormatted;
  final String voucherIcon;
  final String freeshipIcon;
  final String chinhhangIcon;
  final String warehouseName;
  final String provinceName;

  const ShopProduct({
    required this.id,
    required this.name,
    required this.slug,
    required this.price,
    required this.oldPrice,
    required this.ctvPrice,
    required this.discountPercent,
    required this.categoryIds,
    required this.brandId,
    required this.stock,
    required this.sold,
    required this.views,
    required this.image,
    required this.thumb,
    required this.productUrl,
    required this.badges,
    required this.isBestseller,
    required this.isFeatured,
    required this.isFlashSale,
    required this.createdAt,
    required this.priceFormatted,
    required this.oldPriceFormatted,
    required this.ctvPriceFormatted,
    required this.voucherIcon,
    required this.freeshipIcon,
    required this.chinhhangIcon,
    required this.warehouseName,
    required this.provinceName,
  });

  factory ShopProduct.fromJson(Map<String, dynamic> json) {
    return ShopProduct(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      price: json['price'] as int? ?? 0,
      oldPrice: json['old_price'] as int? ?? 0,
      ctvPrice: json['ctv_price'] as int? ?? 0,
      discountPercent: json['discount_percent'] as int? ?? 0,
      categoryIds: (json['category_ids'] as List?)?.cast<int>() ?? [],
      brandId: json['brand_id'] as int? ?? 0,
      stock: json['stock'] as int? ?? 0,
      sold: json['sold'] as int? ?? 0,
      views: json['views'] as int? ?? 0,
      image: json['image'] as String? ?? '',
      thumb: json['thumb'] as String? ?? '',
      productUrl: json['product_url'] as String? ?? '',
      badges: (json['badges'] as List?)?.cast<String>() ?? [],
      isBestseller: json['is_bestseller'] as int? ?? 0,
      isFeatured: json['is_featured'] as int? ?? 0,
      isFlashSale: json['is_flash_sale'] as int? ?? 0,
      createdAt: json['created_at'] as int? ?? 0,
      priceFormatted: json['price_formatted'] as String? ?? '',
      oldPriceFormatted: json['old_price_formatted'] as String? ?? '',
      ctvPriceFormatted: json['ctv_price_formatted'] as String? ?? '',
      voucherIcon: json['voucher_icon'] as String? ?? '',
      freeshipIcon: json['freeship_icon'] as String? ?? '',
      chinhhangIcon: json['chinhhang_icon'] as String? ?? '',
      warehouseName: json['warehouse_name'] as String? ?? '',
      provinceName: json['province_name'] as String? ?? '',
    );
  }
}

class ShopFlashSale {
  final int id;
  final String title;
  final List<int> mainProducts;
  final Map<String, dynamic> subProducts;
  final int startTime;
  final int endTime;
  final String timeline;
  final int createdAt;
  final int timeLeft;
  final bool isActive;

  const ShopFlashSale({
    required this.id,
    required this.title,
    required this.mainProducts,
    required this.subProducts,
    required this.startTime,
    required this.endTime,
    required this.timeline,
    required this.createdAt,
    required this.timeLeft,
    required this.isActive,
  });

  factory ShopFlashSale.fromJson(Map<String, dynamic> json) {
    return ShopFlashSale(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      mainProducts: (json['main_products'] as List?)?.cast<int>() ?? [],
      subProducts: json['sub_products'] as Map<String, dynamic>? ?? {},
      startTime: json['start_time'] as int? ?? 0,
      endTime: json['end_time'] as int? ?? 0,
      timeline: json['timeline'] as String? ?? '',
      createdAt: json['created_at'] as int? ?? 0,
      timeLeft: json['time_left'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? false,
    );
  }
}

class ShopVoucher {
  final int id;
  final String code;
  final int discountValue;
  final int maxDiscount;
  final String discountType;
  final String applyType;
  final List<int> productIds;
  final int minOrderValue;
  final int startTime;
  final int endTime;
  final String description;
  final String imageUrl;
  final int minPrice;
  final int maxPrice;
  final int allowCombination;
  final int maxUsesPerUser;
  final int maxGlobalUses;
  final int currentUses;
  final int createdAt;
  final int timeLeft;
  final bool isActive;
  final String discountDescription;

  const ShopVoucher({
    required this.id,
    required this.code,
    required this.discountValue,
    required this.maxDiscount,
    required this.discountType,
    required this.applyType,
    required this.productIds,
    required this.minOrderValue,
    required this.startTime,
    required this.endTime,
    required this.description,
    required this.imageUrl,
    required this.minPrice,
    required this.maxPrice,
    required this.allowCombination,
    required this.maxUsesPerUser,
    required this.maxGlobalUses,
    required this.currentUses,
    required this.createdAt,
    required this.timeLeft,
    required this.isActive,
    required this.discountDescription,
  });

  factory ShopVoucher.fromJson(Map<String, dynamic> json) {
    return ShopVoucher(
      id: json['id'] as int? ?? 0,
      code: json['code'] as String? ?? '',
      discountValue: json['discount_value'] as int? ?? 0,
      maxDiscount: json['max_discount'] as int? ?? 0,
      discountType: json['discount_type'] as String? ?? '',
      applyType: json['apply_type'] as String? ?? '',
      productIds: (json['product_ids'] as List?)?.cast<int>() ?? [],
      minOrderValue: json['min_order_value'] as int? ?? 0,
      startTime: json['start_time'] as int? ?? 0,
      endTime: json['end_time'] as int? ?? 0,
      description: json['description'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      minPrice: json['min_price'] as int? ?? 0,
      maxPrice: json['max_price'] as int? ?? 0,
      allowCombination: json['allow_combination'] as int? ?? 0,
      maxUsesPerUser: json['max_uses_per_user'] as int? ?? 0,
      maxGlobalUses: json['max_global_uses'] as int? ?? 0,
      currentUses: json['current_uses'] as int? ?? 0,
      createdAt: json['created_at'] as int? ?? 0,
      timeLeft: json['time_left'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? false,
      discountDescription: json['discount_description'] as String? ?? '',
    );
  }
}

class ShopWarehouse {
  final int id;
  final String? warehouseCode;
  final String? warehouseName;
  final String contactName;
  final String contactPhone;
  final int isDefault;
  final int isPickup;
  final int isReturn;
  final double latitude;
  final double longitude;
  final String addressDetail;
  final int provinceId;
  final int districtId;
  final int wardId;
  final String provinceName;
  final String districtName;
  final String wardName;
  final String fullAddress;
  final int freeShipMode;
  final int freeShipMinOrder;
  final int freeShipDiscount;
  final String freeshipDescription;

  const ShopWarehouse({
    required this.id,
    this.warehouseCode,
    this.warehouseName,
    required this.contactName,
    required this.contactPhone,
    required this.isDefault,
    required this.isPickup,
    required this.isReturn,
    required this.latitude,
    required this.longitude,
    required this.addressDetail,
    required this.provinceId,
    required this.districtId,
    required this.wardId,
    required this.provinceName,
    required this.districtName,
    required this.wardName,
    required this.fullAddress,
    required this.freeShipMode,
    required this.freeShipMinOrder,
    required this.freeShipDiscount,
    required this.freeshipDescription,
  });

  factory ShopWarehouse.fromJson(Map<String, dynamic> json) {
    return ShopWarehouse(
      id: json['id'] as int? ?? 0,
      warehouseCode: json['warehouse_code'] as String?,
      warehouseName: json['warehouse_name'] as String?,
      contactName: json['contact_name'] as String? ?? '',
      contactPhone: json['contact_phone'] as String? ?? '',
      isDefault: json['is_default'] as int? ?? 0,
      isPickup: json['is_pickup'] as int? ?? 0,
      isReturn: json['is_return'] as int? ?? 0,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      addressDetail: json['address_detail'] as String? ?? '',
      provinceId: json['province_id'] as int? ?? 0,
      districtId: json['district_id'] as int? ?? 0,
      wardId: json['ward_id'] as int? ?? 0,
      provinceName: json['province_name'] as String? ?? '',
      districtName: json['district_name'] as String? ?? '',
      wardName: json['ward_name'] as String? ?? '',
      fullAddress: json['full_address'] as String? ?? '',
      freeShipMode: json['free_ship_mode'] as int? ?? 0,
      freeShipMinOrder: json['free_ship_min_order'] as int? ?? 0,
      freeShipDiscount: json['free_ship_discount'] as int? ?? 0,
      freeshipDescription: json['freeship_description'] as String? ?? '',
    );
  }
}

class ShopCategory {
  final int id;
  final String icon;
  final String title;
  final String description;
  final int parentId;
  final int isIndex;
  final String link;
  final String image;
  final String bannerImage;
  final String leftImage;
  final String seoTitle;
  final String seoDescription;
  final int order;
  final List<int> socdoCategoryIds;
  final String socdoCategoryName;
  final String categoryUrl;

  const ShopCategory({
    required this.id,
    required this.icon,
    required this.title,
    required this.description,
    required this.parentId,
    required this.isIndex,
    required this.link,
    required this.image,
    required this.bannerImage,
    required this.leftImage,
    required this.seoTitle,
    required this.seoDescription,
    required this.order,
    required this.socdoCategoryIds,
    required this.socdoCategoryName,
    required this.categoryUrl,
  });

  factory ShopCategory.fromJson(Map<String, dynamic> json) {
    return ShopCategory(
      id: json['id'] as int? ?? 0,
      icon: json['icon'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      parentId: json['parent_id'] as int? ?? 0,
      isIndex: json['is_index'] as int? ?? 0,
      link: json['link'] as String? ?? '',
      image: json['image'] as String? ?? '',
      bannerImage: json['banner_image'] as String? ?? '',
      leftImage: json['left_image'] as String? ?? '',
      seoTitle: json['seo_title'] as String? ?? '',
      seoDescription: json['seo_description'] as String? ?? '',
      order: json['order'] as int? ?? 0,
      socdoCategoryIds: (json['socdo_category_ids'] as List?)?.cast<int>() ?? [],
      socdoCategoryName: json['socdo_category_name'] as String? ?? '',
      categoryUrl: json['category_url'] as String? ?? '',
    );
  }
}

class ShopStatistics {
  final int totalProducts;
  final int totalFlashSales;
  final int totalVouchers;
  final int totalWarehouses;
  final int totalCategories;

  const ShopStatistics({
    required this.totalProducts,
    required this.totalFlashSales,
    required this.totalVouchers,
    required this.totalWarehouses,
    required this.totalCategories,
  });

  factory ShopStatistics.fromJson(Map<String, dynamic> json) {
    try {
      print('🔍 Debug ShopStatistics.fromJson: ${json.keys}');

      return ShopStatistics(
        totalProducts: json['total_products'] as int,
        totalFlashSales: json['total_flash_sales'] as int,
        totalVouchers: json['total_vouchers'] as int,
        totalWarehouses: json['total_warehouses'] as int,
        totalCategories: json['total_categories'] as int,
      );
    } catch (e) {
      print('❌ Lỗi ShopStatistics.fromJson: $e');
      print('❌ JSON data: $json');
      rethrow;
    }
  }

  factory ShopStatistics.empty() {
    return const ShopStatistics(
      totalProducts: 0,
      totalFlashSales: 0,
      totalVouchers: 0,
      totalWarehouses: 0,
      totalCategories: 0,
    );
  }
}

class ShopParameters {
  final int shopId;
  final String username;
  final int includeProducts;
  final int includeFlashSale;
  final int includeVouchers;
  final int includeWarehouses;
  final int includeCategories;
  final int productsLimit;

  const ShopParameters({
    required this.shopId,
    required this.username,
    required this.includeProducts,
    required this.includeFlashSale,
    required this.includeVouchers,
    required this.includeWarehouses,
    required this.includeCategories,
    required this.productsLimit,
  });

  factory ShopParameters.fromJson(Map<String, dynamic> json) {
    try {
      print('🔍 Debug ShopParameters.fromJson: ${json.keys}');

      return ShopParameters(
        shopId: json['shop_id'] as int,
        username: json['username'] as String,
        includeProducts: json['include_products'] as int,
        includeFlashSale: json['include_flash_sale'] as int,
        includeVouchers: json['include_vouchers'] as int,
        includeWarehouses: json['include_warehouses'] as int,
        includeCategories: json['include_categories'] as int,
        productsLimit: json['products_limit'] as int,
      );
    } catch (e) {
      print('❌ Lỗi ShopParameters.fromJson: $e');
      print('❌ JSON data: $json');
      rethrow;
    }
  }

  factory ShopParameters.empty() {
    return const ShopParameters(
      shopId: 0,
      username: '',
      includeProducts: 0,
      includeFlashSale: 0,
      includeVouchers: 0,
      includeWarehouses: 0,
      includeCategories: 0,
      productsLimit: 0,
    );
  }
}
