import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kronium/core/app_theme.dart';
import 'package:kronium/widgets/hover_widget.dart';

import 'package:lottie/lottie.dart';
import 'mock_project_booking_data.dart';
import 'package:kronium/core/user_auth_service.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  ProjectsPageState createState() => ProjectsPageState();
}

class ProjectsPageState extends State<ProjectsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
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

  final List<Map<String, dynamic>> projects = [
    {
      'title': 'Solar Farm Installation',
      'category': 'Completed',
      'image': 'https://images.china.cn/attachement/jpg/site1007/20140903/e89a8f5fc4c21570d2e420.jpg',
      'date': 'June 2023',
      'location': 'Harare, Zimbabwe',
      'description': '5MW solar farm installation for commercial energy production',
      'features': ['50,000 panels', 'Battery storage', 'Grid integration', '20-year maintenance'],
      'client': 'Green Energy Solutions Ltd.',
      'testimonial': 'KRONIUM delivered ahead of schedule with excellent quality control.',
    },
    {
      'title': 'Industrial Greenhouse Complex',
      'category': 'Ongoing',
      'image': 'https://harnoisgreenhouse.com/wp-content/uploads/2024/02/Projet_Herbes-Gourmandes-2--1024x683.webp',
      'date': 'January 2024',
      'location': 'Bulawayo, Zimbabwe',
      'description': '10-acre automated greenhouse for year-round vegetable production',
      'features': ['Climate control', 'Hydroponic systems', 'Automated irrigation', 'IoT monitoring'],
      'client': 'FreshFarms Zimbabwe',
      'progress': 65,
    },
    {
      'title': 'Commercial Steel Structure',
      'category': 'Completed',
      'image': 'https://media.graphassets.com/resize=width:800/output=format:webp/82AmyZlQBWZBxJaKpGxF',
      'date': 'September 2023',
      'location': 'Mutare, Zimbabwe',
      'description': '15,000 sq ft steel warehouse with office complex',
      'features': ['Quick assembly', 'Custom design', 'Energy efficient', '10-year warranty'],
      'client': 'LogiStore Africa',
      'testimonial': 'The most professional construction team we\'ve worked with.',
    },
    {
      'title': 'Farm Automation System',
      'category': 'Featured',
      'image': 'https://imgproxy.divecdn.com/r1fQ9Ook6EvUz6BTCJ8YsZOfd_vXi5tUQHMOvHoQEos/g:ce/rs:fill:1200:675:1/Z3M6Ly9kaXZlc2l0ZS1zdG9yYWdlL2RpdmVpbWFnZS9HZXR0eUltYWdlcy0xNDY5NjM5NzkxLmpwZw==.webp',
      'date': 'March 2024',
      'location': 'Gweru, Zimbabwe',
      'description': 'Complete IoT solution for 500-acre wheat farm',
      'features': ['Soil sensors', 'Drone monitoring', 'Automated irrigation', 'Yield prediction'],
      'client': 'GoldenFields Agribusiness',
      'progress': 30,
    },
  ];

  // A. Real-Time Date Availability (mock):
  List<DateTime> _globalUnavailableDates = [];

  // --- E. User Experience Enhancements ---
  // 1. Progress indicator (stepper) for booking flow
  // 2. Save user info for next time (mock, local variable)

  // Add these variables at the top of your state class:
  String? _savedName, _savedEmail, _savedPhone;

  // Add these at the top of ProjectsPageState:
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Add this variable to your state class:
  double? _transportCost;

  // Add this to the state class:
  Map<String, dynamic>? _selectedProject;

  // Add this variable to the state class for admin check:
  bool _isAdmin = true; // Set to false for normal users

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Kronium Projects',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          ),
        automaticallyImplyLeading: false,
        actions: [
          if (_isAdmin)
            IconButton(
              icon: const Icon(Iconsax.calendar_remove, color: Colors.white),
              tooltip: 'Manage Booked Dates',
              onPressed: _showAdminBookedDatesBottomSheet,
            ),
          Container(),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Search/filter row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  children: [
                    // Search bar
                    Expanded(
                      child: TextField(
                        onChanged: (value) => setState(() => _searchQuery.value = value),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search projects...',
                          hintStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: AppTheme.primaryColor.withOpacity(0.15),
                          prefixIcon: const Icon(Iconsax.search_normal, color: Colors.white70, size: 20),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Filter dropdown
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedSort.value,
                        dropdownColor: AppTheme.primaryColor,
                        icon: const Icon(Iconsax.arrow_down_1, color: Colors.white),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        items: ['Newest', 'Oldest', 'Location'].map((option) {
                          return DropdownMenuItem<String>(
                            value: option,
                            child: Text(option, style: const TextStyle(color: Colors.white)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedSort.value = value!);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // TabBar
              SafeArea(
                bottom: false,
                child: Container(
                  color: AppTheme.primaryColor,
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white.withOpacity(0.7),
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white.withOpacity(0.18),
                    ),
                    tabs: categories.map((category) => Tab(text: category)).toList(),
                  ),
                ),
              ),
            ],
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
                style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
              ),
            ),
          Expanded(
            child: TabBarView(
        controller: _tabController,
        children: categories.map((category) {
          return _buildProjectList(category);
        }).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: userController.role.value == 'customer' && _selectedProject != null
        ? FloatingActionButton.extended(
            onPressed: () => _showBookingFormBottomSheet(context, _selectedProject!),
            icon: const Icon(Iconsax.message_question),
            label: const Text('Request Similar Project'),
            backgroundColor: AppTheme.primaryColor,
          )
        : userController.role.value == 'guest' && _selectedProject != null
          ? FloatingActionButton.extended(
              onPressed: () => _showGuestPrompt(),
              icon: const Icon(Iconsax.login),
              label: const Text('Sign Up to Request'),
              backgroundColor: Colors.orange,
            )
          : null,
    );
  }

  Widget _buildProjectList(String category) {
    List<Map<String, dynamic>> filteredProjects = _searchQuery.value.isNotEmpty
        ? projects.where((project) => 
            project['title'].toLowerCase().contains(_searchQuery.value.toLowerCase()) ||
            project['description'].toLowerCase().contains(_searchQuery.value.toLowerCase()))
            .toList()
        : category == 'All Projects'
            ? projects 
            : projects.where((project) =>
                project['title'].toString().toLowerCase().contains(category.toLowerCase()) ||
                (project['category']?.toString().toLowerCase() == category.toLowerCase())
              ).toList();

    // Apply sorting
    filteredProjects = _sortProjects(filteredProjects);

    // If no projects, show empty state only (prevents RangeError)
    if (filteredProjects.isEmpty) {
      return _buildEmptyState();
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
              itemCount: filteredProjects.length,
              itemBuilder: (context, index) {
                return _projectCard(filteredProjects[index]);
              },
            ),
          );
  }

  List<Map<String, dynamic>> _sortProjects(List<Map<String, dynamic>> projects) {
    switch (_selectedSort.value) {
      case 'Newest':
        return projects..sort((a, b) => b['date'].compareTo(a['date']));
      case 'Oldest':
        return projects..sort((a, b) => a['date'].compareTo(b['date']));
      case 'Location':
        return projects..sort((a, b) => a['location'].compareTo(b['location']));
      default:
        return projects;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/search_empty.json',
            width: 200,
            height: 200,
          ),
          const SizedBox(height: 20),
          Text(
            _searchQuery.value.isEmpty
                ? 'No projects available in this category'
                : 'No projects found for "${_searchQuery.value}"',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              _searchQuery.value = '';
              _tabController.animateTo(0);
            },
            child: const Text('View All Projects'),
          ),
        ],
      ),
    );
  }

  Widget _projectCard(Map<String, dynamic> project) {
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

  Widget _buildProjectCardContent(Map<String, dynamic> project, bool isHover) {
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
          borderRadius: BorderRadius.circular(16),
          boxShadow: isHover
              ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.13),
                    blurRadius: 15,
                    spreadRadius: 1,
                    offset: const Offset(0, 5),
                  ),
                ]
              : [
                  const BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    spreadRadius: 1,
                    offset: Offset(0, 3),
                  ),
                ],
        ),
        child: IntrinsicHeight(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: SizedBox(
                  height: 100,
                    width: double.infinity,
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: Image.network(
                      project['image'],
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                  child: SingleChildScrollView(
                    // If content is too long, allow scroll inside card
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                project['title'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (project['category'] == 'Ongoing' || project['category'] == 'Featured')
                              GestureDetector(
                                onTap: () {
                                  if (project['category'] == 'Ongoing') {
                                    _tabController.animateTo(categories.indexOf('Ongoing'));
                                  } else if (project['category'] == 'Featured') {
                                    _tabController.animateTo(categories.indexOf('Featured'));
                                  }
                                },
                    child: Container(
                                  margin: const EdgeInsets.only(left: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: project['category'] == 'Featured' 
                            ? Colors.amber 
                            : AppTheme.primaryColor,
                                    borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        project['category'],
                        style: const TextStyle(
                          color: Colors.white,
                                      fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
                        const SizedBox(height: 3),
                        Row(
                children: [
                            const Icon(Iconsax.location, size: 12, color: Colors.grey),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                project['location'],
                    style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                        const SizedBox(height: 4),
                  Text(
                    project['description'],
                    style: const TextStyle(
                            fontSize: 11,
                      color: Colors.grey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                        if (project['progress'] != null) ...[
                          const SizedBox(height: 6),
                        LinearProgressIndicator(
                          value: project['progress'] / 100,
                            backgroundColor: AppTheme.surfaceLight,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                            minHeight: 5,
                          borderRadius: BorderRadius.circular(3),
                        ),
                          const SizedBox(height: 2),
                        Text(
                          '${project['progress']}% Complete',
                          style: const TextStyle(
                              fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                        if (project['testimonial'] != null) ...[
                          const SizedBox(height: 4),
                        Row(
                          children: [
                              const Icon(Iconsax.quote_down, size: 11, color: Colors.grey),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Text(
                              'Client Feedback',
                              style: TextStyle(
                                    fontSize: 10,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                            ),
                        ),
                      ],
                    ),
                ],
          ],
        ),
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

  void _showProjectDetails(Map<String, dynamic> project) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
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
                project['title'],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Icon(Iconsax.location, size: 16, color: Colors.grey),
                  const SizedBox(width: 5),
                  Text(
                    project['location'],
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const Spacer(),
                  if (project['category'] != null)
                  Chip(
                    label: Text(project['category']),
                    backgroundColor: project['category'] == 'Featured'
                        ? Colors.amber.withOpacity(0.2)
                        : AppTheme.primaryColor.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: project['category'] == 'Featured'
                          ? Colors.amber[800]
                          : AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  project['image'],
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Project Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                project['description'],
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),
              const Text(
                'Project Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _projectDetailItem('Date Completed', project['date']),
              _projectDetailItem('Client', project['client']),
              if (project['progress'] != null)
                _projectDetailItem('Progress', '${project['progress']}% Complete'),
              const SizedBox(height: 20),
              const Text(
                'Key Features',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Column(
                children: project['features'].map<Widget>((feature) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle, color: AppTheme.primaryColor, size: 20),
                      const SizedBox(width: 10),
                      Expanded(child: Text(feature)),
                    ],
                  ),
                )).toList(),
              ),
              if (project['testimonial'] != null) ...[
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 10),
                const Text(
                  'Client Testimonial',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Iconsax.quote_down, size: 24, color: Colors.white),
                      const SizedBox(height: 10),
                      Text(
                        project['testimonial'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          height: 1.5,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '- ${project['client']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('VIEW MORE PROJECTS'),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        if (userController.role.value == 'customer') {
                          _showBookingFormBottomSheet(context, project);
                        } else if (userController.role.value == 'guest') {
                          _showGuestPrompt();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        userController.role.value == 'guest'
                          ? 'SIGN UP TO REQUEST'
                          : 'REQUEST SIMILAR PROJECT',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProjectDatePicker(Map<String, dynamic> project) async {
    DateTime now = DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      selectableDayPredicate: (date) {
        return !_takenDates.any((d) => d.year == date.year && d.month == date.month && d.day == date.day);
      },
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: AppTheme.surfaceLight,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      if (_takenDates.any((d) => d.year == picked.year && d.month == picked.month && d.day == picked.day)) {
        // Date is taken, propose next available
        DateTime nextAvailable = picked.add(const Duration(days: 1));
        while (_takenDates.any((d) => d.year == nextAvailable.year && d.month == nextAvailable.month && d.day == nextAvailable.day)) {
          nextAvailable = nextAvailable.add(const Duration(days: 1));
        }
        Get.snackbar(
          'Date Unavailable',
          'The selected date is already booked. Next available: ${nextAvailable.toLocal().toString().split(' ')[0]}',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      } else {
        // Mark the date as booked in the provider (mock)
        MockProjectBookingData().addBooking(MockBooking(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          clientName: 'Client',
          clientContact: '',
          date: picked,
          location: project['location'] ?? '',
          size: '',
          transportCost: 0,
          status: 'booked',
        ));
        Get.snackbar(
          'Date Selected',
          'You selected: ${picked.toLocal().toString().split(' ')[0]}. Date is now reserved for you!',
          backgroundColor: AppTheme.primaryColor,
          colorText: Colors.white,
        );
      }
    }
  }

  Widget _projectDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.label, color: Colors.grey, size: 16),
          const SizedBox(width: 10),
          Text(
            '$label: $value',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic>? _getSelectedProject() {
    return _selectedProject;
  }

  void _showBookingFormBottomSheet(BuildContext context, Map<String, dynamic> project) {
    // --- Modular Booking Bottom Sheet for Project Request ---
    final List<String> projectTypes = [
      'Greenhouse',
      'Construction',
      'Solar Systems',
      'Irrigation Systems',
      'Logistics',
    ];
    int _currentStep = 0;
    String? _selectedType = projectTypes.first;
    DateTime? _selectedDate;
    String _location = '';
    String _size = '';
    double? _liveTransportCost;
    final _formKey = GlobalKey<FormState>();
    
    // Prefill user info if available
    _nameController.text = _savedName ?? '';
    _emailController.text = _savedEmail ?? '';
    _phoneController.text = _savedPhone ?? '';

    void _updateTransportCost() {
      _liveTransportCost = _calculateSmartTransportCost(_location, _size);
    }

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setModalState) {
          void nextStep() {
            if (_currentStep < 2) {
              setModalState(() => _currentStep++);
            }
          }
          void prevStep() {
            if (_currentStep > 0) {
              setModalState(() => _currentStep--);
            }
          }
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // --- Stepper Indicator ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.looks_one, color: _currentStep == 0 ? AppTheme.primaryColor : Colors.grey),
                    Container(width: 30, height: 2, color: _currentStep > 0 ? AppTheme.primaryColor : Colors.grey[300]),
                    Icon(Icons.looks_two, color: _currentStep == 1 ? AppTheme.primaryColor : Colors.grey),
                    Container(width: 30, height: 2, color: _currentStep > 1 ? AppTheme.primaryColor : Colors.grey[300]),
                    Icon(Icons.looks_3, color: _currentStep == 2 ? AppTheme.primaryColor : Colors.grey),
                  ],
                ),
                const SizedBox(height: 20),
                if (_currentStep == 0) ...[
                  // --- Step 1: Select Project Type ---
                  const Text('Select Project Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    children: projectTypes.map((type) => ChoiceChip(
                      label: Text(type),
                      selected: _selectedType == type,
                      onSelected: (selected) {
                        setModalState(() => _selectedType = type);
                      },
                      selectedColor: AppTheme.primaryColor,
                      labelStyle: TextStyle(color: _selectedType == type ? Colors.white : AppTheme.primaryColor),
                    )).toList(),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: nextStep,
                        child: const Text('Next'),
                      ),
                    ],
                  ),
                ] else if (_currentStep == 1) ...[
                  // --- Step 2: User Details & Date ---
                  const Text('Your Details & Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 10),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(labelText: 'Full Name'),
                          validator: (v) => v == null || v.isEmpty ? 'Enter your name' : null,
                        ),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(labelText: 'Email'),
                          validator: (v) => v == null || v.isEmpty ? 'Enter your email' : null,
                        ),
                        TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(labelText: 'Phone'),
                          validator: (v) => v == null || v.isEmpty ? 'Enter your phone' : null,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Text(_selectedDate == null
                                ? 'No date selected'
                                : 'Date: \\${_selectedDate!.toLocal().toString().split(' ')[0]}'),
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
                                    return !_takenDates.any((d) => d.year == date.year && d.month == date.month && d.day == date.day);
                                  },
                                );
                                if (picked != null) {
                                  setModalState(() => _selectedDate = picked);
                                }
                              },
                              child: const Text('Pick Date'),
                            ),
                          ],
                        ),
                        if (_selectedDate != null && _takenDates.any((d) => d.year == _selectedDate!.year && d.month == _selectedDate!.month && d.day == _selectedDate!.day))
                          const Text('Selected date is unavailable. Please pick another.', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(onPressed: prevStep, child: const Text('Back')),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate() && _selectedDate != null && !_takenDates.any((d) => d.year == _selectedDate!.year && d.month == _selectedDate!.month && d.day == _selectedDate!.day)) {
                            nextStep();
                          }
                        },
                        child: const Text('Next'),
                      ),
                    ],
                  ),
                ] else if (_currentStep == 2) ...[
                  // --- Step 3: Location, Size, Transport Cost ---
                  const Text('Project Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Project Location'),
                    onChanged: (v) {
                      setModalState(() {
                        _location = v;
                        _updateTransportCost();
                      });
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Project Size (e.g. 1000 sqm)'),
                    onChanged: (v) {
                      setModalState(() {
                        _size = v;
                        _updateTransportCost();
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  if (_location.isNotEmpty && _size.isNotEmpty)
                    Row(
                      children: [
                        const Text('Estimated Transport Cost: ', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(_liveTransportCost != null ? '\\${_liveTransportCost!.toStringAsFixed(2)} USD' : '--'),
                      ],
                    ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(onPressed: prevStep, child: const Text('Back')),
                      ElevatedButton(
                        onPressed: _location.isNotEmpty && _size.isNotEmpty
                          ? () {
                              // Save user info for next time (mock)
                              _savedName = _nameController.text;
                              _savedEmail = _emailController.text;
                              _savedPhone = _phoneController.text;
                              // Mock booking submission
                              Get.back();
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
                                      const Icon(Icons.check_circle, color: Colors.green, size: 60),
                                      const SizedBox(height: 20),
                                      const Text('Request Submitted!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                                      const SizedBox(height: 10),
                                      Text('We have received your request for a $_selectedType project on \\${_selectedDate!.toLocal().toString().split(' ')[0]}. Our team will contact you soon.'),
                                      const SizedBox(height: 20),
                                      ElevatedButton(
                                        onPressed: () => Get.back(),
                                        child: const Text('Close'),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                          : null,
                        child: const Text('Submit'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }

  // B. Smart Transport Cost Calculation (mock):
  double _calculateSmartTransportCost(String location, String size) {
    // Mock: base + (size length * 2) + (location length * 1.5) + random distance factor
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
                const Text('Booked Project Dates', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 10),
                if (bookings.isEmpty)
                  const Text('No booked dates.'),
                if (bookings.isNotEmpty)
                  ...bookings.map((booking) => Card(
                    child: ListTile(
                      title: Text('Date: \\${booking.date.toLocal().toString().split(' ')[0]}'),
                      subtitle: Text('Client: \\${booking.clientName}\nLocation: \\${booking.location}'),
                      trailing: IconButton(
                        icon: const Icon(Iconsax.trash, color: Colors.red),
                        tooltip: 'Remove Date',
                        onPressed: () {
                          // Remove booking
                          MockProjectBookingData().removeBooking(booking.id as MockBooking);
                          setModalState(() {});
                          // Notify client (mock):
                          Get.back();
                          _showClientDateRemovedNotification(booking);
                        },
                      ),
                    ),
                  )),
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
            const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 60),
            const SizedBox(height: 20),
            const Text('Booking Cancelled', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
            const SizedBox(height: 10),
            Text('Your booking for \\${booking.date.toLocal().toString().split(' ')[0]} at \\${booking.location} has been removed by admin. Please contact support or book a new date.'),
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
            const Text('Sign Up or Log In Required', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
            const SizedBox(height: 10),
            const Text('You need an account to request a project or book a service.'),
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
}