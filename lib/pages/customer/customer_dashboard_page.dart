import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kronium/core/app_theme.dart';
import 'package:kronium/core/user_auth_service.dart';
import 'package:kronium/pages/projects/mock_project_booking_data.dart';
import 'package:kronium/widgets/login_bottom_sheet.dart';

// Add controllers and saved fields for booking form
final TextEditingController _nameController = TextEditingController();
final TextEditingController _emailController = TextEditingController();
final TextEditingController _phoneController = TextEditingController();
String? _savedName, _savedEmail, _savedPhone;

List<DateTime> get _takenDates => MockProjectBookingData().bookedDates;

double _calculateSmartTransportCost(String location, String size) {
  double base = 10.0;
  double sizeFactor = size.length * 2.0;
  double locationFactor = location.length * 1.5;
  double distanceFactor = (location.hashCode % 20).toDouble();
  return base + sizeFactor + locationFactor + distanceFactor;
}

class CustomerDashboardPage extends StatefulWidget {
  const CustomerDashboardPage({super.key});

  @override
  State<CustomerDashboardPage> createState() => _CustomerDashboardPageState();
}

class _CustomerDashboardPageState extends State<CustomerDashboardPage> {
  // Mock project data
  final List<Map<String, dynamic>> _projects = [
    {
      'title': 'Solar Farm Installation',
      'status': 'Completed',
      'progress': 100,
      'date': 'June 2023',
      'location': 'Harare, Zimbabwe',
      'description': '5MW solar farm installation for commercial energy production',
      'lastUpdate': 'Completed and handed over',
    },
    {
      'title': 'Industrial Greenhouse Complex',
      'status': 'In Progress',
      'progress': 65,
      'date': 'January 2024',
      'location': 'Bulawayo, Zimbabwe',
      'description': '10-acre automated greenhouse for year-round vegetable production',
      'lastUpdate': 'Irrigation system installed',
    },
    {
      'title': 'Commercial Steel Structure',
      'status': 'Booked',
      'progress': 0,
      'date': 'September 2024',
      'location': 'Mutare, Zimbabwe',
      'description': '15,000 sq ft steel warehouse with office complex',
      'lastUpdate': 'Booking confirmed',
    },
  ];

  String _selectedStatus = 'All';
  final List<String> _statusFilters = ['All', 'Booked', 'In Progress', 'Completed'];

