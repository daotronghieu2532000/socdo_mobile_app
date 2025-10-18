import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../cart/cart_screen.dart';
import 'widgets/category_product_card_horizontal.dart';

class ParentCategoryProductsScreen extends StatefulWidget {
  final int parentCategoryId;
  final String parentCategoryName;

  const ParentCategoryProductsScreen({
    super.key,
    required this.parentCategoryId,
    required this.parentCategoryName,
  });

  @override
  State<ParentCategoryProductsScreen> createState() => _ParentCategoryProductsScreenState();
}

class _ParentCategoryProductsScreenState extends State<ParentCategoryProductsScreen> {
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();
  
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  int _currentPage = 1;
  bool _hasNextPage = false;
  bool _isLoadingMore = false;
  int _totalProducts = 0;
  List<int> _loadedCategories = []; // Track which categories we've loaded
  String _currentSort = 'newest'; // newest | price_asc | price_desc | popular

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadProducts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Infinite scroll logic
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  // Helper method để parse int an toàn từ String hoặc int
  int _safeParseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  // Helper method để parse double an toàn từ String hoặc num
  double _safeParseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  // Helper method để parse bool an toàn
  bool _safeParseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    if (value is int) return value == 1;
    return false;
  }

  Future<void> _loadProducts({bool loadMore = false}) async {
    if (!loadMore) {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _currentPage = 1;
      });
    }

    try {
      final response = await _apiService.getProductsByParentCategory(
        parentCategoryId: widget.parentCategoryId,
        page: loadMore ? _currentPage + 1 : 1,
        limit: 50, // Tăng từ 10 lên 50
        sort: _currentSort,
      );

      if (response != null && mounted) {
        final data = response['data'];
        final rawProducts = List<Map<String, dynamic>>.from(data['products'] ?? []);
        final pagination = data['pagination'] ?? {};
        
        // Debug log để kiểm tra API response
        print('🔍 Parent Category Products API Response:');
        print('📊 Raw products count: ${rawProducts.length}');
        if (rawProducts.isNotEmpty) {
          print('📊 First product sample: ${rawProducts.first}');
        }
        print('📊 Pagination: $pagination');

        // Map API fields to UI expected fields
        final products = rawProducts.map((product) {
          try {
            final mappedProduct = {
              'id': _safeParseInt(product['id']),
              'name': product['tieu_de']?.toString() ?? 'Sản phẩm',
              'image': product['minh_hoa']?.toString() ?? '',
              'price': _safeParseInt(product['gia_moi']),
              'old_price': _safeParseInt(product['gia_cu']),
              'discount_percent': _safeParseInt(product['discount_percent']),
              'rating': 5.0, // Default rating
              'sold': _safeParseInt(product['ban']),
              'view': _safeParseInt(product['view']),
              'shop_id': product['shop']?.toString() ?? '',
              'shop_name': product['shop_name']?.toString() ?? 'Shop',
              'is_freeship': _safeParseBool(product['isFreeship']),
              'hasVoucher': _safeParseBool(product['hasVoucher']),
              'badges': product['badges'] ?? [],
              'voucher_icon': product['voucher_icon']?.toString(),
              'freeship_icon': product['freeship_icon']?.toString(),
              'chinhhang_icon': product['chinhhang_icon']?.toString(),
              'warehouse_name': product['warehouse_name']?.toString(),
              'province_name': product['province_name']?.toString(),
              'link': product['link']?.toString() ?? '',
              'date_post': product['date_post']?.toString() ?? '',
              'kho': _safeParseInt(product['kho']),
              'thuong_hieu': product['thuong_hieu']?.toString() ?? '',
              'noi_ban': product['noi_ban']?.toString() ?? '',
              'cat': product['cat']?.toString() ?? '',
              'status': product['status'] != null ? _safeParseInt(product['status']) : 1,
            };
            return mappedProduct;
          } catch (e) {
            print('❌ Error mapping product: $e');
            print('❌ Product data: $product');
            rethrow;
          }
        }).toList();

        // Get included categories for tracking
        final includedCategories = List<int>.from(data['filters']['included_categories'] ?? []);
        
        setState(() {
          if (loadMore) {
            _products.addAll(products);
            _currentPage++;
            _loadedCategories.addAll(includedCategories);
          } else {
            _products = products;
            _currentPage = 1;
            _loadedCategories = includedCategories;
          }
          
          _hasNextPage = _safeParseBool(pagination['has_next']) ?? false;
          _totalProducts = _safeParseInt(pagination['total_products']) ?? _safeParseInt(pagination['total']) ?? 0;
          _isLoading = false;
          _isLoadingMore = false;
          _hasError = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Không thể tải dữ liệu';
        });
      }
    } catch (e) {
      print('❌ Lỗi khi tải sản phẩm: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Có lỗi xảy ra khi tải dữ liệu';
      });
    }
  }

  void _onSortChanged(String sort) {
    if (sort != _currentSort) {
      setState(() {
        _currentSort = sort;
      });
      _loadProducts();
    }
  }

  Future<void> _onRefresh() async {
    await _loadProducts();
  }

  void _loadMore() {
    if (!_isLoadingMore && _hasNextPage) {
      _loadMoreProducts();
    }
  }

  Future<void> _loadMoreProducts() async {
    setState(() {
      _isLoadingMore = true;
    });
      
    try {
      // Use the new smart loading method
      final response = await _apiService.loadMoreProductsFromParentCategory(
        parentCategoryId: widget.parentCategoryId,
        alreadyLoadedCategories: _loadedCategories,
        page: _currentPage + 1,
        limit: 50, // Tăng từ 10 lên 50
        sort: _currentSort,
      );
      
      if (response != null && mounted) {
        final data = response['data'];
        final rawProducts = List<Map<String, dynamic>>.from(data['products'] ?? []);
        final pagination = data['pagination'] ?? {};
        final includedCategories = List<int>.from(data['filters']['included_categories'] ?? []);
        
        // Map API fields to UI expected fields
        final products = rawProducts.map((product) {
          try {
            return {
              'id': _safeParseInt(product['id']),
              'name': product['tieu_de']?.toString() ?? 'Sản phẩm',
              'image': product['minh_hoa']?.toString() ?? '',
              'price': _safeParseInt(product['gia_moi']),
              'old_price': _safeParseInt(product['gia_cu']),
              'discount_percent': _safeParseInt(product['discount_percent']),
              'rating': 5.0,
              'sold': _safeParseInt(product['ban']),
              'view': _safeParseInt(product['view']),
              'shop_id': product['shop']?.toString() ?? '',
              'shop_name': product['shop_name']?.toString() ?? 'Shop',
              'is_freeship': _safeParseBool(product['isFreeship']),
              'hasVoucher': _safeParseBool(product['hasVoucher']),
              'badges': product['badges'] ?? [],
              'voucher_icon': product['voucher_icon']?.toString(),
              'freeship_icon': product['freeship_icon']?.toString(),
              'chinhhang_icon': product['chinhhang_icon']?.toString(),
              'warehouse_name': product['warehouse_name']?.toString(),
              'province_name': product['province_name']?.toString(),
              'link': product['link']?.toString() ?? '',
              'date_post': product['date_post']?.toString() ?? '',
              'kho': _safeParseInt(product['kho']),
              'thuong_hieu': product['thuong_hieu']?.toString() ?? '',
              'noi_ban': product['noi_ban']?.toString() ?? '',
              'cat': product['cat']?.toString() ?? '',
              'status': product['status'] != null ? _safeParseInt(product['status']) : 1,
            };
          } catch (e) {
            print('❌ Error mapping product in loadMore: $e');
            print('❌ Product data: $product');
            rethrow;
          }
        }).toList();
        
        setState(() {
          _products.addAll(products);
          _currentPage++;
          _loadedCategories.addAll(includedCategories);
          _hasNextPage = _safeParseBool(pagination['has_next']) ?? false;
          _isLoadingMore = false;
        });
      } else {
        setState(() {
          _isLoadingMore = false;
          _hasNextPage = false;
        });
      }
    } catch (e) {
      print('❌ Lỗi khi load thêm sản phẩm: $e');
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.parentCategoryName),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CartScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _onRefresh,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: Column(
                    children: [
                      // Product count and filter bar
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Product count
                            Row(
                              children: [
                                Text(
                                  'Tìm thấy ${_totalProducts > 0 ? _totalProducts : _products.length} sản phẩm',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Sort options
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButton<String>(
                                    value: _currentSort,
                                    isExpanded: true,
                                    underline: const SizedBox(),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'newest',
                                        child: Text('Mới nhất'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'price_asc',
                                        child: Text('Giá thấp đến cao'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'price_desc',
                                        child: Text('Giá cao đến thấp'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'popular',
                                        child: Text('Phổ biến'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      if (value != null) {
                                        _onSortChanged(value);
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                IconButton(
                                  icon: const Icon(Icons.filter_list),
                                  onPressed: () {
                                    // TODO: Implement filter dialog
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Products list
                      Expanded(
                        child: _products.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.inventory_2_outlined,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Không có sản phẩm nào',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                controller: _scrollController,
                                padding: const EdgeInsets.all(16),
                                itemCount: _products.length + (_isLoadingMore ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index == _products.length) {
                                    // Loading indicator for infinite scroll
                                    return const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 16),
                                      child: Center(child: CircularProgressIndicator()),
                                    );
                                  }
                                  
                                  final productData = _products[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: CategoryProductCardHorizontal(
                                      product: productData,
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
    );
  }
}