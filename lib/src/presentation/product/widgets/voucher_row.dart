import 'package:flutter/material.dart';
import 'voucher_tag.dart';

class VoucherRow extends StatelessWidget {
  final List<String> vouchers;
  final VoidCallback? onTap;

  const VoucherRow({
    super.key,
    this.vouchers = const ['50.000₫', '20.000₫'],
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFEFFFF8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.percent, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            const Text('Mã giảm giá', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            Wrap(
              spacing: 8, 
              children: vouchers.map((voucher) => VoucherTag(text: voucher)).toList(),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
