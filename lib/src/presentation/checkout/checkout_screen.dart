import 'dart:math';
import 'package:flutter/material.dart';
import 'widgets/delivery_info_section.dart';
import 'widgets/product_section.dart';
import 'widgets/order_summary_section.dart';
import 'widgets/voucher_section.dart';
import 'widgets/payment_methods_section.dart';
import 'widgets/payment_details_section.dart';
import 'widgets/terms_section.dart';
import 'widgets/bottom_order_bar.dart';
import '../../core/services/cart_service.dart' as cart_service;
import '../../core/services/api_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/shipping_quote_store.dart';
import '../../core/services/voucher_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String selectedPaymentMethod = 'cod'; // Chỉ hỗ trợ COD
  bool agreeToTerms = false;
  final cart_service.CartService _cartService = cart_service.CartService();
  final ApiService _api = ApiService();
  final AuthService _auth = AuthService();

  int get totalPrice => _cartService.items
      .where((item) => item.isSelected)
      .fold(0, (sum, item) => sum + (item.price * item.quantity));

  int get selectedCount => _cartService.items
      .where((item) => item.isSelected)
      .length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const DeliveryInfoSection(),
          const SizedBox(height: 12),
          ProductSection(),
          const SizedBox(height: 12),
          const OrderSummarySection(),
          const SizedBox(height: 12),
          const VoucherSection(),
          const SizedBox(height: 12),
          PaymentMethodsSection(
            selectedPaymentMethod: selectedPaymentMethod,
            onPaymentMethodChanged: (value) {
              // Không cần thay đổi vì chỉ có COD
            },
          ),
          const SizedBox(height: 12),
          const PaymentDetailsSection(),
          const SizedBox(height: 12),
          TermsSection(
            agreeToTerms: agreeToTerms,
            onTermsChanged: (value) {
              setState(() {
                agreeToTerms = value ?? false;
              });
            },
          ),
          const SizedBox(height: 100),
        ],
      ),
      bottomNavigationBar: BottomOrderBar(
        totalPrice: totalPrice,
        onOrder: () async {
          if (!agreeToTerms) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Vui lòng đồng ý với điều khoản')),
            );
            return;
          }
          final user = await _auth.getCurrentUser();
          if (user == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Vui lòng đăng nhập để đặt hàng')),
            );
            return;
          }
          // Chuẩn bị payload theo API create_order
          final items = _cartService.items
              .where((i) => i.isSelected)
              .map((i) => {
                    'id': i.id,
                    'tieu_de': i.name,
                    'anh_chinh': i.image,
                    'quantity': i.quantity,
                    'gia_moi': i.price,
                    'thanh_tien': i.price * i.quantity,
                    'shop': i.shopId,
                  })
              .toList();
          // Lấy địa chỉ mặc định từ user_profile để điền
          final profile = await _api.getUserProfile(userId: user.userId);
          final addr = (profile?['addresses'] as List?)?.cast<Map<String, dynamic>?>().firstWhere(
                  (a) => (a?['active'] == 1 || a?['active'] == '1'),
                  orElse: () => null) ??
              (profile?['addresses'] as List?)?.cast<Map<String, dynamic>?>().firstOrNull;
          if (addr == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Vui lòng thêm địa chỉ nhận hàng')),
            );
            return;
          }
          final ship = ShippingQuoteStore();
          final voucherService = VoucherService();
          
          // Tính voucher discount như trong PaymentDetailsSection
          final totalGoods = items.fold(0, (s, i) => s + (i['gia_moi'] as int) * (i['quantity'] as int));
          final shopDiscount = voucherService.calculateTotalDiscount(totalGoods);
          final platformDiscount = voucherService.calculatePlatformDiscountWithItems(
            totalGoods,
            items.map((e) => e['id'] as int).toList(),
          );
          final voucherDiscount = (shopDiscount + platformDiscount).clamp(0, totalGoods);
          
          // 🔍 DEBUG: Voucher Calculation
          print('💰 VOUCHER CALCULATION DEBUG:');
          print('  📦 Total Goods: ${totalGoods.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}₫');
          print('  🏪 Shop Discount: ${shopDiscount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}₫');
          print('  🏢 Platform Discount: ${platformDiscount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}₫');
          print('  💸 Total Voucher Discount: ${voucherDiscount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}₫');
          
          // Debug chi tiết từng item
          print('  📋 Items Detail:');
          for (final item in items) {
            final itemTotal = (item['gia_moi'] as int) * (item['quantity'] as int);
            print('    - ${item['tieu_de']}: ${item['gia_moi']}₫ x ${item['quantity']} = ${itemTotal.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}₫ (Shop: ${item['shop']})');
          }
          
          // Lấy mã coupon từ platform voucher
          final platformVoucher = voucherService.platformVoucher;
          final couponCode = platformVoucher?.code ?? '';
          
          // 🔍 DEBUG: Platform Voucher Info
          print('🎫 PLATFORM VOUCHER DEBUG:');
          print('  📝 Coupon Code: ${couponCode.isEmpty ? "Không có" : couponCode}');
          if (platformVoucher != null) {
            print('  💰 Discount Value: ${platformVoucher.discountValue}');
            print('  📊 Discount Type: ${platformVoucher.discountType}');
            print('  📋 Formatted: ${platformVoucher.formattedDiscount}');
            print('  🏷️ Title: ${platformVoucher.title}');
            print('  📅 Expiry: ${platformVoucher.endDate}');
            print('  💵 Min Order: ${platformVoucher.minOrderValue?.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},') ?? 'N/A'}₫');
          }
          
          // 🔍 DEBUG: Shop Vouchers Info
          final appliedShopVouchers = voucherService.appliedVouchers;
          if (appliedShopVouchers.isNotEmpty) {
            print('🏪 SHOP VOUCHERS DEBUG:');
            for (final entry in appliedShopVouchers.entries) {
              final shopId = entry.key;
              final voucher = entry.value;
              print('  Shop $shopId:');
              print('    - Title: ${voucher.title}');
              print('    - Discount Value: ${voucher.discountValue}');
              print('    - Discount Type: ${voucher.discountType}');
              print('    - Formatted: ${voucher.formattedDiscount}');
              print('    - Min Order: ${voucher.minOrderValue?.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},') ?? 'N/A'}₫');
            }
          } else {
            print('🏪 SHOP VOUCHERS DEBUG: Không có voucher shop nào được áp dụng');
          }
          
          // Tính ship support từ freeship logic
          // API shipping_quote.php đã xử lý freeship và trả về final_fee
          // Chúng ta sẽ sử dụng thông tin từ debug để tính ship_support
          int shipSupport = 0;
          int finalShipFee = ship.lastFee;
          
          // 🔍 DEBUG: Ship Fee Before Freeship
          print('🚢 SHIPPING CALCULATION DEBUG:');
          print('  📦 Original Ship Fee: ${ship.lastFee.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}₫');
          print('  🚛 Shipping Provider: ${ship.provider ?? "Unknown"}');
          
          // Gọi API shipping_quote để lấy thông tin freeship cho tất cả items
          try {
            final shippingItems = items.map((item) => {
              'product_id': item['id'],
              'quantity': item['quantity'],
            }).toList();
            
            print('  📤 Shipping Quote Request:');
            for (final item in shippingItems) {
              print('    - Product ID: ${item['product_id']}, Quantity: ${item['quantity']}');
            }
            
            final shippingQuote = await _api.getShippingQuote(
              userId: user.userId,
              items: shippingItems.cast<Map<String, dynamic>>(),
            );
            
            print('  📥 Shipping Quote Response: ${shippingQuote != null ? "Success" : "Failed"}');
            
            if (shippingQuote != null && shippingQuote['success'] == true) {
              final debug = shippingQuote['data']?['debug'];
              if (debug != null) {
                print('  🔍 Debug Info Available: Yes');
                
                // Debug shop freeship details
                final shopFreeshipDetails = debug['shop_freeship_details'] as Map<String, dynamic>?;
                if (shopFreeshipDetails != null && shopFreeshipDetails.isNotEmpty) {
                  print('  🏪 Shop Freeship Details:');
                  for (final entry in shopFreeshipDetails.entries) {
                    final shopId = entry.key;
                    final config = entry.value as Map<String, dynamic>;
                    print('    Shop $shopId:');
                    print('      - Mode: ${config['mode']}');
                    print('      - Applied: ${config['applied']}');
                    print('      - Type: ${config['type'] ?? 'N/A'}');
                    print('      - Subtotal: ${config['subtotal']?.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},') ?? 'N/A'}₫');
                    print('      - Min Order: ${config['min_order']?.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},') ?? 'N/A'}₫');
                    print('      - Discount: ${config['discount'] ?? 'N/A'}');
                  }
                }
                
                final freeshipExcluded = debug['freeship_excluded'] as Map<String, dynamic>?;
                if (freeshipExcluded != null) {
                  print('  💸 Freeship Excluded Info:');
                  print('    - Exclude Weight: ${freeshipExcluded['weight'] ?? 0}g');
                  print('    - Exclude Value: ${freeshipExcluded['value']?.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},') ?? '0'}₫');
                  print('    - Weight to Quote: ${freeshipExcluded['weight_to_quote'] ?? 0}g');
                  print('    - Value to Quote: ${freeshipExcluded['value_to_quote']?.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},') ?? '0'}₫');
                  
                  // Lấy ship support từ API response
                  final shipFixedSupport = freeshipExcluded['ship_fixed_support'] as int? ?? 0;
                  final shipPercentSupport = freeshipExcluded['ship_percent_support'] as double? ?? 0.0;
                  
                  print('    - Ship Fixed Support: ${shipFixedSupport.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}₫');
                  print('    - Ship Percent Support: $shipPercentSupport%');
                  
                  // Tính tổng ship support
                  shipSupport = shipFixedSupport;
                  if (shipPercentSupport > 0) {
                    final percentSupportAmount = (ship.lastFee * shipPercentSupport / 100).round();
                    shipSupport += percentSupportAmount;
                    print('    - Percent Support Amount: ${percentSupportAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}₫');
                  }
                  
                  // Tính final ship fee
                  finalShipFee = max(0, ship.lastFee - shipSupport);
                  
                  print('  🧮 Ship Support Calculation:');
                  print('    - Original Fee: ${ship.lastFee.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}₫');
                  print('    - Fixed Support: ${shipFixedSupport.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}₫');
                  print('    - Percent Support: $shipPercentSupport%');
                  print('    - Total Support: ${shipSupport.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}₫');
                  print('    - Final Fee: ${finalShipFee.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}₫');
                } else {
                  print('  ❌ No freeship excluded info found');
                }
              } else {
                print('  ❌ No debug info in response');
              }
            } else {
              print('  ❌ Shipping quote failed: ${shippingQuote?['message'] ?? 'Unknown error'}');
            }
          } catch (e) {
            // Nếu có lỗi khi gọi shipping_quote, sử dụng ship fee gốc
            print('  ❌ Error getting shipping quote: $e');
          }
          
          // Đảm bảo ship support không vượt quá ship fee gốc
          shipSupport = shipSupport.clamp(0, ship.lastFee);
          finalShipFee = finalShipFee.clamp(0, ship.lastFee);
          
          print('  ✅ Final Ship Values:');
          print('    - Ship Support: ${shipSupport.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}₫');
          print('    - Final Ship Fee: ${finalShipFee.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}₫');
          
          // 🔍 DEBUG: Final Order Summary
          print('📋 FINAL ORDER SUMMARY DEBUG:');
          print('  👤 User ID: ${user.userId}');
          print('  📦 Total Items: ${items.length}');
          print('  💰 Total Goods: ${totalGoods.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}₫');
          print('  🏪 Shop Discount: ${shopDiscount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}₫');
          print('  🏢 Platform Discount: ${platformDiscount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}₫');
          print('  🚢 Ship Fee: ${finalShipFee.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}₫');
          print('  💸 Ship Support: ${shipSupport.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}₫');
          
          final grandTotal = totalGoods + finalShipFee - shopDiscount - platformDiscount;
          print('  🧮 Grand Total Calculation:');
          print('    = Total Goods: ${totalGoods.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}₫');
          print('    + Ship Fee: ${finalShipFee.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}₫');
          print('    - Shop Discount: ${shopDiscount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}₫');
          print('    - Platform Discount: ${platformDiscount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}₫');
          print('    = Grand Total: ${grandTotal.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}₫');
          
          print('  📤 API Call Parameters:');
          print('    - giam (Shop Discount): $shopDiscount');
          print('    - voucherTmdt (Platform Discount): $platformDiscount');
          print('    - phiShip (Final Ship Fee): $finalShipFee');
          print('    - shipSupport (Ship Support): $shipSupport');
          print('    - coupon: $couponCode');
          print('    - shippingProvider: ${ship.provider}');
          
          final res = await _api.createOrder(
            userId: user.userId,
            hoTen: addr['ho_ten']?.toString() ?? user.name,
            dienThoai: addr['dien_thoai']?.toString() ?? user.mobile,
            email: user.email,
            diaChi: addr['dia_chi']?.toString() ?? '',
            tinh: int.tryParse('${addr['tinh'] ?? 0}') ?? 0,
            huyen: int.tryParse('${addr['huyen'] ?? 0}') ?? 0,
            xa: int.tryParse('${addr['xa'] ?? 0}'),
            sanpham: items.cast<Map<String, dynamic>>(),
            thanhtoan: selectedPaymentMethod.toUpperCase(),
            ghiChu: '',
            coupon: couponCode,
            giam: shopDiscount,           // ✅ Shop discount
            voucherTmdt: platformDiscount, // ✅ Platform discount
            phiShip: finalShipFee,        // ✅ Ship fee sau khi trừ freeship
            shipSupport: shipSupport,      // ✅ Ship support từ freeship
            shippingProvider: ship.provider,
          );
          
          print('  📥 API Response: ${res != null ? "Success" : "Failed"}');
          if (res != null) {
            print('    - Success: ${res['success']}');
            print('    - Message: ${res['message']}');
            if (res['data'] != null) {
              print('    - Order Code: ${res['data']['ma_don'] ?? 'N/A'}');
              final backendTotal = res['data']['tongtien'] as int? ?? 0;
              print('    - Backend Total: ${backendTotal.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}₫');
              
              // So sánh với tính toán frontend
              print('  🔍 CALCULATION COMPARISON:');
              print('    - Frontend Grand Total: ${grandTotal.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}₫');
              print('    - Backend Total: ${backendTotal.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}₫');
              print('    - Difference: ${(grandTotal - backendTotal).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}₫');
              if (grandTotal == backendTotal) {
                print('    ✅ CALCULATION MATCH!');
              } else {
                print('    ❌ CALCULATION MISMATCH!');
              }
            }
          }
          if ((res?['success'] == true)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Đặt hàng thành công: ${res?['data']?['ma_don'] ?? ''}')),
            );
            if (!mounted) return;
            Navigator.pushNamed(context, '/order/success', arguments: {'ma_don': res?['data']?['ma_don']});
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Đặt hàng thất bại: ${res?['message'] ?? 'Lỗi không xác định'}')),
            );
          }
        },
      ),
    );
  }
}

