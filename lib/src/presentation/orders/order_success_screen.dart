import 'package:flutter/material.dart';

class OrderSuccessScreen extends StatelessWidget {
  final String maDon;
  const OrderSuccessScreen({super.key, required this.maDon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đặt hàng thành công')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 80),
              const SizedBox(height: 12),
              Text('Mã đơn: $maDon', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 8),
              const Text('Cảm ơn bạn đã mua sắm tại Socdo!'),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/orders', (route) => route.isFirst),
                    child: const Text('Xem đơn hàng'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                    child: const Text('Về trang chủ'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


