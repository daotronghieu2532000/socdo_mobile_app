import 'package:flutter/material.dart';

class SpecsTable extends StatelessWidget {
  final List<Map<String, dynamic>> specs;

  const SpecsTable({
    super.key,
    this.specs = const [],
  });

  @override
  Widget build(BuildContext context) {
    final defaultSpecs = [
      {'label': 'Thương hiệu', 'value': 'Youtheory', 'isBlue': false},
      {'label': 'Cung cấp bởi', 'value': 'GG MART', 'isBlue': false},
      {'label': 'Tình trạng', 'value': 'Còn hàng', 'isBlue': false},
      {'label': 'Xuất xứ', 'value': 'Mỹ', 'isBlue': false},
    ];

    final specsData = specs.isNotEmpty ? specs : defaultSpecs;

    return Column(
      children: [
        for (final spec in specsData)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 120, 
                  child: Text(
                    spec['label'] as String, 
                    style: const TextStyle(
                      color: Colors.black54, 
                      fontSize: 14,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    spec['value'] as String, 
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: spec['isBlue'] as bool 
                          ? Theme.of(context).colorScheme.primary 
                          : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
