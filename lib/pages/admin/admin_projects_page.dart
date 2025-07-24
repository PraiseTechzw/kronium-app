import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kronium/core/app_theme.dart';
import 'package:kronium/core/routes.dart';
import 'package:kronium/core/user_auth_service.dart';
import 'dart:math';
import 'package:kronium/core/firebase_service.dart';
import 'package:kronium/models/project_model.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';
import 'package:kronium/pages/admin/admin_project_requests_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminProjectsPage extends StatefulWidget {
  const AdminProjectsPage({super.key});

  @override
  State<AdminProjectsPage> createState() => _AdminProjectsPageState();
}

class _AdminProjectsPageState extends State<AdminProjectsPage> {
  final List<Map<String, dynamic>> bookedDates = [];
  Project? _selectedProject;
  final List<String> categories = [
    'Greenhouses',
    'Steel Structures',
    'Solar Systems',
    'Construction',
    'Logistics',
    'IoT & Automation',
  ];
  bool _hasHandledRequestArgs = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // If navigated with requestData, open the add project modal pre-filled
    final args = Get.arguments;
    if (!_hasHandledRequestArgs && args != null && args['requestData'] != null) {
      _hasHandledRequestArgs = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _addOrEditProject(
          initialData: args['requestData'],
          requestId: args['requestId'],
        );
      });
    }
  }

  void _addOrEditProject({Project? project, Map<String, dynamic>? initialData, String? requestId}) {
    final titleController = TextEditingController(text: project?.title ?? initialData?['title'] ?? '');
    final locationController = TextEditingController(text: project?.location ?? initialData?['location'] ?? '');
    final descController = TextEditingController(text: project?.description ?? initialData?['description'] ?? '');
    final sizeController = TextEditingController(text: project?.size ?? initialData?['size'] ?? '');
    List<String> features = List<String>.from(project?.features ?? initialData?['features'] ?? []);
    String featureInput = '';
    List<String> mediaUrls = List<String>.from(project?.mediaUrls ?? initialData?['mediaUrls'] ?? []);
    String mediaInput = '';
    DateTime? selectedDate = project?.date;
    bool isUploading = false;
    String? selectedCategory = project?.category ?? initialData?['category'] ?? categories.first;
    TextEditingController transportCostController = TextEditingController(text: project?.transportCost?.toString() ?? initialData?['transportCost']?.toString() ?? '');
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
                      project == null ? 'Add Project' : 'Edit Project',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Title', prefixIcon: Icon(Iconsax.document_text)),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(labelText: 'Location', prefixIcon: Icon(Iconsax.location)),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: sizeController,
                      decoration: const InputDecoration(labelText: 'Size (e.g. 1000 sqm)', prefixIcon: Icon(Iconsax.size)),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: descController,
                      decoration: const InputDecoration(labelText: 'Description', prefixIcon: Icon(Iconsax.info_circle)),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    // Date Picker
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
                                initialDate: selectedDate ?? now,
                                firstDate: DateTime(now.year - 2),
                                lastDate: DateTime(now.year + 5),
                              );
                              if (picked != null) {
                                setModalState(() {
                                  selectedDate = picked;
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                selectedDate != null
                                    ? 'Date: ${selectedDate!.toLocal().toString().split(' ')[0]}'
                                    : 'Pick Project Date',
                                style: TextStyle(
                                  color: selectedDate != null ? Colors.black : Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Features', style: TextStyle(fontWeight: FontWeight.bold)),
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
                    const SizedBox(height: 16),
                    // Media Picker
                    Row(
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Iconsax.image, color: Colors.white),
                          label: const Text('Add Image', style: TextStyle(color: Colors.white)),
                          onPressed: isUploading ? null : () async {
                            setModalState(() => isUploading = true);
                            FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
                            if (result != null && result.files.single.path != null) {
                              File file = File(result.files.single.path!);
                              try {
                                String url = await FirebaseService.instance.uploadImage(file, file.path);
                                setModalState(() {
                                  mediaUrls.add(url);
                                });
                              } catch (e) {
                                Get.snackbar('Error', 'Failed to upload image: $e', backgroundColor: Colors.red, colorText: Colors.white);
                              }
                            }
                            setModalState(() => isUploading = false);
                          },
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          icon: const Icon(Iconsax.video, color: Colors.white),
                          label: const Text('Add Video', style: TextStyle(color: Colors.white)),
                          onPressed: isUploading ? null : () async {
                            setModalState(() => isUploading = true);
                            FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.video);
                            if (result != null && result.files.single.path != null) {
                              File file = File(result.files.single.path!);
                              try {
                                String url = await FirebaseService.instance.uploadVideo(file, file.path);
                                setModalState(() {
                                  mediaUrls.add(url);
                                });
                              } catch (e) {
                                Get.snackbar('Error', 'Failed to upload video: $e', backgroundColor: Colors.red, colorText: Colors.white);
                              }
                            }
                            setModalState(() => isUploading = false);
                          },
                        ),
                      ],
                    ),
                    if (mediaUrls.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Text('Media Preview', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: mediaUrls.map((url) {
                              final isVideo = url.endsWith('.mp4') || url.contains('video');
                              return Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.grey[300]!),
                                      color: Colors.black12,
                                    ),
                                    child: isVideo
                                        ? _VideoPreviewWidget(url: url)
                                        : ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: Image.network(
                                              url,
                                              fit: BoxFit.cover,
                                              width: 100,
                                              height: 100,
                                              errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 40),
                                            ),
                                          ),
                                  ),
                                  Positioned(
                                    top: 2,
                                    right: 2,
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(20),
                                        onTap: () => setModalState(() => mediaUrls.remove(url)),
                                        child: const Padding(
                                          padding: EdgeInsets.all(2),
                                          child: Icon(Iconsax.close_circle, color: Colors.red, size: 24),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      items: categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                      onChanged: (v) => setModalState(() => selectedCategory = v),
                      decoration: const InputDecoration(labelText: 'Category', prefixIcon: Icon(Iconsax.category)),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            // Validation
                            if (titleController.text.trim().isEmpty || locationController.text.trim().isEmpty || descController.text.trim().isEmpty || selectedDate == null || mediaUrls.isEmpty) {
                              Get.snackbar('Error', 'Title, Location, Description, Date, and at least one image/video are required', backgroundColor: Colors.red, colorText: Colors.white);
                              return;
                            }
                            final newProject = Project(
                              id: project?.id ?? '',
                              title: titleController.text.trim(),
                              description: descController.text.trim(),
                              location: locationController.text.trim(),
                              size: sizeController.text.trim(),
                              mediaUrls: mediaUrls,
                              features: features,
                              approved: project?.approved ?? false,
                              progress: project?.progress ?? 0.0,
                              date: selectedDate,
                              bookedDates: project?.bookedDates ?? [],
                              category: selectedCategory,
                              transportCost: double.tryParse(transportCostController.text) ?? 0.0,
                            );
                            try {
                              if (project == null) {
                                await FirebaseService.instance.addProject(newProject);
                                if (requestId != null) {
                                  // Mark the request as reviewed after project creation
                                  await FirebaseFirestore.instance.collection('projectRequests').doc(requestId).update({'reviewed': true});
                                }
                                Get.back();
                                Get.snackbar('Success', 'Project added!', backgroundColor: Colors.green, colorText: Colors.white);
                              } else {
                                await FirebaseService.instance.updateProject(project.id, newProject.toMap());
                                Get.back();
                                Get.snackbar('Success', 'Project updated!', backgroundColor: Colors.green, colorText: Colors.white);
                              }
                            } catch (e) {
                              Get.snackbar('Error', 'Failed to save project: $e', backgroundColor: Colors.red, colorText: Colors.white);
                            }
                          },
                          child: Text(project == null ? 'Add Project' : 'Update Project'),
                        ),
                        const SizedBox(width: 10),
                        if (project != null)
                          OutlinedButton(
                            onPressed: () async {
                              try {
                                await FirebaseService.instance.deleteProject(project.id);
                                Get.back();
                                Get.snackbar('Deleted', 'Project deleted!', backgroundColor: Colors.red, colorText: Colors.white);
                              } catch (e) {
                                Get.snackbar('Error', 'Failed to delete project: $e', backgroundColor: Colors.red, colorText: Colors.white);
                              }
                            },
                            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                            child: const Text('Delete'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Projects'),
      ),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Iconsax.message_question),
          label: const Text('View Project Requests'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () => Get.to(() => const AdminProjectRequestsPage()),
        ),
      ),
    );
  }

  Widget _buildProjectCardContent(Project project) {
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
                  project.mediaUrls.isNotEmpty ? project.mediaUrls.first : '',
                  fit: BoxFit.cover,
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
                  project.title,
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
                        project.location,
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  project.description,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  ),
                if (project.category != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Chip(
                      label: Text(project.category!),
                      backgroundColor: Colors.green[50],
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                if (project.transportCost != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('Transport Cost: ${project.transportCost}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showProjectDetails(Project project) {
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
                  Row(
                    children: [
                        Expanded(
                          child: Text(
                            project.title,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                        IconButton(
                          icon: const Icon(Iconsax.edit),
                          tooltip: 'Edit Project',
                          onPressed: () {
                            Navigator.pop(context);
                            _addOrEditProject(project: project);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Iconsax.trash, color: Colors.red),
                          tooltip: 'Delete Project',
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Project'),
                                content: const Text('Are you sure you want to delete this project?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                  ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Delete')),
                        ],
                      ),
                            );
                            if (confirm == true) {
                              await FirebaseService.instance.deleteProject(project.id);
                              Navigator.pop(context);
                              Get.snackbar('Deleted', 'Project deleted!', backgroundColor: Colors.red, colorText: Colors.white);
                            }
                          },
                      ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (project.mediaUrls.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          project.mediaUrls.isNotEmpty ? project.mediaUrls.first : '',
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 60),
                        ),
                      ),
                    const SizedBox(height: 16),
                  Row(
                    children: [
                        const Icon(Iconsax.location, size: 16, color: Colors.grey),
                        const SizedBox(width: 5),
                        Text(project.location, style: const TextStyle(fontSize: 15, color: Colors.grey)),
                        const Spacer(),
                        const Icon(Iconsax.size, size: 16, color: Colors.grey),
                        const SizedBox(width: 5),
                        Text(project.size, style: const TextStyle(fontSize: 15, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(project.description, style: const TextStyle(fontSize: 15)),
                    const SizedBox(height: 16),
                    if (project.features.isNotEmpty) ...[
                      const Text('Features', style: TextStyle(fontWeight: FontWeight.bold)),
                      Wrap(
                        spacing: 8,
                        children: project.features.map((f) => Chip(label: Text(f))).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Row(
                      children: [
                        const Text('Approved', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 10),
                        Switch(
                          value: project.approved,
                          onChanged: (v) async {
                            await FirebaseService.instance.updateProject(project.id, {'approved': v});
                            setModalState(() {});
                            Get.snackbar('Updated', v ? 'Project approved' : 'Approval removed', backgroundColor: Colors.green, colorText: Colors.white);
                          },
                        ),
                        const Spacer(),
                        const Text('Progress', style: TextStyle(fontWeight: FontWeight.bold)),
                        Expanded(
                          child: Slider(
                            value: project.progress,
                            min: 0,
                            max: 100,
                            divisions: 100,
                            label: '${project.progress.round()}%',
                            onChanged: (v) async {
                              await FirebaseService.instance.updateProject(project.id, {'progress': v});
                              setModalState(() {});
                            },
                          ),
                        ),
                        Text('${project.progress.round()}%'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Booked Dates', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    if (project.bookedDates.isEmpty)
                      const Text('No booked dates.'),
                    if (project.bookedDates.isNotEmpty)
                      ...project.bookedDates.map((booking) => Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: const Icon(Iconsax.calendar, color: AppTheme.primaryColor),
                          title: Text('Date: ${booking.date.toLocal().toString().split(' ')[0]}'),
                          subtitle: Text('Client ID: ${booking.clientId}\nStatus: ${booking.status}'),
                          trailing: IconButton(
                            icon: const Icon(Iconsax.trash, color: Colors.red),
                            tooltip: 'Remove Date',
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Remove Booked Date'),
                                  content: const Text('Are you sure you want to remove this booked date?'),
                                    actions: [
                                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                    ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Remove')),
                                    ],
                                ),
                              );
                              if (confirm == true) {
                                final updatedDates = List<BookedDate>.from(project.bookedDates)..remove(booking);
                                await FirebaseService.instance.updateProject(project.id, {
                                  'bookedDates': updatedDates.map((e) => e.toMap()).toList(),
                                });
                                setModalState(() {});
                                Get.snackbar('Removed', 'Booked date removed.', backgroundColor: Colors.red, colorText: Colors.white);
                          }
                        },
                          ),
                        ),
                      )),
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
}

class _VideoPreviewWidget extends StatefulWidget {
  final String url;
  const _VideoPreviewWidget({required this.url});
  @override
  State<_VideoPreviewWidget> createState() => _VideoPreviewWidgetState();
}

class _VideoPreviewWidgetState extends State<_VideoPreviewWidget> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        setState(() => _initialized = true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _initialized
        ? GestureDetector(
            onTap: () {
              if (_controller.value.isPlaying) {
                _controller.pause();
              } else {
                _controller.play();
              }
              setState(() {});
            },
            child: Stack(
              alignment: Alignment.center,
      children: [
                AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
                if (!_controller.value.isPlaying)
                  const Icon(Iconsax.play, size: 40, color: Colors.white),
              ],
            ),
          )
        : const Center(child: CircularProgressIndicator());
  }
} 