import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kronium/core/app_theme.dart';
import 'package:kronium/core/firebase_service.dart';
import 'package:kronium/models/project_model.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class AdminProjectManagementPage extends StatefulWidget {
  const AdminProjectManagementPage({super.key});

  @override
  State<AdminProjectManagementPage> createState() =>
      _AdminProjectManagementPageState();
}

class _AdminProjectManagementPageState extends State<AdminProjectManagementPage>
    with TickerProviderStateMixin {
  final FirebaseService _firebaseService = Get.find<FirebaseService>();
  late TabController _tabController;
  String _selectedStatus = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        title: const Text('Project Management'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'All Projects', icon: Icon(Iconsax.folder)),
            Tab(text: 'Planning', icon: Icon(Iconsax.calendar_1)),
            Tab(text: 'In Progress', icon: Icon(Iconsax.clock)),
            Tab(text: 'Completed', icon: Icon(Iconsax.tick_circle)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _showAddProjectDialog,
            icon: const Icon(Iconsax.add),
            tooltip: 'Add New Project',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search projects...',
                      prefixIcon: const Icon(Iconsax.search_normal),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _selectedStatus,
                  items: const [
                    DropdownMenuItem(value: 'All', child: Text('All Status')),
                    DropdownMenuItem(
                      value: 'planning',
                      child: Text('Planning'),
                    ),
                    DropdownMenuItem(
                      value: 'inProgress',
                      child: Text('In Progress'),
                    ),
                    DropdownMenuItem(value: 'onHold', child: Text('On Hold')),
                    DropdownMenuItem(
                      value: 'completed',
                      child: Text('Completed'),
                    ),
                    DropdownMenuItem(
                      value: 'cancelled',
                      child: Text('Cancelled'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          // Projects List
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProjectsList(),
                _buildProjectsList(status: ProjectStatus.planning),
                _buildProjectsList(status: ProjectStatus.inProgress),
                _buildProjectsList(status: ProjectStatus.completed),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsList({ProjectStatus? status}) {
    return StreamBuilder<List<Project>>(
      stream: _firebaseService.getProjects(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.warning_2, size: 64, color: Colors.red[400]),
                const SizedBox(height: 16),
                Text('Error loading projects: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final projects = snapshot.data ?? [];
        var filteredProjects = projects;

        // Filter by status if specified
        if (status != null) {
          filteredProjects = projects.where((p) => p.status == status).toList();
        }

        // Filter by search query
        if (_searchQuery.isNotEmpty) {
          filteredProjects =
              filteredProjects.where((project) {
                return project.title.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    project.description.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    (project.clientName?.toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        ) ??
                        false);
              }).toList();
        }

        if (filteredProjects.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  status == null ? Iconsax.folder_open : _getStatusIcon(status),
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  status == null
                      ? 'No projects found'
                      : 'No ${status.name} projects',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add your first project to get started',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredProjects.length,
          itemBuilder: (context, index) {
            final project = filteredProjects[index];
            return _buildProjectCard(project);
          },
        );
      },
    );
  }

  Widget _buildProjectCard(Project project) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showProjectDetails(project),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      project.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusChip(project.status),
                ],
              ),
              const SizedBox(height: 8),
              if (project.clientName != null) ...[
                Text(
                  'Client: ${project.clientName}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
              ],
              Text(
                project.description,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Iconsax.location, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      project.location,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ),
                  Icon(Iconsax.calendar, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    project.date != null
                        ? '${project.date!.day}/${project.date!.month}/${project.date!.year}'
                        : 'No date',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Progress',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: project.progress / 100,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getProgressColor(project.progress),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${project.progress.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => _showProjectDetails(project),
                        icon: const Icon(Iconsax.eye),
                        tooltip: 'View Details',
                      ),
                      IconButton(
                        onPressed: () => _showEditProjectDialog(project),
                        icon: const Icon(Iconsax.edit),
                        tooltip: 'Edit Project',
                      ),
                      IconButton(
                        onPressed: () => _showProgressUpdateDialog(project),
                        icon: const Icon(Iconsax.chart),
                        tooltip: 'Update Progress',
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(ProjectStatus status) {
    Color color;
    switch (status) {
      case ProjectStatus.planning:
        color = Colors.blue;
        break;
      case ProjectStatus.inProgress:
        color = Colors.orange;
        break;
      case ProjectStatus.onHold:
        color = Colors.red;
        break;
      case ProjectStatus.completed:
        color = Colors.green;
        break;
      case ProjectStatus.cancelled:
        color = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress < 30) return Colors.red;
    if (progress < 70) return Colors.orange;
    return Colors.green;
  }

  IconData _getStatusIcon(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.planning:
        return Iconsax.calendar_1;
      case ProjectStatus.inProgress:
        return Iconsax.clock;
      case ProjectStatus.onHold:
        return Iconsax.pause;
      case ProjectStatus.completed:
        return Iconsax.tick_circle;
      case ProjectStatus.cancelled:
        return Iconsax.close_circle;
    }
  }

  void _showAddProjectDialog() {
    _showProjectFormBottomSheet();
  }

  void _showEditProjectDialog(Project project) {
    _showProjectFormBottomSheet(project: project);
  }

  void _showProjectFormBottomSheet({Project? project}) {
    final titleController = TextEditingController(text: project?.title ?? '');
    final descriptionController = TextEditingController(
      text: project?.description ?? '',
    );
    final locationController = TextEditingController(
      text: project?.location ?? '',
    );
    final sizeController = TextEditingController(text: project?.size ?? '');
    final clientNameController = TextEditingController(
      text: project?.clientName ?? '',
    );
    final clientEmailController = TextEditingController(
      text: project?.clientEmail ?? '',
    );
    final clientPhoneController = TextEditingController(
      text: project?.clientPhone ?? '',
    );
    final transportCostController = TextEditingController(
      text: project?.transportCost?.toString() ?? '',
    );

    String selectedCategory = project?.category ?? 'Greenhouses';
    ProjectStatus selectedStatus = project?.status ?? ProjectStatus.planning;
    DateTime? selectedDate = project?.date;
    List<String> features = List.from(project?.features ?? []);
    List<ProjectMedia> projectMedia = List.from(project?.projectMedia ?? []);
    bool isUploading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => DraggableScrollableSheet(
          initialChildSize: 0.95,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          project == null ? Iconsax.add_circle : Iconsax.edit,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              project == null ? 'Add New Project' : 'Edit Project',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              project == null 
                                  ? 'Create a new project with all details'
                                  : 'Update project information',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                // Form Content
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Basic Information Section
                        _buildSectionHeader('Basic Information', Iconsax.info_circle),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: titleController,
                          label: 'Project Title',
                          hint: 'Enter project title',
                          icon: Iconsax.text,
                          isRequired: true,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: descriptionController,
                          label: 'Description',
                          hint: 'Describe the project details',
                          icon: Iconsax.document_text,
                          maxLines: 3,
                          isRequired: true,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: locationController,
                                label: 'Location',
                                hint: 'Project location',
                                icon: Iconsax.location,
                                isRequired: true,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField(
                                controller: sizeController,
                                label: 'Size',
                                hint: '10 acres, 500 sqm',
                                icon: Iconsax.ruler,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Project Details Section
                        _buildSectionHeader('Project Details', Iconsax.setting),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDropdownField<String>(
                                value: selectedCategory,
                                label: 'Category',
                                icon: Iconsax.category,
                                items: const [
                                  DropdownMenuItem(value: 'Greenhouses', child: Text('Greenhouses')),
                                  DropdownMenuItem(value: 'Steel Structures', child: Text('Steel Structures')),
                                  DropdownMenuItem(value: 'Solar Systems', child: Text('Solar Systems')),
                                  DropdownMenuItem(value: 'Construction', child: Text('Construction')),
                                  DropdownMenuItem(value: 'Logistics', child: Text('Logistics')),
                                  DropdownMenuItem(value: 'IoT & Automation', child: Text('IoT & Automation')),
                                ],
                                onChanged: (value) => setModalState(() => selectedCategory = value!),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildDropdownField<ProjectStatus>(
                                value: selectedStatus,
                                label: 'Status',
                                icon: Iconsax.flag,
                                items: ProjectStatus.values.map((status) {
                                  return DropdownMenuItem(
                                    value: status,
                                    child: Text(status.name.toUpperCase()),
                                  );
                                }).toList(),
                                onChanged: (value) => setModalState(() => selectedStatus = value!),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildDateField(
                          selectedDate: selectedDate,
                          onDateSelected: (date) => setModalState(() => selectedDate = date),
                        ),
                        const SizedBox(height: 24),
                        // Client Information Section
                        _buildSectionHeader('Client Information', Iconsax.user),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: clientNameController,
                          label: 'Client Name',
                          hint: 'Enter client name',
                          icon: Iconsax.user,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: clientEmailController,
                                label: 'Email',
                                hint: 'client@email.com',
                                icon: Iconsax.sms,
                                keyboardType: TextInputType.emailAddress,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField(
                                controller: clientPhoneController,
                                label: 'Phone',
                                hint: '+1234567890',
                                icon: Iconsax.call,
                                keyboardType: TextInputType.phone,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: transportCostController,
                          label: 'Transport Cost',
                          hint: '0.00',
                          icon: Iconsax.dollar_circle,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 24),
                        // Media Upload Section
                        _buildSectionHeader('Project Media', Iconsax.gallery),
                        const SizedBox(height: 16),
                        _buildMediaUploadSection(
                          projectMedia: projectMedia,
                          isUploading: isUploading,
                          onImageUpload: () => _pickAndUploadMedia(
                            ImageSource.gallery,
                            (media) => setModalState(() => projectMedia.add(media)),
                            () => setModalState(() => isUploading = true),
                            () => setModalState(() => isUploading = false),
                          ),
                          onVideoUpload: () => _pickAndUploadVideo(
                            (media) => setModalState(() => projectMedia.add(media)),
                            () => setModalState(() => isUploading = true),
                            () => setModalState(() => isUploading = false),
                          ),
                          onRemoveMedia: (media) => setModalState(() => projectMedia.remove(media)),
                        ),
                        const SizedBox(height: 100), // Space for bottom buttons
                      ],
                    ),
                  ),
                ),
                // Bottom Action Buttons
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Colors.grey[200]!),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: Colors.grey[300]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (titleController.text.trim().isEmpty ||
                                descriptionController.text.trim().isEmpty ||
                                locationController.text.trim().isEmpty) {
                              Get.snackbar(
                                'Error',
                                'Please fill in all required fields',
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                              return;
                            }

                            final newProject = Project(
                              id: project?.id ?? const Uuid().v4(),
                              title: titleController.text.trim(),
                              description: descriptionController.text.trim(),
                              location: locationController.text.trim(),
                              size: sizeController.text.trim(),
                              mediaUrls: projectMedia.map((m) => m.url).toList(),
                              projectMedia: projectMedia,
                              bookedDates: project?.bookedDates ?? [],
                              features: features,
                              approved: true,
                              progress: project?.progress ?? 0.0,
                              status: selectedStatus,
                              date: selectedDate,
                              category: selectedCategory,
                              transportCost: double.tryParse(transportCostController.text) ?? 0.0,
                              clientId: project?.clientId,
                              clientName: clientNameController.text.trim().isNotEmpty
                                  ? clientNameController.text.trim()
                                  : null,
                              clientEmail: clientEmailController.text.trim().isNotEmpty
                                  ? clientEmailController.text.trim()
                                  : null,
                              clientPhone: clientPhoneController.text.trim().isNotEmpty
                                  ? clientPhoneController.text.trim()
                                  : null,
                              updates: project?.updates ?? [],
                              startDate: project?.startDate,
                              endDate: project?.endDate,
                              createdAt: project?.createdAt ?? DateTime.now(),
                              updatedAt: DateTime.now(),
                            );

                            try {
                              if (project == null) {
                                await _firebaseService.addProject(newProject);
                                Get.snackbar(
                                  'Success',
                                  'Project added successfully!',
                                  backgroundColor: Colors.green,
                                  colorText: Colors.white,
                                );
                              } else {
                                await _firebaseService.updateProject(project.id, newProject.toMap());
                                Get.snackbar(
                                  'Success',
                                  'Project updated successfully!',
                                  backgroundColor: Colors.green,
                                  colorText: Colors.white,
                                );
                              }
                              Navigator.pop(context);
                            } catch (e) {
                              Get.snackbar(
                                'Error',
                                'Failed to save project: $e',
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(project == null ? Iconsax.add : Iconsax.edit),
                              const SizedBox(width: 8),
                              Text(project == null ? 'Add Project' : 'Update Project'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showProjectDetails(Project project) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder:
                (context, scrollController) => Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(24),
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
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                project.title,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            _buildStatusChip(project.status),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          project.description,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        _buildDetailRow(
                          'Location',
                          project.location,
                          Iconsax.location,
                        ),
                        _buildDetailRow('Size', project.size, Iconsax.ruler),
                        _buildDetailRow(
                          'Category',
                          project.category ?? 'N/A',
                          Iconsax.category,
                        ),
                        if (project.clientName != null)
                          _buildDetailRow(
                            'Client',
                            project.clientName!,
                            Iconsax.user,
                          ),
                        if (project.date != null)
                          _buildDetailRow(
                            'Date',
                            '${project.date!.day}/${project.date!.month}/${project.date!.year}',
                            Iconsax.calendar,
                          ),
                        _buildDetailRow(
                          'Progress',
                          '${project.progress.toStringAsFixed(0)}%',
                          Iconsax.chart,
                        ),
                        if (project.transportCost != null &&
                            project.transportCost! > 0)
                          _buildDetailRow(
                            'Transport Cost',
                            '\$${project.transportCost!.toStringAsFixed(2)}',
                            Iconsax.dollar_circle,
                          ),
                        const SizedBox(height: 20),
                        if (project.projectMedia.isNotEmpty) ...[
                          const Text(
                            'Project Media',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                ),
                            itemCount: project.projectMedia.length,
                            itemBuilder: (context, index) {
                              final media = project.projectMedia[index];
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child:
                                      media.type == 'image'
                                          ? Image.network(
                                            media.url,
                                            fit: BoxFit.cover,
                                            errorBuilder: (
                                              context,
                                              error,
                                              stackTrace,
                                            ) {
                                              return Container(
                                                color: Colors.grey[200],
                                                child: const Icon(
                                                  Iconsax.image,
                                                ),
                                              );
                                            },
                                          )
                                          : Container(
                                            color: Colors.grey[200],
                                            child: const Icon(Iconsax.video),
                                          ),
                                ),
                              );
                            },
                          ),
                        ],
                        const SizedBox(height: 20),
                        if (project.updates.isNotEmpty) ...[
                          const Text(
                            'Project Updates',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...project.updates.map(
                            (update) => Card(
                              child: ListTile(
                                title: Text(update.title),
                                subtitle: Text(update.description),
                                trailing: Text(
                                  '${update.progress.toStringAsFixed(0)}%',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
          ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showProgressUpdateDialog(Project project) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    double progress = project.progress;
    ProjectStatus status = project.status;
    List<String> mediaUrls = [];

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: const Text('Update Progress'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: titleController,
                          decoration: const InputDecoration(
                            labelText: 'Update Title',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        Text('Progress: ${progress.toStringAsFixed(0)}%'),
                        Slider(
                          value: progress,
                          min: 0,
                          max: 100,
                          divisions: 100,
                          onChanged:
                              (value) => setDialogState(() => progress = value),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<ProjectStatus>(
                          initialValue: status,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(),
                          ),
                          items:
                              ProjectStatus.values.map((s) {
                                return DropdownMenuItem(
                                  value: s,
                                  child: Text(s.name.toUpperCase()),
                                );
                              }).toList(),
                          onChanged:
                              (value) => setDialogState(() => status = value!),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (titleController.text.trim().isEmpty ||
                            descriptionController.text.trim().isEmpty) {
                          Get.snackbar('Error', 'Please fill in all fields');
                          return;
                        }

                        try {
                          // Update project progress and status
                          await _firebaseService.updateProjectProgress(
                            project.id,
                            progress,
                            status,
                          );

                          // Add project update
                          final update = ProjectUpdate(
                            id: const Uuid().v4(),
                            title: titleController.text.trim(),
                            description: descriptionController.text.trim(),
                            progress: progress,
                            mediaUrls: mediaUrls,
                            createdAt: DateTime.now(),
                            createdBy:
                                'admin', // You might want to get actual admin ID
                          );

                          await _firebaseService.addProjectUpdate(
                            project.id,
                            update,
                          );

                          Get.snackbar(
                            'Success',
                            'Progress updated successfully!',
                          );
                          Navigator.pop(context);
                        } catch (e) {
                          Get.snackbar(
                            'Error',
                            'Failed to update progress: $e',
                          );
                        }
                      },
                      child: const Text('Update'),
                    ),
                  ],
                ),
          ),
    );
  }

  Future<void> _pickAndUploadMedia(
    ImageSource source,
    Function(ProjectMedia) onSuccess,
    Function() onStart,
    Function() onEnd,
  ) async {
    try {
      onStart();
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final url = await _firebaseService.uploadImage(file, 'project_media');

        final media = ProjectMedia(
          id: const Uuid().v4(),
          url: url,
          type: 'image',
          uploadedAt: DateTime.now(),
          uploadedBy: 'admin', // You might want to get actual admin ID
        );

        onSuccess(media);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload image: $e');
    } finally {
      onEnd();
    }
  }

  Future<void> _pickAndUploadVideo(
    Function(ProjectMedia) onSuccess,
    Function() onStart,
    Function() onEnd,
  ) async {
    try {
      onStart();
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.first.path!);
        final url = await _firebaseService.uploadVideo(file, 'project_media');

        final media = ProjectMedia(
          id: const Uuid().v4(),
          url: url,
          type: 'video',
          uploadedAt: DateTime.now(),
          uploadedBy: 'admin', // You might want to get actual admin ID
        );

        onSuccess(media);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload video: $e');
    } finally {
      onEnd();
    }
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
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
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    bool isRequired = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              const Text(
                '*',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppTheme.primaryColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.primaryColor),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField<T>({
    required T value,
    required String label,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required Function(T?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          initialValue: value,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppTheme.primaryColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.primaryColor),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          items: items,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDateField({
    required DateTime? selectedDate,
    required Function(DateTime?) onDateSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Project Date',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final result = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (result != null) {
              onDateSelected(result);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[50],
            ),
            child: Row(
              children: [
                Icon(Iconsax.calendar, color: AppTheme.primaryColor),
                const SizedBox(width: 12),
                Text(
                  selectedDate != null
                      ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                      : 'Select Date',
                  style: TextStyle(
                    color: selectedDate != null ? Colors.black : Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Icon(Iconsax.arrow_down_2, color: Colors.grey[600]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMediaUploadSection({
    required List<ProjectMedia> projectMedia,
    required bool isUploading,
    required VoidCallback onImageUpload,
    required VoidCallback onVideoUpload,
    required Function(ProjectMedia) onRemoveMedia,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.gallery, color: AppTheme.primaryColor, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Project Media',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${projectMedia.length} files',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isUploading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text('Uploading...'),
                  ],
                ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onImageUpload,
                    icon: const Icon(Iconsax.image, size: 18),
                    label: const Text('Add Image'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[50],
                      foregroundColor: Colors.blue[700],
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onVideoUpload,
                    icon: const Icon(Iconsax.video, size: 18),
                    label: const Text('Add Video'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[50],
                      foregroundColor: Colors.red[700],
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          if (projectMedia.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: projectMedia.map((media) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: media.type == 'image' ? Colors.blue[50] : Colors.red[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: media.type == 'image' ? Colors.blue[200]! : Colors.red[200]!,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        media.type == 'image' ? Iconsax.image : Iconsax.video,
                        size: 16,
                        color: media.type == 'image' ? Colors.blue[700] : Colors.red[700],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        media.type.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: media.type == 'image' ? Colors.blue[700] : Colors.red[700],
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => onRemoveMedia(media),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
