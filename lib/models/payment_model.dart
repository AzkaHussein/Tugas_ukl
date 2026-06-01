import 'bill_model.dart';

class PaymentModel {
  final int id;
  final int billId;
  final String paymentDate;
  final bool verified;
  final num totalAmount;
  final String paymentProof;
  final String ownerToken;
  final BillModel? bill;

  PaymentModel({
    required this.id,
    required this.billId,
    required this.paymentDate,
    required this.verified,
    required this.totalAmount,
    required this.paymentProof,
    required this.ownerToken,
    this.bill,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] ?? 0,
      billId: json['bill_id'] ?? 0,
      paymentDate: json['payment_date'] ?? '',
      verified: json['verified'] ?? false,
      totalAmount: json['total_amount'] ?? 0,
      paymentProof: json['payment_proof'] ?? '',
      ownerToken: json['owner_token'] ?? '',
      bill: json['bill'] != null ? BillModel.fromJson(json['bill']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bill_id': billId,
      'payment_date': paymentDate,
      'verified': verified,
      'total_amount': totalAmount,
      'payment_proof': paymentProof,
      'owner_token': ownerToken,
    };
  }
}