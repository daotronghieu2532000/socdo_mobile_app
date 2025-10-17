import 'package:flutter/material.dart';
import 'dart:math';

class ProductCarousel extends StatefulWidget {
  final String title;
  final List<Widget> children;
  final int itemsPerPage;
  final double spacing;

  const ProductCarousel({
    super.key,
    required this.title,
    required this.children,
    this.itemsPerPage = 2,
    this.spacing = 12.0,
  });

  @override
  State<ProductCarousel> createState() => _ProductCarouselState();
}

class _ProductCarouselState extends State<ProductCarousel> {
  late PageController _pageController;
  int _currentPage = 0;
  late int _totalPages;

  @override
  void initState() {
    super.initState();
    _totalPages = (widget.children.length / widget.itemsPerPage).ceil();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pageController = PageController(
      viewportFraction: 1.0, // Full width for page-based navigation
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header with navigation buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), // Thêm vertical padding
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_totalPages > 1) ...[
                Row(
                  children: [
                    // Previous button
                    if (_currentPage > 0)
                      GestureDetector(
                        onTap: _previousPage,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.chevron_left,
                            size: 20,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    if (_currentPage > 0) const SizedBox(width: 8),
                    // Next button
                    if (_currentPage < _totalPages - 1)
                      GestureDetector(
                        onTap: _nextPage,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.chevron_right,
                            size: 20,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 0), // Bỏ hoàn toàn khoảng cách
        // Product carousel
        SizedBox(
          height: 360, // Tăng chiều cao để phù hợp với RelatedProductCard
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemCount: _totalPages,
            itemBuilder: (context, pageIndex) {
              final startIndex = pageIndex * widget.itemsPerPage;
              final endIndex = min(startIndex + widget.itemsPerPage, widget.children.length);
              final pageItems = widget.children.sublist(startIndex, endIndex);
              
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: pageItems.asMap().entries.map((entry) {
                    final index = entry.key;
                    final child = entry.value;
                    
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: index < pageItems.length - 1 ? widget.spacing : 0,
                        ),
                        child: child,
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
