import 'package:flutter/material.dart';

import '../screens/admin/dashboard/admin_dashboard_screen.dart';
import '../screens/admin/activity/admin_activity_screen.dart';
import '../screens/admin/profile/admin_profile_screen.dart';

class AdminBottomNavbar extends StatelessWidget {
  final int currentIndex;
  const AdminBottomNavbar({super.key, required this.currentIndex});

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
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment_outlined),
          activeIcon: Icon(Icons.assignment),
          label: 'Activity',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      onTap: (index) {
        if (index == currentIndex) return;
        if (index == 0) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => const AdminDashboardScreen(),
            ),
            (route) => false,
          );
        }
        if (index == 1) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => const AdminActivityScreen(),
            ),
            (route) => false,
          );
        }
        if (index == 2) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => const AdminProfileScreen(),
            ),
            (route) => false,
          );
        }
      },
    );
  }
}