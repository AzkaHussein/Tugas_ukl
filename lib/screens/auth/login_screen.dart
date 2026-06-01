import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/app_colors.dart';
import '../../core/utils/shared_prefs.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../admin/dashboard/admin_dashboard_screen.dart';
import '../customer/dashboard/customer_dashboard_screen.dart';
import 'register_screen.dart';
import 'register_user_screen.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _rememberMe = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username dan password wajib diisi')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final ownerToken = SharedPrefs.getOwnerToken();

      final response = await http.post(
        Uri.parse('https://learn.smktelkom-mlg.sch.id/pdam/auth'),
        headers: {
          'Content-Type': 'application/json',
          'app-key': ownerToken ?? '',
        },
        body: jsonEncode({
          'username': _usernameController.text,
          'password': _passwordController.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        if (!mounted) return;
        // simpan token dan role
        await SharedPrefs.saveToken(data['token']);
        if (!mounted) return;
        await SharedPrefs.saveRole(data['role']);

        // routing berdasarkan role
        if (!mounted) return;
        if (data['role'] == 'ADMIN') {
          Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const AdminDashboardScreen()));
        } else if (data['role'] == 'CUSTOMER') {
          Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const CustomerDashboardScreen()));
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Login gagal'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Koneksi gagal, coba lagi'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Blue wave decoration at top right
          Positioned(
            top: 0,
            right: 0,
            child: CustomPaint(
              size: const Size(200, 200),
              painter: WavePainter(),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    // Header
                    Row(
                      children: [
                        Icon(
                          Icons.water_drop,
                          color: AppColors.primaryBlue,
                          size: 28,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'WATERCASH',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Welcome Back!',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Main Card
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryBlue.withValues(alpha: 0.3),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextField(
                            controller: _usernameController,
                            labelText: 'Email Or User Name',
                            hintText: 'Enter your Email here',
                            prefixIcon: Icons.email_outlined,
                            suffixIcon: _usernameController.text.isNotEmpty
                                ? const Icon(Icons.check_circle, color: AppColors.primaryBlue)
                                : null,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _passwordController,
                            labelText: 'Password',
                            hintText: 'Enter your password',
                            prefixIcon: Icons.lock_outline,
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: AppColors.primaryBlue,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: Checkbox(
                                      value: _rememberMe,
                                      onChanged: (v) => setState(() => _rememberMe = v ?? false),
                                      activeColor: Colors.white,
                                      checkColor: AppColors.primaryBlue,
                                      side: const BorderSide(color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Remember me',
                                    style: TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                ],
                              ),
                              const Text(
                                'Forgot Password?',
                                style: TextStyle(color: Colors.white, fontSize: 12, decoration: TextDecoration.underline),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          CustomButton(
                            text: 'Sign in',
                            isLoading: _isLoading,
                            onPressed: _login,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          const Text(
                            'OR LOGIN WITH',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF1877F2),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Belum punya akun?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF8A8A9A),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const RegisterScreen()),
                            ),
                            child: const Text(
                              'Register Admin',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF1877F2),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const RegisterUserScreen()),
                            ),
                            child: const Text(
                              'Register User',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF1877F2),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryBlue.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width, 0);
    path.quadraticBezierTo(size.width * 0.8, size.height * 0.3, size.width * 0.5, size.height * 0.2);
    path.quadraticBezierTo(size.width * 0.3, size.height * 0.1, 0, size.height * 0.4);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}