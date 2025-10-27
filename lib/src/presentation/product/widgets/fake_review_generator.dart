import 'dart:math';

class FakeReviewGenerator {
  static final List<String> _customerNames = [
    'Nguyễn Văn An',
    'Trần Thị Bình',
    'Lê Văn Cường',
    'Phạm Thị Dung',
    'Hoàng Văn Em',
    'Đỗ Thị Giang',
    'Bùi Văn Hải',
    'Vũ Thị Hoa',
    'Ngô Văn Kiên',
    'Đinh Thị Lan',
    'Lý Văn Minh',
    'Cao Thị Nga',
    'Mai Văn Oanh',
    'Dương Thị Phượng',
    'Tạ Văn Quân',
    'Hồ Thị Sơn',
    'Nguyễn Văn Tuấn',
    'Trần Thị Uyên',
    'Lê Văn Việt',
    'Phạm Thị Xuân',
    'Hoàng Văn Yên',
    'Đỗ Thị Hạnh',
    'Bùi Văn Tùng',
    'Vũ Thị Mai',
    'Ngô Văn Nam',
    'Đinh Thị Hà',
    'Lý Văn Long',
    'Cao Thị Thu',
    'Mai Văn Hùng',
    'Dương Thị Linh',
  ];

  static final List<String> _reviewTexts = [
    'Hàng rất ổn.',
    'Sản phẩm khá ok.',
    'Tôi ưng sản phẩm này.',
    'Giá khá rẻ và cạnh tranh, chất lượng tạm được.',
    'Mua hàng khá tiện, nhanh gọn.',
    'Hàng đúng như mô tả.',
    'Giao hàng nhanh, đóng gói cẩn thận.',
    'Sản phẩm tốt, giá hợp lý.',
    'Đáng đồng tiền bát gạo.',
    'Hài lòng với sản phẩm.',
    'Chất lượng ổn, đáng mua.',
    'Hàng đến nhanh, đúng hẹn.',
    'Khá hài lòng với trải nghiệm.',
    'Sản phẩm như mong đợi.',
    'Tốt, sẽ mua lại.',
    'Chấp nhận được.',
    'Ổn, không phàn nàn.',
    'Được, không có vấn đề gì.',
    'Hàng tốt, đúng mô tả.',
    'Khá ổn, tôi hài lòng.',
    'Sản phẩm đáp ứng nhu cầu.',
    'Giao nhanh, đóng gói kỹ.',
    'Hàng chất lượng ổn.',
    'Giá cả hợp lý.',
    'Mua nhiều lần rồi, vẫn tốt.',
  ];

  // Tạo seed dựa trên productId và ngày hiện tại
  static int _generateSeed(int productId) {
    final now = DateTime.now();
    final dateSeed = now.year * 10000 + now.month * 100 + now.day;
    return productId * 1000000 + dateSeed;
  }

  // Lấy initials từ tên
  static String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[parts.length - 2][0]}${parts[parts.length - 1][0]}'.toUpperCase();
    }
    return parts.first.substring(0, parts.first.length > 2 ? 2 : 1).toUpperCase();
  }

  // Random thời gian đánh giá
  static String _getRandomTime(Random random) {
    final months = random.nextInt(12) + 1;
    if (months == 1) return '1 tháng trước';
    if (months == 2) return '2 tháng trước';
    if (months <= 6) return '$months tháng trước';
    return '1 năm trước';
  }

  // Generate fake reviews cho một sản phẩm
  static List<Map<String, dynamic>> generateFakeReviews(int productId, {int count = 3}) {
    final seed = _generateSeed(productId);
    final random = Random(seed);
    
    final reviews = <Map<String, dynamic>>[];
    
    // Trộn danh sách để mỗi sản phẩm có đánh giá khác nhau
    final shuffledNames = List<String>.from(_customerNames);
    for (int i = shuffledNames.length - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);
      final temp = shuffledNames[i];
      shuffledNames[i] = shuffledNames[j];
      shuffledNames[j] = temp;
    }

    final shuffledTexts = List<String>.from(_reviewTexts);
    for (int i = shuffledTexts.length - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);
      final temp = shuffledTexts[i];
      shuffledTexts[i] = shuffledTexts[j];
      shuffledTexts[j] = temp;
    }

    // Chọn random từng bộ tên và review
    final usedNames = <String>{};
    
    // Generate ratings trước để đảm bảo trung bình >= 4.8
    final ratings = <int>[];
    for (int i = 0; i < count; i++) {
      // Mỗi review có 85% chance là 5 sao, 15% là 4 sao
      // Với 3 reviews, trung bình sẽ là: ~4.7-5.0
      final rating = random.nextDouble() < 0.85 ? 5 : 4;
      ratings.add(rating);
    }

    // Đảm bảo trung bình >= 4.8 (tối thiểu tổng = 15 sao cho 3 reviews)
    // 5+5+4 = 14 (4.67) < 4.8
    // 5+5+5 = 15 (5.0) >= 4.8
    final sumRatings = ratings.fold<int>(0, (sum, rating) => sum + rating);
    if (sumRatings < 15) {
      // Nếu tổng < 15, đổi tất cả rating 4 thành 5
      for (int i = 0; i < ratings.length; i++) {
        if (ratings[i] == 4) {
          ratings[i] = 5;
        }
      }
    }
    
    for (int i = 0; i < count; i++) {
      // Chọn tên chưa dùng
      String name;
      do {
        name = shuffledNames[random.nextInt(shuffledNames.length)];
      } while (usedNames.contains(name) && usedNames.length < shuffledNames.length);
      usedNames.add(name);

      // Chọn review text
      final reviewText = shuffledTexts[random.nextInt(shuffledTexts.length)];

      reviews.add({
        'name': name,
        'initials': _getInitials(name),
        'rating': ratings[i],
        'time': _getRandomTime(random),
        'reviewText': reviewText,
      });
    }

    return reviews;
  }

  // Tính rating trung bình từ reviews
  static double calculateAverageRating(List<Map<String, dynamic>> reviews) {
    if (reviews.isEmpty) return 5.0;
    final sum = reviews.fold<double>(0.0, (sum, review) => sum + (review['rating'] as int));
    // Làm tròn đến 1 chữ số thập phân
    return double.parse((sum / reviews.length).toStringAsFixed(1));
  }

  // Tính tổng số đánh giá (fake)
  static int calculateReviewCount(int productId) {
    final seed = _generateSeed(productId);
    final random = Random(seed);
    // Random số đánh giá từ 50 đến 150
    return 50 + random.nextInt(100);
  }
}

