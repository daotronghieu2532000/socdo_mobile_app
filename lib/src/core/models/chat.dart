class ChatSession {
  final int sessionId;
  final String phien;
  final int shopId;
  final String shopName;
  final String shopAvatar;
  final String? lastMessage;
  final int lastMessageTime;
  final String lastMessageFormatted;
  final int unreadCount;

  ChatSession({
    required this.sessionId,
    required this.phien,
    required this.shopId,
    required this.shopName,
    required this.shopAvatar,
    this.lastMessage,
    required this.lastMessageTime,
    required this.lastMessageFormatted,
    required this.unreadCount,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      sessionId: int.tryParse(json['session_id']?.toString() ?? '0') ?? 0,
      phien: json['phien'] ?? '',
      shopId: int.tryParse(json['shop_id']?.toString() ?? '0') ?? 0,
      shopName: json['shop_name'] ?? '',
      shopAvatar: json['shop_avatar'] ?? '/images/user.png',
      lastMessage: json['last_message'],
      lastMessageTime: int.tryParse(json['last_message_time']?.toString() ?? '0') ?? 0,
      lastMessageFormatted: json['last_message_formatted'] ?? '',
      unreadCount: int.tryParse(json['unread_count']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'phien': phien,
      'shop_id': shopId,
      'shop_name': shopName,
      'shop_avatar': shopAvatar,
      'last_message': lastMessage,
      'last_message_time': lastMessageTime,
      'last_message_formatted': lastMessageFormatted,
      'unread_count': unreadCount,
    };
  }
}

class ChatMessage {
  final int id;
  final int senderId;
  final String senderType;
  final String senderName;
  final String senderAvatar;
  final String content;
  final int datePost;
  final String dateFormatted;
  final bool isRead;
  final bool isOwn;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderType,
    required this.senderName,
    required this.senderAvatar,
    required this.content,
    required this.datePost,
    required this.dateFormatted,
    required this.isRead,
    required this.isOwn,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      senderId: int.tryParse(json['sender_id']?.toString() ?? '0') ?? 0,
      senderType: json['sender_type'] ?? '',
      senderName: json['sender_name'] ?? '',
      senderAvatar: json['sender_avatar'] ?? '/images/user.png',
      content: json['content'] ?? '',
      datePost: int.tryParse(json['date_post']?.toString() ?? '0') ?? 0,
      dateFormatted: json['date_formatted'] ?? '',
      isRead: json['is_read'] == 1 || json['is_read'] == '1' || json['is_read'] == true,
      isOwn: json['is_own'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'sender_type': senderType,
      'sender_name': senderName,
      'sender_avatar': senderAvatar,
      'content': content,
      'date_post': datePost,
      'date_formatted': dateFormatted,
      'is_read': isRead ? 1 : 0,
      'is_own': isOwn,
    };
  }
}

class ChatSessionResponse {
  final bool success;
  final int sessionId;
  final String phien;
  final Map<String, dynamic> shopInfo;

  ChatSessionResponse({
    required this.success,
    required this.sessionId,
    required this.phien,
    required this.shopInfo,
  });

  factory ChatSessionResponse.fromJson(Map<String, dynamic> json) {
    return ChatSessionResponse(
      success: json['success'] ?? false,
      sessionId: int.tryParse(json['session_id']?.toString() ?? '0') ?? 0,
      phien: json['phien'] ?? '',
      shopInfo: json['shop_info'] ?? {},
    );
  }
}

class ChatListResponse {
  final bool success;
  final List<ChatSession> sessions;
  final Map<String, dynamic> pagination;

  ChatListResponse({
    required this.success,
    required this.sessions,
    required this.pagination,
  });

  factory ChatListResponse.fromJson(Map<String, dynamic> json) {
    return ChatListResponse(
      success: json['success'] ?? false,
      sessions: (json['sessions'] as List<dynamic>?)
          ?.map((e) => ChatSession.fromJson(e))
          .toList() ?? [],
      pagination: json['pagination'] ?? {},
    );
  }
}

class ChatMessagesResponse {
  final bool success;
  final List<ChatMessage> messages;
  final String phien;
  final Map<String, dynamic> pagination;

  ChatMessagesResponse({
    required this.success,
    required this.messages,
    required this.phien,
    required this.pagination,
  });

  factory ChatMessagesResponse.fromJson(Map<String, dynamic> json) {
    return ChatMessagesResponse(
      success: json['success'] ?? false,
      messages: (json['messages'] as List<dynamic>?)
          ?.map((e) => ChatMessage.fromJson(e))
          .toList() ?? [],
      phien: json['phien'] ?? '',
      pagination: json['pagination'] ?? {},
    );
  }
}

class ChatSendResponse {
  final bool success;
  final ChatMessage? message;

  ChatSendResponse({
    required this.success,
    this.message,
  });

  factory ChatSendResponse.fromJson(Map<String, dynamic> json) {
    return ChatSendResponse(
      success: json['success'] ?? false,
      message: json['message'] != null && json['message'] is Map<String, dynamic> 
          ? ChatMessage.fromJson(json['message']) 
          : null,
    );
  }
}

class ChatUnreadResponse {
  final bool success;
  final int unreadCount;

  ChatUnreadResponse({
    required this.success,
    required this.unreadCount,
  });

  factory ChatUnreadResponse.fromJson(Map<String, dynamic> json) {
    return ChatUnreadResponse(
      success: json['success'] ?? false,
      unreadCount: int.tryParse(json['unread_count']?.toString() ?? '0') ?? 0,
    );
  }
}
