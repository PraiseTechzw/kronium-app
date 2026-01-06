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
  
  const EnhancedBookingForm({
    super.key,
    required this.service,
  });

  @override
  State<EnhancedBookingForm> createState() => _EnhancedBookingFormState();
}

class _EnhancedBookingFormState extends State<EnhancedBookingForm> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final TextEditingController _streetAddressController = TextEditingController();
  final TextEditingController _suburbController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _landmarksController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _contactPersonController = TextEditingController();
  final TextEditingController _emergencyContactController = TextEditingController();
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