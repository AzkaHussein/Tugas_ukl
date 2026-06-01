class AdminModel {
  final int id;
  final int userId;
  final String name;
  final String phone;
  final String ownerToken;
  final String createdAt;
  final String updatedAt;
  final UserModel? user;

  AdminModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.phone,
    required this.ownerToken,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      ownerToken: json['owner_token'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'phone': phone,
      'owner_token': ownerToken,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class UserModel {
  final int id;
  final String username;
  final String name;
  final String phone;
  final String role;
  final String createdAt;
  final String updatedAt;

  UserModel({
    required this.id,
    required this.username,
    required this.name,
    required this.phone,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'phone': phone,
      'role': role,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}