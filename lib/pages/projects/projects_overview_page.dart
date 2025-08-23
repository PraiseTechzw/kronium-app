import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kronium/core/app_theme.dart';
import 'package:kronium/core/user_controller.dart';
import 'package:kronium/widgets/hover_widget.dart';

class ProjectsOverviewPage extends StatefulWidget {
  const ProjectsOverviewPage({super.key});

  @override
  State<ProjectsOverviewPage> createState() => _ProjectsOverviewPageState();
}

class _ProjectsOverviewPageState extends State<ProjectsOverviewPage> {
  final UserController _userController = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryColor,
                AppTheme.secondaryColor,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Iconsax.document_text,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Projects Hub',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Iconsax.arrow_left_2,
              color: Colors.white,
              size: 20,
            ),
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(),
            const SizedBox(height: 24),
            _buildQuickActionsSection(),
            const SizedBox(height: 24),
            _buildProjectsSection(),
            const SizedBox(height: 24),
            _buildManagementSection(),
            const SizedBox(height: 24),
            _buildAnalyticsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withOpacity(0.1),
            AppTheme.secondaryColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Iconsax.document_text,
                  color: AppTheme.primaryColor,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to Projects Hub',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Manage your projects, track progress, and collaborate with your team',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return _buildSectionCard(
      title: 'Quick Actions',
      icon: Iconsax.flash,
      children: [
        _buildActionCard(
          icon: Iconsax.add_circle,
          title: 'Create New Project',
          subtitle: 'Start a new project from scratch',
          color: Colors.green,
          onTap: () => Get.toNamed('/projects'),
        ),
        const SizedBox(height: 16),
        _buildActionCard(
          icon: Iconsax.search_normal,
          title: 'Browse Projects',
          subtitle: 'View all available projects',
          color: Colors.blue,
          onTap: () => Get.toNamed('/projects'),
        ),
        const SizedBox(height: 16),
        _buildActionCard(
          icon: Iconsax.calendar,
          title: 'Book Project Date',
          subtitle: 'Schedule your project timeline',
          color: Colors.orange,
          onTap: () => Get.toNamed('/projects'),
        ),
      ],
    );
  }

  Widget _buildProjectsSection() {
    return _buildSectionCard(
      title: 'Project Categories',
      icon: Iconsax.category,
      children: [
        _buildCategoryCard(
          icon: Iconsax.home,
          title: 'Greenhouses',
          subtitle: 'Agricultural structures',
          count: '12',
          color: Colors.green,
          onTap: () => Get.toNamed('/projects'),
        ),
        const SizedBox(height: 16),
        _buildCategoryCard(
          icon: Iconsax.buildings,
          title: 'Steel Structures',
          subtitle: 'Industrial buildings',
          count: '8',
          color: Colors.blue,
          onTap: () => Get.toNamed('/projects'),
        ),
        const SizedBox(height: 16),
        _buildCategoryCard(
          icon: Iconsax.sun_1,
          title: 'Solar Systems',
          subtitle: 'Renewable energy',
          count: '15',
          color: Colors.orange,
          onTap: () => Get.toNamed('/projects'),
        ),
        const SizedBox(height: 16),
        _buildCategoryCard(
          icon: Iconsax.hammer,
          title: 'Construction',
          subtitle: 'General construction',
          count: '20',
          color: Colors.purple,
          onTap: () => Get.toNamed('/projects'),
        ),
        const SizedBox(height: 16),
        _buildCategoryCard(
          icon: Iconsax.truck,
          title: 'Logistics',
          subtitle: 'Transportation services',
          count: '6',
          color: Colors.indigo,
          onTap: () => Get.toNamed('/projects'),
        ),
        const SizedBox(height: 16),
        _buildCategoryCard(
          icon: Iconsax.cpu,
          title: 'IoT & Automation',
          subtitle: 'Smart technology',
          count: '10',
          color: Colors.teal,
          onTap: () => Get.toNamed('/projects'),
        ),
      ],
    );
  }

  Widget _buildManagementSection() {
    if (_userController.role.value != 'admin') {
      return const SizedBox.shrink();
    }

    return _buildSectionCard(
      title: 'Admin Management',
      icon: Iconsax.shield_tick,
      children: [
        _buildActionCard(
          icon: Iconsax.calendar_remove,
          title: 'Manage Bookings',
          subtitle: 'View and manage project bookings',
          color: Colors.red,
          onTap: () => Get.toNamed('/bookings-management'),
        ),
        const SizedBox(height: 16),
        _buildActionCard(
          icon: Iconsax.chart,
          title: 'Project Analytics',
          subtitle: 'View project statistics and reports',
          color: Colors.purple,
          onTap: () => Get.toNamed('/project-analytics'),
        ),
        const SizedBox(height: 16),
        _buildActionCard(
          icon: Iconsax.user_edit,
          title: 'Team Management',
          subtitle: 'Manage project team members',
          color: Colors.indigo,
          onTap: () => Get.toNamed('/team-management'),
        ),
      ],
    );
  }

  Widget _buildAnalyticsSection() {
    return _buildSectionCard(
      title: 'Your Projects',
      icon: Iconsax.chart_square,
      children: [
        _buildStatCard(
          icon: Iconsax.timer,
          title: 'Active Projects',
          value: '3',
          color: Colors.green,
        ),
        const SizedBox(height: 16),
        _buildStatCard(
          icon: Iconsax.check_circle,
          title: 'Completed',
          value: '12',
          color: Colors.blue,
        ),
        const SizedBox(height: 16),
        _buildStatCard(
          icon: Iconsax.clock,
          title: 'In Progress',
          value: '5',
          color: Colors.orange,
        ),
        const SizedBox(height: 16),
        _buildStatCard(
          icon: Iconsax.calendar,
          title: 'Upcoming',
          value: '2',
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return HoverWidget(
      hoverChild: Transform.translate(
        offset: const Offset(0, -2),
        child: _buildActionCardContent(icon, title, subtitle, color, true),
      ),
      onHover: (event) {},
      child: GestureDetector(
        onTap: onTap,
        child: _buildActionCardContent(icon, title, subtitle, color, false),
      ),
    );
  }

  Widget _buildActionCardContent(
    IconData icon,
    String title,
    String subtitle,
    Color color,
    bool isHovered,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isHovered
            ? [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
        border: Border.all(
          color: isHovered ? color.withOpacity(0.3) : Colors.grey.withOpacity(0.1),
          width: isHovered ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Iconsax.arrow_right_3,
            color: color,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String count,
    required Color color,
    required VoidCallback onTap,
  }) {
    return HoverWidget(
      hoverChild: Transform.translate(
        offset: const Offset(0, -2),
        child: _buildCategoryCardContent(icon, title, subtitle, count, color, true),
      ),
      onHover: (event) {},
      child: GestureDetector(
        onTap: onTap,
        child: _buildCategoryCardContent(icon, title, subtitle, count, color, false),
      ),
    );
  }

  Widget _buildCategoryCardContent(
    IconData icon,
    String title,
    String subtitle,
    String count,
    Color color,
    bool isHovered,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isHovered
            ? [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
        border: Border.all(
          color: isHovered ? color.withOpacity(0.3) : Colors.grey.withOpacity(0.1),
          width: isHovered ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              count,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
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
