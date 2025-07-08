import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kronium/core/app_theme.dart';
import 'package:kronium/core/routes.dart';
import 'package:kronium/models/service_model.dart';
import 'package:kronium/widgets/hover_widget.dart';

import 'package:lottie/lottie.dart';
import 'package:video_player/video_player.dart';
import 'package:kronium/core/services_data.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  ServicesPageState createState() => ServicesPageState();
}

class ServicesPageState extends State<ServicesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> categories = ['All', ...servicesData.map((s) => s['category'] ?? '').toSet().where((c) => c != '').toList()];
  final RxString _searchQuery = ''.obs;
  final RxList<String> _favorites = <String>[].obs;
  final RxString _selectedSort = 'Popular'.obs;
  final List<String> sortOptions = ['Popular', 'Newest', 'Price: Low to High', 'Price: High to Low'];
  final RxString _selectedCategory = 'All'.obs;
  final RxBool _isAdmin = false.obs; // Set to true only for real admin users
  final RxMap<String, int> _serviceViews = <String, int>{}.obs;
  final RxMap<String, int> _serviceBookings = <String, int>{}.obs;

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
      floatingActionButton: Obx(() => _isAdmin.value
          ? FloatingActionButton.extended(
              onPressed: _showAddServiceDialog,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Add Service', style: TextStyle(color: Colors.white)),
              backgroundColor: AppTheme.primaryColor,
            )
          : FloatingActionButton.extended(
              onPressed: () => _showBookingForm(context, null),
              icon: const Icon(Icons.calendar_today, color: Colors.white),
        label: const Text('Book Service', style: TextStyle(color: Colors.white)),
              backgroundColor: AppTheme.primaryColor,
            )),
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
                  childAspectRatio: 0.9, 
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
    return GestureDetector(
      onTap: () {
        _serviceViews[service['title']] = (_serviceViews[service['title']] ?? 0) + 1;
        _showServiceDetailsFromMap(service);
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    service['image'],
                    height: 70,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  bottom: 4,
                  child: CircleAvatar(
                    backgroundColor: Colors.white70,
                    radius: 18,
                    child: Icon(service['icon'], color: Theme.of(context).primaryColor, size: 22),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
              child: Column(
                children: [
                  Text(
                    service['title'],
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    service['description'],
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(_favorites.contains(service['title']) ? Icons.favorite : Icons.favorite_border, color: Colors.red, size: 18),
                        onPressed: () {
                        setState(() {
                          if (_favorites.contains(service['title'])) {
                            _favorites.remove(service['title']);
                          } else {
                            _favorites.add(service['title']);
                          }
                        });
                      },
                      ),
                      IconButton(
                        icon: const Icon(Icons.info_outline, color: Colors.blue, size: 18),
                        onPressed: () => _showServiceDetailsFromMap(service),
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today, color: Colors.green, size: 18),
                        onPressed: () => _showBookingForm(context, service),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showServiceDetailsFromMap(Map<String, dynamic> service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.85,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SafeArea(
            child: SingleChildScrollView(
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                        child: Icon(
                          service['icon'],
                          color: Theme.of(context).primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                              service['title'],
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                            if (service['category'] != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                                  service['category'],
                          style: TextStyle(
                            fontSize: 14,
                                    color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                        ),
                          ),
                        ),
                      ],
                    ),
                  ),
                    ],
                    ),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      service['image'],
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20),
              const Text(
                'Service Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                    service['description'],
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('BACK TO SERVICES'),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                            Navigator.of(context).pop();
                            _showBookingForm(context, service);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'BOOK NOW',
                        style: TextStyle(color: Colors.white),
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
    );
  }

  void _showBookingForm(BuildContext context, Map<String, dynamic>? service) {
    final _formKey = GlobalKey<FormState>();
    String name = '';
    String email = '';
    String phone = '';
    String details = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(service != null ? 'Book ${service['title']}' : 'Book a Service'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (v) => v == null || v.isEmpty ? 'Enter your name' : null,
                  onSaved: (v) => name = v ?? '',
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (v) => v == null || !v.contains('@') ? 'Enter a valid email' : null,
                  onSaved: (v) => email = v ?? '',
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Phone'),
                  validator: (v) => v == null || v.length < 7 ? 'Enter a valid phone' : null,
                  onSaved: (v) => phone = v ?? '',
                ),
                if (service != null)
                  TextFormField(
                    initialValue: service['title'],
                    decoration: const InputDecoration(labelText: 'Service'),
                    enabled: false,
                  ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Details'),
                  maxLines: 3,
                  onSaved: (v) => details = v ?? '',
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                _formKey.currentState?.save();
                if (service != null) {
                  _serviceBookings[service['title']] = (_serviceBookings[service['title']] ?? 0) + 1;
                }
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Booking submitted! We will contact you soon.')),
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
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