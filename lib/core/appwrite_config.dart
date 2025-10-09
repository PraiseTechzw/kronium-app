class AppwriteConfig {
  // Appwrite Configuration
  static const String endpoint = 'https://cloud.appwrite.io/v1';

  // Appwrite project ID
  static const String projectId = '6867ce160037a5704b1d';

  // Storage bucket IDs
  static const String imageBucketId = '687a6819003de32d8af1';
  static const String videoBucketId = '687a6819003de32d8af1';
  static const String projectMediaBucketId = '687a6819003de32d8af1';

  // Check if configuration is properly set
  static bool get isConfigured {
    return projectId != 'YOUR_PROJECT_ID_HERE' &&
        imageBucketId != 'YOUR_IMAGE_BUCKET_ID_HERE' &&
        videoBucketId != 'YOUR_VIDEO_BUCKET_ID_HERE' &&
        projectMediaBucketId != 'YOUR_PROJECT_MEDIA_BUCKET_ID_HERE';
  }

  // Instructions:
  // 1. Go to https://cloud.appwrite.io/
  // 2. Sign in to your account
  // 3. Create a new project or select an existing one
  // 4. Copy the Project ID from Project Settings
  // 5. Replace 'YOUR_PROJECT_ID_HERE' with your actual project ID
  // 6. Create storage buckets for images, videos, and project media
  // 7. Replace the bucket IDs with your actual bucket IDs
  // 8. Make sure to set proper permissions for your buckets
}
