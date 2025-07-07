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

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  ServicesPageState createState() => ServicesPageState();
}

class ServicesPageState extends State<ServicesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> categories = ['All', 'Construction', 'Renewable Energy', 'Agriculture', 'Technology'];
  final RxString _searchQuery = ''.obs;
  final RxList<String> _favorites = <String>[].obs;
  final RxString _selectedSort = 'Popular'.obs;
  final List<String> sortOptions = ['Popular', 'Newest', 'Price: Low to High', 'Price: High to Low'];

  final List<Service> services = [
    Service(
      id: '1',
      title: 'Greenhouse Construction',
      category: 'Agriculture',
      icon: FontAwesomeIcons.warehouse,
      color: const Color(0xFF2ECC71),
      description: 'Professional greenhouse design and construction for optimal plant growth',
      features: [
        'Custom sizing options',
        'Climate control systems',
        'Durable polycarbonate materials',
        '5-year warranty'
      ],
      imageUrl: 'assets/images/greenhouse.jpg',
      price: 3500,
      videoUrl: 'https://example.com/greenhouse-video.mp4',
    ),
    Service(
      id: '2',
      title: 'Solar Panel Installation',
      category: 'Renewable Energy',
      icon: FontAwesomeIcons.solarPanel,
      color: const Color(0xFFF39C12),
      description: 'Complete solar energy solutions for homes and businesses',
      features: [
        'Residential & commercial systems',
        'Battery storage options',
        'Government rebate assistance',
        '25-year performance guarantee'
      ],
      imageUrl: 'assets/images/solar.jpg',
      price: 8500,
    ),
    Service(
      id: '3',
      title: 'Steel Structures',
      category: 'Construction',
      icon: FontAwesomeIcons.building,
      color: const Color(0xFF3498DB),
      description: 'Durable steel buildings for commercial and industrial use',
      features: [
        'Custom engineering',
        'Quick assembly',
        'Low maintenance',
        '30+ year lifespan'
      ],
      imageUrl: 'assets/images/steel.jpg',
      price: 12500,
      videoUrl: 'https://example.com/steel-structures-video.mp4',
    ),
  ];

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

  List<Service> _applySorting(List<Service> services) {
    switch (_selectedSort.value) {
      case 'Newest':
        return services..sort((a, b) => b.title.compareTo(a.title));
      case 'Price: Low to High':
        return services..sort((a, b) => (a.price ?? 0).compareTo(b.price ?? 0));
      case 'Price: High to Low':
        return services..sort((a, b) => (b.price ?? 0).compareTo(a.price ?? 0));
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
                onPressed: () => Get.back(),
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
            icon: const Icon(FontAwesomeIcons.filter, color: Colors.white, size: 20),
            onSelected: (value) => _selectedSort.value = value,
            itemBuilder: (BuildContext context) => sortOptions.map((String choice) {
              return PopupMenuItem<String>(
                value: choice,
                child: Text(choice),
              );
            }).toList(),
          ),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.search, size: 20, color: Colors.white),
            onPressed: _showAdvancedSearchDialog,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Container(
            color: AppTheme.primaryColor,
            child: Column(
              children: [
                FadeInDown(
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white70,
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white.withOpacity(0.2),
                      ),
                      tabs: categories.map((category) => Tab(text: category)).toList(),
                    ),
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
      body: TabBarView(
        controller: _tabController,
        children: categories.map((category) {
          return _buildServiceList(category);
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.bookProject),
        icon: const FaIcon(FontAwesomeIcons.calendarPlus, size: 20, color: Colors.white),
        label: const Text('Book Service', style: TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildServiceList(String category) {
    return Obx(() {
      List<Service> filteredServices = _searchQuery.value.isEmpty
          ? category == 'All' 
              ? services 
              : services.where((service) => service.category == category).toList()
          : services.where((service) => 
              service.title.toLowerCase().contains(_searchQuery.value.toLowerCase()) ||
              service.description.toLowerCase().contains(_searchQuery.value.toLowerCase()))
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
                  return _serviceCard(filteredServices[index]);
                },
              ),
            );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/search_empty.json',
            width: 200,
            height: 200,
          ),
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
              _tabController.animateTo(0);
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

  Widget _serviceCard(Service service) {
    return HoverWidget(
      hoverChild: Transform.translate(
        offset: const Offset(0, -5),
        child: _buildServiceCardContent(service, true),
      ),
      onHover: (event) {},
      child: _buildServiceCardContent(service, false),
    );
  }

  Widget _buildServiceCardContent(Service service, bool isHover) {
    return GestureDetector(
      onTap: () => _showServiceDetails(service),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.shadow,
              blurRadius: isHover ? 15 : 8,
              spreadRadius: 1,
              offset: const Offset(0, 5),
            ),
          ],
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              service.color.withOpacity(0.13),
              AppTheme.surfaceLight,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Decorative background circle
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: service.color.withOpacity(0.08),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: service.videoUrl != null
                          ? _VideoThumbnail(videoUrl: service.videoUrl!)
                          : Image.asset(
                              service.imageUrl ?? 'assets/images/logo.jpg',
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Obx(() => IconButton(
                        icon: FaIcon(
                          _favorites.contains(service.title)
                              ? FontAwesomeIcons.solidHeart
                              : FontAwesomeIcons.heart,
                          color: _favorites.contains(service.title)
                              ? Colors.red
                              : AppTheme.primaryColor,
                        ),
                        onPressed: () {
                          if (_favorites.contains(service.title)) {
                            _favorites.remove(service.title);
                          } else {
                            _favorites.add(service.title);
                          }
                        },
                      )),
                    ),
                    if (service.price != null)
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'From \$${service.price}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    if (service.videoUrl != null)
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: service.color.withOpacity(0.13),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          service.category,
                          style: TextStyle(
                            fontSize: 12,
                            color: service.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        service.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        service.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Learn More',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: service.color,
                            ),
                          ),
                          FaIcon(
                            FontAwesomeIcons.arrowRight,
                            size: 14,
                            color: service.color,
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
    );
  }

  void _showAdvancedSearchDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search services...',
                  prefixIcon: const FaIcon(FontAwesomeIcons.search, size: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) => _searchQuery.value = value,
              ),
              const SizedBox(height: 15),
              Obx(() => DropdownButtonFormField<String>(
                value: _selectedSort.value,
                decoration: InputDecoration(
                  labelText: 'Sort by',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: sortOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) => _selectedSort.value = value!,
              )),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                    ),
                    child: const Text('Search', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showServiceDetails(Service service) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
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
                      color: service.color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: FaIcon(
                      service.icon,
                      color: service.color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          service.category,
                          style: TextStyle(
                            fontSize: 14,
                            color: service.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Obx(() => IconButton(
                    icon: FaIcon(
                      _favorites.contains(service.title) 
                        ? FontAwesomeIcons.solidHeart 
                        : FontAwesomeIcons.heart,
                      color: _favorites.contains(service.title) 
                        ? Colors.red 
                        : Colors.grey,
                    ),
                    onPressed: () {
                      if (_favorites.contains(service.title)) {
                        _favorites.remove(service.title);
                      } else {
                        _favorites.add(service.title);
                      }
                    },
                  )),
                ],
              ),
              const SizedBox(height: 20),
              if (service.videoUrl != null) ...[
                _VideoPlayerWidget(videoUrl: service.videoUrl!),
                const SizedBox(height: 20),
              ] else ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    service.imageUrl ?? 'assets/images/logo.jpg',
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20),
              ],
              const Text(
                'Service Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                service.description,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),
              const Text(
                'Key Features',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Column(
                children: service.features.map((feature) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FaIcon(FontAwesomeIcons.checkCircle, size: 18, color: service.color),
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
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),
              const Text(
                'Pricing & Booking',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _detailItem(FontAwesomeIcons.moneyBillWave, 'Starting Price', 
                service.price != null ? '\$${service.price}' : 'Contact for quote'),
              _detailItem(FontAwesomeIcons.clock, 'Duration', '2-6 weeks'),
              _detailItem(FontAwesomeIcons.calendarCheck, 'Availability', 'Next 2 weeks'),
              if (service.videoUrl != null) ...[
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 10),
                const Text(
                  'Video Demonstration',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                _detailItem(FontAwesomeIcons.video, 'Video Link', service.videoUrl!),
              ],
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
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
                        Get.back();
                        Get.toNamed(
                          AppRoutes.bookProject, 
                          arguments: service
                        );
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
    );
  }

  Widget _detailItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FaIcon(icon, size: 18, color: AppTheme.primaryColor),
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