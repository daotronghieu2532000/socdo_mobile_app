import 'package:flutter/material.dart';

class ChipItem extends StatelessWidget {
  final String label;
  const ChipItem({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 90,
          height: 70,
          decoration: BoxDecoration(
            color: const Color(0xFFF6F7FB),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.image, color: Colors.grey),
        ),
        const SizedBox(height: 6),
        SizedBox(width: 100, child: Text(label, textAlign: TextAlign.center)),
      ],
    );
  }
}
