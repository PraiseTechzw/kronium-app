import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kronium/core/app_theme.dart';
import 'package:kronium/core/user_auth_service.dart'
    show userController;
import 'package:kronium/pages/home/active_projects_section.dart';
import 'package:kronium/pages/home/featured_services_section.dart';
import 'package:kronium/pages/home/quick_actions_sections.dart';
import 'package:kronium/widgets/background_switcher.dart';

/// Keep this widget focused and readable. Extend as needed.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return BackgroundSwitcher(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildSliverAppBar(),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 20),
                  const QuickActionsSection(),
                  const SizedBox(height: 24),
                  const FeaturedServicesSection(),
                  const SizedBox(height: 24),
                  const ActiveProjectsSection(),
                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300.0,
      floating: false,
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: AppTheme.primaryColor,
      collapsedHeight: 80.0,
      stretch: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor,
                AppTheme.secondaryColor,
                AppTheme.primaryColor.withValues(alpha: 0.9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildHeaderRow(),
                  const SizedBox(height: 28),
                  _buildUserInfoSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Colors.white.withValues(alpha: 0.25),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.4),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.shadow,
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.engineering, color: Colors.white, size: 28),
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'KRONIUM',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2.0,
                  shadows: [
                    Shadow(
                      color: AppTheme.shadow,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
              Text(
                'Engineering Solutions',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.95),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfoSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadow,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(35),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.4),
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.shadow,
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(Icons.engineering, color: Colors.white, size: 35),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.95),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Obx(() {
                  final userName =
                      userController.userProfile.value?.name ?? 'User';
                  return Text(
                    userName,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.8,
                      shadows: [
                        Shadow(
                          color: AppTheme.shadow,
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 10),
                Obx(() {
                  final userId =
                      userController.userProfile.value?.id ??
                      userController.userId.value;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppTheme.secondaryColor.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.fingerprint, size: 16, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          'ID: ${userId.isNotEmpty ? userId : 'N/A'}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.secondaryColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.secondaryColor.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Icon(Icons.assignment_turned_in, color: Colors.white, size: 24),
                const SizedBox(height: 6),
                Text(
                  'Projects',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
