import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:kronium/core/app_theme.dart';

class AddServicePage extends StatefulWidget {
  const AddServicePage({super.key});

  @override
  AddServicePageState createState() => AddServicePageState();
}

class AddServicePageState extends State<AddServicePage> {
  final _formKey = GlobalKey<FormState>();
  final List<String> categories = ['Construction', 'Renewable Energy', 'Agriculture', 'Technology'];
  final ImagePicker _picker = ImagePicker();
  
  // Form controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _imagePathController = TextEditingController(text: 'assets/images/service.jpg');
  final TextEditingController _videoUrlController = TextEditingController();
  
  String _selectedCategory = 'Construction';
  Color _selectedColor = const Color(0xFF3498DB);
  IconData _selectedIcon = FontAwesomeIcons.building;
  final List<String> _features = [];
  final TextEditingController _featureController = TextEditingController();
  File? _videoFile;
  bool _isUploadingVideo = false;

  // Color and icon options
  final List<Color> colorOptions = [
    const Color(0xFF2ECC71), const Color(0xFFF39C12),
    const Color(0xFF3498DB), const Color(0xFF9B59B6),
    const Color(0xFFE74C3C),
  ];

  final List<IconData> iconOptions = [
    FontAwesomeIcons.building, FontAwesomeIcons.solarPanel,
    FontAwesomeIcons.tractor, FontAwesomeIcons.laptopCode,
    FontAwesomeIcons.warehouse, FontAwesomeIcons.hardHat,
    FontAwesomeIcons.bolt, FontAwesomeIcons.leaf,
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imagePathController.dispose();
    _videoUrlController.dispose();
    _featureController.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    setState(() => _isUploadingVideo = true);
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        setState(() => _videoFile = File(video.path));
      }
    } catch (e) {
      Get.snackbar(
        'Error', 
        'Failed to pick video: ${e.toString()}',
        backgroundColor: AppTheme.errorColor,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() => _isUploadingVideo = false);
    }
  }

  Widget _buildVideoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Service Video',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        if (_videoFile != null || _videoUrlController.text.isNotEmpty) ...[
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Icon(Icons.videocam, color: Colors.red, size: 40),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _videoFile?.path.split('/').last ?? 
                          _videoUrlController.text,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _videoFile != null 
                            ? '${(_videoFile!.lengthSync() / 1024 / 1024).toStringAsFixed(1)} MB' 
                            : 'URL provided',
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => setState(() {
                      _videoFile = null;
                      _videoUrlController.clear();
                    }),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'OR',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 8),
        ],
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                _videoUrlController,
                'YouTube/Vimeo URL',
                FontAwesomeIcons.link,
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: _pickVideo,
              icon: const Icon(Icons.upload),
              label: const Text('Upload'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        if (_isUploadingVideo) ...[
          const SizedBox(height: 10),
          const LinearProgressIndicator(),
          const SizedBox(height: 5),
          const Text(
            'Uploading video...',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ],
    );
  }

  Widget _buildFormSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller, 
    String label, 
    IconData icon, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildDropdownField(
    String label,
    List<String> items,
    String value,
    void Function(String?) onChanged, {
    IconData? icon,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newService = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'category': _selectedCategory,
        'price': double.tryParse(_priceController.text),
        'imagePath': _imagePathController.text,
        'video': _videoFile ?? _videoUrlController.text,
        'icon': _selectedIcon,
        'color': _selectedColor,
        'features': List<String>.from(_features),
      };
      
      print('New Service with Video: $newService');
      
      Get.snackbar(
        'Success',
        'Service with video added successfully',
        backgroundColor: AppTheme.primaryColor,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      
      Get.back(result: newService);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text('Add New Service', 
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            fontSize: 20, 
            color: Colors.white
          )
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFormSection('Basic Information', [
                _buildTextField(_titleController, 'Service Title', Icons.title, validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter a title';
                  return null;
                }),
                const SizedBox(height: 16),
                _buildTextField(_descriptionController, 'Description', Icons.description, 
                  maxLines: 3, validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter a description';
                    return null;
                  }),
                const SizedBox(height: 16),
                _buildDropdownField(
                  'Category',
                  categories,
                  _selectedCategory,
                  (value) => setState(() => _selectedCategory = value!),
                  icon: FontAwesomeIcons.list,
                ),
                const SizedBox(height: 16),
                _buildTextField(_priceController, 'Price (\$)', FontAwesomeIcons.dollarSign,
                  keyboardType: TextInputType.number, validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter a price';
                    if (double.tryParse(value) == null) return 'Please enter a valid number';
                    return null;
                  }),
                const SizedBox(height: 16),
                _buildTextField(_imagePathController, 'Image Path', FontAwesomeIcons.image,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter an image path';
                    return null;
                  }),
              ]),
              
              const SizedBox(height: 24),
              _buildFormSection('Video Demonstration', [
                _buildVideoSection(),
              ]),
              
              const SizedBox(height: 24),
              _buildFormSection('Appearance', [
                const Text('Select Icon', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 60,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: iconOptions.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => setState(() => _selectedIcon = iconOptions[index]),
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: _selectedIcon == iconOptions[index] 
                              ? _selectedColor.withValues(alpha: 0.2) 
                              : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            border: _selectedIcon == iconOptions[index]
                              ? Border.all(color: _selectedColor, width: 2)
                              : null,
                          ),
                          child: Center(
                            child: FaIcon(
                              iconOptions[index],
                              color: _selectedIcon == iconOptions[index] 
                                ? _selectedColor 
                                : Colors.grey[600],
                              size: 24,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Select Color', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 50,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: colorOptions.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => setState(() => _selectedColor = colorOptions[index]),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: colorOptions[index],
                            shape: BoxShape.circle,
                            border: _selectedColor == colorOptions[index]
                              ? Border.all(color: Colors.white, width: 3)
                              : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ]),
              
              const SizedBox(height: 24),
              _buildFormSection('Features', [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _featureController,
                        decoration: InputDecoration(
                          labelText: 'Add Feature',
                          prefixIcon: const Icon(Icons.add),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.green),
                      onPressed: () {
                        if (_featureController.text.isNotEmpty) {
                          setState(() {
                            _features.add(_featureController.text);
                            _featureController.clear();
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_features.isNotEmpty) ...[
                  const Text('Current Features:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _features.map((feature) => Chip(
                      label: Text(feature),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () => setState(() => _features.remove(feature)),
                    )).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
              ]),
              
              const SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save Service',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}