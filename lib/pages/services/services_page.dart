import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kronium/core/app_theme.dart';

import 'package:kronium/core/user_auth_service.dart' show UserAuthService;
import 'package:kronium/core/supabase_service.dart';
import 'package:kronium/models/service_model.dart';
import 'package:kronium/models/booking_model.dart';
import 'package:kronium/core/user_controller.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  ServicesPageState createState() => ServicesPageState();
}

class ServicesPageState extends State<ServicesPage>
    with TickerProviderStateMixin {
  final RxString _searchQuery = ''.obs;
  final RxString _selectedSort = 'Popular'.obs;
  final List<String> sortOptions = [
    'Popular',
    'Newest',
    'Price: Low to High',
    'Price: High to Low',
  ];

  // Home screen services that should appear first
  static const List<String> _homeScreenServices = [
    'Greenhouse Construction',
    'Solar Systems',
    'Construction',
    'Irrigation Systems',
    'IoT Solutions',
    'Logistics',
  ];

  late AnimationController _searchAnimationController;
  late AnimationController _titleAnimationController;
  late Animation<double> _searchScaleAnimation;
  late Animation<double> _titleSlideAnimation;

  @override
  void initState() {
    super.initState();
    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _titleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _searchScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _searchAnimationController,
        curve: Curves.easeOutBack,
      ),
    );

    _titleSlideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _titleAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _titleAnimationController.forward();

    // Listen to search query changes for animations
    ever(_searchQuery, (query) {
      if (query.isNotEmpty) {
        _searchAnimationController.forward();
      } else {
        _searchAnimationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _searchAnimationController.dispose();
    _titleAnimationController.dispose();
    super.dispose();
  }

  List<Service> _getHardcodedServices() {
    return [
      Service(
        id: '1',
        title: 'Greenhouse Construction',
        category: 'Agriculture',
        icon: Icons.warehouse,
        color: const Color(0xFF2ECC71),
        description:
            'Professional greenhouse design and construction for optimal plant growth',
        features: [
          'Customised sizing options',
          'Wooden / Metal structure frame',
          'Drip irrigation system',
          'Fertigation system',
          'Ventilation curtain design',
          '40% shadenet',
          'Bolt and nut linkages',
          '200micron greenhouse plastic / 40% shadenet',
          'Curiosite treated gumpoles / painted steel round tubes',
          'Greenhouse Types: Wooden, Hybrid (Wooden/Metal), Metal, Netshade',
        ],
        imageUrl: 'assets/images/services/Greenhouse.jpg',
        price: 3500,
      ),
      Service(
        id: '2',
        title: 'Solar Systems',
        category: 'Energy',
        icon: Icons.solar_power,
        color: const Color(0xFFF1C40F),
        description:
            'Domestic, industrial and commercial solar systems design and installation to ensure all your farm, home or business process run smoothly without any power outages',
        features: [
          'Domestic solar systems',
          'Industrial solar systems',
          'Commercial solar systems',
          'Design and installation',
          'Power outage prevention',
        ],
        imageUrl: 'assets/images/services/solar.jpg',
        price: 8000,
      ),
      Service(
        id: '3',
        title: 'Construction',
        category: 'Building',
        icon: Icons.home_work,
        color: const Color(0xFFE67E22),
        description:
            'Professional building and construction service with inclusion of structure plans, 3D models and rendering',
        features: [
          'Structure Types: Modern Houses, Animal Shelter, Farm Structures',
        ],
        imageUrl: 'assets/images/services/construction.jpg',
        price: 5000,
      ),
      Service(
        id: '4',
        title: 'Irrigation Systems',
        category: 'Agriculture',
        icon: Icons.water_drop,
        color: const Color(0xFF3498DB),
        description:
            'Professional irrigation design and installation for optimal plant health and growth',
        features: [
          'Customised design',
          'Pipe network',
          'Valves',
          'All necessary accessories',
          'Irrigation Types: Drip, Rainpipe, Centre pivots',
        ],
        imageUrl: 'assets/images/services/irrigation.jpg',
        price: 2500,
      ),
      Service(
        id: '5',
        title: 'IoT Solutions',
        category: 'Technology',
        icon: Icons.devices,
        color: const Color(0xFF9B59B6),
        description:
            'Smart technology solutions for agricultural automation and monitoring',
        features: [
          'Smart sensors',
          'Automated monitoring',
          'Data analytics',
          'Remote control systems',
          'Integration services',
        ],
        imageUrl: 'assets/images/services/Iot.png',
        price: 4000,
      ),
      Service(
        id: '6',
        title: 'Logistics',
        category: 'Transport',
        icon: Icons.local_shipping,
        color: const Color(0xFF34495E),
        description:
            'Professional transport and logistics provision for carrying your farm produce to the market from your farm',
        features: [
          'Farm to market transport',
          'Professional logistics',
          'Produce transportation',
          'Reliable delivery service',
        ],
        imageUrl: 'assets/images/services/logistics.png',
        price: 1500,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();
    final isAdmin = userController.role.value == 'admin';
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
        ),
        title: AnimatedBuilder(
          animation: _titleSlideAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 30 * (1 - _titleSlideAnimation.value)),
              child: Opacity(
                opacity: _titleSlideAnimation.value,
                child: const Text(
                  'Our Services',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.white,
                    letterSpacing: 1.2,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        centerTitle: true,
        actions: [
          if (isAdmin)
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1000),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Iconsax.add,
                        color: Colors.white,
                        size: 24,
                      ),
                      tooltip: 'Add Service',
                      onPressed: () {
                        // TODO: Implement add service
                      },
                    ),
                  ),
                );
              },
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                // Enhanced Search Bar
                AnimatedBuilder(
                  animation: _searchScaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _searchScaleAnimation.value,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search for services...',
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            prefixIcon: Container(
                              margin: const EdgeInsets.all(8),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Iconsax.search_normal,
                                color: AppTheme.primaryColor,
                                size: 22,
                              ),
                            ),
                            suffixIcon:
                                _searchQuery.value.isNotEmpty
                                    ? Container(
                                      margin: const EdgeInsets.all(8),
                                      child: IconButton(
                                        onPressed:
                                            () => _searchQuery.value = '',
                                        icon: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.close,
                                            size: 16,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                    )
                                    : null,
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 18,
                              horizontal: 20,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                          ),
                          onChanged: (value) => _searchQuery.value = value,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                // Enhanced Search Results Display
                Obx(
                  () =>
                      _searchQuery.value.isNotEmpty
                          ? TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 300),
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Iconsax.search_status,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Search results for "${_searchQuery.value}"',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          )
                          : const SizedBox(),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _searchScaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _searchQuery.value.isEmpty ? 1.0 : 0.0,
            child: Opacity(
              opacity: _searchQuery.value.isEmpty ? 1.0 : 0.0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: FloatingActionButton(
                  onPressed: () {
                    // Focus on search field
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  child: const Icon(
                    Iconsax.search_normal,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Column(
        children: [
          // Services Grid
          Expanded(
            child: StreamBuilder<List<Service>>(
              stream: Get.find<SupabaseService>().getServices(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error loading services'));
                }
                final services = snapshot.data ?? [];
                final hardcodedServices = _getHardcodedServices();

                // Build final list: home screen services first, then others
                final List<Service> allServices = [];
                final Set<String> addedTitles = {};
                
                // Add home screen services in order (use database version if exists, otherwise hardcoded)
                for (var homeScreenTitle in _homeScreenServices) {
                  // Try to find in database first
                  final dbMatches = services.where(
                    (s) => s.title.toLowerCase() == homeScreenTitle.toLowerCase(),
                  ).toList();
                  
                  if (dbMatches.isNotEmpty) {
                    allServices.add(dbMatches.first);
                    addedTitles.add(dbMatches.first.title.toLowerCase());
                  } else {
                    // Use hardcoded version
                    final hardcodedMatches = hardcodedServices.where(
                      (s) => s.title.toLowerCase() == homeScreenTitle.toLowerCase(),
                    ).toList();
                    if (hardcodedMatches.isNotEmpty) {
                      allServices.add(hardcodedMatches.first);
                      addedTitles.add(hardcodedMatches.first.title.toLowerCase());
                    }
                  }
                }
                
                // Add other services from database that aren't home screen services
                for (var service in services) {
                  final isHomeScreen = _homeScreenServices.any(
                    (hs) => hs.toLowerCase() == service.title.toLowerCase(),
                  );
                  if (!isHomeScreen && !addedTitles.contains(service.title.toLowerCase())) {
                    allServices.add(service);
                    addedTitles.add(service.title.toLowerCase());
                  }
                }

                // Filter based on search query
                final filtered = allServices.where((s) {
                  final query = _searchQuery.value.toLowerCase();
                  return query.isEmpty ||
                      s.title.toLowerCase().contains(query) ||
                      s.category.toLowerCase().contains(query);
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('No services found'));
                }
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio:
                              0.75, // Adjusted for better proportions
                        ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final service = filtered[index];
                      final missing = <String>[];
                      if (isAdmin) {
                        if (service.description.isEmpty) {
                          missing.add('Description');
                        }
                        if (service.features.isEmpty) missing.add('Features');
                      }
                      return Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(24),
                                  ),
                                ),
                                builder:
                                    (context) => _ServiceDetailSheet(
                                      service: service,
                                      isAdmin: isAdmin,
                                    ),
                              );
                            },
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
                                    // Use local assets instead of network images
                                    service.imageUrl != null &&
                                            service.imageUrl!.startsWith(
                                              'assets/',
                                            )
                                        ? Image.asset(
                                          service.imageUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Container(
                                                    color: Colors.grey[200],
                                                    child: Icon(
                                                      service.icon,
                                                      size: 48,
                                                      color: service.color,
                                                    ),
                                                  ),
                                        )
                                        : service.imageUrl != null &&
                                            service.imageUrl!.isNotEmpty
                                        ? Image.network(
                                          service.imageUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Container(
                                                    color: Colors.grey[200],
                                                    child: Icon(
                                                      service.icon,
                                                      size: 48,
                                                      color: service.color,
                                                    ),
                                                  ),
                                        )
                                        : Container(
                                          color: Colors.grey[200],
                                          child: Icon(
                                            service.icon,
                                            size: 48,
                                            color: service.color,
                                          ),
                                        ),
                                    // Enhanced gradient overlay
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        gradient: LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                          colors: [
                                            Colors.black.withOpacity(0.7),
                                            Colors.transparent,
                                            Colors.transparent,
                                            Colors.black.withOpacity(0.3),
                                          ],
                                          stops: const [0.0, 0.3, 0.7, 1.0],
                                        ),
                                      ),
                                    ),
                                    // Service title with better positioning
                                    Positioned(
                                      bottom: 16,
                                      left: 16,
                                      right: 16,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            service.title,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              shadows: [
                                                Shadow(
                                                  color: Colors.black54,
                                                  blurRadius: 6,
                                                ),
                                              ],
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (service.category.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: service.color
                                                    .withOpacity(0.9),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                service.category,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    // Price indicator removed
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (isAdmin && missing.isNotEmpty)
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange[100],
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.warning,
                                      color: Colors.orange,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'Missing: ${missing.join(', ')}',
                                        style: const TextStyle(
                                          color: Colors.orange,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          if (isAdmin)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: PopupMenuButton<String>(
                                onSelected: (value) {
                                  // TODO: Implement edit/delete
                                },
                                itemBuilder:
                                    (context) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Text('Edit'),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Text('Delete'),
                                      ),
                                    ],
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceDetailSheet extends StatelessWidget {
  final Service service;
  final bool isAdmin;
  const _ServiceDetailSheet({required this.service, required this.isAdmin});
  @override
  Widget build(BuildContext context) {
    final missing = <String>[];
    if (isAdmin) {
      if (service.description.isEmpty) missing.add('Description');
      if (service.features.isEmpty) missing.add('Features');
    }
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Close button
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(Icons.close, size: 20, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Admin warning banner
                  if (isAdmin && missing.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.orange[50]!, Colors.orange[100]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.orange[200]!,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.orange[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.warning_rounded,
                              color: Colors.orange[700],
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Missing Information',
                                  style: TextStyle(
                                    color: Colors.orange[800],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Please add: ${missing.join(', ')}',
                                  style: TextStyle(
                                    color: Colors.orange[700],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Service image with enhanced styling
                  Container(
                    width: double.infinity,
                    height: 220,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child:
                          service.imageUrl != null &&
                                  service.imageUrl!.isNotEmpty
                              ? service.imageUrl!.startsWith('assets/')
                                  ? Image.asset(
                                    service.imageUrl!,
                                    width: double.infinity,
                                    height: 220,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (
                                          context,
                                          error,
                                          stackTrace,
                                        ) => Container(
                                          width: double.infinity,
                                          height: 220,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                service.color.withOpacity(0.1),
                                                service.color.withOpacity(0.05),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Icon(
                                            service.icon,
                                            size: 80,
                                            color: service.color.withOpacity(
                                              0.6,
                                            ),
                                          ),
                                        ),
                                  )
                                  : Image.network(
                                    service.imageUrl!,
                                    width: double.infinity,
                                    height: 220,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (
                                          context,
                                          error,
                                          stackTrace,
                                        ) => Container(
                                          width: double.infinity,
                                          height: 220,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                service.color.withOpacity(0.1),
                                                service.color.withOpacity(0.05),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Icon(
                                            service.icon,
                                            size: 80,
                                            color: service.color.withOpacity(
                                              0.6,
                                            ),
                                          ),
                                        ),
                                  )
                              : Container(
                                width: double.infinity,
                                height: 220,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      service.color.withOpacity(0.1),
                                      service.color.withOpacity(0.05),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(
                                  service.icon,
                                  size: 80,
                                  color: service.color.withOpacity(0.6),
                                ),
                              ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Service title and category
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
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (service.category.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      service.color.withOpacity(0.15),
                                      service.color.withOpacity(0.1),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                    color: service.color.withOpacity(0.3),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      service.icon,
                                      size: 18,
                                      color: service.color,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      service.category,
                                      style: TextStyle(
                                        color: service.color,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Price display removed
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Service Overview Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: service.color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.info_outline_rounded,
                                color: service.color,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Service Overview',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          service.description.isNotEmpty
                              ? service.description
                              : 'No description provided.',
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.6,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Key Features Section
                  if (service.features.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.green[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.check_circle_rounded,
                                  color: Colors.green[700],
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Key Features',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ...service.features.map(
                            (feature) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 2),
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Colors.green[500],
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      feature,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey[700],
                                        height: 1.4,
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
                    const SizedBox(height: 20),
                  ],

                  // Book Service Button
                  if (!isAdmin)
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryColor,
                            AppTheme.secondaryColor,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(24),
                              ),
                            ),
                            builder:
                                (context) =>
                                    _ServiceBookingForm(service: service),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(
                          Iconsax.calendar,
                          color: Colors.white,
                          size: 24,
                        ),
                        label: const Text(
                          'Book This Service',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceBookingForm extends StatefulWidget {
  final Service service;
  const _ServiceBookingForm({required this.service});
  @override
  State<_ServiceBookingForm> createState() => _ServiceBookingFormState();
}

class _ServiceBookingFormState extends State<_ServiceBookingForm> {
  DateTime? _selectedDate;
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _locationController.dispose();
    _notesController.dispose();
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Close button
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(Icons.close, size: 20, color: Colors.grey[600]),
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
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryColor.withOpacity(0.1),
                              AppTheme.secondaryColor.withOpacity(0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Iconsax.calendar,
                          color: AppTheme.primaryColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Book This Service',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.service.title,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Service Location Field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!, width: 1),
                    ),
                    child: TextField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        labelText: 'Service Location',
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
                            Iconsax.location,
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
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 20,
                        ),
                        hintText:
                            'Enter the location where you need the service',
                        hintStyle: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 14,
                        ),
                      ),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Date Selection Field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!, width: 1),
                    ),
                    child: Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.all(12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Iconsax.calendar,
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
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
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 20,
                                horizontal: 16,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Service Date',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _selectedDate != null
                                        ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                        : 'Select a date',
                                    style: TextStyle(
                                      color:
                                          _selectedDate != null
                                              ? AppTheme.primaryColor
                                              : Colors.grey[500],
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Additional Notes Field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!, width: 1),
                    ),
                    child: TextField(
                      controller: _notesController,
                      decoration: InputDecoration(
                        labelText: 'Additional Notes (Optional)',
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
                            Iconsax.note,
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
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 20,
                        ),
                        hintText: 'Any special requirements or notes...',
                        hintStyle: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 14,
                        ),
                      ),
                      maxLines: 3,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Submit Button
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor,
                          AppTheme.secondaryColor,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed:
                          _isLoading ||
                                  user == null ||
                                  _selectedDate == null ||
                                  _locationController.text.trim().isEmpty
                              ? null
                              : () async {
                                setState(() => _isLoading = true);
                                try {
                                  final booking = Booking(
                                    serviceName: widget.service.title,
                                    clientName: user.name,
                                    clientEmail: user.email,
                                    clientPhone: user.phone,
                                    date: _selectedDate!,
                                    status: BookingStatus.pending,
                                    price: 0.0, // Price removed from services
                                    location: _locationController.text.trim(),
                                    notes: _notesController.text.trim(),
                                  );
                                  await Get.find<SupabaseService>().addBooking(
                                    booking,
                                  );
                                  Navigator.pop(context);
                                  Get.snackbar(
                                    'Success! 🎉',
                                    'Service booking submitted successfully!',
                                    backgroundColor: Colors.green,
                                    colorText: Colors.white,
                                    duration: const Duration(seconds: 3),
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
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : const Text(
                                'Submit Booking',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
