import 'package:flutter/material.dart';

import '../screens/customer/dashboard/customer_dashboard_screen.dart';
import '../screens/customer/activity/customer_activity_screen.dart';
import '../screens/customer/profile/customer_profile_screen.dart';

class CustomerBottomNavbar extends StatelessWidget {
  final int currentIndex;
  const CustomerBottomNavbar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: const Color(0xFF1877F2),
      unselectedItemColor: const Color(0xFF8A8A9A),
      backgroundColor: Colors.white,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Beranda',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment_outlined),
          activeIcon: Icon(Icons.assignment),
          label: 'Aktivitas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
      onTap: (index) {
        if (index == currentIndex) return;
        if (index == 0) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => const CustomerDashboardScreen(),
            ),
            (route) => false,
          );
        }
        if (index == 1) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => const CustomerActivityScreen(),
            ),
            (route) => false,
          );
        }
        if (index == 2) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => const CustomerProfileScreen(),
            ),
            (route) => false,
          );
        }
      },
    );
  }
}

