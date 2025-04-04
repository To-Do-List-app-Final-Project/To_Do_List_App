// lib/features/auth/data/models/user_model.dart

class UserModel {
  final String id;
  final String username;
  final String email;

  const UserModel({
    required this.id,
    required this.username,
    required this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Check if the data is nested under 'data' key
    final userData = json.containsKey('data') ? json['data'] : json;

    return UserModel(
      id: userData['_id']?.toString() ?? '',
      username: userData['username'] ?? '',
      email: userData['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'email': email,
    };
  }

  UserModel copyWith({
    String? id,
    String? username,
    String? email,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
    );
  }
}
