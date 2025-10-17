import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../core/models/search_result.dart';
import '../../core/models/product_detail.dart';
import '../../core/utils/format_utils.dart';
import '../product/product_detail_screen.dart';
import '../product/widgets/variant_selection_dialog.dart';
import '../product/widgets/simple_purchase_dialog.dart';
import '../../core/services/cart_service.dart' as cart_service;
import '../cart/cart_screen.dart';
import '../checkout/checkout_screen.dart';
import 'widgets/search_product_card_horizontal.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ApiService _apiService = ApiService();
  final cart_service.CartService _cartService = cart_service.CartService();

  SearchResult? _searchResult;
  bool _isSearching = false;
  String _currentKeyword = '';
  int _currentPage = 1;
  final int _itemsPerPage = 50; // Tăng từ 10 lên 50

  // Lọc & sắp xếp
  String _sort =
      'relevance'; // relevance | price-asc | price-desc | rating-desc | sold-desc
  bool _onlyFreeship = false;
  bool _onlyInStock = false;
  bool _onlyHasVoucher = false;
  RangeValues _priceRange = const RangeValues(0, 20000000);
  String? _selectedCategory; // theo tên danh mục từ API

  // Lịch sử tìm kiếm
  final List<String> _searchHistory = [
    'điện thoại',
    'laptop',
    'tai nghe',
    'sữa tươi',
  ];

  // Danh sách danh mục
  List<Map<String, dynamic>> _categories = [];
  bool _categoriesLoaded = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    if (_categoriesLoaded) return;

    try {
      // Call API để lấy danh mục cha (type=parents) và chỉ lấy 4 danh mục đầu tiên
      final categories = await _apiService.getCategoriesList(
        type: 'parents',
        limit: 4,
        includeChildren: false,
        includeProductsCount: true,
      );
      if (categories != null && mounted) {
        setState(() {
          _categories = categories;
          _categoriesLoaded = true;
        });
      }
    } catch (e) {
      print('❌ Lỗi khi tải danh mục: $e');
      // Nếu API fail, vẫn set loaded = true để không retry liên tục
      if (mounted) {
        setState(() {
          _categoriesLoaded = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    // Có thể thêm debounce logic ở đây
  }

  void _onScroll() {
    // Infinite scroll logic
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _performSearch(String keyword, {bool isLoadMore = false}) async {
    if (keyword.trim().isEmpty) {
      setState(() {
        _searchResult = null;
        _currentKeyword = '';
        _currentPage = 1;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      if (!isLoadMore) {
        _currentKeyword = keyword;
        _currentPage = 1;
        // Reset scroll position khi search mới
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      }
    });

    try {
      final page = isLoadMore ? _currentPage + 1 : 1;
      final result = await _apiService.searchProducts(
        keyword: keyword,
        page: page,
        limit: _itemsPerPage,
      );

      if (result != null && mounted) {
        final searchResult = SearchResult.fromJson(result);

        print(
          '🔍 Search result: ${searchResult.products.length} products, total: ${searchResult.pagination.total}',
        );

        setState(() {
          if (isLoadMore && _searchResult != null) {
            // Thêm sản phẩm mới vào danh sách hiện tại
            final existingProducts = List<SearchProduct>.from(
              _searchResult!.products,
            );
            existingProducts.addAll(searchResult.products);

            _searchResult = SearchResult(
              success: searchResult.success,
              products: existingProducts,
              pagination: searchResult.pagination,
              keyword: searchResult.keyword,
              searchTime: searchResult.searchTime,
            );
            _currentPage = page;
          } else {
            _searchResult = searchResult;
            _currentPage = page;
          }
          _isSearching = false;
        });

        // Thêm vào lịch sử tìm kiếm
        if (!_searchHistory.contains(keyword)) {
          _searchHistory.insert(0, keyword);
          if (_searchHistory.length > 4) {
            _searchHistory.removeLast();
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi tìm kiếm: $e')));
      }
    }
  }

  void _onSearchSubmitted(String keyword) {
    _performSearch(keyword);
  }

  void _onKeywordTapped(String keyword) {
    _searchController.text = keyword;
    _performSearch(keyword);
  }

  void _loadMore() {
    if (_searchResult != null &&
        _searchResult!.pagination.hasNext &&
        !_isSearching &&
        _currentKeyword.isNotEmpty) {
      _performSearch(_currentKeyword, isLoadMore: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: SafeArea(
          bottom: false,
          child: Container(
            color: Theme.of(context).colorScheme.primary,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: 'Tìm kiếm sản phẩm, thương hiệu,...',
                              border: InputBorder.none,
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                            onSubmitted: _onSearchSubmitted,
                            autofocus: true,
                            textInputAction: TextInputAction.search,
                            keyboardType: TextInputType.text,
                            enableSuggestions: true,
                            autocorrect: true,
                            smartDashesType: SmartDashesType.enabled,
                            smartQuotesType: SmartQuotesType.enabled,
                            textCapitalization: TextCapitalization.none,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              setState(() {
                                _searchResult = null;
                                _currentKeyword = '';
                                _currentPage = 1;
                              });
                              // Reset scroll position khi clear search
                              if (_scrollController.hasClients) {
                                _scrollController.animateTo(
                                  0,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOut,
                                );
                              }
                            },
                            child: const Icon(Icons.clear, color: Colors.grey),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () {
                    // TODO: Implement camera search
                  },
                  icon: const Icon(
                    Icons.photo_camera_outlined,
                    color: Colors.white,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Thoát',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_searchResult != null) {
      return _buildSearchResults();
    } else {
      return _buildSearchSuggestions();
    }
  }

  Widget _buildSearchResults() {
    // Kiểm tra nếu không có sản phẩm nào
    final hasNoResults =
        _searchResult!.products.isEmpty ||
        (_searchResult!.products.length == 1 &&
            _searchResult!.products.first.name.isEmpty);

    if (hasNoResults) {
      return _buildNoResults();
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
               Text(
                 'Tìm thấy ${_searchResult!.pagination.total > 0 ? _searchResult!.pagination.total : _searchResult!.products.length} kết quả cho "$_currentKeyword"',
                 style: const TextStyle(
                   fontSize: 16,
                   fontWeight: FontWeight.w600,
                   color: Colors.grey,
                 ),
               ),
            ],
          ),
        ),
        // Bộ lọc nhanh
        _buildFilters(),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _getDisplayedProducts().length + (_isSearching ? 1 : 0),
            itemBuilder: (context, index) {
              // Hiển thị loading indicator ở cuối danh sách khi đang load more
              if (index == _getDisplayedProducts().length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final product = _getDisplayedProducts()[index];
              return SearchProductCardHorizontal(product: product);
            },
          ),
        ),
      ],
    );
  }

  // Build bộ lọc
  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          _sortChip('Phù hợp', 'relevance'),
          const SizedBox(width: 8),
          _sortChip('Giá ↑', 'price-asc'),
          const SizedBox(width: 8),
          _sortChip('Giá ↓', 'price-desc'),
          const SizedBox(width: 8),
          _sortChip('Đánh giá', 'rating-desc'),
          const SizedBox(width: 8),
          _sortChip('Đã bán', 'sold-desc'),
          const SizedBox(width: 8),
          FilterChip(
            selected: _onlyFreeship,
            label: const Text('Freeship'),
            onSelected: (v) => setState(() => _onlyFreeship = v),
          ),
          const SizedBox(width: 8),
          FilterChip(
            selected: _onlyInStock,
            label: const Text('Còn hàng'),
            onSelected: (v) => setState(() => _onlyInStock = v),
          ),
          const SizedBox(width: 8),
          FilterChip(
            selected: _onlyHasVoucher,
            label: const Text('Có voucher'),
            onSelected: (v) => setState(() => _onlyHasVoucher = v),
          ),
          const SizedBox(width: 8),
          ActionChip(
            label: const Text('Khoảng giá'),
            onPressed: _showPriceFilter,
          ),
          const SizedBox(width: 8),
          ActionChip(
            label: Text(
              _selectedCategory == null ? 'Danh mục' : _selectedCategory!,
            ),
            onPressed: _showCategoryFilter,
          ),
        ],
      ),
    );
  }

  Widget _sortChip(String label, String value) {
    final bool selected = _sort == value;
    return ChoiceChip(
      selected: selected,
      label: Text(label),
      onSelected: (_) => setState(() => _sort = value),
    );
  }

  // Lấy danh sách sau khi áp dụng lọc/sắp xếp
  List<SearchProduct> _getDisplayedProducts() {
    List<SearchProduct> items = List<SearchProduct>.from(
      _searchResult!.products,
    );
    if (_onlyFreeship) {
      items = items.where((p) => p.isFreeship).toList();
    }
    if (_onlyInStock) {
      items = items.where((p) => p.inStock).toList();
    }
    if (_onlyHasVoucher) {
      items = items.where((p) => p.hasVoucher).toList();
    }
    items = items
        .where(
          (p) =>
              p.price >= _priceRange.start.round() &&
              p.price <= _priceRange.end.round(),
        )
        .toList();
    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      items = items
          .where(
            (p) => (p.category).toLowerCase().contains(
              _selectedCategory!.toLowerCase(),
            ),
          )
          .toList();
    }
    switch (_sort) {
      case 'price-asc':
        items.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price-desc':
        items.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'rating-desc':
        items.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'sold-desc':
        items.sort((a, b) => b.sold.compareTo(a.sold));
        break;
      default:
        break;
    }
    return items;
  }

  void _showPriceFilter() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        RangeValues temp = _priceRange;
        return StatefulBuilder(
          builder: (ctx, setM) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Khoảng giá',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  RangeSlider(
                    min: 0,
                    max: 20000000,
                    divisions: 200,
                    labels: RangeLabels(
                      FormatUtils.formatCurrency(temp.start.round()),
                      FormatUtils.formatCurrency(temp.end.round()),
                    ),
                    values: temp,
                    onChanged: (v) => setM(() => temp = v),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(FormatUtils.formatCurrency(temp.start.round())),
                      Text(FormatUtils.formatCurrency(temp.end.round())),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _priceRange = const RangeValues(0, 20000000);
                            });
                            Navigator.pop(context);
                          },
                          child: const Text('Đặt lại'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _priceRange = temp;
                            });
                            Navigator.pop(context);
                          },
                          child: const Text('Áp dụng'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showCategoryFilter() async {
    // Lấy danh sách danh mục từ state đã tải (_categories)
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        final cats = _categories.isEmpty
            ? ['Điện tử', 'Gia dụng', 'Thời trang', 'Mỹ phẩm']
            : _categories
                  .map((e) => (e['cat_tieude'] ?? e['name'] ?? '').toString())
                  .where((e) => e.isNotEmpty)
                  .toList();
        String? temp = _selectedCategory;
        return StatefulBuilder(
          builder: (ctx, setM) {
            final maxHeight = MediaQuery.of(ctx).size.height * 0.7;
            return SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  height: maxHeight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Danh mục',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ChoiceChip(
                                label: const Text('Tất cả'),
                                selected: temp == null,
                                onSelected: (_) => setM(() => temp = null),
                              ),
                              ...cats.map(
                                (c) => ChoiceChip(
                                  label: Text(c),
                                  selected: temp == c,
                                  onSelected: (_) => setM(() => temp = c),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedCategory = null;
                                });
                                Navigator.pop(context);
                              },
                              child: const Text('Bỏ lọc'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedCategory = temp;
                                });
                                Navigator.pop(context);
                              },
                              child: const Text('Áp dụng'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: const Color(0xFFF0F0F0),
      child: const Center(
        child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
      ),
    );
  }

  Map<String, dynamic> _fakeMeta(int price) {
    final base = price % 97;
    final reviews = 20 + (base % 80);
    final sold = 30 + (base % 120);
    return {'rating': '5.0', 'reviews': reviews, 'sold': sold};
  }

  void _navigateToProductDetail(
    int id,
    String name,
    String image,
    int price, {
    String? shopId,
    String? shopName,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(
          productId: id,
          title: name,
          image: image,
          price: price,
          initialShopId: int.tryParse(shopId ?? ''),
          initialShopName: shopName,
        ),
      ),
    );
  }

  void _showPurchaseDialog(
    BuildContext context,
    SearchProduct searchProduct,
  ) async {
    try {
      final productDetail = await _apiService.getProductDetail(
        searchProduct.id,
      );
      final parentContext = Navigator.of(context).context;
      if (parentContext.mounted) {
        showModalBottomSheet(
          context: parentContext,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) {
            if (productDetail != null && productDetail.variants.isNotEmpty) {
              return VariantSelectionDialog(
                product: productDetail,
                selectedVariant: productDetail.variants.first,
                onBuyNow: (variant, quantity) {
                  _handleBuyNow(
                    parentContext,
                    productDetail,
                    variant,
                    quantity,
                    fallbackShopId: searchProduct.shopId,
                    fallbackShopName: searchProduct.shopName,
                  );
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (context.mounted) Navigator.of(context).pop();
                  });
                },
                onAddToCart: (variant, quantity) {
                  _handleAddToCart(
                    parentContext,
                    productDetail,
                    variant,
                    quantity,
                    fallbackShopId: searchProduct.shopId,
                    fallbackShopName: searchProduct.shopName,
                  );
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (context.mounted) Navigator.of(context).pop();
                  });
                },
              );
            } else if (productDetail != null) {
              return SimplePurchaseDialog(
                product: productDetail,
                onBuyNow: (product, quantity) {
                  _handleBuyNowSimple(
                    parentContext,
                    product,
                    quantity,
                    fallbackShopId: searchProduct.shopId,
                    fallbackShopName: searchProduct.shopName,
                  );
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (context.mounted) Navigator.of(context).pop();
                  });
                },
                onAddToCart: (product, quantity) {
                  _handleAddToCartSimple(
                    parentContext,
                    product,
                    quantity,
                    fallbackShopId: searchProduct.shopId,
                    fallbackShopName: searchProduct.shopName,
                  );
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (context.mounted) Navigator.of(context).pop();
                  });
                },
              );
            } else {
              return const SizedBox(
                height: 200,
                child: Center(child: Text('Không thể tải thông tin sản phẩm')),
              );
            }
          },
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _handleBuyNow(
    BuildContext context,
    ProductDetail product,
    ProductVariant variant,
    int quantity, {
    String? fallbackShopId,
    String? fallbackShopName,
  }) {
    final item = cart_service.CartItem(
      id: product.id,
      name: '${product.name} - ${variant.name}',
      image: product.imageUrl,
      price: variant.price,
      oldPrice: variant.oldPrice,
      quantity: quantity,
      variant: variant.name,
      shopId: int.tryParse(product.shopId ?? (fallbackShopId ?? '0')) ?? 0,
      shopName: product.shopNameFromInfo.isNotEmpty
          ? product.shopNameFromInfo
          : (product.shopName ?? fallbackShopName ?? 'Unknown Shop'),
      addedAt: DateTime.now(),
      isSelected: true,
    );
    _cartService.addItem(item);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CheckoutScreen()),
    );
  }

  void _handleAddToCart(
    BuildContext context,
    ProductDetail product,
    ProductVariant variant,
    int quantity, {
    String? fallbackShopId,
    String? fallbackShopName,
  }) {
    final item = cart_service.CartItem(
      id: product.id,
      name: '${product.name} - ${variant.name}',
      image: product.imageUrl,
      price: variant.price,
      oldPrice: variant.oldPrice,
      quantity: quantity,
      variant: variant.name,
      shopId: int.tryParse(product.shopId ?? (fallbackShopId ?? '0')) ?? 0,
      shopName: product.shopNameFromInfo.isNotEmpty
          ? product.shopNameFromInfo
          : (product.shopName ?? fallbackShopName ?? 'Unknown Shop'),
      addedAt: DateTime.now(),
    );
    _cartService.addItem(item);
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.showSnackBar(
      SnackBar(
        content: Text(
          'Đã thêm ${product.name} (${variant.name}) x$quantity vào giỏ hàng',
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Xem giỏ hàng',
          textColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartScreen()),
            );
          },
        ),
      ),
    );
  }

  void _handleBuyNowSimple(
    BuildContext context,
    ProductDetail product,
    int quantity, {
    String? fallbackShopId,
    String? fallbackShopName,
  }) {
    final item = cart_service.CartItem(
      id: product.id,
      name: product.name,
      image: product.imageUrl,
      price: product.price,
      oldPrice: product.oldPrice,
      quantity: quantity,
      shopId: int.tryParse(product.shopId ?? (fallbackShopId ?? '0')) ?? 0,
      shopName: product.shopNameFromInfo.isNotEmpty
          ? product.shopNameFromInfo
          : (product.shopName ?? fallbackShopName ?? 'Unknown Shop'),
      addedAt: DateTime.now(),
      isSelected: true,
    );
    _cartService.addItem(item);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CheckoutScreen()),
    );
  }

  void _handleAddToCartSimple(
    BuildContext context,
    ProductDetail product,
    int quantity, {
    String? fallbackShopId,
    String? fallbackShopName,
  }) {
    final item = cart_service.CartItem(
      id: product.id,
      name: product.name,
      image: product.imageUrl,
      price: product.price,
      oldPrice: product.oldPrice,
      quantity: quantity,
      shopId: int.tryParse(product.shopId ?? (fallbackShopId ?? '0')) ?? 0,
      shopName: product.shopNameFromInfo.isNotEmpty
          ? product.shopNameFromInfo
          : (product.shopName ?? fallbackShopName ?? 'Unknown Shop'),
      addedAt: DateTime.now(),
    );
    _cartService.addItem(item);
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.showSnackBar(
      SnackBar(
        content: Text('Đã thêm ${product.name} x$quantity vào giỏ hàng'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Xem giỏ hàng',
          textColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartScreen()),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Không tìm thấy kết quả',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy thử tìm kiếm với từ khóa khác',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              _searchController.clear();
              setState(() {
                _searchResult = null;
                _currentKeyword = '';
                _currentPage = 1;
              });
              // Reset scroll position khi tìm kiếm lại
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            },
            child: const Text('Tìm kiếm lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_searchHistory.isNotEmpty) ...[
          _SectionTitle(icon: Icons.history, title: 'Lịch sử tìm kiếm'),
          const SizedBox(height: 8),
          _SearchHistoryList(history: _searchHistory, onTap: _onKeywordTapped),
          const SizedBox(height: 16),
        ],
        _SectionTitle(icon: Icons.trending_up, title: 'Từ khóa tìm kiếm nhiều'),
        const SizedBox(height: 8),
        _KeywordGrid(onTap: _onKeywordTapped),
        const SizedBox(height: 16),
        _SectionTitle(
          icon: Icons.article_outlined,
          title: 'Danh mục tìm kiếm nhiều',
        ),
        const SizedBox(height: 8),
        _CategoryPairs(categories: _categories, onTap: _onKeywordTapped),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _SearchHistoryList extends StatelessWidget {
  final List<String> history;
  final Function(String) onTap;

  const _SearchHistoryList({required this.history, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Chỉ hiển thị 4 item đầu tiên
    final limitedHistory = history.take(4).toList();

    return Column(
      children: limitedHistory.map((keyword) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.history, color: Colors.grey),
            title: Text(keyword),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
            onTap: () => onTap(keyword),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _KeywordGrid extends StatelessWidget {
  final Function(String) onTap;

  const _KeywordGrid({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = ['dầu gội', 'nước giặt', 'chảo', 'điện gia dụng'];

    // Chỉ hiển thị 4 item đầu tiên
    final limitedItems = items.take(4).toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: limitedItems.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 72,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemBuilder: (context, i) =>
          _KeywordItem(limitedItems[i], onTap: () => onTap(limitedItems[i])),
    );
  }
}

class _KeywordItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _KeywordItem(this.title, {required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF1F4F9),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.search, color: Colors.grey),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 16))),
          ],
        ),
      ),
    );
  }
}

