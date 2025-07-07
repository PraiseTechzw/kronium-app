import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  // Create from Firestore document
  factory Service.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Service(
      id: doc.id,
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
      createdAt: data['createdAt']?.toDate(),
      updatedAt: data['updatedAt']?.toDate(),
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toFirestore() {
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
        description: 'Professional greenhouse design and construction for optimal plant growth',
        features: [
          'Custom sizing options',
          'Climate control systems',
          'Durable polycarbonate materials',
          '5-year warranty'
        ],
        imageUrl: 'assets/images/greenhouse.jpg',
        price: 3500,
        videoUrl: 'https://example.com/greenhouse-video.mp4', // Example video
      ),
      Service(
        id: '2',
        title: 'Solar Panel Installation',
        category: 'Renewable Energy',
        icon: Icons.solar_power,
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
        // This service doesn't have a video (videoUrl is null)
      ),
      // Add more services as needed
    ];
  }
}