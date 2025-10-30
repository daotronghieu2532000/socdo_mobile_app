
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
  int _refreshKey = 0; // Key để trigger reload các widget con

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

  Future<void> _refreshData() async {
    try {
      print('🔄 Refreshing home data...');
      
      // Clear cache và load lại dữ liệu
      _cachedApiService.clearCachePattern('home_');
      
      await Future.wait([
        _cachedApiService.getHomeBanners(forceRefresh: true),
        _cachedApiService.getHomeFlashSale(forceRefresh: true),
        _cachedApiService.getHomePartnerBanners(forceRefresh: true),
        _cachedApiService.getHomeSuggestions(limit: 100, forceRefresh: true),
      ]);
      
      print('✅ Home data refreshed successfully');
      
      // Trigger reload các widget con bằng cách thay đổi refreshKey
      if (mounted) {
        setState(() {
          _refreshKey++;
        });
      }
    } catch (e) {
      print('❌ Error refreshing home data: $e');
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
                  child: RefreshIndicator(
                    onRefresh: _refreshData,
                    child: ListView(
                      controller: _scrollController,
                      padding: EdgeInsets.zero,
                      children: [
                        // Mobile Banner - Full width, 295px height
                        MobileBannerSlider(key: ValueKey('mobile_banner_$_refreshKey')),
                        const SizedBox(height: 8),
                        
                        // Quick actions
                        Container(
                          color: Colors.white,
                          child: const QuickActions(),
                        ),
                        const SizedBox(height: 8),
                        
                        // Flash Sale section
                        FlashSaleSection(key: ValueKey('flash_sale_$_refreshKey')),
                        const SizedBox(height: 8),
                        
                        // Partner Banner - Below flash sale, 160px height
                        PartnerBannerSlider(key: ValueKey('partner_banner_$_refreshKey')),
                        const SizedBox(height: 8),
                        
                        // Suggested products grid
                        Container(
                          color: Colors.white,
                          child: ProductGrid(key: ValueKey('product_grid_$_refreshKey'), title: 'Gợi ý cho bạn'),
                        ),
                      ],
                    ),
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


