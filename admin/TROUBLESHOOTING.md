# Kronium Admin Dashboard Troubleshooting Guide

## Common Issues and Solutions

### 1. Database Schema Issues

**Problem**: Getting errors like "Could not find the 'clientEmail' column"

**Solution**:
1. Run the `admin_database_fix.sql` script in your Supabase SQL Editor
2. This will create the correct table structure for both Flutter app and admin dashboard
3. Restart your Flutter app after running the SQL script

### 2. Authentication Issues

**Problem**: Can't login to admin dashboard

**Solutions**:
- Ensure you have an admin user in the database:
  ```sql
  INSERT INTO users (id, name, email, role, is_active) 
  VALUES (
    '7ae34399-5d33-4ee1-86be-4ef04a21b15d',
    'Admin User',
    'admin@kronium.com',
    'admin',
    true
  );
  ```
- Check your Supabase Auth settings
- Verify environment variables in `.env.local`

### 3. Environment Configuration

**Problem**: Dashboard not connecting to Supabase

**Check**:
1. `.env.local` file exists and has correct values:
   ```env
   NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
   NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
   ```
2. Supabase project is active and accessible
3. RLS policies allow admin access

### 4. Build Errors

**Problem**: TypeScript or build errors

**Solutions**:
1. Run `npm install` to ensure all dependencies are installed
2. Run `npm run type-check` to identify TypeScript issues
3. Check for missing imports or type definitions
4. Ensure all components are properly exported

### 5. Data Not Loading

**Problem**: Dashboard shows empty data or loading states

**Check**:
1. Database tables exist and have data
2. RLS policies allow reading data
3. Network tab in browser dev tools for API errors
4. Console for JavaScript errors

### 6. Mobile Responsiveness

**Problem**: Dashboard not working on mobile

**Solutions**:
- The dashboard is designed for desktop/tablet use primarily
- For mobile management, use the Flutter app
- Ensure viewport meta tag is present in layout

### 7. Performance Issues

**Problem**: Dashboard is slow

**Solutions**:
1. Check database indexes are created
2. Optimize queries in dashboard components
3. Use pagination for large datasets
4. Enable Supabase connection pooling

## Development Setup

### Prerequisites
- Node.js 18+
- npm or yarn
- Supabase account and project

### Setup Steps
1. Navigate to admin directory: `cd admin`
2. Run setup script: `./setup_admin.sh`
3. Update `.env.local` with your Supabase credentials
4. Run database fix script in Supabase SQL Editor
5. Start development server: `npm run dev`

## Database Schema Requirements

The admin dashboard expects these tables:

### users
- id (UUID, Primary Key)
- name (VARCHAR)
- email (VARCHAR, Unique)
- phone (VARCHAR)
- role (VARCHAR) - 'customer', 'admin', 'manager', 'technician'
- is_active (BOOLEAN)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)

### services
- id (UUID, Primary Key)
- title (VARCHAR)
- description (TEXT)
- price (DECIMAL)
- category (VARCHAR)
- is_active (BOOLEAN)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)

### bookings
- id (UUID, Primary Key)
- serviceName (VARCHAR)
- clientName (VARCHAR)
- clientEmail (VARCHAR)
- clientPhone (VARCHAR)
- date (TIMESTAMP)
- status (VARCHAR)
- price (DECIMAL)
- location (TEXT)
- notes (TEXT)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)

### projects
- id (UUID, Primary Key)
- title (VARCHAR)
- description (TEXT)
- clientName (VARCHAR)
- clientEmail (VARCHAR)
- clientPhone (VARCHAR)
- location (TEXT)
- status (VARCHAR)
- progress (DECIMAL)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)

## Useful Commands

```bash
# Development
npm run dev          # Start development server
npm run build        # Build for production
npm run start        # Start production server
npm run lint         # Run linting
npm run type-check   # Check TypeScript

# Debugging
npm run build -- --debug    # Build with debug info
```

## Getting Help

1. Check browser console for JavaScript errors
2. Check Network tab for API request failures
3. Verify Supabase logs for database issues
4. Ensure all environment variables are set correctly
5. Run the setup script to verify configuration

## Integration with Flutter App

The admin dashboard shares the same database with the Flutter app:
- Changes in admin dashboard appear in Flutter app
- Bookings created in Flutter app appear in admin dashboard
- User management affects both platforms
- Service management is centralized

Make sure both applications use the same Supabase project and database schema.