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

class AdminProjectsPage extends StatefulWidget {
  const AdminProjectsPage({super.key});

  @override
  State<AdminProjectsPage> createState() => _AdminProjectsPageState();
}

class _AdminProjectsPageState extends State<AdminProjectsPage> {
  final List<Map<String, dynamic>> bookedDates = [];
  Project? _selectedProject;

  void _addOrEditProject({Project? project}) {
    final titleController = TextEditingController(text: project?.title ?? '');
    final locationController = TextEditingController(text: project?.location ?? '');
    final descController = TextEditingController(text: project?.description ?? '');
    final sizeController = TextEditingController(text: project?.size ?? '');
    List<String> features = List<String>.from(project?.features ?? []);
    String featureInput = '';
    List<String> mediaUrls = List<String>.from(project?.mediaUrls ?? []);
    String mediaInput = '';
    DateTime? selectedDate = project?.date;
    bool isUploading = false;
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
                          icon: const Icon(Iconsax.image),
                          label: const Text('Add Image'),
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
                          icon: const Icon(Iconsax.video),
                          label: const Text('Add Video'),
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
                      Wrap(
                        spacing: 8,
                        children: mediaUrls.map((url) => Stack(
                          alignment: Alignment.topRight,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 8, right: 8),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: url.endsWith('.mp4')
                                    ? Container(
                                        color: Colors.black12,
                                        width: 80,
                                        height: 80,
                                        child: const Icon(Iconsax.video, size: 40),
                                      )
                                    : Image.network(url, height: 80, width: 80, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.broken_image)),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Iconsax.close_circle, color: Colors.red, size: 20),
                              onPressed: () => setModalState(() => mediaUrls.remove(url)),
                            ),
                          ],
                        )).toList(),
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
                            );
                            try {
                              if (project == null) {
                                await FirebaseService.instance.addProject(newProject);
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
        child: StreamBuilder<List<Project>>(
          stream: FirebaseService.instance.getProjects(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final projects = snapshot.data ?? [];
            if (projects.isEmpty) {
              return const Center(child: Text('No projects found.'));
            }
            return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.9,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
          ),
          itemCount: projects.length,
          itemBuilder: (context, index) {
            final project = projects[index];
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedProject = project;
                });
                    _showProjectDetails(project);
                  },
                  child: _buildProjectCardContent(project),
                );
              },
            );
          },
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
                          project.mediaUrls.first,
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