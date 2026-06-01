import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants/app_colors.dart';
import 'core/utils/shared_prefs.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/admin/dashboard/admin_dashboard_screen.dart';
import 'screens/admin/profile/admin_profile_screen.dart';
import 'screens/admin/services/service_list_screen.dart';
import 'screens/admin/services/service_form_screen.dart';
import 'screens/admin/customers/customer_list_screen.dart';
import 'screens/admin/customers/customer_form_screen.dart';
import 'screens/admin/bills/bill_list_screen.dart';
import 'screens/admin/bills/bill_form_screen.dart';
import 'screens/customer/dashboard/customer_dashboard_screen.dart';
import 'screens/customer/profile/customer_profile_screen.dart';
import 'screens/customer/payments/payment_list_screen.dart';
import 'screens/customer/payments/bill_selection_screen.dart';
import 'screens/customer/payments/payment_detail_bill_screen.dart';
import 'screens/customer/payments/payment_upload_screen.dart';
import 'screens/customer/payments/payment_success_screen.dart';
import 'screens/customer/activity/customer_activity_screen.dart';
import 'screens/admin/activity/admin_activity_screen.dart';
import 'screens/customer/tips/tips_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefs.init();
  runApp(const WaterCashApp());
}

class WaterCashApp extends StatelessWidget {
  const WaterCashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WATERCASH',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primaryBlue,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: GoogleFonts.poppins().fontFamily,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryBlue,
          primary: AppColors.primaryBlue,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/admin-dashboard': (context) => const AdminDashboardScreen(),
        '/admin-profile': (context) => const AdminProfileScreen(),
        '/admin-services': (context) => const ServiceListScreen(),
        '/admin-service-form': (context) => const ServiceFormScreen(isEdit: false),
        '/admin-customers': (context) => const CustomerListScreen(),
        '/admin-customer-form': (context) => const CustomerFormScreen(isEdit: false),
        '/admin-bills': (context) => const BillListScreen(),
        '/admin-bill-form': (context) => const BillFormScreen(isEdit: false),
        '/customer-dashboard': (context) => const CustomerDashboardScreen(),
        '/customer-profile': (context) => const CustomerProfileScreen(),
        '/customer-payments': (context) => const PaymentListScreen(),
        '/customer-activity': (context) => const CustomerActivityScreen(),
        '/admin-activity': (context) => const AdminActivityScreen(),
        '/customer-bill-selection': (context) => const BillSelectionScreen(),
        '/customer-tips': (context) => const TipsScreen(),

      },
    );
  }
}