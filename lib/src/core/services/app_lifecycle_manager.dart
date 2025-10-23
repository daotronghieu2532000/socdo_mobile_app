import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Quản lý lifecycle của app và lưu trữ state khi app đi vào background
class AppLifecycleManager extends WidgetsBindingObserver {
  static final AppLifecycleManager _instance = AppLifecycleManager._internal();
  factory AppLifecycleManager() => _instance;
  AppLifecycleManager._internal();

  // Keys cho SharedPreferences
  static const String _currentTabKey = 'app_current_tab';
  static const String _scrollPositionKey = 'app_scroll_position';
  static const String _lastActiveTimeKey = 'app_last_active_time';
  static const String _homeScrollPositionKey = 'home_scroll_position';
  static const String _categoryScrollPositionKey = 'category_scroll_position';
  static const String _affiliateScrollPositionKey = 'affiliate_scroll_position';

  // Timeout cho state preservation (2 phút = 120 giây)
  // Giảm từ 5 phút xuống 2 phút để cân bằng giữa UX và data freshness
  static const Duration _stateTimeout = Duration(minutes: 2);
  
  DateTime? _lastActiveTime;
  bool _isAppInBackground = false;

  /// Khởi tạo AppLifecycleManager
  void initialize() {
    WidgetsBinding.instance.addObserver(this);
    _loadLastActiveTime();
  }

  /// Dispose AppLifecycleManager
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        _handleAppResumed();
        break;
      case AppLifecycleState.paused:
        _handleAppPaused();
        break;
      case AppLifecycleState.inactive:
        // App đang chuyển đổi giữa foreground và background
        break;
      case AppLifecycleState.detached:
        // App bị terminate
        break;
      case AppLifecycleState.hidden:
        // App bị ẩn (Android)
        break;
    }
  }

  /// Xử lý khi app được resume
  void _handleAppResumed() {
    _isAppInBackground = false;
    _lastActiveTime = DateTime.now();
    _saveLastActiveTime();
  }

  /// Xử lý khi app bị pause
  void _handleAppPaused() {
    _isAppInBackground = true;
    _lastActiveTime = DateTime.now();
    _saveLastActiveTime();
  }

  /// Lưu thời gian hoạt động cuối cùng
  Future<void> _saveLastActiveTime() async {
    if (_lastActiveTime != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastActiveTimeKey, _lastActiveTime!.toIso8601String());
    }
  }

  /// Load thời gian hoạt động cuối cùng
  Future<void> _loadLastActiveTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastActiveString = prefs.getString(_lastActiveTimeKey);
      if (lastActiveString != null) {
        _lastActiveTime = DateTime.parse(lastActiveString);
      }
    } catch (e) {
      // Ignore error
    }
  }

  /// Kiểm tra xem state có còn hợp lệ không
  bool isStateValid() {
    if (_lastActiveTime == null) return false;
    
    final now = DateTime.now();
    final timeDiff = now.difference(_lastActiveTime!);
    
    return timeDiff <= _stateTimeout;
  }

  /// Lưu tab hiện tại
  Future<void> saveCurrentTab(int tabIndex) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_currentTabKey, tabIndex);
    } catch (e) {
      // Ignore error
    }
  }

  /// Lấy tab đã lưu
  Future<int?> getSavedTab() async {
    if (!isStateValid()) {
      return null;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final tab = prefs.getInt(_currentTabKey);
      if (tab != null) {
        return tab;
      }
    } catch (e) {
      // Ignore error
    }
    return null;
  }

  /// Lưu vị trí scroll của một tab cụ thể
  Future<void> saveScrollPosition(int tabIndex, double scrollPosition) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String key;
      
      switch (tabIndex) {
        case 0:
          key = _homeScrollPositionKey;
          break;
        case 1:
          key = _categoryScrollPositionKey;
          break;
        case 2:
          key = _affiliateScrollPositionKey;
          break;
        default:
          return;
      }
      
      await prefs.setDouble(key, scrollPosition);
    } catch (e) {
      // Ignore error
    }
  }

  /// Lấy vị trí scroll đã lưu của một tab cụ thể
  Future<double?> getSavedScrollPosition(int tabIndex) async {
    if (!isStateValid()) {
      return null;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      String key;
      
      switch (tabIndex) {
        case 0:
          key = _homeScrollPositionKey;
          break;
        case 1:
          key = _categoryScrollPositionKey;
          break;
        case 2:
          key = _affiliateScrollPositionKey;
          break;
        default:
          return null;
      }
      
      final position = prefs.getDouble(key);
      if (position != null) {
        return position;
      }
    } catch (e) {
      // Ignore error
    }
    return null;
  }

  /// Xóa tất cả state đã lưu
  Future<void> clearAllState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_currentTabKey);
      await prefs.remove(_scrollPositionKey);
      await prefs.remove(_lastActiveTimeKey);
      await prefs.remove(_homeScrollPositionKey);
      await prefs.remove(_categoryScrollPositionKey);
      await prefs.remove(_affiliateScrollPositionKey);
    } catch (e) {
      // Ignore error
    }
  }

  /// Lưu state tổng quát (có thể mở rộng cho các state khác)
  Future<void> saveState(Map<String, dynamic> state) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_general_state', jsonEncode(state));
    } catch (e) {
      // Ignore error
    }
  }

  /// Lấy state tổng quát
  Future<Map<String, dynamic>?> getSavedState() async {
    if (!isStateValid()) {
      return null;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final stateString = prefs.getString('app_general_state');
      if (stateString != null) {
        final state = jsonDecode(stateString) as Map<String, dynamic>;
        return state;
      }
    } catch (e) {
      // Ignore error
    }
    return null;
  }

  /// Kiểm tra xem app có đang trong background không
  bool get isInBackground => _isAppInBackground;

  /// Lấy thời gian cuối cùng app hoạt động
  DateTime? get lastActiveTime => _lastActiveTime;
}
