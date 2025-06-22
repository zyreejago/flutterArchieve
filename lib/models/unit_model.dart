class UnitModel {
  final String? id;
  final String title;
  final String description;
  final String? imageUrl;
  final String? videoUrl;
  final String? youtubeLink;
  final String? iconName;
  final List<String> vocabulary;
  final List<String> phrases;
  final int unitNumber;
  final int chapterCount;
  final bool completed;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UnitModel({
    this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    this.videoUrl,
    this.youtubeLink,
    this.iconName,
    this.vocabulary = const [],
    this.phrases = const [],
    this.unitNumber = 1,
    this.chapterCount = 0,
    this.completed = false,
    this.createdAt,
    this.updatedAt,
  });

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      id: json['id']?.toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'],
      videoUrl: json['video_url'],
      youtubeLink: json['youtube_link'],
      iconName: json['icon_name'],
      vocabulary: json['vocabulary'] != null 
          ? List<String>.from(json['vocabulary']) 
          : [],
      phrases: json['phrases'] != null 
          ? List<String>.from(json['phrases']) 
          : [],
      unitNumber: json['unit_number'] ?? 1,
      chapterCount: json['chapter_count'] ?? 0,
      completed: json['completed'] ?? false,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'video_url': videoUrl,
      'youtube_link': youtubeLink,
      'icon_name': iconName,
      'vocabulary': vocabulary,
      'phrases': phrases,
      'unit_number': unitNumber,
      'chapter_count': chapterCount,
      'completed': completed,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  UnitModel copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    String? videoUrl,
    String? youtubeLink,
    String? iconName,
    List<String>? vocabulary,
    List<String>? phrases,
    int? unitNumber,
    int? chapterCount,
    bool? completed,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UnitModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      youtubeLink: youtubeLink ?? this.youtubeLink,
      iconName: iconName ?? this.iconName,
      vocabulary: vocabulary ?? this.vocabulary,
      phrases: phrases ?? this.phrases,
      unitNumber: unitNumber ?? this.unitNumber,
      chapterCount: chapterCount ?? this.chapterCount,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UnitModel(id: $id, title: $title, description: $description, imageUrl: $imageUrl, videoUrl: $videoUrl, youtubeLink: $youtubeLink, iconName: $iconName, vocabulary: $vocabulary, phrases: $phrases, unitNumber: $unitNumber, chapterCount: $chapterCount, completed: $completed, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UnitModel &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.imageUrl == imageUrl &&
        other.videoUrl == videoUrl &&
        other.youtubeLink == youtubeLink &&
        other.iconName == iconName &&
        other.vocabulary == vocabulary &&
        other.phrases == phrases &&
        other.unitNumber == unitNumber &&
        other.chapterCount == chapterCount &&
        other.completed == completed &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      description,
      imageUrl,
      videoUrl,
      youtubeLink,
      iconName,
      vocabulary,
      phrases,
      unitNumber,
      chapterCount,
      completed,
      createdAt,
      updatedAt,
    );
  }
}