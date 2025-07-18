import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kronium/core/app_theme.dart';

import 'package:video_player/video_player.dart';
import 'package:kronium/core/services_data.dart';
import 'package:kronium/core/user_auth_service.dart' show userController, UserAuthService;
import 'package:kronium/models/service_model.dart';
import 'package:kronium/core/firebase_service.dart' show FirebaseService;

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  ServicesPageState createState() => ServicesPageState();
}

class ServicesPageState extends State<ServicesPage> {
  final RxString _searchQuery = ''.obs;
  final RxString _selectedSort = 'Popular'.obs;
  final List<String> sortOptions = ['Popular', 'Newest', 'Price: Low to High', 'Price: High to Low'];

  @override
  Widget build(BuildContext context) {
    final isAdmin = userController.role.value == 'admin';
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text('Our Services', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)),
        centerTitle: true,
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Iconsax.add, color: Colors.white),
              tooltip: 'Add Service',
              onPressed: () {
                // TODO: Implement add service
              },
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
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
      body: StreamBuilder<List<Service>>(
        stream: FirebaseService.instance.getServices(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading services'));
          }
          final services = snapshot.data ?? [];
          final filtered = services.where((s) {
            final query = _searchQuery.value.toLowerCase();
            return query.isEmpty || s.title.toLowerCase().contains(query) || s.category.toLowerCase().contains(query);
          }).toList();
          if (filtered.isEmpty) {
            return const Center(child: Text('No services found'));
          }
          return Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
                ),
              itemCount: filtered.length,
                itemBuilder: (context, index) {
                final service = filtered[index];
                final missing = <String>[];
                if (isAdmin) {
                  if (service.description.isEmpty) missing.add('Description');
                  if (service.features.isEmpty) missing.add('Features');
                  if (service.price == null) missing.add('Price');
                }
                return Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                          ),
                          builder: (context) => _ServiceDetailSheet(service: service, isAdmin: isAdmin),
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
                              service.imageUrl != null && service.imageUrl!.isNotEmpty
                                  ? Image.asset(
                                      service.imageUrl!,
                          fit: BoxFit.cover,
                                    )
                                  : Container(
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
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
                                    service.title,
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
                    ),
                    if (isAdmin && missing.isNotEmpty)
                  Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning, color: Colors.orange, size: 18),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Missing: ${missing.join(', ')}',
                                  style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12),
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
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'edit', child: Text('Edit')),
                            const PopupMenuItem(value: 'delete', child: Text('Delete')),
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
      if (service.price == null) missing.add('Price');
    }
    return Container(
        decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
            ),
          ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
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
                  borderRadius: BorderRadius.circular(12),
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
            // Service image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: service.imageUrl != null && service.imageUrl!.isNotEmpty
                  ? Image.asset(
                      service.imageUrl!,
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: double.infinity,
                      height: 180,
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                    ),
      ),
            const SizedBox(height: 20),
            Text(
              service.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            if (service.category.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 12),
                child: Container(
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
              ),
            const SizedBox(height: 8),
            const Text('Service Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
                        Text(
              service.description.isNotEmpty ? service.description : 'No description provided.',
              style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                      const SizedBox(height: 18),
            if (service.features.isNotEmpty) ...[
              const Text('Key Features', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Column(
                children: service.features.map((feature) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 18),
                      const SizedBox(width: 10),
                      Expanded(child: Text(feature, style: const TextStyle(fontSize: 15))),
                    ],
          ),
                )).toList(),
              ),
                  const SizedBox(height: 18),
            ],
            const Text('Pricing', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
          Text(
              service.price != null ? '\$${service.price}' : 'Contact for quote',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
        ),
            const SizedBox(height: 30),
            // Optionally, add booking or edit buttons here
          ],
        ),
      ),
    );
  }
}