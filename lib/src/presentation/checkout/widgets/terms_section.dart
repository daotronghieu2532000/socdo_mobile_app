import 'package:flutter/material.dart';

class TermsSection extends StatelessWidget {
  final bool agreeToTerms;
  final ValueChanged<bool?> onTermsChanged;
  
  const TermsSection({
    super.key,
    required this.agreeToTerms,
    required this.onTermsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Checkbox(
            value: agreeToTerms,
            onChanged: onTermsChanged,
            activeColor: Colors.red,
          ),
          Expanded(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(color: Colors.black, fontSize: 14),
                children: [
                  TextSpan(text: 'Nhấn "Đặt hàng" đồng nghĩa bạn đồng ý với '),
                  TextSpan(
                    text: 'điều khoản',
                    style: TextStyle(color: Colors.red),
                  ),
                  TextSpan(text: ' và '),
                  TextSpan(
                    text: 'chính sách',
                    style: TextStyle(color: Colors.red),
                  ),
                  TextSpan(text: ' của chúng tôi.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
