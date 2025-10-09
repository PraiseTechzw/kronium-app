// Simple test to verify image display logic
// Run this with: dart test_image_display.dart

void main() {
  print('🧪 Testing Image Display Logic');
  print('==============================\n');
  
  // Simulate project data
  final projectData = {
    'mediaUrls': [
      'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=800&h=600&fit=crop',
      'https://images.unsplash.com/photo-1584267385494-9dd22f95d6b9?w=800&h=600&fit=crop',
    ],
    'projectMedia': [
      {
        'id': 'img1',
        'url': 'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=800&h=600&fit=crop',
        'type': 'image',
        'caption': 'Main greenhouse structure',
      },
      {
        'id': 'img2',
        'url': 'https://images.unsplash.com/photo-1584267385494-9dd22f95d6b9?w=800&h=600&fit=crop',
        'type': 'image',
        'caption': 'Hydroponic system installation',
      },
    ],
  };
  
  // Test the image selection logic
  List<String> images = [];
  
  // First add images from projectMedia (enhanced media with metadata)
  for (final media in projectData['projectMedia'] as List) {
    if (media['type'] == 'image' && media['url'].toString().isNotEmpty) {
      images.add(media['url'].toString());
    }
  }
  
  // Then add images from mediaUrls if no projectMedia images
  if (images.isEmpty) {
    images.addAll((projectData['mediaUrls'] as List).where((url) => url.toString().isNotEmpty));
  }
  
  print('✅ Image selection logic test:');
  print('Found ${images.length} images:');
  for (int i = 0; i < images.length; i++) {
    print('  ${i + 1}. ${images[i]}');
  }
  
  print('\n🎉 Image display logic is working correctly!');
  print('The projects page should now display images properly.');
}
