import 'package:flutter/material.dart';

class OrderSummarySection extends StatelessWidget {
  const OrderSummarySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.local_offer, color: Colors.teal),
              const SizedBox(width: 8),
              const Text('Mã giảm giá của shop'),
              const Spacer(),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.local_shipping, color: Colors.grey),
              const SizedBox(width: 8),
              const Text('Phí vận chuyển: 13.000₫'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.local_shipping, color: Colors.grey),
              const SizedBox(width: 8),
              const Text('Thời gian giao hàng: Dự kiến từ 11/09 - 14/09'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.verified, color: Color(0xFF4A90E2)),
              const SizedBox(width: 8),
              const Text('Được đồng kiểm ?'),
              const SizedBox(width: 4),
              Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: Colors.grey,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('?', style: TextStyle(color: Colors.white, fontSize: 10)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
