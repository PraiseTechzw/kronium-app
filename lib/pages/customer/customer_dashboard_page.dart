import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kronium/core/admin_auth_service.dart';
import 'package:kronium/core/app_theme.dart';
import 'package:kronium/core/firebase_service.dart';
import 'package:kronium/core/routes.dart';
import 'package:kronium/core/user_auth_service.dart';
import 'package:kronium/models/booking_model.dart';

class CustomerDashboardPage extends StatelessWidget {
  const CustomerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userAuthService = Get.find<UserAuthService>();
    final firebaseService = Get.find<FirebaseService>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.logout),
            onPressed: () async {
              await userAuthService.logout();
              Get.offAllNamed(AppRoutes.customerLogin);
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Obx(() {
        final user = userAuthService.currentUserProfile;
        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
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
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Text(
                          user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              user.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
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
              
              // Quick Actions
              FadeInLeft(
                delay: const Duration(milliseconds: 100),
                child: const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionCard(
                        icon: Iconsax.box,
                        title: 'Book Service',
                        subtitle: 'Find and book services',
                        color: AppTheme.primaryColor,
                        onTap: () => Get.toNamed(AppRoutes.services),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickActionCard(
                        icon: Iconsax.document_text,
                        title: 'My Projects',
                        subtitle: 'View your projects',
                        color: AppTheme.secondaryColor,
                        onTap: () => Get.toNamed(AppRoutes.projects),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Recent Bookings
              FadeInLeft(
                delay: const Duration(milliseconds: 300),
                child: const Text(
                  'Recent Bookings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Recent Bookings Stream
              StreamBuilder<List<Booking>>(
                stream: firebaseService.getBookings(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }
                  
                  final bookings = snapshot.data ?? [];
                  final userBookings = bookings.where((booking) => 
                    booking.clientEmail == user.email
                  ).toList();
                  
                  if (userBookings.isEmpty) {
                    return FadeInUp(
                      delay: const Duration(milliseconds: 400),
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              Iconsax.document_text,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No bookings yet',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Start by booking your first service',
                              style: TextStyle(
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => Get.toNamed(AppRoutes.services),
                              child: const Text('Browse Services'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  
                  return Column(
                    children: userBookings.take(3).map((booking) {
                      return FadeInUp(
                        delay: Duration(milliseconds: 400 + (userBookings.indexOf(booking) * 100)),
                        child: _buildBookingCard(booking),
                      );
                    }).toList(),
                  );
                },
              ),
              
              const SizedBox(height: 24),
              
              // Profile Section
              FadeInLeft(
                delay: const Duration(milliseconds: 500),
                child: const Text(
                  'Account',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              FadeInUp(
                delay: const Duration(milliseconds: 600),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Iconsax.user, color: AppTheme.primaryColor),
                        title: const Text('Profile'),
                        subtitle: Text(user.name),
                        trailing: const Icon(Iconsax.arrow_right_3),
                        onTap: () => Get.toNamed(AppRoutes.profile),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Iconsax.setting_2, color: AppTheme.primaryColor),
                        title: const Text('Settings'),
                        trailing: const Icon(Iconsax.arrow_right_3),
                        onTap: () => Get.toNamed(AppRoutes.settings),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Iconsax.message, color: AppTheme.primaryColor),
                        title: const Text('Chat Support'),
                        trailing: const Icon(Iconsax.arrow_right_3),
                        onTap: () => Get.toNamed(AppRoutes.customerChat),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }

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
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(Booking booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  booking.serviceName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: booking.statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  booking.statusText,
                  style: TextStyle(
                    color: booking.statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Iconsax.calendar, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                '${booking.date.day}/${booking.date.month}/${booking.date.year}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                '\$${booking.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          if (booking.location.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Iconsax.location, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    booking.location,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
} 