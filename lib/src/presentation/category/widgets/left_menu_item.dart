import 'package:flutter/material.dart';

class LeftMenuItem extends StatelessWidget {
  final String label;
  final String? imagePath;
  final bool selected;
  final VoidCallback onTap;
  const LeftMenuItem({
    super.key,
    required this.label,
    required this.imagePath,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? Theme.of(context).colorScheme.primary : Colors.transparent;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? Colors.white : const Color(0xFFF6F7FB),
          border: Border(left: BorderSide(color: borderColor, width: 3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFDEE3EA)),
              ),
              clipBehavior: Clip.antiAlias,
              child: imagePath == null
                  ? const Icon(Icons.image, color: Colors.grey)
                  : Image.asset(
                      imagePath!,
                      fit: BoxFit.cover,
                    ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
