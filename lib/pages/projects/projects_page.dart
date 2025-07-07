import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kronium/core/app_theme.dart';
import 'package:kronium/core/routes.dart';
import 'package:kronium/widgets/hover_widget.dart';

import 'package:lottie/lottie.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  ProjectsPageState createState() => ProjectsPageState();
}

class ProjectsPageState extends State<ProjectsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> categories = ['All', 'Completed', 'Ongoing', 'Featured'];
  final RxString _searchQuery = ''.obs;
  final RxString _selectedSort = 'Newest'.obs;

  final List<Map<String, dynamic>> projects = [
    {
      'title': 'Solar Farm Installation',
      'category': 'Completed',
      'image': 'assets/projects/solar_farm.jpg',
      'date': 'June 2023',
      'location': 'Nairobi, Kenya',
      'description': '5MW solar farm installation for commercial energy production',
      'features': ['50,000 panels', 'Battery storage', 'Grid integration', '20-year maintenance'],
      'client': 'Green Energy Solutions Ltd.',
      'testimonial': 'KRONIUM delivered ahead of schedule with excellent quality control.',
    },
    {
      'title': 'Industrial Greenhouse Complex',
      'category': 'Ongoing',
      'image': 'assets/projects/greenhouse.jpg',
      'date': 'January 2024',
      'location': 'Nakuru, Kenya',
      'description': '10-acre automated greenhouse for year-round vegetable production',
      'features': ['Climate control', 'Hydroponic systems', 'Automated irrigation', 'IoT monitoring'],
      'client': 'FreshFarms Kenya',
      'progress': 65,
    },
    {
      'title': 'Commercial Steel Structure',
      'category': 'Completed',
      'image': 'assets/projects/steel_building.jpg',
      'date': 'September 2023',
      'location': 'Mombasa, Kenya',
      'description': '15,000 sq ft steel warehouse with office complex',
      'features': ['Quick assembly', 'Custom design', 'Energy efficient', '10-year warranty'],
      'client': 'LogiStore Africa',
      'testimonial': 'The most professional construction team we\'ve worked with.',
    },
    {
      'title': 'Farm Automation System',
      'category': 'Featured',
      'image': 'assets/projects/farm_tech.jpg',
      'date': 'March 2024',
      'location': 'Eldoret, Kenya',
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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Our Portfolio', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.search_normal),
            onPressed: _showSearchDialog,
            tooltip: 'Search Projects',
          ),
          IconButton(
            icon: const Icon(Iconsax.sort),
            onPressed: _showSortDialog,
            tooltip: 'Sort Projects',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              FadeInDown(
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white.withOpacity(0.6),
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white.withOpacity(0.2),
                    ),
                    tabs: categories.map((category) => Tab(text: category)).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Obx(() => _searchQuery.value.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Showing results for "${_searchQuery.value}"',
                        style: const TextStyle(color: Colors.white),
                      ),
                    )
                  : const SizedBox()),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: categories.map((category) {
          return _buildProjectList(category);
        }).toList(),
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
        : category == 'All' 
            ? projects 
            : projects.where((project) => project['category'] == category).toList();

    // Apply sorting
    filteredProjects = _sortProjects(filteredProjects);

    return filteredProjects.isEmpty
        ? _buildEmptyState()
        : Padding(
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
      child: _buildProjectCardContent(project, false),
    );
  }

  Widget _buildProjectCardContent(Map<String, dynamic> project, bool isHover) {
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
                    color: AppTheme.primaryColor.withOpacity(0.2),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.asset(
                    project['image'],
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                if (project['category'] == 'Ongoing' || project['category'] == 'Featured')
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: project['category'] == 'Featured' 
                            ? Colors.amber 
                            : AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        project['category'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project['title'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Iconsax.location, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        project['location'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    project['description'],
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 15),
                  if (project['progress'] != null)
                    Column(
                      children: [
                        LinearProgressIndicator(
                          value: project['progress'] / 100,
                          backgroundColor: Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${project['progress']}% Complete',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  if (project['testimonial'] != null)
                    Column(
                      children: [
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Iconsax.quote_down, size: 16, color: Colors.grey),
                            const SizedBox(width: 5),
                            Text(
                              'Client Feedback',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search projects...',
                  prefixIcon: const Icon(Iconsax.search_normal),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  _searchQuery.value = value;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Get.back(),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSortDialog() {
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Sort Projects By',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ...['Newest', 'Oldest', 'Location'].map((option) => Obx(
              () => ListTile(
                title: Text(option),
                leading: Radio(
                  value: option,
                  groupValue: _selectedSort.value,
                  onChanged: (value) {
                    _selectedSort.value = value.toString();
                    Get.back();
                  },
                  activeColor: AppTheme.primaryColor,
                ),
                onTap: () {
                  _selectedSort.value = option;
                  Get.back();
                },
              ),
            )),
          ],
        ),
      ),
    );
  }

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
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Iconsax.quote_down, size: 24, color: Colors.grey),
                      const SizedBox(height: 10),
                      Text(
                        project['testimonial'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '- ${project['client']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
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
                        Get.toNamed(AppRoutes.bookProject);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'BOOK SIMILAR PROJECT',
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

  Widget _projectDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}