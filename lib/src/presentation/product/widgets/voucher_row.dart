import 'package:flutter/material.dart';

class VoucherRow extends StatelessWidget {
  final List<String>? vouchers;
  final String? couponCode;
  final String? couponDetails;
  final VoidCallback? onTap;

  const VoucherRow({
    super.key,
    this.vouchers,
    this.couponCode,
    this.couponDetails,
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
            Expanded(
              child: Text(
                couponDetails ?? (vouchers?.isNotEmpty == true ? vouchers!.join(', ') : 'Có sẵn'),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
