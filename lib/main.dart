import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'src/app.dart';
import 'src/core/services/app_initialization_service.dart';

void main() async {
  // Giữ native splash screen cho đến khi Flutter ready
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  
  // Khởi tạo app services
  await _initializeApp();
  
  runApp(const SocdoApp());
}

Future<void> _initializeApp() async {
  try {
    print('🚀 Đang khởi tạo ứng dụng...');
    
    // Khởi tạo token
    final initService = AppInitializationService();
    final success = await initService.initializeApp();
    
    if (success) {
      print('✅ Khởi tạo ứng dụng thành công');
    } else {
      print('⚠️ Khởi tạo ứng dụng thất bại, tiếp tục chạy app');
    }
    
    // Đợi ít nhất 2 giây để hiển thị splash screen
    await Future.delayed(const Duration(seconds: 2));
    
  } catch (e) {
    print('❌ Lỗi khởi tạo ứng dụng: $e');
    // Vẫn tiếp tục chạy app dù có lỗi
  } finally {
    // Ẩn splash screen
    FlutterNativeSplash.remove();
  }
}
