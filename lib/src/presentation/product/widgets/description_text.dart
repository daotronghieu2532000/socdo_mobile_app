import 'package:flutter/material.dart';

class DescriptionText extends StatelessWidget {
  final String description;
  final VoidCallback? onViewMore;

  const DescriptionText({
    super.key,
    this.description = 'Thành phần có trong viên uống Collagen Youtheory Collagen type I: Đây là loại collagen tạo nên cấu trúc da, gân, thành mạch, dây chằng, nội tạng và là thành phần chính của xương...',
    this.onViewMore,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          description,
          textAlign: TextAlign.justify,
          style: const TextStyle(fontSize: 14, height: 1.4),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onViewMore,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'Xem thêm',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down,
                color: Colors.red,
                size: 16,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
