import 'dart:async';
import 'api_service.dart';
import 'affiliate_service.dart';
import 'memory_cache_service.dart';
import '../models/product_detail.dart';
import '../models/voucher.dart';
import '../models/shop_detail.dart';

/// Enhanced API Service với Memory Cache
/// Tự động cache dữ liệu API để giảm số lần gọi và cải thiện performance
class CachedApiService {
  static final CachedApiService _instance = CachedApiService._internal();
  factory CachedApiService() => _instance;
  CachedApiService._internal();

  final ApiService _apiService = ApiService();
  final AffiliateService _affiliateService = AffiliateService();
  final MemoryCacheService _cache = MemoryCacheService();
  
  // Cache duration cho từng loại API
  static const Duration _defaultCacheDuration = Duration(minutes: 5);
  static const Duration _longCacheDuration = Duration(minutes: 30);
  static const Duration _shortCacheDuration = Duration(minutes: 2);

  /// Khởi tạo service
  void initialize() {
    _cache.initialize();
    print('✅ CachedApiService initialized');
  }

  /// Dispose service
  void dispose() {
    _cache.dispose();
  }

  /// Lấy chi tiết shop với cache
  Future<ShopDetail?> getShopDetailCached({
    int? shopId,
    String? username,
    int includeProducts = 1,
    int includeFlashSale = 1,
    int includeVouchers = 1,
    int includeWarehouses = 1,
    int includeCategories = 1,
    int productsLimit = 20,
    bool forceRefresh = false,
    Duration? cacheDuration,
  }) async {
    final cacheKey = MemoryCacheService.createKey(
      CacheKeys.shopDetail,
      {
        if (shopId != null) 'shopId': shopId,
        if (username != null) 'username': username,
        'p': includeProducts,
        'fs': includeFlashSale,
        'v': includeVouchers,
        'w': includeWarehouses,
        'c': includeCategories,
        'limit': productsLimit,
      },
    );

    if (!forceRefresh && _cache.has(cacheKey)) {
      final cached = _cache.get<ShopDetail>(cacheKey);
      if (cached != null) {
        print('🏪 Using cached shop detail for $shopId/$username');
        return cached;
      }
    }

    try {
      print('🌐 Fetching shop detail from API for $shopId/$username...');
      final detail = await _apiService.getShopDetail(
        shopId: shopId,
        username: username,
        includeProducts: includeProducts,
        includeFlashSale: includeFlashSale,
        includeVouchers: includeVouchers,
        includeWarehouses: includeWarehouses,
        includeCategories: includeCategories,
        productsLimit: productsLimit,
      );

      if (detail != null) {
        _cache.set(cacheKey, detail, duration: cacheDuration ?? _defaultCacheDuration);
        print('✅ Shop detail cached successfully for $shopId/$username');
      }
      return detail;
    } catch (e) {
      print('❌ Error fetching shop detail: $e');
      final cached = _cache.get<ShopDetail>(cacheKey);
      if (cached != null) {
        print('🔄 Using stale cache for shop detail $shopId/$username');
        return cached;
      }
      rethrow;
    }
  }

  /// Lấy banners cho trang chủ với cache
  Future<List<Map<String, dynamic>>> getHomeBanners({
    bool forceRefresh = false,
    Duration? cacheDuration,
  }) async {
    const cacheKey = CacheKeys.homeBanners;
    
    // Kiểm tra cache trước
    if (!forceRefresh && _cache.has(cacheKey)) {
      final cachedData = _cache.get<List<Map<String, dynamic>>>(cacheKey);
      if (cachedData != null) {
        print('📱 Using cached home banners');
        return cachedData;
      }
    }

    try {
      print('🌐 Fetching home banners from API...');
      final banners = await _apiService.getBanners(
        position: 'banner_index_mobile',
        limit: 10,
      );
      
      // Convert BannerModel to Map
      final bannersData = banners?.map((banner) => banner.toJson()).toList() ?? [];
      
      // Lưu vào cache
      _cache.set(cacheKey, bannersData, duration: cacheDuration ?? _defaultCacheDuration);
      
      print('✅ Home banners cached successfully');
      return bannersData;
    } catch (e) {
      print('❌ Error fetching home banners: $e');
      
      // Fallback về cache cũ nếu có
      final cachedData = _cache.get<List<Map<String, dynamic>>>(cacheKey);
      if (cachedData != null) {
        print('🔄 Using stale cache for home banners');
        return cachedData;
      }
      
      rethrow;
    }
  }

