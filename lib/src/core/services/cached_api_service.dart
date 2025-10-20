import 'dart:async';
import 'api_service.dart';
import 'memory_cache_service.dart';

/// Enhanced API Service với Memory Cache
/// Tự động cache dữ liệu API để giảm số lần gọi và cải thiện performance
class CachedApiService {
  static final CachedApiService _instance = CachedApiService._internal();
  factory CachedApiService() => _instance;
  CachedApiService._internal();

  final ApiService _apiService = ApiService();
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

  /// Lấy flash sale cho trang chủ với cache
  Future<List<Map<String, dynamic>>> getHomeFlashSale({
    bool forceRefresh = false,
    Duration? cacheDuration,
  }) async {
    const cacheKey = CacheKeys.homeFlashSale;
    
    // Kiểm tra cache trước
    if (!forceRefresh && _cache.has(cacheKey)) {
      final cachedData = _cache.get<List<Map<String, dynamic>>>(cacheKey);
      if (cachedData != null) {
        print('⚡ Using cached home flash sale');
        return cachedData;
      }
    }

    try {
      print('🌐 Fetching home flash sale from API...');
      final flashSaleDeals = await _apiService.getFlashSaleDeals(
        timeSlot: '09:00', // Default time slot
        status: 'active',
        limit: 10,
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

  /// Lấy chi tiết sản phẩm với cache
  Future<Map<String, dynamic>?> getProductDetail(
    int productId, {
    bool forceRefresh = false,
    Duration? cacheDuration,
  }) async {
    final cacheKey = MemoryCacheService.createKey(CacheKeys.productDetail, {'id': productId});
    
    // Kiểm tra cache trước
    if (!forceRefresh && _cache.has(cacheKey)) {
      final cachedData = _cache.get<Map<String, dynamic>>(cacheKey);
      if (cachedData != null) {
        print('📦 Using cached product detail');
        return cachedData;
      }
    }

    try {
      print('🌐 Fetching product detail from API...');
      final product = await _apiService.getProductDetail(productId);
      
      // Convert ProductDetail to Map
      final productData = product?.toJson();
      
      // Lưu vào cache
      _cache.set(cacheKey, productData, duration: cacheDuration ?? _defaultCacheDuration);
      
      print('✅ Product detail cached successfully');
      return productData;
    } catch (e) {
      print('❌ Error fetching product detail: $e');
      
      // Fallback về cache cũ nếu có
      final cachedData = _cache.get<Map<String, dynamic>>(cacheKey);
      if (cachedData != null) {
        print('🔄 Using stale cache for product detail');
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
}
