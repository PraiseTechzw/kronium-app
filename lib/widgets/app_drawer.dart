import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kronium/core/app_theme.dart';
import 'package:kronium/core/routes.dart';
import 'package:kronium/core/user_auth_service.dart';
import 'package:kronium/core/admin_auth_service.dart';
import 'package:kronium/core/user_controller.dart';

/// AppDrawer is a beautiful, modular drawer for Kronium.
/// Place all drawer logic and UI here for clean code.
class AppDrawer extends StatelessWidget {
  final bool isDarkMode;
  final UserAuthService userAuthService;
  final AdminAuthService adminAuthService;
  final ValueChanged<bool> onDarkModeChanged;
  final VoidCallback onShowAbout;
  final VoidCallback onShowContact;
  final List<Widget>? extraItems;

  const AppDrawer({
    super.key,
    required this.isDarkMode,
    required this.userAuthService,
    required this.adminAuthService,
    required this.onDarkModeChanged,
    required this.onShowAbout,
    required this.onShowContact,
    this.extraItems,
  });

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();
    final isAdmin = userController.role.value == 'admin';
    return Drawer(
      child: Container(
        color: AppTheme.backgroundLight,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // User Info Section
            Container(
              decoration: BoxDecoration(
                color: Color(0xFF0C8A44), // Green background
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.shadow,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Iconsax.user,
                      color: Color(0xFF0C8A44),
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userAuthService.isUserLoggedIn.value
                        ? 'Welcome, ${userAuthService.currentUserProfile?.name ?? ''}'
                        : 'Welcome',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Settings & Preferences',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  if (isAdmin)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange[700],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Admin',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (isAdmin) ...[
              ListTile(
                leading: const Icon(
                  Iconsax.shield_tick,
                  color: AppTheme.primaryColor,
                ),
                title: const Text(
                  'Admin Dashboard',
                  style: TextStyle(color: AppTheme.textPrimary),
                ),
                onTap: () => Get.toNamed('/admin-dashboard'),
              ),
              ListTile(
                leading: const Icon(Iconsax.box, color: AppTheme.primaryColor),
                title: const Text(
                  'Manage Services',
                  style: TextStyle(color: AppTheme.textPrimary),
                ),
                onTap: () => Get.toNamed('/admin-services'),
              ),
              ListTile(
                leading: const Icon(
                  Iconsax.calendar,
                  color: AppTheme.primaryColor,
                ),
                title: const Text(
                  'Bookings',
                  style: TextStyle(color: AppTheme.textPrimary),
                ),
                onTap: () => Get.toNamed('/admin-bookings'),
              ),
              ListTile(
                leading: const Icon(
                  Iconsax.message,
                  color: AppTheme.primaryColor,
                ),
                title: const Text(
                  'Admin Chat',
                  style: TextStyle(color: AppTheme.textPrimary),
                ),
                onTap: () => Get.toNamed('/admin-chat'),
              ),
              const Divider(),
            ],
            // Remove any ListTile or item related to account/profile actions (e.g., My Profile, Sign Out, etc.)
            // Only keep navigation, dashboard, help, about, etc.
            if (extraItems != null) ...extraItems!,
            // Settings Section
            ListTile(
              leading: Icon(Iconsax.moon, color: AppTheme.primaryColor),
              title: Text(
                'Dark Mode',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              trailing: Switch(
                value: isDarkMode,
                onChanged: onDarkModeChanged,
                activeColor: AppTheme.primaryColor,
              ),
            ),
            Divider(color: AppTheme.divider),
            ListTile(
              leading: Icon(Iconsax.document, color: AppTheme.primaryColor),
              title: Text(
                'Privacy Policy',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              onTap: () {
                /* Show privacy policy dialog or page */
              },
            ),
            ListTile(
              leading: Icon(
                Iconsax.document_text,
                color: AppTheme.primaryColor,
              ),
              title: Text(
                'Terms of Service',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              onTap: () {
                /* Show terms of service dialog or page */
              },
            ),
            ListTile(
              leading: Icon(
                Iconsax.message_question,
                color: AppTheme.primaryColor,
              ),
              title: Text(
                'Help & Support',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              onTap: () {
                /* Show help/support dialog or page */
              },
            ),
            ListTile(
              leading: Icon(Iconsax.star, color: AppTheme.primaryColor),
              title: Text(
                'Rate the App',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              onTap: () {
                /* Implement rate app logic */
              },
            ),
            ListTile(
              leading: Icon(Iconsax.info_circle, color: AppTheme.primaryColor),
              title: Text(
                'About App',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              onTap: onShowAbout,
            ),
            Divider(color: AppTheme.divider),
            ListTile(
              leading: Icon(Iconsax.message, color: AppTheme.primaryColor),
              title: Text(
                'Contact Us',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              onTap: onShowContact,
            ),
            Divider(color: AppTheme.divider),
            // Admin Section
            if (adminAuthService.isAdminLoggedIn.value) ...[
              _drawerItem(
                context,
                'Admin Dashboard',
                Iconsax.shield_tick,
                AppRoutes.adminDashboard,
              ),
              _drawerItem(context, 'Sign Out Admin', Iconsax.logout, () async {
                await adminAuthService.logout();
                Get.offAllNamed(AppRoutes.welcome);
              }),
            ],
            const SizedBox(height: 24),
            // App branding at the bottom
            Center(
              child: Text(
                'Kronium',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  /// Drawer item builder for navigation or actions.
  Widget _drawerItem(
    BuildContext context,
    String title,
    IconData icon,
    dynamic routeOrAction,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: AppTheme.textPrimary,
        ),
      ),
      onTap: () {
        Get.back();
        if (routeOrAction is String) {
          Get.toNamed(routeOrAction);
        } else if (routeOrAction is Function) {
          routeOrAction();
        }
      },
      hoverColor: AppTheme.primaryColor.withOpacity(0.08),
    );
  }
}
