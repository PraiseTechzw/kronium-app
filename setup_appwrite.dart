// Quick Appwrite Setup Script
// Run this with: dart setup_appwrite.dart

import 'dart:io';

void main() {
  print('🚀 Kronium App - Appwrite Setup Helper');
  print('=====================================\n');

  print('The current Appwrite configuration is not set up.');
  print('You need to create an Appwrite project and get the IDs.\n');

  print('📋 Step-by-Step Instructions:');
  print('1. Go to https://cloud.appwrite.io/');
  print('2. Sign up or log in to your account');
  print('3. Create a new project');
  print('4. Copy the Project ID');
  print('5. Create storage buckets for images, videos, and project media');
  print('6. Copy the Bucket IDs');
  print('7. Update lib/core/appwrite_config.dart with your IDs\n');

  print('📁 Files to update:');
  print('- lib/core/appwrite_config.dart (main configuration)');
  print('- APPWRITE_SETUP.md (detailed setup guide)\n');

  print('🔧 Current configuration:');
  print('Project ID: YOUR_PROJECT_ID_HERE');
  print('Image Bucket: YOUR_IMAGE_BUCKET_ID_HERE');
  print('Video Bucket: YOUR_VIDEO_BUCKET_ID_HERE');
  print('Project Media Bucket: YOUR_PROJECT_MEDIA_BUCKET_ID_HERE\n');

  print('✅ Once you update the configuration, the app will work!');
  print('📖 See APPWRITE_SETUP.md for detailed instructions.');
}
