import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/models/banner.dart';
import '../../../core/services/cached_api_service.dart';
import '../../product/product_detail_screen.dart';

class MobileBannerSlider extends StatefulWidget {
  const MobileBannerSlider({super.key});

  @override
  State<MobileBannerSlider> createState() => _MobileBannerSliderState();
}

class _MobileBannerSliderState extends State<MobileBannerSlider> {
  final CachedApiService _cachedApiService = CachedApiService();
  List<BannerModel> _banners = [];
  bool _isLoading = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load ngay lập tức từ cache mà không gọi setState nhiều lần
    _loadBannersFromCache();
  }

  Future<void> _loadBannersFromCache() async {
    try {
      // Chỉ load từ cache, không gọi API
      final bannersData = await _cachedApiService.getHomeBanners();
      
      if (mounted) {
        if (bannersData.isNotEmpty) {
          // Convert Map to BannerModel
          final banners = bannersData.map((data) => BannerModel.fromJson(data)).toList();
          
          setState(() {
            _banners = banners;
            _isLoading = false;
          });
          
          // print('✅ Mobile banners loaded from cache (${banners.length} banners)');
        } else {
          // Fallback nếu không có cache
          setState(() {
            _isLoading = false;
          });
          // print('⚠️ No cached mobile banners');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      // print('❌ Error loading mobile banners from cache: $e');
    }
  }

  Future<void> _handleBannerTap(BannerModel banner) async {
    try {
      // Nếu có product_id từ API (đã join với sanpham), dùng trực tiếp
      if (banner.productId != null && banner.productId! > 0) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(
              productId: banner.productId,
            ),
          ),
        );
        return;
      }
      
      // Nếu không có product_id, parse từ link
      if (banner.link.isEmpty || banner.link.trim().isEmpty) return;
      
      final link = banner.link.trim();
      
      // Kiểm tra xem có phải link sản phẩm không
      if (link.startsWith('https://socdo.vn/product/') || link.startsWith('https://www.socdo.vn/product/')) {
        // Extract product ID from URL
        // Examples: 
        // - https://socdo.vn/product/123 (old format with ID)
        // - https://socdo.vn/product/slug.html (new format with slug)
        
        final uri = Uri.parse(link);
        final segments = uri.pathSegments;
        
        if (segments.isNotEmpty && segments[0] == 'product') {
          if (segments.length >= 2) {
            // Try to parse as ID (old format)
            final productId = int.tryParse(segments[1]);
            if (productId != null) {
              // Navigate to product detail screen with ID
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ProductDetailScreen(
                    productId: productId,
                  ),
                ),
              );
              return;
            }
            // If not ID, could be slug - you might need to implement slug lookup
            // For now, just open in browser
          }
        }
      }
      
      // Mở link khác bằng web browser
      final uri = Uri.parse(link);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // print('❌ Lỗi khi mở link banner: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 295,
        width: double.infinity,
        color: Colors.grey[200],
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_banners.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 295,
      width: double.infinity,
      child: Stack(
        children: [
          CarouselSlider.builder(
            itemCount: _banners.length,
            itemBuilder: (context, index, realIndex) {
              final banner = _banners[index];
              return GestureDetector(
                onTap: () => _handleBannerTap(banner),
                child: Container(
                  width: double.infinity,
                  height: 295,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      banner.image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                            size: 50,
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
            options: CarouselOptions(
              height: 295,
              viewportFraction: 1.0,
              autoPlay: _banners.length > 1,
              autoPlayInterval: const Duration(seconds: 3),
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              autoPlayCurve: Curves.fastOutSlowIn,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
          
          // Dots indicator
          if (_banners.length > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _banners.length,
                  (index) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentIndex == index 
                          ? Colors.white 
                          : Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
