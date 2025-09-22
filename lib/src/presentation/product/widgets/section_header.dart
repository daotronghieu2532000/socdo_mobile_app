import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final Widget? trailing;

  const SectionHeader(
    this.text, {
    super.key,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Text(
                text, 
                style: const TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
