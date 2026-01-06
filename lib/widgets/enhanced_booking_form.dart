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
    _landmarksController.dispose();
    _notesController.dispose();
    _contactPersonController.dispose();
    _emergencyContactController.dispose();
    super.dispose();
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
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40),
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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Service Info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Iconsax.calendar, color: AppTheme.primaryColor),
                          const SizedBox(width: 12),
                          Text(
                            widget.service.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Emergency Contact
                    TextFormField(
                      controller: _emergencyContactController,
                      decoration: const InputDecoration(
                        labelText: 'Emergency Contact *',
                        hintText: 'Phone number for emergencies',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Emergency contact is required';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Zimbabwe Location Section
                    Text(
                      'Service Location in Zimbabwe',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Please provide detailed address information to help our team locate you easily.',
                        style: TextStyle(color: Colors.blue[700], fontSize: 14),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Street Address
                    TextFormField(
                      controller: _streetAddressController,
                      decoration: const InputDecoration(
                        labelText: 'Street Address *',
                        hintText: 'e.g., 123 Samora Machel Avenue, House 45',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Street address is required';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Suburb and City
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _suburbController,
                            decoration: const InputDecoration(
                              labelText: 'Suburb/Township *',
                              hintText: 'e.g., Avondale',
                              border: OutlineInputBorder(),
                            ),
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
                          child: TextFormField(
                            controller: _cityController,
                            decoration: const InputDecoration(
                              labelText: 'City *',
                              hintText: 'e.g., Harare',
                              border: OutlineInputBorder(),
                            ),
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
                    DropdownButtonFormField<String>(
                      value: _selectedProvince,
                      decoration: const InputDecoration(
                        labelText: 'Province *',
                        border: OutlineInputBorder(),
                      ),
                      items:
                          _zimbabweProvinces.map((String province) {
                            return DropdownMenuItem<String>(
                              value: province,
                              child: Text(province),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedProvince = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a province';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Landmarks
                    TextFormField(
                      controller: _landmarksController,
                      decoration: const InputDecoration(
                        labelText: 'Nearby Landmarks (Optional)',
                        hintText:
                            'e.g., Near OK Supermarket, Opposite Shell Garage',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),

                    const SizedBox(height: 16),

                    // Date Selection
                    ListTile(
                      title: Text(
                        _selectedDate != null
                            ? 'Date: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                            : 'Select Date *',
                      ),
                      leading: const Icon(Iconsax.calendar),
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (picked != null) {
                          setState(() {
                            _selectedDate = picked;
                          });
                        }
                      },
                      tileColor: Colors.grey[100],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Priority Selection
                    Text(
                      'Priority Level',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children:
                          _priorities.map((priority) {
                            final isSelected = _selectedPriority == priority;
                            Color color = Colors.blue;
                            if (priority == 'Low') color = Colors.green;
                            if (priority == 'High') color = Colors.orange;
                            if (priority == 'Urgent') color = Colors.red;

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
                                  color: isSelected ? color : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: color),
                                ),
                                child: Text(
                                  priority,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : color,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),

                    const SizedBox(height: 16),

                    // Notes
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Additional Notes',
                        hintText:
                            'Special requirements, access instructions...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),

                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed:
                            _canSubmit() && !_isLoading ? _submitBooking : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _isUrgent ? Colors.red : AppTheme.primaryColor,
                        ),
                        child:
                            _isLoading
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : Text(
                                  _isUrgent
                                      ? 'Submit Emergency Request'
                                      : 'Submit Booking',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canSubmit() {
    final user = UserAuthService.instance.userProfile.value;
    return user != null &&
        _selectedDate != null &&
        _streetAddressController.text.trim().isNotEmpty &&
        _suburbController.text.trim().isNotEmpty &&
        _cityController.text.trim().isNotEmpty &&
        _selectedProvince != null &&
        _emergencyContactController.text.trim().isNotEmpty;
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;

    final user = UserAuthService.instance.userProfile.value;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
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
        status: _isUrgent ? BookingStatus.confirmed : BookingStatus.pending,
        price: 0.0,
        location: _getFullAddress(),
        notes: _buildNotesWithMetadata(),
        priority: _selectedPriority,
        isUrgent: _isUrgent,
        emergencyContact: _emergencyContactController.text.trim(),
        contactPerson:
            _contactPersonController.text.trim().isNotEmpty
                ? _contactPersonController.text.trim()
                : null,
      );

      await Get.find<SupabaseService>().addBooking(booking);
      Navigator.pop(context);

      Get.snackbar(
        _isUrgent ? 'Emergency Booking Submitted! 🚨' : 'Success! 🎉',
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

    // Add detailed location information
    metadata += '\n--- Zimbabwe Location Details ---\n';
    if (_streetAddressController.text.trim().isNotEmpty) {
      metadata += 'Street Address: ${_streetAddressController.text.trim()}\n';
    }
    if (_suburbController.text.trim().isNotEmpty) {
      metadata += 'Suburb/Township: ${_suburbController.text.trim()}\n';
    }
    if (_cityController.text.trim().isNotEmpty) {
      metadata += 'City: ${_cityController.text.trim()}\n';
    }
    if (_selectedProvince != null) {
      metadata += 'Province: $_selectedProvince\n';
    }
    if (_landmarksController.text.trim().isNotEmpty) {
      metadata += 'Landmarks: ${_landmarksController.text.trim()}\n';
    }

    return notes + metadata;
  }
}
