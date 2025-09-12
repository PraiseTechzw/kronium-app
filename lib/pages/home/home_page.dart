import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kronium/core/admin_auth_service.dart';
import 'package:kronium/core/app_theme.dart';
import 'package:kronium/core/user_auth_service.dart';
import 'package:kronium/core/user_controller.dart';
import 'package:kronium/pages/services/services_page.dart';
import 'package:kronium/pages/home/home_screen.dart';
import 'package:kronium/pages/projects/projects_page.dart';
import 'package:kronium/widgets/app_drawer.dart';
import 'package:kronium/pages/customer/customer_chat_page.dart';
import 'package:kronium/pages/customer/customer_dashboard_page.dart';
import 'package:kronium/pages/customer/customer_profile_page.dart';
import 'package:kronium/widgets/background_switcher.dart';

/// HomePage is the main shell for the app's tabbed navigation.
/// It manages the app bar, drawer, bottom navigation, and tab switching.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final RxInt _currentIndex = 0.obs;
  final PageController _pageController = PageController();
  final RxBool _isDarkMode = false.obs;
  final RxBool _viewAsAdmin = true.obs; // Admins can toggle this

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
      final isAdmin = role == 'admin';
      final viewAsAdmin = !isAdmin || _viewAsAdmin.value;

      // Build tab list dynamically
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
          icon: Icon(Iconsax.document_text),
          label: 'Projects',
        ),
      ];

      if (role == 'customer' || (isAdmin && viewAsAdmin)) {
        pages.add(const CustomerChatPage());
        items.add(
          const BottomNavigationBarItem(
            icon: Icon(Iconsax.message),
            label: 'Chat',
          ),
        );
      }

      // Always add Profile/Login as last tab
      items.add(
        BottomNavigationBarItem(
          icon: const Icon(Iconsax.user),
          label: role == 'guest' ? 'Login' : 'Profile',
        ),
      );
      pages.add(const CustomerProfilePage());

      return BackgroundSwitcher(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: null, // HomeScreen has SliverAppBar
          drawer: AppDrawer(
            isDarkMode: isDarkMode,
            userAuthService: Get.find<UserAuthService>(),
            adminAuthService: Get.find<AdminAuthService>(),
            onDarkModeChanged: (val) => _isDarkMode.value = val,
            onShowAbout: _showAboutPage,
            onShowContact: _showContactInfo,
            extraItems:
                isAdmin
                    ? [
                      SwitchListTile(
                        title: Text(
                          viewAsAdmin ? 'Admin View' : 'Customer View',
                        ),
                        value: viewAsAdmin,
                        onChanged: (val) => _viewAsAdmin.value = val,
                        secondary: Icon(
                          viewAsAdmin
                              ? Iconsax.shield_tick
                              : Iconsax.user,
                        ),
                      ),
                    ]
                    : role == 'customer'
                    ? [
                      ListTile(
                        leading: const Icon(Iconsax.activity),
                        title: const Text('Dashboard'),
                        onTap: () {
                          Navigator.of(context).pop();
                          Get.to(() => const CustomerDashboardPage());
                        },
                      ),
                    ]
                    : [],
          ),
          body: PageView(
            controller: _pageController,
            onPageChanged: (index) => _currentIndex.value = index,
            children: pages,
          ),
          floatingActionButton:
              isAdmin && viewAsAdmin
                  ? FloatingActionButton(
                    backgroundColor: AppTheme.primaryColor,
                    child: const Icon(Iconsax.setting_2, color: Colors.white),
                    onPressed: () => _showAdminQuickActions(context),
                  )
                  : null,
          bottomNavigationBar: FadeInUp(
            child: BottomNavigationBar(
              currentIndex: _currentIndex.value,
              onTap: (index) async {
                final isProfileTab = index == _getBottomNavItems().length - 1;
                final isLoggedIn = role != 'guest';

                if (isProfileTab && !isLoggedIn) {
                  Get.toNamed('/customer-login');
                  return;
                }

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
              items: _getBottomNavItems(),
            ),
          ),
        ),
      );
    });
  }

  List<BottomNavigationBarItem> _getBottomNavItems() {
    final userController = Get.find<UserController>();
    final role = userController.role.value;
    final isAdmin = role == 'admin';
    final viewAsAdmin = !isAdmin || _viewAsAdmin.value;

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
        icon: Icon(Iconsax.document_text),
        label: 'Projects',
      ),
    ];

    if (role == 'customer' || (isAdmin && viewAsAdmin)) {
      items.add(
        const BottomNavigationBarItem(
          icon: Icon(Iconsax.message),
          label: 'Chat',
        ),
      );
    }

    items.add(
      BottomNavigationBarItem(
        icon: const Icon(Iconsax.user),
        label: role == 'guest' ? 'Login' : 'Profile',
      ),
    );

    return items;
  }

  void _showAdminQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (context) => Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Admin Quick Actions',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(
                    Iconsax.shield_tick,
                    color: AppTheme.primaryColor,
                  ),
                  title: const Text('Admin Dashboard'),
                  onTap: () {
                    Get.toNamed('/admin-dashboard');
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Iconsax.box,
                    color: AppTheme.primaryColor,
                  ),
                  title: const Text('Manage Services'),
                  onTap: () {
                    Get.toNamed('/admin-services');
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Iconsax.calendar,
                    color: AppTheme.primaryColor,
                  ),
                  title: const Text('Bookings'),
                  onTap: () {
                    Get.toNamed('/admin-bookings');
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Iconsax.message,
                    color: AppTheme.primaryColor,
                  ),
                  title: const Text('Admin Chat'),
                  onTap: () {
                    Get.toNamed('/admin-chat');
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
    );
  }

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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'To provide innovative solutions that exceed client expectations '
                'while maintaining the highest standards of quality and professionalism.',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 20),
              const Text(
                'Our Values',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildValueItem('Quality', 'We never compromise on quality'),
              _buildValueItem(
                'Innovation',
                'We embrace new technologies and methods',
              ),
              _buildValueItem(
                'Integrity',
                'We maintain the highest ethical standards',
              ),
              _buildValueItem('Customer Focus', 'Your success is our priority'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
    );
  }

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
            _buildContactItem(
              Iconsax.location,
              'Address',
              '123 Business St, City, State 12345',
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _buildValueItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          Text(
            description,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

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
              Text(value, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }
}
