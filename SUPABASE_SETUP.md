# Supabase Backend Setup Guide

## Overview

This application uses Supabase as the complete backend solution for:
- **Authentication** - User and admin authentication
- **Database** - PostgreSQL database for all data storage
- **Storage** - File storage for images and videos
- **Real-time** - Real-time subscriptions for live updates

## Project Configuration

**Project URL:** `https://ebbrnljnmtoxnxiknfqp.supabase.co`  
**Anon Key:** Configured in `lib/core/supabase_config.dart`

## Database Schema

### 1. Users Table (`users`)

```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  simpleId VARCHAR(4),
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  phone VARCHAR(50),
  profileImage TEXT,
  address TEXT,
  createdAt TIMESTAMP DEFAULT NOW(),
  updatedAt TIMESTAMP DEFAULT NOW(),
  isActive BOOLEAN DEFAULT true,
  favoriteServices JSONB DEFAULT '[]'::jsonb,
  role VARCHAR(20) DEFAULT 'customer' -- 'customer' or 'admin'
);
```

### 2. Admins Table (`admins`)

```sql
CREATE TABLE admins (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  company_name VARCHAR(255),
  role VARCHAR(20) DEFAULT 'admin',
  created_at TIMESTAMP DEFAULT NOW()
);
```

### 3. Services Table (`services`)

```sql
CREATE TABLE services (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title VARCHAR(255) NOT NULL,
  description TEXT,
  category VARCHAR(100),
  price DECIMAL(10, 2),
  duration INTEGER, -- in minutes
  imageUrl TEXT,
  videoUrl TEXT,
  isActive BOOLEAN DEFAULT true,
  createdAt TIMESTAMP DEFAULT NOW(),
  updatedAt TIMESTAMP DEFAULT NOW()
);
```

### 4. Bookings Table (`bookings`)

```sql
CREATE TABLE bookings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  serviceName VARCHAR(255) NOT NULL,
  clientName VARCHAR(255) NOT NULL,
  clientEmail VARCHAR(255) NOT NULL,
  clientPhone VARCHAR(50) NOT NULL,
  date TIMESTAMP NOT NULL,
  status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'confirmed', 'inProgress', 'completed', 'cancelled'
  price DECIMAL(10, 2) NOT NULL,
  location TEXT NOT NULL,
  notes TEXT,
  createdAt TIMESTAMP DEFAULT NOW(),
  updatedAt TIMESTAMP DEFAULT NOW()
);
```

### 5. Projects Table (`projects`)

```sql
CREATE TABLE projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title VARCHAR(255) NOT NULL,
  description TEXT,
  clientName VARCHAR(255) NOT NULL,
  clientEmail VARCHAR(255) NOT NULL,
  clientPhone VARCHAR(50) NOT NULL,
  location TEXT NOT NULL,
  size VARCHAR(100), -- e.g. "10 acres", "500 sqm"
  status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'active', 'completed', 'cancelled'
  progress DECIMAL(5, 2) DEFAULT 0, -- 0-100
  mediaUrls JSONB DEFAULT '[]'::jsonb,
  updates JSONB DEFAULT '[]'::jsonb, -- Array of project updates
  createdAt TIMESTAMP DEFAULT NOW(),
  updatedAt TIMESTAMP DEFAULT NOW()
);
```

### 6. Chat Rooms Table (`chat_rooms`)

```sql
CREATE TABLE chat_rooms (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customerId VARCHAR(255) NOT NULL,
  customerName VARCHAR(255) NOT NULL,
  customerEmail VARCHAR(255) NOT NULL,
  lastMessageAt TIMESTAMP,
  createdAt TIMESTAMP DEFAULT NOW()
);
```

### 7. Chat Messages Table (`chat_messages`)

```sql
CREATE TABLE chat_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chatRoomId UUID REFERENCES chat_rooms(id) ON DELETE CASCADE,
  senderId VARCHAR(255) NOT NULL,
  senderName VARCHAR(255) NOT NULL,
  senderType VARCHAR(20) NOT NULL, -- 'customer' or 'admin'
  message TEXT NOT NULL,
  timestamp TIMESTAMP DEFAULT NOW(),
  read BOOLEAN DEFAULT false
);
```

## Storage Buckets

### Public Bucket (`public`)

