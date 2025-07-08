import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kronium/core/app_theme.dart';
import 'package:kronium/models/service_model.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kronium/core/constants.dart';

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
        'icon': Iconsax.building,
        'image': 'https://images.unsplash.com/photo-1506744038136-46273834b3fb',
      },
      {
        'title': 'Construction',
        'icon': Iconsax.buildings,
        'image': 'https://images.unsplash.com/photo-1464983953574-0892a716854b',
      },
      {
        'title': 'Solar Systems',
        'icon': Iconsax.sun_1,
        'image': 'https://images.unsplash.com/photo-1464983953574-0892a716854b',
      },
      {
        'title': 'Irrigation Systems',
        'icon': Iconsax.drop,
        'image': 'https://images.unsplash.com/photo-1519125323398-675f0ddb6308',
      },
      {
        'title': 'Logistics',
        'icon': Iconsax.truck,
        'image': 'https://images.unsplash.com/photo-1519125323398-675f0ddb6308',
      },
      {
        'title': 'IoT & Automation Projects',
        'icon': Iconsax.cpu,
        'image': 'https://images.unsplash.com/photo-1519125323398-675f0ddb6308',
      },
    ];
    final List<String> _backgroundImages = [
      'https://images.unsplash.com/photo-1506744038136-46273834b3fb', // Greenhouse
      'https://images.unsplash.com/photo-1464983953574-0892a716854b', // Construction
      'https://images.unsplash.com/photo-1519125323398-675f0ddb6308', // Solar/Logistics/IoT
    ];
    return Stack(
      children: [
        // Background carousel
        Positioned.fill(
          child: CarouselSlider(
            options: CarouselOptions(
              height: double.infinity,
              viewportFraction: 1.0,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 6),
              enableInfiniteScroll: true,
              scrollPhysics: const NeverScrollableScrollPhysics(),
              disableCenter: true,
              enlargeCenterPage: false,
              aspectRatio: MediaQuery.of(context).size.aspectRatio,
            ),
            items: _backgroundImages.map((img) => Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(img),
                  fit: BoxFit.cover,
                ),
              ),
            )).toList(),
          ),
        ),
        // Gradient overlay for readability
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.55), Colors.black.withOpacity(0.25)],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
        ),
        // Main content
        Positioned.fill(
          child: SingleChildScrollView(
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
                    childAspectRatio: 1.1,
                  ),
                  itemCount: _services.length,
                  itemBuilder: (context, index) {
                    final service = _services[index];
                    return GestureDetector(
                      onTap: () => _onServiceTap(context, service),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.10),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundColor: AppTheme.primaryColor.withOpacity(0.08),
                              backgroundImage: NetworkImage(service['image']),
                              child: Icon(service['icon'], color: AppTheme.primaryColor, size: 32),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              service['title'],
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
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
      ],
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
    return Container(
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
                    color: service.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(service.icon, color: service.color, size: 24),
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
              ],
            ),
            const SizedBox(height: 20),
            if (service.videoUrl != null) ...[
              // Video thumbnail or player could go here
              Container(
                height: 180,
                width: double.infinity,
                color: Colors.black12,
                child: const Center(child: Icon(Icons.play_circle_fill, size: 48, color: Colors.grey)),
              ),
              const SizedBox(height: 20),
            ] else ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: service.imageUrl != null
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
            _detailItem(Icons.attach_money, 'Starting Price',
              service.price != null ? '\$24${service.price}' : 'Contact for quote'),
            _detailItem(Icons.schedule, 'Duration', '2-6 weeks'),
            _detailItem(Icons.event_available, 'Availability', 'Next 2 weeks'),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('BACK'),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Navigate to booking or quote page if needed
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'REQUEST QUOTE',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
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