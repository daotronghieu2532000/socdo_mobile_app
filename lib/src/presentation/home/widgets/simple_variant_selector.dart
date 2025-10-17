import 'package:flutter/material.dart';
import '../../../core/models/product_detail.dart';
import '../../../core/utils/format_utils.dart';

class SimpleVariantSelector extends StatefulWidget {
  final List<ProductVariant> variants;
  final Function(ProductVariant?) onVariantChanged;
  final Function(int quantity, ProductVariant variant) onQuantityChanged;
  final String? defaultProductImage; // Ảnh sản phẩm chính mặc định

  const SimpleVariantSelector({
    super.key,
    required this.variants,
    required this.onVariantChanged,
    required this.onQuantityChanged,
    this.defaultProductImage,
  });

  @override
  State<SimpleVariantSelector> createState() => _SimpleVariantSelectorState();
}

class _SimpleVariantSelectorState extends State<SimpleVariantSelector> {
  final Map<String, String> _selectedAttributes = {};
  final Map<String, int> _quantities = {};
  bool _hasUserSelected = false; // Track xem user đã chọn biến thể hay chưa

  @override
  void initState() {
    super.initState();
    // Không tự động chọn biến thể mặc định để tránh lỗi
  }

  ProductVariant? _getSelectedVariant() {
    for (final variant in widget.variants) {
      if (variant.matchesSelection(_selectedAttributes)) {
        return variant;
      }
    }
    return null;
  }

  List<ProductVariantGroup> _getVariantGroups() {
    final Map<String, Set<String>> attributeGroups = {};
    
    for (final variant in widget.variants) {
      for (final entry in variant.attributes.entries) {
        attributeGroups.putIfAbsent(entry.key, () => <String>{});
        attributeGroups[entry.key]!.add(entry.value);
      }
    }

    return attributeGroups.entries.map((entry) {
      return ProductVariantGroup(
        name: entry.key,
        options: entry.value.toList()..sort(),
        variants: widget.variants,
      );
    }).toList();
  }

