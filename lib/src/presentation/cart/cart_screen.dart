import 'package:flutter/material.dart';
import '../../core/assets/app_images.dart';
import 'widgets/shop_section.dart';
import 'widgets/suggest_section.dart';
import 'widgets/bottom_checkout_bar.dart';
import 'widgets/counter_bubble.dart';
import 'models/shop_cart.dart';
import 'models/cart_item.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool selectAll = true;
  final List<ShopCart> shops = [
    ShopCart(
      name: 'German Goods',
      items: [
        CartItem(
          title:
              "Viên uống chống lão hoá, đẹp da Collagen Youtheory Type 1-2-3 - 390 viên của Mỹ",
          price: 880000,
          oldPrice: 900000,
          image: AppImages.products[0],
        ),
      ],
    ),
    ShopCart(
      name: 'VitaGlow',
      items: [
        CartItem(
          title: 'Viên uống Collagen Youtheory Type 1 2 & 3 của Mỹ, 390 viên',
          price: 615000,
          image: AppImages.products[1],
        ),
      ],
    ),
  ];

  int get selectedCount => shops
      .expand((s) => s.items)
      .where((i) => i.isSelected)
      .length;

  int get totalPrice => shops
      .expand((s) => s.items)
      .where((i) => i.isSelected)
      .fold(0, (sum, i) => sum + i.price * i.quantity);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Text('Giỏ hàng '),
            SizedBox(width: 4),
            CounterBubble(count: 2),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {}, 
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sửa'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          for (final shop in shops) ShopSection(shop: shop, onChanged: _onChanged),
          const SizedBox(height: 12),
          const SuggestSection(),
          const SizedBox(height: 100),
        ],
      ),
      bottomNavigationBar: BottomCheckoutBar(
        selectAll: selectAll,
        onToggleAll: (v) {
          setState(() {
            selectAll = v;
            for (final s in shops) {
              for (final i in s.items) {
                i.isSelected = v;
              }
            }
          });
        },
        totalPrice: totalPrice,
        selectedCount: selectedCount,
      ),
    );
  }

  void _onChanged() => setState(() {
        selectAll = shops
            .expand((s) => s.items)
            .every((element) => element.isSelected);
      });
}



