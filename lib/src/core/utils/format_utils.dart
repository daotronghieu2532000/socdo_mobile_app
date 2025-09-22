import '../assets/app_images.dart';

class FormatUtils {
  /// Format currency with Vietnamese Dong symbol
  static String formatCurrency(int value) {
    final s = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      buffer.write(s[i]);
      final positionFromEnd = s.length - i - 1;
      if (positionFromEnd % 3 == 0 && positionFromEnd != 0) buffer.write('.');
    }
    return '${buffer.toString()}₫';
  }

  /// Resolve product image by index
  static String resolveProductImage(int index) {
    return AppImages.products[index % AppImages.products.length];
  }

  /// Format price with comma separator
  static String formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
      (Match m) => '${m[1]},',
    );
  }

  /// Format time in HH:MM:SS format
  static String formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// Format number with thousand separator
  static String formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
      (Match m) => '${m[1]}.',
    );
  }

  /// Format percentage
  static String formatPercentage(double percentage) {
    return '${percentage.toStringAsFixed(0)}%';
  }

  /// Format rating with decimal places
  static String formatRating(double rating) {
    return rating.toStringAsFixed(1);
  }
}
