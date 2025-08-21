import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kronium/core/app_theme.dart';
import 'package:kronium/widgets/hover_widget.dart';

import 'package:lottie/lottie.dart';
import 'mock_project_booking_data.dart';
import 'package:kronium/core/user_auth_service.dart';
import 'package:kronium/core/firebase_service.dart';
import 'package:kronium/models/project_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    // 5. Remove the _loadProjects method and any local projects list.
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // 5. Remove the _loadProjects method and any local projects list.

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
                        items: ['Newest', 'Oldest', 'Location', 'Title'].map((option) {
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
        onPressed: () => _showRequestProjectForm(context),
            icon: const Icon(Iconsax.message_question),
        label: const Text('Request a Project'),
            backgroundColor: AppTheme.primaryColor,
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
        projects = _searchQuery.value.isNotEmpty
        ? projects.where((project) => 
                project.title.toLowerCase().contains(_searchQuery.value.toLowerCase()) ||
                project.description.toLowerCase().contains(_searchQuery.value.toLowerCase()))
            .toList()
        : category == 'All Projects'
            ? projects 
            : projects.where((project) =>
                    project.title.toString().toLowerCase().contains(category.toLowerCase())).toList();

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
                      project.mediaUrls.isNotEmpty ? project.mediaUrls.first : '',
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
                                project.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
                                project.location,
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
                    project.description,
                    style: const TextStyle(
                            fontSize: 11,
                      color: Colors.grey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                        ...[
                        const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: project.progress / 100,
                          backgroundColor: AppTheme.surfaceLight,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                          minHeight: 5,
                        borderRadius: BorderRadius.circular(3),
                      ),
                        const SizedBox(height: 2),
                      Text(
                        '${project.progress}% Complete',
                        style: const TextStyle(
                            fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
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
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- IMAGE & HEADER ---
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                      ),
                        child: Image.network(
                          project.mediaUrls.isNotEmpty ? project.mediaUrls.first : '',
                          width: double.infinity,
                          height: 240,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 240,
                            color: Colors.grey[200],
                            child: const Center(child: Icon(Icons.broken_image, size: 60, color: Colors.grey)),
                    ),
                  ),
                      ),
                      Positioned(
                        left: 20,
                        bottom: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                    project.title,
                        style: const TextStyle(
                                  color: Colors.white,
                      fontWeight: FontWeight.bold,
                                  fontSize: 20,
                        ),
                      ),
                            ),
                      ],
                          ),
                        ),
                    ],
                  ),
                   const SizedBox(height: 18),
                   // --- PROJECT OVERVIEW ---
                   Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 20),
                     child: Card(
                       elevation: 0,
                       color: Colors.grey[50],
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                       child: Padding(
                         padding: const EdgeInsets.all(18),
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Row(
                               children: [
                                 const Icon(Iconsax.location, size: 18, color: AppTheme.primaryColor),
                                 const SizedBox(width: 6),
                                 Expanded(
                                   child: Text(
                                     project.location,
                                     style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                                   ),
                                 ),
                                 const SizedBox(width: 10),
                                 if (project.date != null)
                                   Row(
                                     children: [
                                       const Icon(Iconsax.calendar, size: 16, color: Colors.grey),
                                       const SizedBox(width: 4),
                                       Text(project.date!.toLocal().toString().split(' ')[0], style: const TextStyle(fontSize: 13, color: Colors.grey)),
                                     ],
                                   ),
                               ],
                  ),
                             const SizedBox(height: 14),
                  const Text(
                    'Project Overview',
                               style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                             const SizedBox(height: 6),
                  Text(
                               project.description,
                               style: const TextStyle(fontSize: 15, height: 1.5),
                  ),
                             const SizedBox(height: 14),
                             _projectDetailItem('Progress', '${project.progress}% Complete'),
                             ...[
                             const SizedBox(height: 8),
                             LinearProgressIndicator(
                               value: project.progress / 100,
                               backgroundColor: AppTheme.surfaceLight,
                               valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                               minHeight: 6,
                               borderRadius: BorderRadius.circular(3),
                             ),
                           ],
                           ],
                         ),
                       ),
                    ),
                  ),
                   const SizedBox(height: 18),
                   // --- KEY FEATURES ---
                   Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 20),
                     child: Card(
                       elevation: 0,
                       color: Colors.grey[50],
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                       child: Padding(
                         padding: const EdgeInsets.all(18),
                         child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                             const Text('Key Features', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                             const SizedBox(height: 10),
                             Wrap(
                               spacing: 8,
                               runSpacing: 8,
                               children: project.features
                                   .map<Widget>((feature) => Chip(
                                         label: Text(feature),
                                         backgroundColor: AppTheme.primaryColor.withOpacity(0.08),
                                         labelStyle: const TextStyle(fontSize: 13),
                                       ))
                                   .toList(),
                             ),
                           ],
                         ),
                       ),
                      ),
                    ),
                   const SizedBox(height: 18),
                   // --- BOOKED DATES ---
                   Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 20),
                     child: Card(
                       elevation: 0,
                       color: Colors.grey[50],
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                       child: Padding(
                         padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                             const Text('Booked Dates', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 10),
                  if (project.bookedDates.isNotEmpty)
                    ...project.bookedDates.map((booking) => Card(
                              color: Colors.white,
                                     elevation: 0,
                                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                                       leading: const Icon(Iconsax.calendar, color: AppTheme.primaryColor),
                        title: Text('Date: ${booking.date.toLocal().toString().split(' ')[0]}'),
                        subtitle: Text('Status: ${booking.status}'),
                      ),
                    )),
                           ],
                         ),
                       ),
                     ),
                   ),
                   const SizedBox(height: 18),
                   // --- BOOK A DATE ---
                   Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 20),
                     child: Card(
                       elevation: 0,
                       color: Colors.grey[50],
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                       child: Padding(
                         padding: const EdgeInsets.all(18),
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             const Text('Book a Date for Project', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Project Location'),
                    onChanged: (v) {
                      setModalState(() {
                        location = v;
                        transportCost = _calculateTransportCost(location, size);
                      });
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Project Size (e.g. 1000 sqm)'),
                    onChanged: (v) {
                      setModalState(() {
                        size = v;
                        transportCost = _calculateTransportCost(location, size);
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(pickedDate == null
                            ? 'No date picked'
                            : 'Picked Date: ${pickedDate.toLocal().toString().split(' ')[0]}'),
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
                              return !project.bookedDates.any((b) => b.date.year == date.year && b.date.month == date.month && b.date.day == date.day);
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
                  if (project.transportCost != null)
                    Row(
                      children: [
                        const Text('Transport Cost: ', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('${project.transportCost}'),
                      ],
                    ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: location.isNotEmpty && size.isNotEmpty && pickedDate != null
                        ? () {
                            setModalState(() {
                              bookedDates.add({
                                'project': project.title,
                                'date': pickedDate!,
                                'client': 'Client',
                                'location': location,
                                'size': size,
                                'transportCost': transportCost,
                              });
                            });
                            Get.snackbar('Date Booked', 'Project date booked successfully!', backgroundColor: Colors.green, colorText: Colors.white);
                          }
                        : null,
                    child: const Text('Book Date'),
                  ),
                           ],
                         ),
                       ),
                     ),
                   ),
                   const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      ),
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
                const Text('Booked Project Dates', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 10),
                if (bookings.isEmpty)
                  const Text('No booked dates.'),
                if (bookings.isNotEmpty)
                  ...bookings.map((booking) => Card(
                    child: ListTile(
                      title: Text('Date: ${booking.date.toLocal().toString().split(' ')[0]}'),
                      subtitle: Text('Client: ${booking.clientName}\nLocation: ${booking.location}'),
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
            Text('Your booking for ${booking.date.toLocal().toString().split(' ')[0]} at ${booking.location} has been removed by admin. Please contact support or book a new date.'),
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
              final takenDates = project.bookedDates.map((b) => DateTime(b.date.year, b.date.month, b.date.day)).toSet();
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
                    Text('Book Project: ${project.title}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: const InputDecoration(labelText: 'Project Location'),
                      onChanged: (v) {
                        setModalState(() {
                          location = v;
                          transportCost = _calculateTransportCost(location, size);
                        });
                      },
                    ),
                    TextField(
                      decoration: const InputDecoration(labelText: 'Project Size (e.g. 1000 sqm)'),
                      onChanged: (v) {
                        setModalState(() {
                          size = v;
                          transportCost = _calculateTransportCost(location, size);
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(pickedDate == null
                              ? 'No date picked'
                              : 'Picked Date: ${pickedDate!.toLocal().toString().split(' ')[0]}'),
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
                                return !takenDates.contains(DateTime(date.year, date.month, date.day));
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
                    if (location.isNotEmpty && size.isNotEmpty && pickedDate != null)
                      Row(
                        children: [
                          const Text('Transport Cost: ', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(transportCost != null ? ' ${transportCost!.toStringAsFixed(2)}' : '--'),
                        ],
                      ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: location.isNotEmpty && size.isNotEmpty && pickedDate != null && !isLoading
                          ? () async {
                              setModalState(() => isLoading = true);
                              try {
                                // Add new booked date to Firestore
                                final newBooking = BookedDate(
                                  date: pickedDate!,
                                  clientId: userController.userId.value,
                                  status: 'booked',
                                );
                                final updatedDates = List<BookedDate>.from(project.bookedDates)..add(newBooking);
                                await FirebaseService.instance.updateProject(project.id, {
                                  'bookedDates': updatedDates.map((e) => e.toMap()).toList(),
                              });
                              Navigator.pop(context);
                                Get.snackbar('Booked', 'Project date booked successfully!', backgroundColor: Colors.green, colorText: Colors.white);
                              } catch (e) {
                                Get.snackbar('Error', 'Failed to book date: $e', backgroundColor: Colors.red, colorText: Colors.white);
                              } finally {
                                setModalState(() => isLoading = false);
                              }
                            }
                          : null,
                      child: isLoading ? const CircularProgressIndicator() : const Text('Book Date'),
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
    final emailController = TextEditingController(text: userProfile?.email ?? '');
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
                          project.location.trim().toLowerCase() == location.trim().toLowerCase()) {
                        matchedTransportCost = project.transportCost;
                        break;
                      }
                    }
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
                          const Text('Request a Project', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 18),
                          const Text('Contact Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const Divider(height: 24),
                          TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                              labelText: 'Your Name',
                              prefixIcon: const Icon(Iconsax.user),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: emailController,
                            decoration: InputDecoration(
                              labelText: 'Your Email',
                              prefixIcon: const Icon(Iconsax.sms),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: phoneController,
                            decoration: InputDecoration(
                              labelText: 'Phone Number',
                              prefixIcon: const Icon(Iconsax.call),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 24),
                          const Text('Project Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const Divider(height: 24),
                          DropdownButtonFormField<String>(
                            value: selectedCategory,
                            items: categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                            onChanged: (v) => setModalState(() => selectedCategory = v),
                            decoration: InputDecoration(
                              labelText: 'Category',
                              prefixIcon: const Icon(Iconsax.category),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'Desired Project Location',
                              prefixIcon: const Icon(Iconsax.location),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onChanged: (v) {
                              setModalState(() {
                                location = v;
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'Desired Project Size (e.g. 1000 sqm)',
                              prefixIcon: const Icon(Iconsax.size),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onChanged: (v) => size = v,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Iconsax.calendar, size: 18, color: Colors.grey),
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
                                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey[300]!),
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.white,
                                    ),
                                    child: Text(
                                      expectedStartDate != null
                                          ? 'Expected Start Date: 24{expectedStartDate!.toLocal().toString().split(' ')[0]}'
                                          : 'Pick Expected Start Date',
                                      style: TextStyle(
                                        color: expectedStartDate != null ? Colors.black : Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Text('Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const Divider(height: 24),
                          Card(
                            color: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Name: ${nameController.text}'),
                                  Text('Email: ${emailController.text}'),
                                  if (phoneController.text.isNotEmpty) Text('Phone: ${phoneController.text}'),
                                  Text('Category: $selectedCategory'),
                                  Text('Location: $location'),
                                  Text('Size: $size'),
                                  if (matchedTransportCost != null)
                                    Text('Estimated Transport Cost: $matchedTransportCost'),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: isLoading || nameController.text.isEmpty || emailController.text.isEmpty || location.isEmpty || size.isEmpty || selectedCategory == null
                                  ? null
                                  : () async {
                                      setModalState(() => isLoading = true);
                                      try {
                                        await FirebaseFirestore.instance.collection('projectRequests').add({
                                          'name': nameController.text.trim(),
                                          'email': emailController.text.trim(),
                                          'phone': phoneController.text.trim(),
                                          'location': location.trim(),
                                          'size': size.trim(),
                                          'category': selectedCategory,
                                          'expectedStartDate': expectedStartDate != null ? Timestamp.fromDate(expectedStartDate!) : null,
                                          'createdAt': FieldValue.serverTimestamp(),
                                          'reviewed': false,
                                        });
                                        Navigator.pop(context);
                                        Get.snackbar('Requested', 'Project request submitted!', backgroundColor: Colors.green, colorText: Colors.white);
                                      } catch (e) {
                                        Get.snackbar('Error', 'Failed to submit request: $e', backgroundColor: Colors.red, colorText: Colors.white);
                                      } finally {
                                        setModalState(() => isLoading = false);
                                      }
                                    },
                              child: isLoading ? const CircularProgressIndicator() : const Text('Submit Request'),
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
}