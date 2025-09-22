import 'package:flutter/material.dart';

class PaymentDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isRed;
  final bool isBold;

  const PaymentDetailRow(
    this.label,
    this.value, {
    super.key,
    this.isRed = false,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: isBold ? FontWeight.w800 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isRed ? Colors.red : Colors.black,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
