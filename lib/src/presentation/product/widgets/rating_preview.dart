import 'package:flutter/material.dart';
import 'review_item.dart';

class RatingPreview extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final List<Map<String, dynamic>> recentReviews;
  final VoidCallback? onViewAll;

  const RatingPreview({
    super.key,
    this.rating = 5.0,
    this.reviewCount = 71,
    this.recentReviews = const [],
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final defaultReviews = [
      {
        'name': 'HN Hiền',
        'initials': 'HN',
        'rating': 5,
        'time': '5 tháng trước',
        'reviewText': 'Sản phẩm rất tốt, tôi rất hài lòng!',
      },
      {
        'name': 'LN Linh Trần',
        'initials': 'LN',
        'rating': 5,
        'time': '3 tháng trước',
        'reviewText': 'Chất lượng tuyệt vời, sẽ mua lại.',
      },
    ];

    final reviews = recentReviews.isNotEmpty ? recentReviews : defaultReviews;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 20),
            const SizedBox(width: 4),
            Text(
              rating.toString(), 
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            Text(
              'Đánh giá sản phẩm ($reviewCount)', 
              style: const TextStyle(fontSize: 14),
            ),
            const Spacer(),
            GestureDetector(
              onTap: onViewAll,
              child: const Icon(Icons.chevron_right, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (int i = 0; i < reviews.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          ReviewItem(
            name: reviews[i]['name'] as String,
            initials: reviews[i]['initials'] as String,
            rating: reviews[i]['rating'] as int,
            time: reviews[i]['time'] as String,
            reviewText: reviews[i]['reviewText'] as String?,
          ),
        ],
      ],
    );
  }
}
