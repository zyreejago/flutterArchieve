class PostModel {
  final String id;
  final String userId;
  final String? userName;
  final String? userAvatar;
  final String content;
  final String? imageUrl;
  final String? videoUrl;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.userId,
    this.userName,
    this.userAvatar,
    required this.content,
    this.imageUrl,
    this.videoUrl,
    required this.likesCount,
    required this.commentsCount,
    required this.isLiked,
    required this.createdAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      userId: json['user_id'],
      userName: json['user_name'],
      userAvatar: json['user_avatar'],
      content: json['content'],
      imageUrl: json['image_url'],
      videoUrl: json['video_url'],
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'user_avatar': userAvatar,
      'content': content,
      'image_url': imageUrl,
      'video_url': videoUrl,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'is_liked': isLiked,
      'created_at': createdAt.toIso8601String(),
    };
  }
}