import 'user_model.dart';
import 'service_model.dart';

class CustomerModel {
  final int id;
  final int userId;
  final String customerNumber;
  final String name;
  final String phone;
  final String address;
  final int serviceId;
  final String ownerToken;
  final String createdAt;
  final String updatedAt;
  final UserModel? user;
  final ServiceModel? service;

  CustomerModel({
    required this.id,
    required this.userId,
    required this.customerNumber,
    required this.name,
    required this.phone,
    required this.address,
    required this.serviceId,
    required this.ownerToken,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.service,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      customerNumber: json['customer_number'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      serviceId: json['service_id'] ?? 0,
      ownerToken: json['owner_token'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      service: json['service'] != null ? ServiceModel.fromJson(json['service']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'customer_number': customerNumber,
      'name': name,
      'phone': phone,
      'address': address,
      'service_id': serviceId,
      'owner_token': ownerToken,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}