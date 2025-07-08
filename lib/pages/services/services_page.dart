import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kronium/core/app_theme.dart';

import 'package:video_player/video_player.dart';
import 'package:kronium/core/services_data.dart';
import 'package:kronium/core/user_auth_service.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  ServicesPageState createState() => ServicesPageState();
}

class ServicesPageState extends State<ServicesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> categories = ['All', ...servicesData.map((s) => s['category'] ?? '').toSet().where((c) => c != '').toList()];
  final RxString _searchQuery = ''.obs;
  final RxString _selectedSort = 'Popular'.obs;
  final List<String> sortOptions = ['Popular', 'Newest', 'Price: Low to High', 'Price: High to Low'];
  final RxString _selectedCategory = 'All'.obs;
  final RxBool _isAdmin = false.obs; // Set to true only for real admin users
  final RxMap<String, int> _serviceViews = <String, int>{}.obs;
  final RxMap<String, int> _serviceBookings = <String, int>{}.obs;
  String? _iconTapped;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _applySorting(List<Map<String, dynamic>> services) {
    switch (_selectedSort.value) {
      case 'Newest':
        return services..sort((a, b) => b['title'].compareTo(a['title']));
      case 'Price: Low to High':
        return services..sort((a, b) => (a['price'] ?? 0).compareTo(b['price'] ?? 0));
      case 'Price: High to Low':
        return services..sort((a, b) => (b['price'] ?? 0).compareTo(a['price'] ?? 0));
      case 'Popular':
      default:
        return services;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        leading: Navigator.canPop(context)
            ? IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: const Text('Our Services', 
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            fontSize: 20, 
                color: Colors.white)),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_alt, color: Colors.white, size: 20),
            onSelected: (value) => _selectedSort.value = value,
            itemBuilder: (BuildContext context) => sortOptions.map((String choice) {
              return PopupMenuItem<String>(
                value: choice,
                child: Text(choice),
              );
            }).toList(),
          ),
          Obx(() => _isAdmin.value
              ? IconButton(
                  icon: const Icon(Icons.analytics, color: Colors.white),
                  onPressed: _showAnalytics,
                )
              : const SizedBox()),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Container(
            color: AppTheme.primaryColor,
            child: Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search services...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) => _searchQuery.value = value,
                  ),
                ),
                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categories.map((cat) => Obx(() => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: _selectedCategory.value == cat,
                        onSelected: (selected) {
                          if (selected) _selectedCategory.value = cat;
                        },
                        selectedColor: Colors.white,
                        backgroundColor: Colors.white24,
                        labelStyle: TextStyle(
                          color: _selectedCategory.value == cat ? AppTheme.primaryColor : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ))).toList(),
                  ),
                ),
                const SizedBox(height: 10),
                Obx(() => _searchQuery.value.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Search results for "${_searchQuery.value}"',
                          style: const TextStyle(color: Colors.white),
                        ),
                      )
                    : const SizedBox()),
              ],
            ),
          ),
        ),
      ),
      body: Obx(() => _buildServiceList(_selectedCategory.value)),
    );
  }

  Widget _buildServiceList(String category) {
    List<Map<String, dynamic>> filteredServices = _searchQuery.value.isEmpty
          ? category == 'All' 
            ? servicesData 
            : servicesData.where((service) => service['category'] == category).toList()
        : servicesData.where((service) => 
            service['title'].toLowerCase().contains(_searchQuery.value.toLowerCase()) ||
            service['description'].toLowerCase().contains(_searchQuery.value.toLowerCase()))
              .toList();
      filteredServices = _applySorting(filteredServices);
      return filteredServices.isEmpty
          ? _buildEmptyState()
          : Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                ),
                itemCount: filteredServices.length,
                itemBuilder: (context, index) {
                return _serviceCardFromMap(filteredServices[index]);
                },
              ),
            );
  }

  Widget _serviceCardFromMap(Map<String, dynamic> service) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
      child: AnimatedOpacity(
        opacity: 1.0,
        duration: const Duration(milliseconds: 500),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.grey.withOpacity(0.12), width: 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                      SizedBox(
                        height: 80,
                          width: double.infinity,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              service['image'],
                          fit: BoxFit.cover,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.08),
                                    Colors.black.withOpacity(0.18),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
                Positioned(
                        left: 12,
                        top: 12,
                        child: GestureDetector(
                          onTapDown: (_) => setState(() => _iconTapped = service['title']),
                          onTapUp: (_) => setState(() => _iconTapped = null),
                          onTapCancel: () => setState(() => _iconTapped = null),
                          child: AnimatedScale(
                            scale: _iconTapped == service['title'] ? 1.15 : 1.0,
                            duration: const Duration(milliseconds: 120),
                    child: Container(
                      decoration: BoxDecoration(
                                color: _iconBgColor(service['category'], context),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.18),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(7),
                              child: Icon(
                                service['icon'],
                          color: Colors.white,
                                size: 28,
                        ),
                      ),
                    ),
                  ),
                      ),
                      if (service['category'] != null)
                        Positioned(
                          right: 10,
                          top: 10,
                          child: Chip(
                            label: Text(
                              service['category'],
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            backgroundColor: Theme.of(context).primaryColor,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                            visualDensity: VisualDensity.compact,
                    ),
                  ),
              ],
            ),
            Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
              child: Column(
                children: [
                  Text(
                          service['title'],
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.1),
                          textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                          service['description'],
                          style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.3),
                          textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                        const SizedBox(height: 6),
                  Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                            Tooltip(
                              message: 'Service details',
                              child: IconButton(
                                icon: const Icon(Icons.info_outline, color: Colors.blue, size: 18),
                                onPressed: () => _showServiceDetailsFromMap(service),
                              ),
                            ),
                            Tooltip(
                              message: 'Book service',
                              child: IconButton(
                                icon: const Icon(Icons.calendar_today, color: Colors.green, size: 18),
                                onPressed: () {
                                  if (userController.role.value == 'customer') {
                                    _showBookingFormBottomSheet(service);
                                  } else if (userController.role.value == 'guest') {
                                    _showGuestPrompt();
                                  }
                                },
                              ),
                            ),
                    ],
                  ),
                ],
              ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showServiceDetailsFromMap(Map<String, dynamic> service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.92,
        child: Container(
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF8FAFC), Color(0xFFE3E8EF)],
            ),
          ),
          child: SafeArea(
        child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
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
                    const SizedBox(height: 18),
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.network(
                            service['image'],
                            width: double.infinity,
                            height: 180,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          left: 16,
                          top: 16,
                          child: Container(
                            decoration: BoxDecoration(
                              color: _iconBgColor(service['category'], context),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.18),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(10),
                            child: Icon(
                              service['icon'],
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                        if (service['category'] != null)
                          Positioned(
                            right: 16,
                            top: 16,
                            child: Chip(
                              label: Text(
                                service['category'],
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              backgroundColor: Theme.of(context).primaryColor,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                              visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      service['title'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      service['description'],
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                    onPressed: () {
                              Navigator.of(context).pop();
                              _showBookingFormBottomSheet(service);
                            },
                            icon: const Icon(Icons.calendar_today, color: Colors.white),
                            label: const Text('Book Now', style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[700],
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showBookingFormBottomSheet(Map<String, dynamic> service) {
    final _formKey = GlobalKey<FormState>();
    String name = '';
    String email = '';
    String phone = '';
    String details = '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.85,
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF8FAFC), Color(0xFFE3E8EF)],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 24, right: 24, top: 24,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: Form(
                  key: _formKey,
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
                      const SizedBox(height: 18),
                      Text(
                        'Book ${service['title']}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Name'),
                        validator: (v) => v == null || v.isEmpty ? 'Enter your name' : null,
                        onSaved: (v) => name = v ?? '',
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Email'),
                        validator: (v) => v == null || !v.contains('@') ? 'Enter a valid email' : null,
                        onSaved: (v) => email = v ?? '',
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Phone'),
                        validator: (v) => v == null || v.length < 7 ? 'Enter a valid phone' : null,
                        onSaved: (v) => phone = v ?? '',
                      ),
                      TextFormField(
                        initialValue: service['title'],
                        decoration: const InputDecoration(labelText: 'Service'),
                        enabled: false,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Details'),
                        maxLines: 3,
                        onSaved: (v) => details = v ?? '',
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              _formKey.currentState?.save();
                              _serviceBookings[service['title']] = (_serviceBookings[service['title']] ?? 0) + 1;
                              Navigator.of(context).pop();
                              _showBookingSuccessBottomSheet(service['title']);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Submit Booking', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showBookingSuccessBottomSheet(String serviceTitle) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.45,
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF8FAFC), Color(0xFFE3E8EF)],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 24),
                  Icon(Icons.check_circle, color: Colors.green, size: 60),
                  const SizedBox(height: 18),
                  Text('Booking for "$serviceTitle" submitted!',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text('We will contact you soon.',
                    style: TextStyle(fontSize: 15, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddServiceDialog() {
    // For demo: just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Admin: Add Service feature coming soon!')),
    );
  }

  void _showAnalytics() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Service Analytics'),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Most Viewed Services:'),
              ...(_serviceViews.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value)))
                .take(3)
                .map((e) => Text('${e.key}: ${e.value} views'))
                .toList(),
              const SizedBox(height: 16),
              const Text('Most Booked Services:'),
              ...(_serviceBookings.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value)))
                .take(3)
                .map((e) => Text('${e.key}: ${e.value} bookings'))
                .toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            _searchQuery.value.isEmpty
                ? 'No services available in this category'
                : 'No services found for "${_searchQuery.value}"',
            style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              _searchQuery.value = '';
              _selectedCategory.value = 'All';
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('View All Services', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Color _iconBgColor(String? category, BuildContext context) {
    switch (category) {
      case 'Agriculture':
        return Colors.green.shade700;
      case 'Water Solutions':
        return Colors.blue.shade600;
      case 'Drilling':
        return Colors.brown.shade400;
      case 'Energy':
        return Colors.orange.shade700;
      case 'Pumps':
        return Colors.teal.shade700;
      default:
        return Theme.of(context).primaryColor.withOpacity(0.92);
    }
  }

  void _showGuestPrompt() {
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
            const Icon(Iconsax.login, color: Colors.orange, size: 60),
            const SizedBox(height: 20),
            const Text('Sign Up or Log In Required', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
            const SizedBox(height: 10),
            const Text('You need an account to book a service or request a project.'),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => Get.toNamed('/customer-login'),
                  child: const Text('Log In'),
                ),
                OutlinedButton(
                  onPressed: () => Get.toNamed('/customer-register'),
                  child: const Text('Sign Up'),
                ),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}

class _VideoThumbnail extends StatelessWidget {
  final String videoUrl;

  const _VideoThumbnail({required this.videoUrl});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 120,
          width: double.infinity,
          color: Colors.black,
          child: const Center(
            child: Icon(
              Icons.play_circle_filled,
              color: Colors.white,
              size: 50,
            ),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.7),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const _VideoPlayerWidget({required this.videoUrl});

  @override
  __VideoPlayerWidgetState createState() => __VideoPlayerWidgetState();
}

class __VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: _controller.value.isInitialized
          ? _controller.value.aspectRatio
          : 16 / 9,
      child: Stack(
        alignment: Alignment.center,
        children: [
          VideoPlayer(_controller),
          if (!_controller.value.isInitialized)
            const CircularProgressIndicator()
          else
            GestureDetector(
              onTap: () {
                setState(() {
                  _isPlaying = !_isPlaying;
                  _isPlaying ? _controller.play() : _controller.pause();
                });
              },
              child: Container(
                color: Colors.transparent,
                child: Center(
                  child: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}