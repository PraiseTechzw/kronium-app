import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animate_do/animate_do.dart';
import 'package:kronium/core/admin_auth_service.dart';
import 'package:kronium/core/app_theme.dart';
import 'package:kronium/core/firebase_service.dart';
import 'package:kronium/core/routes.dart';
import 'package:kronium/core/user_auth_service.dart';
import 'package:kronium/core/user_controller.dart';
import 'package:kronium/widgets/admin_scaffold.dart';
import 'package:kronium/models/booking_model.dart';
import 'package:kronium/pages/admin/admin_project_requests_page.dart';

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
    final userController = Get.find<UserController>();

    return AdminScaffold(
      title: 'Admin Dashboard',
      actions: [
        IconButton(
          icon: const Icon(Iconsax.logout),
          onPressed: () async {
            await adminAuthService.logout();
            Get.offAllNamed(AppRoutes.welcome);
          },
        ),
        ElevatedButton.icon(
          icon: const Icon(Iconsax.message_question),
          label: const Text('View Project Requests'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () => Get.to(() => const AdminProjectRequestsPage()),
        ),
      ],
      isDarkMode: _isDarkMode,
      onDarkModeChanged: (val) => setState(() => _isDarkMode = val),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            FadeInDown(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.18),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Iconsax.shield_tick,
                        color: AppTheme.primaryColor,
                        size: 36,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, Admin',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Here is your business overview and latest activity.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Statistics Cards
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: FutureBuilder<Map<String, dynamic>>(
                future: firebaseService.getAdminStats(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final stats =
                      snapshot.data ??
                      {
                        'totalServices': 0,
                        'totalBookings': 0,
                        'pendingBookings': 0,
                      };

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildStatCard(
                          'Services',
                          stats['totalServices'].toString(),
                          Iconsax.box,
                          Colors.blue,
                        ),
                        const SizedBox(width: 16),
                        _buildStatCard(
                          'Bookings',
                          stats['totalBookings'].toString(),
                          Iconsax.calendar,
                          Colors.green,
                        ),
                        const SizedBox(width: 16),
                        _buildStatCard(
                          'Pending',
                          stats['pendingBookings'].toString(),
                          Iconsax.clock,
                          Colors.orange,
                        ),
                        const SizedBox(width: 16),
                        _buildStatCard(
                          'Revenue',
                          '\$${(stats['totalBookings'] * 100).toString()}',
                          Iconsax.dollar_circle,
                          Colors.purple,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),

            // Recent Activity (Latest Bookings)
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Bookings',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _RecentBookingsList(),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // (Optional) Analytics/Graphs section can be added here
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // Dashboard tab
        onTap: (index) {
          switch (index) {
            case 0:
              // Already on dashboard
              break;
            case 1:
              Get.toNamed(AppRoutes.adminServices);
              break;
            case 2:
              Get.toNamed(AppRoutes.adminProjects);
              break;
            case 3:
              Get.toNamed(AppRoutes.adminChat);
              break;
            case 4:
              Get.toNamed(AppRoutes.profile);
              break;
          }
        },
        backgroundColor: AppTheme.surfaceLight,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.secondaryColor,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Iconsax.home_2),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Iconsax.box), label: 'Services'),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.document_text),
            label: 'Projects',
          ),
          BottomNavigationBarItem(icon: Icon(Iconsax.message), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Iconsax.user), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
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
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _RecentBookingsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final firebaseService = Get.find<FirebaseService>();
    return StreamBuilder<List<Booking>>(
      stream: firebaseService.getBookings(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final bookings = snapshot.data ?? [];
        if (bookings.isEmpty) {
          return const Text('No recent bookings.');
        }
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: bookings.length > 5 ? 5 : bookings.length,
          separatorBuilder: (_, __) => const Divider(height: 18),
          itemBuilder: (context, index) {
            final booking = bookings[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                child: const Icon(
                  Iconsax.calendar,
                  color: AppTheme.primaryColor,
                ),
              ),
              title: Text(
                booking.clientName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${booking.serviceName} • ${booking.date.toLocal().toString().split(' ')[0]}',
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _statusColor(booking.status.name).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _statusText(booking.status.name),
                  style: TextStyle(
                    color: _statusColor(booking.status.name),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _statusText(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }
}
