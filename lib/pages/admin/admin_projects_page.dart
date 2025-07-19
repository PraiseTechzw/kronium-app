import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kronium/core/app_theme.dart';
import 'package:kronium/core/routes.dart';
import 'package:kronium/core/user_auth_service.dart';
import 'dart:math';

class AdminProjectsPage extends StatefulWidget {
  const AdminProjectsPage({super.key});

  @override
  State<AdminProjectsPage> createState() => _AdminProjectsPageState();
}

class _AdminProjectsPageState extends State<AdminProjectsPage> {
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
      'progress': 100,
      'approved': true,
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
      'approved': false,
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
      'progress': 100,
      'approved': true,
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
      'approved': false,
    },
  ];

  final List<Map<String, dynamic>> bookedDates = [];
  Map<String, dynamic>? _selectedProject;

  void _addOrEditProject({Map<String, dynamic>? project, int? index}) {
    final titleController = TextEditingController(text: project?['title'] ?? '');
    final locationController = TextEditingController(text: project?['location'] ?? '');
    final descController = TextEditingController(text: project?['description'] ?? '');
    final clientController = TextEditingController(text: project?['client'] ?? '');
    final imageController = TextEditingController(text: project?['image'] ?? '');
    final dateController = TextEditingController(text: project?['date'] ?? '');
    List<String> features = List<String>.from(project?['features'] ?? []);
    String featureInput = '';
    double progress = project?['progress']?.toDouble() ?? 0;
    bool approved = project?['approved'] ?? false;
    bool active = project?['active'] ?? true;
    DateTime? selectedDate;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: Text(project == null ? 'Add Project' : 'Edit Project'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title', prefixIcon: Icon(Iconsax.document_text))),
                    TextField(controller: locationController, decoration: const InputDecoration(labelText: 'Location', prefixIcon: Icon(Iconsax.location))),
                    TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description', prefixIcon: Icon(Iconsax.info_circle)), maxLines: 2),
                    TextField(controller: clientController, decoration: const InputDecoration(labelText: 'Client', prefixIcon: Icon(Iconsax.user))),
                    TextField(controller: imageController, decoration: const InputDecoration(labelText: 'Image URL', prefixIcon: Icon(Iconsax.image))),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text('Date:'),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: dateController,
                            readOnly: true,
                            decoration: const InputDecoration(hintText: 'Pick date'),
                            onTap: () async {
                              DateTime now = DateTime.now();
                              DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate ?? now,
                                firstDate: DateTime(now.year - 2),
                                lastDate: DateTime(now.year + 5),
                              );
                              if (picked != null) {
                                setModalState(() {
                                  selectedDate = picked;
                                  dateController.text = picked.toLocal().toString().split(' ')[0];
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Features chips
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(labelText: 'Add Feature', prefixIcon: Icon(Iconsax.add)),
                            onChanged: (v) => featureInput = v,
                            onSubmitted: (v) {
                              if (v.trim().isNotEmpty) {
                                setModalState(() {
                                  features.add(v.trim());
                                });
                              }
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Iconsax.add_circle, color: Colors.green),
                          onPressed: () {
                            if (featureInput.trim().isNotEmpty) {
                              setModalState(() {
                                features.add(featureInput.trim());
                                featureInput = '';
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    if (features.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        children: features.map((f) => Chip(
                          label: Text(f),
                          onDeleted: () => setModalState(() => features.remove(f)),
                        )).toList(),
                      ),
                    const SizedBox(height: 10),
                    if (imageController.text.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(imageController.text, height: 80, width: 120, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.broken_image)),
                      ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text('Progress:'),
                        Expanded(
                          child: Slider(
                            value: progress,
                            min: 0,
                            max: 100,
                            divisions: 100,
                            label: '${progress.round()}%',
                            onChanged: (v) => setModalState(() => progress = v),
                          ),
                        ),
                        Text('${progress.round()}%'),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: approved,
                          onChanged: (v) => setModalState(() => approved = v ?? false),
                        ),
                        const Text('Approved'),
                        const SizedBox(width: 16),
                        Checkbox(
                          value: active,
                          onChanged: (v) => setModalState(() => active = v ?? true),
                        ),
                        const Text('Active'),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    final newProject = {
                      'title': titleController.text,
                      'location': locationController.text,
                      'description': descController.text,
                      'client': clientController.text,
                      'image': imageController.text,
                      'progress': progress,
                      'approved': approved,
                      'active': active,
                      'category': project?['category'] ?? 'Ongoing',
                      'features': features,
                      'date': dateController.text,
                    };
                    setState(() {
                      if (index != null) {
                        projects[index] = newProject;
                      } else {
                        projects.add(newProject);
                      }
                    });
                    Get.back();
                  },
                  child: Text(project == null ? 'Add' : 'Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text('Admin Projects', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.add),
            tooltip: 'Add Project',
            onPressed: () => _addOrEditProject(),
          ),
        ],
      ),
      body: Padding(
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
            final project = projects[index];
            if (project['title'] == null || project['image'] == null || project['location'] == null || project['description'] == null) {
              return Container(
                color: Colors.red[900],
                child: const Center(
                  child: Text(
                    'Project data error',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              );
            }
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedProject = project;
                });
                _showProjectDetails(project, index);
              },
              child: _buildProjectCardContent(project),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProjectCardContent(Map<String, dynamic> project) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
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
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project['title'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Iconsax.location, size: 12, color: Colors.grey),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        project['location'] ?? '',
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  project['description'] ?? '',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
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
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ],
                if (project['approved'] == true)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text('Approved', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 10)),
                  ),
                if (project['approved'] == false)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text('Pending Approval', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 10)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showProjectDetails(Map<String, dynamic> project, int index) {
    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setModalState) {
          String location = '';
          String size = '';
          double? transportCost;
          DateTime? pickedDate;
          double progress = project['progress']?.toDouble() ?? 0;
          bool approved = project['approved'] ?? false;
          return Container(
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
                    child: Image.network(
                      project['image'],
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
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
                  const Text('Booked Dates', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 10),
                  if (bookedDates.where((b) => b['project'] == project['title']).isEmpty)
                    const Text('No booked dates.'),
                  if (bookedDates.where((b) => b['project'] == project['title']).isNotEmpty)
                    ...bookedDates.where((b) => b['project'] == project['title']).map((booking) => Card(
                      child: ListTile(
                        title: Text('Date: ${booking['date'].toLocal().toString().split(' ')[0]}'),
                        subtitle: Text('Client: ${booking['client']}\nLocation: ${booking['location']}'),
                        trailing: IconButton(
                          icon: const Icon(Iconsax.trash, color: Colors.red),
                          tooltip: 'Remove Date',
                          onPressed: () {
                            setModalState(() {
                              bookedDates.remove(booking);
                            });
                            Get.snackbar('Booking Removed', 'The booked date has been removed.', backgroundColor: Colors.red, colorText: Colors.white);
                          },
                        ),
                      ),
                    )),
                  const SizedBox(height: 20),
                  const Divider(),
                  const Text('Book a Date for Project', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
                              return !bookedDates.any((b) => b['project'] == project['title'] && b['date'].year == date.year && b['date'].month == date.month && b['date'].day == date.day);
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
                        Text(transportCost != null ? ' 24${transportCost!.toStringAsFixed(2)}' : '--'),
                      ],
                    ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: location.isNotEmpty && size.isNotEmpty && pickedDate != null
                        ? () {
                            setModalState(() {
                              bookedDates.add({
                                'project': project['title'],
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
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          switch (value) {
                            case 'edit':
                              _addOrEditProject(project: project, index: index);
                              break;
                            case 'approve':
                              setModalState(() {
                                projects[index]['approved'] = true;
                              });
                              Get.snackbar('Approved', 'Project approved!', backgroundColor: Colors.green, colorText: Colors.white);
                              break;
                            case 'progress':
                              showDialog(
                                context: context,
                                builder: (context) {
                                  double tempProgress = progress;
                                  return AlertDialog(
                                    title: const Text('Update Progress'),
                                    content: Slider(
                                      value: tempProgress,
                                      min: 0,
                                      max: 100,
                                      divisions: 100,
                                      label: '${tempProgress.round()}%',
                                      onChanged: (v) {
                                        setModalState(() => tempProgress = v);
                                      },
                                    ),
                                    actions: [
                                      TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
                                      ElevatedButton(
                                        onPressed: () {
                                          setModalState(() {
                                            projects[index]['progress'] = tempProgress;
                                          });
                                          Get.back();
                                        },
                                        child: const Text('Update'),
                                      ),
                                    ],
                                  );
                                },
                              );
                              break;
                            case 'delete':
                              setModalState(() {
                                projects.removeAt(index);
                              });
                              Get.back();
                              Get.snackbar('Deleted', 'Project deleted!', backgroundColor: Colors.red, colorText: Colors.white);
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'edit', child: Text('Edit')),
                          const PopupMenuItem(value: 'approve', child: Text('Approve')),
                          const PopupMenuItem(value: 'progress', child: Text('Update Progress')),
                          const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                        ],
                      ),
                    ],
                  ),
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

  Widget _projectDetailItem(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
} 