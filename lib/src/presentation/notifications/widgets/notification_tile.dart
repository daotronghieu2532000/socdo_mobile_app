import 'package:flutter/material.dart';

class NotificationTile extends StatelessWidget {
  final int index;
  final String? title;
  final String? content;
  final String? timeAgo;
  final IconData? icon;
  final VoidCallback? onTap;

  const NotificationTile({
    super.key,
    required this.index,
    this.title,
    this.content,
    this.timeAgo,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final notificationData = _getNotificationData(index);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F4F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon ?? Icons.notifications_outlined,
                color: Colors.grey,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title ?? notificationData['title'] as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700, 
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content ?? notificationData['content'] as String,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    timeAgo ?? notificationData['timeAgo'] as String,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getNotificationData(int index) {
    final notifications = [
      {
        'title': 'Nhanh tay! Mã SFREEAK91RX7EOK',
        'content': 'Khám phá ưu đãi và thông tin mới nhất. Mua ngay, số lượng có hạn!',
        'timeAgo': '1 giờ trước',
      },
      {
        'title': 'GH Creation EX - Chiều cao mơ ước',
        'content': 'Sản phẩm mới đã có mặt tại cửa hàng. Đặt hàng ngay để nhận ưu đãi!',
        'timeAgo': '2 giờ trước',
      },
      {
        'title': 'Đơn hàng #12345 đã được giao',
        'content': 'Đơn hàng của bạn đã được giao thành công. Cảm ơn bạn đã mua sắm!',
        'timeAgo': '3 giờ trước',
      },
      {
        'title': 'Flash Sale - Giảm giá 50%',
        'content': 'Cơ hội mua sắm với giá siêu ưu đãi. Chỉ còn 2 giờ nữa!',
        'timeAgo': '4 giờ trước',
      },
      {
        'title': 'Mã giảm giá mới cho bạn',
        'content': 'Bạn có mã giảm giá 20% cho đơn hàng tiếp theo. Sử dụng ngay!',
        'timeAgo': '5 giờ trước',
      },
      {
        'title': 'Sản phẩm yêu thích đã có hàng',
        'content': 'Sản phẩm bạn đã thêm vào danh sách yêu thích đã có hàng trở lại.',
        'timeAgo': '6 giờ trước',
      },
      {
        'title': 'Cập nhật ứng dụng mới',
        'content': 'Phiên bản mới với nhiều tính năng hấp dẫn đã sẵn sàng!',
        'timeAgo': '1 ngày trước',
      },
      {
        'title': 'Chúc mừng sinh nhật!',
        'content': 'Chúc mừng sinh nhật! Bạn nhận được voucher 100k từ chúng tôi.',
        'timeAgo': '2 ngày trước',
      },
    ];

    return notifications[index % notifications.length];
  }
}
