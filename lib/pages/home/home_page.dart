import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kronium/core/app_theme.dart';
import 'package:kronium/core/user_auth_service.dart';
import 'package:kronium/core/user_controller.dart';
import 'package:kronium/pages/services/services_page.dart';
import 'package:kronium/pages/home/home_screen.dart';
import 'package:kronium/pages/projects/projects_page.dart';
import 'package:kronium/widgets/app_drawer.dart';
import 'package:kronium/pages/customer/customer_chat_page.dart';
import 'package:kronium/pages/profile/profile_page.dart';
import 'package:kronium/widgets/background_switcher.dart';

/// HomePage is the main shell for the app's tabbed navigation.
/// Customer-only version with admin functionality removed.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final RxInt _currentIndex = 0.obs;
  final PageController _pageController = PageController();
  final RxBool _isDarkMode = false.obs;

  @override
  void initState() {
    super.initState();
    final userController = Get.find<UserController>();
    final userAuthService = Get.find<UserAuthService>();

    // Check authentication status and redirect if needed
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Give services time to initialize and load user profile
      await Future.delayed(const Duration(milliseconds: 2000));

      if (!userAuthService.isUserLoggedIn.value &&
          userController.role.value == 'guest') {
        print(
          'HomePage: User not logged in, redirecting to customer register...',
        );
        Get.offAllNamed('/customer-register');
        return;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();

    return Obx(() {
      final isDarkMode = _isDarkMode.value;
      final role = userController.role.value;

      // Build tab list dynamically - Customer focused
      final List<Widget> pages = [
        const HomeScreen(),
        const ServicesPage(),
        const ProjectsPage(),
      ];

      final List<BottomNavigationBarItem> items = [
        const BottomNavigationBarItem(
          icon: Icon(Iconsax.home_2),
          label: 'Home',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Iconsax.box),
          label: 'Services',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Iconsax.folder_2),
          label: 'Projects',
        ),
      ];

      // Add customer chat for customers
      if (role == 'customer') {
        pages.add(const CustomerChatPage());
        items.add(
          const BottomNavigationBarItem(
            icon: Icon(Iconsax.message),
            label: 'Chat',
          ),
        );
      }

      // Add profile tab
      pages.add(const ProfilePage());
      items.add(
        BottomNavigationBarItem(
          icon: const Icon(Iconsax.user),
          label: role == 'guest' ? 'Login' : 'Profile',
        ),
      );

      return BackgroundSwitcher(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: null, // HomeScreen has SliverAppBar
          drawer: AppDrawer(
            isDarkMode: isDarkMode,
            onDarkModeChanged: (value) => _isDarkMode.value = value,
            onShowAbout: _showAboutInfo,
            onShowContact: _showContactInfo,
          ),
          body: PageView(
            controller: _pageController,
            onPageChanged: (index) => _currentIndex.value = index,
            children: pages,
          ),
          bottomNavigationBar: Obx(
            () => BottomNavigationBar(
              currentIndex: _currentIndex.value,
              onTap: (index) {
                _currentIndex.value = index;
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
              selectedItemColor: AppTheme.primaryColor,
              unselectedItemColor: Colors.grey,
              elevation: 8,
              items: _buildBottomNavItems(),
            ),
          ),
        ),
      );
    });
  }

  List<BottomNavigationBarItem> _buildBottomNavItems() {
    final userController = Get.find<UserController>();
    final role = userController.role.value;

    final List<BottomNavigationBarItem> items = [
      const BottomNavigationBarItem(icon: Icon(Iconsax.home_2), label: 'Home'),
      const BottomNavigationBarItem(icon: Icon(Iconsax.box), label: 'Services'),
      const BottomNavigationBarItem(
        icon: Icon(Iconsax.folder_2),
        label: 'Projects',
      ),
    ];

    // Add customer chat for customers
    if (role == 'customer') {
      items.add(
        const BottomNavigationBarItem(
          icon: Icon(Iconsax.message),
          label: 'Chat',
        ),
      );
    }

    // Add profile tab
    items.add(
      BottomNavigationBarItem(
        icon: const Icon(Iconsax.user),
        label: role == 'guest' ? 'Login' : 'Profile',
      ),
    );

    return items;
  }

  void _showAboutInfo() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('About Kronium'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('🌾 Kronium - Agricultural & Construction Services'),
                SizedBox(height: 8),
                Text('📱 Version: 1.0.0'),
                SizedBox(height: 8),
                Text(
                  '🏢 Your trusted partner for agricultural and construction solutions',
                ),
                SizedBox(height: 8),
                Text('© 2024 Kronium. All rights reserved.'),
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

  void _showContactInfo() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Contact Information'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('📧 Email: support@kronium.com'),
                SizedBox(height: 8),
                Text('📞 Phone: +1 (555) 123-4567'),
                SizedBox(height: 8),
                Text('🌐 Website: www.kronium.com'),
                SizedBox(height: 8),
                Text('📍 Address: 123 Agriculture St, Farm City, FC 12345'),
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
}
