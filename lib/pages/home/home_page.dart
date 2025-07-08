import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kronium/core/admin_auth_service.dart';
import 'package:kronium/core/app_theme.dart';
import 'package:kronium/core/routes.dart';
import 'package:kronium/core/user_auth_service.dart';
import 'package:kronium/pages/services/services_page.dart';
import 'package:kronium/pages/home/home_screen.dart';
import 'package:kronium/pages/projects/projects_page.dart';
import 'package:kronium/widgets/app_drawer.dart';

/// HomePage is the main shell for the app's tabbed navigation.
/// It manages the app bar, drawer, bottom navigation, and tab switching.
class HomePage extends StatelessWidget {
  final RxInt _currentIndex = 0.obs;
  final PageController _pageController = PageController();
  final RxBool _isDarkMode = false.obs;

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDarkMode = _isDarkMode.value;
      return Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        // Show app bar only on Home tab
        appBar: _currentIndex.value == 0
            ? AppBar(
          title: FadeInLeft(
                  child: const Text('KRONIUM', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          actions: [
            FadeInRight(
              child: IconButton(
                icon: const Icon(Iconsax.notification),
                onPressed: () => _showNotifications(),
              ),
            ),
          ],
          elevation: 0,
                backgroundColor: AppTheme.primaryColor,
          iconTheme: IconThemeData(color: isDarkMode ? Colors.white : Colors.black),
              )
            : null,
        // Beautiful, modular drawer
        drawer: AppDrawer(
          isDarkMode: isDarkMode,
          userAuthService: Get.find<UserAuthService>(),
          adminAuthService: Get.find<AdminAuthService>(),
          onDarkModeChanged: (val) => _isDarkMode.value = val,
          onShowAbout: _showAboutPage,
          onShowContact: _showContactInfo,
        ),
        // Main tabbed content
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) => _currentIndex.value = index,
          children: const [
            HomeScreen(),
            ServicesPage(),
            ProjectsPage(),
          ],
        ),
            // Themed bottom navigation
        bottomNavigationBar: Obx(() => FadeInUp(
          child: BottomNavigationBar(
            currentIndex: _currentIndex.value,
            onTap: (index) {
              _currentIndex.value = index;
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            },
            backgroundColor: AppTheme.surfaceLight,
            selectedItemColor: AppTheme.primaryColor,
            unselectedItemColor: AppTheme.secondaryColor,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Iconsax.home_2),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Iconsax.box),
                label: 'Services',
              ),
              BottomNavigationBarItem(
                icon: Icon(Iconsax.document_text),
                label: 'Projects',
              ),
            ],
          ),
        )),
      );
    });
  }

  
  /// Show notifications (placeholder)
  void _showNotifications() {
    Get.snackbar(
      'Notifications',
      'No new notifications',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Show about dialog
  void _showAboutPage() {
    Get.dialog(
      AlertDialog(
        title: const Text('About Us'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Professional Excellence',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'We are committed to delivering high-quality services to our clients. '
                'With years of experience and a dedicated team of professionals, '
                'we ensure that every project meets the highest standards.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Our Mission',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'To provide innovative solutions that exceed client expectations '
                'while maintaining the highest standards of quality and professionalism.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Our Values',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildValueItem('Quality', 'We never compromise on quality'),
              _buildValueItem('Innovation', 'We embrace new technologies and methods'),
              _buildValueItem('Integrity', 'We maintain the highest ethical standards'),
              _buildValueItem('Customer Focus', 'Your success is our priority'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Show contact info dialog
  void _showContactInfo() {
    Get.dialog(
      AlertDialog(
        title: const Text('Contact Us'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildContactItem(Iconsax.sms, 'Email', 'info@kroniumpro.com'),
            const SizedBox(height: 12),
            _buildContactItem(Iconsax.call, 'Phone', '+1 (555) 123-4567'),
            const SizedBox(height: 12),
            _buildContactItem(Iconsax.location, 'Address', '123 Business St, City, State 12345'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Helper for about dialog values
  Widget _buildValueItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// Helper for contact info dialog
  Widget _buildContactItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryColor),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
