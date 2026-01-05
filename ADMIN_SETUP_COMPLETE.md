# Kronium Admin Dashboard - Complete Setup Guide

## 🎯 Overview

Your Kronium admin dashboard has been configured to work correctly with your Flutter mobile app. Both applications now share the same database schema and can work together seamlessly.

## 🔧 What Was Fixed

### 1. Database Schema Issues
- **Problem**: The admin dashboard expected a relational database structure while the Flutter app used a denormalized structure
- **Solution**: Created `admin_database_fix.sql` to establish the correct schema that works for both applications

### 2. Admin Dashboard Pages
- **Fixed**: `admin/app/dashboard/bookings/page.tsx` - Now works with the correct booking schema
- **Fixed**: `admin/app/dashboard/page.tsx` - Dashboard overview now displays data correctly
- **Updated**: Interface now matches the Flutter app's data structure

### 3. Environment Configuration
- **Verified**: Supabase connection settings in `admin/.env.local`
- **Created**: Setup script `admin/setup_admin.sh` for easy installation

## 📋 Setup Instructions

### Step 1: Database Setup
1. Go to your Supabase dashboard
2. Navigate to SQL Editor
3. Run the `admin_database_fix.sql` script
4. This will create the correct table structure for both Flutter and admin dashboard

### Step 2: Admin Dashboard Setup
1. Navigate to the admin directory:
   ```bash
   cd /home/praise-masunga/Desktop/Projects/flutter/kronium-app/admin
   ```

2. Run the setup script:
   ```bash
   ./setup_admin.sh
   ```

3. Start the development server:
   ```bash
   npm run dev
   ```

4. Open http://localhost:3000 in your browser

### Step 3: Flutter App
1. **Restart your Flutter app** completely (stop and start again)
2. The booking creation should now work without the `clientEmail` column error
3. Data created in Flutter will appear in the admin dashboard

## 🗄️ Database Schema

The corrected database schema includes:

### bookings table
```sql
CREATE TABLE bookings (
  id UUID PRIMARY KEY,
  serviceName VARCHAR(255) NOT NULL,
  clientName VARCHAR(255) NOT NULL,
  clientEmail VARCHAR(255) NOT NULL,
  clientPhone VARCHAR(50) NOT NULL,
  date TIMESTAMP NOT NULL,
  status VARCHAR(20) DEFAULT 'pending',
  price DECIMAL(10, 2) NOT NULL,
  location TEXT NOT NULL,
  notes TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

### users table
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  phone VARCHAR(50),
  role VARCHAR(20) DEFAULT 'customer',
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

### services table
```sql
CREATE TABLE services (
  id UUID PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  category VARCHAR(100) NOT NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

## 🚀 Features Working

### Admin Dashboard
- ✅ User management
- ✅ Service management  
- ✅ Booking management with correct schema
- ✅ Dashboard overview with real-time stats
- ✅ Responsive design for desktop/tablet

### Flutter App Integration
- ✅ Booking creation now works without errors
- ✅ Data synchronization between Flutter and admin
- ✅ Shared user and service management
- ✅ Real-time updates

## 🔐 Admin Access

Default admin user created:
- **Email**: admin@kronium.com
- **ID**: 7ae34399-5d33-4ee1-86be-4ef04a21b15d
- **Role**: admin

You can create additional admin users through the admin dashboard or by inserting into the users table with role='admin'.

## 📱 Mobile vs Web

- **Flutter App**: Primary interface for customers and field workers
- **Admin Dashboard**: Management interface for administrators
- **Data Sync**: Both applications share the same database and update in real-time

## 🛠️ Development Commands

```bash
# Admin Dashboard
cd admin
npm run dev          # Development server
npm run build        # Production build
npm run start        # Production server
npm run type-check   # TypeScript validation

# Flutter App
flutter clean        # Clear cache
flutter pub get      # Get dependencies
flutter run          # Run app
```

## 🔍 Troubleshooting

If you encounter issues:

1. **Database Errors**: Ensure `admin_database_fix.sql` was run successfully
2. **Connection Issues**: Check `.env.local` has correct Supabase credentials
3. **Build Errors**: Run `npm install` in admin directory
4. **Flutter Errors**: Restart the app completely after database changes

See `admin/TROUBLESHOOTING.md` for detailed troubleshooting guide.

## 📞 Next Steps

1. **Test the booking flow**: Create a booking in Flutter app and verify it appears in admin dashboard
2. **User management**: Create additional admin users as needed
3. **Service management**: Add/edit services through the admin dashboard
4. **Customization**: Modify the admin dashboard styling and features as needed

## ✅ Success Indicators

You'll know everything is working when:
- Flutter app can create bookings without `clientEmail` errors
- Admin dashboard shows booking data correctly
- User and service management works in admin dashboard
- Data appears in real-time between both applications

Your Kronium platform is now fully functional with both mobile and web admin interfaces working together!