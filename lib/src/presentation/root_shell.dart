import 'package:flutter/material.dart';

import 'home/home_screen.dart';
import 'category/category_screen.dart';
import 'cart/cart_screen.dart';
import '../core/services/cart_service.dart' as cart_service;
import '../core/utils/format_utils.dart';
// import 'notifications/notifications_screen.dart';
import 'affiliate/affiliate_screen.dart';

class RootShell extends StatefulWidget {
  final int initialIndex;
  const RootShell({super.key, this.initialIndex = 0});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  late int _currentIndex = widget.initialIndex;
  final cart_service.CartService _cart = cart_service.CartService();

  // Tabs: Trang chủ, Danh mục, Affiliate
  final List<Widget> _tabs = const [
    HomeScreen(),
    CategoryScreen(),
    AffiliateScreen(),
  ];

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final bool selected = _currentIndex == index;
    final Color color = selected ? Colors.red : Colors.grey;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentIndex = index),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  color: color, 
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_currentIndex],
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: const BoxDecoration(color: Colors.white),
          padding: const EdgeInsets.only(left: 12, right: 0),
          child: Row(
            children: [
              // Các tab điều hướng
              Expanded(
                child: Row(
                  children: [
                    _buildNavItem(index: 0, icon: Icons.home_outlined, label: 'Trang chủ'),
                    _buildNavItem(index: 1, icon: Icons.grid_view_rounded, label: 'Danh mục'),
                    _buildNavItem(index: 2, icon: Icons.people_outline, label: 'Affiliate'),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Container cho phần giỏ hàng và nút đặt mua với nền riêng
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9ECEF), // Màu đậm hơn cho phần giỏ hàng
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      // Icon + nhãn Giỏ hàng hiển thị badge động
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const CartScreen()),
                          );
                        },
                        borderRadius: BorderRadius.circular(6),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                const Icon(
                                  Icons.shopping_cart_outlined,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                                Positioned(
                                  top: -4,
                                  right: -6,
                                  child: Container(
                                    width: 16,
                                    height: 16,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        _cart.itemCount.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Giỏ hàng',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                                height: 1.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Nút đặt mua chiếm phần còn lại, sát lề phải
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const CartScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 0, // Bỏ shadow để hòa hợp với container
                          ),
                          child: Text(
                            'Đặt mua (${_cart.selectedItemCount})\n${FormatUtils.formatCurrency(_cart.selectedTotalPrice)}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, height: 1.1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
/// Bottom bar có thể tái sử dụng ở các màn con
class RootShellBottomBar extends StatefulWidget {
  const RootShellBottomBar({super.key});

  @override
  State<RootShellBottomBar> createState() => _RootShellBottomBarState();
}

class _RootShellBottomBarState extends State<RootShellBottomBar> {
  final cart_service.CartService _cart = cart_service.CartService();

  @override
  void initState() {
    super.initState();
    _cart.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    _cart.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(color: Colors.white),
        padding: const EdgeInsets.only(left: 12, right: 0),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  _navItem(context, icon: Icons.home_outlined, label: 'Trang chủ', onTap: () => _openHome(context)),
                  _navItem(context, icon: Icons.grid_view_rounded, label: 'Danh mục', onTap: () => _openCategory(context)),
                  _navItem(context, icon: Icons.people_outline, label: 'Affiliate', onTap: () => _openAffiliate(context)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFE9ECEF), borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CartScreen())),
                      borderRadius: BorderRadius.circular(6),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              const Icon(Icons.shopping_cart_outlined, color: Colors.grey, size: 20),
                              Positioned(
                                top: -4,
                                right: -6,
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                  child: Center(
                                    child: Text(_cart.itemCount.toString(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          const Text('Giỏ hàng', style: TextStyle(color: Colors.grey, fontSize: 10, height: 1.0, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CartScreen())),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0),
                        child: Text('Đặt mua (${_cart.selectedItemCount})\n${FormatUtils.formatCurrency(_cart.selectedTotalPrice)}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, height: 1.1)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.grey, size: 20),
              const SizedBox(height: 3),
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w500, height: 1.0)),
            ],
          ),
        ),
      ),
    );
  }
  
  void _openHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const RootShell(initialIndex: 0)),
      (route) => false,
    );
  }
  
  void _openCategory(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const RootShell(initialIndex: 1)),
      (route) => false,
    );
  }
  
  void _openAffiliate(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const RootShell(initialIndex: 2)),
      (route) => false,
    );
  }
}

// removed unused placeholder screen


