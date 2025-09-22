import 'package:flutter/material.dart';
import '../../../core/assets/app_images.dart';

class SlidesBanner extends StatefulWidget {
  const SlidesBanner({super.key});

  @override
  State<SlidesBanner> createState() => _SlidesBannerState();
}

class _SlidesBannerState extends State<SlidesBanner> {
  final PageController _controller = PageController(viewportFraction: 1);
  int _current = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _autoSlide());
  }

  void _autoSlide() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;
      _current = (_current + 1) % AppImages.slides.length;
      _controller.animateToPage(
        _current,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 7,
      child: Container(
        margin: const EdgeInsets.all(12),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xFFE9F1FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: AppImages.slides.length,
              itemBuilder: (context, index) => Image.asset(
                AppImages.slides[index],
                fit: BoxFit.cover,
              ),
              onPageChanged: (i) => setState(() => _current = i),
            ),
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  AppImages.slides.length,
                  (i) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
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
      ),
    );
  }
}
