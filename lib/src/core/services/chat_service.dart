import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_manager.dart';
import '../models/chat.dart';

class ChatService {
  static const String _baseUrl = 'https://api.socdo.vn/v1';
  
  final TokenManager _tokenManager = TokenManager();
  
  // Lấy token từ TokenManager
  Future<String?> get _token async => await _tokenManager.getToken();

  // Headers cho API calls
  Future<Map<String, String>> get _headers async {
    final token = await _token;
    print('🔑 [DEBUG] Token status:');
    print('   Token exists: ${token != null}');
    if (token != null) {
      print('   Token length: ${token.length}');
      print('   Token preview: ${token.substring(0, token.length > 20 ? 20 : token.length)}...');
    }
    
    final headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    
    print('📋 [DEBUG] Headers: $headers');
    return headers;
  }

  /// Tạo phiên chat mới với shop
  Future<ChatSessionResponse> createSession(int shopId, int userId) async {
    try {
      final headers = await _headers;
      final url = '$_baseUrl/chat_api_correct';
      final body = {
        'action': 'create_session',
        'shop_id': shopId.toString(),
        'user_id': userId.toString(),
      };
      
      print('🔍 [DEBUG] Creating chat session:');
      print('   URL: $url');
      print('   Headers: $headers');
      print('   Body: $body');
      print('   Shop ID: $shopId');
      
      // Kiểm tra token validity
      final token = await _token;
      if (token != null) {
        final isValid = _tokenManager.isTokenValid(token);
        print('🔐 [DEBUG] Token validation:');
        print('   Token exists: true');
        print('   Token valid: $isValid');
        if (!isValid) {
          print('⚠️ [DEBUG] Token is invalid or expired!');
        }
      } else {
        print('❌ [DEBUG] No token found!');
      }
      
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body, // gửi form-urlencoded theo yêu cầu PHP
      );

      print('📡 [DEBUG] Response received:');
      print('   Status Code: ${response.statusCode}');
      print('   Response Body: ${response.body}');
      print('   Response Headers: ${response.headers}');
      
      // Log chi tiết hơn cho lỗi 500
      if (response.statusCode == 500) {
        print('🚨 [DEBUG] Server Error Details:');
        print('   Request URL: $url');
        print('   Request Method: POST');
        print('   Request Headers: $headers');
        print('   Request Body: $body');
        print('   Response Status: ${response.statusCode}');
        print('   Response Body Length: ${response.body.length}');
        if (response.body.isNotEmpty) {
          print('   Response Body Content: ${response.body}');
        }
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ [DEBUG] Successfully parsed response: $data');
        return ChatSessionResponse.fromJson(data);
      } else {
        print('❌ [DEBUG] HTTP Error: ${response.statusCode}');
        print('   Error Body: ${response.body}');
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('💥 [DEBUG] Exception in createSession: $e');
      throw Exception('Lỗi tạo phiên chat: $e');
    }
  }

  /// Lấy danh sách phiên chat
  Future<ChatListResponse> getSessions({required int userId, required String userType, int page = 1, int limit = 20}) async {
    try {
      final headers = await _headers;
      final response = await http.post(
        Uri.parse('$_baseUrl/chat_api_correct'),
        headers: headers,
        body: {
          'action': 'list_sessions',
          'user_id': userId.toString(),
          'user_type': userType,
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ChatListResponse.fromJson(data);
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Lỗi lấy danh sách chat: $e');
    }
  }

  /// Lấy tin nhắn của phiên chat
  Future<ChatMessagesResponse> getMessages({
    required String phien,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final headers = await _headers;
      final body = <String, String>{
        'action': 'get_messages',
        'phien': phien,
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/chat_api_correct'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ChatMessagesResponse.fromJson(data);
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Lỗi lấy tin nhắn: $e');
    }
  }

  /// Gửi tin nhắn
  Future<ChatSendResponse> sendMessage({
    required String phien,
    required String content,
    required String senderType,
    int productId = 0,
    int variantId = 0,
  }) async {
    try {
      final headers = await _headers;
      final body = <String, String>{
        'action': 'send_message',
        'phien': phien,
        'content': content,
        'sender_type': senderType,
        'product_id': productId.toString(),
        'variant_id': variantId.toString(),
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/chat_api_correct'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ChatSendResponse.fromJson(data);
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Lỗi gửi tin nhắn: $e');
    }
  }

  /// Đánh dấu tin nhắn đã đọc
  Future<bool> markAsRead({required String phien, bool markAll = true, String? messageIds}) async {
    try {
      final headers = await _headers;
      final body = <String, String>{
        'action': 'mark_read',
        'phien': phien,
        'mark_all': markAll.toString(),
      };

      if (messageIds != null && messageIds.isNotEmpty) {
        body['message_ids'] = messageIds;
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/chat_api_correct'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Lỗi đánh dấu đã đọc: $e');
    }
  }

  /// Lấy số tin nhắn chưa đọc
  Future<ChatUnreadResponse> getUnreadCount({required int userId, required String userType}) async {
    try {
      final headers = await _headers;
      final response = await http.post(
        Uri.parse('$_baseUrl/chat_api_correct'),
        headers: headers,
        body: {
          'action': 'get_unread_count',
          'user_id': userId.toString(),
          'user_type': userType,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ChatUnreadResponse.fromJson(data);
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Lỗi lấy số tin nhắn chưa đọc: $e');
    }
  }

  /// Đóng phiên chat
  Future<bool> closeSession({required String phien}) async {
    try {
      final headers = await _headers;
      final body = <String, String>{
        'action': 'close_session',
        'phien': phien,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/chat_api_correct'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Lỗi đóng phiên chat: $e');
    }
  }

  /// Tìm kiếm tin nhắn
  Future<ChatMessagesResponse> searchMessages({
    required String phien,
    required String keyword,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final headers = await _headers;
      final body = <String, String>{
        'action': 'search_messages',
        'phien': phien,
        'keyword': keyword,
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/chat_api_correct'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ChatMessagesResponse.fromJson(data);
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Lỗi tìm kiếm tin nhắn: $e');
    }
  }

  /// Tạo SSE connection URL
  Future<String> getSseUrl({required String phien, int? sessionId}) async {
    final token = await _token;
    final params = <String, String>{
      'token': token ?? '',
      'phien': phien,
    };
    
    if (sessionId != null) {
      params['session_id'] = sessionId.toString();
    }

    final queryString = params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return '$_baseUrl/chat_sse?$queryString';
  }
}
