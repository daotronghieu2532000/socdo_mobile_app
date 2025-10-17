import 'package:flutter/material.dart';

class ProductBadge extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;
  final EdgeInsets padding;

  const ProductBadge({
    super.key,
    required this.text,
    this.backgroundColor = Colors.red,
    this.textColor = Colors.white,
    this.fontSize = 10,
    this.padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class ProductBadgesRow extends StatelessWidget {
  final List<String> badges;
  final double spacing;
  final double fontSize;
  final EdgeInsets padding;

  const ProductBadgesRow({
    super.key,
    required this.badges,
    this.spacing = 4,
    this.fontSize = 10,
    this.padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
  });

  @override
  Widget build(BuildContext context) {
    if (badges.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: badges.map((badge) {
        Color backgroundColor;
        Color textColor = Colors.white;

        // Xác định màu sắc dựa trên loại badge
        if (badge.contains('%') || badge.contains('Giảm')) {
          backgroundColor = Colors.red;
        } else if (badge == 'Voucher') {
          backgroundColor = Colors.orange;
        } else if (badge.contains('Freeship') || badge.contains('ship')) {
          backgroundColor = Colors.green;
        } else if (badge == 'Flash Sale' || badge == 'FLASH SALE') {
          backgroundColor = Colors.purple;
        } else if (badge == 'Bán chạy' || badge == 'BÁN CHẠY') {
          backgroundColor = Colors.blue;
        } else if (badge == 'Nổi bật' || badge == 'NỔI BẬT') {
          backgroundColor = Colors.indigo;
        } else if (badge == 'Chính hãng') {
          backgroundColor = Colors.teal;
        } else {
          backgroundColor = Colors.grey;
        }

        return ProductBadge(
          text: badge,
          backgroundColor: backgroundColor,
          textColor: textColor,
          fontSize: fontSize,
          padding: padding,
        );
      }).toList(),
    );
  }
}

class ProductLocationInfo extends StatelessWidget {
  final String? locationText;
  final String? warehouseName;
  final String? provinceName;
  final double fontSize;
  final Color textColor;

  const ProductLocationInfo({
    super.key,
    this.locationText,
    this.warehouseName,
    this.provinceName,
    this.fontSize = 11,
    this.textColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    String displayText = '';
    
    if (locationText != null && locationText!.isNotEmpty) {
      displayText = locationText!;
    } else if (warehouseName != null && warehouseName!.isNotEmpty) {
      displayText = warehouseName!;
    } else if (provinceName != null && provinceName!.isNotEmpty) {
      displayText = provinceName!;
    }

    if (displayText.isEmpty) return const SizedBox.shrink();

    return Row(
      children: [
        Icon(
          Icons.location_on,
          size: fontSize,
          color: textColor,
        ),
        const SizedBox(width: 2),
        Expanded(
          child: Text(
            displayText,
            style: TextStyle(
              fontSize: fontSize,
              color: textColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
