import 'service_model.dart';
import 'customer_model.dart';
import 'payment_model.dart';

class BillModel {
  final int id;
  final int customerId;
  final int adminId;
  final int month;
  final int year;
  final String measurementNumber;
  final num usageValue;
  final num price;
  final int serviceId;
  final bool paid;
  final String ownerToken;
  final ServiceModel? service;
  final CustomerModel? customer;
  final List<PaymentModel>? payments;
  final num? amount;
  final bool? verifiedPayment;

  BillModel({
    required this.id,
    required this.customerId,
    required this.adminId,
    required this.month,
    required this.year,
    required this.measurementNumber,
    required this.usageValue,
    required this.price,
    required this.serviceId,
    required this.paid,
    required this.ownerToken,
    this.service,
    this.customer,
    this.payments,
    this.amount,
    this.verifiedPayment,
  });

  factory BillModel.fromJson(Map<String, dynamic> json) {
    return BillModel(
      id: json['id'] ?? 0,
      customerId: json['customer_id'] ?? 0,
      adminId: json['admin_id'] ?? 0,
      month: json['month'] ?? 0,
      year: json['year'] ?? 0,
      measurementNumber: json['measurement_number'] ?? '',
      usageValue: json['usage_value'] ?? 0,
      price: json['price'] ?? 0,
      serviceId: json['service_id'] ?? 0,
      paid: json['paid'] ?? false,
      ownerToken: json['owner_token'] ?? '',
      service: json['service'] != null ? ServiceModel.fromJson(json['service']) : null,
      customer: json['customer'] != null ? CustomerModel.fromJson(json['customer']) : null,
      payments: json['payments'] != null
          ? (json['payments'] as List).map((p) => PaymentModel.fromJson(p)).toList()
          : null,
      amount: json['amount'],
      verifiedPayment: json['verified_payment'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'admin_id': adminId,
      'month': month,
      'year': year,
      'measurement_number': measurementNumber,
      'usage_value': usageValue,
      'price': price,
      'service_id': serviceId,
      'paid': paid,
      'owner_token': ownerToken,
    };
  }
}