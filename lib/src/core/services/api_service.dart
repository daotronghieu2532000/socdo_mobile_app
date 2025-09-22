import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_manager.dart';

class ApiService {
  static const String baseUrl = 'https://api.socdo.vn/v1';
  static const String apiKey = 'zzz8m4rjxnvgogy1gr1htkncn7';
  static const String apiSecret = 'wz2yht03i0ag2ilib8gpfhbgusq2pw9ylo3sn2n2uqs4djugtf5nbgn1h0o3jx';
  
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();
  
  final TokenManager _tokenManager = TokenManager();

  /// Lấy token từ API
  Future<String?> _fetchToken() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/get_token'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'api_key': apiKey,
          'api_secret': apiSecret,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['token'] != null) {
          final token = data['token'] as String;
          await _tokenManager.saveToken(token);
          print('✅ Lấy token thành công: ${token.substring(0, 20)}...');
          return token;
        } else {
          print('❌ API trả về lỗi: ${data['message']}');
          return null;
        }
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Lỗi khi lấy token: $e');
      return null;
    }
  }

  /// Lấy token hợp lệ (từ cache hoặc fetch mới)
  Future<String?> getValidToken() async {
    // Kiểm tra token hiện tại
    String? currentToken = await _tokenManager.getToken();
    
    if (currentToken != null && _tokenManager.isTokenValid(currentToken)) {
      print('✅ Sử dụng token có sẵn');
      return currentToken;
    }
    
    print('🔄 Token không tồn tại hoặc hết hạn, lấy token mới...');
    return await _fetchToken();
  }

  /// Thực hiện API call với token
  Future<http.Response?> apiCall({
    required String endpoint,
    required String method,
    Map<String, dynamic>? body,
    Map<String, String>? additionalHeaders,
  }) async {
    final token = await getValidToken();
    if (token == null) {
      print('❌ Không thể lấy token');
      return null;
    }

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      ...?additionalHeaders,
    };

    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      
      switch (method.toUpperCase()) {
        case 'GET':
          return await http.get(uri, headers: headers);
        case 'POST':
          return await http.post(
            uri, 
            headers: headers, 
            body: body != null ? jsonEncode(body) : null,
          );
        case 'PUT':
          return await http.put(
            uri, 
            headers: headers, 
            body: body != null ? jsonEncode(body) : null,
          );
        case 'DELETE':
          return await http.delete(uri, headers: headers);
        default:
          throw Exception('Unsupported HTTP method: $method');
      }
    } catch (e) {
      print('❌ Lỗi API call: $e');
      return null;
    }
  }

  /// GET request
  Future<http.Response?> get(String endpoint, {Map<String, String>? headers}) {
    return apiCall(endpoint: endpoint, method: 'GET', additionalHeaders: headers);
  }

  /// POST request
  Future<http.Response?> post(String endpoint, {Map<String, dynamic>? body, Map<String, String>? headers}) {
    return apiCall(endpoint: endpoint, method: 'POST', body: body, additionalHeaders: headers);
  }

  /// PUT request
  Future<http.Response?> put(String endpoint, {Map<String, dynamic>? body, Map<String, String>? headers}) {
    return apiCall(endpoint: endpoint, method: 'PUT', body: body, additionalHeaders: headers);
  }

  /// DELETE request
  Future<http.Response?> delete(String endpoint, {Map<String, String>? headers}) {
    return apiCall(endpoint: endpoint, method: 'DELETE', additionalHeaders: headers);
  }

  /// Làm mới token (force refresh)
  Future<String?> refreshToken() async {
    await _tokenManager.clearToken();
    return await _fetchToken();
  }

  /// Xóa token (logout)
  Future<void> clearToken() async {
    await _tokenManager.clearToken();
  }
}
