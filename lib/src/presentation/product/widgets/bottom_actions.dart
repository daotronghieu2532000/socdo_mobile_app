import 'package:flutter/material.dart';

class BottomActions extends StatelessWidget {
  final int price;
  final VoidCallback? onChat;
  final VoidCallback? onAddToCart;
  final VoidCallback? onBuyNow;

  const BottomActions({
    super.key,
    required this.price,
    this.onChat,
    this.onAddToCart,
    this.onBuyNow,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onChat,
              child: Container(
                height: 54,
                color: const Color(0xFF0FC6FF),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline, color: Colors.white, size: 18),
                      SizedBox(height: 2),
                      Text('Chat ngay', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: onAddToCart,
              child: Container(
                height: 54,
                color: const Color(0xFF00B2FF),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 18),
                      SizedBox(height: 2),
                      Text('Thêm vào giỏ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: onBuyNow,
              child: Container(
                height: 54,
                color: Colors.red,
                child: const Center(
                  child: Text('MUA NGAY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
