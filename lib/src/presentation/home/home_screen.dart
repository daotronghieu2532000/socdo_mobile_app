import 'package:flutter/material.dart';
import 'widgets/home_app_bar.dart';
import 'widgets/slides_banner.dart';
import 'widgets/quick_actions.dart';
import 'widgets/flash_sale_section.dart';
import 'widgets/product_grid.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          const HomeAppBar(),
          Expanded(
            child: ListView(
              children: [
                // Banner slides
                const SlidesBanner(),
                const SizedBox(height: 8),
                
                // Quick actions
                Container(
                  color: Colors.white,
                  child: const QuickActions(),
                ),
                const SizedBox(height: 8),
                
                // Flash Sale section
                const FlashSaleSection(),
                const SizedBox(height: 8),
                
                // Suggested products grid
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(12),
                  child: const ProductGrid(title: 'Gợi ý cho bạn'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

