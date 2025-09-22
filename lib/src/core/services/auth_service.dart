import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import '../models/user.dart';

class AuthService {
  static const String _userKey = 'user_data';
  static const String _loginTimeKey = 'login_time'; // Không sử dụng nữa, chỉ để clean up
  
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _apiService = ApiService();
  User? _currentUser;
  
  // Callback để thông báo khi trạng thái đăng nhập thay đổi
  final List<Function()> _onAuthStateChanged = [];

  /// Đăng ký tài khoản mới
  Future<Map<String, dynamic>> register({
    required String fullName,
    required String phoneNumber,
    required String password,
    required String rePassword,
  }) async {
    try {
      final response = await _apiService.post('/register', body: {
        'full_name': fullName,
        'phone_number': phoneNumber,
        'password': password,
        're_password': rePassword,
      });

      if (response != null) {
        print('🔍 Register response status: ${response.statusCode}');
        print('🔍 Register response body: ${response.body}');
        
        try {
          final data = jsonDecode(response.body);
          
          if (data['success'] == true) {
            print('✅ Đăng ký thành công: $fullName');
            return {
              'success': true,
              'message': data['message'] ?? 'Đăng ký thành công',
              'data': data['data'],
            };
          } else {
            return {
              'success': false,
              'message': data['message'] ?? 'Đăng ký thất bại',
            };
          }
        } catch (e) {
          print('❌ Lỗi parse JSON register response: $e');
          return {
            'success': false,
            'message': 'Lỗi xử lý dữ liệu từ server',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Lỗi kết nối server',
        };
      }
    } catch (e) {
      print('❌ Lỗi register: $e');
      return {
        'success': false,
        'message': 'Lỗi kết nối server',
      };
    }
  }

  /// Đăng nhập
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _apiService.post('/login', body: {
        'username': username,
        'password': password,
      });

      if (response != null) {
        print('🔍 Login response status: ${response.statusCode}');
        print('🔍 Login response body: ${response.body}');
        
        try {
          final data = jsonDecode(response.body);
          
          // Kiểm tra success field trong response
          if (data['success'] == true && data['data'] != null) {
            // Đăng nhập thành công
            final user = User.fromJson(data['data']);
            await _saveUser(user);
            
            print('✅ Đăng nhập thành công: ${user.name}');
            return {
              'success': true,
              'message': data['message'] ?? 'Đăng nhập thành công',
              'user': user,
            };
          } else {
            // Đăng nhập thất bại - có response nhưng success = false
            return {
              'success': false,
              'message': 'Sai tài khoản hoặc mật khẩu',
            };
          }
        } catch (jsonError) {
          // Lỗi parse JSON
          print('❌ Lỗi parse JSON: $jsonError');
          return {
            'success': false,
            'message': 'Lỗi xử lý dữ liệu từ server',
          };
        }
      } else {
        // Không có response
        return {
          'success': false,
          'message': 'Không thể kết nối đến server',
        };
      }
    } catch (e) {
      print('❌ Lỗi đăng nhập: $e');
      return {
        'success': false,
        'message': 'Có lỗi xảy ra: $e',
      };
    }
  }

  /// Lưu thông tin user vào SharedPreferences
  Future<void> _saveUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Lưu thông tin user (vĩnh viễn)
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
      
      _currentUser = user;
      print('✅ Đã lưu thông tin user vĩnh viễn: ${user.name}');
      
      // Thông báo cho các listener về việc thay đổi trạng thái
      _notifyAuthStateChanged();
    } catch (e) {
      print('❌ Lỗi khi lưu user: $e');
    }
  }

  /// Lấy thông tin user hiện tại
  Future<User?> getCurrentUser() async {
    if (_currentUser != null) {
      return _currentUser;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      
      if (userJson != null) {
        final userData = jsonDecode(userJson) as Map<String, dynamic>;
        _currentUser = User.fromJson(userData);
        return _currentUser;
      }
      
      return null;
    } catch (e) {
      print('❌ Lỗi khi lấy user: $e');
      return null;
    }
  }

  /// Kiểm tra user đã đăng nhập chưa
  Future<bool> isLoggedIn() async {
    try {
      final user = await getCurrentUser();
      // Chỉ cần kiểm tra có user data hay không, không kiểm tra thời gian hết hạn
      return user != null;
    } catch (e) {
      print('❌ Lỗi kiểm tra đăng nhập: $e');
      return false;
    }
  }

  /// Đăng xuất
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      await prefs.remove(_loginTimeKey); // Xóa luôn để clean up
      
      _currentUser = null;
      print('✅ Đã đăng xuất và xóa thông tin user');
      
      // Thông báo cho các listener về việc thay đổi trạng thái
      _notifyAuthStateChanged();
    } catch (e) {
      print('❌ Lỗi khi đăng xuất: $e');
    }
  }

  /// Thêm listener cho sự thay đổi trạng thái đăng nhập
  void addAuthStateListener(Function() listener) {
    _onAuthStateChanged.add(listener);
  }

  /// Xóa listener
  void removeAuthStateListener(Function() listener) {
    _onAuthStateChanged.remove(listener);
  }

  /// Thông báo cho tất cả listener về sự thay đổi trạng thái
  void _notifyAuthStateChanged() {
    for (final listener in _onAuthStateChanged) {
      try {
        listener();
      } catch (e) {
        print('❌ Lỗi trong auth state listener: $e');
      }
    }
  }

  /// Cập nhật thông tin user
  Future<void> updateUser(User user) async {
    await _saveUser(user);
  }

  /// Lấy URL avatar (với fallback)
  String getAvatarUrl(String? avatar) {
    if (avatar == null || avatar.isEmpty) {
      return 'lib/src/core/assets/images/user_default.png';
    }
    
    // Nếu avatar là URL đầy đủ
    if (avatar.startsWith('http')) {
      return avatar;
    }
    
    // Nếu avatar là path relative, thêm tiền tố https://socdo.vn/
    if (avatar.startsWith('/')) {
      return 'https://socdo.vn$avatar';
    } else {
      return 'https://socdo.vn/$avatar';
    }
  }

  /// Lấy tên hiển thị
  String getDisplayName(User user) {
    return user.name.isNotEmpty ? user.name : user.username;
  }

  /// Lấy số dư hiển thị
  String getFormattedBalance(User user) {
    return '${user.userMoney.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} VND';
  }
}
