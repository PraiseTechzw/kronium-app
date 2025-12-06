# Database Setup Instructions

## Overview

This directory contains the complete database schema and seed data for the Kronium application.

## Files

- `schema.sql` - Complete database schema with tables, functions, triggers, and RLS policies
- `seeds.sql` - Initial seed data for testing and development

## ID Generation Format

User IDs are automatically generated in sequential order with the format:
- **Format**: `AAA00001` (3 uppercase letters + 5 sequential numbers)
- **Examples**: AAA00001, AAA00002, AAA00003, ..., AAA99999, AAB00001, AAB00002, etc.
- **Total Capacity**: 17,576 letter combinations × 99,999 numbers = 1,757,475,024 unique IDs

The IDs are generated automatically by the database trigger when a new user is created.

## Setup Steps

### 1. Create Database in Supabase

1. Go to your Supabase Dashboard
2. Navigate to SQL Editor
3. Create a new query

### 2. Run Schema Script

1. Copy the entire contents of `schema.sql`
2. Paste into Supabase SQL Editor
3. Click "Run" to execute

This will create:
- All database tables
- Functions for sequential ID generation
- Triggers for auto-generating IDs
- Row Level Security (RLS) policies
- Real-time subscriptions

### 3. Run Seed Data (Optional)

1. Copy the entire contents of `seeds.sql`
2. Paste into Supabase SQL Editor
3. Click "Run" to execute

This will populate the database with:
- Sample users
- Admin account
- Sample services
- Sample bookings
- Sample projects
- Sample chat data

## Verification

After running the schema, verify the setup:

```sql
-- Check if tables exist
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public'
ORDER BY table_name;

-- Check if functions exist
SELECT routine_name 
FROM information_schema.routines 
WHERE routine_schema = 'public'
ORDER BY routine_name;

-- Test ID generation (should return AAA00001)
SELECT generate_sequential_id();
```

## Admin Account

The seed data creates an admin account:
- **Email**: admin@kronium.com
- **Password**: Set through Supabase Auth (use dashboard or app)
- **Role**: admin

## Storage Setup

Don't forget to:
1. Create a storage bucket named `public`
2. Make it public (allow public access)
3. Configure CORS if needed

Go to: Supabase Dashboard → Storage → New Bucket

## Troubleshooting

### IDs Not Generating

If IDs aren't being generated automatically:
1. Check if the trigger exists:
   ```sql
   SELECT * FROM pg_trigger WHERE tgname = 'trigger_auto_generate_user_id';
   ```
2. Verify the function exists:
   ```sql
   SELECT generate_sequential_id();
   ```

### RLS Blocking Access

If you can't access data:
1. Temporarily disable RLS for testing:
   ```sql
   ALTER TABLE users DISABLE ROW LEVEL SECURITY;
   ```
2. Then re-enable and adjust policies as needed

## Next Steps

After database setup:
1. Configure authentication providers in Supabase Dashboard
2. Set up email templates for password reset
3. Upload service images to storage bucket
4. Test the application with seed data

## Support

For issues:
- Check Supabase logs in Dashboard
- Review RLS policies if access is denied
- Verify triggers are enabled

