import 'package:flutter/material.dart';
import '../../../core/models/product_detail.dart';
import '../../../core/utils/format_utils.dart';

class SmartVariantSelector extends StatefulWidget {
  final List<ProductVariant> variants;
  final Function(ProductVariant?) onVariantChanged;
  final Function(int quantity, ProductVariant variant) onQuantityChanged;

  const SmartVariantSelector({
    super.key,
    required this.variants,
    required this.onVariantChanged,
    required this.onQuantityChanged,
  });

  @override
  State<SmartVariantSelector> createState() => _SmartVariantSelectorState();
}

class _SmartVariantSelectorState extends State<SmartVariantSelector> {
  Map<String, String> _selectedAttributes = {};
  final Map<String, int> _quantities = {};
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeSelection();
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _initializeSelection() {
    if (_isDisposed || !mounted) return;
    if (widget.variants.isNotEmpty) {
      // Tự động chọn biến thể đầu tiên làm mặc định
      final firstVariant = widget.variants.first;
      _selectedAttributes = Map.from(firstVariant.attributes);
      _notifyVariantChanged();
    }
  }

  void _notifyVariantChanged() {
    if (_isDisposed || !mounted) return;
    final selectedVariant = _getSelectedVariant();
    widget.onVariantChanged(selectedVariant);
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
    
    // Nhóm các thuộc tính theo tên
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
    if (_isDisposed || !mounted) return;
    setState(() {
      _selectedAttributes[groupName] = option;
      _notifyVariantChanged();
    });
  }

  void _onQuantityChanged(ProductVariant variant, int quantity) {
    if (_isDisposed || !mounted) return;
    setState(() {
      _quantities[variant.id] = quantity;
    });
    widget.onQuantityChanged(quantity, variant);
  }

  @override
  Widget build(BuildContext context) {
    final variantGroups = _getVariantGroups();
    final selectedVariant = _getSelectedVariant();

    return Column(
      children: [
        // Hiển thị thông tin biến thể đã chọn
        if (selectedVariant != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Biến thể đã chọn:',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        selectedVariant.attributes.entries
                            .map((e) => '${e.key}: ${e.value}')
                            .join(', '),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  FormatUtils.formatCurrency(selectedVariant.price),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Hiển thị các nhóm thuộc tính
        ...variantGroups.map((group) => _buildAttributeGroup(group)),

        // Hiển thị quantity selector cho biến thể đã chọn
        if (selectedVariant != null) ...[
          const SizedBox(height: 12),
          _buildQuantitySelector(selectedVariant),
        ],
      ],
    );
  }

  Widget _buildAttributeGroup(ProductVariantGroup group) {
    final availableOptions = group.getAvailableOptions(_selectedAttributes);
    final currentSelection = _selectedAttributes[group.name];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          group.name,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: group.options.map((option) {
            final isAvailable = availableOptions.contains(option);
            final isSelected = currentSelection == option;
            
            return GestureDetector(
              onTap: isAvailable ? () => _onAttributeChanged(group.name, option) : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Colors.red 
                      : isAvailable 
                          ? Colors.white 
                          : Colors.grey[200],
                  border: Border.all(
                    color: isSelected 
                        ? Colors.red 
                        : isAvailable 
                            ? Colors.grey[400]! 
                            : Colors.grey[300]!,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isSelected 
                        ? Colors.white 
                        : isAvailable 
                            ? Colors.black87 
                            : Colors.grey[500],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildQuantitySelector(ProductVariant variant) {
    final quantity = _quantities[variant.id] ?? 0;

    return Row(
      children: [
        const Text(
          'Số lượng:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Row(
          children: [
            GestureDetector(
              onTap: quantity > 0 
                  ? () => _onQuantityChanged(variant, quantity - 1) 
                  : null,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: quantity > 0 ? Colors.grey : Colors.grey[300]!,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  Icons.remove,
                  size: 16,
                  color: quantity > 0 ? Colors.black87 : Colors.grey[400],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 40,
              height: 32,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              child: Center(
                child: Text(
                  '$quantity',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _onQuantityChanged(variant, quantity + 1),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.add,
                  size: 16,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
