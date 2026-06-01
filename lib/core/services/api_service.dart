import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import '../utils/shared_prefs.dart';

class ApiService {
  static Map<String, String> _getHeaders({bool needAuth = true}) {
    final headers = {
      'Content-Type': 'application/json',
      'app-key': SharedPrefs.getOwnerToken() ?? '',
    };
    if (needAuth && SharedPrefs.getToken() != null) {
      headers['Authorization'] = 'Bearer ${SharedPrefs.getToken()}';
    }
    return headers;
  }

  // Auth
  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.auth),
        headers: {'Content-Type': 'application/json', 'app-key': SharedPrefs.getOwnerToken() ?? ''},
        body: jsonEncode({'username': username, 'password': password}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    }
  }

  static Future<Map<String, dynamic>> registerAdmin(String username, String password, String name, String phone) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.admins),
        headers: {'Content-Type': 'application/json', 'app-key': SharedPrefs.getOwnerToken() ?? ''},
        body: jsonEncode({
          'username': username,
          'password': password,
          'name': name,
          'phone': phone,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    }
  }

  // Profile
  static Future<Map<String, dynamic>> getAdminMe() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.adminMe),
        headers: _getHeaders(),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    }
  }

  static Future<Map<String, dynamic>> getCustomerMe() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.customerMe),
        headers: _getHeaders(),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    }
  }

  // Services CRUD
  static Future<Map<String, dynamic>> getServices() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.services),
        headers: _getHeaders(),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server', 'data': []};
    }
  }

  static Future<Map<String, dynamic>> getServiceById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.services}/$id'),
        headers: _getHeaders(),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    }
  }

  static Future<Map<String, dynamic>> createService(String name, String minUsage, String maxUsage, String price) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.services),
        headers: _getHeaders(),
        body: jsonEncode({
          'name': name,
          'min_usage': minUsage,
          'max_usage': maxUsage,
          'price': price,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    }
  }

  static Future<Map<String, dynamic>> updateService(int id, String name, String minUsage, String maxUsage, String price) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConstants.services}/$id'),
        headers: _getHeaders(),
        body: jsonEncode({
          'name': name,
          'min_usage': minUsage,
          'max_usage': maxUsage,
          'price': price,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    }
  }

  static Future<Map<String, dynamic>> deleteService(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.services}/$id'),
        headers: _getHeaders(),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    }
  }

  // Customers CRUD
  static Future<Map<String, dynamic>> getCustomers() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.customers),
        headers: _getHeaders(),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server', 'data': []};
    }
  }

  static Future<Map<String, dynamic>> getCustomerById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.customers}/$id'),
        headers: _getHeaders(),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    }
  }

  static Future<Map<String, dynamic>> createCustomer({
    required String username,
    required String password,
    required String customerNumber,
    required String address,
    required int serviceId,
    required String name,
    required String phone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.customers),
        headers: _getHeaders(),
        body: jsonEncode({
          'username': username,
          'password': password,
          'customer_number': customerNumber,
          'address': address,
          'service_id': serviceId,
          'name': name,
          'phone': phone,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    }
  }

  static Future<Map<String, dynamic>> updateCustomer(int id, {
    required String customerNumber,
    required String address,
    required int serviceId,
    required String name,
    required String phone,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConstants.customers}/$id'),
        headers: _getHeaders(),
        body: jsonEncode({
          'customer_number': customerNumber,
          'address': address,
          'service_id': serviceId,
          'name': name,
          'phone': phone,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    }
  }

  static Future<Map<String, dynamic>> deleteCustomer(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.customers}/$id'),
        headers: _getHeaders(),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    }
  }

  // Bills CRUD
  static Future<Map<String, dynamic>> getBills() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.bills),
        headers: _getHeaders(),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server', 'data': []};
    }
  }

  static Future<Map<String, dynamic>> getBillById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.bills}/$id'),
        headers: _getHeaders(),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    }
  }

  static Future<Map<String, dynamic>> createBill({
    required int customerId,
    required int month,
    required int year,
    required String measurementNumber,
    required num usageValue,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.bills),
        headers: _getHeaders(),
        body: jsonEncode({
          'customer_id': customerId,
          'month': month,
          'year': year,
          'measurement_number': measurementNumber,
          'usage_value': usageValue,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    }
  }

  static Future<Map<String, dynamic>> updateBill(int id, {
    required int month,
    required int year,
    required String measurementNumber,
    required num usageValue,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConstants.bills}/$id'),
        headers: _getHeaders(),
        body: jsonEncode({
          'month': month,
          'year': year,
          'measurement_number': measurementNumber,
          'usage_value': usageValue,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    }
  }

  static Future<Map<String, dynamic>> deleteBill(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.bills}/$id'),
        headers: _getHeaders(),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    }
  }

  static Future<Map<String, dynamic>> getBillsMe() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.billsMe),
        headers: _getHeaders(),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server', 'data': []};
    }
  }

  // Payments
  static Future<Map<String, dynamic>> getPayments() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.payments),
        headers: _getHeaders(),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server', 'data': []};
    }
  }

  static Future<Map<String, dynamic>> getPaymentsMe() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.paymentsMe),
        headers: _getHeaders(),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server', 'data': []};
    }
  }

  static Future<Map<String, dynamic>> getPaymentMeById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.paymentsMe}/$id'),
        headers: _getHeaders(),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    }
  }

  static Future<Map<String, dynamic>> createPayment(int billId, XFile file) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConstants.payments),
      );
      request.headers['app-key'] = SharedPrefs.getOwnerToken() ?? '';
      request.headers['Authorization'] = 'Bearer ${SharedPrefs.getToken()}';
      request.fields['bill_id'] = billId.toString();

      final bytes = await file.readAsBytes();
      final fileName = file.name.isNotEmpty ? file.name : 'payment_proof.jpg';
      final mimeType = _getMimeType(fileName);
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: fileName,
        contentType: http.MediaType.parse(mimeType),
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    }
  }

  static Future<Map<String, dynamic>> verifyPaymentAccepted(int paymentId) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConstants.payments}/$paymentId'),
        headers: _getHeaders(),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    }
  }

  static Future<Map<String, dynamic>> verifyPaymentRejected(int paymentId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.payments}/$paymentId'),
        headers: _getHeaders(),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    }
  }

  static String _getMimeType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'pdf':
        return 'application/pdf';
      default:
        return 'application/octet-stream';
    }
  }
}