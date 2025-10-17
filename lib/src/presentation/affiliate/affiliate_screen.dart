import 'package:flutter/material.dart';
import '../../core/models/affiliate_dashboard.dart';
import '../../core/services/affiliate_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/utils/format_utils.dart';
import 'affiliate_products_screen.dart';
import 'affiliate_links_screen.dart';
import 'affiliate_orders_screen.dart';
import 'affiliate_withdraw_screen.dart';
import 'commission_history_screen.dart';
import 'withdrawal_history_screen.dart';

class AffiliateScreen extends StatefulWidget {
  const AffiliateScreen({super.key});

  @override
  State<AffiliateScreen> createState() => _AffiliateScreenState();
}

class _AffiliateScreenState extends State<AffiliateScreen> {
  final AffiliateService _affiliateService = AffiliateService();
  final AuthService _authService = AuthService();
  AffiliateDashboard? _dashboard;
  bool _isLoading = true;
  String? _error;
  int _currentTabIndex = 0;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _initUser();
  }

  Future<void> _initUser() async {
    final user = await _authService.getCurrentUser();
    setState(() {
      _currentUserId = user?.userId;
    });
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final dashboard = await _affiliateService.getDashboard(userId: _currentUserId);
      print('📊 Dashboard loaded: $dashboard');
      
      if (mounted) {
        setState(() {
          _dashboard = dashboard;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Lỗi khi tải dữ liệu: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Affiliate'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _loadDashboard,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadDashboard,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : _dashboard == null
                  ? const Center(child: Text('Không có dữ liệu'))
                  : Column(
                      children: [
                        // Affiliate Marketing Banner
                        Container(
                          margin: const EdgeInsets.all(16),
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Stack(
                              children: [
                                // Background Image
                                Positioned.fill(
                                  child: Image.asset(
                                    'assets/images/affiliate-marketing-15725072874221438636530.jpg',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.purple[600]!,
                                              Colors.pink[500]!,
                                              Colors.orange[400]!,
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.image_not_supported,
                                            color: Colors.white,
                                            size: 48,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                // Overlay with content
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.black.withOpacity(0.3),
                                          Colors.black.withOpacity(0.6),
                                        ],
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Spacer(),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      '💰 Affiliate Program',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 20,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    const Text(
                                                      'Kiếm tiền từ việc chia sẻ',
                                                      style: TextStyle(
                                                        color: Colors.white70,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      'Tổng hoa hồng: ${FormatUtils.formatCurrency(_dashboard!.totalCommission.toInt())}',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: const Icon(
                                                  Icons.trending_up,
                                                  color: Colors.white,
                                                  size: 24,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Custom Tab Bar
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildCustomTab('Tổng quan', 0),
                              ),
                              Expanded(
                                child: _buildCustomTab('Quản lý', 1),
                              ),
                              Expanded(
                                child: _buildCustomTab('Lịch sử', 2),
                              ),
                            ],
                          ),
                        ),

                        // Tab Content
                        Expanded(
                          child: IndexedStack(
                            index: _currentTabIndex,
                            children: [
                              _buildOverviewTab(),
                              _buildManagementTab(),
                              _buildHistoryTab(),
                            ],
                          ),
                        ),
                      ],
                    ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Balance Cards
          // Only show one compact balance card
          Row(
            children: [
              Expanded(
                child: _buildSimpleCard(
                  'Có thể rút',
                  FormatUtils.formatCurrency(_dashboard!.withdrawableBalance.toInt()),
                  Colors.green,
                  Icons.account_balance_wallet,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AffiliateWithdrawScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Statistics
          Row(
            children: [
              Expanded(
                child: _buildSimpleCard(
                  'Lượt click',
                  _dashboard!.totalClicks.toString(),
                  Colors.blue,
                  Icons.mouse,
                  null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSimpleCard(
                  'Đơn hàng',
                  _dashboard!.totalOrders.toString(),
                  Colors.purple,
                  Icons.shopping_bag,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AffiliateOrdersScreen()),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildSimpleCard(
                  'Tỷ lệ chuyển đổi',
                  '${_dashboard!.conversionRate.toStringAsFixed(1)}%',
                  _dashboard!.conversionRate >= 3
                      ? Colors.green
                      : _dashboard!.conversionRate >= 1
                          ? Colors.orange
                          : Colors.red,
                  Icons.trending_up,
                  null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildManagementTab() {
    return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildMenuCard(
            Icons.inventory_2_outlined,
            'Sản phẩm Affiliate',
            'Tạo link chia sẻ sản phẩm',
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AffiliateProductsScreen()),
            ),
          ),
          const SizedBox(height: 12),
          _buildMenuCard(
            Icons.link,
            'Affiliate đang follow ✅',
            'Quản lý các sản phẩm đang theo dõi',
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AffiliateLinksScreen()),
            ),
          ),
          const SizedBox(height: 12),
          _buildMenuCard(
            Icons.receipt_long,
            'Đơn hàng',
            'Theo dõi đơn hàng & hoa hồng',
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AffiliateOrdersScreen()),
            ),
          ),
          const SizedBox(height: 12),
          _buildMenuCard(
            Icons.account_balance_wallet,
            'Rút tiền',
            'Tạo yêu cầu rút hoa hồng',
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AffiliateWithdrawScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildMenuCard(
            Icons.history,
            'Lịch sử hoa hồng',
            'Xem chi tiết hoa hồng đã nhận',
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CommissionHistoryScreen()),
            ),
          ),
          const SizedBox(height: 12),
          _buildMenuCard(
            Icons.account_balance,
            'Lịch sử rút tiền',
            'Theo dõi yêu cầu rút tiền',
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WithdrawalHistoryScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleCard(String title, String value, Color color, IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.purple[600],
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomTab(String text, int index) {
    final isSelected = _currentTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentTabIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.purple[600] : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildBannerStat(String title, String value, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard(String title, String value, Color color, IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
      ),
        child: Column(
        children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactStat(String title, String value, Color bgColor, Color textColor, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGrid() {
    final menuItems = [
      {
        'icon': Icons.inventory_2_outlined,
        'title': 'Sản phẩm',
        'subtitle': 'Tạo link',
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AffiliateProductsScreen()),
        ),
      },
      {
        'icon': Icons.link,
        'title': 'Links',
        'subtitle': 'Quản lý',
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AffiliateLinksScreen()),
        ),
      },
      {
        'icon': Icons.receipt_long,
        'title': 'Đơn hàng',
        'subtitle': 'Theo dõi',
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AffiliateOrdersScreen()),
        ),
      },
      {
        'icon': Icons.account_balance_wallet,
        'title': 'Rút tiền',
        'subtitle': 'Yêu cầu',
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AffiliateWithdrawScreen()),
        ),
      },
      {
        'icon': Icons.history,
        'title': 'Lịch sử',
        'subtitle': 'Hoa hồng',
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CommissionHistoryScreen()),
        ),
      },
      {
        'icon': Icons.account_balance,
        'title': 'Lịch sử',
        'subtitle': 'Rút tiền',
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const WithdrawalHistoryScreen()),
        ),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 4.0,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return GestureDetector(
          onTap: item['onTap'] as VoidCallback,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    color: Colors.blue[600],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item['title'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item['subtitle'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showClaimDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chuyển hoa hồng'),
        content: Text(
          'Bạn có ${FormatUtils.formatCurrency(_dashboard!.claimableAmount.toInt())} đã đủ điều kiện chuyển vào số dư có thể rút.\n\nBạn có muốn chuyển ngay không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              _claimCommission();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
              foregroundColor: Colors.white,
            ),
            child: const Text('Chuyển ngay'),
          ),
        ],
      ),
    );
  }

  Future<void> _claimCommission() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final result = await _affiliateService.claimCommission(userId: _currentUserId ?? 0);
      
      if (mounted) {
        Navigator.pop(context); // Close loading
        
        if (result != null && result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Chuyển hoa hồng thành công'),
              backgroundColor: Colors.green,
            ),
          );
          _loadDashboard(); // Reload dashboard
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result?['message'] ?? 'Chuyển hoa hồng thất bại'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
      ),
    );
  }
    }
  }
}
