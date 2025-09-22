import 'package:flutter/material.dart';
import '../../checkout/checkout_screen.dart';
import '../../../core/utils/format_utils.dart';

class BottomCheckoutBar extends StatelessWidget {
  final bool selectAll;
  final ValueChanged<bool> onToggleAll;
  final int totalPrice;
  final int selectedCount;
  const BottomCheckoutBar({
    super.key,
    required this.selectAll,
    required this.onToggleAll,
    required this.totalPrice,
    required this.selectedCount,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        decoration: const BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2)),
        ]),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tiếp tục tới Thanh toán để áp dụng nhiều mã giảm giá! ↓',
              style: TextStyle(color: Colors.grey[700], fontSize: 12),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Checkbox(
                  value: selectAll, 
                  activeColor: Colors.red,
                  onChanged: (v) => onToggleAll(v ?? false),
                ),
                const Text('Tất cả'),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(FormatUtils.formatCurrency(totalPrice),
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(height: 2),
                    const Text('Tiết kiệm 0đ', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: selectedCount == 0 ? null : () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CheckoutScreen(
                            totalPrice: totalPrice,
                            selectedCount: selectedCount,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text('THANH TOÁN (${selectedCount})'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
