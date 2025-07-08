import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kronium/core/app_theme.dart';
import 'package:kronium/core/routes.dart';
import 'package:kronium/widgets/hover_widget.dart';

import 'package:lottie/lottie.dart';
import 'mock_project_booking_data.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
  }

  @override
  void dispose() {
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
        actions: [Container()],
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.bookProject),
        icon: const Icon(Iconsax.message_question),
        label: const Text('Request Similar Project'),
        backgroundColor: AppTheme.primaryColor,
      ),
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
        onTap: () => _showProjectDetails(project),
      child: _buildProjectCardContent(project, false),
      ),
    );
  }

  Widget _buildProjectCardContent(Map<String, dynamic> project, bool isHover) {
    // Use IntrinsicHeight to allow card to size to content, preventing overflow
    return GestureDetector(
      onTap: () => _showProjectDetails(project),
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
                        _showProjectDatePicker(project);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'REQUEST SIMILAR PROJECT',
                        style: TextStyle(color: Colors.white),
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
}