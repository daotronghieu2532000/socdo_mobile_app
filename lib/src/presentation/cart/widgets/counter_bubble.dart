import 'package:flutter/material.dart';

class CounterBubble extends StatelessWidget {
  final int count;
  const CounterBubble({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(999)),
      child: Text('($count)', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w700)),
    );
  }
}
