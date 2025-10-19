import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../core/models/shop_detail.dart';
import '../product/product_detail_screen.dart';
import '../cart/cart_screen.dart';
import 'widgets/shop_info_header.dart';
import 'widgets/shop_products_section.dart';
import 'widgets/shop_flash_sales_section.dart';
import 'widgets/shop_vouchers_section.dart';
import 'widgets/shop_warehouses_section.dart';
import 'widgets/shop_categories_section.dart';

class ShopDetailScreen extends StatefulWidget {
  final int? shopId;
  final String? shopUsername;
  final String? shopName;
  final String? shopAvatar;

  const ShopDetailScreen({
    super.key,
    this.shopId,
    this.shopUsername,
    this.shopName,
    this.shopAvatar,
  });

  @override
  State<ShopDetailScreen> createState() => _ShopDetailScreenState();
}

class _ShopDetailScreenState extends State<ShopDetailScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  ShopDetail? _shopDetail;
  bool _isLoading = true;
  String? _error;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadShopDetail();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadShopDetail() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final shopDetail = await _apiService.getShopDetail(
        shopId: widget.shopId,
        username: widget.shopUsername,
        includeProducts: 1,
        includeFlashSale: 1,
        includeVouchers: 1,
        includeWarehouses: 1,
        includeCategories: 1,
        productsLimit: 20,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _shopDetail = shopDetail;
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

  void _navigateToProduct(ShopProduct product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(
          productId: product.id,
          title: product.name,
          image: product.image,
          price: product.price,
          initialShopId: widget.shopId,
          initialShopName: widget.shopName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.shopName ?? 'Đang tải...'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.shopName ?? 'Lỗi'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(_error!, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadShopDetail,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (_shopDetail == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.shopName ?? 'Không tìm thấy'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: const Center(
          child: Text('Không tìm thấy thông tin shop'),
        ),
      );
    }

    final shopInfo = _shopDetail!.shopInfo;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(shopInfo.name),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
            icon: const Icon(Icons.shopping_cart),
            tooltip: 'Giỏ hàng',
          ),
        ],
      ),
      body: Column(
        children: [
          // Shop Info Header
          ShopInfoHeader(shopInfo: shopInfo),
          
          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Colors.red,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.red,
              tabs: const [
                Tab(text: 'Sản phẩm'),
                Tab(text: 'Flash Sale'),
                Tab(text: 'Voucher'),
                Tab(text: 'Kho hàng'),
                Tab(text: 'Danh mục'),
              ],
            ),
          ),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Sản phẩm
                ShopProductsSection(
                  products: _shopDetail!.products,
                  onProductTap: _navigateToProduct,
                ),
                
                // Flash Sale
                ShopFlashSalesSection(
                  flashSales: _shopDetail!.flashSales,
                ),
                
                // Voucher
                ShopVouchersSection(
                  vouchers: _shopDetail!.vouchers,
                ),
                
                // Kho hàng
                ShopWarehousesSection(
                  warehouses: _shopDetail!.warehouses,
                ),
                
                // Danh mục
                ShopCategoriesSection(
                  categories: _shopDetail!.categories,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
