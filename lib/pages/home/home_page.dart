import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kronium/core/admin_auth_service.dart';
import 'package:kronium/core/app_theme.dart';
import 'package:kronium/core/firebase_service.dart';
import 'package:kronium/core/routes.dart';
import 'package:kronium/core/user_auth_service.dart';
import 'package:kronium/models/service_model.dart';


class Project {
  final String title;
  final String date;
  final String status;
  final double progress;

  Project({
    required this.title,
    required this.date,
    required this.status,
    required this.progress,
  });
}

class Testimonial {
  final String name;
  final String comment;
  final int rating;

  Testimonial({
    required this.name,
    required this.comment,
    required this.rating,
  });
}

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
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
        appBar: AppBar(
          title: FadeInLeft(
            child: const Text('KRONIUM PRO', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          actions: [
            FadeInRight(
              child: IconButton(
                icon: const Icon(Iconsax.notification),
                onPressed: () => _showNotifications(),
              ),
            ),
            FadeInRight(
              delay: const Duration(milliseconds: 100),
              child: IconButton(
                icon: Icon(isDarkMode ? Iconsax.sun_1 : Iconsax.moon),
                onPressed: () => _isDarkMode.toggle(),
              ),
            ),
            // User Authentication Buttons
            Obx(() {
              final userAuthService = Get.find<UserAuthService>();
              
              if (userAuthService.isUserLoggedIn.value) {
                return FadeInRight(
                  delay: const Duration(milliseconds: 200),
                  child: IconButton(
                    icon: const Icon(Iconsax.user),
                    onPressed: () => Get.toNamed(AppRoutes.customerDashboard),
                    tooltip: 'My Dashboard',
                  ),
                );
              } else {
                return FadeInRight(
                  delay: const Duration(milliseconds: 200),
                  child: IconButton(
                    icon: const Icon(Iconsax.login),
                    onPressed: () => Get.toNamed(AppRoutes.customerLogin),
                    tooltip: 'Customer Login',
                  ),
                );
              }
            }),
            // Admin Access Button
            Obx(() {
              final adminAuthService = Get.find<AdminAuthService>();
              if (adminAuthService.isAdminLoggedIn.value) {
                return FadeInRight(
                  delay: const Duration(milliseconds: 300),
                  child: IconButton(
                    icon: const Icon(Iconsax.shield_tick),
                    onPressed: () => Get.toNamed(AppRoutes.adminDashboard),
                    tooltip: 'Admin Dashboard',
                  ),
                );
              } else {
                return FadeInRight(
                  delay: const Duration(milliseconds: 300),
                  child: IconButton(
                    icon: const Icon(Iconsax.shield),
                    onPressed: () => Get.toNamed(AppRoutes.adminLogin),
                    tooltip: 'Admin Login',
                  ),
                );
              }
            }),
          ],
          elevation: 0,
          backgroundColor: isDarkMode ? Colors.grey[900] : AppTheme.primaryColor,
          iconTheme: IconThemeData(color: isDarkMode ? Colors.white : Colors.black),
        ),
        drawer: _buildDrawer(),
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) => _currentIndex.value = index,
          children: [
            _buildDashboard(),
            _buildServicesPage(),
          ],
        ),
        floatingActionButton: _buildFloatingActionButton(),
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
            backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
            selectedItemColor: AppTheme.primaryColor,
            unselectedItemColor: Colors.grey,
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
            ],
          ),
        )),
      );
    });
  }

  Widget _buildFloatingActionButton() {
    return FadeInUp(
      delay: const Duration(milliseconds: 500),
      child: FloatingActionButton(
        onPressed: () {
          final userAuthService = Get.find<UserAuthService>();
          if (userAuthService.isUserLoggedIn.value) {
            Get.toNamed(AppRoutes.bookProject);
          } else {
            Get.snackbar(
              'Login Required',
              'Please sign in to book a service',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.orange,
              colorText: Colors.white,
            );
            Get.toNamed(AppRoutes.customerLogin);
          }
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Iconsax.add, color: Colors.white),
      ),
    );
  }

  Widget _buildDrawer() {
    return Obx(() {
      final isDarkMode = _isDarkMode.value;
      final userAuthService = Get.find<UserAuthService>();
      final adminAuthService = Get.find<AdminAuthService>();

      return Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Iconsax.user, color: AppTheme.primaryColor),
                  ),
                  SizedBox(height: 10),
                  Text(
                    userAuthService.isUserLoggedIn.value
                        ? 'Welcome, ${userAuthService.currentUserProfile?.name ?? ''}'
                        : 'Welcome',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Settings & Preferences',
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                  ),
                ],
              ),
            ),

            // --- Account Section ---
            if (userAuthService.isUserLoggedIn.value) ...[
              _drawerItem('My Profile', Iconsax.user_edit, AppRoutes.customerProfile),
              _drawerItem('My Projects', Iconsax.document_text, AppRoutes.projects),
              Divider(),
              _drawerItem('Sign Out', Iconsax.logout, () async {
                await userAuthService.logout();
                Get.back();
              }),
            ] else ...[
              _drawerItem('Sign In', Iconsax.login, AppRoutes.customerLogin),
              _drawerItem('Sign Up', Iconsax.user_add, AppRoutes.customerRegister),
              Divider(),
            ],

            // --- Preferences Section ---
            SwitchListTile(
              title: Text('Dark Mode'),
              value: isDarkMode,
              onChanged: (val) => _isDarkMode.value = val,
              secondary: Icon(isDarkMode ? Iconsax.moon : Iconsax.sun_1),
            ),
            Divider(),

            // --- App Info Section ---
            _drawerItem('About Us', Iconsax.info_circle, () => _showAboutPage()),
            _drawerItem('Contact Us', Iconsax.message, () => _showContactInfo()),
            Divider(),

            // --- Admin Section ---
            if (adminAuthService.isAdminLoggedIn.value) ...[
              _drawerItem('Admin Dashboard', Iconsax.shield_tick, AppRoutes.adminDashboard),
              _drawerItem('Sign Out Admin', Iconsax.logout, () async {
                await adminAuthService.logout();
                Get.back();
              }),
            ] else ...[
              _drawerItem('Admin Login', Iconsax.shield, AppRoutes.adminLogin),
            ],
          ],
        ),
      );
    });
  }

  Widget _drawerItem(String title, IconData icon, dynamic route) {
    return ListTile(
      leading: Obx(() => Icon(icon, color: _isDarkMode.value ? Colors.white : Colors.grey[700])),
      title: Obx(() => Text(
        title,
        style: TextStyle(
          color: _isDarkMode.value ? Colors.white : Colors.grey[700],
          fontWeight: FontWeight.w500,
        ),
      )),
      onTap: () {
        Get.back();
        if (route is String) {
          Get.toNamed(route);
        } else if (route is Function) {
          route();
        }
      },
      hoverColor: AppTheme.primaryColor.withValues(alpha: 0.1),
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Section
          FadeInDown(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Professional Services',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Quality solutions for your business needs',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => Get.toNamed(AppRoutes.bookProject),
                    icon: const Icon(Iconsax.calendar_add),
                    label: const Text('Book Now'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Featured Services
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: const Text(
              'Our Services',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),

          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: StreamBuilder<List<Service>>(
              stream: Get.find<FirebaseService>().getServices(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final services = snapshot.data ?? [];
                final featuredServices = services.take(3).toList();

                if (featuredServices.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(Iconsax.box, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No services available',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: featuredServices.length,
                  itemBuilder: (context, index) {
                    final service = featuredServices[index];
                    return _buildServiceCard(service);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Testimonials
          FadeInUp(
            delay: const Duration(milliseconds: 600),
            child: const Text(
              'What Our Clients Say',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),

          FadeInUp(
            delay: const Duration(milliseconds: 800),
            child: _buildTestimonials(),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(Service service) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => Get.toNamed(AppRoutes.bookProject, arguments: service),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: service.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  service.icon,
                  color: service.color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                service.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                service.category,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              if (service.price != null)
                Text(
                  '\$${service.price}',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestimonials() {
    final testimonials = [
      Testimonial(
        name: 'John Doe',
        comment: 'Excellent service! The team was professional and delivered on time.',
        rating: 5,
      ),
      Testimonial(
        name: 'Jane Smith',
        comment: 'High quality work and great communication throughout the project.',
        rating: 5,
      ),
      Testimonial(
        name: 'Mike Johnson',
        comment: 'Very satisfied with the results. Highly recommended!',
        rating: 5,
      ),
    ];

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: testimonials.length,
        itemBuilder: (context, index) {
          final testimonial = testimonials[index];
          return Container(
            width: 300,
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < testimonial.rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 16,
                    );
                  }),
                ),
                const SizedBox(height: 12),
                Text(
                  testimonial.comment,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Text(
                  '- ${testimonial.name}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildServicesPage() {
    return StreamBuilder<List<Service>>(
      stream: Get.find<FirebaseService>().getServices(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final services = snapshot.data ?? [];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'All Services',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final service = services[index];
                  return _buildServiceCard(service);
                },
              ),
            ],
          ),
        );
      },
    );
  }



  void _showNotifications() {
    Get.snackbar(
      'Notifications',
      'No new notifications',
      snackPosition: SnackPosition.BOTTOM,
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
