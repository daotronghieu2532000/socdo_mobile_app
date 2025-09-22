import 'package:flutter/material.dart';
import 'payment_detail_row.dart';

class PaymentDetailsSection extends StatelessWidget {
  const PaymentDetailsSection({super.key});

  @override
  Widget build(BuildContext context) {
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
          PaymentDetailRow('Tổng tiền hàng', '3.294.000₫'),
          PaymentDetailRow('Tổng tiền phí vận chuyển', '13.000₫'),
          PaymentDetailRow('Tổng cộng Voucher giảm giá', '0₫', isRed: true),
          const Divider(height: 20),
          PaymentDetailRow('Tổng thanh toán', '3.307.000₫', isBold: true),
        ],
      ),
    );
  }
}
