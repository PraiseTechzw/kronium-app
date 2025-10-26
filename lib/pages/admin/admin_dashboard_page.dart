import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animate_do/animate_do.dart';
import 'package:kronium/core/admin_auth_service.dart';
import 'package:kronium/core/app_theme.dart';
import 'package:kronium/core/firebase_service.dart';
import 'package:kronium/core/routes.dart';
import 'package:kronium/widgets/admin_scaffold.dart';
import 'package:kronium/models/booking_model.dart';
import 'package:kronium/models/chat_model.dart';
import 'package:kronium/models/user_model.dart';
import 'package:kronium/models/service_model.dart';
import 'package:kronium/pages/admin/admin_project_requests_page.dart';
import 'package:kronium/pages/admin/admin_project_management_page.dart';
import 'package:kronium/core/admin_notification_service.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  bool _isDarkMode = false;
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};
  List<Booking> _recentBookings = [];
  List<ChatRoom> _recentChats = [];
  List<User> _recentCustomers = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final firebaseService = Get.find<FirebaseService>();

    try {
      final stats = await firebaseService.getAdminStats();
      final bookings = await firebaseService.getBookings().first;
      final chatRooms = await firebaseService.getChatRooms().first;
      final users = await firebaseService.getUsers().first;

      setState(() {
        _stats = stats;
        _recentBookings = bookings.take(5).toList();
        _recentChats = chatRooms.take(3).toList();
        _recentCustomers =
            users.where((user) => user.isActive).take(5).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminAuthService = Get.find<AdminAuthService>();

    return AdminScaffold(
      title: 'Admin Dashboard',
      actions: [
        const AdminNotificationWidget(),
        IconButton(
          icon: const Icon(Iconsax.logout),
          onPressed: () async {
            await adminAuthService.logout();
            Get.offAllNamed(AppRoutes.welcome);
          },
        ),
        IconButton(
          icon: const Icon(Iconsax.message_question),
          onPressed: () => Get.to(() => const AdminProjectRequestsPage()),
          tooltip: 'View Project Requests',
        ),
      ],
      isDarkMode: _isDarkMode,
      onDarkModeChanged: (val) => setState(() => _isDarkMode = val),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
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
                            colors: [
                              AppTheme.primaryColor,
                              AppTheme.secondaryColor,
                            ],
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
                            IconButton(
                              onPressed: _loadDashboardData,
                              icon: const Icon(
                                Iconsax.refresh,
                                color: Colors.white,
                                size: 24,
                              ),
                              tooltip: 'Refresh Data',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Statistics Cards
                    FadeInUp(
                      delay: const Duration(milliseconds: 200),
                      child: Column(
                        children: [
                          // First row - Main stats
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  'Services',
                                  _stats['totalServices']?.toString() ?? '0',
                                  Iconsax.box,
                                  Colors.blue,
                                  subtitle: 'Active',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  'Bookings',
                                  _stats['totalBookings']?.toString() ?? '0',
                                  Iconsax.calendar,
                                  Colors.green,
                                  subtitle: 'Total',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Second row - Secondary stats
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  'Pending',
                                  _stats['pendingBookings']?.toString() ?? '0',
                                  Iconsax.clock,
                                  Colors.orange,
                                  subtitle: 'Awaiting',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  'Revenue',
                                  '\$${((_stats['totalBookings'] ?? 0) * 150).toString()}',
                                  Iconsax.dollar_circle,
                                  Colors.purple,
                                  subtitle: 'Estimated',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Third row - Chat stats
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  'Active Chats',
                                  _recentChats.length.toString(),
                                  Iconsax.message,
                                  Colors.teal,
                                  subtitle: 'Support',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  'Completion',
                                  '${(((_stats['totalBookings'] ?? 0) - (_stats['pendingBookings'] ?? 0)) / (_stats['totalBookings'] ?? 1) * 100).toStringAsFixed(0)}%',
                                  Iconsax.tick_circle,
                                  Colors.indigo,
                                  subtitle: 'Rate',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Quick Actions
                    FadeInUp(
                      delay: const Duration(milliseconds: 300),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Quick Actions',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              const Spacer(),
                              TextButton.icon(
                                onPressed: _loadDashboardData,
                                icon: const Icon(Iconsax.refresh, size: 16),
                                label: const Text('Refresh'),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppTheme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: _buildQuickActionCard(
                                  'Full Management',
                                  Iconsax.setting_2,
                                  Colors.purple,
                                  () => Get.toNamed(AppRoutes.adminManagement),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildQuickActionCard(
                                  'Add Service',
                                  Iconsax.add_circle,
                                  Colors.blue,
                                  () => Get.toNamed(AppRoutes.adminServices),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildQuickActionCard(
                                  'Manage Projects',
                                  Iconsax.document_text,
                                  Colors.green,
                                  () => Get.to(
                                    () => const AdminProjectManagementPage(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildQuickActionCard(
                                  'Chat Support',
                                  Iconsax.message,
                                  Colors.orange,
                                  () => Get.toNamed(AppRoutes.adminChat),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Recent Activity Section
                    FadeInUp(
                      delay: const Duration(milliseconds: 400),
                      child: Column(
                        children: [
                          // Recent Bookings
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Recent Bookings',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const Spacer(),
                                  TextButton(
                                    onPressed:
                                        () => Get.toNamed(
                                          AppRoutes.adminBookings,
                                        ),
                                    style: TextButton.styleFrom(
                                      foregroundColor: AppTheme.primaryColor,
                                    ),
                                    child: const Text('View All'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildRecentBookingsList(),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Recent Chats
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Recent Chats',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const Spacer(),
                                  TextButton(
                                    onPressed:
                                        () => Get.toNamed(AppRoutes.adminChat),
                                    style: TextButton.styleFrom(
                                      foregroundColor: AppTheme.primaryColor,
                                    ),
                                    child: const Text('View All'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildRecentChatsList(),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Recent Customers Section
                    FadeInUp(
                      delay: const Duration(milliseconds: 500),
                      child: Column(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Recent Customers',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const Spacer(),
                                  TextButton(
                                    onPressed:
                                        () => Get.toNamed(
                                          AppRoutes.adminManagement,
                                        ),
                                    style: TextButton.styleFrom(
                                      foregroundColor: AppTheme.primaryColor,
                                    ),
                                    child: const Text('View All'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildRecentCustomersList(),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Analytics Section
                    FadeInUp(
                      delay: const Duration(milliseconds: 600),
                      child: _buildAnalyticsSection(),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(color: color.withOpacity(0.1), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentBookingsList() {
    if (_recentBookings.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Icon(Iconsax.calendar_1, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              'No recent bookings',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'New bookings will appear here',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _recentBookings.length,
        separatorBuilder:
            (_, __) => Divider(
              height: 1,
              color: Colors.grey[100],
              indent: 16,
              endIndent: 16,
            ),
        itemBuilder: (context, index) {
          final booking = _recentBookings[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Iconsax.calendar,
                color: AppTheme.primaryColor,
                size: 18,
              ),
            ),
            title: Text(
              booking.clientName,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
            subtitle: Text(
              '${booking.serviceName} • ${_formatDate(booking.date)}',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _statusColor(booking.status.name).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _statusColor(booking.status.name).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                _statusText(booking.status.name),
                style: TextStyle(
                  color: _statusColor(booking.status.name),
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentCustomersList() {
    if (_recentCustomers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Icon(Iconsax.user, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              'No customers yet',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Customer registrations will appear here',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _recentCustomers.length,
        separatorBuilder:
            (_, __) => Divider(
              height: 1,
              color: Colors.grey[100],
              indent: 16,
              endIndent: 16,
            ),
        itemBuilder: (context, index) {
          final customer = _recentCustomers[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              child: Text(
                customer.name.isNotEmpty ? customer.name[0].toUpperCase() : 'C',
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              customer.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
            subtitle: Text(
              customer.email,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Iconsax.message,
                    color: Colors.blue,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Iconsax.add_circle,
                    color: Colors.green,
                    size: 16,
                  ),
                ),
              ],
            ),
            onTap: () {
              _showCustomerActions(customer);
            },
          );
        },
      ),
    );
  }

  Widget _buildRecentChatsList() {
    if (_recentChats.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Icon(Iconsax.message, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              'No active chats',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Customer messages will appear here',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _recentChats.length,
        separatorBuilder:
            (_, __) => Divider(
              height: 1,
              color: Colors.grey[100],
              indent: 16,
              endIndent: 16,
            ),
        itemBuilder: (context, index) {
          final chat = _recentChats[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                chat.customerName.isNotEmpty
                    ? chat.customerName[0].toUpperCase()
                    : 'C',
                style: const TextStyle(
                  color: Colors.teal,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            title: Text(
              chat.customerName,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
            subtitle: Text(
              chat.customerEmail,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            trailing: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Iconsax.arrow_right_3,
                color: Colors.teal,
                size: 14,
              ),
            ),
            onTap: () => Get.toNamed(AppRoutes.adminChat),
          );
        },
      ),
    );
  }

  Widget _buildAnalyticsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Analytics Overview',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildAnalyticsCard(
                'Booking Rate',
                '${((_stats['totalBookings'] ?? 0) / ((_stats['totalServices'] ?? 1) * 10) * 100).toStringAsFixed(1)}%',
                Iconsax.chart_2,
                Colors.blue,
                'Conversion rate',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAnalyticsCard(
                'Completion Rate',
                '${(((_stats['totalBookings'] ?? 0) - (_stats['pendingBookings'] ?? 0)) / (_stats['totalBookings'] ?? 1) * 100).toStringAsFixed(1)}%',
                Iconsax.tick_circle,
                Colors.green,
                'Success rate',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnalyticsCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String? subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
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
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  void _showCustomerActions(User customer) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  child: Text(
                    customer.name.isNotEmpty
                        ? customer.name[0].toUpperCase()
                        : 'C',
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  customer.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  customer.email,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Get.back();
                          Get.toNamed(AppRoutes.adminChat);
                        },
                        icon: const Icon(Iconsax.message),
                        label: const Text('Message'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Get.back();
                          _showServiceOfferDialog(customer);
                        },
                        icon: const Icon(Iconsax.add_circle),
                        label: const Text('Offer Service'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Get.back();
                          Get.toNamed(AppRoutes.adminBookings);
                        },
                        icon: const Icon(Iconsax.calendar),
                        label: const Text('View Bookings'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Get.back();
                          // Navigate to management tab in admin main page
                          Get.toNamed(AppRoutes.adminMain);
                        },
                        icon: const Icon(Iconsax.setting_2),
                        label: const Text('Manage'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
    );
  }

  void _showServiceOfferDialog(User customer) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Offer Service to ${customer.name}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Select a service to offer to this customer:'),
                const SizedBox(height: 16),
                StreamBuilder<List<Service>>(
                  stream: Get.find<FirebaseService>().getServices(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }

                    final services = snapshot.data ?? [];

                    if (services.isEmpty) {
                      return const Text('No services available');
                    }

                    return Column(
                      children:
                          services
                              .map(
                                (service) => ListTile(
                                  leading: Icon(
                                    service.icon,
                                    color: service.color,
                                  ),
                                  title: Text(service.title),
                                  subtitle: Text(service.description),
                                  trailing: Text(
                                    '\$${service.price ?? 'Contact'}',
                                  ),
                                  onTap: () {
                                    Get.back();
                                    _sendServiceOffer(customer, service);
                                  },
                                ),
                              )
                              .toList(),
                    );
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }

  void _sendServiceOffer(User customer, Service service) {
    Get.snackbar(
      'Service Offer Sent',
      'Service "${service.title}" has been offered to ${customer.name}',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
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
