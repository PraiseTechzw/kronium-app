# Supabase Storage Setup Guide

## Overview

This guide explains how to set up Supabase Storage for the Kronium application. The storage system handles all file uploads including profile images, service media, project documents, and chat attachments.

## Quick Setup

### Step 1: Create Storage Bucket via SQL

Run the `storage_setup.sql` script in your Supabase SQL Editor:

```bash
# In Supabase Dashboard → SQL Editor
# Copy and paste the entire contents of database/storage_setup.sql
# Click "Run"
```

### Step 2: Set Up Storage Policies

Run the `storage_policies.sql` script for detailed access control:

```bash
# In Supabase Dashboard → SQL Editor
# Copy and paste the entire contents of database/storage_policies.sql
# Click "Run"
```

### Step 3: Verify Setup

Check that the bucket was created:

```sql
SELECT * FROM storage.buckets WHERE id = 'public';
```

## Storage Structure

The application uses the following folder structure:

```
public/
├── profile_images/          # User profile pictures
│   └── {userId}/           # Organized by user ID
├── service_images/          # Service listing images
├── service_videos/          # Service demonstration videos
├── project_media/           # Project photos and videos
├── project_documents/       # Project-related documents
├── booking_attachments/     # Booking-related files
└── chat_attachments/        # Chat message attachments
```

## Manual Setup (Alternative)

If you prefer to set up via the Supabase Dashboard:

### 1. Create Public Bucket

1. Go to **Storage** in Supabase Dashboard
2. Click **New Bucket**
3. Set bucket name: `public`
4. Make it **Public** (toggle enabled)
5. Set file size limit: `50 MB`
6. Click **Create Bucket**

### 2. Configure CORS

Add CORS configuration to allow uploads from your app:

```json
{
  "allowedOrigins": ["*"],
  "allowedMethods": ["GET", "POST", "PUT", "DELETE"],
  "allowedHeaders": ["*"],
  "exposeHeaders": ["ETag"],
  "maxAgeSeconds": 3600
}
```

### 3. Set Up Policies

Go to **Storage** → **Policies** and create policies for the `public` bucket:

#### Read Policy (Public Access)
- Policy Name: `Public Access`
- Allowed Operation: `SELECT`
- Policy Definition:
```sql
bucket_id = 'public'
```

#### Upload Policy (Authenticated Users)
- Policy Name: `Authenticated Upload`
- Allowed Operation: `INSERT`
- Policy Definition:
```sql
bucket_id = 'public' AND auth.role() = 'authenticated'
```

## File Upload Limits

- **Maximum file size**: 50 MB
- **Allowed image types**: JPEG, PNG, GIF, WebP
- **Allowed video types**: MP4, MPEG, QuickTime
- **Allowed document types**: PDF, DOC, DOCX

## Usage in Flutter App

The storage is accessed through `SupabaseService`:

```dart
// Upload image
final supabaseService = Get.find<SupabaseService>();
final file = File(imagePath);
final url = await supabaseService.uploadImage(file, 'service_images');

// Upload video
final videoUrl = await supabaseService.uploadVideo(file, 'service_videos');
```

## Access URLs

Files are accessible via public URLs:

```
https://{project-url}.supabase.co/storage/v1/object/public/public/{folder}/{filename}
```

Example:
```
https://ebbrnljnmtoxnxiknfqp.supabase.co/storage/v1/object/public/public/service_images/image123.jpg
```

## Storage Statistics

View storage usage by folder:

```sql
SELECT * FROM storage_stats;
```

This shows:
- File count per folder
- Total size in bytes and MB
- Organized by folder

## Cleanup Old Files

Delete files older than specified days:

```sql
-- Delete files older than 90 days from service_images folder
SELECT cleanup_old_files('service_images', 90);
```

## Troubleshooting

### Upload Fails

1. **Check bucket exists**:
   ```sql
   SELECT * FROM storage.buckets;
   ```

2. **Verify policies**:
   ```sql
   SELECT * FROM pg_policies WHERE tablename = 'objects';
   ```

3. **Check file size**: Ensure file is under 50 MB

4. **Verify authentication**: User must be logged in

### Access Denied

1. **Check RLS policies**: Ensure policies are correctly configured
2. **Verify user role**: Admin vs regular user permissions
3. **Check bucket public setting**: Should be enabled for public access

### Files Not Showing

1. **Check URL format**: Must match exact path structure
2. **Verify file exists**:
   ```sql
   SELECT * FROM storage.objects WHERE bucket_id = 'public';
   ```
3. **Check CORS**: Ensure CORS is configured correctly

## Security Considerations

1. **File Type Validation**: Only allowed MIME types are accepted
2. **File Size Limits**: 50 MB maximum per file
3. **Access Control**: RLS policies restrict access based on user roles
4. **Folder Organization**: Files are organized by type and user

## Monitoring

Monitor storage usage:

```sql
-- Total storage used
SELECT 
  pg_size_pretty(SUM((metadata->>'size')::bigint)) AS total_size
FROM storage.objects
WHERE bucket_id = 'public';

-- Files by folder
SELECT * FROM storage_stats;

-- Recent uploads
SELECT 
  name,
  created_at,
  (metadata->>'size')::bigint AS size_bytes
FROM storage.objects
WHERE bucket_id = 'public'
ORDER BY created_at DESC
LIMIT 10;
```

## Support

For issues:
- Check Supabase Storage logs
- Review RLS policies
- Verify bucket configuration
- Test file upload with small file first

