# Service Image Upload Setup Guide

This guide explains how to set up and use the new image upload functionality for services in the Kronium admin dashboard.

## What's Changed

### 1. Database Updates
- Added new columns to the `services` table:
  - `image_path`: Stores the storage path of uploaded images
  - `image_filename`: Original filename of uploaded image
  - `image_size`: File size in bytes
  - `image_type`: MIME type of the image
- Kept `image_url` for backward compatibility

### 2. New Components
- **ImageUpload Component**: Handles drag-and-drop and click-to-upload functionality
- **Updated Service Forms**: Both create and edit forms now use image uploads instead of URL input

### 3. Storage Configuration
- Uses Supabase Storage with a dedicated `service-images` bucket
- Supports JPEG, PNG, WebP, and GIF formats
- 5MB file size limit
- Public access for viewing images

## Setup Instructions

### Step 1: Update Database Schema
Run the database update script:
```sql
-- Run this in your Supabase SQL Editor
\i update_services_for_image_upload.sql
```

### Step 2: Configure Supabase Storage
Run the storage setup script:
```sql
-- Run this in your Supabase SQL Editor
\i admin/setup-storage.sql
```

### Step 3: Verify Storage Bucket
1. Go to your Supabase Dashboard
2. Navigate to Storage
3. Confirm the `service-images` bucket exists and is public
4. Check that RLS policies are properly configured

### Step 4: Test Image Upload
1. Go to Admin Dashboard → Services → Create Service
2. Try uploading an image using the new image upload component
3. Verify the image appears in the service listing

## Features

### Image Upload Component
- **Drag & Drop**: Users can drag images directly onto the upload area
- **Click to Upload**: Traditional file picker interface
- **Image Preview**: Shows uploaded image with option to change or remove
- **Validation**: Checks file type and size before upload
- **Progress Feedback**: Shows upload status with toast notifications

### Supported Formats
- JPEG (.jpg, .jpeg)
- PNG (.png)
- WebP (.webp)
- GIF (.gif)

### File Size Limits
- Maximum: 5MB per image
- Recommended: Under 2MB for optimal performance

## Usage

### Creating a New Service
1. Navigate to Services → Create Service
2. Fill in service details
3. Use the image upload component to add a service image
4. The image will be automatically uploaded to Supabase Storage
5. Save the service

### Editing an Existing Service
1. Navigate to Services → Click Edit on any service
2. The current image (if any) will be displayed
3. You can change the image by uploading a new one
4. Or remove the image entirely
5. Save changes

### Image Display
- Images are displayed in the services grid
- Fallback to a default icon if no image is uploaded
- Images are automatically optimized for display

## Technical Details

### Storage Structure
```
service-images/
├── 1704123456789-abc123.jpg
├── 1704123567890-def456.png
└── ...
```

### Database Fields
```sql
-- New image-related fields
image_path TEXT,        -- Storage path: "service-images/filename.jpg"
image_filename TEXT,    -- Original filename
image_size INTEGER,     -- File size in bytes
image_type TEXT,        -- MIME type: "image/jpeg"

-- Legacy field (kept for compatibility)
image_url TEXT          -- Direct URL or external image URL
```

### Image URL Generation
The system automatically generates public URLs for uploaded images using Supabase Storage's `getPublicUrl()` method.

## Troubleshooting

### Upload Fails
1. Check file size (must be under 5MB)
2. Verify file format is supported
3. Ensure Supabase Storage bucket exists and is properly configured
4. Check browser console for detailed error messages

### Images Not Displaying
1. Verify the storage bucket is public
2. Check RLS policies allow public read access
3. Ensure the image path is correctly stored in the database

### Permission Errors
1. Confirm user is authenticated
2. Check RLS policies for storage operations
3. Verify admin user has proper permissions

## Migration from URL-based Images

Existing services with `image_url` values will continue to work. The system checks both `image_url` and `image_path` fields when displaying images, prioritizing uploaded images over URL-based ones.

To migrate existing URL-based images to uploaded images:
1. Download the images from their current URLs
2. Edit each service and upload the downloaded image
3. The new uploaded image will take precedence

## Security Considerations

- All uploads are validated for file type and size
- RLS policies restrict upload/modify operations to authenticated users
- Public read access is enabled for displaying images
- File names are randomized to prevent conflicts and enhance security

## Performance Optimization

- Images are served directly from Supabase CDN
- Automatic compression and optimization by Supabase Storage
- Lazy loading in the services grid for better performance
- Proper indexing on image-related database fields