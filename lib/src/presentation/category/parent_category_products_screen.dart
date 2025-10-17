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
    _loadProducts();
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

        // Map API fields to UI expected fields
        final products = rawProducts.map((product) {
          final mappedProduct = {
            'id': product['id'],
            'name': product['tieu_de'] ?? 'Sản phẩm',
            'image': product['minh_hoa'] ?? '',
            'price': product['gia_moi'] ?? 0,
            'old_price': product['gia_cu'] ?? 0,
            'discount_percent': product['discount_percent'] ?? 0,
            'rating': 5.0, // Default rating
            'sold': product['ban'] ?? 0,
            'view': product['view'] ?? 0,
            'shop_id': product['shop'] ?? '',
            'shop_name': 'Shop', // Default shop name
            'is_freeship': product['isFreeship'] ?? false,
            'hasVoucher': product['hasVoucher'] ?? false,
            'badges': product['badges'] ?? [],
            'link': product['link'] ?? '',
            'date_post': product['date_post'] ?? '',
            'kho': product['kho'] ?? 0,
            'thuong_hieu': product['thuong_hieu'] ?? '',
            'noi_ban': product['noi_ban'] ?? '',
            'cat': product['cat'] ?? '',
            'status': product['status'] ?? 1,
          };
          return mappedProduct;
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
          
          _hasNextPage = pagination['has_next'] ?? false;
          _totalProducts = pagination['total_products'] ?? 0;
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

  Future<void> _loadMoreProducts() async {
    if (!_isLoadingMore && _hasNextPage) {
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
            return {
              'id': product['id'],
              'name': product['tieu_de'] ?? 'Sản phẩm',
              'image': product['minh_hoa'] ?? '',
              'price': product['gia_moi'] ?? 0,
              'old_price': product['gia_cu'] ?? 0,
              'discount_percent': product['discount_percent'] ?? 0,
              'rating': 5.0,
              'sold': product['ban'] ?? 0,
              'view': product['view'] ?? 0,
              'shop_id': product['shop'] ?? '',
              'shop_name': 'Shop',
              'is_freeship': product['isFreeship'] ?? false,
              'hasVoucher': product['hasVoucher'] ?? false,
              'badges': product['badges'] ?? [],
              'link': product['link'] ?? '',
              'date_post': product['date_post'] ?? '',
              'kho': product['kho'] ?? 0,
              'thuong_hieu': product['thuong_hieu'] ?? '',
              'noi_ban': product['noi_ban'] ?? '',
              'cat': product['cat'] ?? '',
              'status': product['status'] ?? 1,
            };
          }).toList();
          
          setState(() {
            _products.addAll(products);
            _currentPage++;
            _loadedCategories.addAll(includedCategories);
            _hasNextPage = pagination['has_next'] ?? false;
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
                                  'Tìm thấy $_totalProducts sản phẩm',
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
                                padding: const EdgeInsets.all(16),
                                itemCount: _products.length + (_hasNextPage ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index == _products.length) {
                                    // Load more button
                                    return Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Center(
                                        child: _isLoadingMore
                                            ? const CircularProgressIndicator()
                                            : ElevatedButton(
                                                onPressed: _loadMoreProducts,
                                                child: const Text('Tải thêm sản phẩm'),
                                              ),
                                      ),
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
