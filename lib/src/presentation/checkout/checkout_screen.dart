import 'package:flutter/material.dart';
import 'widgets/delivery_info_section.dart';
import 'widgets/product_section.dart';
import 'widgets/order_summary_section.dart';
import 'widgets/voucher_section.dart';
import 'widgets/payment_methods_section.dart';
import 'widgets/payment_details_section.dart';
import 'widgets/terms_section.dart';
import 'widgets/bottom_order_bar.dart';

class CheckoutScreen extends StatefulWidget {
  final int totalPrice;
  final int selectedCount;
  
  const CheckoutScreen({
    super.key,
    required this.totalPrice,
    required this.selectedCount,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String selectedPaymentMethod = 'cod'; // cod, transfer, atm, credit
  bool agreeToTerms = false;

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
          const ProductSection(),
          const SizedBox(height: 12),
          const OrderSummarySection(),
          const SizedBox(height: 12),
          const VoucherSection(),
          const SizedBox(height: 12),
          PaymentMethodsSection(
            selectedPaymentMethod: selectedPaymentMethod,
            onPaymentMethodChanged: (value) {
              setState(() {
                selectedPaymentMethod = value ?? 'cod';
              });
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
        totalPrice: 3307000, // Total of 3 products + shipping
        onOrder: () {
          if (agreeToTerms) {
            // Handle order placement
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đặt hàng thành công!')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Vui lòng đồng ý với điều khoản')),
            );
          }
        },
      ),
    );
  }
}

