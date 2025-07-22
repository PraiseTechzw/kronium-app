import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kronium/core/app_theme.dart';
import 'package:kronium/core/routes.dart';
import 'package:kronium/core/user_auth_service.dart';
import 'dart:math';
import 'package:kronium/core/firebase_service.dart';
import 'package:kronium/models/project_model.dart';

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
    List<String> features = List<String>.from(project?.bookedDates.map((e) => e.status) ?? []); // Placeholder for features, adjust as needed
    String featureInput = '';
    List<String> mediaUrls = List<String>.from(project?.mediaUrls ?? []);
    String mediaInput = '';
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
                    const Text('Media/Image URLs', style: TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(labelText: 'Add Media URL', prefixIcon: Icon(Iconsax.add)),
                            onChanged: (v) => mediaInput = v,
                            onSubmitted: (v) {
                              if (v.trim().isNotEmpty) {
                                setModalState(() {
                                  mediaUrls.add(v.trim());
                                });
                              }
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Iconsax.add_circle, color: Colors.green),
                          onPressed: () {
                            if (mediaInput.trim().isNotEmpty) {
                              setModalState(() {
                                mediaUrls.add(mediaInput.trim());
                                mediaInput = '';
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    if (mediaUrls.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        children: mediaUrls.map((f) => Chip(
                          label: Text(f),
                          onDeleted: () => setModalState(() => mediaUrls.remove(f)),
                        )).toList(),
                        ),
                    if (mediaUrls.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(mediaUrls.first, height: 80, width: 120, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.broken_image)),
                        ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            // Validation
                            if (titleController.text.trim().isEmpty || locationController.text.trim().isEmpty || descController.text.trim().isEmpty) {
                              Get.snackbar('Error', 'Title, Location, and Description are required', backgroundColor: Colors.red, colorText: Colors.white);
                              return;
                            }
                            final newProject = Project(
                              id: project?.id ?? '',
                              title: titleController.text.trim(),
                              description: descController.text.trim(),
                              location: locationController.text.trim(),
                              size: sizeController.text.trim(),
                              mediaUrls: mediaUrls,
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
    // TODO: Implement project details bottom sheet with edit/delete actions, approval toggle, and file upload
  }
} 