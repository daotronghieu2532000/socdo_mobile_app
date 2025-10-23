import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/cart_service.dart' as cart_service;
import '../../../core/services/shipping_events.dart';
import '../../../core/services/shipping_quote_store.dart';

class OrderSummarySection extends StatefulWidget {
  const OrderSummarySection({super.key});

  @override
  State<OrderSummarySection> createState() => _OrderSummarySectionState();
}

class _OrderSummarySectionState extends State<OrderSummarySection> {
  final _api = ApiService();
  final _auth = AuthService();
  int? _shipFee;
  String? _etaText;
  String? _provider;
  bool _hasFreeshipAvailable = false;
  StreamSubscription<void>? _shipSub;

  @override
  void initState() {
    super.initState();
    _load();
    // Lắng nghe sự kiện cần tính lại phí ship khi đổi địa chỉ
    _shipSub = ShippingEvents.stream.listen((_) {
      if (!mounted) return;
      _load();
    });
  }

  @override
  void dispose() {
    _shipSub?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final u = await _auth.getCurrentUser();
    if (u == null) return;
    // Chuẩn bị danh sách items trong giỏ
    final cart = cart_service.CartService();
    final items = cart.items
        .map((i) => {
              'product_id': i.id,
              'quantity': i.quantity,
            })
        .toList();
    if (items.isEmpty) {
      // debug khi giỏ rỗng sẽ không gọi API
      // bỏ comment nếu cần thấy log trên console
      // ignore: avoid_print
      print('🛒 cart empty -> skip shipping quote');
      return;
    }
    // debug input gửi server
    // ignore: avoid_print
    print('🧮 shipping input items: $items');
    // Call server to compute shipping. Server uses class_ghtk + class_superai,
    // evaluates all providers and returns the cheaper one with an ETA text.
    final rawQuote = await _api.getShippingQuote(userId: u.userId, items: items);
    if (!mounted) return;
    setState(() {
      // Robust parse of dynamic 'fee' (can be int/num/string)
      final dynamic feeDyn = rawQuote?['fee'];
      int? parsedFee;
      if (feeDyn is int) {
        parsedFee = feeDyn;
      } else if (feeDyn is num) {
        parsedFee = feeDyn.toInt();
      } else if (feeDyn is String) {
        // Remove non-digits just in case server returns formatted string
        final onlyDigits = feeDyn.replaceAll(RegExp(r'[^0-9]'), '');
        parsedFee = int.tryParse(onlyDigits);
      }
      _shipFee = parsedFee ?? 0;
      _etaText = rawQuote?['eta_text']?.toString();
      _provider = rawQuote?['provider']?.toString();
      
      // Check if there's freeship available using raw API response
      _checkFreeshipAvailability(rawQuote);
      
      // Lưu vào store dùng chung cho các section khác (PaymentDetails, Bottom bar)
      ShippingQuoteStore().setQuote(
        fee: _shipFee!,
        etaText: _etaText,
        provider: _provider,
      );
    });
  }

  void _checkFreeshipAvailability(Map<String, dynamic>? quote) {
    try {
      _hasFreeshipAvailable = false;
      
      print('🔍 _checkFreeshipAvailability called with quote: $quote');
      
      if (quote != null) {
        print('🔍 Quote is not null');
        
        // Debug info is directly in quote['debug'] (not in quote['data']['debug'])
        final debug = quote['debug'];
        print('🔍 Debug from quote: $debug');
        
        if (debug != null) {
          final shopFreeshipDetails = debug['shop_freeship_details'] as Map<String, dynamic>?;
          print('🔍 DEBUG: shopFreeshipDetails = $shopFreeshipDetails');
          if (shopFreeshipDetails != null && shopFreeshipDetails.isNotEmpty) {
            print('🔍 DEBUG: Found ${shopFreeshipDetails.length} shops with freeship config');
            // Check if any shop has freeship config (regardless of applied status)
            for (final entry in shopFreeshipDetails.entries) {
              final config = entry.value as Map<String, dynamic>;
              final mode = config['mode'] as int? ?? 0;
              final discount = (config['discount'] as num?)?.toDouble() ?? 0.0;
              
              print('🔍 DEBUG: Shop ${entry.key}: mode=$mode, discount=$discount');
              
              // If there's any freeship config (mode >= 0 and discount > 0), show button
              if (mode >= 0 && discount > 0) {
                print('🔍 DEBUG: Found freeship config! Setting _hasFreeshipAvailable = true');
                _hasFreeshipAvailable = true;
                break;
              }
            }
          } else {
            print('🔍 DEBUG: No shop freeship details found');
          }
        } else {
          print('🔍 DEBUG: Debug is null');
        }
      } else {
        print('🔍 Quote is null');
      }
      
      print('🔍 FREESHIP AVAILABILITY CHECK: $_hasFreeshipAvailable');
    } catch (e) {
      print('🔍 ERROR in _checkFreeshipAvailability: $e');
      _hasFreeshipAvailable = false;
    }
  }