  /// Lấy flash sale cho trang chủ với cache (theo khung giờ hiện tại)
  Future<List<Map<String, dynamic>>> getHomeFlashSale({
    bool forceRefresh = false,
    Duration? cacheDuration,
  }) async {
    // Xác định timeline hiện tại giống UI
    final now = DateTime.now();
    final hour = now.hour;
    final String currentTimeline = (hour >= 0 && hour < 9)
        ? '00:00'
        : (hour >= 9 && hour < 16)
            ? '09:00'
            : '16:00';

    // Bao gồm timeline trong cache key để tránh lẫn dữ liệu giữa các khung giờ
    final cacheKey = MemoryCacheService.createKey(
      CacheKeys.homeFlashSale,
      {'slot': currentTimeline},
    );
    
    // Migration: Xóa cache cũ dùng key cố định nếu còn tồn tại để tránh dùng nhầm dữ liệu slot khác
    if (_cache.has(CacheKeys.homeFlashSale)) {
      _cache.remove(CacheKeys.homeFlashSale);
    }

    // Kiểm tra cache trước
    if (!forceRefresh && _cache.has(cacheKey)) {
      final cachedData = _cache.get<List<Map<String, dynamic>>>(cacheKey);
      if (cachedData != null) {
        print('⚡ Using cached home flash sale');
        return cachedData;
      }
    }

    try {
      print('🌐 Fetching home flash sale from API for slot: $currentTimeline...');
      final flashSaleDeals = await _apiService.getFlashSaleDeals(
        timeSlot: currentTimeline,
        status: 'active',
        limit: 100,
      );
      
      // Convert FlashSaleDeal to Map
      final flashSaleData = flashSaleDeals?.map((deal) => deal.toJson()).toList() ?? [];
      
      // Lưu vào cache với thời gian ngắn hơn vì flash sale thay đổi nhanh
      _cache.set(cacheKey, flashSaleData, duration: cacheDuration ?? _shortCacheDuration);
      
      print('✅ Home flash sale cached successfully');
      return flashSaleData;
    } catch (e) {
      print('❌ Error fetching home flash sale: $e');
      
      // Fallback về cache cũ nếu có
      final cachedData = _cache.get<List<Map<String, dynamic>>>(cacheKey);
      if (cachedData != null) {
        print('🔄 Using stale cache for home flash sale');
        return cachedData;
      }
      
      rethrow;
    }
  }

  /// Lấy banner đối tác cho trang chủ với cache
  Future<List<Map<String, dynamic>>> getHomePartnerBanners({
    bool forceRefresh = false,
    Duration? cacheDuration,
  }) async {
    const cacheKey = CacheKeys.homePartnerBanners;
    
    // Kiểm tra cache trước
    if (!forceRefresh && _cache.has(cacheKey)) {
      final cachedData = _cache.get<List<Map<String, dynamic>>>(cacheKey);
      if (cachedData != null) {
        print('🤝 Using cached partner banners');
        return cachedData;
      }
    }

    try {
      print('🌐 Fetching partner banners from API...');
      final banners = await _apiService.getBanners(
        position: 'banner_doitac',
        limit: 10,
      );
      
      // Convert BannerModel to Map
      final bannersData = banners?.map((banner) => banner.toJson()).toList() ?? [];
      
      // Lưu vào cache
      _cache.set(cacheKey, bannersData, duration: cacheDuration ?? _longCacheDuration);
      
      print('✅ Partner banners cached successfully');
      return bannersData;
    } catch (e) {
      print('❌ Error fetching partner banners: $e');
      
      // Fallback về cache cũ nếu có
      final cachedData = _cache.get<List<Map<String, dynamic>>>(cacheKey);
      if (cachedData != null) {
        print('🔄 Using stale cache for partner banners');
        return cachedData;
      }
      
      rethrow;
    }
  }

  /// Lấy sản phẩm gợi ý cho trang chủ với cache
  Future<List<Map<String, dynamic>>> getHomeSuggestions({
    int limit = 20,
    bool forceRefresh = false,
    Duration? cacheDuration,
  }) async {
    final cacheKey = MemoryCacheService.createKey(CacheKeys.homeSuggestions, {'limit': limit});
    
    // Kiểm tra cache trước
    if (!forceRefresh && _cache.has(cacheKey)) {
      final cachedData = _cache.get<List<Map<String, dynamic>>>(cacheKey);
      if (cachedData != null) {
        print('💡 Using cached home suggestions');
        return cachedData;
      }
    }

    try {
      print('🌐 Fetching home suggestions from API...');
      final suggestions = await _apiService.getProductSuggests(limit: limit);
      
      // Convert ProductSuggest to Map
      final suggestionsData = suggestions?.map((suggestion) => suggestion.toJson()).toList() ?? [];
      
      // Lưu vào cache
      _cache.set(cacheKey, suggestionsData, duration: cacheDuration ?? _defaultCacheDuration);
      
      print('✅ Home suggestions cached successfully');
      return suggestionsData;
    } catch (e) {
      print('❌ Error fetching home suggestions: $e');
      
      // Fallback về cache cũ nếu có
      final cachedData = _cache.get<List<Map<String, dynamic>>>(cacheKey);
      if (cachedData != null) {
        print('🔄 Using stale cache for home suggestions');
        return cachedData;
      }
      
      rethrow;
    }
  }


