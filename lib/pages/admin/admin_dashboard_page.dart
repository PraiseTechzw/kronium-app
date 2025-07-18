import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animate_do/animate_do.dart';
import 'package:kronium/core/admin_auth_service.dart';
import 'package:kronium/core/app_theme.dart';
import 'package:kronium/core/firebase_service.dart';
import 'package:kronium/core/routes.dart';
import 'package:kronium/widgets/app_drawer.dart';
import 'package:kronium/widgets/admin_scaffold.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    final adminAuthService = Get.find<AdminAuthService>();
    final firebaseService = Get.find<FirebaseService>();

    return AdminScaffold(
      title: 'Admin Dashboard',
        actions: [
          IconButton(
            icon: const Icon(Iconsax.logout),
            onPressed: () async {
              await adminAuthService.logout();
              Get.offAllNamed(AppRoutes.home);
            },
          ),
        ],
        isDarkMode: _isDarkMode,
        onDarkModeChanged: (val) => setState(() => _isDarkMode = val),
      body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              FadeInDown(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Iconsax.shield_tick,
                          color: AppTheme.primaryColor,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back, Admin!',
                          style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Manage your business efficiently',
                              style: TextStyle(
                                fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Statistics Cards
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: FutureBuilder<Map<String, dynamic>>(
                  future: firebaseService.getAdminStats(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final stats = snapshot.data ?? {
                      'totalServices': 0,
                      'totalBookings': 0,
                      'pendingBookings': 0,
                    };

                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.2,
                      children: [
                        _buildStatCard(
                          'Total Services',
                          stats['totalServices'].toString(),
                          Iconsax.box,
                          Colors.blue,
                        ),
                        _buildStatCard(
                          'Total Bookings',
                          stats['totalBookings'].toString(),
                          Iconsax.calendar,
                          Colors.green,
                        ),
                        _buildStatCard(
                          'Pending Bookings',
                          stats['pendingBookings'].toString(),
                          Iconsax.clock,
                          Colors.orange,
                        ),
                        _buildStatCard(
                          'Revenue',
                          '\$${(stats['totalBookings'] * 100).toString()}',
                          Iconsax.dollar_circle,
                          Colors.purple,
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Quick Actions
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              FadeInUp(
                delay: const Duration(milliseconds: 600),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.3,
                  children: [
                    _buildActionCard(
                      'Manage Services',
                      Iconsax.box,
                      () => Get.toNamed(AppRoutes.adminServices),
                    ),
                    _buildActionCard(
                  'Manage Bookings',
                      Iconsax.calendar,
                      () => Get.toNamed(AppRoutes.adminBookings),
                    ),
                    _buildActionCard(
                      'Customer Support',
                      Iconsax.message,
                      () => Get.toNamed(AppRoutes.adminChat),
                    ),
                _buildActionCard(
                  'Settings',
                  Iconsax.setting_2,
                  () {},
                      ),
                    ],
                ),
              ),
            ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1), // Placeholder color for action cards
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.blue, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String title, String subtitle, String time, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Text(
          time,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  void _showAnalytics() {
    Get.snackbar(
      'Analytics',
      'Analytics feature coming soon!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
} 