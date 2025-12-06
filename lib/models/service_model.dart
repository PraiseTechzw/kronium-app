import 'package:flutter/material.dart';

class Service {
  final String? id;
  final String title;
  final String category;
  final IconData icon;
  final Color color;
  final String description;
  final List<String> features;
  final String? imageUrl;
  final String? videoUrl;
  final double? price;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Service({
    this.id,
    required this.title,
    required this.category,
    required this.icon,
    required this.color,
    required this.description,
    required this.features,
    this.imageUrl,
    this.videoUrl,
    this.price,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  // Create from Map
  factory Service.fromMap(Map<String, dynamic> data, {String? id}) {
    return Service(
      id: id ?? data['id'],
      title: data['title'] ?? '',
      category: data['category'] ?? '',
      icon: _getIconFromString(data['icon'] ?? 'warehouse'),
      color: _getColorFromString(data['color'] ?? '#2ECC71'),
      description: data['description'] ?? '',
      features: List<String>.from(data['features'] ?? []),
      imageUrl: data['imageUrl'],
      videoUrl: data['videoUrl'],
      price: data['price']?.toDouble(),
      isActive: data['isActive'] ?? true,
      createdAt: data['createdAt'] is DateTime ? data['createdAt'] : (data['createdAt'] != null ? DateTime.parse(data['createdAt'].toString()) : null),
      updatedAt: data['updatedAt'] is DateTime ? data['updatedAt'] : (data['updatedAt'] != null ? DateTime.parse(data['updatedAt'].toString()) : null),
    );
  }

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'icon': icon.codePoint.toString(),
      'color': '#${color.value.toRadixString(16).padLeft(8, '0')}',
      'description': description,
      'features': features,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'price': price,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Helper method to get icon from string
  static IconData _getIconFromString(String iconString) {
    switch (iconString) {
      case 'warehouse':
        return Icons.warehouse;
      case 'solar_power':
        return Icons.solar_power;
      case 'construction':
        return Icons.construction;
      case 'engineering':
        return Icons.engineering;
      case 'water_drop':
        return Icons.water_drop;
      case 'local_shipping':
        return Icons.local_shipping;
      case 'home_repair_service':
        return Icons.home_repair_service;
      case 'electrical_services':
        return Icons.electrical_services;
      case 'plumbing':
        return Icons.plumbing;
      case 'cleaning_services':
        return Icons.cleaning_services;
      default:
        return Icons.warehouse;
    }
  }

  // Helper method to get color from string
  static Color _getColorFromString(String colorString) {
    try {
      return Color(int.parse(colorString.replaceAll('#', '0xFF')));
    } catch (e) {
      return const Color(0xFF2ECC71);
    }
  }

  // Copy with method
  Service copyWith({
    String? id,
    String? title,
    String? category,
    IconData? icon,
    Color? color,
    String? description,
    List<String>? features,
    String? imageUrl,
    String? videoUrl,
    double? price,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Service(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      description: description ?? this.description,
      features: features ?? this.features,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      price: price ?? this.price,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Keeping your existing static method
  static List<Service> getAllServices() {
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
        videoUrl: 'https://example.com/greenhouse-video.mp4',
      ),
      Service(
        id: '2',
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
        id: '3',
        title: 'Construction',
        category: 'Building',
        icon: Icons.construction,
        color: const Color(0xFFE67E22),
        description:
            'Professional building and construction service with inclusion of structure plans, 3D models and rendering',
        features: [
          'Structure plans',
          '3D models',
          'Rendering',
          'Structure Types: Modern Houses, Animal Shelter, Farm Structures',
        ],
        imageUrl: 'assets/images/services/construction.jpg',
        price: 5000,
      ),
      Service(
        id: '4',
        title: 'Steel Structures',
        category: 'Building',
        icon: Icons.engineering,
        color: const Color(0xFF95A5A6),
        description:
            'Professional customised steel fabrication services including design and installation of structures',
        features: [
          'Steel sheds',
          'Spray races',
          'Neck clamps',
          'Steel reservoir tanks',
          'Solar dryers',
        ],
        imageUrl: 'assets/images/services/Iot.png',
        price: 4000,
      ),
      Service(
        id: '5',
        title: 'Solar Systems',
        category: 'Renewable Energy',
        icon: Icons.solar_power,
        color: const Color(0xFFF39C12),
        description:
            'Domestic, industrial and commercial solar systems design and installation to ensure all your farm, home or business process run smoothly without any power outages',
        features: [
          'Domestic systems',
          'Industrial systems',
          'Commercial systems',
          'Design and installation',
          'Power outage prevention',
        ],
        imageUrl: 'assets/images/services/solar.png',
        price: 8500,
      ),
      Service(
        id: '6',
        title: 'Logistics',
        category: 'Transport',
        icon: Icons.local_shipping,
        color: const Color(0xFF9B59B6),
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
}
