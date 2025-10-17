import 'package:flutter/foundation.dart';

class CartItem {
  final int id;
  final String name;
  final String image;
  final int price;
  final int? oldPrice;
  final int quantity;
  final String? variant;
  final int shopId;
  final String shopName;
  final DateTime addedAt;
  bool isSelected;

  CartItem({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    this.oldPrice,
    required this.quantity,
    this.variant,
    required this.shopId,
    required this.shopName,
    required this.addedAt,
    this.isSelected = true,
  });

  CartItem copyWith({
    int? id,
    String? name,
    String? image,
    int? price,
    int? oldPrice,
    int? quantity,
    String? variant,
    int? shopId,
    String? shopName,
    DateTime? addedAt,
    bool? isSelected,
  }) {
    return CartItem(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      price: price ?? this.price,
      oldPrice: oldPrice ?? this.oldPrice,
      quantity: quantity ?? this.quantity,
      variant: variant ?? this.variant,
      shopId: shopId ?? this.shopId,
      shopName: shopName ?? this.shopName,
      addedAt: addedAt ?? this.addedAt,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'price': price,
      'oldPrice': oldPrice,
      'quantity': quantity,
      'variant': variant,
      'shopId': shopId,
      'shopName': shopName,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      price: json['price'],
      oldPrice: json['oldPrice'],
      quantity: json['quantity'],
      variant: json['variant'],
      shopId: json['shopId'],
      shopName: json['shopName'],
      addedAt: DateTime.parse(json['addedAt']),
    );
  }
}

class CartService extends ChangeNotifier {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  int get totalPrice => _items.fold(0, (sum, item) => sum + (item.price * item.quantity));

  int get totalSavings => _items.fold(0, (sum, item) {
    if (item.oldPrice != null) {
      return sum + ((item.oldPrice! - item.price) * item.quantity);
    }
    return sum;
  });

  List<CartItem> get selectedItems => _items.where((item) => item.quantity > 0).toList();

  int get selectedItemCount => selectedItems.fold(0, (sum, item) => sum + item.quantity);

  int get selectedTotalPrice => selectedItems.fold(0, (sum, item) => sum + (item.price * item.quantity));

  // Group items by shop
  Map<int, List<CartItem>> get itemsByShop {
    final Map<int, List<CartItem>> grouped = {};
    for (final item in _items) {
      if (!grouped.containsKey(item.shopId)) {
        grouped[item.shopId] = [];
      }
      grouped[item.shopId]!.add(item);
    }
    return grouped;
  }

  // Add item to cart
  void addItem(CartItem item) {
    // Check if item already exists (same id and variant)
    final existingIndex = _items.indexWhere(
      (existing) => existing.id == item.id && existing.variant == item.variant,
    );

    if (existingIndex != -1) {
      // Update quantity if item exists
      _items[existingIndex] = _items[existingIndex].copyWith(
        quantity: _items[existingIndex].quantity + item.quantity,
      );
    } else {
      // Add new item
      _items.add(item);
    }

    notifyListeners();
  }

  // Remove item from cart
  void removeItem(int itemId, {String? variant}) {
    _items.removeWhere(
      (item) => item.id == itemId && item.variant == variant,
    );
    notifyListeners();
  }

  // Update item quantity
  void updateQuantity(int itemId, int quantity, {String? variant}) {
    if (quantity <= 0) {
      removeItem(itemId, variant: variant);
      return;
    }

    final index = _items.indexWhere(
      (item) => item.id == itemId && item.variant == variant,
    );

    if (index != -1) {
      _items[index] = _items[index].copyWith(quantity: quantity);
      notifyListeners();
    }
  }

  // Clear all items
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  // Clear items by shop
  void clearShopItems(int shopId) {
    _items.removeWhere((item) => item.shopId == shopId);
    notifyListeners();
  }

  // Remove specific item by CartItem object
  void removeCartItem(CartItem item) {
    _items.removeWhere((existing) => 
        existing.id == item.id && 
        existing.variant == item.variant &&
        existing.shopId == item.shopId);
    notifyListeners();
  }

  // Update item variant with price
  void updateItemVariant(CartItem item, String? newVariant, {int? newPrice, int? newOldPrice}) {
    final currentIndex = _items.indexWhere((existing) => 
        existing.id == item.id && 
        existing.variant == item.variant &&
        existing.shopId == item.shopId);
    
    if (currentIndex == -1) return;
    
    // Check if there's already an item with the new variant
    final existingVariantIndex = _items.indexWhere((existing) => 
        existing.id == item.id && 
        existing.variant == newVariant &&
        existing.shopId == item.shopId);
    
    if (existingVariantIndex != -1) {
      // Merge quantities and remove the current item
      _items[existingVariantIndex] = _items[existingVariantIndex].copyWith(
        quantity: _items[existingVariantIndex].quantity + item.quantity
      );
      _items.removeAt(currentIndex);
    } else {
      // Update the variant with new price and oldPrice
      _items[currentIndex] = _items[currentIndex].copyWith(
        variant: newVariant,
        price: newPrice ?? item.price,  // Sử dụng giá mới nếu có
        oldPrice: newOldPrice ?? item.oldPrice,  // Sử dụng giá cũ mới nếu có
      );
    }
    
    notifyListeners();
  }

  // Update item price and oldPrice
  void updateItemPrice(int itemId, int newPrice, int newOldPrice, {String? variant, int? shopId}) {
    final index = _items.indexWhere(
      (item) => item.id == itemId && 
                item.variant == variant &&
                (shopId == null || item.shopId == shopId),
    );

    if (index != -1) {
      _items[index] = _items[index].copyWith(
        price: newPrice,
        oldPrice: newOldPrice,
      );
      notifyListeners();
    }
  }

  // Check if item is in cart
  bool isInCart(int itemId, {String? variant}) {
    return _items.any(
      (item) => item.id == itemId && item.variant == variant,
    );
  }

  // Get item quantity in cart
  int getItemQuantity(int itemId, {String? variant}) {
    final item = _items.firstWhere(
      (item) => item.id == itemId && item.variant == variant,
      orElse: () => CartItem(
        id: 0,
        name: '',
        image: '',
        price: 0,
        quantity: 0,
        shopId: 0,
        shopName: '',
        addedAt: DateTime.now(),
      ),
    );
    return item.quantity;
  }
}