  void _onAttributeChanged(String groupName, String option) {
    if (!mounted) return;
    
    setState(() {
      // Đánh dấu user đã chọn
      _hasUserSelected = true;
      
      // Nếu đã chọn option này rồi, bỏ chọn (toggle)
      if (_selectedAttributes[groupName] == option) {
        _selectedAttributes.remove(groupName);
      } else {
        // Chọn option mới
        _selectedAttributes[groupName] = option;
        
        // Kiểm tra xem có variant nào compatible không
        final newSelection = Map<String, String>.from(_selectedAttributes);
        final availableVariants = widget.variants.where((variant) {
          return variant.isCompatibleWith(newSelection);
        }).toList();
        
        // Nếu không có variant nào compatible, chỉ giữ lại lựa chọn hiện tại
        if (availableVariants.isEmpty) {
          _selectedAttributes.clear();
          _selectedAttributes[groupName] = option;
        }
      }
    });
    
    // Gọi callback sau khi setState hoàn thành
    // Lưu ý: callback này chỉ để thông báo biến thể đã chọn, KHÔNG thay đổi giá sản phẩm chính
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final selectedVariant = _getSelectedVariant();
        widget.onVariantChanged(selectedVariant);
      }
    });
  }

  void _onQuantityChanged(ProductVariant variant, int quantity) {
    if (!mounted) return;
    setState(() {
      _quantities[variant.id] = quantity;
    });
    widget.onQuantityChanged(quantity, variant);
  }

  @override
  Widget build(BuildContext context) {
    final variantGroups = _getVariantGroups();
    final selectedVariant = _getSelectedVariant();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chỉ hiện khi user đã chọn biến thể VÀ có đủ thuộc tính để tạo thành biến thể hoàn chỉnh
            if (_hasUserSelected && selectedVariant != null && _selectedAttributes.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[50]!, Colors.blue[100]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!, width: 1),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Ảnh sản phẩm (mặc định hoặc biến thể)
                        if (widget.defaultProductImage != null || (selectedVariant.imageUrl != null && _selectedAttributes.containsKey('Màu sắc'))) ...[
                          GestureDetector(
                            onTap: () {
                              final imageToShow = (selectedVariant.imageUrl != null && _selectedAttributes.containsKey('Màu sắc')) 
                                  ? selectedVariant.imageUrl! 
                                  : widget.defaultProductImage!;
                              _showFullScreenImage(imageToShow);
                            },
                            child: Stack(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.blue[200]!, width: 2),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.asset(
                                      (selectedVariant.imageUrl != null && _selectedAttributes.containsKey('Màu sắc')) 
                                          ? selectedVariant.imageUrl! 
                                          : widget.defaultProductImage!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.grey[200],
                                          child: Icon(
                                            Icons.image_not_supported,
                                            color: Colors.grey[400],
                                            size: 24,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                // Icon phóng to ở góc phải của ảnh
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () {
                                      final imageToShow = (selectedVariant.imageUrl != null && _selectedAttributes.containsKey('Màu sắc')) 
                                          ? selectedVariant.imageUrl! 
                                          : widget.defaultProductImage!;
                                      _showFullScreenImage(imageToShow);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      child: const Icon(
                                        Icons.fullscreen,
                                        color: Colors.white,
                                        size: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        // Giá và icon
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Giá cũ và giá mới
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      FormatUtils.formatCurrency(selectedVariant.price),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.red,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Vẫn còn hàng',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.green[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                Padding(
                                  padding: const EdgeInsets.only(top: 2), // Điều chỉnh để giá cũ nằm cùng baseline với giá mới
                                  child: Text(
                                    FormatUtils.formatCurrency(selectedVariant.price * 12 ~/ 10), // Giá cũ (cao hơn 20%)
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        children: _selectedAttributes.entries.map((entry) {
                          return Expanded(
                            child: Column(
                              children: [
                                Text(
                                  entry.key,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  entry.value,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Hiển thị các nhóm thuộc tính với design đẹp hơn
            ...variantGroups.map((group) => _buildAttributeGroup(group)),

            // Hiển thị quantity selector cho biến thể đã chọn
            // Chỉ hiện khi user đã chọn biến thể VÀ có đủ thuộc tính
            // Lưu ý: Quantity này chỉ áp dụng cho biến thể đã chọn, không ảnh hưởng đến sản phẩm chính
            if (_hasUserSelected && selectedVariant != null && _selectedAttributes.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildQuantitySelector(selectedVariant),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAttributeGroup(ProductVariantGroup group) {
    final availableOptions = group.getAvailableOptions(_selectedAttributes);
    final currentSelection = _selectedAttributes[group.name];

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header với icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  _getIconForGroup(group.name),
                  color: Colors.blue[600],
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                group.name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          
          // Options với design đẹp hơn
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: group.options.map((option) {
                final isAvailable = availableOptions.contains(option);
                final isSelected = currentSelection == option;
                
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  child: GestureDetector(
                    onTap: () {
                      // Ngăn event bubbling để không trigger navigation
                      _onAttributeChanged(group.name, option);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: isSelected 
                            ? LinearGradient(
                                colors: [Colors.red[400]!, Colors.red[600]!],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: isSelected 
                            ? null
                            : isAvailable 
                                ? Colors.white 
                                : Colors.grey[100], // Màu xám mờ cho tùy chọn không có sẵn như Shopee
                        border: Border.all(
                          color: isSelected 
                              ? Colors.red[600]!
                              : isAvailable 
                                  ? Colors.grey[300]! 
                                  : Colors.grey[200]!, // Border xám mờ cho tùy chọn không có sẵn
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: isSelected ? [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ] : null,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Hình ảnh biến thể (chỉ hiện cho màu sắc)
                          if (group.name.toLowerCase() == 'màu sắc' && _getImageForOption(group.name, option) != null) ...[
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isSelected ? Colors.white : Colors.grey[300]!,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.asset(
                                  _getImageForOption(group.name, option)!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[200],
                                      child: Icon(
                                        Icons.image_not_supported,
                                        color: Colors.grey[400],
                                        size: 20,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                          ],
                          // Text và icon
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isSelected) ...[
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                              ],
                              Text(
                                option,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected 
                                      ? Colors.white 
                                      : isAvailable 
                                          ? Colors.black87 
                                          : Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForGroup(String groupName) {
    switch (groupName.toLowerCase()) {
      case 'dung lượng':
        return Icons.storage;
      case 'màu sắc':
        return Icons.palette;
      case 'kích thước':
        return Icons.straighten;
      case 'kích cỡ':
        return Icons.straighten;
      case 'chip':
        return Icons.memory;
      case 'trọng lượng':
        return Icons.scale;
      default:
        return Icons.category;
    }
  }

  // Lấy hình ảnh cho một tùy chọn cụ thể
  String? _getImageForOption(String groupName, String option) {
    for (final variant in widget.variants) {
      if (variant.attributes[groupName] == option) {
        return variant.imageUrl;
      }
    }
    return null;
  }

  // Hiển thị ảnh toàn màn hình
  void _showFullScreenImage(String imageUrl) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              // Ảnh toàn màn hình
              Center(
                child: InteractiveViewer(
                  panEnabled: true,
                  boundaryMargin: const EdgeInsets.all(20),
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.asset(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 200,
                        height: 200,
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey[400],
                          size: 50,
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Nút đóng
              Positioned(
                top: 40,
                right: 20,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuantitySelector(ProductVariant variant) {
    final quantity = _quantities[variant.id] ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange[50]!, Colors.orange[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[200]!, width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.orange[500],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.shopping_cart,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Số lượng',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              if (quantity > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[500],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$quantity',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Chọn số lượng bạn muốn mua:',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Quantity controls với design đẹp hơn
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: quantity > 0 
                          ? () => _onQuantityChanged(variant, quantity - 1) 
                          : null,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: quantity > 0 ? Colors.red[50] : Colors.grey[100],
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                          ),
                        ),
                        child: Icon(
                          Icons.remove,
                          size: 18,
                          color: quantity > 0 ? Colors.red[600] : Colors.grey[400],
                        ),
                      ),
                    ),
                    Container(
                      width: 50,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.symmetric(
                          vertical: BorderSide(color: Colors.orange[200]!),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$quantity',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _onQuantityChanged(variant, quantity + 1),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                        child: Icon(
                          Icons.add,
                          size: 18,
                          color: Colors.green[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
