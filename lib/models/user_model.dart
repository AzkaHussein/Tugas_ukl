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