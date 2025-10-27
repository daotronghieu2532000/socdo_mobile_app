
import 'package:flutter/material.dart';
import 'widgets/home_app_bar.dart';
import 'widgets/quick_actions.dart';
import 'widgets/flash_sale_section.dart';
import 'widgets/product_grid.dart';
import 'widgets/mobile_banner_slider.dart';
import 'widgets/partner_banner_slider.dart';
import '../common/widgets/go_top_button.dart';
import '../../core/widgets/scroll_preservation_wrapper.dart';
import '../../core/services/cached_api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final CachedApiService _cachedApiService = CachedApiService();
  bool _isPreloading = true;

  @override
  void initState() {
    super.initState();
    _preloadData();
  }

  Future<void> _preloadData() async {
    try {
      // Preload tất cả dữ liệu cần thiết cho trang chủ
      print('🚀 Preloading home data...');
      
      await Future.wait([
        _cachedApiService.getHomeBanners(),
        _cachedApiService.getHomeFlashSale(),
        _cachedApiService.getHomePartnerBanners(),
        _cachedApiService.getHomeSuggestions(limit: 100),
      ]);
      
      print('✅ Home data preloaded successfully');
      
      if (mounted) {
        setState(() {
          _isPreloading = false;
        });
      }
    } catch (e) {
      print('❌ Error preloading home data: $e');
      if (mounted) {
        setState(() {
          _isPreloading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Hiển thị loading screen trong khi preload
    if (_isPreloading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return ScrollPreservationWrapper(
      tabIndex: 0, // Home tab
      scrollController: _scrollController,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Column(
              children: [
                const HomeAppBar(),
                Expanded(
                  child: ListView(
                    controller: _scrollController,
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
                        child: const ProductGrid(title: 'Gợi ý cho bạn'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Go Top Button
            GoTopButton(
              scrollController: _scrollController,
              showAfterScrollDistance: 1000.0, // Khoảng 2.5 màn hình
            ),
          ],
        ),
      ),
    );
  }
}


