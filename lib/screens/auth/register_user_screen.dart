import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../../core/constants/app_colors.dart';
import '../../core/utils/shared_prefs.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class RegisterUserScreen extends StatefulWidget {
  const RegisterUserScreen({super.key});

  @override
  State<RegisterUserScreen> createState() => _RegisterUserScreenState();
}

class _RegisterUserScreenState extends State<RegisterUserScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    // Validasi semua field wajib diisi
    if (_nameController.text.isEmpty ||
        _usernameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty ||
        _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field harus diisi')),
      );
      return;
    }

    // Password cocok
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password tidak cocok')),
      );
      return;
    }

    // Phone < 10 karakter
    if (_phoneController.text.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nomor telepon tidak valid')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final ownerToken = SharedPrefs.getOwnerToken();

      final customerNumber =
          'CUST-${DateTime.now().millisecondsSinceEpoch}';

      final response = await http.post(
        Uri.parse('https://learn.smktelkom-mlg.sch.id/pdam/customers'),
        headers: {
          'Content-Type': 'application/json',
          'app-key': ownerToken ?? '',
        },
        body: jsonEncode({
          'username': _usernameController.text,
          'password': _passwordController.text,
          'name': _nameController.text,
          'phone': _phoneController.text,
          'address': _addressController.text,
          'customer_number': customerNumber,
          'service_id': 1,
        }),
      );

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Register berhasil! Silakan login'),
            backgroundColor: Colors.green,
          ),
        );
        if (!mounted) return;
        Navigator.pop(context);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Register gagal'),
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryBlue),
          onPressed: () => Navigator.pop(context),
        ),
      ),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header logo WATERCASH (kiri atas)
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
                  const SizedBox(height: 10),
                  Text(
                    'Welcome Back!',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 20),
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
                        Text(
                          'Register User',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _nameController,
                          labelText: 'Name',
                          hintText: 'Enter your name',
                          prefixIcon: Icons.person_outline,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _usernameController,
                          labelText: 'Username',
                          hintText: 'Enter your username',
                          prefixIcon: Icons.account_circle_outlined,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _phoneController,
                          labelText: 'Phone',
                          hintText: 'Enter your phone number',
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
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
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.white,
                            ),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _confirmPasswordController,
                          labelText: 'Confirm Password',
                          hintText: 'Confirm your password',
                          prefixIcon: Icons.lock_outline,
                          obscureText: _obscureConfirmPassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.white,
                            ),
                            onPressed: () => setState(() =>
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword),
                          ),
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _addressController,
                          labelText: 'Home Address',
                          hintText: 'Enter your home address',
                          prefixIcon: Icons.home_outlined,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 24),
                        CustomButton(
                          text: 'Register',
                          isLoading: _isLoading,
                          onPressed: _register,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Sudah punya akun? ',
                          style: TextStyle(color: AppColors.textGrey, fontSize: 13),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            foregroundColor: AppColors.primaryBlue,
                          ),
                          child: Text(
                            'Sign in',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryBlue,
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
    path.quadraticBezierTo(size.width * 0.8, size.height * 0.3,
        size.width * 0.5, size.height * 0.2);
    path.quadraticBezierTo(size.width * 0.3, size.height * 0.1, 0,
        size.height * 0.4);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

