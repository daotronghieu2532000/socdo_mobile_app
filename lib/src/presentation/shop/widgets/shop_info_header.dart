import 'package:flutter/material.dart';
import '../../../core/models/shop_detail.dart';

class ShopInfoHeader extends StatelessWidget {
  final ShopInfo shopInfo;

  const ShopInfoHeader({
    super.key,
    required this.shopInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 30,
                backgroundImage: shopInfo.avatarUrl.isNotEmpty
                    ? NetworkImage(shopInfo.avatarUrl)
                    : null,
                child: shopInfo.avatarUrl.isEmpty
                    ? const Icon(Icons.store, size: 30)
                    : null,
              ),
              const SizedBox(width: 16),
              
              // Shop Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shopInfo.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@${shopInfo.username}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            shopInfo.address.isNotEmpty ? shopInfo.address : 'Chưa cập nhật địa chỉ',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Statistics
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Sản phẩm',
                shopInfo.totalProducts.toString(),
                Icons.inventory_2,
              ),
              _buildStatItem(
                'Thành viên từ',
                _formatDate(shopInfo.createdAt),
                Icons.calendar_today,
              ),
              _buildStatItem(
                'Đánh giá',
                '4.8',
                Icons.star,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Shop badges
          if (shopInfo.isCtv == 1 || shopInfo.isDropship == 1 || shopInfo.isLeader == 1)
            Wrap(
              spacing: 8,
              children: [
                if (shopInfo.isCtv == 1)
                  _buildBadge('CTV', Colors.blue),
                if (shopInfo.isDropship == 1)
                  _buildBadge('Dropship', Colors.green),
                if (shopInfo.isLeader == 1)
                  _buildBadge('Leader', Colors.orange),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${date.day}/${date.month}/${date.year}';
  }
}
