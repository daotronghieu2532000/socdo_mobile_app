import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'local_notification_service.dart';
import 'api_service.dart';
import 'auth_service.dart';
import 'notification_handler.dart';

/// Top-level function để handle background messages
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('📱 Background message received: ${message.messageId}');
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  // Background messages không thể hiển thị UI, chỉ log
}

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final LocalNotificationService _localNotifications = LocalNotificationService();
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  final NotificationHandler _notificationHandler = NotificationHandler();
  
  bool _initialized = false;
  String? _currentToken;

  /// Khởi tạo push notification service
  Future<void> initialize() async {
    if (_initialized) {
      print('✅ Push notification service already initialized');
      return;
    }

    try {
      print('🚀 Initializing push notification service...');

      // Initialize local notifications
      await _localNotifications.initialize();

      // Request permission
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✅ Notification permission granted');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        print('⚠️ Provisional notification permission granted');
      } else {
        print('❌ Notification permission denied');
        return;
      }

      // Setup message handlers
      _setupMessageHandlers();

      // Get token and register
      await _getAndRegisterToken();

      // Listen for token refresh
      _messaging.onTokenRefresh.listen(_handleTokenRefresh);

      _initialized = true;
      print('✅ Push notification service initialized successfully');
    } catch (e) {
      print('❌ Error initializing push notification service: $e');
    }
  }

  /// Setup message handlers
  void _setupMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📱 Foreground message received: ${message.messageId}');
      _handleForegroundMessage(message);
    });

    // Handle when app is opened from background/terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📱 App opened from notification: ${message.messageId}');
      _handleNotificationTap(message);
    });

    // Handle when app is opened from terminated state
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('📱 App opened from terminated state: ${message.messageId}');
        _handleNotificationTap(message);
      }
    });

    // Set background message handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  /// Handle foreground message (app is open)
  void _handleForegroundMessage(RemoteMessage message) {
    print('📨 [DEBUG] Foreground message received');
    final notification = message.notification;
    final data = message.data;

    print('📨 [DEBUG] Notification title: ${notification?.title}');
    print('📨 [DEBUG] Notification body: ${notification?.body}');
    print('📨 [DEBUG] Message data: $data');
    print('📨 [DEBUG] Data keys: ${data.keys.toList()}');

    if (notification != null) {
      print('📨 [DEBUG] Showing local notification with payload');
      // Hiển thị local notification vì FCM không tự hiển thị khi app ở foreground
      _localNotifications.showNotification(
        id: message.hashCode,
        title: notification.title ?? 'Thông báo',
        body: notification.body ?? '',
        payload: data,
      );
      print('📨 [DEBUG] Local notification shown with ID: ${message.hashCode}');
    }

    // Update notification count nếu cần
    _updateNotificationBadge();
  }

  /// Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    _notificationHandler.handleNotificationData(data);
  }

  /// Get FCM token and register to server
  Future<void> _getAndRegisterToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        print('✅ FCM Token obtained: ${token.substring(0, 20)}...');
        _currentToken = token;
        await _registerTokenToServer(token);
      } else {
        print('⚠️ FCM Token is null');
      }
    } catch (e) {
      print('❌ Error getting FCM token: $e');
    }
  }

  /// Handle token refresh
  void _handleTokenRefresh(String newToken) async {
    print('🔄 FCM Token refreshed: ${newToken.substring(0, 20)}...');
    _currentToken = newToken;
    await _registerTokenToServer(newToken);
  }

  /// Register token to server
  Future<void> _registerTokenToServer(String token) async {
    try {
      final user = await _authService.getCurrentUser();
      if (user == null) {
        print('⚠️ User not logged in, skip token registration');
        return;
      }

      // Get device info
      String platform = 'android';
      String? deviceModel;
      
      try {
        final deviceInfoPlugin = DeviceInfoPlugin();
        if (defaultTargetPlatform == TargetPlatform.android) {
          final androidInfo = await deviceInfoPlugin.androidInfo;
          platform = 'android';
          deviceModel = '${androidInfo.brand} ${androidInfo.model}';
        } else if (defaultTargetPlatform == TargetPlatform.iOS) {
          final iosInfo = await deviceInfoPlugin.iosInfo;
          platform = 'ios';
          deviceModel = '${iosInfo.name} ${iosInfo.model}';
        }
      } catch (e) {
        print('⚠️ Could not get device info: $e');
      }

      // Get app version
      String? appVersion;
      try {
        final packageInfo = await PackageInfo.fromPlatform();
        appVersion = packageInfo.version;
      } catch (e) {
        appVersion = null;
      }

      // Register token via API
      final success = await _apiService.registerDeviceToken(
        userId: user.userId,
        deviceToken: token,
        platform: platform,
        deviceModel: deviceModel,
        appVersion: appVersion,
      );

      if (success) {
        print('✅ Device token registered successfully');
      } else {
        print('❌ Failed to register device token');
      }
    } catch (e) {
      print('❌ Error registering device token: $e');
    }
  }

  /// Update notification badge (số lượng thông báo chưa đọc)
  void _updateNotificationBadge() {
    // Có thể implement badge update logic ở đây
    // Hoặc trigger reload notification list
  }

  /// Get current token
  String? get currentToken => _currentToken;

  /// Check if initialized
  bool get isInitialized => _initialized;
}

