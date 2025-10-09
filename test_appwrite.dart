// Test Appwrite Connection and List Buckets
// Run this with: dart test_appwrite.dart

import 'dart:io';

void main() async {
  print('🔍 Testing Appwrite Connection...');
  print('Project ID: 6867ce160037a5704b1d');
  print('Endpoint: https://cloud.appwrite.io/v1\n');
  
  print('📋 Next Steps:');
  print('1. Go to https://cloud.appwrite.io/');
  print('2. Sign in to your account');
  print('3. Find your project with ID: 6867ce160037a5704b1d');
  print('4. Go to Storage section');
  print('5. Create these buckets if they don\'t exist:');
  print('   - images (for service images)');
  print('   - videos (for service videos)');
  print('   - project-media (for project media)');
  print('6. Copy the bucket IDs and update lib/core/appwrite_config.dart\n');
  
  print('🔧 Current configuration status:');
  print('✅ Project ID: Set');
  print('❌ Image Bucket ID: Not set');
  print('❌ Video Bucket ID: Not set');
  print('❌ Project Media Bucket ID: Not set\n');
  
  print('Once you have the bucket IDs, update appwrite_config.dart:');
  print('static const String imageBucketId = \'YOUR_ACTUAL_IMAGE_BUCKET_ID\';');
  print('static const String videoBucketId = \'YOUR_ACTUAL_VIDEO_BUCKET_ID\';');
  print('static const String projectMediaBucketId = \'YOUR_ACTUAL_PROJECT_MEDIA_BUCKET_ID\';');
}



