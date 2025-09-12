import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kronium/core/app_theme.dart';
import 'package:kronium/core/firebase_service.dart';
import 'package:kronium/models/service_model.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:kronium/core/appwrite_client.dart';

class AdminAddServicePage extends StatefulWidget {
  const AdminAddServicePage({super.key});

  @override
  State<AdminAddServicePage> createState() => _AdminAddServicePageState();
}

class _AdminAddServicePageState extends State<AdminAddServicePage> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  String? _selectedCategory;
  String? _selectedServiceTitle;
  final _descriptionController = TextEditingController();
  final _featuresController = TextEditingController();
  final _priceController = TextEditingController();
  String? _imageUrl;
  bool _isLoading = false;
  XFile? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  final Map<String, List<String>> _categoryToServices = {
    'Construction': [
      'Greenhouse Construction',
      'Farm Structures',
    ],
    'Water': [
      'Irrigation Systems',
      'Borehole Siting',
      'Borehole Drilling',
      'AC & DC Pump Installation',
    ],
    'Energy': [
      'Solar System & Installation',
      'Kronium Engineering Works',
    ],
    'Logistics': [
      'Logistics (Transportation)',
    ],
    'Waste Management': [
      'Waste Management Systems',
    ],
    'Automation/IoT': [
      'IoT and Automation',
    ],
    'Engineering Programs': [
      'Engineering Solutions for Churches (ES4C)',
      'Engineering Solutions for Educational Institutions (ES4EI)',
      'Engineering Solutions for Health Institutions (ES4HI)',
      'Engineering Solutions for Local Authorities (ES4LA)',
      'Engineering Solutions for Industry (ES4I)',
      'Engineering Solutions for Farms, Wastelands & Water Bodys (ES4FWW)',
      'Engineering Solutions for Mines (ES4M)',
      'Engineering Solution for ICT (ES4ICT)',
      'Engineering Solutions for Homes (ES4H)',
      'Engineering Solutions for Offices and Shopping Malls (ES4OSM)',
    ],
  };

  List<String> get _categories => _categoryToServices.keys.toList();
  List<String> get _filteredServiceTitles =>
      _selectedCategory != null ? _categoryToServices[_selectedCategory!] ?? [] : [];

  List<String> get _featuresList => _featuresController.text.split(',').map((f) => f.trim()).where((f) => f.isNotEmpty).toList();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _featuresController.dispose();
    _priceController.dispose();
    super.dispose();
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
    try {
      final bytes = await image.readAsBytes();
      final fileName = image.name;
      // Use the correct Appwrite bucket ID
      const bucketId = '687a6819003de32d8af1';
      final fileId = await AppwriteService.uploadFile(
        bucketId: bucketId,
        path: '',
        bytes: bytes,
        fileName: fileName,
      );
      if (fileId != null) {
        // Appwrite file URL pattern (adjust if needed)
        return 'https://cloud.appwrite.io/v1/storage/buckets/$bucketId/files/$fileId/view?project=6867ce160037a5704b1d';
      }
      return null;
    } catch (e) {
      print('Appwrite upload error: $e');
      rethrow;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    String? imageUrl = _imageUrl;
    if (_pickedImage != null) {
      try {
        imageUrl = await _uploadImageToAppwrite(_pickedImage!);
        if (imageUrl == null) {
          setState(() => _isLoading = false);
          Get.snackbar('Error', 'Image upload failed (no fileId returned)', backgroundColor: Colors.red, colorText: Colors.white);
          return;
        }
      } catch (e) {
        setState(() => _isLoading = false);
        Get.snackbar('Error', 'Image upload failed: ${e.toString()}', backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }
    }
    final service = Service(
      title: _selectedServiceTitle ?? '',
      category: _selectedCategory ?? '',
      description: _descriptionController.text.trim(),
      features: _featuresList,
      imageUrl: imageUrl ?? '',
      price: double.tryParse(_priceController.text.trim()),
      isActive: true,
      icon: Icons.warehouse, // Default icon
      color: AppTheme.primaryColor, // Default color
    );
    await FirebaseService.instance.addService(service);
    setState(() => _isLoading = false);
    Get.back();
    Get.snackbar('Service Added', 'The new service has been added successfully!', backgroundColor: Colors.green, colorText: Colors.white);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Service'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 3) {
            setState(() => _currentStep++);
          } else {
            _submit();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) setState(() => _currentStep--);
        },
        controlsBuilder: (context, details) => const SizedBox.shrink(),
        steps: [
          Step(
            title: const Text('Basic Info'),
            isActive: _currentStep >= 0,
            content: Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: _categories.map((cat) => DropdownMenuItem(
                      value: cat,
                      child: Text(cat),
                    )).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedCategory = val;
                        _selectedServiceTitle = null;
                      });
                    },
                    validator: (v) => v == null || v.isEmpty ? 'Select a category' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedServiceTitle,
                    decoration: const InputDecoration(labelText: 'Service Title'),
                    items: _filteredServiceTitles.map((title) => DropdownMenuItem(
                      value: title,
                      child: Text(title),
                    )).toList(),
                    onChanged: (val) => setState(() => _selectedServiceTitle = val),
                    validator: (v) => v == null || v.isEmpty ? 'Select a service title' : null,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    setState(() => _currentStep++);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Continue', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Step(
            title: const Text('Description & Features'),
            isActive: _currentStep >= 1,
            content: Column(
              children: [
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  validator: (v) => v == null || v.isEmpty ? 'Enter description' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _featuresController,
                  decoration: const InputDecoration(labelText: 'Features (comma separated)'),
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : () => setState(() => _currentStep--),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).primaryColor,
                          side: BorderSide(color: Theme.of(context).primaryColor),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Back', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () => setState(() => _currentStep++),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Continue', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Image (Optional)'),
            isActive: _currentStep >= 2,
            content: Column(
              children: [
                if (_pickedImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(_pickedImage!.path),
                      height: 120,
                      width: 160,
                      fit: BoxFit.cover,
                    ),
                  )
                else if (_imageUrl != null && _imageUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(_imageUrl!, height: 120, width: 160, fit: BoxFit.cover),
                  )
                else
                  Column(
                    children: [
                      Icon(Icons.image_outlined, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text('No image selected.', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text('Pick Image'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Theme.of(context).primaryColor,
                    side: BorderSide(color: Theme.of(context).primaryColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
                if (_pickedImage != null)
                  TextButton.icon(
                    onPressed: _isLoading
                        ? null
                        : () => setState(() => _pickedImage = null),
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text('Remove Image', style: TextStyle(color: Colors.red)),
                  ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : () => setState(() => _currentStep--),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).primaryColor,
                          side: BorderSide(color: Theme.of(context).primaryColor),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Back', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () => setState(() => _currentStep++),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Continue', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Transport Cost & Review'),
            isActive: _currentStep >= 3,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Transport Cost',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Enter transport cost' : null,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : () => setState(() => _currentStep--),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).primaryColor,
                          side: BorderSide(color: Theme.of(context).primaryColor),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Back', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
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
                            : const Text('Continue', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).primaryColor,
                          side: BorderSide(color: Theme.of(context).primaryColor),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 