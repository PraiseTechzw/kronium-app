// Test script to add sample projects with images
// Run this with: dart test_project_images.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kronium/models/project_model.dart';

void main() async {
  print('🧪 Testing Project Image Display');
  print('================================\n');

  // Initialize Firebase
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  try {
    // Create sample projects with images
    final sampleProjects = [
      {
        'title': 'Modern Greenhouse Project',
        'description':
            'A state-of-the-art greenhouse facility with automated climate control and hydroponic systems.',
        'location': 'Harare, Zimbabwe',
        'size': '500 sqm',
        'mediaUrls': [
          'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=800&h=600&fit=crop',
          'https://images.unsplash.com/photo-1584267385494-9dd22f95d6b9?w=800&h=600&fit=crop',
        ],
        'projectMedia': [
          {
            'id': 'img1',
            'url':
                'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=800&h=600&fit=crop',
            'type': 'image',
            'caption': 'Main greenhouse structure',
            'uploadedAt': Timestamp.now(),
            'uploadedBy': 'admin',
          },
          {
            'id': 'img2',
            'url':
                'https://images.unsplash.com/photo-1584267385494-9dd22f95d6b9?w=800&h=600&fit=crop',
            'type': 'image',
            'caption': 'Hydroponic system installation',
            'uploadedAt': Timestamp.now(),
            'uploadedBy': 'admin',
          },
        ],
        'features': [
          'Automated Climate Control',
          'Hydroponic Systems',
          'Solar Power',
          'Water Recycling',
        ],
        'approved': true,
        'progress': 0.75,
        'status': 'inProgress',
        'category': 'Greenhouses',
        'transportCost': 1500.0,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      },
      {
        'title': 'Steel Structure Warehouse',
        'description':
            'Large-scale steel warehouse construction with modern logistics integration.',
        'location': 'Bulawayo, Zimbabwe',
        'size': '2000 sqm',
        'mediaUrls': [
          'https://images.unsplash.com/photo-1541888946425-d81bb19240f5?w=800&h=600&fit=crop',
        ],
        'projectMedia': [
          {
            'id': 'img3',
            'url':
                'https://images.unsplash.com/photo-1541888946425-d81bb19240f5?w=800&h=600&fit=crop',
            'type': 'image',
            'caption': 'Steel structure framework',
            'uploadedAt': Timestamp.now(),
            'uploadedBy': 'admin',
          },
        ],
        'features': [
          'Steel Framework',
          'Modern Logistics',
          'Loading Docks',
          'Security Systems',
        ],
        'approved': true,
        'progress': 0.45,
        'status': 'inProgress',
        'category': 'Steel Structures',
        'transportCost': 3000.0,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      },
      {
        'title': 'Solar Power Installation',
        'description':
            'Complete solar power system installation for industrial facility.',
        'location': 'Gweru, Zimbabwe',
        'size': '1000 sqm',
        'mediaUrls': [
          'https://images.unsplash.com/photo-1509391366360-2e959784a276?w=800&h=600&fit=crop',
        ],
        'projectMedia': [
          {
            'id': 'img4',
            'url':
                'https://images.unsplash.com/photo-1509391366360-2e959784a276?w=800&h=600&fit=crop',
            'type': 'image',
            'caption': 'Solar panel installation',
            'uploadedAt': Timestamp.now(),
            'uploadedBy': 'admin',
          },
        ],
        'features': [
          'Solar Panels',
          'Battery Storage',
          'Grid Integration',
          'Monitoring System',
        ],
        'approved': true,
        'progress': 0.90,
        'status': 'inProgress',
        'category': 'Solar Systems',
        'transportCost': 2000.0,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      },
    ];

    print('Adding sample projects to Firestore...');

    for (final projectData in sampleProjects) {
      await firestore.collection('projects').add(projectData);
      print('✅ Added project: ${projectData['title']}');
    }

    print('\n🎉 Sample projects added successfully!');
    print('Now check the app to see if images are displaying correctly.');
    print('\nNote: The images are using Unsplash URLs for testing.');
    print('In production, these would be Appwrite URLs from your storage.');
  } catch (e) {
    print('❌ Error adding sample projects: $e');
  }
}