  /// Lấy danh sách sản phẩm theo danh mục với cache
  Future<List<Map<String, dynamic>>> getCategoryProducts(
    int categoryId, {
    int page = 1,
    int limit = 20,
    String sort = 'relevance',
    bool forceRefresh = false,
    Duration? cacheDuration,
  }) async {
    final cacheKey = MemoryCacheService.createKey(CacheKeys.categoryProducts, {
      'categoryId': categoryId,
      'page': page,
      'limit': limit,
      'sort': sort,
    });
    
    // Kiểm tra cache trước
    if (!forceRefresh && _cache.has(cacheKey)) {
      final cachedData = _cache.get<List<Map<String, dynamic>>>(cacheKey);
      if (cachedData != null) {
        print('📂 Using cached category products');
        return cachedData;
      }
    }

    try {
      print('🌐 Fetching category products from API...');
      // Note: Cần implement method getCategoryProducts trong ApiService
      // Tạm thời return empty list
      final products = <Map<String, dynamic>>[];
      
      // Lưu vào cache
      _cache.set(cacheKey, products, duration: cacheDuration ?? _defaultCacheDuration);
      
      print('✅ Category products cached successfully');
      return products;
    } catch (e) {
      print('❌ Error fetching category products: $e');
      
      // Fallback về cache cũ nếu có
      final cachedData = _cache.get<List<Map<String, dynamic>>>(cacheKey);
      if (cachedData != null) {
        print('🔄 Using stale cache for category products');
        return cachedData;
      }
      
      rethrow;
    }
  }

  /// Xóa cache theo pattern
  void clearCachePattern(String pattern) {
    final keysToRemove = <String>[];
    
    // Access private _cache through public method
    final cacheInfo = _cache.getCacheInfo();
    for (final key in cacheInfo['entries'].keys) {
      if (key.contains(pattern)) {
        keysToRemove.add(key);
      }
    }
    
    for (final key in keysToRemove) {
      _cache.remove(key);
    }
    
    print('🧹 Cleared cache pattern: $pattern (${keysToRemove.length} entries)');
  }

  /// Xóa tất cả cache
  void clearAllCache() {
    _cache.clear();
    print('🧹 Cleared all cache');
  }

  /// Lấy thông tin cache (để debug)
  Map<String, dynamic> getCacheInfo() {
    return _cache.getCacheInfo();
  }

  /// Lấy danh sách categories với cache
  Future<List<Map<String, dynamic>>> getCategoriesList({
    String type = 'parents',
    int? parentId,
    bool includeChildren = false,
    bool includeProductsCount = false,
    bool forceRefresh = false,
    Duration? cacheDuration,
  }) async {
    final cacheKey = MemoryCacheService.createKey(CacheKeys.categories, {
      'type': type,
      'parentId': parentId,
      'includeChildren': includeChildren,
      'includeProductsCount': includeProductsCount,
    });
    
    // Kiểm tra cache trước
    if (!forceRefresh && _cache.has(cacheKey)) {
      final cachedData = _cache.get<List<Map<String, dynamic>>>(cacheKey);
      if (cachedData != null) {
        print('📂 Using cached categories list');
        return cachedData;
      }
    }

    try {
      print('🌐 Fetching categories list from API...');
      final categories = await _apiService.getCategoriesList(
        type: type,
        parentId: parentId ?? 0,
        includeChildren: includeChildren,
        includeProductsCount: includeProductsCount,
      );
      
      // Convert to Map list - categories đã là List<Map<String, dynamic>>
      final categoriesData = categories ?? [];
      
      // Lưu vào cache với thời gian dài vì categories ít thay đổi
      _cache.set(cacheKey, categoriesData, duration: cacheDuration ?? _longCacheDuration);
      
      print('✅ Categories list cached successfully');
      return categoriesData;
    } catch (e) {
      print('❌ Error fetching categories list: $e');
      
      // Fallback về cache cũ nếu có
      final cachedData = _cache.get<List<Map<String, dynamic>>>(cacheKey);
      if (cachedData != null) {
        print('🔄 Using stale cache for categories list');
        return cachedData;
      }
      
      rethrow;
    }
  }

  /// Lấy sản phẩm theo danh mục với cache và pagination
  Future<Map<String, dynamic>?> getCategoryProductsWithPagination({
    required int categoryId,
    int page = 1,
    int limit = 50,
    String sort = 'relevance',
    bool forceRefresh = false,
    Duration? cacheDuration,
  }) async {
    final cacheKey = MemoryCacheService.createKey(CacheKeys.categoryProducts, {
      'categoryId': categoryId,
      'page': page,
      'limit': limit,
      'sort': sort,
    });
    
    // Kiểm tra cache trước
    if (!forceRefresh && _cache.has(cacheKey)) {
      final cachedData = _cache.get<Map<String, dynamic>>(cacheKey);
      if (cachedData != null) {
        print('📦 Using cached category products (page $page)');
        return cachedData;
      }
    }

    try {
      print('🌐 Fetching category products from API (page $page)...');
      final response = await _apiService.getProductsByCategory(
        categoryId: categoryId,
        page: page,
        limit: limit,
        sort: sort,
      );
      
      // Lưu vào cache
      _cache.set(cacheKey, response, duration: cacheDuration ?? _defaultCacheDuration);
      
      print('✅ Category products cached successfully (page $page)');
      return response;
    } catch (e) {
      print('❌ Error fetching category products: $e');
      
      // Fallback về cache cũ nếu có
      final cachedData = _cache.get<Map<String, dynamic>>(cacheKey);
      if (cachedData != null) {
        print('🔄 Using stale cache for category products (page $page)');
        return cachedData;
      }
      
      rethrow;
    }
  }

  /// Xóa cache của category cụ thể
  void clearCategoryCache(int categoryId) {
    clearCachePattern('category_products:{"categoryId":$categoryId');
    print('🧹 Cleared cache for category $categoryId');
  }

