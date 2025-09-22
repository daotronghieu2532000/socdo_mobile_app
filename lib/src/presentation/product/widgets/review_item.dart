import 'package:flutter/material.dart';

class ReviewItem extends StatelessWidget {
  final String name;
  final String initials;
  final int rating;
  final String time;
  final String? reviewText;
  final VoidCallback? onLike;
  final bool isLiked;
  
  const ReviewItem({
    super.key,
    required this.name,
    required this.initials,
    required this.rating,
    required this.time,
    this.reviewText,
    this.onLike,
    this.isLiked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  ...List.generate(rating, (index) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 14,
                  )),
                  const SizedBox(width: 4),
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              if (reviewText != null) ...[
                const SizedBox(height: 4),
                Text(
                  reviewText!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),
              ],
            ],
          ),
        ),
        GestureDetector(
          onTap: onLike,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isLiked ? Colors.red.withOpacity(0.1) : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isLiked ? Icons.thumb_up : Icons.thumb_up_outlined, 
                  size: 14, 
                  color: isLiked ? Colors.red : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  isLiked ? 'Đã thích' : 'Cảm ơn', 
                  style: TextStyle(
                    fontSize: 12, 
                    color: isLiked ? Colors.red : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
