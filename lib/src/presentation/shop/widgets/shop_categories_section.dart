import 'package:flutter/material.dart';
import '../../../core/models/shop_detail.dart';
import '../../../core/services/cached_api_service.dart';
import 'shop_section_wrapper.dart';

class ShopCategoriesSection extends StatefulWidget {
  final int shopId;

  const ShopCategoriesSection({
    super.key,
    required this.shopId,
  });

  @override
  State<ShopCategoriesSection> createState() => _ShopCategoriesSectionState();
}

class _ShopCategoriesSectionState extends State<ShopCategoriesSection> {
  final CachedApiService _cachedApiService = CachedApiService();
  
  List<ShopCategory> _categories = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final categoriesData = await _cachedApiService.getShopCategoriesCached(
        shopId: widget.shopId,
      );

      if (mounted) {
        final categories = categoriesData.map((data) => ShopCategory.fromJson(data)).toList();
        
        setState(() {
          _categories = categories;
          _isLoading = false;
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
    return ShopSectionWrapper(
      isLoading: _isLoading,
      error: _error,
      emptyMessage: 'Shop chưa có danh mục nào',
      emptyIcon: Icons.category_outlined,
      onRetry: _loadCategories,
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return _buildCategoryCard(category);
        },
      ),
    );
  }

  Widget _buildCategoryCard(ShopCategory category) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (category.image.isNotEmpty)
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(category.image),
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.category,
                size: 30,
                color: Colors.grey,
              ),
            ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              category.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}