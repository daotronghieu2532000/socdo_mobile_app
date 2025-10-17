import 'package:flutter/material.dart';

class LeftMenuItem extends StatefulWidget {
  final String label;
  final String? imageUrl;
  final bool selected;
  final VoidCallback onTap;
  const LeftMenuItem({
    super.key,
    required this.label,
    required this.imageUrl,
    required this.selected,
    required this.onTap,
  });

  @override
  State<LeftMenuItem> createState() => _LeftMenuItemState();
}

class _LeftMenuItemState extends State<LeftMenuItem> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _animationController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _animationController.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  gradient: widget.selected 
                    ? LinearGradient(
                        colors: [
                          primaryColor.withOpacity(0.1),
                          primaryColor.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : _isHovered 
                      ? LinearGradient(
                          colors: [
                            Colors.grey.withOpacity(0.05),
                            Colors.grey.withOpacity(0.02),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: widget.selected 
                    ? null 
                    : _isHovered 
                      ? null 
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.selected 
                      ? primaryColor.withOpacity(0.3)
                      : _isHovered 
                        ? Colors.grey.withOpacity(0.2)
                        : Colors.transparent,
                    width: 1.5,
                  ),
                  boxShadow: widget.selected || _isHovered
                    ? [
                        BoxShadow(
                          color: widget.selected 
                            ? primaryColor.withOpacity(0.1)
                            : Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _buildCategoryImage(),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.label,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: widget.selected ? FontWeight.w600 : FontWeight.w500,
                        color: widget.selected 
                          ? primaryColor
                          : _isHovered 
                            ? Colors.grey[700]
                            : Colors.grey[600],
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryImage() {
    if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      // Build URL đầy đủ với domain socdo.vn
      String fullImageUrl = widget.imageUrl!;
      if (!fullImageUrl.startsWith('http')) {
        if (fullImageUrl.startsWith('/')) {
          fullImageUrl = 'https://socdo.vn$fullImageUrl';
        } else {
          fullImageUrl = 'https://socdo.vn/$fullImageUrl';
        }
      }
      
      return Image.network(
        fullImageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.grey[100]!,
                  Colors.grey[50]!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(
              Icons.category_outlined, 
              color: Colors.grey[400],
              size: 24,
            ),
          );
        },
      );
    }
    
    // Fallback icon
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey[100]!,
            Colors.grey[50]!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(
        Icons.category_outlined, 
        color: Colors.grey[400],
        size: 24,
      ),
    );
  }
}
