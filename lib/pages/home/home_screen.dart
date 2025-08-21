import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import 'package:kronium/core/constants.dart';
import 'package:kronium/widgets/background_switcher.dart';
import 'package:kronium/core/app_theme.dart';
import 'package:kronium/core/routes.dart';
import 'package:kronium/core/firebase_service.dart';
import 'package:kronium/core/user_auth_service.dart'
    show userController, UserAuthService;
import 'package:kronium/models/project_model.dart';
import 'package:kronium/core/services_data.dart';
import 'package:flutter_social_button/flutter_social_button.dart';

/// Keep this widget focused and readable. Extend as needed.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentSlide = 0;
  final CarouselSliderController carouselController =
      CarouselSliderController();

  // Helper method to build status items
  Widget _buildStatusItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.7)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Helper method to build quick action cards
  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.1),
              color.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: color.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Mock testimonials (replace with real data as needed)

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> companySlides =
        AppConstants.companySlidesData;

    return BackgroundSwitcher(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section with Logo, User Name, and User ID
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.95),
                      Colors.white.withValues(alpha: 0.85),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // App Logo and User Info Row
                    Row(
                      children: [
                        // App Logo
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor.withValues(
                                  alpha: 0.2,
                                ),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.asset(
                              'assets/images/logo.jpg',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: const Icon(
                                    Icons.agriculture,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        // User Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // User Full Name
                              Obx(() {
                                final userName =
                                    userController.userProfile.value?.name ??
                                    'User';
                                return Text(
                                  userName,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                    letterSpacing: 0.5,
                                  ),
                                );
                              }),
                              const SizedBox(height: 4),
                              // User ID
                              Obx(() {
                                final userId =
                                    userController.userProfile.value?.id ??
                                    userController.userId.value;
                                return Text(
                                  'ID: ${userId.isNotEmpty ? userId : 'N/A'}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                    fontFamily: 'monospace',
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Welcome Message
                    Text(
                      'Welcome to Kronium',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your trusted partner for innovative agricultural and construction solutions',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              // Quick Actions Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.95),
                      Colors.white.withValues(alpha: 0.85),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Quick Actions',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        Icon(
                          Icons.bolt,
                          color: AppTheme.primaryColor,
                          size: 24,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickActionCard(
                            icon: Icons.construction,
                            title: 'Our Services',
                            subtitle: 'Explore solutions',
                            color: AppTheme.primaryColor,
                            onTap: () => Get.toNamed(AppRoutes.services),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickActionCard(
                            icon: Icons.phone,
                            title: 'Contact Us',
                            subtitle: 'Get in touch',
                            color: AppTheme.secondaryColor,
                            onTap: () {},
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickActionCard(
                            icon: Icons.assignment_turned_in_outlined,
                            title: 'Projects',
                            subtitle: 'Bookings & progress',
                            color: Colors.teal,
                            onTap: () => Get.toNamed(AppRoutes.projects),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickActionCard(
                            icon: Icons.description_outlined,
                            title: 'Book Project',
                            subtitle: 'Request a quote',
                            color: Colors.indigo,
                            onTap: () => Get.toNamed(AppRoutes.projects),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Company Stats Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor.withValues(alpha: 0.1),
                      AppTheme.secondaryColor.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Company Overview',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        Icon(
                          Icons.business,
                          color: AppTheme.primaryColor,
                          size: 24,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatusItem(
                            icon: Icons.access_time,
                            title: 'Business Hours',
                            subtitle: 'Mon - Fri: 8:00 AM - 6:00 PM',
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 50,
                          color: AppTheme.primaryColor.withValues(alpha: 0.2),
                        ),
                        Expanded(
                          child: _buildStatusItem(
                            icon: Icons.location_on,
                            title: 'Location',
                            subtitle: 'Zimbabwe',
                            color: AppTheme.secondaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatusItem(
                            icon: Icons.engineering,
                            title: 'Services',
                            subtitle: '6 Core Services',
                            color: Colors.teal,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 50,
                          color: AppTheme.primaryColor.withValues(alpha: 0.2),
                        ),
                        Expanded(
                          child: _buildStatusItem(
                            icon: Icons.people,
                            title: 'Programs',
                            subtitle: '11 Specialized Programs',
                            color: Colors.indigo,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Featured Services Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white.withValues(alpha: 0.95),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Featured Services',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Get.toNamed(AppRoutes.services),
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: servicesData.length,
                        itemBuilder: (context, index) {
                          final s = servicesData[index];
                          return Container(
                            width: 160,
                            margin: const EdgeInsets.only(right: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.primaryColor.withValues(alpha: 0.08),
                                  AppTheme.secondaryColor.withValues(alpha: 0.06),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(
                                color: AppTheme.primaryColor.withValues(alpha: 0.12),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  s['icon'] as IconData,
                                  color: AppTheme.primaryColor,
                                  size: 24,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  s['title'] as String,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  s['description'] as String,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // Active projects for current user (top 3)
              Obx(() {
                final isLoggedIn =
                    UserAuthService.instance.isUserLoggedIn.value;
                if (!isLoggedIn) return const SizedBox.shrink();
                final userId =
                    userController.userProfile.value?.id ??
                    userController.userId.value;
                if (userId.isEmpty) return const SizedBox.shrink();
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'My Active Projects',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 12),
                      StreamBuilder<List<Project>>(
                        stream: FirebaseService.instance.getProjects(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Text('No active projects yet.');
                          }
                          final mine =
                              snapshot.data!
                                  .where(
                                    (p) => p.bookedDates.any(
                                      (d) => d.clientId == userId,
                                    ),
                                  )
                                  .toList();
                          if (mine.isEmpty) {
                            return const Text('No active projects yet.');
                          }
                          mine.sort((a, b) => b.progress.compareTo(a.progress));
                          final top = mine.take(3).toList();
                          return Column(
                            children:
                                top.map((p) {
                                  final status =
                                      p.progress >= 100
                                          ? 'Completed'
                                          : (p.progress > 0
                                              ? 'In Progress'
                                              : 'Booked');
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppTheme.primaryColor.withValues(
                                          alpha: 0.12,
                                        ),
                                      ),
                                      color: Colors.white,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                p.title,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Chip(
                                              label: Text(status),
                                              backgroundColor:
                                                  status == 'Completed'
                                                      ? Colors.green
                                                      : status == 'In Progress'
                                                      ? Colors.orange
                                                      : AppTheme.primaryColor,
                                              labelStyle: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        LinearProgressIndicator(
                                          value:
                                              (p.progress.clamp(0, 100)) / 100,
                                          minHeight: 6,
                                          backgroundColor:
                                              AppTheme.surfaceLight,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                status == 'Completed'
                                                    ? Colors.green
                                                    : status == 'In Progress'
                                                    ? Colors.orange
                                                    : AppTheme.primaryColor,
                                              ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Get.toNamed(AppRoutes.projects),
                          child: const Text('Open Projects'),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              ContactCard(
                contacts:
                    companySlides.firstWhere(
                      (s) => s['title'] == 'CONTACT & OFFICES',
                    )['body'],
                socials:
                    companySlides.firstWhere(
                      (s) => s['title'] == 'CONTACT & OFFICES',
                    )['socials'],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ContactCard extends StatelessWidget {
  final List<Map<String, dynamic>> contacts;
  final List<Map<String, dynamic>>? socials;
  const ContactCard({required this.contacts, this.socials, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      color: AppTheme.primaryColor.withValues(alpha: 0.80),
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.contact_phone_outlined,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 10),
                const Text(
                  'Contact & Offices',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...contacts.map((item) {
              if (item['type'] == 'phone') {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: GestureDetector(
                    onTap: () => launchUrl(Uri.parse('tel:${item['value']}')),
                    child: Row(
                      children: [
                        const Icon(Icons.phone, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          item['value'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else if (item['type'] == 'email') {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: GestureDetector(
                    onTap:
                        () => launchUrl(Uri.parse('mailto:${item['value']}')),
                    child: Row(
                      children: [
                        const Icon(Icons.email, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          item['value'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else if (item['type'] == 'address') {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item['value'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
            // Website link
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: GestureDetector(
                onTap: () => launchUrl(Uri.parse('https://www.kronium.co.zw')),
                child: Row(
                  children: [
                    const Icon(Icons.language, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'www.kronium.co.zw',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            // Social media icons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // LinkedIn
                SizedBox(
                  width: 48,
                  height: 48,
                  child: FlutterSocialButton(
                    onTap:
                        () => launchUrl(
                          Uri.parse('https://linkedin.com/company/kronium'),
                        ),
                    buttonType: ButtonType.linkedin,
                    title: '',
                  ),
                ),
                const SizedBox(width: 12),
                // Instagram
                SizedBox(
                  width: 48,
                  height: 48,
                  child: FlutterSocialButton(
                    onTap:
                        () => launchUrl(
                          Uri.parse('https://instagram.com/kronium'),
                        ),
                    buttonType: ButtonType.instagram,
                    title: '',
                  ),
                ),
                const SizedBox(width: 12),
                // Facebook
                SizedBox(
                  width: 48,
                  height: 48,
                  child: FlutterSocialButton(
                    onTap:
                        () => launchUrl(
                          Uri.parse('https://facebook.com/kronium'),
                        ),
                    buttonType: ButtonType.facebook,
                    title: '',
                  ),
                ),
                const SizedBox(width: 12),
                // WhatsApp
                SizedBox(
                  width: 48,
                  height: 48,
                  child: FlutterSocialButton(
                    onTap:
                        () =>
                            launchUrl(Uri.parse('https://wa.me/263784148718')),
                    buttonType: ButtonType.whatsapp,
                    title: '',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
