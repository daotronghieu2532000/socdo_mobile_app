import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'product_description_screen.dart';
import 'widgets/bottom_actions.dart';
import 'widgets/variant_selection_dialog.dart';
import 'widgets/simple_purchase_dialog.dart';
import 'widgets/row_tile.dart';
import 'widgets/voucher_row.dart';
import 'widgets/rating_preview.dart';
import 'widgets/shop_bar.dart';
import 'widgets/section_header.dart';
import 'widgets/specs_table.dart';
import 'widgets/description_text.dart';
// import 'widgets/viewed_product_card.dart'; // Đã ẩn để dùng lại sau
// import 'widgets/similar_product_card.dart'; // Đã thay thế bằng RelatedProductCard
import 'widgets/related_product_card_horizontal.dart';
import 'widgets/same_shop_product_card_horizontal.dart';
import 'widgets/product_carousel.dart';
import '../../core/utils/format_utils.dart';
import '../../core/services/api_service.dart';
import '../../core/services/cached_api_service.dart';
import '../../core/models/product_detail.dart';
import '../../core/models/same_shop_product.dart';
import '../../core/models/related_product.dart';
import '../search/search_screen.dart';
import '../cart/cart_screen.dart';
import '../checkout/checkout_screen.dart';
import '../shop/shop_detail_screen.dart';
import '../chat/chat_screen.dart';
import '../../core/services/cart_service.dart';
import '../../core/services/auth_service.dart';
import '../common/widgets/go_top_button.dart';

class ProductDetailScreen extends StatefulWidget {
  final int? productId;
  final String? title;
  final String? image;
  final int? price;
  final int? initialShopId;
  final String? initialShopName;
  
