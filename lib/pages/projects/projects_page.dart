import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kronium/core/app_theme.dart';
import 'package:kronium/widgets/hover_widget.dart';

import 'package:lottie/lottie.dart';
import 'mock_project_booking_data.dart';
import 'package:kronium/core/user_auth_service.dart';
import 'package:kronium/core/user_controller.dart';
import 'package:kronium/core/firebase_service.dart';
import 'package:kronium/models/project_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  ProjectsPageState createState() => ProjectsPageState();
}

class ProjectsPageState extends State<ProjectsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late final UserController userController;
  final List<String> categories = [
    'All Projects',
    'Greenhouses',
    'Steel Structures',
    'Solar Systems',
    'Construction',
    'Logistics',
    'IoT & Automation',
  ];
  final RxString _searchQuery = ''.obs;
  final RxString _selectedSort = 'Newest'.obs;

  // Animation controllers
  late AnimationController _searchAnimationController;
  late AnimationController _titleAnimationController;
  late Animation<double> _searchScaleAnimation;
  late Animation<double> _titleSlideAnimation;

  // 1. Remove all references to project.category, project.date, project.testimonial, and project.client.
  // 2. Remove or fallback for any UI that depends on these fields.
  // 3. Only use fields that exist on the Project model.
  // 4. Ensure the project list uses StreamBuilder<List<Project>> for real-time updates.
  // 5. Remove the _loadProjects method and any local projects list.

  // Add these variables at the top of your state class:
  String? _savedName, _savedEmail, _savedPhone;

  // Add these at the top of ProjectsPageState:
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Add this variable to your state class:
  double? _transportCost;

  // Add this to the state class:
  Project? _selectedProject;

  // Add this variable to the state class for admin check:
  final bool _isAdmin = true; // Set to false for normal users

  // Add this variable to store bookings
  List<Map<String, dynamic>> bookedDates = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
    userController = Get.find<UserController>();

    // Initialize animation controllers
    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _titleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _searchScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _searchAnimationController,
        curve: Curves.easeOutBack,
      ),
    );

    _titleSlideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _titleAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _titleAnimationController.forward();

    // Initialize search animation to its final state
    _searchAnimationController.value = 1.0;

    // Listen to search query changes for animations
    ever(_searchQuery, (query) {
      if (query.isNotEmpty) {
        _searchAnimationController.forward();
      } else {
        _searchAnimationController.reverse();
      }
    });

    // 5. Remove the _loadProjects method and any local projects list.
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _tabController.dispose();
    _searchAnimationController.dispose();
    _titleAnimationController.dispose();
    super.dispose();
  }

  // 5. Remove the _loadProjects method and any local projects list.

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
              colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
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
        title: AnimatedBuilder(
          animation: _titleSlideAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 30 * (1 - _titleSlideAnimation.value)),
              child: Opacity(
                opacity: _titleSlideAnimation.value,
                child: const Text(
                  'Kronium Projects',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.white,
                    letterSpacing: 1.2,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          if (_isAdmin)
            IconButton(
              icon: const Icon(Iconsax.calendar_remove, color: Colors.white),
              tooltip: 'Manage Booked Dates',
              onPressed: _showAdminBookedDatesBottomSheet,
            ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Iconsax.document_text, color: Colors.white),
              onPressed: () => Get.toNamed('/projects-overview'),
              tooltip: 'Projects Overview',
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                // Enhanced Search Bar
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (value) => _searchQuery.value = value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search projects...',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      prefixIcon: Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Iconsax.search_normal,
                          color: AppTheme.primaryColor,
                          size: 22,
                        ),
                      ),
                      suffixIcon:
                          _searchQuery.value.isNotEmpty
                              ? Container(
                                margin: const EdgeInsets.all(8),
                                child: IconButton(
                                  onPressed: () => _searchQuery.value = '',
                                  icon: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                              )
                              : null,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 20,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.white, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Enhanced Search Results Display
                Obx(
                  () =>
                      _searchQuery.value.isNotEmpty
                          ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Iconsax.search_status,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Search results for "${_searchQuery.value}"',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          )
                          : const SizedBox(),
                ),
                const SizedBox(height: 8),
                // Enhanced TabBar
                SafeArea(
                  bottom: false,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white.withOpacity(0.7),
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white.withOpacity(0.25),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      tabs:
                          categories
                              .map(
                                (category) => Tab(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: Text(
                                      category,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          if (_searchQuery.value.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                'Showing results for "${_searchQuery.value}"',
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children:
                  categories.map((category) {
                    return _buildProjectList(category);
                  }).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _searchScaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _searchQuery.value.isEmpty ? 1.0 : 0.0,
            child: Opacity(
              opacity: _searchQuery.value.isEmpty ? 1.0 : 0.0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: FloatingActionButton.extended(
                  onPressed: () => _showRequestProjectForm(context),
                  icon: const Icon(
                    Iconsax.message_question,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Request a Project',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- Project List Refactor ---
  // Replace the _buildProjectList method with a version that only uses fields that exist on the Project model and does not use .value on a Stream.
  // Use StreamBuilder<List<Project>> for real-time updates.
  // Remove all code that references project.date, project.testimonial, and project.client.
  // Remove any sorting/filtering logic that uses non-existent fields.
  Widget _buildProjectList(String category) {
    return StreamBuilder<List<Project>>(
      stream: FirebaseService.instance.getProjects(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildEmptyState();
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        List<Project> projects = snapshot.data ?? [];

        // Apply search filter
        projects =
            _searchQuery.value.isNotEmpty
                ? projects
                    .where(
                      (project) =>
                          project.title.toLowerCase().contains(
                            _searchQuery.value.toLowerCase(),
                          ) ||
                          project.description.toLowerCase().contains(
                            _searchQuery.value.toLowerCase(),
                          ),
                    )
                    .toList()
                : category == 'All Projects'
                ? projects
                : projects
                    .where(
                      (project) => project.title
                          .toString()
                          .toLowerCase()
                          .contains(category.toLowerCase()),
                    )
                    .toList();

        // Apply sorting
        projects = _sortProjects(projects);

        // If no projects, show empty state only (prevents RangeError)
        if (projects.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('No projects available.'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _showRequestProjectForm(context),
                  child: const Text('Request a Project'),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.9,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
            ),
            itemCount: projects.length,
            itemBuilder: (context, index) {
              return _projectCard(projects[index]);
            },
          ),
        );
      },
    );
  }

  List<Project> _sortProjects(List<Project> projects) {
    switch (_selectedSort.value) {
      case 'Location':
        return projects..sort((a, b) => a.location.compareTo(b.location));
      case 'Title':
        return projects..sort((a, b) => a.title.compareTo(b.title));
      default:
        return projects;
    }
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated empty state icon
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1200),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.5 + (0.5 * value),
                child: Opacity(
                  opacity: value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor.withOpacity(0.1),
                          AppTheme.secondaryColor.withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(60),
                      border: Border.all(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.work_outline_rounded,
                      size: 60,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),

          // Enhanced title
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 800),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 30 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: Text(
                    'No Projects Yet',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // Enhanced description
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1000),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: Text(
                    'Start building amazing projects and showcase your work to the world. Your portfolio is waiting to be filled with success stories!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.secondaryColor.withOpacity(0.8),
                      height: 1.5,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 40),

          // Call to action button
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1200),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: Opacity(
                  opacity: value,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor,
                          AppTheme.secondaryColor,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(25),
                        onTap: () {
                          // Add action here
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.add_circle_outline_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Create Your First Project',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _projectCard(Project project) {
    return HoverWidget(
      hoverChild: Transform.translate(
        offset: const Offset(0, -5),
        child: _buildProjectCardContent(project, true),
      ),
      onHover: (event) {},
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedProject = project;
          });
          _showProjectDetails(project);
        },
        child: _buildProjectCardContent(project, false),
      ),
    );
  }

  Widget _buildProjectCardContent(Project project, bool isHover) {
    // Use IntrinsicHeight to allow card to size to content, preventing overflow
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedProject = project;
        });
        _showProjectDetails(project);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow:
              isHover
                  ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 8),
                    ),
                  ]
                  : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 15,
                      spreadRadius: 1,
                      offset: const Offset(0, 6),
                    ),
                  ],
          border: Border.all(
            color:
                isHover
                    ? AppTheme.primaryColor.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.1),
            width: isHover ? 2 : 1,
          ),
        ),
        child: IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Enhanced image section
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Stack(
                  children: [
                    SizedBox(
                      height: 120,
                      width: double.infinity,
                      child:
                          project.mediaUrls.isNotEmpty
                              ? Image.network(
                                project.mediaUrls.first,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) => Container(
                                      color: AppTheme.primaryColor.withOpacity(
                                        0.1,
                                      ),
                                      child: Icon(
                                        Icons.broken_image,
                                        size: 40,
                                        color: AppTheme.primaryColor
                                            .withOpacity(0.6),
                                      ),
                                    ),
                              )
                              : Container(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 40,
                                  color: AppTheme.primaryColor.withOpacity(0.6),
                                ),
                              ),
                    ),
                    // Progress indicator overlay
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryColor,
                              AppTheme.secondaryColor,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Project title
                      Text(
                        project.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Location with icon
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Iconsax.location,
                              size: 14,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              project.location,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Description
                      Text(
                        project.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      // Progress section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Progress',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${project.progress}%',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: project.progress / 100,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.primaryColor,
                                      AppTheme.secondaryColor,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<DateTime> get _takenDates => MockProjectBookingData().bookedDates;

  void _showProjectDetails(Project project) {
    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setModalState) {
          String location = '';
          String size = '';
          double? transportCost;
          DateTime? pickedDate;
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.all(0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar and close button
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Handle bar
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      // Close button
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            size: 20,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Project Header Section
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primaryColor.withOpacity(0.05),
                                AppTheme.secondaryColor.withOpacity(0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Project Title and Category
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          project.title,
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.primaryColor,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        if (project.category != null)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  AppTheme.primaryColor
                                                      .withOpacity(0.1),
                                                  AppTheme.secondaryColor
                                                      .withOpacity(0.1),
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color: AppTheme.primaryColor
                                                    .withOpacity(0.3),
                                                width: 1,
                                              ),
                                            ),
                                            child: Text(
                                              project.category!,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: AppTheme.primaryColor,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  // Project Progress Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getProgressColor(
                                        project.progress,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: _getProgressColor(
                                          project.progress,
                                        ).withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      '${project.progress.toInt()}%',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: _getProgressColor(
                                          project.progress,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Project Details Grid
                        Row(
                          children: [
                            Expanded(
                              child: _buildDetailCard(
                                icon: Icons.location_on_outlined,
                                title: 'Location',
                                value: project.location,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildDetailCard(
                                icon: Icons.straighten_outlined,
                                title: 'Size',
                                value: project.size,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: _buildDetailCard(
                                icon: Icons.trending_up_outlined,
                                title: 'Progress',
                                value: '${project.progress.toInt()}%',
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildDetailCard(
                                icon: Icons.calendar_today_outlined,
                                title: 'Created',
                                value:
                                    project.date != null
                                        ? project.date!
                                            .toLocal()
                                            .toString()
                                            .split(' ')[0]
                                        : 'N/A',
                                color: Colors.purple,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Project Description Section
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey[200]!,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor.withOpacity(
                                        0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.description_outlined,
                                      color: AppTheme.primaryColor,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Project Overview',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                project.description,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: AppTheme.secondaryColor.withOpacity(
                                    0.8,
                                  ),
                                  height: 1.6,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Key Features Section
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey[200]!,
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.green[100],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.check_circle_outline_rounded,
                                      color: Colors.green[700],
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Key Features',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildFeatureList(project.features),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppTheme.primaryColor.withOpacity(
                                      0.3,
                                    ),
                                    width: 2,
                                  ),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(14),
                                    onTap: () {
                                      // Add contact action
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.phone_outlined,
                                            color: AppTheme.primaryColor,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Contact Team',
                                            style: TextStyle(
                                              color: AppTheme.primaryColor,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.primaryColor,
                                      AppTheme.secondaryColor,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryColor.withOpacity(
                                        0.3,
                                      ),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(14),
                                    onTap: () {
                                      // Add booking action
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.calendar_today_outlined,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Book Project',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  double _calculateTransportCost(String location, String size) {
    if (location.isEmpty || size.isEmpty) return 0.0;
    double base = 10.0;
    double sizeFactor = size.length * 2.0;
    double locationFactor = location.length * 1.5;
    double distanceFactor = (location.hashCode % 20).toDouble();
    return base + sizeFactor + locationFactor + distanceFactor;
  }

  // Admin-side booked dates management bottom sheet:
  void _showAdminBookedDatesBottomSheet() {
    List<MockBooking> bookings = MockProjectBookingData().bookings;
    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Booked Project Dates',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 10),
                if (bookings.isEmpty) const Text('No booked dates.'),
                if (bookings.isNotEmpty)
                  ...bookings.map(
                    (booking) => Card(
                      child: ListTile(
                        title: Text(
                          'Date: ${booking.date.toLocal().toString().split(' ')[0]}',
                        ),
                        subtitle: Text(
                          'Client: ${booking.clientName}\nLocation: ${booking.location}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Iconsax.trash, color: Colors.red),
                          tooltip: 'Remove Date',
                          onPressed: () {
                            // Remove booking
                            MockProjectBookingData().removeBooking(
                              booking.id as MockBooking,
                            );
                            setModalState(() {});
                            // Notify client (mock):
                            Get.back();
                            _showClientDateRemovedNotification(booking);
                          },
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }

  // Client notification when date is removed (mock):
  void _showClientDateRemovedNotification(MockBooking booking) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(30),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange,
              size: 60,
            ),
            const SizedBox(height: 20),
            const Text(
              'Booking Cancelled',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
            const SizedBox(height: 10),
            Text(
              'Your booking for ${booking.date.toLocal().toString().split(' ')[0]} at ${booking.location} has been removed by admin. Please contact support or book a new date.',
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Get.back(),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showGuestPrompt() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(30),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Iconsax.login, color: Colors.orange, size: 60),
            const SizedBox(height: 20),
            const Text(
              'Sign Up or Log In Required',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
            const SizedBox(height: 10),
            const Text(
              'You need an account to request a project or book a service.',
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => Get.toNamed('/customer-login'),
                  child: const Text('Log In'),
                ),
                OutlinedButton(
                  onPressed: () => Get.toNamed('/customer-register'),
                  child: const Text('Sign Up'),
                ),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // Show booking form bottom sheet for customer
  void _showBookingFormBottomSheet(BuildContext context, Project project) {
    String location = '';
    String size = '';
    double? transportCost;
    DateTime? pickedDate;
    bool isLoading = false;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              // Get all booked dates for this project
              final takenDates =
                  project.bookedDates
                      .map(
                        (b) => DateTime(b.date.year, b.date.month, b.date.day),
                      )
                      .toSet();
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 60,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Book Project: ${project.title}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Project Location',
                      ),
                      onChanged: (v) {
                        setModalState(() {
                          location = v;
                          transportCost = _calculateTransportCost(
                            location,
                            size,
                          );
                        });
                      },
                    ),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Project Size (e.g. 1000 sqm)',
                      ),
                      onChanged: (v) {
                        setModalState(() {
                          size = v;
                          transportCost = _calculateTransportCost(
                            location,
                            size,
                          );
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            pickedDate == null
                                ? 'No date picked'
                                : 'Picked Date: ${pickedDate!.toLocal().toString().split(' ')[0]}',
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            DateTime now = DateTime.now();
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: now,
                              firstDate: now,
                              lastDate: now.add(const Duration(days: 365)),
                              selectableDayPredicate: (date) {
                                return !takenDates.contains(
                                  DateTime(date.year, date.month, date.day),
                                );
                              },
                            );
                            if (picked != null) {
                              setModalState(() {
                                pickedDate = picked;
                              });
                            }
                          },
                          child: const Text('Pick Date'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (location.isNotEmpty &&
                        size.isNotEmpty &&
                        pickedDate != null)
                      Row(
                        children: [
                          const Text(
                            'Transport Cost: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            transportCost != null
                                ? ' ${transportCost!.toStringAsFixed(2)}'
                                : '--',
                          ),
                        ],
                      ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed:
                          location.isNotEmpty &&
                                  size.isNotEmpty &&
                                  pickedDate != null &&
                                  !isLoading
                              ? () async {
                                setModalState(() => isLoading = true);
                                try {
                                  // Add new booked date to Firestore
                                  final newBooking = BookedDate(
                                    date: pickedDate!,
                                    clientId: userController.userId.value,
                                    status: 'booked',
                                  );
                                  final updatedDates = List<BookedDate>.from(
                                    project.bookedDates,
                                  )..add(newBooking);
                                  await FirebaseService.instance
                                      .updateProject(project.id, {
                                        'bookedDates':
                                            updatedDates
                                                .map((e) => e.toMap())
                                                .toList(),
                                      });
                                  Navigator.pop(context);
                                  Get.snackbar(
                                    'Booked',
                                    'Project date booked successfully!',
                                    backgroundColor: Colors.green,
                                    colorText: Colors.white,
                                  );
                                } catch (e) {
                                  Get.snackbar(
                                    'Error',
                                    'Failed to book date: $e',
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                  );
                                } finally {
                                  setModalState(() => isLoading = false);
                                }
                              }
                              : null,
                      child:
                          isLoading
                              ? const CircularProgressIndicator()
                              : const Text('Book Date'),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // Add the _showRequestProjectForm method:
  void _showRequestProjectForm(BuildContext context) {
    final List<String> categories = [
      'Greenhouses',
      'Steel Structures',
      'Solar Systems',
      'Construction',
      'Logistics',
      'IoT & Automation',
    ];
    String? selectedCategory = categories.first;
    String location = '';
    String size = '';
    final userProfile = userController.userProfile.value;
    final nameController = TextEditingController(text: userProfile?.name ?? '');
    final emailController = TextEditingController(
      text: userProfile?.email ?? '',
    );
    final phoneController = TextEditingController();
    bool isLoading = false;
    DateTime? expectedStartDate;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[100],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        // Dispose controllers after the bottom sheet is closed
        return WillPopScope(
          onWillPop: () async {
            nameController.dispose();
            emailController.dispose();
            phoneController.dispose();
            return true;
          },
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: StatefulBuilder(
              builder: (context, setModalState) {
                return StreamBuilder<List<Project>>(
                  stream: FirebaseService.instance.getProjects(),
                  builder: (context, snapshot) {
                    final allProjects = snapshot.data ?? [];
                    double? matchedTransportCost;
                    for (final project in allProjects) {
                      if (project.category == selectedCategory &&
                          project.location.trim().toLowerCase() ==
                              location.trim().toLowerCase()) {
                        matchedTransportCost = project.transportCost;
                        break;
                      }
                    }
                    return SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header with Close Button
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryColor
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Iconsax.add_circle,
                                        color: AppTheme.primaryColor,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Request a Project',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Close Button
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Iconsax.close_circle,
                                    size: 20,
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                  color: Colors.grey[600],
                                  padding: const EdgeInsets.all(8),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const SizedBox(height: 18),
                          const Text(
                            'Contact Information',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const Divider(height: 24),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.grey[200]!,
                                width: 1,
                              ),
                            ),
                            child: TextField(
                              controller: nameController,
                              decoration: InputDecoration(
                                labelText: 'Your Name',
                                labelStyle: TextStyle(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                                prefixIcon: Container(
                                  margin: const EdgeInsets.all(12),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withOpacity(
                                      0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Iconsax.user,
                                    color: AppTheme.primaryColor,
                                    size: 18,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: AppTheme.primaryColor,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.grey[200]!,
                                width: 1,
                              ),
                            ),
                            child: TextField(
                              controller: emailController,
                              decoration: InputDecoration(
                                labelText: 'Your Email',
                                labelStyle: TextStyle(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                                prefixIcon: Container(
                                  margin: const EdgeInsets.all(12),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withOpacity(
                                      0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Iconsax.sms,
                                    color: AppTheme.primaryColor,
                                    size: 18,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: AppTheme.primaryColor,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.grey[200]!,
                                width: 1,
                              ),
                            ),
                            child: TextField(
                              controller: phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: 'Phone Number',
                                labelStyle: TextStyle(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                                prefixIcon: Container(
                                  margin: const EdgeInsets.all(12),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withOpacity(
                                      0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Iconsax.call,
                                    color: AppTheme.primaryColor,
                                    size: 18,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: AppTheme.primaryColor,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Project Details',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const Divider(height: 24),
                          DropdownButtonFormField<String>(
                            value: selectedCategory,
                            items:
                                categories
                                    .map(
                                      (cat) => DropdownMenuItem(
                                        value: cat,
                                        child: Text(cat),
                                      ),
                                    )
                                    .toList(),
                            onChanged:
                                (v) =>
                                    setModalState(() => selectedCategory = v),
                            decoration: InputDecoration(
                              labelText: 'Category',
                              prefixIcon: const Icon(Iconsax.category),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.grey[200]!,
                                width: 1,
                              ),
                            ),
                            child: TextField(
                              onChanged: (v) {
                                setModalState(() {
                                  location = v;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'Desired Project Location',
                                labelStyle: TextStyle(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                                prefixIcon: Container(
                                  margin: const EdgeInsets.all(12),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withOpacity(
                                      0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Iconsax.location,
                                    color: AppTheme.primaryColor,
                                    size: 18,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: AppTheme.primaryColor,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.grey[200]!,
                                width: 1,
                              ),
                            ),
                            child: TextField(
                              onChanged: (v) => size = v,
                              decoration: InputDecoration(
                                labelText:
                                    'Desired Project Size (e.g. 1000 sqm)',
                                labelStyle: TextStyle(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                                prefixIcon: Container(
                                  margin: const EdgeInsets.all(12),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withOpacity(
                                      0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Iconsax.size,
                                    color: AppTheme.primaryColor,
                                    size: 18,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: AppTheme.primaryColor,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(
                                Iconsax.calendar,
                                size: 18,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () async {
                                    DateTime now = DateTime.now();
                                    DateTime? picked = await showDatePicker(
                                      context: context,
                                      initialDate: expectedStartDate ?? now,
                                      firstDate: now,
                                      lastDate: DateTime(now.year + 5),
                                    );
                                    if (picked != null) {
                                      setModalState(() {
                                        expectedStartDate = picked;
                                      });
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                      horizontal: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.white,
                                    ),
                                    child: Text(
                                      expectedStartDate != null
                                          ? 'Expected Start Date: ${expectedStartDate!.toLocal().toString().split(' ')[0]}'
                                          : 'Pick Expected Start Date',
                                      style: TextStyle(
                                        color:
                                            expectedStartDate != null
                                                ? Colors.black
                                                : Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Summary',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const Divider(height: 24),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppTheme.primaryColor.withOpacity(0.2),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryColor.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryColor
                                              .withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Icon(
                                          Iconsax.document_text,
                                          color: AppTheme.primaryColor,
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'Project Summary',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  _buildSummaryRow('Name', nameController.text),
                                  _buildSummaryRow(
                                    'Email',
                                    emailController.text,
                                  ),
                                  if (phoneController.text.isNotEmpty)
                                    _buildSummaryRow(
                                      'Phone',
                                      phoneController.text,
                                    ),
                                  _buildSummaryRow(
                                    'Category',
                                    selectedCategory ?? '',
                                  ),
                                  _buildSummaryRow('Location', location),
                                  _buildSummaryRow('Size', size),
                                  if (matchedTransportCost != null)
                                    _buildSummaryRow(
                                      'Estimated Transport Cost',
                                      '\$${matchedTransportCost.toStringAsFixed(2)}',
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.primaryColor,
                                  AppTheme.secondaryColor,
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryColor.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed:
                                  isLoading ||
                                          nameController.text.isEmpty ||
                                          emailController.text.isEmpty ||
                                          location.isEmpty ||
                                          size.isEmpty ||
                                          selectedCategory == null
                                      ? null
                                      : () async {
                                        setModalState(() => isLoading = true);
                                        try {
                                          await FirebaseFirestore.instance
                                              .collection('projectRequests')
                                              .add({
                                                'name':
                                                    nameController.text.trim(),
                                                'email':
                                                    emailController.text.trim(),
                                                'phone':
                                                    phoneController.text.trim(),
                                                'location': location.trim(),
                                                'size': size.trim(),
                                                'category': selectedCategory,
                                                'expectedStartDate':
                                                    expectedStartDate != null
                                                        ? Timestamp.fromDate(
                                                          expectedStartDate!,
                                                        )
                                                        : null,
                                                'createdAt':
                                                    FieldValue.serverTimestamp(),
                                                'reviewed': false,
                                              });
                                          Navigator.pop(context);
                                          Get.snackbar(
                                            'Requested',
                                            'Project request submitted!',
                                            backgroundColor: Colors.green,
                                            colorText: Colors.white,
                                          );
                                        } catch (e) {
                                          Get.snackbar(
                                            'Error',
                                            'Failed to submit request: $e',
                                            backgroundColor: Colors.red,
                                            colorText: Colors.white,
                                          );
                                        } finally {
                                          setModalState(
                                            () => isLoading = false,
                                          );
                                        }
                                      },
                              child:
                                  isLoading
                                      ? const CircularProgressIndicator()
                                      : const Text('Submit Request'),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  // Helper widget for project details
  Widget _projectDetailItem(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  // Helper for detail cards
  Widget _buildDetailCard({
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
        border: Border.all(color: color.withOpacity(0.2), width: 1),
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
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // Helper for feature list
  Widget _buildFeatureList(List<String> features) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          features
              .map<Widget>(
                (feature) => Chip(
                  label: Text(feature),
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.08),
                  labelStyle: const TextStyle(fontSize: 13),
                ),
              )
              .toList(),
    );
  }

  // Helper for summary rows
  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'Not specified' : value,
              style: TextStyle(
                color: value.isEmpty ? Colors.grey[500] : Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper for progress color
  Color _getProgressColor(double progress) {
    if (progress >= 100) return Colors.green;
    if (progress >= 75) return Colors.blue;
    if (progress >= 50) return Colors.orange;
    if (progress >= 25) return Colors.yellow[700]!;
    return Colors.red;
  }
}
