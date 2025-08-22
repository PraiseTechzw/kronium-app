import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:kronium/core/app_theme.dart';
import 'package:kronium/core/routes.dart';
import 'package:kronium/core/user_auth_service.dart';

class ActiveProjectsSection extends StatelessWidget {
  const ActiveProjectsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoggedIn = UserAuthService.instance.isUserLoggedIn.value;
      if (!isLoggedIn) return const SizedBox.shrink();

      final userId =
          userController.userProfile.value?.id ?? userController.userId.value;
      if (userId.isEmpty) return const SizedBox.shrink();

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.98),
              Colors.white.withValues(alpha: 0.95),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.shadow.withValues(alpha: 0.1),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Active Projects',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: AppTheme.primaryColor,
                  ),
                ),
                Icon(
                  Icons.assignment_turned_in,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No projects yet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start by booking your first project',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () => Get.toNamed(AppRoutes.projects),
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: const Text('View All Projects'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
