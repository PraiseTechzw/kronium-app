
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animate_do/animate_do.dart';
import 'package:kronium/core/app_theme.dart';
import 'package:kronium/core/firebase_service.dart';
import 'package:kronium/core/user_controller.dart';
import 'package:kronium/models/service_model.dart';
import 'package:kronium/core/user_auth_service.dart' show UserController;
import 'package:kronium/core/routes.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kronium/core/appwrite_client.dart';
import 'dart:io';

class AdminServicesPage extends StatelessWidget {
  const AdminServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseService = Get.find<FirebaseService>();
    final userController = Get.find<UserController>(); // Added userController

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text('Admin Services', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.user, color: Colors.white),
            onPressed: () {
              // Navigate to admin profile or settings
              Get.toNamed(AppRoutes.profile);
            },
          ),
        ],
        elevation: 0,
      ),
      backgroundColor: AppTheme.backgroundLight,
      floatingActionButton: Obx(() {
        final role = userController.role.value;
        if (role == 'admin') {
          return FloatingActionButton(
            backgroundColor: AppTheme.primaryColor,
            onPressed: () {
              Get.toNamed(AppRoutes.adminAddService);
            },
            tooltip: 'Add Service',
            child: const Icon(Iconsax.add, color: Colors.white),
          );
        }
        return const SizedBox.shrink();
      }),
      bottomNavigationBar: Obx(() {
        final role = userController.role.value;
        final isAdmin = role == 'admin';
        final viewAsAdmin = true; // Or use a toggle if you want
        return BottomNavigationBar(
          currentIndex: 1, // Services tab
          onTap: (index) {
            switch (index) {
              case 0:
                Get.toNamed(AppRoutes.adminDashboard);
                break;
              case 1:
                // Already on services
                break;
              case 2:
                Get.toNamed(AppRoutes.adminProjects);
                break;
              case 3:
                Get.toNamed(AppRoutes.adminChat);
                break;
              case 4:
                Get.toNamed(AppRoutes.profile);
                break;
            }
          },
          backgroundColor: AppTheme.surfaceLight,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: AppTheme.secondaryColor,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Iconsax.home_2),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Iconsax.box),
              label: 'Services',
            ),
            BottomNavigationBarItem(
              icon: Icon(Iconsax.document_text),
              label: 'Projects',
            ),
            BottomNavigationBarItem(
              icon: Icon(Iconsax.message),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Iconsax.user),
              label: 'Profile',
            ),
          ],
        );
      }),
      body: StreamBuilder<List<Service>>(
        stream: firebaseService.getServices(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.warning_2, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading services',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          final services = snapshot.data ?? [];

          if (services.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.box, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No services yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first service to get started',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showAddServiceDialog(context),
                    icon: const Icon(Iconsax.add),
                    label: const Text('Add Service'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return FadeInUp(
                delay: Duration(milliseconds: index * 100),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: service.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: service.imageUrl != null && service.imageUrl!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                service.imageUrl!,
                                fit: BoxFit.cover,
                                width: 60,
                                height: 60,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: Colors.grey[200],
                                  child: Icon(
                                    Icons.broken_image,
                                    color: Colors.grey,
                                    size: 32,
                                  ),
                                ),
                              ),
                            )
                          : Icon(
                              service.icon,
                              color: service.color,
                              size: 24,
                            ),
                    ),
                    title: Text(
                      service.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          service.category,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          service.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: service.isActive
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                service.isActive ? 'Active' : 'Inactive',
                                style: TextStyle(
                                  color: service.isActive ? Colors.green : Colors.red,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (service.price != null)
                              Text(
                                '\$${service.price}',
                                style: TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            _showEditServiceDialog(context, service);
                            break;
                          case 'toggle':
                            _toggleServiceStatus(service);
                            break;
                          case 'delete':
                            _deleteService(service);
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Iconsax.edit, size: 16),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'toggle',
                          child: Row(
                            children: [
                              Icon(
                                service.isActive ? Iconsax.eye_slash : Iconsax.eye,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(service.isActive ? 'Deactivate' : 'Activate'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Iconsax.trash, size: 16, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddServiceDialog(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) => FractionallySizedBox(
          heightFactor: 0.85,
          child: _ServiceDialog(
            service: null,
            isEditing: false,
          ),
        ),
      );
    });
  }

  void _showEditServiceDialog(BuildContext context, Service service) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) => FractionallySizedBox(
          heightFactor: 0.85,
          child: _ServiceDialog(
            service: service,
            isEditing: true,
          ),
        ),
      );
    });
  }

  void _toggleServiceStatus(Service service) {
    final firebaseService = Get.find<FirebaseService>();
    firebaseService.updateService(service.id!, {
      'isActive': !service.isActive,
    });
  }

  void _deleteService(Service service) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Service'),
        content: Text('Are you sure you want to delete "${service.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final firebaseService = Get.find<FirebaseService>();
              firebaseService.deleteService(service.id!);
              Get.back();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _ServiceDialog extends StatefulWidget {
  final Service? service;
  final bool isEditing;

  const _ServiceDialog({
    this.service,
    required this.isEditing,
  });

  @override
  State<_ServiceDialog> createState() => _ServiceDialogState();
}

class _ServiceDialogState extends State<_ServiceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final List<String> _features = [];
  final List<TextEditingController> _featureControllers = [];
  
  String? _selectedIcon;
  Color _selectedColor = AppTheme.primaryColor;
  bool _isLoading = false;
  String? _imageUrl;
  XFile? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.service != null) {
      _titleController.text = widget.service!.title;
      _categoryController.text = widget.service!.category;
      _descriptionController.text = widget.service!.description;
      _priceController.text = widget.service!.price?.toString() ?? '';
      _selectedIcon = widget.service!.icon.codePoint.toString();
      _selectedColor = widget.service!.color;
      _features.addAll(widget.service!.features);
      _imageUrl = widget.service!.imageUrl;
      for (String feature in _features) {
        _featureControllers.add(TextEditingController(text: feature));
      }
    } else {
      _addFeatureField();
    }
  }

  void _addFeatureField() {
    setState(() {
      _features.add('');
      _featureControllers.add(TextEditingController());
    });
  }

  void _removeFeatureField(int index) {
    setState(() {
      _features.removeAt(index);
      _featureControllers[index].dispose();
      _featureControllers.removeAt(index);
    });
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() {
        _pickedImage = picked;
      });
    }
  }

  Future<String?> _uploadImageToAppwrite(XFile image) async {
    final bytes = await image.readAsBytes();
    final fileName = image.name;
    const bucketId = '687a6819003de32d8af1';
    const projectId = '6867ce160037a5704b1d';
    print('Uploading image to Appwrite: bucketId=$bucketId, fileName=$fileName, bytes=${bytes.length}');
    final fileId = await AppwriteService.uploadFile(
      bucketId: bucketId,
      path: '',
      bytes: bytes,
      fileName: fileName,
    );
    print('Appwrite upload returned fileId: $fileId');
    if (fileId != null) {
      final url = 'https://cloud.appwrite.io/v1/storage/buckets/$bucketId/files/$fileId/view?project=$projectId';
      print('Appwrite file URL: $url');
      return url;
    }
    print('Appwrite upload failed, fileId is null');
    return null;
  }

  Future<void> _saveService() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final firebaseService = Get.find<FirebaseService>();
      // Update features from controllers
      for (int i = 0; i < _featureControllers.length; i++) {
        if (i < _features.length) {
          _features[i] = _featureControllers[i].text;
        }
      }
      String? imageUrl = _imageUrl;
      if (_pickedImage != null) {
        imageUrl = await _uploadImageToAppwrite(_pickedImage!);
        if (imageUrl == null) {
          throw Exception('Image upload failed');
        }
      }
      final service = Service(
        id: widget.service?.id,
        title: _titleController.text,
        category: _categoryController.text,
        icon: _getIconFromString(_selectedIcon ?? 'warehouse'),
        color: _selectedColor,
        description: _descriptionController.text,
        features: _features.where((f) => f.isNotEmpty).toList(),
        price: double.tryParse(_priceController.text),
        imageUrl: imageUrl,
      );
      if (widget.isEditing) {
        await firebaseService.updateService(service.id!, service.toFirestore());
      } else {
        await firebaseService.addService(service);
      }
      Get.back();
      Get.snackbar(
        'Success',
        widget.isEditing ? 'Service updated successfully' : 'Service added successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save service: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  IconData _getIconFromString(String iconString) {
    switch (iconString) {
      case 'warehouse':
        return Icons.warehouse;
      case 'solar_power':
        return Icons.solar_power;
      case 'construction':
        return Icons.construction;
      case 'engineering':
        return Icons.engineering;
      case 'home_repair_service':
        return Icons.home_repair_service;
      case 'electrical_services':
        return Icons.electrical_services;
      case 'plumbing':
        return Icons.plumbing;
      case 'cleaning_services':
        return Icons.cleaning_services;
      default:
        return Icons.warehouse;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 500),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.isEditing ? Iconsax.edit : Iconsax.add,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.isEditing ? 'Edit Service' : 'Add New Service',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Service Title',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter service title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _categoryController,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter category';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Price (optional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Features Section
                      const Text(
                        'Features',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...List.generate(_featureControllers.length, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _featureControllers[index],
                                  decoration: InputDecoration(
                                    labelText: 'Feature ${index + 1}',
                                    border: const OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              if (_featureControllers.length > 1)
                                IconButton(
                                  onPressed: () => _removeFeatureField(index),
                                  icon: const Icon(Iconsax.trash, color: Colors.red),
                                ),
                            ],
                          ),
                        );
                      }),
                      TextButton.icon(
                        onPressed: _addFeatureField,
                        icon: const Icon(Iconsax.add),
                        label: const Text('Add Feature'),
                      ),
                      // Image picker and preview
                      const SizedBox(height: 16),
                      if (_pickedImage != null)
                        Image.file(
                          File(_pickedImage!.path),
                          height: 120,
                        )
                      else if (_imageUrl != null && _imageUrl!.isNotEmpty)
                        Image.network(_imageUrl!, height: 120),
                      TextButton.icon(
                        onPressed: _isLoading ? null : _pickImage,
                        icon: const Icon(Iconsax.image),
                        label: const Text('Pick Image'),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: _isLoading ? null : () => Get.back(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveService,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(widget.isEditing ? 'Update' : 'Add'),
                      ),
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

  @override
  void dispose() {
    for (var controller in _featureControllers) {
      controller.dispose();
    }
    _titleController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }
} 