  /// Lấy affiliate dashboard với cache
  Future<Map<String, dynamic>?> getAffiliateDashboard({
    required int? userId,
    bool forceRefresh = false,
    Duration? cacheDuration,
  }) async {
    final cacheKey = MemoryCacheService.createKey(CacheKeys.affiliateDashboard, {
      'userId': userId,
    });
    
    // Kiểm tra cache trước
    if (!forceRefresh && _cache.has(cacheKey)) {
      final cachedData = _cache.get<Map<String, dynamic>>(cacheKey);
      if (cachedData != null) {
        print('💰 Using cached affiliate dashboard');
        return cachedData;
      }
    }

    try {
      print('🌐 Fetching affiliate dashboard from API...');
      final dashboard = await _affiliateService.getDashboard(userId: userId);
      
      if (dashboard != null) {
        // Convert AffiliateDashboard object to Map for caching
        final dashboardMap = {
          'success': true,
          'data': dashboard.toJson(),
        };
        
        // Lưu vào cache với thời gian ngắn vì dashboard thay đổi thường xuyên
        _cache.set(cacheKey, dashboardMap, duration: cacheDuration ?? _shortCacheDuration);
        print('✅ Affiliate dashboard cached successfully');
        return dashboardMap;
      }
      
      return null;
    } catch (e) {
      print('❌ Error fetching affiliate dashboard: $e');
      
      // Fallback về cache cũ nếu có
      final cachedData = _cache.get<Map<String, dynamic>>(cacheKey);
      if (cachedData != null) {
        print('🔄 Using stale cache for affiliate dashboard');
        return cachedData;
      }
      
      rethrow;
    }
  }

  /// Lấy affiliate links với cache và pagination
  Future<Map<String, dynamic>?> getAffiliateLinks({
    required int? userId,
    int page = 1,
    int limit = 50,
    String? search,
    String sortBy = 'newest',
    bool onlyHasLink = false,
    bool forceRefresh = false,
    Duration? cacheDuration,
  }) async {
    final cacheKey = MemoryCacheService.createKey(CacheKeys.affiliateLinks, {
      'userId': userId,
      'page': page,
      'limit': limit,
      'search': search,
      'sortBy': sortBy,
      'onlyHasLink': onlyHasLink,
    });
    
    // Kiểm tra cache trước
    if (!forceRefresh && _cache.has(cacheKey)) {
      final cachedData = _cache.get<Map<String, dynamic>>(cacheKey);
      if (cachedData != null) {
        print('🔗 Using cached affiliate links (page $page)');
        return cachedData;
      }
    }

    try {
      print('🌐 Fetching affiliate links from API (page $page)...');
      final result = await _affiliateService.getMyLinks(
        userId: userId,
        page: page,
        limit: limit,
        search: search,
        sortBy: sortBy,
        onlyHasLink: onlyHasLink,
      );
      
      if (result != null) {
        // Lưu vào cache
        _cache.set(cacheKey, result, duration: cacheDuration ?? _defaultCacheDuration);
        print('✅ Affiliate links cached successfully (page $page)');
      }
      
      return result;
    } catch (e) {
      print('❌ Error fetching affiliate links: $e');
      
      // Fallback về cache cũ nếu có
      final cachedData = _cache.get<Map<String, dynamic>>(cacheKey);
      if (cachedData != null) {
        print('🔄 Using stale cache for affiliate links (page $page)');
        return cachedData;
      }
      
      rethrow;
    }
  }

  /// Lấy affiliate products với cache và pagination
  Future<Map<String, dynamic>?> getAffiliateProducts({
    required int? userId,
    int page = 1,
    int limit = 50,
    String? search,
    String sortBy = 'newest',
    bool onlyFollowing = false,
    bool forceRefresh = false,
    Duration? cacheDuration,
  }) async {
    final cacheKey = MemoryCacheService.createKey(CacheKeys.affiliateProducts, {
      'userId': userId,
      'page': page,
      'limit': limit,
      'search': search,
      'sortBy': sortBy,
      'onlyFollowing': onlyFollowing,
    });
    
    // Kiểm tra cache trước
    if (!forceRefresh && _cache.has(cacheKey)) {
      final cachedData = _cache.get<Map<String, dynamic>>(cacheKey);
      if (cachedData != null) {
        print('📦 Using cached affiliate products (page $page)');
        return cachedData;
      }
    }

    try {
      print('🌐 Fetching affiliate products from API (page $page)...');
      print('🔍 Cache key: $cacheKey');
      print('🔍 Parameters: userId=$userId, page=$page, limit=$limit, search=$search, sortBy=$sortBy, onlyFollowing=$onlyFollowing');
      
      final result = await _affiliateService.getProducts(
        userId: userId,
        page: page,
        limit: limit,
        search: search,
        sortBy: sortBy,
        onlyFollowing: onlyFollowing,
      );
      
      print('🔍 API result: $result');
      print('🔍 API result type: ${result.runtimeType}');
      print('🔍 API result is null: ${result == null}');
      print('🔍 API result isEmpty: ${result?.isEmpty}');
      
      if (result != null) {
        print('🔍 Products in result: ${result['products']?.length ?? 0}');
        // Lưu vào cache
        _cache.set(cacheKey, result, duration: cacheDuration ?? _defaultCacheDuration);
        print('✅ Affiliate products cached successfully (page $page)');
      } else {
        print('❌ API returned null result');
      }
      
      return result;
    } catch (e) {
      print('❌ Error fetching affiliate products: $e');
      
      // Fallback về cache cũ nếu có
      final cachedData = _cache.get<Map<String, dynamic>>(cacheKey);
      if (cachedData != null) {
        print('🔄 Using stale cache for affiliate products (page $page)');
        return cachedData;
      }
      
      rethrow;
    }
  }

