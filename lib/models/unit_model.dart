// lib/models/unit_model.dart
class UnitModel {
  final String id;
  final String title;
  final int unitNumber;
  final int chapterCount;
  final bool completed;
  final DateTime createdAt;
  final String? iconName; // Font Awesome icon name
  final String? youtubeLink; // Added YouTube link field

  UnitModel({
    required this.id,
    required this.title,
    required this.unitNumber,
    required this.chapterCount,
    this.completed = false,
    required this.createdAt,
    this.iconName,
    this.youtubeLink, // Added to constructor
  });

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      id: json['id'],
      title: json['title'],
      unitNumber: json['unit_number'],
      chapterCount: json['chapter_count'],
      completed: json['completed'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      iconName: json['icon_name'],
      youtubeLink: json['youtube_link'], // Parse from JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'unit_number': unitNumber,
      'chapter_count': chapterCount,
      'completed': completed,
      'created_at': createdAt.toIso8601String(),
      'icon_name': iconName,
      'youtube_link': youtubeLink, // Add to JSON output
    };
  }
}