import 'package:flutter/material.dart';

class VoucherSection extends StatelessWidget {
  const VoucherSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.confirmation_number, color: Colors.red),
          const SizedBox(width: 8),
          const Text('Chiaki Voucher'),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Chọn hoặc nhập mã', style: TextStyle(color: Colors.red, fontSize: 12)),
                SizedBox(width: 4),
                Icon(Icons.chevron_right, color: Colors.grey, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