  void _showFreeshipDialog(BuildContext context) async {
    // Sử dụng dữ liệu đã có từ _checkFreeshipAvailability thay vì gọi API lại
    print('🔍 FREESHIP DIALOG DEBUG:');
    print('  - _hasFreeshipAvailable: $_hasFreeshipAvailable');
    
    if (!_hasFreeshipAvailable) {
      print('  - No freeship available, not showing dialog');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sản phẩm này không có ưu đãi vận chuyển')),
      );
      return;
    }
    
    // Lấy thông tin freeship từ shipping quote
    final u = await _auth.getCurrentUser();
    if (u == null) return;
    
    final cart = cart_service.CartService();
    final items = cart.items
        .map((i) => {
              'product_id': i.id,
              'quantity': i.quantity,
            })
        .toList();
    
    if (items.isEmpty) return;
    
    print('  - Items: $items');
    
    Map<String, dynamic>? shopFreeshipDetails;
    
    try {
      final quote = await _api.getShippingQuote(userId: u.userId, items: items);
      print('  - Quote response: ${quote != null ? "Success" : "Failed"}');
      
      if (quote != null) {
        final debug = quote['debug'];
        print('  - Debug available: ${debug != null}');
        
        if (debug != null) {
          shopFreeshipDetails = debug['shop_freeship_details'] as Map<String, dynamic>?;
          print('  - Shop freeship details: ${shopFreeshipDetails?.keys.toList()}');
          
          if (shopFreeshipDetails != null) {
            for (final entry in shopFreeshipDetails.entries) {
              print('    Shop ${entry.key}: ${entry.value}');
            }
          } else {
            print('  - shop_freeship_details is null in debug');
          }
        } else {
          print('  - Debug is null');
        }
      } else {
        print('  - Quote failed');
      }
    } catch (e) {
      print('  - Error getting quote: $e');
    }
    