  /// Xóa cache của affiliate cụ thể
  void clearAffiliateCache(int userId) {
    clearCachePattern('affiliate_dashboard:{"userId":$userId');
    clearCachePattern('affiliate_links:{"userId":$userId');
    clearCachePattern('affiliate_products:{"userId":$userId');
    print('🧹 Cleared cache for affiliate user $userId');
  }

  /// Xóa tất cả cache của affiliate
  void clearAllAffiliateCache() {
    clearCachePattern('affiliate_dashboard');
    clearCachePattern('affiliate_links');
    clearCachePattern('affiliate_products');
    print('🧹 Cleared all affiliate cache');
  }

  /// Lấy chi tiết sản phẩm với cache
  Future<ProductDetail?> getProductDetailCached(
    int productId, {
    bool forceRefresh = false,
    Duration? cacheDuration,
  }) async {
    final cacheKey = MemoryCacheService.createKey(CacheKeys.productDetail, {'id': productId});
    
    // Kiểm tra cache trước
    if (!forceRefresh && _cache.has(cacheKey)) {
      final cachedProduct = _cache.get<ProductDetail>(cacheKey);
      if (cachedProduct != null) {
        print('📦 Using cached product detail for ID: $productId');
        return cachedProduct;
      }
    }

    try {
      print('🌐 Fetching product detail from API for ID: $productId...');
      final product = await _apiService.getProductDetail(productId);
      
      // Lưu trực tiếp ProductDetail object vào cache
      if (product != null) {
        _cache.set(cacheKey, product, duration: cacheDuration ?? _longCacheDuration);
        print('✅ Product detail cached successfully for ID: $productId');
      }
      
      return product;
    } catch (e) {
      print('❌ Error fetching product detail: $e');
      
      // Fallback về cache cũ nếu có
      final cachedProduct = _cache.get<ProductDetail>(cacheKey);
      if (cachedProduct != null) {
        print('🔄 Using stale cache for product detail ID: $productId');
        return cachedProduct;
      }
      
      rethrow;
    }
  }

  /// Lấy sản phẩm cùng gian hàng với cache
  Future<Map<String, dynamic>?> getSameShopProductsCached(
    int productId, {
    int limit = 10,
    bool forceRefresh = false,
    Duration? cacheDuration,
  }) async {
    final cacheKey = MemoryCacheService.createKey(CacheKeys.sameShopProducts, {
      'productId': productId,
      'limit': limit,
    });
    
    // Kiểm tra cache trước
    if (!forceRefresh && _cache.has(cacheKey)) {
      final cachedData = _cache.get<Map<String, dynamic>>(cacheKey);
      if (cachedData != null) {
        print('🏪 Using cached same shop products for product ID: $productId');
        return cachedData;
      }
    }

    try {
      print('🌐 Fetching same shop products from API for product ID: $productId...');
      final response = await _apiService.getProductsSameShop(
        productId: productId,
        limit: limit,
      );
      
      // Lưu vào cache
      _cache.set(cacheKey, response, duration: cacheDuration ?? _defaultCacheDuration);
      
      print('✅ Same shop products cached successfully for product ID: $productId');
      return response;
    } catch (e) {
      print('❌ Error fetching same shop products: $e');
      
      // Fallback về cache cũ nếu có
      final cachedData = _cache.get<Map<String, dynamic>>(cacheKey);
      if (cachedData != null) {
        print('🔄 Using stale cache for same shop products ID: $productId');
        return cachedData;
      }
      
      rethrow;
    }
  }

  /// Lấy sản phẩm liên quan với cache
  Future<List<Map<String, dynamic>>?> getRelatedProductsCached(
    int productId, {
    int limit = 8,
    String type = 'auto',
    bool forceRefresh = false,
    Duration? cacheDuration,
  }) async {
    final cacheKey = MemoryCacheService.createKey(CacheKeys.relatedProducts, {
      'productId': productId,
      'limit': limit,
      'type': type,
    });
    
    // Kiểm tra cache trước
    if (!forceRefresh && _cache.has(cacheKey)) {
      final cachedData = _cache.get<List<Map<String, dynamic>>>(cacheKey);
      if (cachedData != null) {
        print('🔗 Using cached related products for product ID: $productId');
        return cachedData;
      }
    }

    try {
      print('🌐 Fetching related products from API for product ID: $productId...');
      final relatedProducts = await _apiService.getRelatedProducts(
        productId: productId,
        limit: limit,
        type: type,
      );
      
      // Convert RelatedProduct to Map list
      final relatedProductsData = relatedProducts?.map((product) => product.toJson()).toList();
      
      // Lưu vào cache
      _cache.set(cacheKey, relatedProductsData, duration: cacheDuration ?? _defaultCacheDuration);
      
      print('✅ Related products cached successfully for product ID: $productId');
      return relatedProductsData;
    } catch (e) {
      print('❌ Error fetching related products: $e');
      
      // Fallback về cache cũ nếu có
      final cachedData = _cache.get<List<Map<String, dynamic>>>(cacheKey);
      if (cachedData != null) {
        print('🔄 Using stale cache for related products ID: $productId');
        return cachedData;
      }
      
      rethrow;
    }
  }

