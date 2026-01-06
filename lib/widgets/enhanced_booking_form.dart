import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kronium/core/app_theme.dart';
import 'package:kronium/core/supabase_service.dart';
import 'package:kronium/core/user_auth_service.dart';
import 'package:kronium/models/booking_model.dart';
import 'package:kronium/models/service_model.dart';

class EnhancedBookingForm extends StatefulWidget {
  final Service service;

  const EnhancedBookingForm({super.key, required this.service});

  @override
  State<EnhancedBookingForm> createState() => _EnhancedBookingFormState();
}

class _EnhancedBookingFormState extends State<EnhancedBookingForm> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final TextEditingController _streetAddressController =
      TextEditingController();
  final TextEditingController _suburbController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _provinceController = TextEditingController();
  final TextEditingController _landmarksController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _contactPersonController =
      TextEditingController();
  final TextEditingController _emergencyContactController =
      TextEditingController();
  bool _isLoading = false;
  bool _isUrgent = false;
  String _selectedPriority = 'Normal';
  final List<String> _priorities = ['Low', 'Normal', 'High', 'Urgent'];
  final _formKey = GlobalKey<FormState>();

  // Zimbabwe provinces
  final List<String> _zimbabweProvinces = [
    'Harare',
    'Bulawayo',
    'Manicaland',
    'Mashonaland Central',
    'Mashonaland East',
    'Mashonaland West',
    'Masvingo',
    'Matabeleland North',
    'Matabeleland South',
    'Midlands',
  ];

  String? _selectedProvince;

  @override
  void dispose() {
    _streetAddressController.dispose();
    _suburbController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    _landmarksController.dispose();
    _notesController.dispose();
    _contactPersonController.dispose();
    _emergencyContactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = UserAuthService.instance.userProfile.value;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Enhanced Handle bar with drag indicator
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              ),
            ),

            // Header with close button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40), // Balance the close button
                  Text(
                    'Book Service',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.close,
                        size: 20,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                  left: 24,
                  right: 24,
                  top: 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Service Info Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryColor.withOpacity(0.1),
                            AppTheme.secondaryColor.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.primaryColor.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Iconsax.calendar,
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
                                  widget.service.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Professional service booking',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Client Information Section
                    _buildSectionHeader('Client Information', Iconsax.user),
                    const SizedBox(height: 12),

                    // Contact Person Field (if different from user)
                    _buildInputField(
                      controller: _contactPersonController,
                      label: 'Contact Person (Optional)',
                      hint: 'If different from ${user?.name ?? 'you'}',
                      icon: Iconsax.user_octagon,
                      validator: null,
                    ),

                    const SizedBox(height: 16),

                    // Emergency Contact Field
                    _buildInputField(
                      controller: _emergencyContactController,
                      label: 'Emergency Contact *',
                      hint: 'Emergency contact number',
                      icon: Iconsax.call,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Emergency contact is required';
                        }
                        if (value.trim().length < 10) {
                          return 'Please enter a valid phone number';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // Service Details Section
                    _buildSectionHeader(
                      'Service Location (Zimbabwe)',
                      Iconsax.setting_2,
                    ),
                    const SizedBox(height: 12),

                    // Location guidance card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue[200]!, width: 1),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Iconsax.info_circle,
                            color: Colors.blue[700],
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Please provide detailed address information to help our team locate you easily in Zimbabwe.',
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Street Address Field
                    _buildInputField(
                      controller: _streetAddressController,
                      label: 'Street Address *',
                      hint: 'e.g., 123 Samora Machel Avenue, House Number 45',
                      icon: Iconsax.location,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Street address is required';
                        }
                        if (value.trim().length < 5) {
                          return 'Please provide a more detailed street address';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Suburb and City Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildInputField(
                            controller: _suburbController,
                            label: 'Suburb/Township *',
                            hint: 'e.g., Avondale, Mbare',
                            icon: Iconsax.building,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Suburb is required';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInputField(
                            controller: _cityController,
                            label: 'City *',
                            hint: 'e.g., Harare, Bulawayo',
                            icon: Iconsax.buildings,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'City is required';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Province Dropdown
                    _buildProvinceDropdown(),

                    const SizedBox(height: 16),

                    // Landmarks Field
                    _buildInputField(
                      controller: _landmarksController,
                      label: 'Nearby Landmarks (Optional)',
                      hint:
                          'e.g., Near OK Supermarket, Opposite Shell Garage, Behind Chicken Inn',
                      icon: Iconsax.map,
                      maxLines: 2,
                      validator: null,
                    ),

                    const SizedBox(height: 16),

                    // Date and Time Selection Row
                    Row(
                      children: [
                        // Date Selection
                        Expanded(flex: 3, child: _buildDateTimeField()),
                        const SizedBox(width: 12),
                        // Time Selection
                        Expanded(flex: 2, child: _buildTimeField()),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Priority Selection
                    _buildPriorityField(),

                    const SizedBox(height: 16),

                    // Urgent Service Toggle
                    _buildUrgentToggle(),

                    const SizedBox(height: 16),

                    // Additional Notes Field
                    _buildInputField(
                      controller: _notesController,
                      label: 'Additional Notes & Requirements',
                      hint:
                          'Special requirements, access instructions, equipment needs...',
                      icon: Iconsax.note_1,
                      maxLines: 4,
                      validator: null,
                    ),

                    const SizedBox(height: 24),

                    // Booking Summary Card
                    _buildBookingSummary(user),

                    const SizedBox(height: 24),

                    // Enhanced Submit Button
                    _buildSubmitButton(user),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
          child: Icon(icon, color: AppTheme.primaryColor, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey[700],
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 20),
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
        ),
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildDateTimeField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: InkWell(
        onTap: () async {
          DateTime now = DateTime.now();
          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: _selectedDate ?? now,
            firstDate: now,
            lastDate: DateTime(now.year + 2),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: AppTheme.primaryColor,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Colors.black,
                  ),
                ),
                child: child!,
              );
            },
          );
          if (picked != null) {
            setState(() {
              _selectedDate = picked;
            });
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Iconsax.calendar,
                  color: AppTheme.primaryColor,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date *',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedDate != null
                          ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                          : 'Select date',
                      style: TextStyle(
                        color:
                            _selectedDate != null
                                ? AppTheme.primaryColor
                                : Colors.grey[500],
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
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

  Widget _buildTimeField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: InkWell(
        onTap: () async {
          TimeOfDay? picked = await showTimePicker(
            context: context,
            initialTime: _selectedTime ?? TimeOfDay.now(),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: AppTheme.primaryColor,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Colors.black,
                  ),
                ),
                child: child!,
              );
            },
          );
          if (picked != null) {
            setState(() {
              _selectedTime = picked;
            });
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Iconsax.clock,
                  color: AppTheme.primaryColor,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Time',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedTime != null
                          ? _selectedTime!.format(context)
                          : 'Select',
                      style: TextStyle(
                        color:
                            _selectedTime != null
                                ? AppTheme.primaryColor
                                : Colors.grey[500],
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
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

  Widget _buildProvinceDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedProvince,
        decoration: InputDecoration(
          labelText: 'Province *',
          labelStyle: TextStyle(
            color: Colors.grey[700],
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Iconsax.map_1,
              color: AppTheme.primaryColor,
              size: 20,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppTheme.primaryColor,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          hintText: 'Select your province',
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontSize: 14,
          ),
        ),
        items: _zimbabweProvinces.map((String province) {
          return DropdownMenuItem<String>(
            value: province,
            child: Text(
              province,
              style: const TextStyle(fontSize: 16),
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedProvince = newValue;
            _provinceController.text = newValue ?? '';
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a province';
          }
          return null;
        },
        style: const TextStyle(fontSize: 16, color: Colors.black87),
        dropdownColor: Colors.white,
        icon: Icon(
          Icons.keyboard_arrow_down,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Iconsax.flag,
                    color: AppTheme.primaryColor,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Priority Level',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children:
                  _priorities.map((priority) {
                    final isSelected = _selectedPriority == priority;
                    Color priorityColor = Colors.grey;
                    switch (priority) {
                      case 'Low':
                        priorityColor = Colors.green;
                        break;
                      case 'Normal':
                        priorityColor = Colors.blue;
                        break;
                      case 'High':
                        priorityColor = Colors.orange;
                        break;
                      case 'Urgent':
                        priorityColor = Colors.red;
                        break;
                    }

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedPriority = priority;
                          _isUrgent = priority == 'Urgent';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? priorityColor : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: priorityColor, width: 1),
                        ),
                        child: Text(
                          priority,
                          style: TextStyle(
                            color: isSelected ? Colors.white : priorityColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUrgentToggle() {
    return Container(
      decoration: BoxDecoration(
        color: _isUrgent ? Colors.red[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isUrgent ? Colors.red[200]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    _isUrgent
                        ? Colors.red.withOpacity(0.1)
                        : AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Iconsax.warning_2,
                color: _isUrgent ? Colors.red : AppTheme.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Emergency Service',
                    style: TextStyle(
                      color: _isUrgent ? Colors.red[700] : Colors.grey[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Requires immediate attention (24-48 hours)',
                    style: TextStyle(
                      color: _isUrgent ? Colors.red[600] : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: _isUrgent,
              onChanged: (value) {
                setState(() {
                  _isUrgent = value;
                  if (value) {
                    _selectedPriority = 'Urgent';
                  } else if (_selectedPriority == 'Urgent') {
                    _selectedPriority = 'Normal';
                  }
                });
              },
              activeColor: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingSummary(user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[50]!, Colors.indigo[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[200]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.document_text, color: Colors.blue[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Booking Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummaryRow('Service', widget.service.title),
          _buildSummaryRow('Client', user?.name ?? 'Not logged in'),
          _buildSummaryRow('Contact', user?.phone ?? 'Not provided'),
          if (_selectedDate != null)
            _buildSummaryRow(
              'Date & Time',
              '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}' +
                  (_selectedTime != null
                      ? ' at ${_selectedTime!.format(context)}'
                      : ''),
            ),
          if (_getFullAddress().isNotEmpty)
            _buildSummaryRow('Location', _getFullAddress()),
          _buildSummaryRow('Priority', _selectedPriority),
          if (_isUrgent)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Iconsax.warning_2, size: 16, color: Colors.red[700]),
                  const SizedBox(width: 4),
                  Text(
                    'EMERGENCY SERVICE',
                    style: TextStyle(
                      color: Colors.red[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _getFullAddress() {
    List<String> addressParts = [];
    
    if (_streetAddressController.text.trim().isNotEmpty) {
      addressParts.add(_streetAddressController.text.trim());
    }
    if (_suburbController.text.trim().isNotEmpty) {
      addressParts.add(_suburbController.text.trim());
    }
    if (_cityController.text.trim().isNotEmpty) {
      addressParts.add(_cityController.text.trim());
    }
    if (_selectedProvince != null && _selectedProvince!.isNotEmpty) {
      addressParts.add(_selectedProvince!);
    }
    
    String fullAddress = addressParts.join(', ');
    
    if (_landmarksController.text.trim().isNotEmpty) {
      fullAddress += '\nLandmarks: ${_landmarksController.text.trim()}';
    }
    
    return fullAddress;
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(user) {
    final bool canSubmit =
        user != null &&
        _selectedDate != null &&
        _locationController.text.trim().isNotEmpty &&
        _emergencyContactController.text.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient:
            canSubmit && !_isLoading
                ? LinearGradient(
                  colors:
                      _isUrgent
                          ? [Colors.red[600]!, Colors.red[700]!]
                          : [AppTheme.primaryColor, AppTheme.secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                : null,
        color: !canSubmit || _isLoading ? Colors.grey[300] : null,
        borderRadius: BorderRadius.circular(16),
        boxShadow:
            canSubmit && !_isLoading
                ? [
                  BoxShadow(
                    color: (_isUrgent ? Colors.red : AppTheme.primaryColor)
                        .withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ]
                : null,
      ),
      child: ElevatedButton(
        onPressed:
            !canSubmit || _isLoading
                ? null
                : () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() => _isLoading = true);
                    try {
                      // Combine date and time
                      DateTime bookingDateTime = _selectedDate!;
                      if (_selectedTime != null) {
                        bookingDateTime = DateTime(
                          _selectedDate!.year,
                          _selectedDate!.month,
                          _selectedDate!.day,
                          _selectedTime!.hour,
                          _selectedTime!.minute,
                        );
                      }

                      final booking = Booking(
                        serviceName: widget.service.title,
                        clientName:
                            _contactPersonController.text.trim().isNotEmpty
                                ? _contactPersonController.text.trim()
                                : user.name,
                        clientEmail: user.email,
                        clientPhone: _emergencyContactController.text.trim(),
                        date: bookingDateTime,
                        status:
                            _isUrgent
                                ? BookingStatus.confirmed
                                : BookingStatus.pending,
                        price: 0.0,
                        location: _locationController.text.trim(),
                        notes: _buildNotesWithMetadata(),
                      );

                      await Get.find<SupabaseService>().addBooking(booking);
                      Navigator.pop(context);

                      Get.snackbar(
                        _isUrgent
                            ? 'Emergency Booking Submitted! 🚨'
                            : 'Success! 🎉',
                        _isUrgent
                            ? 'Emergency service request submitted. You will be contacted within 2 hours.'
                            : 'Service booking submitted successfully!',
                        backgroundColor: _isUrgent ? Colors.red : Colors.green,
                        colorText: Colors.white,
                        duration: Duration(seconds: _isUrgent ? 5 : 3),
                        snackPosition: SnackPosition.TOP,
                      );
                    } catch (e) {
                      Get.snackbar(
                        'Error ❌',
                        'Failed to book service: $e',
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                        duration: const Duration(seconds: 4),
                        snackPosition: SnackPosition.TOP,
                      );
                    } finally {
                      setState(() => _isLoading = false);
                    }
                  }
                },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child:
            _isLoading
                ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isUrgent) ...[
                      const Icon(
                        Iconsax.warning_2,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      _isUrgent ? 'Submit Emergency Request' : 'Submit Booking',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  String _buildNotesWithMetadata() {
    String notes = _notesController.text.trim();
    String metadata = '\n\n--- Booking Details ---\n';
    metadata += 'Priority: $_selectedPriority\n';
    if (_isUrgent) metadata += 'EMERGENCY SERVICE REQUESTED\n';
    if (_selectedTime != null) {
      metadata += 'Preferred Time: ${_selectedTime!.format(context)}\n';
    }
    if (_contactPersonController.text.trim().isNotEmpty) {
      metadata += 'Contact Person: ${_contactPersonController.text.trim()}\n';
    }
    metadata +=
        'Emergency Contact: ${_emergencyContactController.text.trim()}\n';

    return notes + metadata;
  }
}
