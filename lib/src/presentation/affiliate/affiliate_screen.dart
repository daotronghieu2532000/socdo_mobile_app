import 'package:flutter/material.dart';
import '../../core/models/affiliate_dashboard.dart';
import '../../core/services/affiliate_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/utils/format_utils.dart';
import '../auth/login_screen.dart';
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
          if (_currentUserId != null)
            IconButton(
              onPressed: _loadDashboard,
              icon: const Icon(Icons.refresh),
            ),
        ],
      ),
      body: _currentUserId == null
          ? _buildLoginPrompt()
          : _isLoading
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

  Widget _buildLoginPrompt() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE3F2FD),
            Color(0xFFF3E5F5),
            Color(0xFFFFF3E0),
          ],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              
              // Affiliate Banner
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                height: 280,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      // Background Image
                      Positioned.fill(
                        child: Image.asset(
                          'affiliate-marketing-15725072874221438636530.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF667eea),
                                    Color(0xFF764ba2),
                                    Color(0xFFf093fb),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.campaign,
                                  color: Colors.white,
                                  size: 80,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      // Overlay với content
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.2),
                                Colors.black.withOpacity(0.5),
                              ],
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
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
                                            '💰 Affiliate Marketing',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                            'Kiếm tiền từ việc chia sẻ sản phẩm',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(
                                                color: Colors.white.withOpacity(0.3),
                                              ),
                                            ),
                                            child: const Text(
                                              'Hoa hồng lên đến 10%',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.3),
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.trending_up,
                                        color: Colors.white,
                                        size: 32,
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

              const SizedBox(height: 40),

              // Login Section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.login,
                      size: 48,
                      color: Color(0xFF667eea),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Đăng nhập để bắt đầu',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Truy cập vào chương trình affiliate và kiếm tiền từ việc chia sẻ sản phẩm',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          ).then((result) {
                            // Reload user info after login
                            if (result == true) {
                              _initUser();
                            }
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF667eea),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.login, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Đăng nhập ngay',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Features
                    Row(
                      children: [
                        Expanded(
                          child: _buildFeatureItem(
                            Icons.share,
                            'Chia sẻ dễ dàng',
                            'Tạo link affiliate',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildFeatureItem(
                            Icons.account_balance_wallet,
                            'Rút tiền nhanh',
                            'Hoa hồng cao',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF667eea).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF667eea).withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: const Color(0xFF667eea),
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
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


}
