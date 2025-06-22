class UserModel {
  final String id;
  final String? email;
  final String? name;
  final String userType; // 'admin' or 'user'
  final DateTime createdAt;

  UserModel({
    required this.id,
    this.email,
    this.name,
    required this.userType,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      userType: json['user_type'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'user_type': userType,
      'created_at': createdAt.toIso8601String(),
    };
  }
}