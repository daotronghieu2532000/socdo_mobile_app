import 'package:flutter/material.dart';
import 'widgets/home_app_bar.dart';
import 'widgets/slides_banner.dart';
import 'widgets/quick_actions.dart';
import 'widgets/flash_sale_section.dart';
import 'widgets/compact_banner.dart';
import 'widgets/product_grid.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: const HomeAppBar(),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: const SlidesBanner()),
          SliverToBoxAdapter(child: const QuickActions()),
          SliverToBoxAdapter(child: const FlashSaleSection()),
          SliverToBoxAdapter(child: const CompactBanner()),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            sliver: const ProductGrid(title: 'Gợi ý dành cho bạn'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add chat functionality here
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
      ),
    );
  }
}




