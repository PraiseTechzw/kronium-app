import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kronium/core/app_theme.dart';
import 'package:kronium/pages/admin/admin_dashboard_page.dart';
import 'package:kronium/pages/admin/admin_management_page.dart';
import 'package:kronium/pages/admin/admin_services_page.dart';
import 'package:kronium/pages/admin/admin_bookings_page.dart';
import 'package:kronium/pages/admin/admin_chat_page.dart';
import 'package:kronium/pages/profile/profile_page.dart';

class AdminMainPage extends StatefulWidget {
  final int initialTab;
  
  const AdminMainPage({super.key, this.initialTab = 0});

  @override
  State<AdminMainPage> createState() => _AdminMainPageState();
}

class _AdminMainPageState extends State<AdminMainPage> {
  late int _currentIndex;

  final List<Widget> _pages = [
    const AdminDashboardPage(),
    const AdminManagementPage(),
    const AdminServicesPage(),
    const AdminBookingsPage(),
    const AdminChatPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Iconsax.home_2,
                  label: 'Home',
                  index: 0,
                ),
                _buildNavItem(
                  icon: Iconsax.setting_2,
                  label: 'Manage',
                  index: 1,
                ),
                _buildNavItem(icon: Iconsax.box, label: 'Services', index: 2),
                _buildNavItem(
                  icon: Iconsax.calendar,
                  label: 'Bookings',
                  index: 3,
                ),
                _buildNavItem(icon: Iconsax.message, label: 'Chat', index: 4),
                _buildNavItem(icon: Iconsax.user, label: 'Profile', index: 5),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppTheme.primaryColor.withOpacity(0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryColor : Colors.grey[600],
              size: 20,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.primaryColor : Colors.grey[600],
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
