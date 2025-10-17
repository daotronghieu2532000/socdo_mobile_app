import 'package:flutter/material.dart';
import 'product_card_horizontal.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/product_suggest.dart';

class ProductGrid extends StatefulWidget {
  final String title;
  const ProductGrid({super.key, required this.title});

  @override
  State<ProductGrid> createState() => _ProductGridState();
}

class _ProductGridState extends State<ProductGrid> {
  final ApiService _apiService = ApiService();
  List<ProductSuggest> _products = [];
  bool _isLoading = true;
  String? _error;
  bool _expanded = false; // Hiển thị 10 mặc định, mở rộng để xem thêm

  @override
  void initState() {
    super.initState();
    _loadProductSuggests();
  }

  Future<void> _loadProductSuggests() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Lấy tối đa 100 sản phẩm gợi ý
      final products = await _apiService.getProductSuggests(limit: 100);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (products != null && products.isNotEmpty) {
            _products = products;
          } else {
            _error = 'Không có sản phẩm gợi ý';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(widget.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        ),
        _buildProductsList(),
      ],
    );
  }

  Widget _buildProductsList() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: CircularProgressIndicator(color: Colors.red),
        ),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _loadProductSuggests,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.recommend_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'Không có sản phẩm gợi ý',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Xác định số lượng item hiển thị theo trạng thái thu gọn/mở rộng
    final int visibleCount = _expanded
        ? _products.length
        : (_products.length > 20 ? 20 : _products.length); // Tăng từ 10 lên 20

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            final product = _products[index];
            return ProductCardHorizontal(
              product: product,
              index: index,
            );
          },
          itemCount: visibleCount,
        ),
        if (_products.length > 20) // Tăng từ 10 lên 20
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _expanded = !_expanded;
                  });
                },
                icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                label: Text(_expanded ? 'Ẩn bớt' : 'Xem thêm'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
