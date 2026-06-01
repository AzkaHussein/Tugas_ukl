import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/services/api_service.dart';
import '../../../core/utils/shared_prefs.dart';
import '../../../widgets/admin_bottom_navbar.dart';
import '../../auth/login_screen.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  bool _isLoading = true;
  String _name = '';
  String _username = '';
  String _phone = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.getAdminMe();
      if (!mounted) return;

      // Debug: print response untuk cek struktur
      debugPrint('Admin Me Response: $response');

      if (response['success'] == true) {
        final data = response['data'];
        setState(() {
          _name = data?['name']?.toString() ?? 'Admin';
          _phone = data?['phone']?.toString() ?? '-';
          // cek username di dalam nested 'user' atau langsung di data
          _username = data?['user']?['username']?.toString()
                   ?? data?['username']?.toString()
                   ?? '-';
          _isLoading = false;
        });
      } else {
        // Response tidak success, tetap stop loading
        setState(() {
          _name = 'Admin';
          _phone = '-';
          _username = '-';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading admin profile: $e');
      if (!mounted) return;
      // Pastikan loading berhenti meski error
      setState(() {
        _name = 'Admin';
        _phone = '-';
        _username = '-';
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat profil: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Logout',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin keluar?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(color: const Color(0xFF8A8A9A)),
            ),
          ),
          TextButton(
            onPressed: () async {
              await SharedPrefs.clearAll();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: Text(
              'Logout',
              style: GoogleFonts.poppins(
                color: const Color(0xFFFF3B30),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Profil Admin')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    const bg = Color(0xFFF5F8FF);
    const blue = Color(0xFF1877F2);
    const grey = Color(0xFF8A8A9A);
    const dark = Color(0xFF1A1A2E);
    const white = Colors.white;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // APPBAR CUSTOM
              Container(
                color: white,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                child: Row(
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/water_drop.png',
                          width: 28,
                          height: 28,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'WATERCASH',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: blue,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.notifications_outlined,
                      color: blue,
                      size: 24,
                    ),
                  ],
                ),
              ),

              // SECTION 1 - AVATAR
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 52,
                          backgroundColor: const Color(0xFFE8F0FE),
                          child: Text(
                            _name.isNotEmpty ? _name[0].toUpperCase() : 'A',
                            style: GoogleFonts.poppins(
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              color: blue,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: const BoxDecoration(
                              color: blue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.verified,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _name,
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: dark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _username,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF4FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Administrator',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: blue,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // SECTION 2 - ACCOUNT DETAILS CARD
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Account Details',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: blue,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _detailRow(
                        Icons.phone_outlined,
                        'Contact Number',
                        _phone,
                      ),
                      _detailRow(
                        Icons.email_outlined,
                        'Work Email',
                        '$_username@pdam-cash.com',
                      ),
                      _detailRow(
                        Icons.apartment_outlined,
                        'Department',
                        'System Infrastructure & Operations',
                        isLast: true,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // SECTION 3 - BUTTONS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Fitur segera hadir',
                              style: GoogleFonts.poppins(),
                            ),
                            backgroundColor: blue,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: blue,
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.settings, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Edit Profile',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _handleLogout,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFFE0E0)),
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.logout, color: Color(0xFFFF3B30), size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Logout',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFFF3B30),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AdminBottomNavbar(currentIndex: 2),
    );
  }

  Widget _detailRow(
    IconData icon,
    String label,
    String value, {
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(
                  color: Color(0xFFE0E0E0),
                  width: 1,
                ),
              ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF4FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF1877F2),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF8A8A9A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}