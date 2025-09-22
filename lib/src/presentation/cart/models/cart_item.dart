class CartItem {
  final String title;
  final int price;
  final int? oldPrice;
  final String image;
  bool isSelected = true;
  int quantity = 1;
  
  CartItem({
    required this.title, 
    required this.price, 
    this.oldPrice, 
    required this.image
  });
}
