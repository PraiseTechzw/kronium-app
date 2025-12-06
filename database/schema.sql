-- ============================================================================
-- KRONIUM APP - COMPLETE DATABASE SCHEMA
-- ============================================================================
-- This file contains all database tables, functions, and triggers for the
-- complete Kronium application backend.
-- ============================================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- 1. USERS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  simpleId VARCHAR(8) UNIQUE, -- Format: ABC12345 (3 letters + 5 numbers)
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

-- Index for faster lookups
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_simpleId ON users(simpleId);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);

-- ============================================================================
-- 2. ADMINS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS admins (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  company_name VARCHAR(255),
  role VARCHAR(20) DEFAULT 'admin',
  created_at TIMESTAMP DEFAULT NOW(),
  CONSTRAINT fk_admin_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_admins_user_id ON admins(user_id);
CREATE INDEX IF NOT EXISTS idx_admins_email ON admins(email);

-- ============================================================================
-- 3. SERVICES TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS services (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
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

CREATE INDEX IF NOT EXISTS idx_services_category ON services(category);
CREATE INDEX IF NOT EXISTS idx_services_isActive ON services(isActive);

-- ============================================================================
-- 4. BOOKINGS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS bookings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
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

CREATE INDEX IF NOT EXISTS idx_bookings_status ON bookings(status);
CREATE INDEX IF NOT EXISTS idx_bookings_clientEmail ON bookings(clientEmail);
CREATE INDEX IF NOT EXISTS idx_bookings_date ON bookings(date);

-- ============================================================================
-- 5. PROJECTS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS projects (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title VARCHAR(255) NOT NULL,
  description TEXT,
  clientName VARCHAR(255) NOT NULL,
  clientEmail VARCHAR(255) NOT NULL,
  clientPhone VARCHAR(50) NOT NULL,
  location TEXT NOT NULL,
  size VARCHAR(100), -- e.g. "10 acres", "500 sqm"
  status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'active', 'completed', 'cancelled'
  progress DECIMAL(5, 2) DEFAULT 0 CHECK (progress >= 0 AND progress <= 100),
  mediaUrls JSONB DEFAULT '[]'::jsonb,
  projectMedia JSONB DEFAULT '[]'::jsonb,
  updates JSONB DEFAULT '[]'::jsonb, -- Array of project updates
  bookedDates JSONB DEFAULT '[]'::jsonb,
  createdAt TIMESTAMP DEFAULT NOW(),
  updatedAt TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_projects_status ON projects(status);
CREATE INDEX IF NOT EXISTS idx_projects_clientEmail ON projects(clientEmail);

-- ============================================================================
-- 6. CHAT ROOMS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS chat_rooms (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  customerId VARCHAR(255) NOT NULL,
  customerName VARCHAR(255) NOT NULL,
  customerEmail VARCHAR(255) NOT NULL,
  lastMessageAt TIMESTAMP,
  createdAt TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_chat_rooms_customerId ON chat_rooms(customerId);
CREATE INDEX IF NOT EXISTS idx_chat_rooms_lastMessageAt ON chat_rooms(lastMessageAt);

-- ============================================================================
-- 7. CHAT MESSAGES TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS chat_messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  chatRoomId UUID REFERENCES chat_rooms(id) ON DELETE CASCADE,
  senderId VARCHAR(255) NOT NULL,
  senderName VARCHAR(255) NOT NULL,
  senderType VARCHAR(20) NOT NULL, -- 'customer' or 'admin'
  message TEXT NOT NULL,
  timestamp TIMESTAMP DEFAULT NOW(),
  read BOOLEAN DEFAULT false
);

CREATE INDEX IF NOT EXISTS idx_chat_messages_chatRoomId ON chat_messages(chatRoomId);
CREATE INDEX IF NOT EXISTS idx_chat_messages_timestamp ON chat_messages(timestamp);

-- ============================================================================
-- 8. SEQUENTIAL ID GENERATOR FUNCTION
-- ============================================================================
-- Function to generate sequential IDs in format: AAA00001 (3 letters + 5 numbers)
-- Format: 3 uppercase letters + 5 sequential numbers
CREATE OR REPLACE FUNCTION generate_sequential_id()
RETURNS VARCHAR(8) AS $$
DECLARE
  letter_prefix VARCHAR(3) := 'AAA'; -- Start with AAA
  next_number INTEGER;
  formatted_number VARCHAR(5);
  new_id VARCHAR(8);
  max_users_per_letter_set INTEGER := 99999; -- 5 digits = 99999 users per letter set
  current_letter_number INTEGER;
  letter_set VARCHAR(3);
BEGIN
  -- Get the highest existing number
  SELECT COALESCE(MAX(CAST(SUBSTRING(simpleId FROM 4 FOR 5) AS INTEGER)), 0)
  INTO next_number
  FROM users
  WHERE simpleId ~ '^[A-Z]{3}[0-9]{5}$'; -- Match format: 3 letters + 5 numbers
  
  -- Get current letter prefix from highest ID if exists
  SELECT SUBSTRING(simpleId FROM 1 FOR 3)
  INTO letter_prefix
  FROM users
  WHERE simpleId ~ '^[A-Z]{3}[0-9]{5}$'
  ORDER BY CAST(SUBSTRING(simpleId FROM 4 FOR 5) AS INTEGER) DESC
  LIMIT 1;
  
  -- If no existing IDs, start with AAA00001
  IF letter_prefix IS NULL THEN
    letter_prefix := 'AAA';
    next_number := 1;
  ELSE
    -- Check if we've reached max for current letter set
    SELECT COALESCE(MAX(CAST(SUBSTRING(simpleId FROM 4 FOR 5) AS INTEGER)), 0)
    INTO current_letter_number
    FROM users
    WHERE simpleId LIKE letter_prefix || '%'
      AND simpleId ~ '^[A-Z]{3}[0-9]{5}$';
    
    IF current_letter_number >= max_users_per_letter_set THEN
      -- Move to next letter set (AAA -> AAB -> AAC ... -> ZZZ)
      letter_prefix := increment_letter_prefix(letter_prefix);
      next_number := 1;
    ELSE
      next_number := current_letter_number + 1;
    END IF;
  END IF;
  
  -- Format number as 5 digits with leading zeros (00001, 00002, etc.)
  formatted_number := LPAD(next_number::TEXT, 5, '0');
  
  -- Combine: 3 letters + 5 numbers (e.g., AAA00001)
  new_id := letter_prefix || formatted_number;
  
  -- Ensure uniqueness (handle edge cases)
  WHILE EXISTS (SELECT 1 FROM users WHERE simpleId = new_id) LOOP
    next_number := next_number + 1;
    IF next_number > max_users_per_letter_set THEN
      letter_prefix := increment_letter_prefix(letter_prefix);
      next_number := 1;
    END IF;
    formatted_number := LPAD(next_number::TEXT, 5, '0');
    new_id := letter_prefix || formatted_number;
  END LOOP;
  
  RETURN new_id;
END;
$$ LANGUAGE plpgsql;

-- Helper function to increment letter prefix (AAA -> AAB -> ... -> ZZZ)
CREATE OR REPLACE FUNCTION increment_letter_prefix(prefix VARCHAR(3))
RETURNS VARCHAR(3) AS $$
DECLARE
  first_char CHAR(1);
  second_char CHAR(1);
  third_char CHAR(1);
  new_prefix VARCHAR(3);
BEGIN
  first_char := SUBSTRING(prefix FROM 1 FOR 1);
  second_char := SUBSTRING(prefix FROM 2 FOR 1);
  third_char := SUBSTRING(prefix FROM 3 FOR 1);
  
  -- Increment from right to left (like counting)
  IF third_char < 'Z' THEN
    third_char := CHR(ASCII(third_char) + 1);
  ELSIF second_char < 'Z' THEN
    second_char := CHR(ASCII(second_char) + 1);
    third_char := 'A';
  ELSIF first_char < 'Z' THEN
    first_char := CHR(ASCII(first_char) + 1);
    second_char := 'A';
    third_char := 'A';
  ELSE
    -- Wrap around to AAA (shouldn't happen in practice)
    first_char := 'A';
    second_char := 'A';
    third_char := 'A';
  END IF;
  
  new_prefix := first_char || second_char || third_char;
  RETURN new_prefix;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 9. TRIGGER TO AUTO-GENERATE SEQUENTIAL USER ID
-- ============================================================================
CREATE OR REPLACE FUNCTION auto_generate_user_id()
RETURNS TRIGGER AS $$
BEGIN
  -- Only generate if simpleId is not provided
  -- Format will be: AAA00001, AAA00002, ..., AAA99999, AAB00001, etc.
  IF NEW.simpleId IS NULL OR NEW.simpleId = '' THEN
    NEW.simpleId := generate_sequential_id();
  END IF;
  
  -- Update updatedAt on any update
  IF TG_OP = 'UPDATE' THEN
    NEW.updatedAt := NOW();
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_auto_generate_user_id
  BEFORE INSERT OR UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION auto_generate_user_id();

-- ============================================================================
-- 10. UPDATE TIMESTAMP TRIGGER FUNCTION
-- ============================================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updatedAt = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply update triggers to relevant tables
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_services_updated_at BEFORE UPDATE ON services
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_bookings_updated_at BEFORE UPDATE ON bookings
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_projects_updated_at BEFORE UPDATE ON projects
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- 11. ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================================================

-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE admins ENABLE ROW LEVEL SECURITY;
ALTER TABLE services ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;

-- Users Table Policies
CREATE POLICY "Users can insert own data" ON users
  FOR INSERT 
  WITH CHECK (auth.uid()::text = id::text);

CREATE POLICY "Users can read own data" ON users
  FOR SELECT USING (auth.uid()::text = id::text);

CREATE POLICY "Users can update own data" ON users
  FOR UPDATE USING (auth.uid()::text = id::text);

CREATE POLICY "Anyone can read active users" ON users
  FOR SELECT USING (isActive = true);

-- Services Table Policies
CREATE POLICY "Anyone can read active services" ON services
  FOR SELECT USING (isActive = true);

-- Bookings Table Policies
CREATE POLICY "Anyone can create bookings" ON bookings
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Users can read own bookings" ON bookings
  FOR SELECT USING (
    clientEmail = (SELECT email FROM users WHERE id::text = auth.uid()::text)
  );

-- Projects Table Policies
CREATE POLICY "Anyone can create projects" ON projects
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Users can read own projects" ON projects
  FOR SELECT USING (
    clientEmail = (SELECT email FROM users WHERE id::text = auth.uid()::text)
  );

-- Chat Rooms Policies
CREATE POLICY "Users can read own chat rooms" ON chat_rooms
  FOR SELECT USING (customerId = auth.uid()::text);

-- Chat Messages Policies
CREATE POLICY "Users can read messages in own chat rooms" ON chat_messages
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM chat_rooms 
      WHERE id = chat_messages.chatRoomId 
      AND (customerId = auth.uid()::text OR senderId = auth.uid()::text)
    )
  );

CREATE POLICY "Users can send messages" ON chat_messages
  FOR INSERT WITH CHECK (senderId = auth.uid()::text);

-- Admin policies (allow admins to access all data)
-- Note: This assumes you have a way to check admin status
-- You may need to adjust these based on your admin authentication setup

-- ============================================================================
-- 12. REAL-TIME ENABLEMENT
-- ============================================================================
-- Enable real-time for tables that need live updates
ALTER PUBLICATION supabase_realtime ADD TABLE users;
ALTER PUBLICATION supabase_realtime ADD TABLE services;
ALTER PUBLICATION supabase_realtime ADD TABLE bookings;
ALTER PUBLICATION supabase_realtime ADD TABLE projects;
ALTER PUBLICATION supabase_realtime ADD TABLE chat_rooms;
ALTER PUBLICATION supabase_realtime ADD TABLE chat_messages;

-- ============================================================================
-- END OF SCHEMA
-- ============================================================================

