# Appwrite Setup Guide

## The Problem
You're getting this error:
```
AppwriteException: project_not_found, Project with the requested ID could not be found
```

This means the project ID `6867ce2e001b592626ae` doesn't exist in your Appwrite account.

## Solution: Set Up Your Appwrite Project

### Step 1: Create Appwrite Account
1. Go to [https://cloud.appwrite.io/](https://cloud.appwrite.io/)
2. Sign up or log in to your account

### Step 2: Create a New Project
1. Click "Create Project"
2. Enter project name: "Kronium App" (or any name you prefer)
3. Click "Create"
4. **Copy the Project ID** from the project dashboard

### Step 3: Create Storage Buckets
1. Go to "Storage" in the left sidebar
2. Create these buckets:

#### Bucket 1: Images
- Name: `images` (or any name)
- **Copy the Bucket ID**

#### Bucket 2: Videos  
- Name: `videos` (or any name)
- **Copy the Bucket ID**

#### Bucket 3: Project Media
- Name: `project-media` (or any name)
- **Copy the Bucket ID**

### Step 4: Set Bucket Permissions
For each bucket:
1. Click on the bucket
2. Go to "Settings" tab
3. Set permissions:
   - **Create**: `any` (or specific roles)
   - **Read**: `any` (for public access)
   - **Update**: `any` (or specific roles)
   - **Delete**: `any` (or specific roles)

### Step 5: Update Configuration
1. Open `lib/core/appwrite_config.dart`
2. Replace the placeholder values:

```dart
class AppwriteConfig {
  static const String endpoint = 'https://cloud.appwrite.io/v1';
  
  // Replace with your actual project ID from Step 2
  static const String projectId = 'YOUR_ACTUAL_PROJECT_ID_HERE';
  
  // Replace with your actual bucket IDs from Step 3
  static const String imageBucketId = 'YOUR_IMAGE_BUCKET_ID_HERE';
  static const String videoBucketId = 'YOUR_VIDEO_BUCKET_ID_HERE';
  static const String projectMediaBucketId = 'YOUR_PROJECT_MEDIA_BUCKET_ID_HERE';
}
```

### Step 6: Test the Setup
1. Run the app: `flutter run`
2. Try uploading an image or video
3. Check the console for success messages

## Example Configuration
```dart
class AppwriteConfig {
  static const String endpoint = 'https://cloud.appwrite.io/v1';
  static const String projectId = '64a1b2c3d4e5f6789abcdef0';
  static const String imageBucketId = '64a1b2c3d4e5f6789abcdef1';
  static const String videoBucketId = '64a1b2c3d4e5f6789abcdef2';
  static const String projectMediaBucketId = '64a1b2c3d4e5f6789abcdef3';
}
```

## Troubleshooting
- **Project not found**: Make sure you copied the correct Project ID
- **Bucket not found**: Make sure you copied the correct Bucket IDs
- **Permission denied**: Check bucket permissions are set to allow public access
- **Network error**: Check your internet connection

## Need Help?
If you're still having issues, please share:
1. Your actual Project ID
2. Your actual Bucket IDs
3. Any error messages you see



