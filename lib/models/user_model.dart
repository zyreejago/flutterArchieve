class UserModel {
  final String id;
  final String? email;
  final String userType; // 'admin' or 'user'
  final DateTime createdAt;

  UserModel({
    required this.id,
    this.email,
    required this.userType,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      userType: json['user_type'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'user_type': userType,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
