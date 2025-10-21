import 'package:flutter/material.dart';
import 'dart:async';
import '../../core/services/api_service.dart';
import '../../core/services/auth_service.dart';
import '../root_shell.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatefulWidget {
  final int initialIndex;
  const OrdersScreen({super.key, this.initialIndex = 0});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final AuthService _auth = AuthService();

  int? _userId;
  List<int> _counts = [0, 0, 0, 0, 0];
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this, initialIndex: widget.initialIndex);
    _init();
  }

  Future<void> _init() async {
    final loggedIn = await _auth.isLoggedIn();
    if (!mounted) return;
    if (!loggedIn) {
      setState(() => _userId = null);
    } else {
      final user = await _auth.getCurrentUser();
      if (!mounted) return;
      setState(() => _userId = user?.userId);
      if (_userId != null) {
        await _loadCounts();
        _pollTimer?.cancel();
        _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) => _loadCounts());
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadCounts() async {
    if (_userId == null) return;
    final api = ApiService();
    final data = await api.getOrdersList(
      userId: _userId!,
      page: 1,
      limit: 100,
      status: null,
    );
    final orders = (data?['data']?['orders'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    int c0 = 0, c1 = 0, c2 = 0, c3 = 0, c4 = 0;
    for (final o in orders) {
      final s = (o['status'] ?? o['trangthai']) as int?;
      if (s == null) continue;
      if ([0, 1].contains(s)) {
        c0++;
      } else if ([11, 10, 12].contains(s)) c1++;
      else if ([2, 8, 9, 7, 14].contains(s)) c2++;
      else if ([5].contains(s)) c3++;
      else if ([3, 4, 6].contains(s)) c4++; // Đơn hàng hủy
    }
    if (!mounted) return;
    setState(() {
      _counts = [c0, c1, c2, c3, c4];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đơn hàng của tôi'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
            child: SizedBox(
              height: 80,
              child: Stack(
                children: [
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    indicatorPadding: const EdgeInsets.symmetric(horizontal: 8),
                    tabs: [
                      _OrderTab(icon: Icons.receipt_long, label: 'Chờ xác nhận', count: _counts[0]),
                      _OrderTab(icon: Icons.store_mall_directory, label: 'Chờ lấy hàng', count: _counts[1]),
                      _OrderTab(icon: Icons.local_shipping, label: 'Chờ giao hàng', count: _counts[2]),
                      _OrderTab(icon: Icons.reviews, label: 'Đánh giá', count: _counts[3]),
                      _OrderTab(icon: Icons.cancel, label: 'Đã hủy', count: _counts[4]),
                    ],
                  ),
                  // Gradient fade effect để chỉ ra có thể cuộn
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 30,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.white.withOpacity(0.0),
                            Colors.white.withOpacity(0.8),
                          ],
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.chevron_right,
                          color: Colors.grey,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ),
      ),
      body: _userId == null
          ? _LoggedOutView()
          : TabBarView(
              controller: _tabController,
              children: [
                _OrdersList(statusGroup: const [0, 1], userId: _userId!),
                _OrdersList(statusGroup: const [1, 11, 10, 12], userId: _userId!),
                _OrdersList(statusGroup: const [2, 8, 9, 7, 14], userId: _userId!),
                _OrdersList(statusGroup: const [5], userId: _userId!),
                _OrdersList(statusGroup: const [3, 4, 6], userId: _userId!),
              ],
            ),
      bottomNavigationBar: const RootShellBottomBar(),
    );
  }
}

class _OrderTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final int? count;
  const _OrderTab({required this.icon, required this.label, this.count});

  @override
  Widget build(BuildContext context) {
    final hasCount = count != null && count! > 0;
    return Tab(
      height: 70,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, size: 24),
                if (hasCount)
                  Positioned(
                    right: -8,
                    top: -8,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        (count! > 99) ? '99+' : '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _OrdersList extends StatefulWidget {
  final int userId;
  final List<int> statusGroup;
  const _OrdersList({required this.userId, required this.statusGroup});

  @override
  State<_OrdersList> createState() => _OrdersListState();
}

class _OrdersListState extends State<_OrdersList> {
  final ApiService _api = ApiService();
  bool _loading = true;
  List<dynamic> _orders = [];
  int _page = 1;
  final int _limit = 50; // Tăng từ 20 lên 50
  final ScrollController _scrollController = ScrollController();
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _load(refresh: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_hasMore || _loading) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
    _load();
    }
  }

  Future<void> _load({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _loading = true;
        _page = 1;
        _hasMore = true;
      });
    } else {
    setState(() => _loading = true);
    }

    // Gọi API không filter, sau đó lọc theo nhóm trạng thái giống Shopee
    final data = await _api.getOrdersList(
      userId: widget.userId,
      page: _page,
      limit: _limit,
      status: null,
    );
    if (!mounted) return;

    final fetched = (data?['data']?['orders'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    // Lọc theo nhóm
    final filtered = fetched.where((o) {
      final s = (o['status'] ?? o['trangthai']) as int?;
      return s != null && widget.statusGroup.contains(s);
    }).toList();

    setState(() {
      if (refresh) {
        _orders = filtered;
      } else {
        _orders.addAll(filtered);
      }
      _loading = false;
      _hasMore = fetched.length >= _limit;
      if (_hasMore) _page += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_orders.isEmpty) {
      return const Center(child: Text('Chưa có đơn hàng'));
    }
    return RefreshIndicator(
      onRefresh: () => _load(refresh: true),
      child: ListView.separated(
        controller: _scrollController,
        itemCount: _orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        padding: const EdgeInsets.all(12),
        itemBuilder: (context, index) {
          final o = _orders[index] as Map<String, dynamic>;
          return _buildOrderCard(o);
        },
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> o) {
    final List products = (o['products'] as List?) ?? [];
    final Map<String, dynamic>? first = products.isNotEmpty ? (products.first as Map).cast<String, dynamic>() : null;
    final int count = _toInt(o['product_count']) ?? products.length;
    final Color statusColor = _statusColor(_toInt(o['status']));
    final String shopName = first?['shop_name']?.toString() ?? '';
    final String etaText = o['delivery_eta_text']?.toString() ?? '';
    return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OrderDetailScreen(
                    userId: widget.userId,
                    maDon: o['ma_don'],
              orderId: _toInt(o['id']),
                  ),
                ),
              );
            },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFEAEAEA)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: shop + status chip
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        if (shopName.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF1F0),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('Shop', style: TextStyle(fontSize: 10, color: Color(0xFFF5222D), fontWeight: FontWeight.w600)),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              shopName,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ]
                        else
                          Expanded(
                            child: Text(
                              o['ma_don'] ?? '',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      o['status_text'] ?? '',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Product summary row (image + info)
              _buildProductSummary(first, count),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text('Tổng số tiền: ', style: TextStyle(fontSize: 12, color: Color(0xFF6C757D))),
                  Text(
                    _formatPrice(o['tongtien_formatted'] ?? ''),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFFFF6B35)),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right, color: Color(0xFFB0B0B0))
                ],
              ),
              // Show shipping fee if available
              if ((o['phi_ship'] ?? 0) > 0) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Text('Phí vận chuyển: ', style: TextStyle(fontSize: 12, color: Color(0xFF6C757D))),
                    Text(
                      _formatPrice(o['phi_ship_formatted'] ?? ''),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1976D2)),
                    ),
                    const Spacer(),
                  ],
                ),
              ],
              // Show voucher info if available
              if ((o['voucher_tmdt'] ?? 0) > 0) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F5FF),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFE1D5F7), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_offer, size: 14, color: Color(0xFF9C27B0)),
                      const SizedBox(width: 4),
                      Text(
                        'Đã áp voucher: -${_formatPrice(o['voucher_tmdt_formatted'] ?? '')}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF9C27B0)),
                      ),
                    ],
                  ),
                ),
              ],
              // Show delivery ETA if available, otherwise show last update
              if ((etaText.isNotEmpty) || (o['delivery_eta_text'] ?? '').toString().isNotEmpty || (o['date_update_formatted'] ?? '').toString().isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F7FF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFBAE7FF)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_shipping, size: 16, color: Color(0xFF1890FF)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          etaText.isNotEmpty
                              ? 'Thời gian giao dự kiến: $etaText'
                              : (o['delivery_eta_text'] ?? '').toString().isNotEmpty
                                  ? 'Thời gian giao dự kiến: ${o['delivery_eta_text']}'
                                  : 'Cập nhật: ${o['date_update_formatted']?.toString() ?? ''}',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF1890FF), fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductSummary(Map<String, dynamic>? first, int count) {
    if (first == null) {
      return const SizedBox.shrink();
    }
    final String img = (first['image'] ?? '').toString();
    final String fixed = img.startsWith('http') ? img : (img.isEmpty ? '' : 'https://socdo.vn$img');
    final String title = (first['name'] ?? '').toString();
    final String variant = [first['color'], first['size']].where((e) => (e?.toString().isNotEmpty ?? false)).join(' • ');
    final int price = (first['price'] as int?) ?? 0;
    final int total = (first['total'] as int?) ?? price;
    final int oldPrice = (first['old_price'] as int?) ?? 0;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            fixed,
            width: 64,
            height: 64,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 64,
              height: 64,
              color: const Color(0xFFF5F5F5),
              child: const Icon(Icons.image_not_supported, size: 20, color: Color(0xFF999999)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
              ),
              if (variant.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(variant, style: const TextStyle(fontSize: 12, color: Color(0xFF6C757D))),
              ],
              const SizedBox(height: 6),
              Row(
                children: [
                  if (oldPrice > 0 && oldPrice > price) ...[
                    Text(
                      _formatCurrency(oldPrice),
                      style: const TextStyle(fontSize: 12, color: Color(0xFF999999), decoration: TextDecoration.lineThrough),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    _formatCurrency(price),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFFFF6B35)),
                  ),
                  const SizedBox(width: 8),
                  Text('x$count', style: const TextStyle(fontSize: 12, color: Color(0xFF6C757D))),
                  const Spacer(),
                  Text(_formatCurrency(total), style: const TextStyle(fontSize: 12, color: Color(0xFF333333))),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatCurrency(int v) {
    return '${_group(v)}đ';
  }

  String _group(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  // Helper function to format price from comma to dot
  String _formatPrice(String priceText) {
    return priceText.replaceAll(',', '.');
  }

  Color _statusColor(int? status) {
    switch (status) {
      case 0:
      case 1:
        return const Color(0xFFFA8C16); // pending
      case 11:
      case 10:
      case 12:
        return const Color(0xFF1890FF); // pickup
      case 2:
      case 8:
      case 9:
      case 7:
      case 14:
        return const Color(0xFF722ED1); // shipping
      case 5:
        return const Color(0xFF52C41A); // delivered
      case 6:
        return const Color(0xFFF5222D); // returned
      default:
        return const Color(0xFF6C757D);
    }
  }

  int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is String) return int.tryParse(v);
    return null;
  }
}

class _LoggedOutView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background Image with opacity
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('lib/src/core/assets/images/logo_socdo.png'),
              fit: BoxFit.cover,
              opacity: 0.15, // Mờ mờ cho đẹp
            ),
          ),
        ),
        // Subtle overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withOpacity(0.8),
                Colors.white.withOpacity(0.9),
              ],
            ),
          ),
        ),
        // Content
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo/Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  size: 40,
                  color: Color(0xFFDC3545),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Bạn chưa đăng nhập',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Đăng nhập để xem đơn hàng của bạn',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 40),
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFDC3545),
                      Color(0xFFC82333),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFDC3545).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Đăng nhập',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


