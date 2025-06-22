class DictionaryWord {
  final String id;  // Ubah dari int ke String
  final String word;
  final String meaning;
  final String? videoUrl;
  final String? imageUrl;
  final String categoryId;  // Ubah dari int ke String
  final int searchCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final WordCategory? category;

  DictionaryWord({
    required this.id,
    required this.word,
    required this.meaning,
    this.videoUrl,
    this.imageUrl,
    required this.categoryId,
    required this.searchCount,
    required this.createdAt,
    required this.updatedAt,
    this.category,
  });

  factory DictionaryWord.fromJson(Map<String, dynamic> json) {
    return DictionaryWord(
      id: json['id'],
      word: json['word'],
      meaning: json['description'] ?? json['meaning'] ?? '',  // Sesuaikan dengan kolom database
      videoUrl: json['video_url'],
      imageUrl: json['image_url'],
      categoryId: json['category_id'],
      searchCount: json['search_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      category: json['word_categories'] != null 
          ? WordCategory.fromJson(json['word_categories']) 
          : null,
    );
  }
}

class WordCategory {
  final String id;  // Ubah dari int ke String
  final String name;
  final String displayName;  // Tambahkan field ini
  final String? icon;
  final int orderIndex;  // Tambahkan field ini
  final DateTime createdAt;

  WordCategory({
    required this.id,
    required this.name,
    required this.displayName,
    this.icon,
    required this.orderIndex,
    required this.createdAt,
  });

  factory WordCategory.fromJson(Map<String, dynamic> json) {
    return WordCategory(
      id: json['id'],
      name: json['name'],
      displayName: json['display_name'] ?? json['name'],
      icon: json['icon'],
      orderIndex: json['order_index'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}