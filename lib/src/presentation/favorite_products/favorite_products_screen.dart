import 'package:flutter/material.dart';
import 'widgets/favorite_product_card.dart';
import 'models/favorite_product.dart';
import '../../core/services/api_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/cart_service.dart';
import '../cart/cart_screen.dart';

class FavoriteProductsScreen extends StatefulWidget {
  const FavoriteProductsScreen({super.key});

  @override
  State<FavoriteProductsScreen> createState() => _FavoriteProductsScreenState();
}

class _FavoriteProductsScreenState extends State<FavoriteProductsScreen> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  final CartService _cartService = CartService();
  
  List<FavoriteProduct> _products = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalFavorites = 0;
  final int _limit = 20;

  @override
  void initState() {
    super.initState();
    _loadFavoriteProducts();
  }

  Future<void> _loadFavoriteProducts({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _products.clear();
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) {
        setState(() {
          _isLoading = false;
          _error = 'Vui lòng đăng nhập để xem sản phẩm yêu thích';
        });
        return;
      }

      final response = await _apiService.getFavoriteProducts(
        userId: currentUser.userId,
        page: _currentPage,
        limit: _limit,
      );

      if (response != null && response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>;
        final productsData = data['products'] as List<dynamic>?;
        final pagination = data['pagination'] as Map<String, dynamic>?;

        if (productsData != null) {
          final newProducts = productsData
              .map((product) => FavoriteProduct.fromJson(product as Map<String, dynamic>))
              .toList();

          setState(() {
            if (refresh) {
              _products = newProducts;
            } else {
              _products.addAll(newProducts);
            }
            _isLoading = false;
            _isLoadingMore = false;
            
            if (pagination != null) {
              _totalPages = pagination['total_pages'] as int? ?? 1;
              _totalFavorites = int.tryParse(pagination['total_favorites']?.toString() ?? '0') ?? 0;
            }
          });
        } else {
          setState(() {
            _isLoading = false;
            _isLoadingMore = false;
            if (refresh) {
              _products = [];
            }
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
          _error = response?['message'] ?? 'Không thể tải danh sách sản phẩm yêu thích';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
        _error = 'Lỗi kết nối: $e';
      });
    }
  }

  Future<void> _refresh() async {
    await _loadFavoriteProducts(refresh: true);
  }

  void _removeProduct(int productId) {
    setState(() {
      _products.removeWhere((product) => product.id == productId);
      _totalFavorites = (_totalFavorites - 1).clamp(0, double.infinity).toInt();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.red,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Text(
          'Sản phẩm yêu thích${_totalFavorites > 0 ? ' ($_totalFavorites)' : ''}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          // Cart button
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CartScreen(),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              child: Stack(
                children: [
                  const Icon(
                    Icons.shopping_cart_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                  // Cart count badge - simplified version
                  FutureBuilder<int>(
                    future: Future.value(_cartService.itemCount),
                    builder: (context, snapshot) {
                      final count = snapshot.data ?? 0;
                      if (count == 0) return const SizedBox.shrink();
                      
                      return Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            count.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _products.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null && _products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.favorite_border,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refresh,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.favorite_border,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Chưa có sản phẩm yêu thích',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Hãy thêm sản phẩm vào danh sách yêu thích để dễ dàng tìm lại sau',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.shopping_bag_outlined),
              label: const Text('Mua sắm ngay'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _products.length + (_isLoadingMore && _currentPage < _totalPages ? 1 : 0),
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          if (index == _products.length) {
            // Loading more indicator
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          final product = _products[index];
          return FavoriteProductCard(
            product: product,
            onRemove: () => _removeProduct(product.id),
          );
        },
      ),
    );
  }
}