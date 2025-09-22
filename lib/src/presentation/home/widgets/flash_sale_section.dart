import 'dart:async';
import 'package:flutter/material.dart';
import '../../flash_sale/flash_sale_screen.dart';
import 'product_card_vertical.dart';
import '../../../core/utils/format_utils.dart';

class FlashSaleSection extends StatefulWidget {
  const FlashSaleSection({super.key});

  @override
  State<FlashSaleSection> createState() => _FlashSaleSectionState();
}

class _FlashSaleSectionState extends State<FlashSaleSection> {
  Duration _timeLeft = const Duration(hours: 2, minutes: 6, seconds: 49);
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft.inSeconds > 0) {
        setState(() {
          _timeLeft = Duration(seconds: _timeLeft.inSeconds - 1);
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    return FormatUtils.formatTime(seconds).replaceAll(':', ' : ');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: const BoxDecoration(
        color: Color(0xFFFFF2F2), // nền đỏ rất nhẹ xung quanh sản phẩm
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Row(
                  children: [
                    Icon(Icons.flash_on, color: Colors.pink, size: 20),
                    const SizedBox(width: 4),
                    Text('FLASH', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.pink)),
                    const SizedBox(width: 4),
                    Text('SALE', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.orange)),
                  ],
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const FlashSaleScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(_timeLeft.inSeconds),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward_ios, size: 12, color: Colors.red),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'Giảm giá sốc, đừng bỏ lỡ!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Hiển thị sản phẩm theo dạng dọc
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) => ProductCardVertical(index: index),
            separatorBuilder: (context, _) => const SizedBox(height: 0),
            itemCount: 4, // Hiển thị 4 sản phẩm như trong hình
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
