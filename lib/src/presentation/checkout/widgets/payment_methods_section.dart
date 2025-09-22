import 'package:flutter/material.dart';
import 'payment_option.dart';

class PaymentMethodsSection extends StatelessWidget {
  final String selectedPaymentMethod;
  final ValueChanged<String?> onPaymentMethodChanged;
  
  const PaymentMethodsSection({
    super.key,
    required this.selectedPaymentMethod,
    required this.onPaymentMethodChanged,
  });

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
            'Phương thức thanh toán',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 16),
          PaymentOption(
            icon: Icons.money,
            title: 'Thanh toán khi nhận hàng',
            value: 'cod',
            groupValue: selectedPaymentMethod,
            onChanged: onPaymentMethodChanged,
          ),
          PaymentOption(
            icon: Icons.qr_code,
            title: 'Thanh toán chuyển khoản',
            value: 'transfer',
            groupValue: selectedPaymentMethod,
            onChanged: onPaymentMethodChanged,
          ),
          PaymentOption(
            icon: Icons.credit_card,
            title: 'Thẻ ATM',
            value: 'atm',
            groupValue: selectedPaymentMethod,
            onChanged: onPaymentMethodChanged,
          ),
          PaymentOption(
            icon: Icons.payment,
            title: 'Thẻ tín dụng ghi nợ',
            value: 'credit',
            groupValue: selectedPaymentMethod,
            onChanged: onPaymentMethodChanged,
          ),
        ],
      ),
    );
  }
}