  /// Xóa cache của sản phẩm cụ thể
  void clearProductCache(int productId) {
    clearCachePattern('product_detail:{"id":$productId');
    clearCachePattern('same_shop_products:{"productId":$productId');
    clearCachePattern('related_products:{"productId":$productId');
    print('🧹 Cleared cache for product $productId');
  }

  /// Xóa tất cả cache của products
  void clearAllProductCache() {
    clearCachePattern(CacheKeys.productDetail);
    clearCachePattern(CacheKeys.sameShopProducts);
    clearCachePattern(CacheKeys.relatedProducts);
    print('🧹 Cleared all product cache');
  }

  /// Force refresh tất cả cache của home
  Future<void> refreshHomeCache() async {
    print('🔄 Force refreshing home cache...');
    
    try {
      await Future.wait([
        getHomeBanners(forceRefresh: true),
        getHomeFlashSale(forceRefresh: true),
        getHomePartnerBanners(forceRefresh: true),
        getHomeSuggestions(forceRefresh: true),
      ]);
      
      print('✅ Home cache refreshed successfully');
    } catch (e) {
      print('❌ Error refreshing home cache: $e');
    }
  }

  /// Lấy danh sách sản phẩm freeship với cache
  Future<List<Map<String, dynamic>>?> getFreeShipProductsCached({
    bool forceRefresh = false,
    Duration? cacheDuration,
  }) async {
    final cacheKey = CacheKeys.freeshipProducts;
    
    // Kiểm tra cache trước
    if (!forceRefresh && _cache.has(cacheKey)) {
      final cachedData = _cache.get<List<Map<String, dynamic>>>(cacheKey);
      if (cachedData != null) {
        print('🚚 Using cached freeship products');
        return cachedData;
      }
    }

    try {
      print('🌐 Fetching freeship products from API...');
      final products = await _apiService.getFreeShipProducts();
      
      // Convert FreeShipProduct list to Map list for caching
      final productsData = products?.map((product) => product.toJson()).toList();
      
      // Lưu vào cache với thời gian dài vì freeship products ít thay đổi
      _cache.set(cacheKey, productsData, duration: cacheDuration ?? _longCacheDuration);
      
      print('✅ Freeship products cached successfully');
      return productsData;
    } catch (e) {
      print('❌ Error fetching freeship products: $e');
      
      // Fallback về cache cũ nếu có
      final cachedData = _cache.get<List<Map<String, dynamic>>>(cacheKey);
      if (cachedData != null) {
        print('🔄 Using stale cache for freeship products');
        return cachedData;
      }
      
      rethrow;
    }
  }

  /// Xóa cache của freeship products
  void clearFreeshipCache() {
    _cache.remove(CacheKeys.freeshipProducts);
    print('🧹 Cleared freeship products cache');
  }

  /// Tìm kiếm sản phẩm với cache
  Future<Map<String, dynamic>?> searchProductsCached({
    required String keyword,
    int page = 1,
    int limit = 50,
    bool forceRefresh = false,
    Duration? cacheDuration,
  }) async {
    final cacheKey = MemoryCacheService.createKey(CacheKeys.searchProducts, {
      'keyword': keyword,
      'page': page,
      'limit': limit,
    });
    
    // Kiểm tra cache trước
    if (!forceRefresh && _cache.has(cacheKey)) {
      final cachedData = _cache.get<Map<String, dynamic>>(cacheKey);
      if (cachedData != null) {
        print('🔍 Using cached search results for keyword: "$keyword" (page $page)');
        return cachedData;
      }
    }

    try {
      print('🌐 Fetching search results from API for keyword: "$keyword" (page $page)...');
      final result = await _apiService.searchProducts(
        keyword: keyword,
        page: page,
        limit: limit,
      );
      
      // Lưu vào cache với thời gian ngắn vì search results thay đổi thường xuyên
      _cache.set(cacheKey, result, duration: cacheDuration ?? _shortCacheDuration);
      
      print('✅ Search results cached successfully for keyword: "$keyword" (page $page)');
      return result;
    } catch (e) {
      print('❌ Error fetching search results: $e');
      
      // Fallback về cache cũ nếu có
      final cachedData = _cache.get<Map<String, dynamic>>(cacheKey);
      if (cachedData != null) {
        print('🔄 Using stale cache for search keyword: "$keyword" (page $page)');
        return cachedData;
      }
      
      rethrow;
    }
  }