class _CategoryPairs extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final Function(String) onTap;

  const _CategoryPairs({required this.categories, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      // Fallback data khi chưa load được categories - chỉ 4 danh mục
      final fallbackRows = const [
        ['Điện thoại & Phụ kiện', 'Thực phẩm & Đồ uống'],
        ['Mỹ phẩm & Chăm sóc da', 'Thời trang & Phụ kiện'],
      ];
      return Column(
        children: [
          for (final r in fallbackRows)
            Row(
              children: [
                Expanded(
                  child: _CategoryCell(title: r[0], onTap: () => onTap(r[0])),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CategoryCell(title: r[1], onTap: () => onTap(r[1])),
                ),
              ],
            ),
        ],
      );
    }

    // Chỉ lấy 4 categories đầu tiên
    final limitedCategories = categories.take(4).toList();

    // Chia categories thành các cặp
    final List<List<Map<String, dynamic>>> categoryPairs = [];
    for (int i = 0; i < limitedCategories.length; i += 2) {
      if (i + 1 < limitedCategories.length) {
        categoryPairs.add([limitedCategories[i], limitedCategories[i + 1]]);
      } else {
        categoryPairs.add([limitedCategories[i]]);
      }
    }

    return Column(
      children: [
        for (final pair in categoryPairs)
          Row(
            children: [
              Expanded(
                child: _CategoryCell(
                  title: pair[0]['cat_tieude'] ?? pair[0]['name'] ?? 'Danh mục',
                  onTap: () =>
                      onTap(pair[0]['cat_tieude'] ?? pair[0]['name'] ?? ''),
                  imageUrl:
                      pair[0]['cat_minhhoa'] ??
                      pair[0]['cat_img'] ??
                      pair[0]['image_url'],
                ),
              ),
              if (pair.length > 1) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: _CategoryCell(
                    title:
                        pair[1]['cat_tieude'] ?? pair[1]['name'] ?? 'Danh mục',
                    onTap: () =>
                        onTap(pair[1]['cat_tieude'] ?? pair[1]['name'] ?? ''),
                    imageUrl:
                        pair[1]['cat_minhhoa'] ??
                        pair[1]['cat_img'] ??
                        pair[1]['image_url'],
                  ),
                ),
              ],
            ],
          ),
      ],
    );
  }
}

class _CategoryCell extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final String? imageUrl;

  const _CategoryCell({
    required this.title,
    required this.onTap,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 76,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F4F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildCategoryImage(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(title, maxLines: 2)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryImage() {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      // Build URL đầy đủ với domain socdo.vn
      String fullImageUrl = imageUrl!;
      if (!fullImageUrl.startsWith('http')) {
        if (fullImageUrl.startsWith('/')) {
          fullImageUrl = 'https://socdo.vn$fullImageUrl';
        } else {
          fullImageUrl = 'https://socdo.vn/$fullImageUrl';
        }
      }

      return Image.network(
        fullImageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[100],
            child: const Icon(Icons.category, color: Colors.grey),
          );
        },
      );
    }

    // Fallback icon
    return Container(
      color: Colors.grey[100],
      child: const Icon(Icons.category, color: Colors.grey),
    );
  }
}
