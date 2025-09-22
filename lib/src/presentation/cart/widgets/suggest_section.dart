import 'package:flutter/material.dart';
import 'suggest_card.dart';

class SuggestSection extends StatelessWidget {
  const SuggestSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text('Có thể bạn cũng thích', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        ),
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 0.75,
          ),
          itemCount: 4,
          itemBuilder: (context, index) => SuggestCard(index: index),
        ),
      ],
    );
  }
}