  const ProductDetailScreen({
    super.key, 
    this.productId,
    this.title, 
    this.image, 
    this.price,
    this.initialShopId,
    this.initialShopName,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ApiService _apiService = ApiService();
  final CachedApiService _cachedApiService = CachedApiService();
  ProductDetail? _productDetail;
  List<SameShopProduct> _sameShopProducts = [];
  bool _isLoading = true;
  bool _isLoadingSameShop = false;
  String? _error;
  
  // Related products
  List<RelatedProduct> _relatedProducts = [];
  bool _isLoadingRelatedProducts = false;
  ProductVariant? _selectedVariant;
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();
  final CartService _cartService = CartService();
  final AuthService _authService = AuthService();
  bool _isFavorite = false;
  bool _isTogglingFavorite = false;
  
  Future<void> _toggleFavorite() async {
    if (_isTogglingFavorite || widget.productId == null) return;

    setState(() {
      _isTogglingFavorite = true;
    });

    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) {
        _showSnack('Vui lòng đăng nhập để thực hiện thao tác này', background: Colors.red);
        return;
      }

      final result = await _apiService.toggleFavoriteProduct(
        userId: currentUser.userId,
        productId: widget.productId!,
      );

      if (result != null && result['success'] == true) {
        final data = result['data'] as Map<String, dynamic>?;
        final isFavorite = data?['is_favorite'] as bool? ?? false;
        
        setState(() {
          _isFavorite = isFavorite;
        });

        final message = isFavorite ? 'Đã thêm vào danh sách yêu thích' : 'Đã xóa khỏi danh sách yêu thích';
        _showSnack(message, background: Colors.green);
      } else {
        _showSnack('Không thể thực hiện thao tác này', background: Colors.red);
      }
    } catch (e) {
      _showSnack('Lỗi khi thực hiện thao tác: $e', background: Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          _isTogglingFavorite = false;
        });
      }
    }
  }

  void _showSnack(String message, {SnackBarAction? action, Color? background}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final messenger = ScaffoldMessenger.maybeOf(context);
      messenger?.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: background,
          duration: const Duration(seconds: 1),
          action: action,
        ),
      );
    });
  }

  void _navigateToShop() {
    if (_productDetail == null) return;
    
    final shopId = int.tryParse(_productDetail!.shopId ?? '0');
    final shopUsername = _productDetail!.shopNameFromInfo.isNotEmpty 
        ? _productDetail!.shopNameFromInfo 
        : null;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShopDetailScreen(
          shopId: shopId,
          shopUsername: shopUsername,
          shopName: _productDetail!.shopNameFromInfo.isNotEmpty 
              ? _productDetail!.shopNameFromInfo 
              : widget.initialShopName,
          shopAvatar: _productDetail!.shopAvatar,
        ),
      ),
    );
  }

  void _navigateToChat() {
    if (_productDetail == null) return;
    
    final shopId = int.tryParse(_productDetail!.shopId ?? '0');
    print('💬 [DEBUG] Navigating to chat:');
    print('   Product Detail: $_productDetail');
    print('   Shop ID from product: ${_productDetail!.shopId}');
    print('   Parsed Shop ID: $shopId');
    print('   Shop Name: ${_productDetail!.shopNameFromInfo}');
    print('   Initial Shop Name: ${widget.initialShopName}');
    
    if (shopId == null || shopId == 0) {
      print('❌ [DEBUG] Invalid shop ID, showing error');
      _showSnack('Không thể xác định shop để chat', background: Colors.red);
      return;
    }
    
    print('✅ [DEBUG] Valid shop ID, navigating to chat');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          shopId: shopId,
          shopName: _productDetail!.shopNameFromInfo.isNotEmpty 
              ? _productDetail!.shopNameFromInfo 
              : widget.initialShopName ?? 'Shop',
          shopAvatar: _productDetail!.shopAvatar,
          productId: widget.productId,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.productId != null) {
      _loadProductDetail();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadProductDetail() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
        _currentImageIndex = 0; // Reset image index
      });

            // Sử dụng cached API service cho product detail
            final productDetail = await _cachedApiService.getProductDetailCached(widget.productId!);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _productDetail = productDetail;
          // Khởi tạo biến thể đầu tiên nếu có
          if (productDetail?.variants.isNotEmpty == true) {
            _selectedVariant = productDetail!.variants.first;
          }
        });
        
        // Load sản phẩm cùng shop và sản phẩm liên quan sau khi load chi tiết sản phẩm
        if (productDetail != null) {
          _loadSameShopProducts();
          _loadRelatedProducts();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Lỗi kết nối: $e';
        });
      }
    }
  }

  Future<void> _loadSameShopProducts() async {
    if (widget.productId == null) return;
    
    try {
      setState(() {
        _isLoadingSameShop = true;
      });

      // Sử dụng cached API service cho same shop products
      final responseData = await _cachedApiService.getSameShopProductsCached(
        widget.productId!,
        limit: 10,
      );
      
      // Nếu cache không có data, fallback về ApiService
      Map<String, dynamic>? response;
      if (responseData == null || responseData.isEmpty) {
        print('🔄 Cache miss, fetching same shop products from ApiService...');
        response = await _apiService.getProductsSameShop(
          productId: widget.productId!,
          limit: 10,
        );
      } else {
        print('🏪 Using cached same shop products data');
        response = responseData;
      }
      
      if (mounted && response != null) {
        final data = response['data'] as Map<String, dynamic>?;
        final products = data?['products'] as List?;
        
        if (products != null) {
          final sameShopProducts = products
              .map((product) => SameShopProduct.fromJson(product as Map<String, dynamic>))
              .toList();
          
          setState(() {
            _sameShopProducts = sameShopProducts;
            _isLoadingSameShop = false;
          });
        } else {
          setState(() {
            _isLoadingSameShop = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingSameShop = false;
        });
      }
      print('❌ Lỗi khi lấy sản phẩm cùng shop: $e');
    }
  }

  Future<void> _loadRelatedProducts() async {
    if (widget.productId == null) return;
    
    try {
      setState(() {
        _isLoadingRelatedProducts = true;
      });

      // Sử dụng cached API service cho related products
      final relatedProductsData = await _cachedApiService.getRelatedProductsCached(
        widget.productId!,
        limit: 8,
        type: 'auto',
      );
      
      // Nếu cache không có data, fallback về ApiService
      List<RelatedProduct>? relatedProducts;
      if (relatedProductsData == null || relatedProductsData.isEmpty) {
        print('🔄 Cache miss, fetching related products from ApiService...');
        relatedProducts = await _apiService.getRelatedProducts(
          productId: widget.productId!,
          limit: 8,
          type: 'auto',
        );
      } else {
        print('🔗 Using cached related products data');
        // Convert cached data to RelatedProduct list
        relatedProducts = relatedProductsData
            .map((data) => RelatedProduct.fromJson(data))
            .toList();
      }
      
      if (mounted && relatedProducts != null) {
        setState(() {
          _relatedProducts = relatedProducts!;
          _isLoadingRelatedProducts = false;
        });
      } else {
        setState(() {
          _isLoadingRelatedProducts = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingRelatedProducts = false;
        });
      }
      print('❌ Lỗi khi lấy sản phẩm liên quan: $e');
    }
  }


  void _showPurchaseDialog() {
    if (_productDetail == null) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        // Nếu có biến thể, hiển thị dialog chọn biến thể
        if (_productDetail!.variants.isNotEmpty) {
          return VariantSelectionDialog(
            product: _productDetail!,
            selectedVariant: _selectedVariant,
            onBuyNow: _handleBuyNow,
            onAddToCart: _handleAddToCart,
          );
        } else {
          // Nếu không có biến thể, hiển thị dialog đơn giản
          return SimplePurchaseDialog(
            product: _productDetail!,
            onBuyNow: _handleBuyNowSimple,
            onAddToCart: _handleAddToCartSimple,
          );
        }
      },
    );
  }

  // Xử lý MUA NGAY cho sản phẩm có biến thể
  void _handleBuyNow(ProductVariant variant, int quantity) {
    print('🛒 MUA NGAY - Variant: ${variant.name}, Quantity: $quantity');
    
    final product = _productDetail!;
    
    // Thêm sản phẩm vào giỏ hàng
    final cartItem = CartItem(
      id: product.id,
      name: '${product.name} - ${variant.name}',
      image: product.imageUrl,
      price: variant.price,
      oldPrice: variant.oldPrice,
      quantity: quantity,
      variant: variant.name,
      shopId: int.tryParse(product.shopId ?? (widget.initialShopId?.toString() ?? '0')) ?? 0,
      shopName: product.shopNameFromInfo.isNotEmpty ? product.shopNameFromInfo : (widget.initialShopName ?? 'Unknown Shop'),
      addedAt: DateTime.now(),
    );
    
    print('🛒 Adding to cart: ${cartItem.name}');
    _cartService.addItem(cartItem);
    
    // Hiển thị thông báo an toàn sau frame
    _showSnack('Đã thêm ${variant.name} vào giỏ hàng', background: Colors.green);
    
    // Chuyển đến trang thanh toán
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CheckoutScreen(),
      ),
    );
  }

  // Xử lý THÊM VÀO GIỎ cho sản phẩm có biến thể
  void _handleAddToCart(ProductVariant variant, int quantity) {
    final product = _productDetail!;
    
    // Thêm sản phẩm vào giỏ hàng
    final cartItem = CartItem(
      id: product.id,
      name: '${product.name} - ${variant.name}',
      image: product.imageUrl,
      price: variant.price,
      oldPrice: variant.oldPrice,
      quantity: quantity,
      variant: variant.name,
      shopId: int.tryParse(product.shopId ?? '0') ?? 0,
      shopName: product.shopNameFromInfo.isNotEmpty ? product.shopNameFromInfo : 'Unknown Shop',
      addedAt: DateTime.now(),
    );
    _cartService.addItem(cartItem);
    
    // Hiển thị thông báo và nút xem giỏ hàng
    _showSnack(
      'Đã thêm ${variant.name} vào giỏ hàng',
      background: Colors.green, // Thêm màu xanh cho thông báo thành công
      action: SnackBarAction(
        label: 'Xem giỏ hàng',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CartScreen()),
          );
        },
      ),
    );
  }


  // Xử lý MUA NGAY cho sản phẩm không có biến thể
  void _handleBuyNowSimple(ProductDetail product, int quantity) {
    print('🛒 MUA NGAY SIMPLE - Product: ${product.name}, Quantity: $quantity');
    
    // Thêm sản phẩm vào giỏ hàng
    final cartItem = CartItem(
      id: product.id,
      name: product.name,
      image: product.imageUrl,
      price: product.price,
      oldPrice: product.oldPrice,
      quantity: quantity,
      shopId: int.tryParse(product.shopId ?? (widget.initialShopId?.toString() ?? '0')) ?? 0,
      shopName: product.shopNameFromInfo.isNotEmpty ? product.shopNameFromInfo : (widget.initialShopName ?? 'Unknown Shop'),
      addedAt: DateTime.now(),
    );
    
    print('🛒 Adding to cart: ${cartItem.name}');
    _cartService.addItem(cartItem);
    
    _showSnack('Đã thêm ${product.name} vào giỏ hàng', background: Colors.green);
    
    // Chuyển đến trang thanh toán
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CheckoutScreen(),
      ),
    );
  }

  // Xử lý THÊM VÀO GIỎ cho sản phẩm không có biến thể
  void _handleAddToCartSimple(ProductDetail product, int quantity) {
    // Thêm sản phẩm vào giỏ hàng
    final cartItem = CartItem(
      id: product.id,
      name: product.name,
      image: product.imageUrl,
      price: product.price,
      oldPrice: product.oldPrice,
      quantity: quantity,
      shopId: int.tryParse(product.shopId ?? (widget.initialShopId?.toString() ?? '0')) ?? 0,
      shopName: product.shopNameFromInfo.isNotEmpty ? product.shopNameFromInfo : (widget.initialShopName ?? 'Unknown Shop'),
      addedAt: DateTime.now(),
    );
    _cartService.addItem(cartItem);
    
    _showSnack(
      'Đã thêm ${product.name} vào giỏ hàng',
      background: Colors.green, // Thêm màu xanh cho thông báo thành công
      action: SnackBarAction(
        label: 'Xem giỏ hàng',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CartScreen()),
          );
        },
      ),
    );
  }



  Widget _buildImageCarousel(ProductDetail? product, String fallbackImage) {
    // Nếu có nhiều ảnh từ API, sử dụng PageView
    if (product?.images.isNotEmpty == true) {
      final productImages = product!.images; // Safe to use ! here because of the null check above
      return GestureDetector(
        onTap: () {
          // Có thể thêm chức năng zoom image ở đây
          print('🔍 Image tapped: ${productImages[_currentImageIndex]}');
        },
        child: PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentImageIndex = index;
            });
          },
          itemCount: productImages.length,
          itemBuilder: (context, index) {
            return _buildSingleImage(productImages[index]);
          },
        ),
      );
    } else {
      // Fallback về ảnh đơn lẻ
      return GestureDetector(
        onTap: () {
          print('🔍 Single image tapped: ${_productDetail?.mainImageUrl ?? fallbackImage}');
        },
        child: _buildSingleImage(_productDetail?.mainImageUrl ?? fallbackImage),
      );
    }
  }

  Widget _buildSingleImage(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          print('❌ Image load error: $error');
          print('❌ Image URL that failed: $imageUrl');
          return Container(
            color: Colors.grey[200],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
                  const SizedBox(height: 8),
                  const Text('NO IMAGE AVAILABLE', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text('URL: ${imageUrl.length > 50 ? '${imageUrl.substring(0, 50)}...' : imageUrl}', 
                       style: const TextStyle(color: Colors.grey, fontSize: 10)),
                ],
              ),
            ),
          );
        },
      );
    } else {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('❌ Asset image error: $error');
          return Container(
            color: Colors.grey[200],
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('NO IMAGE AVAILABLE', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  void _nextImage() {
    if (_productDetail?.images.isNotEmpty == true && 
        _currentImageIndex < _productDetail!.images.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousImage() {
    if (_currentImageIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Các method _handleMoreOptions, _shareProduct, _toggleFavorite, _reportProduct đã được xóa
  // vì nút ... đã bị ẩn theo yêu cầu

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Đang tải...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lỗi')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(_error!, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadProductDetail,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    final product = _productDetail;
    final title = product?.name ?? widget.title ?? 'Sản phẩm';
    final image = product?.imageUrl ?? widget.image ?? 'lib/src/core/assets/images/product_1.png';
    final price = _selectedVariant?.price ?? product?.price ?? widget.price ?? 0;
    final oldPrice = _selectedVariant?.oldPrice ?? product?.oldPrice;
    return Scaffold(
      bottomNavigationBar: BottomActions(
        price: price,
        shopId: int.tryParse(_productDetail?.shopId ?? '0'),
        onChat: _navigateToChat,
        onBuyNow: _showPurchaseDialog,
        onAddToCart: _showPurchaseDialog,
      ),
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 340,
            title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
            // Thêm padding để tránh bị cắt ảnh
            toolbarHeight: 56,
            collapsedHeight: 56,
            actions: [
              // Search button - Navigate to search screen
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SearchScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.search),
                tooltip: 'Tìm kiếm',
              ),
              // Cart button - Navigate to cart screen
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CartScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.shopping_cart_outlined),
                tooltip: 'Giỏ hàng',
              ),
              // More options menu - Đã ẩn theo yêu cầu
              // PopupMenuButton<String>(
              //   onSelected: (value) {
              //     _handleMoreOptions(value);
              //   },
              //   itemBuilder: (BuildContext context) => [
              //     const PopupMenuItem<String>(
              //       value: 'share',
              //       child: Row(
              //         children: [
              //           Icon(Icons.share, size: 20),
              //           SizedBox(width: 8),
              //           Text('Chia sẻ sản phẩm'),
              //         ],
              //       ),
              //     ),
              //     const PopupMenuItem<String>(
              //       value: 'favorite',
              //       child: Row(
              //         children: [
              //           Icon(Icons.favorite_border, size: 20),
              //           SizedBox(width: 8),
              //           Text('Thêm vào yêu thích'),
              //         ],
              //       ),
              //     ),
              //     const PopupMenuItem<String>(
              //       value: 'report',
              //       child: Row(
              //         children: [
              //           Icon(Icons.report_outlined, size: 20),
              //           SizedBox(width: 8),
              //           Text('Báo cáo sản phẩm'),
              //         ],
              //       ),
              //     ),
              //   ],
              //   icon: const Icon(Icons.more_horiz),
              //   tooltip: 'Thêm tùy chọn',
              // ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Hiển thị carousel hình ảnh
                  _buildImageCarousel(product, image),
                  // Hiển thị số lượng hình ảnh nếu có gallery
                  if (product?.images.isNotEmpty == true)
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(12)),
                        child: Text(
                          '${_currentImageIndex + 1}/${product!.images.length}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  // Navigation arrows
                  if (product?.images.isNotEmpty == true && product!.images.length > 1) ...[
                    // Previous arrow
                    if (_currentImageIndex > 0)
                      Positioned(
                        left: 12,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: GestureDetector(
                            onTap: _previousImage,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black45,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.chevron_left,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                    // Next arrow
                    if (_currentImageIndex < product.images.length - 1)
                      Positioned(
                        right: 12,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: GestureDetector(
                            onTap: _nextImage,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black45,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.chevron_right,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Text(FormatUtils.formatCurrency(price),
                                style: const TextStyle(fontSize: 24, color: Colors.red, fontWeight: FontWeight.w800)),
                            if (oldPrice != null) ...[
                              const SizedBox(width: 8),
                              Text(FormatUtils.formatCurrency(oldPrice),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                  )),
                            ],
                          ],
                        ),
                      ),
                      // Icon trái tim có thể tương tác
                      GestureDetector(
                        onTap: _toggleFavorite,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: _isTogglingFavorite
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Icon(
                                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                                  color: _isFavorite ? Colors.red : Colors.grey,
                                  size: 20,
                                ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(title, 
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  // TODO: Hiển thị chọn biến thể với thiết kế minimalist hiện đại (nếu có) - ĐÃ COMMENT TẠM THỜI
                  // if (product?.variants.isNotEmpty == true) ...[
                  //   Container(
                  //     padding: const EdgeInsets.all(16),
                  //     decoration: BoxDecoration(
                  //       color: Colors.white,
                  //       borderRadius: BorderRadius.circular(12),
                  //       border: Border.all(color: Colors.grey[100]!, width: 1),
                  //     ),
                  //     child: Column(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         // Header với giá
                  //         Row(
                  //           children: [
                  //             Text(
                  //               'Chọn biến thể',
                  //               style: TextStyle(
                  //                 fontSize: 15,
                  //                 fontWeight: FontWeight.w600,
                  //                 color: Colors.grey[800],
                  //               ),
                  //             ),
                  //             const Spacer(),
                  //             Container(
                  //               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  //               decoration: BoxDecoration(
                  //                 color: Colors.red[50],
                  //                 borderRadius: BorderRadius.circular(6),
                  //               ),
                  //               child: Text(
                  //                 '${_selectedVariant?.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}₫',
                  //                 style: TextStyle(
                  //                   fontSize: 14,
                  //                   fontWeight: FontWeight.bold,
                  //                   color: Colors.red[700],
                  //                 ),
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //         const SizedBox(height: 12),
                  //         // Selection buttons minimalist
                  //         ...product!.variants.map((ProductVariant variant) {
                  //           final isSelected = _selectedVariant?.id == variant.id;
                  //           return Container(
                  //             margin: const EdgeInsets.only(bottom: 8),
                  //             child: InkWell(
                  //               onTap: () {
                  //                 setState(() {
                  //                   _selectedVariant = variant;
                  //                 });
                  //               },
                  //               borderRadius: BorderRadius.circular(8),
                  //               child: Container(
                  //                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  //                 decoration: BoxDecoration(
                  //                   color: isSelected ? Colors.red[50] : Colors.transparent,
                  //                   borderRadius: BorderRadius.circular(8),
                  //                   border: Border.all(
                  //                     color: isSelected ? Colors.red : Colors.grey[200]!,
                  //                     width: isSelected ? 1.5 : 1,
                  //                   ),
                  //                 ),
                  //                 child: Row(
                  //                   children: [
                  //                     // Radio button custom
                  //                     Container(
                  //                       width: 20,
                  //                       height: 20,
                  //                       decoration: BoxDecoration(
                  //                         shape: BoxShape.circle,
                  //                         border: Border.all(
                  //                           color: isSelected ? Colors.red : Colors.grey[400]!,
                  //                           width: 2,
                  //                         ),
                  //                       ),
                  //                       child: isSelected
                  //                           ? Center(
                  //                               child: Container(
                  //                                 width: 8,
                  //                                 height: 8,
                  //                                 decoration: const BoxDecoration(
                  //                                   color: Colors.red,
                  //                                   shape: BoxShape.circle,
                  //                                 ),
                  //                               ),
                  //                             )
                  //                           : null,
                  //                     ),
                  //                     const SizedBox(width: 12),
                  //                     Expanded(
                  //                       child: Text(
                  //                         variant.name,
                  //                         style: TextStyle(
                  //                           fontSize: 14,
                  //                           fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  //                           color: isSelected ? Colors.red[700] : Colors.grey[700],
                  //                         ),
                  //                       ),
                  //                     ),
                  //                     Text(
                  //                       '${variant.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}₫',
                  //                       style: TextStyle(
                  //                         fontSize: 13,
                  //                         fontWeight: FontWeight.w600,
                  //                         color: Colors.red[600],
                  //                       ),
                  //                     ),
                  //                   ],
                  //                 ),
                  //               ),
                  //             ),
                  //           );
                  //         }).toList(),
                  //       ],
                  //     ),
                  //   ),
                  //   const SizedBox(height: 16),
                  // ],
                  const SizedBox(height: 12),
                  RowTile(icon: Icons.autorenew, title: 'Đổi trả hàng trong vòng 15 ngày'),
                  const SizedBox(height: 8),
                  // Hiển thị mã giảm giá nếu có
                  if (product?.hasCoupon == true)
                    VoucherRow(
                      couponCode: product!.couponCode,
                      couponDetails: product.couponDetails,
                    ),
                  const SizedBox(height: 20),
                  const RatingPreview(),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          ShopBar(
            shopName: product?.shopNameFromInfo,
            shopAvatar: product?.shopAvatar,
            shopAddress: product?.shopAddress,
            shopUrl: product?.shopUrl,
            totalProducts: () {
              final totalProducts = product?.shopInfo?['total_products'] as int?;
              print('🔍 Debug ShopBar totalProducts: $totalProducts');
              print('🔍 Debug ShopBar shopInfo: ${product?.shopInfo}');
              return totalProducts;
            }(), // Truyền số sản phẩm từ shopInfo với debug
            onViewShop: _navigateToShop,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 2), // Giảm từ 8 xuống 2
                  if (_isLoadingSameShop)
                    const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_sameShopProducts.isNotEmpty) ...[
                    ProductCarousel(
                      title: 'Sản phẩm cùng gian hàng',
                      height: 170, // Tăng height để phù hợp với card 150x150
                      itemWidth: 320, // Tăng itemWidth một chút để phù hợp
                      children: _sameShopProducts.map((product) {
                        return SameShopProductCardHorizontal(product: product);
                      }).toList(),
                    ),
                  ] else
                    const SizedBox(
                      height: 100,
                      child: Center(
                        child: Text(
                          'Không có sản phẩm cùng gian hàng',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  const SizedBox(height: 8), // Giảm từ 16 xuống 8
                  // Hiển thị đặc điểm nổi bật nếu có
                  if (product?.highlights?.isNotEmpty == true) ...[
                    const SectionHeader('Đặc điểm nổi bật'),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Html(
                        data: product!.highlights!,
                        style: {
                          "body": Style(
                            margin: Margins.zero,
                            padding: HtmlPaddings.zero,
                            fontSize: FontSize(14),
                            lineHeight: const LineHeight(1.5),
                          ),
                          "ul": Style(
                            margin: Margins.zero,
                            padding: HtmlPaddings.zero,
                            listStyleType: ListStyleType.none,
                          ),
                          "li": Style(
                            margin: Margins.only(bottom: 8),
                            padding: HtmlPaddings.zero,
                          ),
                          "p": Style(
                            margin: Margins.zero,
                            padding: HtmlPaddings.zero,
                          ),
                          "img": Style(
                            width: Width(300),
                            height: Height.auto(),
                            margin: Margins.symmetric(vertical: 8),
                          ),
                        },
                        extensions: [
                          TagExtension(
                            tagsToExtend: {"img"},
                            builder: (context) {
                              final src = context.attributes['src'] ?? '';
                              final fullUrl = src.startsWith('http') 
                                  ? src 
                                  : 'https://socdo.vn$src';
                              return Image.network(
                                fullUrl,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 100,
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: Icon(Icons.image_not_supported, color: Colors.grey),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  // Hiển thị chi tiết sản phẩm nếu có
                  if (product?.description?.isNotEmpty == true) ...[
                    const SectionHeader('Chi tiết sản phẩm'),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Html(
                        data: product!.description!,
                        style: {
                          "body": Style(
                            margin: Margins.zero,
                            padding: HtmlPaddings.zero,
                            fontSize: FontSize(14),
                            lineHeight: const LineHeight(1.5),
                          ),
                          "h1, h2, h3, h4, h5, h6": Style(
                            margin: Margins.only(bottom: 8),
                            padding: HtmlPaddings.zero,
                            fontWeight: FontWeight.bold,
                          ),
                          "p": Style(
                            margin: Margins.only(bottom: 8),
                            padding: HtmlPaddings.zero,
                          ),
                          "img": Style(
                            width: Width(300),
                            height: Height.auto(),
                            margin: Margins.symmetric(vertical: 8),
                          ),
                        },
                        extensions: [
                          TagExtension(
                            tagsToExtend: {"img"},
                            builder: (context) {
                              final src = context.attributes['src'] ?? '';
                              final fullUrl = src.startsWith('http') 
                                  ? src 
                                  : 'https://socdo.vn$src';
                              return Image.network(
                                fullUrl,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 100,
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: Icon(Icons.image_not_supported, color: Colors.grey),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ],
                  // Fallback nếu không có dữ liệu
                  if ((product?.highlights?.isEmpty ?? true) && (product?.description?.isEmpty ?? true)) ...[
                  const SectionHeader('Chi tiết sản phẩm'),
                  SpecsTable(),
                  const SizedBox(height: 12),
                  DescriptionText(
                    onViewMore: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDescriptionScreen(
                              productName: product?.name ?? 'Sản phẩm',
                              productImage: product?.imageUrl ?? 'lib/src/core/assets/images/product_1.png',
                          ),
                        ),
                      );
                    },
                  ),
                  ],
                  // Mục "Sản phẩm đã xem" đã được ẩn để dùng lại sau
                  // const SizedBox(height: 24),
                  // ProductCarousel(
                  //   title: 'Sản phẩm đã xem',
                  //   itemsPerPage: 2,
                  //   children: List.generate(6, (index) => ViewedProductCard(index: index)),
                  // ),
                  const SizedBox(height: 12), // Giảm từ 24 xuống 12
                  // Sản phẩm liên quan từ API thật
                  if (_isLoadingRelatedProducts)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_relatedProducts.isNotEmpty) ...[
                    ProductCarousel(
                      title: 'Sản phẩm liên quan',
                      height: 160,
                      itemWidth: 280,
                      children: _relatedProducts.map((product) {
                        return RelatedProductCardHorizontal(product: product);
                      }).toList(),
                    ),
                  ] else
                    const SizedBox.shrink(), // Ẩn nếu không có dữ liệu
                  const SizedBox(height: 8), // Giảm từ 20 xuống 8
                ],
              ),
            ),
          ),
        ],
      ),
          // Go Top Button
          GoTopButton(
            scrollController: _scrollController,
            showAfterScrollDistance: 1000.0, // Khoảng 2.5 màn hình
          ),
        ],
      ),
    );
  }
}
















