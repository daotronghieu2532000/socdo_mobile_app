import 'package:flutter/material.dart';
import 'widgets/home_app_bar.dart';
import 'widgets/quick_actions.dart';
import 'widgets/flash_sale_section.dart';
import 'widgets/product_grid.dart';
import 'widgets/mobile_banner_slider.dart';
import 'widgets/partner_banner_slider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const HomeAppBar(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Mobile Banner - Full width, 295px height
                const MobileBannerSlider(),
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
                
                // Partner Banner - Below flash sale, 160px height
                const PartnerBannerSlider(),
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