  /// Lấy gợi ý tìm kiếm với cache
  Future<List<String>?> getSearchSuggestionsCached({
    required String keyword,
    int limit = 5,
    bool forceRefresh = false,
    Duration? cacheDuration,
  }) async {
    final cacheKey = MemoryCacheService.createKey(CacheKeys.searchSuggestions, {
      'keyword': keyword,
      'limit': limit,
    });
    
    // Kiểm tra cache trước
    if (!forceRefresh && _cache.has(cacheKey)) {
      final cachedData = _cache.get<List<String>>(cacheKey);
      if (cachedData != null) {
        print('💡 Using cached search suggestions for keyword: "$keyword"');
        return cachedData;
      }
    }

    try {
      print('🌐 Fetching search suggestions from API for keyword: "$keyword"...');
      final suggestions = await _apiService.getSearchSuggestions(
        keyword: keyword,
        limit: limit,
      );
      
      // Lưu vào cache với thời gian ngắn vì suggestions thay đổi thường xuyên
      _cache.set(cacheKey, suggestions, duration: cacheDuration ?? _shortCacheDuration);
      
      print('✅ Search suggestions cached successfully for keyword: "$keyword"');
      return suggestions;
    } catch (e) {
      print('❌ Error fetching search suggestions: $e');
      
      // Fallback về cache cũ nếu có
      final cachedData = _cache.get<List<String>>(cacheKey);
      if (cachedData != null) {
        print('🔄 Using stale cache for search suggestions keyword: "$keyword"');
        return cachedData;
      }
      
      rethrow;
    }
  }

  /// Xóa cache của search cụ thể
  void clearSearchCache(String keyword) {
    clearCachePattern('search_products:{"keyword":"$keyword"');
    clearCachePattern('search_suggestions:{"keyword":"$keyword"');
    print('🧹 Cleared search cache for keyword: "$keyword"');
  }

  /// Xóa tất cả cache của search
  void clearAllSearchCache() {
    clearCachePattern(CacheKeys.searchProducts);
    clearCachePattern(CacheKeys.searchSuggestions);
    print('🧹 Cleared all search cache');
  }

  /// Lấy flash sale deals với cache
  Future<List<Map<String, dynamic>>?> getFlashSaleDealsCached({
    required String timeSlot,
    String status = 'active',
    int limit = 100,
    bool forceRefresh = false,
    Duration? cacheDuration,
  }) async {
    final cacheKey = MemoryCacheService.createKey(CacheKeys.flashSaleDeals, {
      'timeSlot': timeSlot,
      'status': status,
      'limit': limit,
    });
    
    // Kiểm tra cache trước
    if (!forceRefresh && _cache.has(cacheKey)) {
      final cachedData = _cache.get<List<Map<String, dynamic>>>(cacheKey);
      if (cachedData != null) {
        print('⚡ Using cached flash sale deals for timeSlot: $timeSlot');
        return cachedData;
      }
    }

    try {
      print('🌐 Fetching flash sale deals from API for timeSlot: $timeSlot...');
      final deals = await _apiService.getFlashSaleDeals(
        timeSlot: timeSlot,
        status: status,
        limit: limit,
      );
      
       // Convert FlashSaleDeal list to Map list for caching
       final dealsData = deals?.map((deal) => deal.toJson()).toList();
      
      // Lưu vào cache với thời gian ngắn vì flash sale thay đổi thường xuyên
      _cache.set(cacheKey, dealsData, duration: cacheDuration ?? _shortCacheDuration);
      
      print('✅ Flash sale deals cached successfully for timeSlot: $timeSlot');
      return dealsData;
    } catch (e) {
      print('❌ Error fetching flash sale deals: $e');
      
      // Fallback về cache cũ nếu có
      final cachedData = _cache.get<List<Map<String, dynamic>>>(cacheKey);
      if (cachedData != null) {
        print('🔄 Using stale cache for flash sale deals timeSlot: $timeSlot');
        return cachedData;
      }
      
      rethrow;
    }
  }

  /// Xóa cache của flash sale cụ thể
  void clearFlashSaleCache(String timeSlot) {
    clearCachePattern('flash_sale_deals:{"timeSlot":"$timeSlot"');
    print('🧹 Cleared flash sale cache for timeSlot: $timeSlot');
  }

  /// Xóa tất cả cache của flash sale
  void clearAllFlashSaleCache() {
    clearCachePattern(CacheKeys.flashSaleDeals);
    print('🧹 Cleared all flash sale cache');
  }

  /// Lấy platform vouchers với cache
  Future<List<Voucher>?> getPlatformVouchersCached({
    int page = 1,
    int limit = 20,
    bool forceRefresh = false,
    Duration? cacheDuration,
  }) async {
    final cacheKey = MemoryCacheService.createKey(CacheKeys.platformVouchers, {
      'page': page,
      'limit': limit,
    });
    
    // Kiểm tra cache trước
    if (!forceRefresh && _cache.has(cacheKey)) {
      final cachedVouchers = _cache.get<List<Voucher>>(cacheKey);
      if (cachedVouchers != null) {
        print('🎫 Using cached platform vouchers for page: $page');
        return cachedVouchers;
      }
    }

    try {
      print('🌐 Fetching platform vouchers from API for page: $page...');
      final vouchers = await _apiService.getVouchers(
        type: 'platform',
        page: page,
        limit: limit,
      );
      
      // Lưu vào cache với thời gian ngắn vì voucher thay đổi thường xuyên
      if (vouchers != null) {
        _cache.set(cacheKey, vouchers, duration: cacheDuration ?? _shortCacheDuration);
        print('✅ Platform vouchers cached successfully for page: $page');
      }
      
      return vouchers;
    } catch (e) {
      print('❌ Error fetching platform vouchers: $e');
      
      // Fallback về cache cũ nếu có
      final cachedVouchers = _cache.get<List<Voucher>>(cacheKey);
      if (cachedVouchers != null) {
        print('🔄 Using stale cache for platform vouchers page: $page');
        return cachedVouchers;
      }
      
      rethrow;
    }
  }

