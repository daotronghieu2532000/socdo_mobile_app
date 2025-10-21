import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math';
import '../../../core/models/shop_detail.dart';
import '../../../core/utils/format_utils.dart';
import '../../product/widgets/variant_selection_dialog.dart';
import '../../product/widgets/simple_purchase_dialog.dart';
import '../../product/product_detail_screen.dart';
import '../../cart/cart_screen.dart';
import '../../checkout/checkout_screen.dart';
import '../../../core/models/product_detail.dart';
import '../../../core/services/cart_service.dart';
import '../../../core/services/cached_api_service.dart';

class ShopFlashSalesSection extends StatefulWidget {
  final List<ShopFlashSale> flashSales;

  const ShopFlashSalesSection({
    super.key,
    required this.flashSales,
  });

  @override
  State<ShopFlashSalesSection> createState() => _ShopFlashSalesSectionState();
}

class _ShopFlashSalesSectionState extends State<ShopFlashSalesSection> {
  late Timer _timer;
  final Map<int, Duration> _timeLeftMap = {};
  final Map<int, bool> _expandedMap = {}; // Track expanded state for each flash sale

  @override
  void initState() {
    super.initState();
    _initializeTimers();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTimers();
    });
  }

  void _initializeTimers() {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    for (var flashSale in widget.flashSales) {
      final timeLeft = flashSale.endTime - now;
      _timeLeftMap[flashSale.id] = Duration(seconds: timeLeft > 0 ? timeLeft : 0);
    }
  }

  void _updateTimers() {
    bool needsUpdate = false;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    
    for (var flashSale in widget.flashSales) {
      final timeLeft = flashSale.endTime - now;
      final currentDuration = Duration(seconds: timeLeft > 0 ? timeLeft : 0);
      
      if (_timeLeftMap[flashSale.id] != currentDuration) {
        _timeLeftMap[flashSale.id] = currentDuration;
        needsUpdate = true;
      }
    }
    
    if (needsUpdate) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.flashSales.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.flash_on_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Shop chưa có flash sale nào',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: widget.flashSales.length,
      itemBuilder: (context, index) {
        final flashSale = widget.flashSales[index];
        return _buildFlashSaleCard(flashSale, context);
      },
    );
  }

  Widget _buildFlashSaleCard(ShopFlashSale flashSale, BuildContext context) {
    final timeLeft = _timeLeftMap[flashSale.id] ?? const Duration();
    final isActive = timeLeft.inSeconds > 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red[400]!, Colors.red[600]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                const Icon(Icons.flash_on, color: Colors.white, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    flashSale.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                // Small countdown on the right
                if (isActive) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                      _formatTime(timeLeft),
                    style: const TextStyle(
                      color: Colors.white,
                        fontSize: 12,
                      fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                // Expand/Collapse button
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _expandedMap[flashSale.id] = !(_expandedMap[flashSale.id] ?? true);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      (_expandedMap[flashSale.id] ?? true) ? Icons.expand_less : Icons.expand_more,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Animated content
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: (_expandedMap[flashSale.id] ?? true) ? null : 0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: (_expandedMap[flashSale.id] ?? true) ? 1.0 : 0.0,
              child: Column(
                children: [
                  // Danh sách sản phẩm
                  if (flashSale.subProducts.isNotEmpty) ...[
                    const Divider(height: 1),
          Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                         
                          const SizedBox(height: 8),
                          ...flashSale.subProducts.entries.map((entry) {
                            final productId = int.tryParse(entry.key) ?? 0;
                            final productData = entry.value;
                            if (productData is! Map<String, dynamic>) {
                              return const SizedBox.shrink();
                            }
                            
                            final productInfo = productData['product_info'] as Map<String, dynamic>?;
                            final variants = productData['variants'] as List<dynamic>?;
                            if (productInfo == null || variants == null || variants.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            
                            final variant = variants.first as Map<String, dynamic>;
                            return _buildFlashSaleProductItem(
                              productId: productId,
                              productInfo: productInfo,
                              variant: variant,
                              context: context,
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    
    if (days > 0) {
      return '⌛ $days : $hours : $minutes : $seconds';
    } else if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  Widget _buildFlashSaleProductItem({
    required int productId,
    required Map<String, dynamic> productInfo,
    required Map<String, dynamic> variant,
    required BuildContext context,
  }) {
    final price = int.tryParse(variant['gia']?.toString() ?? '0') ?? 0;
    final oldPrice = int.tryParse(variant['gia_cu']?.toString() ?? '0') ?? 0;
    final discountPercent = oldPrice > 0 && price < oldPrice 
        ? ((oldPrice - price) / oldPrice * 100).round() 
        : 0;
    
    // Get product info
    final productName = productInfo['name'] as String? ?? 'Sản phẩm #$productId';
    final productImage = productInfo['image'] as String? ?? '';
    final voucherIcon = productInfo['voucher_icon'] as String? ?? '';
    final freeshipIcon = productInfo['freeship_icon'] as String? ?? '';
    final chinhhangIcon = productInfo['chinhhang_icon'] as String? ?? '';
    final warehouseName = productInfo['warehouse_name'] as String? ?? '';
    final provinceName = productInfo['province_name'] as String? ?? '';
    
    // Generate fake data
    final fakeData = _generateFakeData(productId, price);
    
    return GestureDetector(
      onTap: () {
        // Navigate to product detail
    Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(
              productId: productId,
              title: productName,
              image: productImage,
              price: price,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Row(
        children: [
          // Product image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF4F6FB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: productImage.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      productImage,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: Icon(Icons.image, color: Colors.grey, size: 32),
                      ),
                    ),
                  )
                : const Center(
                    child: Icon(Icons.image, color: Colors.grey, size: 32),
                  ),
          ),
          const SizedBox(width: 12),
          
          // Product info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      FormatUtils.formatCurrency(price),
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    if (oldPrice > 0) ...[
                      const SizedBox(width: 6),
                    Text(
                        FormatUtils.formatCurrency(oldPrice),
                        style: const TextStyle(
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                        fontSize: 12,
                      ),
                    ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 12, color: Colors.amber),
                    const SizedBox(width: 2),
                    Text(
                      '${fakeData['rating']} (${fakeData['reviews']}) | Đã bán ${fakeData['sold']}',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Badges row
                Wrap(
                  spacing: 4,
                  runSpacing: 2,
                  children: [
                    if (discountPercent > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Giảm $discountPercent%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (voucherIcon.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          voucherIcon,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (freeshipIcon.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          freeshipIcon,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (chinhhangIcon.isNotEmpty)
                  Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          chinhhangIcon,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                          ),
                        ),
                      ],
                    ),
                if (warehouseName.isNotEmpty || provinceName.isNotEmpty) ...[
                  const SizedBox(height: 4),
                Row(
                  children: [
                      const Icon(Icons.location_on, size: 10, color: Colors.grey),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          provinceName.isNotEmpty ? provinceName : warehouseName,
                          style: const TextStyle(fontSize: 9, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              ],
            ),
          ),
          
          // Add to cart button
          GestureDetector(
            onTap: () => _showPurchaseDialog(context, productId),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_shopping_cart,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  // Helper function to generate fake rating and sold data
  Map<String, dynamic> _generateFakeData(int productId, int price) {
    final random = Random(productId);
    final isExpensive = price >= 1000000;
    
    final reviews = isExpensive 
        ? (random.nextInt(21) + 5)
        : (random.nextInt(95) + 10);
    
    final sold = isExpensive
        ? (random.nextInt(21) + 5)
        : (random.nextInt(90) + 15);
    
    return {
      'rating': '5.0',
      'reviews': reviews,
      'sold': sold,
    };
  }

  void _showPurchaseDialog(BuildContext context, int productId) async {
    try {
      // Dùng cache cho chi tiết sản phẩm để thống nhất với các nơi khác
      final productDetail = await CachedApiService().getProductDetailCached(productId);
      final parentContext = Navigator.of(context).context;
      
      if (parentContext.mounted && productDetail != null) {
        showModalBottomSheet(
          context: parentContext,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) {
            if (productDetail.variants.isNotEmpty) {
              return VariantSelectionDialog(
                product: productDetail,
                selectedVariant: productDetail.variants.first,
                onBuyNow: (variant, quantity) {
                  _handleBuyNow(parentContext, productDetail, variant, quantity);
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (context.mounted) Navigator.of(context).pop();
                  });
                },
                onAddToCart: (variant, quantity) {
                  _handleAddToCart(parentContext, productDetail, variant, quantity);
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (context.mounted) Navigator.of(context).pop();
                  });
                },
              );
    } else {
              return SimplePurchaseDialog(
                product: productDetail,
                onBuyNow: (product, quantity) {
                  _handleBuyNowSimple(parentContext, product, quantity);
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (context.mounted) Navigator.of(context).pop();
                  });
                },
                onAddToCart: (product, quantity) {
                  _handleAddToCartSimple(parentContext, product, quantity);
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (context.mounted) Navigator.of(context).pop();
                  });
                },
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

  void _handleBuyNow(BuildContext context, ProductDetail product, ProductVariant variant, int quantity) {
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
    
    CartService().addItem(cartItem);
    
    final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
    if (scaffoldMessenger != null) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Đã thêm ${variant.name} vào giỏ hàng'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CheckoutScreen()),
    );
  }

  void _handleAddToCart(BuildContext context, ProductDetail product, ProductVariant variant, int quantity) {
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
    
    CartService().addItem(cartItem);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã thêm ${product.name} (${variant.name}) x$quantity vào giỏ hàng'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'Xem giỏ hàng',
          textColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CartScreen()),
            );
          },
        ),
      ),
    );
  }

  void _handleBuyNowSimple(BuildContext context, ProductDetail product, int quantity) {
    final cartItem = CartItem(
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
    
    CartService().addItem(cartItem);
    
    final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
    if (scaffoldMessenger != null) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Đã thêm ${product.name} vào giỏ hàng'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CheckoutScreen()),
    );
  }

  void _handleAddToCartSimple(BuildContext context, ProductDetail product, int quantity) {
    final cartItem = CartItem(
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
    
    CartService().addItem(cartItem);
    
    final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
    if (scaffoldMessenger != null) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Đã thêm ${product.name} x$quantity vào giỏ hàng'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'Xem giỏ hàng',
            textColor: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
          ),
        ),
      );
    }
  }
}
