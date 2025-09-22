import 'package:flutter/material.dart';
import 'product_card_vertical.dart';

class ProductGrid extends StatelessWidget {
  final String title;
  const ProductGrid({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ),
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) => ProductCardVertical(index: index),
            separatorBuilder: (context, _) => const SizedBox(height: 0),
            itemCount: 6, // Hiển thị 6 sản phẩm
          ),
        ],
      ),
    );
  }
}
