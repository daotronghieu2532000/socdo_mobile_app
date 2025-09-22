import 'package:flutter/material.dart';

class VariantSelector extends StatelessWidget {
  final List<String> variants;
  final int selectedIndex;
  final ValueChanged<int>? onVariantChanged;

  const VariantSelector({
    super.key,
    required this.variants,
    this.selectedIndex = 0,
    this.onVariantChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < variants.length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => onVariantChanged?.call(i),
              child: Container(
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: selectedIndex == i 
                        ? Theme.of(context).colorScheme.primary 
                        : const Color(0xFFE3E6EC),
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: selectedIndex == i 
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                      : Colors.white,
                ),
                child: Text(
                  variants[i],
                  style: TextStyle(
                    color: selectedIndex == i 
                        ? Theme.of(context).colorScheme.primary 
                        : Colors.black,
                    fontWeight: selectedIndex == i 
                        ? FontWeight.w600 
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
