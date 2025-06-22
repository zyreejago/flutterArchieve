class ConversationModel {
  final String id;
  final String participant1;
  final String participant2;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final DateTime createdAt;
  final String? otherUserName;
  final String? otherUserAvatar;
  final int unreadCount;

  ConversationModel({
    required this.id,
    required this.participant1,
    required this.participant2,
    this.lastMessage,
    this.lastMessageAt,
    required this.createdAt,
    this.otherUserName,
    this.otherUserAvatar,
    this.unreadCount = 0,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'],
      participant1: json['participant_1'],
      participant2: json['participant_2'],
      lastMessage: json['last_message'],
      lastMessageAt: json['last_message_at'] != null 
          ? DateTime.parse(json['last_message_at']) 
          : null,
      createdAt: DateTime.parse(json['created_at']),
      otherUserName: json['other_user_name'],
      otherUserAvatar: json['other_user_avatar'],
      unreadCount: json['unread_count'] ?? 0,
    );
  }
}

class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final DateTime createdAt;
  final bool isRead;
  final String? senderName;
  final String? senderAvatar;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.createdAt,
    required this.isRead,
    this.senderName,
    this.senderAvatar,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      conversationId: json['conversation_id'],
      senderId: json['sender_id'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      isRead: json['is_read'] ?? false,
      senderName: json['sender_name'],
      senderAvatar: json['sender_avatar'],
    );
  }
}