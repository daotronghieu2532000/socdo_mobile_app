import 'api_service.dart';
import 'push_notification_service.dart';

class AppInitializationService {
  static final AppInitializationService _instance = AppInitializationService._internal();
  factory AppInitializationService() => _instance;
  AppInitializationService._internal();

  final ApiService _apiService = ApiService();
  final PushNotificationService _pushService = PushNotificationService();
  bool _isInitialized = false;

  /// Khởi tạo app - gọi khi app start
  Future<bool> initializeApp() async {
    if (_isInitialized) {
      print('✅ App đã được khởi tạo');
      return true;
    }

    print('🚀 Bắt đầu khởi tạo app...');
    
    try {
      // Lấy token (sẽ tự động check cache hoặc fetch mới)
      final token = await _apiService.getValidToken();
      
      if (token != null) {
        // Khởi tạo push notification service
        _pushService.initialize().catchError((e) {
          print('⚠️ Error initializing push service: $e');
          // Không block app nếu push service lỗi
        });
        
        _isInitialized = true;
        print('✅ Khởi tạo app thành công');
        return true;
      } else {
        print('❌ Không thể lấy token, khởi tạo thất bại');
        return false;
      }
    } catch (e) {
      print('❌ Lỗi khởi tạo app: $e');
      return false;
    }
  }

  /// Kiểm tra app đã được khởi tạo chưa
  bool get isInitialized => _isInitialized;

  /// Reset trạng thái khởi tạo (dùng khi logout)
  void resetInitialization() {
    _isInitialized = false;
    print('🔄 Reset trạng thái khởi tạo app');
  }

  /// Khởi tạo lại app (force refresh token)
  Future<bool> reinitializeApp() async {
    _isInitialized = false;
    await _apiService.refreshToken();
    return await initializeApp();
  }
}
