class ProductVariant {
  final String id;
  final Map<String, String> attributes; // {"Dung lượng": "512GB", "Màu sắc": "Vàng"}
  final int price;
  final int discount;
  final int stock;
  final bool isAvailable;
  final String? imageUrl; // URL hình ảnh của biến thể

  const ProductVariant({
    required this.id,
    required this.attributes,
    required this.price,
    required this.discount,
    required this.stock,
    this.isAvailable = true,
    this.imageUrl,
  });

  // Kiểm tra xem biến thể này có khớp với các thuộc tính đã chọn không
  bool matchesSelection(Map<String, String> selectedAttributes) {
    for (final entry in selectedAttributes.entries) {
      if (attributes[entry.key] != entry.value) {
        return false;
      }
    }
    return true;
  }

  // Kiểm tra xem biến thể này có khả dụng với một số thuộc tính đã chọn không
  bool isCompatibleWith(Map<String, String> partialSelection) {
    for (final entry in partialSelection.entries) {
      if (attributes.containsKey(entry.key) && attributes[entry.key] != entry.value) {
        return false;
      }
    }
    return true;
  }

  @override
  String toString() {
    return 'ProductVariant(id: $id, attributes: $attributes, price: $price)';
  }
}

class ProductVariantGroup {
  final String name;
  final List<String> options;
  final List<ProductVariant> variants;

  const ProductVariantGroup({
    required this.name,
    required this.options,
    required this.variants,
  });

  // Lấy các tùy chọn có sẵn dựa trên các lựa chọn hiện tại
  List<String> getAvailableOptions(Map<String, String> currentSelection) {
    final availableOptions = <String>{};
    
    for (final variant in variants) {
      if (variant.isCompatibleWith(currentSelection)) {
        final option = variant.attributes[name];
        if (option != null) {
          availableOptions.add(option);
        }
      }
    }
    
    return availableOptions.toList();
  }

  // Kiểm tra xem một tùy chọn có khả dụng không
  bool isOptionAvailable(String option, Map<String, String> currentSelection) {
    return getAvailableOptions(currentSelection).contains(option);
  }
}
