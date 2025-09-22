import 'package:flutter/material.dart';
import 'group_card.dart';
import 'chip_item.dart';

class RightContent extends StatelessWidget {
  final String title;
  const RightContent({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF6F7FB),
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          GroupCard(
            title: title,
            children: const [
              ChipItem(label: 'Vitamin A'),
              ChipItem(label: 'Vitamin E'),
              ChipItem(label: 'Vitamin C'),
              ChipItem(label: 'Vitamin B'),
              ChipItem(label: 'Sắt Bổ Máu'),
              ChipItem(label: 'Vitamin D'),
            ],
          ),
          GroupCard(
            title: 'Collagen',
            children: const [
              ChipItem(label: 'Dạng nước'),
              ChipItem(label: 'Dạng viên'),
            ],
          ),
          GroupCard(
            title: 'Bổ mắt',
            children: const [
              ChipItem(label: 'Dầu cá'),
              ChipItem(label: 'Omega 3 6 9'),
            ],
          ),
          GroupCard(
            title: 'Bổ trợ xương khớp',
            children: const [
              ChipItem(label: 'Glucosamine'),
              ChipItem(label: 'Dầu xoa bóp'),
            ],
          ),
          GroupCard(
            title: 'Tăng cân',
            children: const [
              ChipItem(label: 'Cho người lớn'),
            ],
          ),
          GroupCard(
            title: 'Tinh chất hàu',
            children: const [
              ChipItem(label: 'Bổ thận'),
            ],
          ),
          GroupCard(
            title: 'Giảm cân',
            children: const [
              ChipItem(label: 'Detox'),
            ],
          ),
        ],
      ),
    );
  }
}
