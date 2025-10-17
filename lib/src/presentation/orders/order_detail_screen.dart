import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../core/services/auth_service.dart';

class OrderDetailScreen extends StatefulWidget {
  final int userId;
  final String? maDon;
  final int? orderId;
  const OrderDetailScreen({super.key, required this.userId, this.maDon, this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final ApiService _api = ApiService();
  final AuthService _auth = AuthService();
  bool _loading = true;
  Map<String, dynamic>? _detail;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await _api.getOrderDetail(
      userId: widget.userId,
      orderId: widget.orderId,
      maDon: widget.maDon,
    );
    if (!mounted) return;
    setState(() {
      _loading = false;
      _detail = data?['data']?['order'] as Map<String, dynamic>?;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết đơn hàng'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _detail == null
              ? const Center(child: Text('Không tìm thấy đơn hàng'))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Order Status Card with Icon
                      _buildStatusCard(),
                      const SizedBox(height: 12),
                      
                      // Shipping Info Card
                      _buildShippingCard(),
                      const SizedBox(height: 12),
                      
                      // Delivery Address Card
                      _buildAddressCard(),
                      const SizedBox(height: 12),
                      // Products Card
                      _buildProductsCard(),
                      const SizedBox(height: 12),
                      
                      // Payment Summary Card
                      _buildPaymentCard(),
                      const SizedBox(height: 16),
                      
                      // Action Buttons
                      if ((_detail!['status'] as int? ?? 0) <= 1)
                        _buildActionButtons(),
                    ],
                  ),
                ),
    );
  }

  // Modern Status Card with Icon and Color
  Widget _buildStatusCard() {
    final status = _detail!['status'] as int? ?? 0;
    final statusText = _detail!['status_text'] ?? '';
    final dateText = _detail!['date_post_formatted'] ?? '';
    
    Color statusColor;
    IconData statusIcon;
    
    switch (status) {
      case 0:
        statusColor = const Color(0xFFFF9500);
        statusIcon = Icons.schedule;
        break;
      case 1:
        statusColor = const Color(0xFF007AFF);
        statusIcon = Icons.check_circle_outline;
        break;
      case 2:
        statusColor = const Color(0xFF34C759);
        statusIcon = Icons.local_shipping;
        break;
      case 5:
        statusColor = const Color(0xFF34C759);
        statusIcon = Icons.check_circle;
        break;
      default:
        statusColor = const Color(0xFF8E8E93);
        statusIcon = Icons.info_outline;
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(statusIcon, color: statusColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trạng thái đơn hàng',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1D1D1F),
                  ),
                ),
              ],
            ),
          ),
          Text(
            dateText,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // Shipping Info Card
  Widget _buildShippingCard() {
    final provider = _detail!['shipping_provider'] ?? '—';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF007AFF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.local_shipping, color: Color(0xFF007AFF), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Đơn vị vận chuyển',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  provider,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1D1D1F),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Address Card
  Widget _buildAddressCard() {
    final address = _detail!['customer_info']?['full_address'] ?? '';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF34C759).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.location_on, color: Color(0xFF34C759), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Địa chỉ giao hàng',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  address,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1D1D1F),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Products Card
  Widget _buildProductsCard() {
    final products = (_detail!['products'] ?? []) as List;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9500).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.shopping_bag, color: Color(0xFFFF9500), size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Sản phẩm đã đặt',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1D1D1F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...products.map((pp) {
            final p = (pp as Map).cast<String, dynamic>();
            final String img = (p['image'] ?? '').toString();
            final String fixed = img.startsWith('http') ? img : (img.isEmpty ? '' : 'https://socdo.vn$img');
            final String variant = [p['color'], p['size']].where((e) => (e?.toString().isNotEmpty ?? false)).join(' • ');
            final int oldPrice = (p['old_price'] as int?) ?? 0;
            final String priceText = p['price_formatted'] ?? '';
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE9ECEF), width: 1),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      fixed,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 60,
                        height: 60,
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
                          p['name'] ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Color(0xFF1D1D1F),
                          ),
                        ),
                        if (variant.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            variant,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              priceText,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFFF6B35),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE3F2FD),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'x${p['quantity']}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1976D2),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      p['total_formatted'] ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1D1D1F),
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // Payment Summary Card
  Widget _buildPaymentCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF34C759).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.receipt, color: Color(0xFF34C759), size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Tổng kết đơn hàng',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1D1D1F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPaymentRow('Tạm tính', _detail!['tamtinh_formatted'] ?? '', isTotal: false),
          _buildPaymentRow('Phí vận chuyển', _detail!['phi_ship_formatted'] ?? '', isTotal: false),
          if ((_detail!['ship_support'] ?? 0) > 0)
            _buildPaymentRow('Phí hỗ trợ giao hàng', _detail!['ship_support_formatted'] ?? '', isTotal: false),
          
          // Voucher và giảm giá
          if ((_detail!['voucher_tmdt'] ?? 0) > 0)
            _buildVoucherRow('Voucher giảm giá', _detail!['voucher_tmdt_formatted'] ?? '', _detail!['coupon_code'] ?? ''),
          if ((_detail!['giam'] ?? 0) > 0)
            _buildPaymentRow('Giảm giá khác', _detail!['giam_formatted'] ?? '', isTotal: false),
          
          const Divider(height: 24),
          _buildPaymentRow('Tổng thanh toán', _detail!['tongtien_formatted'] ?? '', isTotal: true),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              color: isTotal ? const Color(0xFF1D1D1F) : Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
              color: isTotal ? const Color(0xFFFF6B35) : const Color(0xFF1D1D1F),
            ),
          ),
        ],
      ),
    );
  }

  // Voucher Row with Icon and Color
  Widget _buildVoucherRow(String label, String value, String couponCode) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F5FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE1D5F7), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF9C27B0).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.local_offer,
              color: Color(0xFF9C27B0),
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1D1D1F),
                  ),
                ),
                if (couponCode.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Mã: $couponCode',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            '-$value',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF9C27B0),
            ),
          ),
        ],
      ),
    );
  }

  // Action Buttons
  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _requestCancel,
              icon: const Icon(Icons.cancel_outlined, size: 18),
              label: const Text('Yêu cầu hủy đơn'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFFF3B30),
                side: const BorderSide(color: Color(0xFFFF3B30)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Future<void> _requestCancel() async {
    final user = await _auth.getCurrentUser();
    if (user == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        final ctrl = TextEditingController();
        return AlertDialog(
          title: const Text('Yêu cầu hủy đơn'),
          content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(hintText: 'Lý do (tuỳ chọn)')
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Đóng')),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Gửi yêu cầu')),
          ],
        );
      },
    );
    if (ok != true) return;
    final res = await _api.orderCancelRequest(
      userId: user.userId,
      maDon: _detail?['ma_don']?.toString(),
      reason: '',
    );
    if (mounted) {
      if (res?['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã gửi yêu cầu hủy')));
        _load();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Không thể hủy: ${res?['message'] ?? ''}')));
      }
    }
  }
}



