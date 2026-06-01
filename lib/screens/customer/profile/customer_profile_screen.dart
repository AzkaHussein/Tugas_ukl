import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/shared_prefs.dart';
import '../../auth/login_screen.dart';
import '../../../widgets/customer_bottom_navbar.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  bool _isLoading = true;
  String _name = '';
  String _username = '';
  String _phone = '';
  String _customerNumber = '';
  String _address = '';
  String _serviceName = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.getCustomerMe();
      if (!mounted) return;
      if (response['success'] == true) {
        setState(() {
          _name = response['data']['name'] ?? 'Customer';
          _phone = response['data']['phone'] ?? '-';
          _username = response['data']['user']?['username'] ?? '-';
          _customerNumber = response['data']['customer_number'] ?? '-';
          _address = response['data']['address'] ?? '-';
          _serviceName = response['data']['service']?['name'] ?? '-';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  String _getInitial(String name) {
    if (name.isEmpty) return '-';
    return name[0].toUpperCase();
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
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
            child: const Text('Logout', style: TextStyle(color: Color(0xFFFF3B30))),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomAppBar(double topPadding) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        top: topPadding + 8,
        left: 20,
        right: 20,
        bottom: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1877F2),
                ),
              ),
            ],
          ),
          const Icon(
            Icons.notifications_outlined,
            color: Color(0xFF1877F2),
            size: 28,
          ),
        ],
      ),
    );
  }

  Widget _infoCard(IconData icon, String label, String value, {Widget? trailing}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1877F2), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    color: const Color(0xFF8A8A9A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildCustomAppBar(topPadding),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        _buildAvatarSection(),
                        const SizedBox(height: 20),
                        _buildInfoCards(),
                        const SizedBox(height: 8),
                        _buildButtons(),
                        const SizedBox(height: 16),
                        _buildDataProtection(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: const CustomerBottomNavbar(currentIndex: 2),
    );
  }

  Widget _buildAvatarSection() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xFFE8F0FE),
              child: Text(
                _getInitial(_name),
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1877F2),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Color(0xFF1877F2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          _name,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFE8F0FE),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Text(
            'PREMIUM CUSTOMER',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              color: const Color(0xFF1877F2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _infoCard(
            Icons.badge_outlined,
            'CUSTOMER NUMBER',
            _customerNumber,
          ),
          _infoCard(
            Icons.person_outline,
            'USERNAME',
            _username,
          ),
          _infoCard(
            Icons.shield_outlined,
            'ACCOUNT ROLE',
            'Customer',
          ),
          _infoCard(
            Icons.phone_outlined,
            'CONTACT NUMBER',
            _phone,
            trailing: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Text(
                'Verified',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          _infoCard(
            Icons.location_on_outlined,
            'ADDRESS',
            _address,
          ),
          _infoCard(
            Icons.water_drop_outlined,
            'SERVICE PACKAGE',
            _serviceName,
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1877F2),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
                    fontWeight: FontWeight.bold,
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
              foregroundColor: const Color(0xFFFF3B30),
              minimumSize: const Size(double.infinity, 52),
              side: const BorderSide(color: Color(0xFFFFE0E0)),
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
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFF3B30),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataProtection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEEF2FF),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline, color: Color(0xFF1877F2), size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DATA PROTECTION',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: const Color(0xFF1877F2),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your personal information is managed according to the municipal privacy policy and encrypted using industry standards',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF4A4A6A),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}