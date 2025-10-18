import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../core/models/product_detail.dart';
import '../product/widgets/variant_selection_dialog.dart';
import '../product/product_detail_screen.dart';
import '../product/widgets/simple_purchase_dialog.dart';
import '../../core/services/cart_service.dart' as cart_service;
import '../checkout/checkout_screen.dart';
import 'widgets/category_product_card_horizontal.dart';

class CategoryProductsScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const CategoryProductsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  final ApiService _apiService = ApiService();
  final cart_service.CartService _cartService = cart_service.CartService();
  final ScrollController _scrollController = ScrollController();
  
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  int _currentPage = 1;
  bool _hasNextPage = false;
  bool _isLoadingMore = false;
  int _totalProducts = 0;
  String _currentSort = 'relevance'; // relevance | price-asc | price-desc | rating-desc | sold-desc
  bool _onlyFreeship = false;
  bool _onlyInStock = false;
  bool _onlyHasVoucher = false;

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
    } else {
      setState(() {
        _isLoadingMore = true;
      });
    }

    try {
      final response = await _apiService.getProductsByCategory(
        categoryId: widget.categoryId,
        page: loadMore ? _currentPage + 1 : 1,
        limit: 50, // Tăng từ 20 lên 50
        sort: _currentSort,
      );

      if (response != null && mounted) {
        final data = response['data'];
        final rawProducts = List<Map<String, dynamic>>.from(data['products'] ?? []);
        final pagination = data['pagination'] ?? {};
        
        // Debug log để kiểm tra API response
        print('🔍 Category Products API Response:');
        print('📊 Raw products count: ${rawProducts.length}');
        if (rawProducts.isNotEmpty) {
          print('📊 First product sample: ${rawProducts.first}');
        }
        print('📊 Pagination: $pagination');
        
        // Lưu total products từ pagination
        _totalProducts = _safeParseInt(pagination['total_products']) ?? _safeParseInt(pagination['total']) ?? 0;

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
            print('🔍 Mapped product: ${mappedProduct['name']} - Price: ${mappedProduct['price']} - Image: ${mappedProduct['image']}');
            return mappedProduct;
          } catch (e) {
            print('❌ Error mapping product: $e');
            print('❌ Product data: $product');
            rethrow;
          }
        }).toList();

        setState(() {
          if (loadMore) {
            _products.addAll(products);
            _currentPage++;
          } else {
            _products = products;
            _currentPage = 1;
          }
          
          _hasNextPage = _safeParseBool(pagination['has_next']) ?? false;
          _isLoading = false;
          _isLoadingMore = false;
          _hasError = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
          _hasError = true;
          _errorMessage = 'Không thể tải dữ liệu';
        });
      }
    } catch (e) {
      print('❌ Lỗi khi tải sản phẩm: $e');
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
        _hasError = true;
        _errorMessage = 'Có lỗi xảy ra: $e';
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

  void _loadMore() {
    if (!_isLoadingMore && _hasNextPage) {
      _loadProducts(loadMore: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        actions: [
          IconButton(icon: const Icon(Icons.tune), onPressed: _showFilters),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadProducts(),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_products.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Không có sản phẩm nào',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Hiển thị số lượng sản phẩm
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                'Tìm thấy ${_totalProducts > 0 ? _totalProducts : _products.length} sản phẩm',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        _buildInlineFilters(),
        // Danh sách sản phẩm với infinite scroll
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _filteredSorted().length + (_isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              // Hiển thị loading indicator ở cuối danh sách khi đang load more
              if (index == _filteredSorted().length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              
              final product = _filteredSorted()[index];
              return CategoryProductCardHorizontal(product: product);
            },
          ),
        ),
      ],
    );
  }


  void _openDetail(int id, String name, String image, int price, {Map<String, dynamic>? rawProduct}) {
    final shop = _extractShop(rawProduct);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(
          productId: id,
          title: name,
          image: image,
          price: price,
          initialShopId: int.tryParse(shop.item1 ?? ''),
          initialShopName: shop.item2,
        ),
      ),
    );
  }

  void _showPurchaseDialog(BuildContext context, int productId, String name, String image, {Map<String, dynamic>? rawProduct}) async {
    final detail = await _apiService.getProductDetail(productId);
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        if (detail != null && detail.variants.isNotEmpty) {
          return VariantSelectionDialog(
            product: detail,
            selectedVariant: detail.variants.first,
            onBuyNow: (v, q) {
              Navigator.pop(ctx);
              Future.delayed(const Duration(milliseconds: 150), () {
                _handleBuyNow(detail, v, q, fallback: rawProduct);
              });
            },
            onAddToCart: (v, q) { _handleAddToCart(detail, v, q, fallback: rawProduct); Navigator.pop(ctx); },
          );
        } else if (detail != null) {
          return SimplePurchaseDialog(
            product: detail,
            onBuyNow: (p, q) {
              Navigator.pop(ctx);
              Future.delayed(const Duration(milliseconds: 150), () {
                _handleBuyNowSimple(p, q, fallback: rawProduct);
              });
            },
            onAddToCart: (p, q) { _handleAddToCartSimple(p, q, fallback: rawProduct); Navigator.pop(ctx); },
          );
        }
        return const SizedBox(height: 200, child: Center(child: Text('Không thể tải thông tin sản phẩm')));
      },
    );
  }

  /// Trả về cặp (shopId, shopName) từ bản ghi API
  ({String? item1, String? item2}) _extractShop(Map<String, dynamic>? p) {
    final id = p?['shop_id']?.toString() ?? p?['shop']?.toString() ?? p?['user_id']?.toString();
    final name = p?['shop_name']?.toString() ?? p?['ten_shop']?.toString();
    return (item1: id, item2: name);
  }

  /// Ưu tiên lấy shop từ ProductDetail; nếu thiếu dùng fallback từ bản ghi danh mục
  ({String id, String name}) _resolveShop(ProductDetail d, {Map<String, dynamic>? fb}) {
    String? id = d.shopId ?? d.shopInfo?['user_id']?.toString();
    String? name = d.shopNameFromInfo.isNotEmpty ? d.shopNameFromInfo : (d.shopName ?? d.shopInfo?['name']?.toString());
    final f = _extractShop(fb);
    id ??= f.item1;
    name ??= f.item2;
    id ??= '0';
    name ??= 'Sóc Đỏ';
    // Debug
    // ignore: avoid_print
    print('🛍️ resolveShop → id=$id, name=$name (detail.shopId=${d.shopId}, d.shopName=${d.shopName}, fromInfo=${d.shopNameFromInfo}, fb=${f.item1}/${f.item2})');
    return (id: id, name: name);
  }

  void _handleBuyNow(ProductDetail product, ProductVariant variant, int quantity, {Map<String, dynamic>? fallback}) {
    final shop = _resolveShop(product, fb: fallback);
    final item = cart_service.CartItem(
      id: product.id,
      name: '${product.name} - ${variant.name}',
      image: product.imageUrl,
      price: variant.price,
      oldPrice: variant.oldPrice,
      quantity: quantity,
      variant: variant.name,
      shopId: int.tryParse(shop.id) ?? 0,
      shopName: shop.name,
      addedAt: DateTime.now(),
      isSelected: true,
    );
    _cartService.addItem(item);
    Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen()));
  }

  void _handleAddToCart(ProductDetail product, ProductVariant variant, int quantity, {Map<String, dynamic>? fallback}) {
    final shop = _resolveShop(product, fb: fallback);
    final item = cart_service.CartItem(
      id: product.id,
      name: '${product.name} - ${variant.name}',
      image: product.imageUrl,
      price: variant.price,
      oldPrice: variant.oldPrice,
      quantity: quantity,
      variant: variant.name,
      shopId: int.tryParse(shop.id) ?? 0,
      shopName: shop.name,
      addedAt: DateTime.now(),
    );
    _cartService.addItem(item);
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.showSnackBar(SnackBar(content: Text('Đã thêm ${product.name} (${variant.name}) x$quantity vào giỏ hàng'), backgroundColor: Colors.green));
  }

  void _handleBuyNowSimple(ProductDetail product, int quantity, {Map<String, dynamic>? fallback}) {
    final shop = _resolveShop(product, fb: fallback);
    final item = cart_service.CartItem(
      id: product.id,
      name: product.name,
      image: product.imageUrl,
      price: product.price,
      oldPrice: product.oldPrice,
      quantity: quantity,
      shopId: int.tryParse(shop.id) ?? 0,
      shopName: shop.name,
      addedAt: DateTime.now(),
      isSelected: true,
    );
    _cartService.addItem(item);
    Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen()));
  }

  void _handleAddToCartSimple(ProductDetail product, int quantity, {Map<String, dynamic>? fallback}) {
    final shop = _resolveShop(product, fb: fallback);
    final item = cart_service.CartItem(
      id: product.id,
      name: product.name,
      image: product.imageUrl,
      price: product.price,
      oldPrice: product.oldPrice,
      quantity: quantity,
      shopId: int.tryParse(shop.id) ?? 0,
      shopName: shop.name,
      addedAt: DateTime.now(),
    );
    _cartService.addItem(item);
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.showSnackBar(SnackBar(content: Text('Đã thêm ${product.name} x$quantity vào giỏ hàng'), backgroundColor: Colors.green));
  }

  // Inline filter chips similar to search
  Widget _buildInlineFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          ChoiceChip(label: const Text('Phù hợp'), selected: _currentSort == 'relevance', onSelected: (_) => _onSortChanged('relevance')),
          const SizedBox(width: 8),
          ChoiceChip(label: const Text('Giá ↑'), selected: _currentSort == 'price-asc', onSelected: (_) => _onSortChanged('price-asc')),
          const SizedBox(width: 8),
          ChoiceChip(label: const Text('Giá ↓'), selected: _currentSort == 'price-desc', onSelected: (_) => _onSortChanged('price-desc')),
          const SizedBox(width: 8),
          ChoiceChip(label: const Text('Đánh giá'), selected: _currentSort == 'rating-desc', onSelected: (_) => _onSortChanged('rating-desc')),
          const SizedBox(width: 8),
          ChoiceChip(label: const Text('Đã bán'), selected: _currentSort == 'sold-desc', onSelected: (_) => _onSortChanged('sold-desc')),
          const SizedBox(width: 8),
          FilterChip(selected: _onlyFreeship, label: const Text('Freeship'), onSelected: (v) => setState(() => _onlyFreeship = v)),
          const SizedBox(width: 8),
          FilterChip(selected: _onlyInStock, label: const Text('Còn hàng'), onSelected: (v) => setState(() => _onlyInStock = v)),
          const SizedBox(width: 8),
          FilterChip(selected: _onlyHasVoucher, label: const Text('Có voucher'), onSelected: (v) => setState(() => _onlyHasVoucher = v)),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _filteredSorted() {
    List<Map<String, dynamic>> items = List<Map<String, dynamic>>.from(_products);
    if (_onlyFreeship) {
      items = items.where((p) => (p['is_freeship'] == true) || (p['free_shipping'] == true)).toList();
    }
    if (_onlyInStock) {
      items = items.where((p) {
        final s = p['kho'] ?? p['stock'] ?? p['so_luong'];
        if (s is int) return s > 0;
        final si = int.tryParse('$s');
        return si == null ? true : si > 0;
      }).toList();
    }
    if (_onlyHasVoucher) {
      items = items.where((p) => p['has_coupon'] == true || p['coupon'] != null || p['coupon_info'] != null).toList();
    }
    switch (_currentSort) {
      case 'price-asc':
        items.sort((a, b) => (a['gia_moi'] ?? 0).compareTo(b['gia_moi'] ?? 0));
        break;
      case 'price-desc':
        items.sort((a, b) => (b['gia_moi'] ?? 0).compareTo(a['gia_moi'] ?? 0));
        break;
      case 'rating-desc':
        items.sort((a, b) => ((b['rating'] ?? 0) as num).compareTo((a['rating'] ?? 0) as num));
        break;
      case 'sold-desc':
        items.sort((a, b) => ((b['ban'] ?? 0) as num).compareTo((a['ban'] ?? 0) as num));
        break;
      default:
        break;
    }
    return items;
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Bộ lọc nhanh', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: [
                FilterChip(selected: _onlyFreeship, label: const Text('Freeship'), onSelected: (v) => setState(() => _onlyFreeship = v)),
                FilterChip(selected: _onlyInStock, label: const Text('Còn hàng'), onSelected: (v) => setState(() => _onlyInStock = v)),
                FilterChip(selected: _onlyHasVoucher, label: const Text('Có voucher'), onSelected: (v) => setState(() => _onlyHasVoucher = v)),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng'))),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton(onPressed: () { setState(() {}); Navigator.pop(context); }, child: const Text('Áp dụng'))),
              ])
            ],
          ),
        ),
      ),
    );
  }
}
