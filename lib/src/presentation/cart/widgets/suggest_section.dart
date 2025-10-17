import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/cart_service.dart';
import '../../../core/models/product_suggest.dart';
import '../../home/widgets/product_card_horizontal.dart';

class SuggestSection extends StatefulWidget {
  const SuggestSection({super.key});

  @override
  State<SuggestSection> createState() => _SuggestSectionState();
}

class _SuggestSectionState extends State<SuggestSection> {
  final ApiService _apiService = ApiService();
  final CartService _cartService = CartService();
  List<ProductSuggest> _suggestions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  Future<void> _loadSuggestions() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Lấy thông tin từ giỏ hàng để gợi ý sản phẩm phù hợp
      final cartItems = _cartService.items;
      
      if (cartItems.isNotEmpty) {
        // Lấy danh mục từ sản phẩm đầu tiên trong giỏ hàng
        final firstItem = cartItems.first;
        final excludeIds = cartItems.map((item) => item.id).join(',');
        
        // Gọi API gợi ý sản phẩm dựa trên danh mục
        final suggestions = await _apiService.getProductSuggestions(
          type: 'related',
          productId: firstItem.id,
          limit: 6,
          excludeIds: excludeIds,
        );
        
        if (mounted) {
          setState(() {
            _suggestions = suggestions ?? [];
            _isLoading = false;
          });
        }
      } else {
        // Nếu giỏ hàng trống, gợi ý sản phẩm phổ biến
        final suggestions = await _apiService.getProductSuggestions(
          type: 'bestseller',
          limit: 6,
        );
        
        if (mounted) {
          setState(() {
            _suggestions = suggestions ?? [];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('❌ Lỗi khi tải gợi ý sản phẩm: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('Có thể bạn cũng thích', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          ),
          SizedBox(height: 80),
          Center(
            child: CircularProgressIndicator(),
          ),
          SizedBox(height: 80),
        ],
      );
    }

    if (_suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text('Có thể bạn cũng thích', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        ),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            final product = _suggestions[index];
            return ProductCardHorizontal(
              product: product,
              index: index,
            );
          },
          itemCount: _suggestions.length,
        ),
      ],
    );
  }
}
