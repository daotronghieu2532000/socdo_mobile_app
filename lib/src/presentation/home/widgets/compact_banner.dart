import 'package:flutter/material.dart';
import '../../../core/assets/app_images.dart';

class CompactBanner extends StatefulWidget {
  const CompactBanner({super.key});

  @override
  State<CompactBanner> createState() => _CompactBannerState();
}

class _CompactBannerState extends State<CompactBanner> {
  final PageController _controller = PageController(viewportFraction: 1);
  int _current = 0;

  final List<Map<String, dynamic>> _banners = [
    {
      'title': 'MUA CHUNG',
      'subtitle': 'MÙA HÈ RỰC LỬA, RINH DEAL THẢ CỬA',
      'image': AppImages.slides[0],
    },
    {
      'title': 'DEAL SỐC TỚI TẤP',
      'subtitle': 'DEAL SỐC TỚI TẤP CHỐT ĐƠN ẦM',
      'image': AppImages.slides[1],
    },
    {
      'title': 'SENDO FARM LIVE',
      'subtitle': 'SẢN PHẨM TƯƠI NGON MỖI NGÀY',
      'image': AppImages.slides[2],
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _autoSlide());
  }

  void _autoSlide() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;
      _current = (_current + 1) % _banners.length;
      _controller.animateToPage(
        _current,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160, // Tăng từ 120 lên 160 để tránh cắt nội dung
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: _banners.length,
            itemBuilder: (context, index) => _buildBannerCard(_banners[index]),
            onPageChanged: (i) => setState(() => _current = i),
          ),
          Positioned(
            bottom: 6,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _banners.length,
                (i) => Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == _current ? Colors.white : Colors.white54,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerCard(Map<String, dynamic> banner) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          banner['image'],
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stack) => Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: Text(
                'MUA CHUNG',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
