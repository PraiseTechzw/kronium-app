import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kronium/core/app_theme.dart';
import 'package:kronium/core/routes.dart';
import 'package:animate_do/animate_do.dart';

class FeaturedServicesSection extends StatelessWidget {
  const FeaturedServicesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      delay: const Duration(milliseconds: 200),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.98),
              Colors.white.withValues(alpha: 0.92),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.shadow.withValues(alpha: 0.08),
              blurRadius: 30,
              offset: const Offset(0, 15),
              spreadRadius: 2,
            ),
            BoxShadow(
              color: AppTheme.primaryColor.withValues(alpha: 0.03),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: AppTheme.primaryColor.withValues(alpha: 0.08),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Featured Services',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                          color: AppTheme.primaryColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Professional engineering solutions',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.secondaryColor.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  constraints: const BoxConstraints(
                    minWidth: 80,
                    maxWidth: 120,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: TextButton(
                    onPressed: () => Get.toNamed(AppRoutes.services),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'View All',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 180, // Increased height to fix bottom overflow
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 6,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final services = [
                    {
                      'title': 'Greenhouse Construction',
                      'image': 'assets/images/services/Greenhouse.jpg',
                      'description': 'Modern greenhouse solutions',
                      'color': Colors.green,
                    },
                    {
                      'title': 'Solar Systems',
                      'image': 'assets/images/services/solar.jpg',
                      'description': 'Renewable energy installations',
                      'color': Colors.orange,
                    },
                    {
                      'title': 'Construction',
                      'image': 'assets/images/services/construction.jpg',
                      'description': 'Professional construction services',
                      'color': Colors.blue,
                    },
                    {
                      'title': 'Irrigation Systems',
                      'image': 'assets/images/services/irrigation.jpg',
                      'description': 'Agricultural automation',
                      'color': Colors.teal,
                    },
                    {
                      'title': 'IoT Solutions',
                      'image': 'assets/images/services/Iot.png',
                      'description': 'Smart technology solutions',
                      'color': Colors.purple,
                    },
                    {
                      'title': 'Logistics',
                      'image': 'assets/images/services/logistics.png',
                      'description': 'Transportation & logistics',
                      'color': Colors.indigo,
                    },
                  ];
                  final s = services[index];
                  return FadeInLeft(
                    delay: Duration(milliseconds: 300 + (index * 100)),
                    child: Container(
                      width: 180, // Increased width for better content fit
                      margin: const EdgeInsets.only(right: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.95),
                            Colors.white.withValues(alpha: 0.85),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.shadow.withValues(alpha: 0.06),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                            spreadRadius: 1,
                          ),
                          BoxShadow(
                            color: (s['color'] as Color).withValues(
                              alpha: 0.08,
                            ),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                        border: Border.all(
                          color: (s['color'] as Color).withValues(alpha: 0.15),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 70, // Increased image height
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: (s['color'] as Color).withValues(
                                  alpha: 0.2,
                                ),
                                width: 1,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.asset(
                                s['image'] as String,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: (s['color'] as Color).withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Icon(
                                      Icons.image_not_supported,
                                      color: s['color'] as Color,
                                      size: 24,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            s['title'] as String,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: AppTheme.primaryColor,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Expanded(
                            child: Text(
                              s['description'] as String,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.secondaryColor.withValues(
                                  alpha: 0.7,
                                ),
                                fontWeight: FontWeight.w500,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
