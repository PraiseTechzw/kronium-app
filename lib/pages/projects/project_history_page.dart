import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kronium/core/app_theme.dart';
import 'package:kronium/models/project_model.dart';
import 'package:kronium/widgets/hover_widget.dart';

import 'package:lottie/lottie.dart';

class ProjectHistoryPage extends StatefulWidget {
  const ProjectHistoryPage({super.key});

  @override
  _ProjectHistoryPageState createState() => _ProjectHistoryPageState();
}

class _ProjectHistoryPageState extends State<ProjectHistoryPage> {
  final RxString _selectedFilter = 'All'.obs;
  final RxString _selectedSort = 'Newest First'.obs;
  final List<String> filters = ['All', 'Completed', 'In Progress', 'Pending', 'Upcoming'];
  final List<String> sortOptions = ['Newest First', 'Oldest First', 'By Project Name'];
  
  final List<Project> projects = [
    Project(
      title: 'Solar Panel Installation',
      date: 'June 15, 2025',
      status: 'Completed',
      progress: 1.0,
      color: const Color(0xFF2ECC71),
      icon: Iconsax.sun_1,
      details: 'Installed 20 solar panels with battery backup system for residential property',
      client: 'Green Energy Solutions',
      location: 'Nairobi, Kenya',
      team: ['John M.', 'Sarah K.', 'David T.'],
      images: [
        'assets/projects/solar1.jpg',
        'assets/projects/solar2.jpg',
        'assets/projects/solar3.jpg',
      ],
    ),
    Project(
      title: 'Greenhouse Construction',
      date: 'June 20, 2025',
      status: 'In Progress',
      progress: 0.7,
      color: const Color(0xFFF39C12),
      icon: Iconsax.home_hashtag,
      details: 'Constructing 1000 sq ft greenhouse with automated climate control systems',
      client: 'Fresh Farms Ltd',
      location: 'Nakuru, Kenya',
      team: ['Michael S.', 'Grace W.', 'Peter K.'],
      images: [
        'assets/projects/greenhouse1.jpg',
        'assets/projects/greenhouse2.jpg',
      ],
    ),
    Project(
      title: 'Farm Irrigation System',
      date: 'June 25, 2025',
      status: 'Pending',
      progress: 0.0,
      color: const Color(0xFFE74C3C),
      icon: Iconsax.drop,
      details: 'Designing water-efficient irrigation system for 5 acre commercial farm',
      client: 'AgriProduce Kenya',
      location: 'Eldoret, Kenya',
      team: ['James M.', 'Susan N.'],
      images: [],
    ),
    Project(
      title: 'Steel Warehouse',
      date: 'July 5, 2025',
      status: 'Upcoming',
      progress: 0.0,
      color: const Color(0xFF3498DB),
      icon: Iconsax.buildings,
      details: 'Planning 5000 sq ft steel structure warehouse with office complex',
      client: 'Logistics Africa',
      location: 'Mombasa, Kenya',
      team: ['Robert K.', 'Elizabeth W.'],
      images: [],
    ),
  ];