Used for storing:
- Service images (`service_images/`)
- Service videos (`service_videos/`)
- Project media (`project_media/`)
- User profile images (`profile_images/`)

**Setup:**
1. Go to Supabase Dashboard → Storage
2. Create a bucket named `public`
3. Make it public (allow public access)
4. Configure CORS if needed

## Row Level Security (RLS) Policies

### Recommended RLS Policies

#### Users Table
```sql
-- Users can read their own data
CREATE POLICY "Users can read own data" ON users
  FOR SELECT USING (auth.uid()::text = id::text);

-- Users can update their own data
CREATE POLICY "Users can update own data" ON users
  FOR UPDATE USING (auth.uid()::text = id::text);

-- Admins can read all users
CREATE POLICY "Admins can read all users" ON users
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM admins WHERE user_id::text = auth.uid()::text
    )
  );
```

#### Services Table
```sql
-- Everyone can read active services
CREATE POLICY "Anyone can read active services" ON services
  FOR SELECT USING (isActive = true);

-- Only admins can insert/update/delete services
CREATE POLICY "Admins can manage services" ON services
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM admins WHERE user_id::text = auth.uid()::text
    )
  );
```

#### Bookings Table
```sql
-- Users can read their own bookings (by email match)
CREATE POLICY "Users can read own bookings" ON bookings
  FOR SELECT USING (
    clientEmail = (SELECT email FROM users WHERE id::text = auth.uid()::text)
  );

-- Anyone can create bookings
CREATE POLICY "Anyone can create bookings" ON bookings
  FOR INSERT WITH CHECK (true);

-- Admins can read all bookings
CREATE POLICY "Admins can read all bookings" ON bookings
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM admins WHERE user_id::text = auth.uid()::text
    )
  );
```

#### Chat Messages
```sql
-- Users can read messages in their chat rooms
CREATE POLICY "Users can read own messages" ON chat_messages
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM chat_rooms 
      WHERE id = chat_messages.chatRoomId 
      AND (customerId = auth.uid()::text OR senderId = auth.uid()::text)
    )
  );

-- Users can send messages
CREATE POLICY "Users can send messages" ON chat_messages
  FOR INSERT WITH CHECK (senderId = auth.uid()::text);
```

## Authentication Setup

### Enable Email Authentication

1. Go to Supabase Dashboard → Authentication → Providers
2. Enable "Email" provider
3. Configure email templates if needed

### Password Reset

1. Go to Authentication → Email Templates
2. Customize "Reset Password" template
3. Set redirect URL (e.g., `yourapp://reset-password`)

## Real-time Setup

Enable real-time for tables that need live updates:

```sql
-- Enable realtime for specific tables
ALTER PUBLICATION supabase_realtime ADD TABLE users;
ALTER PUBLICATION supabase_realtime ADD TABLE services;
ALTER PUBLICATION supabase_realtime ADD TABLE bookings;
ALTER PUBLICATION supabase_realtime ADD TABLE projects;
ALTER PUBLICATION supabase_realtime ADD TABLE chat_rooms;
ALTER PUBLICATION supabase_realtime ADD TABLE chat_messages;
```

## Environment Variables (Optional)

For better security, move credentials to environment variables:

```dart
// .env file
SUPABASE_URL=https://ebbrnljnmtoxnxiknfqp.supabase.co
SUPABASE_ANON_KEY=your_anon_key_here
```

Then use `flutter_dotenv` package to load them.

## Testing Checklist

- [ ] Database tables created
- [ ] Storage bucket created and configured
- [ ] RLS policies enabled
- [ ] Email authentication enabled
- [ ] Real-time enabled for required tables
- [ ] Test user registration
- [ ] Test user login
- [ ] Test admin account creation
- [ ] Test file uploads
- [ ] Test real-time subscriptions
- [ ] Test password reset

## Migration from Firebase

All Firebase code has been removed. The application now uses:
- Supabase Auth instead of Firebase Auth
- Supabase Database instead of Firestore
- Supabase Storage instead of Firebase Storage
- Supabase Real-time instead of Firestore streams

## Support

For issues or questions:
1. Check Supabase documentation: https://supabase.com/docs
2. Check Flutter Supabase docs: https://supabase.com/docs/reference/dart/introduction
3. Review error logs in Supabase Dashboard







