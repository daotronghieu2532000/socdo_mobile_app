import 'package:flutter/material.dart';
import '../../core/models/affiliate_dashboard.dart';
import '../../core/services/affiliate_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/cached_api_service.dart';
import '../../core/utils/format_utils.dart';
import '../../core/widgets/scroll_preservation_wrapper.dart';
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
  final CachedApiService _cachedApiService = CachedApiService();
  AffiliateDashboard? _dashboard;
  bool _isLoading = true;
  String? _error;
  int _currentTabIndex = 0;
  int? _currentUserId;
  bool? _isAffiliateRegistered;
  bool _agreeToTerms = false;

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
    
    if (_currentUserId != null) {
      await _checkAffiliateStatus();
    }
    
    _loadDashboard();
  }

  Future<void> _checkAffiliateStatus() async {
    if (_currentUserId == null) return;
    
    try {
      final isRegistered = await _affiliateService.getUserAffiliateStatus(userId: _currentUserId!);
      if (mounted) {
        setState(() {
          _isAffiliateRegistered = isRegistered;
        });
      }
    } catch (e) {
      print('❌ Lỗi check affiliate status: $e');
    }
  }

  void _showAffiliateTermsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
            minHeight: 400,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Header - Cố định
              Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[200]!),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF667eea).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.description_outlined,
                        color: Color(0xFF667eea),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Điều khoản chương trình Affiliate',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1D1D1F),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, size: 20),
                    ),
                  ],
                ),
              ),
              
              // Content - Scroll được
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAffiliateTermsSection(
                        '1. ĐỊNH NGHĨA',
                        '1.1 "Số Dư Tài Khoản" có nghĩa là Phí Hoa Hồng cộng dồn chưa thanh toán đã đến hạn và có thể thanh toán cho Đối Tác Tiếp Thị Liên Kết.\n\n1.2 "Phương Tiện Tiếp Thị Liên Kết" có nghĩa là tất cả các phương tiện truyền thông, bao gồm nhưng không giới hạn ở các website, ứng dụng di động, cũng như các thư thông (newsletters), Đối Tác tiếp thị liên kết thứ cấp trong hệ thống của Đối Tác Tiếp Thị Liên Kết.\n\n1.3 "Đường Link Tiếp Thị Liên Kết" có nghĩa là các tài liệu truyền thông/quảng cáo được Đối Tác Tiếp Thị Liên Kết cung cấp cho Socdo.vn thông qua Chương Trình.',
                      ),
                      _buildAffiliateTermsSection(
                        '2. CÁC YÊU CẦU KHI THAM GIA CHƯƠNG TRÌNH',
                        '2.1 Thông tin đăng ký: Để phục vụ cho việc đăng ký tham gia Chương Trình, Đối Tác Tiếp Thị Liên Kết sẽ cung cấp bất kỳ thông tin nào được Socdo.vn yêu cầu và sẽ đảm bảo các thông tin đó là đúng, chính xác, và đầy đủ.\n\n2.2 Giấy Phép Hạn Chế: Socdo.vn cấp cho Đối Tác Tiếp Thị Liên Kết quyền thể hiện Đường Link Tiếp Thị Liên Kết trên Phương Tiện Tiếp Thị Liên Kết bằng chi phí của mình.\n\n2.3 Điều kiện tham gia: Phương Tiện Tiếp Thị Liên Kết phải được đăng tải công khai và truy cập được thông qua thông tin được cung cấp ở đơn đăng ký tham gia Chương Trình.',
                      ),
                      _buildAffiliateTermsSection(
                        '3. PHÍ HOA HỒNG VÀ ĐIỀU KHOẢN THANH TOÁN',
                        '3.1 Phí Hoa Hồng: Các loại phí mà Socdo.vn sẽ chi trả cho Đối Tác Tiếp Thị Liên Kết trong một tháng bất kỳ sẽ được tính theo mức được thể hiện ở website của Chương Trình.\n\n3.2 Cách Tính Phí Hoa Hồng: Phí Hoa Hồng cho một tháng bất kỳ sẽ được tính dựa trên Giá Trị Giao Dịch Thành Công Thuần nhân với Mức Phí Hoa Hồng.\n\n3.3 Chi Trả Tối Thiểu: Socdo.vn sẽ chi trả Số Dư Tài Khoản cho Đối Tác Tiếp Thị Liên Kết theo định kỳ hàng tháng, với điều kiện là Số Dư Tài Khoản vào ngày thanh toán đạt mức chi trả tối thiểu 200.000 VNĐ.',
                      ),
                      _buildAffiliateTermsSection(
                        '4. TRÁCH NHIỆM CỦA ĐỐI TÁC TIẾP THỊ LIÊN KẾT',
                        '4.1 Hành Xử Trong Kinh Doanh: Đối Tác Tiếp Thị Liên Kết sẽ không giao kết hợp đồng ràng buộc Socdo.vn hoặc đưa ra các tuyên bố hoặc bảo đảm thay mặt Socdo.vn.\n\n4.2 Tuân Thủ Quy Định Pháp Luật: Đối Tác Tiếp Thị Liên Kết sẽ đảm bảo Phương Tiện Tiếp Thị Liên Kết và việc đặt Đường Link Tiếp Thị Liên Kết tuân thủ tất cả các quy định pháp luật.\n\n4.3 Các Hành Động Bị Cấm: Không được sử dụng email quảng cáo, robot, các công cụ thao tác tự động, hoặc các phương pháp không trung thực.',
                      ),
                      _buildAffiliateTermsSection(
                        '5. QUYỀN VÀ NGHĨA VỤ CỦA SOCDO.VN',
                        '5.1 Nền Tảng: Socdo.vn sẽ vận hành và đảm bảo hoạt động của Nền Tảng.\n\n5.2 Quyền Hủy, Từ Chối, Gỡ Bỏ: Socdo.vn bảo lưu quyền xem xét bất kỳ Phương Tiện Tiếp Thị Liên Kết nào cũng như bất kỳ tài liệu liên quan nào do Đối Tác Tiếp Thị Liên Kết đệ trình.\n\n5.3 Thay Đổi Điều Khoản: Socdo.vn có thể cập nhật, sửa đổi, hoặc thay đổi các Điều Khoản và Điều Kiện này.',
                      ),
                      _buildAffiliateTermsSection(
                        '6. THÔNG TIN MẬT',
                        '6.1 Định nghĩa: "Thông Tin Mật" có nghĩa là tất cả các thông tin về bản chất là thông tin không công khai của một bên trong Thỏa Thuận này.\n\n6.2 Không Sử Dụng và Không Tiết Lộ: Mỗi bên sẽ bảo mật tất cả Thông Tin Mật của bên còn lại và không tiết lộ cho bất kỳ bên thứ ba nào.',
                      ),
                      _buildAffiliateTermsSection(
                        '7. THỜI HẠN VÀ CHẤM DỨT',
                        '7.1 Thời Hạn: Thỏa Thuận này có hiệu lực vào ngày mà Socdo.vn duyệt đăng ký tham gia Chương Trình Tiếp Thị Liên Kết.\n\n7.2 Chấm Dứt Bởi Socdo.vn: Socdo.vn có toàn quyền quyết định đơn phương chấm dứt Thỏa Thuận này bằng bất kỳ lý do gì mà Socdo.vn cho là hợp lý.\n\n7.3 Các Trường Hợp Chấm Dứt: Thỏa Thuận này sẽ chấm dứt ngay lập tức khi một bên thực hiện phá sản hoặc ngừng hoạt động kinh doanh.',
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Footer note
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE9ECEF),
                            width: 1,
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Color(0xFF6C757D),
                              size: 20,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Phiên bản này có hiệu lực kể từ ngày: 18/08/2025',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF6C757D),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAffiliateTermsSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1D1D1F),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6C757D),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _registerAffiliate() async {
    if (_currentUserId == null) return;
    
    // Check if user agreed to terms
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đồng ý với điều khoản chương trình Affiliate'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final result = await _affiliateService.registerAffiliate(userId: _currentUserId!);
      
      if (mounted) {
        if (result != null && result['success'] == true) {
          // Đăng ký thành công
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Đăng ký affiliate thành công'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
          
          // Cập nhật trạng thái và reload dashboard
          await _checkAffiliateStatus();
          await _loadDashboard();
        } else {
          // Đăng ký thất bại
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result?['message'] ?? 'Đăng ký affiliate thất bại'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi đăng ký affiliate: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Sử dụng cached API service cho dashboard
      final dashboardData = await _cachedApiService.getAffiliateDashboard(
        userId: _currentUserId,
      );
      
      // Xử lý dữ liệu từ cache hoặc API
      AffiliateDashboard? dashboard;
      
      if (dashboardData != null && dashboardData.isNotEmpty) {
        // Sử dụng dữ liệu từ cache
        print('💰 Using cached dashboard data');
        if (dashboardData['data'] != null) {
          dashboard = AffiliateDashboard.fromJson(dashboardData['data']);
        }
      } else {
        // Cache miss, gọi API trực tiếp
        print('🔄 Cache miss, fetching from AffiliateService...');
        dashboard = await _affiliateService.getDashboard(userId: _currentUserId);
        print('📊 Dashboard loaded: $dashboard');
      }
      
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
    return ScrollPreservationWrapper(
      tabIndex: 2, // Affiliate tab
      child: Scaffold(
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
            : _isAffiliateRegistered == false
                ? _buildAffiliateRegistrationPrompt()
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
                                                        '💰 TIẾP THỊ LIÊN KẾT',
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
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Affiliate Banner - Full width at top
              Container(
                width: double.infinity,
                height: 180,
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
                          'assets/images/affiliate-marketing-15725072874221438636530.jpg',
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
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            '💰 TIẾP THỊ LIÊN KẾT',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          const Text(
                                            'Kiếm tiền từ việc chia sẻ sản phẩm',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(16),
                                              border: Border.all(
                                                color: Colors.white.withOpacity(0.3),
                                              ),
                                            ),
                                            child: const Text(
                                              'hoa hồng lên đến 30%',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
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
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.3),
                                        ),
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

              const SizedBox(height: 24),

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
            'ĐANG THEO DÕI ✅',
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

  Widget _buildAffiliateRegistrationPrompt() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF667eea),
            Color(0xFF764ba2),
            Color(0xFFf093fb),
          ],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Affiliate Banner - Full width at top
              Container(
                width: double.infinity,
                height: 180,
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
                          'assets/images/affiliate-marketing-15725072874221438636530.jpg',
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
                      // Gradient Overlay
                      Container(
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
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
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
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        const Text(
                                          'Kiếm tiền từ việc chia sẻ sản phẩm',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(
                                              color: Colors.white.withOpacity(0.3),
                                            ),
                                          ),
                                          child: const Text(
                                            'hoa hồng lên đến 30%',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
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
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                      ),
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
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Registration Section
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [               
                    const SizedBox(height: 12),
                    _buildBenefitItem(
                      Icons.monetization_on,
                      'Hoa hồng cao',
                      'Nhận hoa hồng lên đến 30% từ mỗi đơn hàng',
                    ),
                    const SizedBox(height: 12),
                    _buildBenefitItem(
                      Icons.share,
                      'Dễ dàng chia sẻ',
                      'Tạo link affiliate chỉ với một cú click',
                    ),
                    const SizedBox(height: 12),
                    _buildBenefitItem(
                      Icons.trending_up,
                      'Theo dõi hiệu quả',
                      'Xem thống kê chi tiết về doanh thu',
                    ),
                    const SizedBox(height: 12),
                    _buildBenefitItem(
                      Icons.account_balance_wallet,
                      'Rút tiền nhanh',
                      'Rút tiền về tài khoản ngân hàng dễ dàng',
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Terms Checkbox
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                            value: _agreeToTerms,
                            onChanged: (value) {
                              setState(() {
                                _agreeToTerms = value ?? false;
                              });
                            },
                            activeColor: const Color(0xFF667eea),
                          ),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(color: Colors.black, fontSize: 14),
                                children: [
                                  const TextSpan(text: 'Tôi đồng ý với '),
                                  WidgetSpan(
                                    child: GestureDetector(
                                      onTap: () => _showAffiliateTermsDialog(context),
                                      child: const Text(
                                        'điều khoản chương trình Affiliate',
                                        style: TextStyle(
                                          color: Color(0xFF667eea),
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline,
                                          decorationColor: Color(0xFF667eea),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const TextSpan(text: ' của Socdo.vn'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Register Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _registerAffiliate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF667eea),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.person_add, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Đăng ký Affiliate ngay',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF667eea).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF667eea),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF718096),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


}