  List<Project> get filteredProjects {
    var result = projects;
    
    // Apply filter
    if (_selectedFilter.value != 'All') {
      result = result.where((p) => p.status == _selectedFilter.value).toList();
    }
    
    // Apply sort
    switch (_selectedSort.value) {
      case 'Newest First':
        result.sort((a, b) => b.date.compareTo(a.date));
        break;
      case 'Oldest First':
        result.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'By Project Name':
        result.sort((a, b) => a.title.compareTo(b.title));
        break;
    }
    
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Project Portfolio', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.filter),
            onPressed: _showFilterOptions,
            tooltip: 'Filter & Sort',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatsOverview(),
          Expanded(
            child: Obx(() {
              if (filteredProjects.isEmpty) {
                return _buildEmptyState();
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredProjects.length,
                itemBuilder: (context, index) {
                  return _projectTimelineCard(filteredProjects[index]);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview() {
    final completed = projects.where((p) => p.status == 'Completed').length;
    final inProgress = projects.where((p) => p.status == 'In Progress').length;
    final pending = projects.where((p) => p.status == 'Pending').length;
    final upcoming = projects.where((p) => p.status == 'Upcoming').length;

    return FadeInDown(
      child: Card(
        margin: const EdgeInsets.all(16),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                'Project Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statItem('Completed', completed, const Color(0xFF2ECC71)),
                  _statItem('In Progress', inProgress, const Color(0xFFF39C12)),
                  _statItem('Pending', pending, const Color(0xFFE74C3C)),
                  _statItem('Upcoming', upcoming, const Color(0xFF3498DB)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statItem(String label, int value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Text(
            value.toString(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _projectTimelineCard(Project project) {
    return FadeInUp(
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: HoverWidget(
          hoverChild: _buildProjectCardContent(project, true),
          onHover: (event) {},
          child: _buildProjectCardContent(project, false),
        ),
      ),
    );
  }

  Widget _buildProjectCardContent(Project project, bool isHovered) {
    return GestureDetector(
      onTap: () => _showProjectDetails(project),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isHovered
              ? [
                  BoxShadow(
                    color: project.color.withOpacity(0.2),
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: project.color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: project.color.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  project.icon,
                  color: Colors.white,
                  size: 12,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          project.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Chip(
                          backgroundColor: project.color.withOpacity(0.1),
                          label: Text(
                            project.status,
                            style: TextStyle(
                              color: project.color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Iconsax.calendar, size: 14, color: Colors.grey),
                        const SizedBox(width: 5),
                        Text(
                          project.date,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 15),
                        const Icon(Iconsax.location, size: 14, color: Colors.grey),
                        const SizedBox(width: 5),
                        Text(
                          project.location,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      project.details,
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 15),
                    if (project.status == 'In Progress')
                      Column(
                        children: [
                          LinearProgressIndicator(
                            value: project.progress,
                            backgroundColor: Colors.grey[200],
                            color: project.color,
                            minHeight: 6,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Project Progress',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                '${(project.progress * 100).toInt()}%',
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
      ),
    );
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
            'No projects found for "${_selectedFilter.value}"',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              _selectedFilter.value = 'All';
            },
            child: const Text('Reset Filters'),
          ),
        ],
      ),
    );
  }

  void _showFilterOptions() {
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
            mainAxisSize: MainAxisSize.min,
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
              const Text(
                'Filter & Sort Projects',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Filter by Status',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Obx(() => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: filters.map((filter) => ChoiceChip(
                  label: Text(filter),
                  selected: _selectedFilter.value == filter,
                  onSelected: (selected) {
                    _selectedFilter.value = filter;
                  },
                  selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: _selectedFilter.value == filter 
                        ? AppTheme.primaryColor 
                        : Colors.grey[700],
                  ),
                )).toList(),
              )),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Sort by',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Obx(() => Column(
                children: sortOptions.map((option) => RadioListTile(
                  title: Text(option),
                  value: option,
                  groupValue: _selectedSort.value,
                  onChanged: (value) {
                    _selectedSort.value = value.toString();
                  },
                  activeColor: AppTheme.primaryColor,
                  contentPadding: EdgeInsets.zero,
                )).toList(),
              )),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Apply Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProjectDetails(Project project) {
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: project.color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      project.icon,
                      color: project.color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          project.client,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (project.images.isNotEmpty) ...[
                SizedBox(
                  height: 200,
                  child: PageView.builder(
                    itemCount: project.images.length,
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          project.images[index],
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
              const Text(
                'Project Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(project.details),
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
              _projectDetailItem('Status', project.status, project.color),
              _projectDetailItem('Location', project.location, Colors.grey[600]!),
              _projectDetailItem('Start Date', project.date, Colors.grey[600]!),
              _projectDetailItem('Project Team', project.team.join(', '), Colors.grey[600]!),
              if (project.status == 'In Progress') ...[
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 10),
                const Text(
                  'Project Progress',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: project.progress,
                  backgroundColor: Colors.grey[200],
                  color: project.color,
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(5),
                ),
                const SizedBox(height: 5),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${(project.progress * 100).toInt()}% Complete',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  Get.toNamed('/book-project', arguments: {'similarTo': project.title});
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'REQUEST SIMILAR PROJECT',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _projectDetailItem(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}