import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kronium/core/app_theme.dart';
import 'package:kronium/core/routes.dart';
import 'package:kronium/core/user_auth_service.dart';
import 'package:kronium/core/admin_auth_service.dart';

/// AppDrawer is a beautiful, modular drawer for Kronium.
/// Place all drawer logic and UI here for clean code.
class AppDrawer extends StatelessWidget {
  final bool isDarkMode;
  final UserAuthService userAuthService;
  final AdminAuthService adminAuthService;
  final ValueChanged<bool> onDarkModeChanged;
  final VoidCallback onShowAbout;
  final VoidCallback onShowContact;

  const AppDrawer({
    super.key,
    required this.isDarkMode,
    required this.userAuthService,
    required this.adminAuthService,
    required this.onDarkModeChanged,
    required this.onShowAbout,
    required this.onShowContact,
  });

  @override
  Widget build(BuildContext context) {
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
                    child: Icon(Iconsax.user, color: Color(0xFF0C8A44), size: 36),
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
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Account Section
            if (userAuthService.isUserLoggedIn.value) ...[
              _drawerItem(context, 'My Profile', Iconsax.user_edit, AppRoutes.customerProfile),
              _drawerItem(context, 'My Projects', Iconsax.document_text, AppRoutes.projects),
              Divider(color: AppTheme.divider),
              _drawerItem(context, 'Sign Out', Iconsax.logout, () async {
                await userAuthService.logout();
                Get.back();
              }),
            ] else ...[
              _drawerItem(context, 'Sign In', Iconsax.login, AppRoutes.customerLogin),
              _drawerItem(context, 'Sign Up', Iconsax.user_add, AppRoutes.customerRegister),
              Divider(color: AppTheme.divider),
            ],
            // Settings Section
            ListTile(
              leading: Icon(Iconsax.moon, color: AppTheme.primaryColor),
              title: Text('Dark Mode', style: TextStyle(color: AppTheme.textPrimary)),
              trailing: Switch(
                value: isDarkMode,
                onChanged: onDarkModeChanged,
                activeColor: AppTheme.primaryColor,
              ),
            ),
            Divider(color: AppTheme.divider),
            ListTile(
              leading: Icon(Iconsax.document, color: AppTheme.primaryColor),
              title: Text('Privacy Policy', style: TextStyle(color: AppTheme.textPrimary)),
              onTap: () {/* Show privacy policy dialog or page */},
            ),
            ListTile(
              leading: Icon(Iconsax.document_text, color: AppTheme.primaryColor),
              title: Text('Terms of Service', style: TextStyle(color: AppTheme.textPrimary)),
              onTap: () {/* Show terms of service dialog or page */},
            ),
            ListTile(
              leading: Icon(Iconsax.message_question, color: AppTheme.primaryColor),
              title: Text('Help & Support', style: TextStyle(color: AppTheme.textPrimary)),
              onTap: () {/* Show help/support dialog or page */},
            ),
            ListTile(
              leading: Icon(Iconsax.star, color: AppTheme.primaryColor),
              title: Text('Rate the App', style: TextStyle(color: AppTheme.textPrimary)),
              onTap: () {/* Implement rate app logic */},
            ),
            ListTile(
              leading: Icon(Iconsax.info_circle, color: AppTheme.primaryColor),
              title: Text('About App', style: TextStyle(color: AppTheme.textPrimary)),
              onTap: onShowAbout,
            ),
            Divider(color: AppTheme.divider),
            ListTile(
              leading: Icon(Iconsax.message, color: AppTheme.primaryColor),
              title: Text('Contact Us', style: TextStyle(color: AppTheme.textPrimary)),
              onTap: onShowContact,
            ),
            Divider(color: AppTheme.divider),
            // Admin Section
            if (adminAuthService.isAdminLoggedIn.value) ...[
              _drawerItem(context, 'Admin Dashboard', Iconsax.shield_tick, AppRoutes.adminDashboard),
              _drawerItem(context, 'Sign Out Admin', Iconsax.logout, () async {
                await adminAuthService.logout();
                Get.back();
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
  Widget _drawerItem(BuildContext context, String title, IconData icon, dynamic routeOrAction) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
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