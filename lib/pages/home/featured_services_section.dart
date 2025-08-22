import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:kronium/core/app_theme.dart';
import 'package:kronium/core/routes.dart';

class FeaturedServicesSection extends StatelessWidget {
  const FeaturedServicesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.98),
            Colors.white.withValues(alpha: 0.95),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadow.withValues(alpha: 0.1),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.1),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Featured Services',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: AppTheme.primaryColor,
                ),
              ),
              TextButton(
                onPressed: () => Get.toNamed(AppRoutes.services),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 6,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final services = [
                  {
                    'title': 'Greenhouse Construction',
                    'icon': Icons.eco,
                    'description': 'Modern greenhouse solutions',
                  },
                  {
                    'title': 'Solar Systems',
                    'icon': Icons.solar_power,
                    'description': 'Renewable energy installations',
                  },
                  {
                    'title': 'Borehole Drilling',
                    'icon': Icons.water_drop,
                    'description': 'Water solutions',
                  },
                  {
                    'title': 'Irrigation Systems',
                    'icon': Icons.opacity,
                    'description': 'Agricultural automation',
                  },
                  {
                    'title': 'AC/DC Pumps',
                    'icon': Icons.power,
                    'description': 'Pumping solutions',
                  },
                  {
                    'title': 'Engineering',
                    'icon': Icons.engineering,
                    'description': 'Professional consulting',
                  },
                ];
                final s = services[index];
                return Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor.withValues(alpha: 0.08),
                        AppTheme.secondaryColor.withValues(alpha: 0.06),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: AppTheme.primaryColor.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        s['icon'] as IconData,
                        color: AppTheme.primaryColor,
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        s['title'] as String,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        s['description'] as String,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black54,
                        ),
                      ),
                    ],
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
