import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text('Thông báo'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        children: [
          // Header với số lượng thông báo
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.notifications_active,
                    color: Colors.red[600],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bạn có 3 thông báo mới',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Cập nhật lần cuối: Hôm nay',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Đánh dấu tất cả đã đọc
                  },
                  child: const Text(
                    'Đánh dấu tất cả đã đọc',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Danh sách thông báo
          Container(
            color: Colors.white,
            child: Column(
              children: [
                _buildNotificationItem(
                  icon: Icons.local_offer,
                  iconColor: Colors.orange,
                  title: 'Mã giảm giá mới',
                  subtitle: 'Bạn có mã giảm giá 20% cho đơn hàng tiếp theo',
                  time: '2 giờ trước',
                  isRead: false,
                ),
                const Divider(height: 1),
                _buildNotificationItem(
                  icon: Icons.shopping_cart,
                  iconColor: Colors.blue,
                  title: 'Đơn hàng đã được xác nhận',
                  subtitle: 'Đơn hàng #12345 của bạn đã được xác nhận và đang chuẩn bị',
                  time: '5 giờ trước',
                  isRead: false,
                ),
                const Divider(height: 1),
                _buildNotificationItem(
                  icon: Icons.local_shipping,
                  iconColor: Colors.green,
                  title: 'Đơn hàng đang được giao',
                  subtitle: 'Đơn hàng #12344 đang được giao đến bạn',
                  time: '1 ngày trước',
                  isRead: true,
                ),
                const Divider(height: 1),
                _buildNotificationItem(
                  icon: Icons.star,
                  iconColor: Colors.purple,
                  title: 'Đánh giá sản phẩm',
                  subtitle: 'Hãy đánh giá sản phẩm bạn vừa mua',
                  time: '2 ngày trước',
                  isRead: true,
                ),
                const Divider(height: 1),
                _buildNotificationItem(
                  icon: Icons.campaign,
                  iconColor: Colors.red,
                  title: 'Khuyến mãi cuối tuần',
                  subtitle: 'Giảm giá lên đến 50% cho tất cả sản phẩm',
                  time: '3 ngày trước',
                  isRead: true,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Nút xóa tất cả thông báo
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () {
                _showDeleteConfirmDialog(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[50],
                foregroundColor: Colors.red[600],
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.delete_outline, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Xóa tất cả thông báo',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String time,
    required bool isRead,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isRead ? FontWeight.w500 : FontWeight.w600,
          color: isRead ? Colors.grey[600] : Colors.black87,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
      trailing: isRead 
          ? null 
          : Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
      onTap: () {
        // TODO: Xử lý khi nhấn vào thông báo
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xóa tất cả thông báo'),
          content: const Text('Bạn có chắc chắn muốn xóa tất cả thông báo? Hành động này không thể hoàn tác.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Xóa tất cả thông báo
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã xóa tất cả thông báo'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text(
                'Xóa',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}