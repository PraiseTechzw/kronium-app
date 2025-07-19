import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kronium/core/app_theme.dart';
import 'package:kronium/models/service_model.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kronium/core/constants.dart';
import 'package:kronium/widgets/background_switcher.dart';
import 'package:intl/intl.dart';
import 'package:kronium/core/user_auth_service.dart' show userController, UserAuthService;
import 'package:kronium/core/firebase_service.dart';
import 'package:kronium/models/booking_model.dart';

/// Keep this widget focused and readable. Extend as needed.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Mock testimonials (replace with real data as needed)

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> _companySlides = AppConstants.companySlidesData;
    int _currentSlide = 0;
    final CarouselSliderController _carouselController = CarouselSliderController();
   
    final List<Map<String, dynamic>> _services = [
      {
        'title': 'Greenhouse Construction',
        'image': 'assets/images/services/Greenhouse.jpg',
      },
      {
        'title': 'Construction',
        'image': 'assets/images/services/construction.jpg',
      },
      {
        'title': 'Solar Systems',
        'image': 'assets/images/services/solar.png',
      },
      {
        'title': 'Irrigation Systems',
        'image': 'assets/images/services/irrigation.jpg',
      },
      {
        'title': 'Logistics',
        'image': 'assets/images/services/logistics.png',
      },
      {
        'title': 'IoT & Automation Projects',
        'image': 'assets/images/services/Iot.png',
      },
    ];
    return BackgroundSwitcher(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Company Info Carousel (Enhanced)
                StatefulBuilder(
                  builder: (context, setState) => Column(
                    children: [
                      CarouselSlider(
                        carouselController: _carouselController,
                        options: CarouselOptions(
                          height: 240,
                          autoPlay: true,
                          enlargeCenterPage: true,
                          viewportFraction: 0.95,
                          aspectRatio: 16/7,
                          autoPlayInterval: const Duration(seconds: 6),
                          onPageChanged: (index, reason) => setState(() => _currentSlide = index),
                        ),
                        items: _companySlides.map((slide) {
                          return Builder(
                            builder: (context) => Container(
                              width: MediaQuery.of(context).size.width,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                gradient: LinearGradient(
                                  colors: [AppTheme.primaryColor, AppTheme.secondaryColor.withOpacity(0.85)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryColor.withOpacity(0.13),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        if (slide['logo'] != null)
                                          Padding(
                                            padding: const EdgeInsets.only(right: 12),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: Image.asset(
                                                slide['logo'],
                                                width: 40,
                                                height: 40,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        if (slide['icon'] != null)
                                          Icon(slide['icon'], color: Colors.white, size: 32),
                                        if (slide['icon'] != null) const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              if (slide['title'] != null)
                                                Text(
                                                  slide['title'],
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20,
                                                    letterSpacing: 0.5,
                                                    shadows: [Shadow(blurRadius: 8, color: Colors.black26)],
                                                  ),
                                                ),
                                              if (slide['subtitle'] != null)
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 2.0),
                                                  child: Text(
                                                    slide['subtitle'],
                                                    style: const TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    if (slide['body'] != null && slide['body'] is String)
                                      Expanded(
                                        child: SingleChildScrollView(
                                          child: Text(
                                            slide['body'],
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (slide['body'] != null && slide['body'] is List)
                                      Expanded(
                                        child: SingleChildScrollView(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              for (var item in slide['body'])
                                                if (item is String)
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 2.5),
                                                    child: Row(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        const Icon(Icons.circle, size: 8, color: Colors.white70),
                                                        const SizedBox(width: 8),
                                                        Expanded(
                                                          child: Text(
                                                            item,
                                                            style: const TextStyle(
                                                              color: Colors.white,
                                                              fontSize: 15,
                                                              fontWeight: FontWeight.w400,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                else if (item is Map && item['type'] == 'phone')
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 2.5),
                                                    child: GestureDetector(
                                                      onTap: () => launchUrl(Uri.parse('tel:${item['value']}')),
                                                      child: Row(
                                                        children: [
                                                          const Icon(Icons.phone, size: 16, color: Colors.white),
                                                          const SizedBox(width: 8),
                                                          Text(
                                                            item['value'],
                                                            style: const TextStyle(
                                                              color: Colors.white,
                                                              fontSize: 15,
                                                              decoration: TextDecoration.underline,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                else if (item is Map && item['type'] == 'email')
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 2.5),
                                                    child: GestureDetector(
                                                      onTap: () => launchUrl(Uri.parse('mailto:${item['value']}')),
                                                      child: Row(
                                                        children: [
                                                          const Icon(Icons.email, size: 16, color: Colors.white),
                                                          const SizedBox(width: 8),
                                                          Text(
                                                            item['value'],
                                                            style: const TextStyle(
                                                              color: Colors.white,
                                                              fontSize: 15,
                                                              decoration: TextDecoration.underline,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                else if (item is Map && item['type'] == 'address')
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 2.5),
                                                    child: Row(
                                                      children: [
                                                        const Icon(Icons.location_on, size: 16, color: Colors.white),
                                                        const SizedBox(width: 8),
                                                        Expanded(
                                                          child: Text(
                                                            item['value'],
                                                            style: const TextStyle(
                                                              color: Colors.white,
                                                              fontSize: 15,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    if (slide['socials'] != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: Row(
                                          children: [
                                            for (var social in slide['socials'])
                                              IconButton(
                                                icon: Icon(social['icon'], color: Colors.white, size: 22),
                                                onPressed: () => launchUrl(Uri.parse(social['url'])),
                                              ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_companySlides.length, (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: _currentSlide == index ? 18 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentSlide == index ? Colors.white : Colors.white38,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        )),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Rotating Banner (Carousel)
                
                const SizedBox(height: 24),
                // Services/Projects List (Grid)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                  ),
                  itemCount: _services.length,
                  itemBuilder: (context, index) {
                    final service = _services[index];
                    return GestureDetector(
                      onTap: () => _onServiceTap(context, service),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              service['image'],
                              fit: BoxFit.cover,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.6),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomLeft,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                              service['title'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black54,
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        ),
                      ),
                    );
                  },
                ),
                ContactCard(
                  contacts: _companySlides.firstWhere((s) => s['title'] == 'CONTACT & OFFICES')['body'],
                  socials: _companySlides.firstWhere((s) => s['title'] == 'CONTACT & OFFICES')['socials'],
                ),
              ],
            ),
          ),
        ),
    );
  }

  void _onServiceTap(BuildContext context, Map<String, dynamic> service) {
    if (service['title'] == 'IoT & Automation Projects') {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => FractionallySizedBox(
          heightFactor: 0.75, // 75% of screen height
          child: Container(
            padding: const EdgeInsets.all(32),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Iconsax.cpu, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text('IoT & Automation Projects', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                SizedBox(height: 10),
                Text('Coming Soon!', style: TextStyle(fontSize: 16, color: Colors.grey)),
              ],
            ),
          ),
        ),
      );
    } else {
      final Service? detail = Service.getAllServices().firstWhereOrNull((s) => s.title == service['title']);
      if (detail == null) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) => FractionallySizedBox(
            heightFactor: 0.75,
            child: Container(
              padding: const EdgeInsets.all(32),
              child: Text('Service details not found.'),
            ),
          ),
        );
        return;
      }
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => FractionallySizedBox(
          heightFactor: 0.75,
          child: _ServiceDetailSheet(service: detail),
        ),
      );
    }
  }
}

// Full service detail sheet using the Service model and layout from services_page.dart
class _ServiceDetailSheet extends StatelessWidget {
  final Service service;
  const _ServiceDetailSheet({required this.service});
  @override
  Widget build(BuildContext context) {
    final isAdmin = userController.role.value == 'admin';
    final List<String> missing = [];
    if (isAdmin) {
      if (service.description.isEmpty) missing.add('Description');
      if (service.features.isEmpty) missing.add('Features');
      if (service.price == null) missing.add('Price');
    }
    return Stack(
      children: [
        Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                if (isAdmin && missing.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning, color: Colors.orange, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Missing info: ${missing.join(', ')}',
                            style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                // Large rounded image at the top
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: service.imageUrl != null
                      ? Image.asset(
                          service.imageUrl!,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: double.infinity,
                          height: 200,
                          color: Colors.grey[200],
                          child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and category
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.title,
                        style: const TextStyle(
                                    fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                                if (service.category.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                        service.category,
                                      style: const TextStyle(
                                        color: Colors.green,
                          fontWeight: FontWeight.bold,
                                        fontSize: 13,
                        ),
                  ),
                ),
              ],
            ),
                          ),
                          // Modern close button
                          IconButton(
                            icon: const Icon(Icons.close, size: 26),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      // Overview
            const Text(
              'Service Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
                      const SizedBox(height: 8),
            Text(
              service.description,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
                      const SizedBox(height: 18),
                      // Features
                      if (service.features.isNotEmpty) ...[
            const Text(
              'Key Features',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
                        const SizedBox(height: 8),
            Column(
              children: service.features.map((feature) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        feature,
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
                        const SizedBox(height: 18),
                      ],
                      // Pricing & Booking
            const Text(
              'Pricing & Booking',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
                      const SizedBox(height: 8),
            _detailItem(Icons.attach_money, 'Starting Price',
                        service.price != null ? '\$${service.price}' : 'Contact for quote'),
            _detailItem(Icons.schedule, 'Duration', '2-6 weeks'),
            _detailItem(Icons.event_available, 'Availability', 'Next 2 weeks'),
            const SizedBox(height: 30),
                      // Action button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Iconsax.calendar, color: Colors.white),
                          label: const Text('Book Service', style: TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                            showModalBottomSheet(
                              context: Get.context!,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                              ),
                              builder: (context) => ServiceBookingForm(service: service),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ],
            ),
        ),
      ),
      ],
    );
  }

  Widget _detailItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppTheme.primaryColor),
          const SizedBox(width: 10),
          SizedBox(
            width: 120,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class ServiceBookingForm extends StatefulWidget {
  final Service service;
  const ServiceBookingForm({required this.service});
  @override
  State<ServiceBookingForm> createState() => _ServiceBookingFormState();
}

class _ServiceBookingFormState extends State<ServiceBookingForm> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _sizeController = TextEditingController();
  DateTime? _selectedDate;
  bool _isLoading = false;
  List<DateTime> _bookedDates = [];

  @override
  void initState() {
    super.initState();
    _fetchBookedDates();
  }

  Future<void> _fetchBookedDates() async {
    final bookings = await FirebaseService.instance.getBookings().first;
    setState(() {
      _bookedDates = bookings
        .where((b) => b.serviceName == widget.service.title)
        .map((b) => DateTime(b.date.year, b.date.month, b.date.day))
        .toList();
    });
  }

  bool _isDateBooked(DateTime date) {
    return _bookedDates.any((d) => d.year == date.year && d.month == date.month && d.day == date.day);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Calendar picker
            Text('Select Project Date', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  selectableDayPredicate: (date) => !_isDateBooked(date),
                );
                if (picked != null) setState(() => _selectedDate = picked);
              },
              child: Text(_selectedDate == null
                  ? 'Pick a date'
                  : DateFormat('yMMMd').format(_selectedDate!)),
            ),
            const SizedBox(height: 16),
            // Location
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Project Location',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Enter location' : null,
            ),
            const SizedBox(height: 16),
            // Size
            TextFormField(
              controller: _sizeController,
              decoration: const InputDecoration(
                labelText: 'Project Size (e.g., sqm)',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Enter size' : null,
            ),
            const SizedBox(height: 16),
            // Transport cost (set by admin)
            Text(
              'Transport Cost: ${widget.service.price != null ? '\$${widget.service.price}' : 'Contact admin'}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 24),
            // Submit
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                        if (!_formKey.currentState!.validate() || _selectedDate == null) return;
                        setState(() => _isLoading = true);
                        final booking = Booking(
                          serviceName: widget.service.title,
                          clientName: '', // Fill from user profile if available
                          clientEmail: '',
                          clientPhone: '',
                          date: _selectedDate!,
                          status: BookingStatus.pending,
                          price: widget.service.price ?? 0.0,
                          location: _locationController.text.trim(),
                          notes: 'Size: ${_sizeController.text.trim()}',
                        );
                        await FirebaseService.instance.addBooking(booking);
                        setState(() => _isLoading = false);
                        Get.snackbar('Success', 'Booking submitted!');
                        Navigator.of(context).pop();
                      },
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Submit Booking'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ContactCard extends StatelessWidget {
  final List<Map<String, dynamic>> contacts;
  final List<Map<String, dynamic>>? socials;
  const ContactCard({required this.contacts, this.socials, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      color: AppTheme.primaryColor.withOpacity(0.80),
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.contact_phone_outlined, color: Colors.white, size: 28),
                const SizedBox(width: 10),
                const Text(
                  'Contact & Offices',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...contacts.map((item) {
              if (item['type'] == 'phone') {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: GestureDetector(
                    onTap: () => launchUrl(Uri.parse('tel:${item['value']}')),
                    child: Row(
                      children: [
                        const Icon(Icons.phone, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          item['value'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else if (item['type'] == 'email') {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: GestureDetector(
                    onTap: () => launchUrl(Uri.parse('mailto:${item['value']}')),
                    child: Row(
                      children: [
                        const Icon(Icons.email, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          item['value'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else if (item['type'] == 'address') {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item['value'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }).toList(),
            if (socials != null && socials!.isNotEmpty) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  for (var social in socials!)
                    IconButton(
                      icon: Icon(social['icon'], color: Colors.white, size: 22),
                      onPressed: () => launchUrl(Uri.parse(social['url'])),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
} 