  @override
  Widget build(BuildContext context) {
    final filteredProjects = _selectedStatus == 'All'
        ? _projects
        : _projects.where((p) => p['status'] == _selectedStatus).toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('My Dashboard'),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.add_square, color: Colors.white),
            tooltip: 'Book New Project',
            onPressed: _showBookProjectBottomSheet,
          ),
          Obx(() {
            final user = UserAuthService.instance.userProfile.value;
            return IconButton(
              icon: Icon(
                user == null ? Iconsax.login : Iconsax.user,
                color: Colors.white,
              ),
              tooltip: user == null ? 'Login' : 'Profile',
              onPressed: () async {
                if (user == null) {
                  await showLoginBottomSheet(context);
                } else {
                  Get.toNamed('/customer-profile');
                }
              },
            );
          }),
        ],
      ),
      body: Column(
        children: [
          // Status filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: _statusFilters.map((status) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(status),
                  selected: _selectedStatus == status,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedStatus = status);
                  },
                  selectedColor: AppTheme.primaryColor,
                  labelStyle: TextStyle(
                    color: _selectedStatus == status ? Colors.white : AppTheme.primaryColor,
                  ),
                ),
              )).toList(),
            ),
          ),
          // Recent updates/notifications
          if (_projects.any((p) => p['lastUpdate'] != null))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Recent Updates', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ..._projects.where((p) => p['lastUpdate'] != null).map((p) => ListTile(
                    leading: const Icon(Iconsax.info_circle, color: AppTheme.primaryColor),
                    title: Text(p['title']),
                    subtitle: Text(p['lastUpdate']),
                  )),
                ],
              ),
            ),
          // Project list
          Expanded(
            child: filteredProjects.isEmpty
                ? Center(
                    child: Text('No projects found for $_selectedStatus', style: const TextStyle(color: Colors.grey)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredProjects.length,
                    itemBuilder: (context, index) {
                      final project = filteredProjects[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => _showProjectDetailsBottomSheet(project),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        project['title'],
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                      ),
                                    ),
                                    Chip(
                                      label: Text(project['status']),
                                      backgroundColor: _statusColor(project['status']),
                                      labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(project['description'], style: const TextStyle(fontSize: 14, color: Colors.black87)),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Iconsax.location, size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(project['location'], style: const TextStyle(fontSize: 13, color: Colors.grey)),
                                    const Spacer(),
                                    Text(project['date'], style: const TextStyle(fontSize: 13, color: Colors.grey)),
                                  ],
                                ),
                                if (project['progress'] != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: LinearProgressIndicator(
                                      value: (project['progress'] as int) / 100,
                                      backgroundColor: AppTheme.surfaceLight,
                                      valueColor: AlwaysStoppedAnimation<Color>(_statusColor(project['status'])),
                                      minHeight: 6,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green;
      case 'In Progress':
        return Colors.orange;
      case 'Booked':
        return AppTheme.primaryColor;
      default:
        return Colors.grey;
    }
  }

  void _showBookProjectBottomSheet() {
    // --- Modular Booking Bottom Sheet for Project Request (copied from projects_page.dart) ---
    final List<String> projectTypes = [
      'Greenhouse',
      'Construction',
      'Solar Systems',
      'Irrigation Systems',
      'Logistics',
    ];
    int currentStep = 0;
    String? selectedType = projectTypes.first;
    DateTime? selectedDate;
    String location = '';
    String size = '';
    double? liveTransportCost;
    final formKey = GlobalKey<FormState>();

    // Prefill user info if available (prefer userProfile, fallback to saved)
    final user = UserAuthService.instance.userProfile.value;
    _nameController.text = user?.name ?? _savedName ?? '';
    _emailController.text = user?.email ?? _savedEmail ?? '';
    _phoneController.text = user?.phone ?? _savedPhone ?? '';

    void updateTransportCost() {
      liveTransportCost = _calculateSmartTransportCost(location, size);
    }

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setModalState) {
          void nextStep() {
            if (currentStep < 2) {
              setModalState(() => currentStep++);
            }
          }
          void prevStep() {
            if (currentStep > 0) {
              setModalState(() => currentStep--);
            }
          }
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // --- Stepper Indicator ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.looks_one, color: currentStep == 0 ? AppTheme.primaryColor : Colors.grey),
                    Container(width: 30, height: 2, color: currentStep > 0 ? AppTheme.primaryColor : Colors.grey[300]),
                    Icon(Icons.looks_two, color: currentStep == 1 ? AppTheme.primaryColor : Colors.grey),
                    Container(width: 30, height: 2, color: currentStep > 1 ? AppTheme.primaryColor : Colors.grey[300]),
                    Icon(Icons.looks_3, color: currentStep == 2 ? AppTheme.primaryColor : Colors.grey),
                  ],
                ),
                const SizedBox(height: 20),
                if (currentStep == 0) ...[
                  // --- Step 1: Select Project Type ---
                  const Text('Select Project Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    children: projectTypes.map((type) => ChoiceChip(
                      label: Text(type),
                      selected: selectedType == type,
                      onSelected: (selected) {
                        setModalState(() => selectedType = type);
                      },
                      selectedColor: AppTheme.primaryColor,
                      labelStyle: TextStyle(color: selectedType == type ? Colors.white : AppTheme.primaryColor),
                    )).toList(),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: nextStep,
                        child: const Text('Next'),
                      ),
                    ],
                  ),
                ] else if (currentStep == 1) ...[
                  // --- Step 2: User Details & Date ---
                  const Text('Your Details & Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 10),
                  Form(
                    key: formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(labelText: 'Full Name'),
                          validator: (v) => v == null || v.isEmpty ? 'Enter your name' : null,
                        ),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(labelText: 'Email'),
                          validator: (v) => v == null || v.isEmpty ? 'Enter your email' : null,
                        ),
                        TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(labelText: 'Phone'),
                          validator: (v) => v == null || v.isEmpty ? 'Enter your phone' : null,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Text(selectedDate == null
                                ? 'No date selected'
                                : 'Date: ${selectedDate!.toLocal().toString().split(' ')[0]}'),
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
                                    return !_takenDates.any((d) => d.year == date.year && d.month == date.month && d.day == date.day);
                                  },
                                );
                                if (picked != null) {
                                  setModalState(() => selectedDate = picked);
                                }
                              },
                              child: const Text('Pick Date'),
                            ),
                          ],
                        ),
                        if (selectedDate != null && _takenDates.any((d) => d.year == selectedDate!.year && d.month == selectedDate!.month && d.day == selectedDate!.day))
                          const Text('Selected date is unavailable. Please pick another.', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(onPressed: prevStep, child: const Text('Back')),
                      ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate() && selectedDate != null && !_takenDates.any((d) => d.year == selectedDate!.year && d.month == selectedDate!.month && d.day == selectedDate!.day)) {
                            nextStep();
                          }
                        },
                        child: const Text('Next'),
                      ),
                    ],
                  ),
                ] else if (currentStep == 2) ...[
                  // --- Step 3: Location, Size, Transport Cost ---
                  const Text('Project Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Project Location'),
                    onChanged: (v) {
                      setModalState(() {
                        location = v;
                        updateTransportCost();
                      });
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Project Size (e.g. 1000 sqm)'),
                    onChanged: (v) {
                      setModalState(() {
                        size = v;
                        updateTransportCost();
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  if (location.isNotEmpty && size.isNotEmpty)
                    Row(
                      children: [
                        const Text('Estimated Transport Cost: ', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(liveTransportCost != null ? '${liveTransportCost!.toStringAsFixed(2)} USD' : '--'),
                      ],
                    ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(onPressed: prevStep, child: const Text('Back')),
                      ElevatedButton(
                        onPressed: location.isNotEmpty && size.isNotEmpty
                          ? () {
                              // Save user info for next time (mock)
                              _savedName = _nameController.text;
                              _savedEmail = _emailController.text;
                              _savedPhone = _phoneController.text;
                              // Mock booking submission
                              Get.back();
                              Get.bottomSheet(
                                Container(
                                  padding: const EdgeInsets.all(30),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.check_circle, color: Colors.green, size: 60),
                                      const SizedBox(height: 20),
                                      const Text('Request Submitted!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                                      const SizedBox(height: 10),
                                      Text('We have received your request for a $selectedType project on ${selectedDate!.toLocal().toString().split(' ')[0]}. Our team will contact you soon.'),
                                      const SizedBox(height: 20),
                                      ElevatedButton(
                                        onPressed: () => Get.back(),
                                        child: const Text('Close'),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                          : null,
                        child: const Text('Submit'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }

  void _showProjectDetailsBottomSheet(Map<String, dynamic> project) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
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
              Text(project['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
              const SizedBox(height: 8),
              Chip(
                label: Text(project['status']),
                backgroundColor: _statusColor(project['status']),
                labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(project['description'], style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Iconsax.location, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(project['location'], style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  const Spacer(),
                  Text(project['date'], style: const TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
              if (project['progress'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: LinearProgressIndicator(
                    value: (project['progress'] as int) / 100,
                    backgroundColor: AppTheme.surfaceLight,
                    valueColor: AlwaysStoppedAnimation<Color>(_statusColor(project['status'])),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              const SizedBox(height: 24),
              Text('Last Update:', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
              Text(project['lastUpdate'] ?? 'No updates yet', style: const TextStyle(fontSize: 15)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Get.back(),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
} 