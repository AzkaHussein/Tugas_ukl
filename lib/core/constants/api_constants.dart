class ApiConstants {
  static const String baseUrl = 'https://learn.smktelkom-mlg.sch.id/pdam';

  // Auth
  static const String auth = '$baseUrl/auth';

  // Admin
  static const String admins = '$baseUrl/admins';
  static const String adminMe = '$baseUrl/admins/me';

  // Customer
  static const String customers = '$baseUrl/customers';
  static const String customerMe = '$baseUrl/customers/me';

  // Services (Layanan)
  static const String services = '$baseUrl/services';

  // Bills
  static const String bills = '$baseUrl/bills';
  static const String billsMe = '$baseUrl/bills/me';

  // Payments
  static const String payments = '$baseUrl/payments';
  static const String paymentsMe = '$baseUrl/payments/me';
  static String paymentProof(String fileName) => '$baseUrl/payment-proof/$fileName';
}