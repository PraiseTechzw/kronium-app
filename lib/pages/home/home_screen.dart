import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kronium/core/app_theme.dart';
import 'package:kronium/models/service_model.dart';
import 'package:get/get.dart';
import 'package:kronium/core/routes.dart';

/// HomeScreen is the main dashboard for the app's Home tab.
/// Keep this widget focused and readable. Extend as needed.
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  // Mock featured services (replace with real data or a stream as needed)
  List<Service> get _featuredServices => [
    Service(
      id: '1',
      title: 'Greenhouse Construction',
      category: 'Agriculture',
      icon: Iconsax.building,
      color: AppTheme.primaryColor,
      description: 'Professional greenhouse design and construction.',
      features: ['Custom sizing', 'Climate control', 'Durable materials'],
      price: 3500,
    ),
    Service(
      id: '2',
      title: 'Solar Panel Installation',
      category: 'Renewable Energy',
      icon: Iconsax.sun_1,
      color: AppTheme.secondaryColor,
      description: 'Complete solar energy solutions.',
      features: ['Battery storage', 'Rebate assistance'],
      price: 8500,
    ),
    Service(
      id: '3',
      title: 'Steel Structures',
      category: 'Construction',
      icon: Iconsax.home_2,
      color: Colors.blue,
      description: 'Durable steel buildings for commercial use.',
      features: ['Custom engineering', 'Quick assembly'],
      price: 12500,
    ),
  ];

  // Mock testimonials (replace with real data as needed)
  final List<Map<String, dynamic>> _testimonials = const [
    {
      'name': 'John Doe',
      'comment': 'Excellent service! The team was professional and delivered on time.',
      'rating': 5,
    },
    {
      'name': 'Jane Smith',
      'comment': 'High quality work and great communication throughout the project.',
      'rating': 5,
    },
    {
      'name': 'Mike Johnson',
      'comment': 'Very satisfied with the results. Highly recommended!',
      'rating': 5,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main Hero/Services Card (restored from old dashboard)
          FadeInDown(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Professional Services',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Quality solutions for your business needs',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => Get.toNamed(AppRoutes.bookProject),
                    icon: const Icon(Iconsax.calendar_add),
                    label: const Text('Book Now'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Welcome Section (optional, can be removed if redundant)
          // FadeInDown(
          //   child: Container(
          //     ...
          //   ),
          // ),
          // const SizedBox(height: 24),

          // Featured Services Section
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: const Text(
              'Our Services',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: _featuredServices.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(Iconsax.box, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No services available',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: _featuredServices.length,
                    itemBuilder: (context, index) {
                      final service = _featuredServices[index];
                      return _buildServiceCard(service);
                    },
                  ),
          ),
          const SizedBox(height: 24),

          // Testimonials Section
          FadeInUp(
            delay: const Duration(milliseconds: 600),
            child: const Text(
              'What Our Clients Say',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          FadeInUp(
            delay: const Duration(milliseconds: 800),
            child: SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _testimonials.length,
                itemBuilder: (context, index) {
                  final testimonial = _testimonials[index];
                  return _buildTestimonialCard(testimonial);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a card for a featured service.
  Widget _buildServiceCard(Service service) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {}, // Add navigation or details as needed
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: service.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  service.icon,
                  color: service.color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                service.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                service.category,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              if (service.price != null)
                Text(
                  '\$24${service.price}',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a card for a testimonial.
  Widget _buildTestimonialCard(Map<String, dynamic> testimonial) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(5, (i) {
              return Icon(
                i < (testimonial['rating'] ?? 0) ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 16,
              );
            }),
          ),
          const SizedBox(height: 12),
          Text(
            testimonial['comment'] ?? '',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Text(
            '- ${testimonial['name'] ?? ''}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
} 