    // Only show dialog if there's actual freeship data
    if (shopFreeshipDetails == null || shopFreeshipDetails.isEmpty) {
      print('  - No freeship data available, not showing dialog');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sản phẩm này không có ưu đãi vận chuyển')),
      );
      return;
    }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
            minHeight: 300,
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
              // Header
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
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.local_shipping,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Ưu đãi vận chuyển',
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
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Debug info
                    
                      const SizedBox(height: 16),
                      
                      if (shopFreeshipDetails != null && shopFreeshipDetails.isNotEmpty) ...[
                    
                        for (final entry in shopFreeshipDetails.entries) ...[
                          _buildFreeshipInfo(entry.key, entry.value),
                          const SizedBox(height: 16),
                        ],
                      ] else ...[
                        Text('❌ No freeship details found', 
                             style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                        const SizedBox(height: 16),
                        const Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 48,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Hiện tại chưa có ưu đãi vận chuyển nào',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      
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
                              Icons.tips_and_updates,
                              color: Color(0xFF28A745),
                              size: 20,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Thêm sản phẩm vào giỏ hàng để được hưởng ưu đãi vận chuyển tốt nhất.',
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

  Widget _buildFreeshipInfo(String shopId, Map<String, dynamic> config) {
    final mode = config['mode'] as int? ?? 0;
    final subtotal = config['subtotal'] as int? ?? 0;
    final minOrder = config['min_order'] as int? ?? 0;
    final discount = (config['discount'] as num?)?.toDouble() ?? 0.0;
    final applied = config['applied'] as bool? ?? false;
    
    String title = '';
    String description = '';
    Color statusColor = Colors.grey;
    
    switch (mode) {
      case 0:
        title = 'Giảm phí ship cố định';
        description = 'Giảm ${_formatCurrency(discount.toInt())} phí ship';
        statusColor = applied ? Colors.green : Colors.orange;
        break;
      case 1:
        title = 'Miễn phí ship 100%';
        description = 'Miễn phí ship toàn bộ đơn hàng';
        statusColor = applied ? Colors.green : Colors.orange;
        break;
      case 2:
        title = 'Giảm phí ship theo %';
        description = 'Giảm ${discount.toInt()}% phí ship';
        statusColor = applied ? Colors.green : Colors.orange;
        break;
      case 3:
        title = 'Miễn phí ship theo sản phẩm';
        description = 'Miễn phí ship cho sản phẩm cụ thể';
        statusColor = applied ? Colors.green : Colors.orange;
        break;
      default:
        title = 'Ưu đãi vận chuyển';
        description = 'Có ưu đãi vận chuyển đặc biệt';
        statusColor = Colors.grey;
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                applied ? Icons.check_circle : Icons.info_outline,
                color: statusColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  applied ? 'Đã áp dụng' : 'Chưa áp dụng',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6C757D),
            ),
          ),
          if (minOrder > 0) ...[
            const SizedBox(height: 8),
            Text(
              'Đơn hàng tối thiểu: ${_formatCurrency(minOrder)}',
              style: TextStyle(
                fontSize: 13,
                color: subtotal >= minOrder ? Colors.green : Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          Text(
            'Giá trị đơn hàng hiện tại: ${_formatCurrency(subtotal)}',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6C757D),
            ),
          ),
        ],
      ),
    );
  }

  void _showInspectionDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
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
                        color: const Color(0xFF4A90E2).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.info_outline,
                        color: Color(0xFF4A90E2),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Quy định đồng kiểm hàng hóa',
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
                      _buildSection(
                        '1. Quyền lợi của khách hàng',
                        '• Kiểm tra hàng hóa trước khi thanh toán\n• Được đổi/trả hàng nếu không đúng mô tả\n• Được hỗ trợ giải quyết tranh chấp\n• Đảm bảo chất lượng sản phẩm như cam kết',
                      ),
                      _buildSection(
                        '2. Quy trình đồng kiểm',
                        '• Nhận hàng từ nhân viên giao hàng\n• Kiểm tra bao bì, tem niêm phong\n• Mở hàng để kiểm tra sản phẩm\n• Xác nhận chất lượng và số lượng\n• Thanh toán hoặc từ chối nhận hàng',
                      ),
                      _buildSection(
                        '3. Lưu ý quan trọng',
                        '• Thời gian kiểm tra: tối đa 15 phút\n• Không được sử dụng sản phẩm\n• Giữ nguyên tem niêm phong khi kiểm tra\n• Thông báo ngay nếu phát hiện lỗi\n• Không làm hỏng bao bì sản phẩm',
                      ),
                      _buildSection(
                        '4. Trường hợp từ chối nhận hàng',
                        '• Sản phẩm không đúng mô tả\n• Bao bì bị hỏng, rách\n• Thiếu phụ kiện đi kèm\n• Sản phẩm bị lỗi, hỏng\n• Không đúng số lượng đặt hàng',
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
                              Icons.security,
                              color: Color(0xFF28A745),
                              size: 20,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Chúng tôi cam kết bảo vệ quyền lợi khách hàng và đảm bảo chất lượng dịch vụ tốt nhất.',
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

  Widget _buildSection(String title, String content) {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Hàng voucher shop đã ẩn vì hiển thị ngay trên header của từng shop
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.mobile_friendly_rounded, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Phí vận chuyển: ${_shipFee != null ? _formatCurrency(_shipFee!) : 'đang tính...'}'),
              ),
              if (_shipFee != null && _shipFee! > 0 && _hasFreeshipAvailable)
                GestureDetector(
                  onTap: () => _showFreeshipDialog(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.red.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: const Text(
                      ' Ưu đãi! Xem ngay',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.grey),
              const SizedBox(width: 8),
              Text('Dự kiến: ${_etaText ?? 'đang tính...'}'),
            ],
          ),
          if (_provider != null) const SizedBox(height: 6),
          if (_provider != null)
            Row(
              children: [
                const Icon(Icons.accessibility_sharp, color: Colors.grey),
                const SizedBox(width: 8),
                Text('Đơn vị: ${_provider!}'),
              ],
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.verified, color: Color(0xFF4A90E2)),
              const SizedBox(width: 8),
              const Text('Được đồng kiểm'),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _showInspectionDialog(context),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A90E2).withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF4A90E2).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      '!',
                      style: TextStyle(
                        color: Color(0xFF4A90E2),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatCurrency(int value) {
    final s = value.toString();
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final p = s.length - i;
      b.write(s[i]);
      if (p > 1 && p % 3 == 1) b.write('.');
    }
    return '${b.toString()}₫';
  }
}
