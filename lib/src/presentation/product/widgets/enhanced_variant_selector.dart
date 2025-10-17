import 'package:flutter/material.dart';
import '../../../core/models/product_detail.dart';

class EnhancedVariantSelector extends StatefulWidget {
  final List<ProductVariant> variants;
  final ProductVariant? selectedVariant;
  final Function(ProductVariant) onVariantSelected;
  final int? currentPrice;
  final int? currentOldPrice;

  const EnhancedVariantSelector({
    super.key,
    required this.variants,
    this.selectedVariant,
    required this.onVariantSelected,
    this.currentPrice,
    this.currentOldPrice,
  });

  @override
  State<EnhancedVariantSelector> createState() => _EnhancedVariantSelectorState();
}

class _EnhancedVariantSelectorState extends State<EnhancedVariantSelector> {
  ProductVariant? _selectedVariant;

  @override
  void initState() {
    super.initState();
    _selectedVariant = widget.selectedVariant ?? 
        (widget.variants.isNotEmpty ? widget.variants.first : null);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.variants.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
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
          // Header với giá hiện tại
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Phân loại sản phẩm',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_selectedVariant != null) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${_selectedVariant!.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}₫',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    if (_selectedVariant!.oldPrice != null && _selectedVariant!.oldPrice! > _selectedVariant!.price)
                      Text(
                        '${_selectedVariant!.oldPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}₫',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          
          // Danh sách biến thể
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.variants.map((variant) {
              final isSelected = _selectedVariant?.id == variant.id;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedVariant = variant;
                  });
                  widget.onVariantSelected(variant);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.red.withOpacity(0.1) : Colors.grey[100],
                    border: Border.all(
                      color: isSelected ? Colors.red : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        variant.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? Colors.red : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${variant.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}₫',
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.red : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (variant.oldPrice != null && variant.oldPrice! > variant.price) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${variant.oldPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}₫',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          
          // Thông tin biến thể được chọn
          if (_selectedVariant != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Đã chọn: ${_selectedVariant!.name}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue[800],
                          ),
                        ),
                        if (_selectedVariant!.stock != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Còn lại: ${_selectedVariant!.stock} sản phẩm',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
