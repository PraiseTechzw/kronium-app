-- Fix Bookings Table Schema
-- This script will update the bookings table to match the Flutter app expectations

-- First, check if bookings table exists and show its structure
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'bookings') THEN
        RAISE NOTICE 'Bookings table exists, dropping it...';
    ELSE
        RAISE NOTICE 'Bookings table does not exist, creating new one...';
    END IF;
END $$;

-- Drop the existing bookings table and recreate with correct structure
DROP TABLE IF EXISTS bookings CASCADE;

-- Create the correct bookings table structure
CREATE TABLE bookings (
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

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_bookings_status ON bookings(status);
CREATE INDEX IF NOT EXISTS idx_bookings_clientEmail ON bookings(clientEmail);
CREATE INDEX IF NOT EXISTS idx_bookings_date ON bookings(date);

-- Enable Row Level Security
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;

-- Create RLS Policies
CREATE POLICY "Anyone can create bookings" ON bookings
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Users can read own bookings" ON bookings
  FOR SELECT USING (
    clientEmail = (SELECT email FROM users WHERE id::text = auth.uid()::text)
  );

CREATE POLICY "Allow booking management" ON bookings
  FOR ALL USING (true);

-- Add update trigger
CREATE TRIGGER update_bookings_updated_at BEFORE UPDATE ON bookings
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Enable real-time
ALTER PUBLICATION supabase_realtime ADD TABLE bookings;

SELECT 'Bookings table schema fixed successfully!' as message;