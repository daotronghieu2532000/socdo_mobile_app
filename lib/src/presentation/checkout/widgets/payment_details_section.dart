import 'package:flutter/material.dart';
import 'payment_detail_row.dart';
import '../../../core/services/cart_service.dart' as cart_service;
import '../../../core/services/voucher_service.dart';
import '../../../core/utils/format_utils.dart';
import '../../../core/services/shipping_quote_store.dart';

class PaymentDetailsSection extends StatefulWidget {
  const PaymentDetailsSection({super.key});

  @override
  State<PaymentDetailsSection> createState() => _PaymentDetailsSectionState();
}

class _PaymentDetailsSectionState extends State<PaymentDetailsSection> {
  @override
  void initState() {
    super.initState();
    // Lắng nghe thay đổi giỏ hàng, voucher và phí ship để cập nhật real-time
    cart_service.CartService().addListener(_onCartChanged);
    VoucherService().addListener(_onVoucherChanged);
    ShippingQuoteStore().addListener(_onShippingChanged);
  }

  @override
  void dispose() {
    cart_service.CartService().removeListener(_onCartChanged);
    VoucherService().removeListener(_onVoucherChanged);
    ShippingQuoteStore().removeListener(_onShippingChanged);
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) setState(() {});
  }

  void _onVoucherChanged() {
    if (mounted) setState(() {});
  }

  void _onShippingChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final cart = cart_service.CartService();
    final voucherService = VoucherService();
    final items = cart.items.where((i) => i.isSelected).toList();
    final totalGoods = items.fold(0, (s, i) => s + i.price * i.quantity);
    // Tính giảm giá: cộng dồn voucher shop (đã áp dụng) + voucher sàn trên subtotal
    final shopDiscount = voucherService.calculateTotalDiscount(totalGoods);
    final platformDiscount = voucherService.calculatePlatformDiscountWithItems(
      totalGoods,
      items.map((e) => e.id).toList(),
    );
    final voucherDiscount = (shopDiscount + platformDiscount).clamp(0, totalGoods);
    // Lấy phí ship từ store đã cập nhật bởi OrderSummarySection
    final shipFee = ShippingQuoteStore().lastFee;
    final grandTotal = (totalGoods + shipFee - voucherDiscount).clamp(0, 1 << 31);
    
    // Debug log để so sánh với BottomOrderBar
    print('📋 PaymentDetailsSection calculation:');
    print('  - totalGoods: ${FormatUtils.formatCurrency(totalGoods)}');
    print('  - shipFee: ${FormatUtils.formatCurrency(shipFee)}');
    print('  - shopDiscount: ${FormatUtils.formatCurrency(shopDiscount)}');
    print('  - platformDiscount: ${FormatUtils.formatCurrency(platformDiscount)}');
    print('  - voucherDiscount: ${FormatUtils.formatCurrency(voucherDiscount)}');
    print('  - grandTotal: ${FormatUtils.formatCurrency(grandTotal)}');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chi tiết thanh toán',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 16),
          PaymentDetailRow('Tổng tiền hàng', FormatUtils.formatCurrency(totalGoods)),
          PaymentDetailRow('Tổng tiền phí vận chuyển', FormatUtils.formatCurrency(shipFee)),
          PaymentDetailRow('Tổng cộng Voucher giảm giá', '-${FormatUtils.formatCurrency(voucherDiscount)}', isRed: true),
          const Divider(height: 20),
          PaymentDetailRow('Tổng thanh toán', FormatUtils.formatCurrency(grandTotal), isBold: true),
        ],
      ),
    );
  }
}
