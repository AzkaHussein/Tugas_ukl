import 'package:flutter/material.dart';
import 'auth/login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1877F2),
        foregroundColor: Colors.white,
        title: const Text('WATERCASH'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/water_drop.png',
              width: 80,
            ),
            const SizedBox(height: 16),
            const Text(
              'Selamat Datang!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1877F2),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Dashboard sedang dalam pengembangan',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF8A8A9A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}