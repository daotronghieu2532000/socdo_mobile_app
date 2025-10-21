import 'package:flutter/material.dart';

class GoTopButton extends StatefulWidget {
  final ScrollController scrollController;
  final double showAfterScrollDistance;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? size;

  const GoTopButton({
    super.key,
    required this.scrollController,
    this.showAfterScrollDistance = 1000.0, // Khoảng 2.5 màn hình
    this.backgroundColor,
    this.iconColor,
    this.size,
  });

  @override
  State<GoTopButton> createState() => _GoTopButtonState();
}

class _GoTopButtonState extends State<GoTopButton>
    with SingleTickerProviderStateMixin {
  bool _isVisible = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    _animationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final scrollOffset = widget.scrollController.offset;
    final shouldShow = scrollOffset > widget.showAfterScrollDistance;
    
    if (shouldShow != _isVisible) {
      setState(() {
        _isVisible = shouldShow;
      });
      
      if (_isVisible) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  void _scrollToTop() {
    widget.scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) {
      return const SizedBox.shrink();
    }

    return Positioned(
      right: 16,
      bottom: 100, // Đặt cách bottom 100px để không che bottom navigation
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTap: _scrollToTop,
          child: Container(
            width: widget.size ?? 40, // Giảm từ 48 xuống 40
            height: widget.size ?? 40, // Giảm từ 48 xuống 40
            decoration: BoxDecoration(
              color: (widget.backgroundColor ?? Theme.of(context).colorScheme.primary).withOpacity(0.8), // Thêm độ mờ 0.8
              borderRadius: BorderRadius.circular(20), // Giảm từ 24 xuống 20
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15), // Giảm độ đậm của shadow
                  blurRadius: 6, // Giảm từ 8 xuống 6
                  offset: const Offset(0, 3), // Giảm từ 4 xuống 3
                ),
              ],
            ),
            child: Icon(
              Icons.keyboard_double_arrow_up,
              color: (widget.iconColor ?? Colors.white).withOpacity(0.9), // Thêm độ mờ cho icon
              size: (widget.size ?? 40) * 0.5, // Giảm từ 0.6 xuống 0.5
            ),
          ),
        ),
      ),
    );
  }
}
