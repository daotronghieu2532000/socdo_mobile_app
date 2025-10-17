import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../core/models/freeship_product.dart';
import '../../core/models/product_detail.dart';
import '../product/product_detail_screen.dart';
import '../product/widgets/variant_selection_dialog.dart';
import '../product/widgets/simple_purchase_dialog.dart';
import '../../core/services/cart_service.dart' as cart_service;
import '../cart/cart_screen.dart';
import '../checkout/checkout_screen.dart';
import '../root_shell.dart';
import 'widgets/freeship_product_card_horizontal.dart';

class FreeShipProductsScreen extends StatefulWidget {
  const FreeShipProductsScreen({super.key});

  @override
  State<FreeShipProductsScreen> createState() => _FreeShipProductsScreenState();
}

class _FreeShipProductsScreenState extends State<FreeShipProductsScreen> {
  final ApiService _apiService = ApiService();
  final cart_service.CartService _cartService = cart_service.CartService();
  List<FreeShipProduct> _products = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final products = await _apiService.getFreeShipProducts();
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (products != null) {
            _products = products;
          } else {
            _error = 'Không thể tải danh sách sản phẩm';
          }
        });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FreeShip',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadProducts,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: const RootShellBottomBar(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Đang tải sản phẩm miễn phí ship...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProducts,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
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
            Icon(
              Icons.local_shipping,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Hiện tại không có sản phẩm miễn phí ship nào',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        // Header banner
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.red, Color(0xFFFF6B6B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.local_shipping,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Miễn phí vận chuyển',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_products.length} sản phẩm',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Products list
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final product = _products[index];
                return FreeShipProductCardHorizontal(product: product);
              },
              childCount: _products.length,
            ),
          ),
        ),
        
        // Bottom padding
        const SliverToBoxAdapter(
          child: SizedBox(height: 80),
        ),
      ],
    );
  }


  Widget _buildPlaceholderImage() {
    return Container(
      color: const Color(0xFFF0F0F0),
      child: const Center(
        child: Icon(
          Icons.image_not_supported,
          size: 40,
          color: Colors.grey,
        ),
      ),
    );
  }

  Map<String, dynamic> _fakeMeta(int price) {
    final base = price % 97;
    final reviews = 20 + (base % 80);
    final sold = 30 + (base % 120);
    return {'rating': '5.0', 'reviews': reviews, 'sold': sold};
  }

  // Helper to parse color from hex string
  Color _parseColor(String hexColor) {
    try {
      final hex = hexColor.replaceAll('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      }
      return Colors.green; // Default
    } catch (e) {
      return Colors.green;
    }
  }

  // Hiển thị dialog mua hàng (y hệt logic homepage)
  void _showPurchaseDialog(BuildContext context, FreeShipProduct product) async {
    try {
      // Lấy thông tin chi tiết sản phẩm
      final productDetail = await _apiService.getProductDetail(product.id);
      
      // Sử dụng context từ parent để tránh vấn đề context hierarchy
      final parentContext = Navigator.of(context).context;
      
      if (parentContext.mounted) {
        showModalBottomSheet(
          context: parentContext,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) {
            // Nếu có biến thể, hiển thị dialog chọn biến thể
            if (productDetail != null && productDetail.variants.isNotEmpty) {
              return VariantSelectionDialog(
                product: productDetail,
                selectedVariant: productDetail.variants.first,
                onBuyNow: (variant, quantity) {
                  // Thực hiện logic trước, để dialog tự đóng sau
                  _handleBuyNow(parentContext, productDetail, variant, quantity);
                  
                  // Delay một chút rồi đóng dialog
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  });
                },
                onAddToCart: (variant, quantity) {
                  // Thực hiện logic trước, để dialog tự đóng sau
                  _handleAddToCart(parentContext, productDetail, variant, quantity);
                  
                  // Delay một chút rồi đóng dialog
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  });
                },
              );
            } else if (productDetail != null) {
              return SimplePurchaseDialog(
                product: productDetail,
                onBuyNow: (product, quantity) {
                  // Thực hiện logic trước, để dialog tự đóng sau
                  _handleBuyNowSimple(parentContext, product, quantity);
                  
                  // Delay một chút rồi đóng dialog
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  });
                },
                onAddToCart: (product, quantity) {
                  // Thực hiện logic trước, để dialog tự đóng sau
                  _handleAddToCartSimple(parentContext, product, quantity);
                  
                  // Delay một chút rồi đóng dialog
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  });
                },
              );
            } else {
              return const SizedBox(
                height: 200,
                child: Center(
                  child: Text('Không thể tải thông tin sản phẩm'),
                ),
              );
            }
          },
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Xử lý MUA NGAY cho sản phẩm có biến thể
  void _handleBuyNow(BuildContext context, ProductDetail product, ProductVariant variant, int quantity) {
    final cartItem = cart_service.CartItem(
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
      isSelected: true,
    );
    
    _cartService.addItem(cartItem);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CheckoutScreen(),
      ),
    );
  }

  // Xử lý THÊM VÀO GIỎ cho sản phẩm có biến thể
  void _handleAddToCart(BuildContext context, ProductDetail product, ProductVariant variant, int quantity) {
    final cartItem = cart_service.CartItem(
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
    
    // Hiển thị thông báo sử dụng ScaffoldMessenger.maybeOf
    try {
      final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
      if (scaffoldMessenger != null) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Đã thêm ${product.name} (${variant.name}) x$quantity vào giỏ hàng'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Xem giỏ hàng',
              textColor: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CartScreen(),
                  ),
                );
              },
            ),
          ),
        );
      }
    } catch (e) {
      // Silent fail
    }
  }

  // Xử lý MUA NGAY cho sản phẩm không có biến thể
  void _handleBuyNowSimple(BuildContext context, ProductDetail product, int quantity) {
    final cartItem = cart_service.CartItem(
      id: product.id,
      name: product.name,
      image: product.imageUrl,
      price: product.price,
      oldPrice: product.oldPrice,
      quantity: quantity,
      shopId: int.tryParse(product.shopId ?? '0') ?? 0,
      shopName: product.shopNameFromInfo.isNotEmpty ? product.shopNameFromInfo : 'Unknown Shop',
      addedAt: DateTime.now(),
      isSelected: true,
    );
    
    _cartService.addItem(cartItem);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CheckoutScreen(),
      ),
    );
  }

  // Xử lý THÊM VÀO GIỎ cho sản phẩm không có biến thể
  void _handleAddToCartSimple(BuildContext context, ProductDetail product, int quantity) {
    final cartItem = cart_service.CartItem(
      id: product.id,
      name: product.name,
      image: product.imageUrl,
      price: product.price,
      oldPrice: product.oldPrice,
      quantity: quantity,
      shopId: int.tryParse(product.shopId ?? '0') ?? 0,
      shopName: product.shopNameFromInfo.isNotEmpty ? product.shopNameFromInfo : 'Unknown Shop',
      addedAt: DateTime.now(),
    );
    
    _cartService.addItem(cartItem);
    
    // Hiển thị thông báo sử dụng ScaffoldMessenger.maybeOf
    try {
      final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
      if (scaffoldMessenger != null) {
        scaffoldMessenger.showSnackBar(
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
                  MaterialPageRoute(
                    builder: (context) => const CartScreen(),
                  ),
                );
              },
            ),
          ),
        );
      }
    } catch (e) {
      // Silent fail
    }
  }

  

  void _navigateToProductDetail(FreeShipProduct product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(
          productId: product.id,
          title: product.name,
          image: product.image ?? 'lib/src/core/assets/images/product_1.png',
          price: product.price,
        ),
      ),
    );
  }
}
