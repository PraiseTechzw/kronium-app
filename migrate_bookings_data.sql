-- Migrate Bookings Data (Alternative approach if you want to preserve existing data)
-- This script will migrate from the relational structure to the denormalized structure

-- First, create a backup of existing bookings
CREATE TABLE bookings_backup AS SELECT * FROM bookings;

-- Create the new bookings table structure
CREATE TABLE bookings_new (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  serviceName VARCHAR(255) NOT NULL,
  clientName VARCHAR(255) NOT NULL,
  clientEmail VARCHAR(255) NOT NULL,
  clientPhone VARCHAR(50) NOT NULL,
  date TIMESTAMP NOT NULL,
  status VARCHAR(20) DEFAULT 'pending',
  price DECIMAL(10, 2) NOT NULL,
  location TEXT NOT NULL,
  notes TEXT,
  createdAt TIMESTAMP DEFAULT NOW(),
  updatedAt TIMESTAMP DEFAULT NOW()
);

-- Migrate existing data (if any exists)
INSERT INTO bookings_new (
  id, 
  serviceName, 
  clientName, 
  clientEmail, 
  clientPhone, 
  date, 
  status, 
  price, 
  location, 
  notes, 
  createdAt, 
  updatedAt
)
SELECT 
  b.id,
  COALESCE(s.title, 'Unknown Service') as serviceName,
  COALESCE(u.name, 'Unknown Client') as clientName,
  COALESCE(u.email, 'unknown@email.com') as clientEmail,
  COALESCE(u.phone, '') as clientPhone,
  b.booking_date as date,
  b.status,
  COALESCE(b.total_amount, 0) as price,
  COALESCE(b.notes, '') as location,
  COALESCE(b.notes, '') as notes,
  b.created_at as createdAt,
  b.updated_at as updatedAt
FROM bookings_backup b
LEFT JOIN users u ON b.user_id = u.id
LEFT JOIN services s ON b.service_id = s.id;

-- Drop old table and rename new one
DROP TABLE bookings CASCADE;
ALTER TABLE bookings_new RENAME TO bookings;

-- Create indexes
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

SELECT 'Bookings data migrated successfully!' as message;