import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/models/banner.dart';
import '../../../core/services/cached_api_service.dart';

class PartnerBannerSlider extends StatefulWidget {
  const PartnerBannerSlider({super.key});

  @override
  State<PartnerBannerSlider> createState() => _PartnerBannerSliderState();
}

class _PartnerBannerSliderState extends State<PartnerBannerSlider> {
  final CachedApiService _cachedApiService = CachedApiService();
  List<BannerModel> _banners = [];
  bool _isLoading = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadBanners();
  }

  Future<void> _loadBanners() async {
    try {
      // Sử dụng cached API service
      final bannersData = await _cachedApiService.getHomePartnerBanners();
      
      if (mounted && bannersData.isNotEmpty) {
        // Convert Map to BannerModel
        final banners = bannersData.map((data) => BannerModel.fromJson(data)).toList();
        
        setState(() {
          _banners = banners;
          _isLoading = false;
        });
        
        print('✅ Partner banners loaded successfully (${banners.length} banners)');
      } else {
        setState(() {
          _isLoading = false;
        });
        print('⚠️ No partner banners found');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      print('❌ Error loading partner banners: $e');
    }
  }

  Future<void> _handleBannerTap(BannerModel banner) async {
    if (banner.link.isNotEmpty) {
      try {
        final uri = Uri.parse(banner.link);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } catch (e) {
        // print('❌ Lỗi khi mở link banner: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 160,
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

    return Container(
      height: 160,
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
                  height: 160,
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
                            size: 40,
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
              height: 160,
              viewportFraction: 1.0,
              autoPlay: _banners.length > 1,
              autoPlayInterval: const Duration(seconds: 4),
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
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _banners.length,
                  (index) => Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
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