  /// Lấy shop vouchers với cache
  Future<List<Voucher>?> getShopVouchersCached({
    String? shopId,
    int page = 1,
    int limit = 20,
    bool forceRefresh = false,
    Duration? cacheDuration,
  }) async {
    final cacheKey = MemoryCacheService.createKey('shop_vouchers', {
      'shopId': shopId,
      'page': page,
      'limit': limit,
    });
    
    // Kiểm tra cache trước
    if (!forceRefresh && _cache.has(cacheKey)) {
      final cachedVouchers = _cache.get<List<Voucher>>(cacheKey);
      if (cachedVouchers != null) {
        print('🏪 Using cached shop vouchers for shopId: $shopId, page: $page');
        return cachedVouchers;
      }
    }

    try {
      print('🌐 Fetching shop vouchers from API for shopId: $shopId, page: $page...');
      final vouchers = await _apiService.getVouchers(
        type: 'shop',
        shopId: shopId != null ? int.tryParse(shopId) : null,
        page: page,
        limit: limit,
      );
      
      // Lưu vào cache với thời gian ngắn vì voucher thay đổi thường xuyên
      if (vouchers != null) {
        _cache.set(cacheKey, vouchers, duration: cacheDuration ?? _shortCacheDuration);
        print('✅ Shop vouchers cached successfully for shopId: $shopId, page: $page');
      }
      
      return vouchers;
    } catch (e) {
      print('❌ Error fetching shop vouchers: $e');
      
      // Fallback về cache cũ nếu có
      final cachedVouchers = _cache.get<List<Voucher>>(cacheKey);
      if (cachedVouchers != null) {
        print('🔄 Using stale cache for shop vouchers shopId: $shopId, page: $page');
        return cachedVouchers;
      }
      
      rethrow;
    }
  }

  /// Lấy danh sách shops cho voucher với cache
  Future<List<Map<String, dynamic>>?> getVoucherShopsCached({
    bool forceRefresh = false,
    Duration? cacheDuration,
  }) async {
    final cacheKey = CacheKeys.voucherShops;
    
    // Kiểm tra cache trước
    if (!forceRefresh && _cache.has(cacheKey)) {
      final cachedShops = _cache.get<List<Map<String, dynamic>>>(cacheKey);
      if (cachedShops != null) {
        print('🏪 Using cached voucher shops');
        return cachedShops;
      }
    }

    try {
      print('🌐 Fetching voucher shops from API...');
      final shops = await _apiService.getShopsWithVouchers();
      
      // Lưu vào cache với thời gian dài vì danh sách shop ít thay đổi
      if (shops != null) {
        _cache.set(cacheKey, shops, duration: cacheDuration ?? _longCacheDuration);
        print('✅ Voucher shops cached successfully');
      }
      
      return shops;
    } catch (e) {
      print('❌ Error fetching voucher shops: $e');
      
      // Fallback về cache cũ nếu có
      final cachedShops = _cache.get<List<Map<String, dynamic>>>(cacheKey);
      if (cachedShops != null) {
        print('🔄 Using stale cache for voucher shops');
        return cachedShops;
      }
      
      rethrow;
    }
  }

  /// Xóa cache của platform vouchers cụ thể
  void clearPlatformVoucherCache(int page) {
    clearCachePattern('platform_vouchers:{"page":$page"');
    print('🧹 Cleared platform voucher cache for page: $page');
  }

  /// Xóa tất cả cache của platform vouchers
  void clearAllPlatformVoucherCache() {
    clearCachePattern(CacheKeys.platformVouchers);
    print('🧹 Cleared all platform voucher cache');
  }

  /// Xóa cache của shop vouchers cụ thể
  void clearShopVoucherCache(String? shopId, int page) {
    clearCachePattern('shop_vouchers:{"shopId":"$shopId","page":$page"');
    print('🧹 Cleared shop voucher cache for shopId: $shopId, page: $page');
  }

  /// Xóa tất cả cache của shop vouchers
  void clearAllShopVoucherCache() {
    clearCachePattern('shop_vouchers');
    print('🧹 Cleared all shop voucher cache');
  }

  /// Xóa cache của voucher shops
  void clearVoucherShopsCache() {
    _cache.remove(CacheKeys.voucherShops);
    print('🧹 Cleared voucher shops cache');
  }

  /// Xóa tất cả cache của voucher
  void clearAllVoucherCache() {
    clearCachePattern(CacheKeys.platformVouchers);
    clearCachePattern('shop_vouchers');
    _cache.remove(CacheKeys.voucherShops);
    print('🧹 Cleared all voucher cache');
  }
}
