-- ============================================================================
-- KRONIUM APP - SEED DATA
-- ============================================================================
-- This file contains seed data for initial database setup
-- ============================================================================

-- ============================================================================
-- SEED USERS (Customers)
-- ============================================================================
INSERT INTO users (name, email, phone, role, isActive) VALUES
  ('John Doe', 'john.doe@example.com', '+1234567890', 'customer', true),
  ('Jane Smith', 'jane.smith@example.com', '+1234567891', 'customer', true),
  ('Mike Johnson', 'mike.johnson@example.com', '+1234567892', 'customer', true),
  ('Sarah Williams', 'sarah.williams@example.com', '+1234567893', 'customer', true),
  ('David Brown', 'david.brown@example.com', '+1234567894', 'customer', true)
ON CONFLICT (email) DO NOTHING;

-- ============================================================================
-- SEED ADMIN USER
-- ============================================================================
INSERT INTO users (name, email, phone, role, isActive) VALUES
  ('Admin User', 'admin@kronium.com', '+1234567899', 'admin', true)
ON CONFLICT (email) DO NOTHING;

-- Create admin entry (link to admin user)
INSERT INTO admins (user_id, name, email, company_name, role)
SELECT id, name, email, 'Kronium Engineering', 'admin'
FROM users
WHERE email = 'admin@kronium.com' AND role = 'admin'
ON CONFLICT (email) DO NOTHING;

-- ============================================================================
-- SEED SERVICES
-- ============================================================================
INSERT INTO services (title, description, category, price, duration, isActive) VALUES
  (
    'Site Survey & Analysis',
    'Comprehensive site survey and analysis for engineering projects. Includes soil testing, topography mapping, and environmental assessment.',
    'Engineering',
    500.00,
    480, -- 8 hours
    true
  ),
  (
    'Structural Design',
    'Complete structural design services for buildings and infrastructure. Includes calculations, drawings, and engineering reports.',
    'Engineering',
    1500.00,
    2400, -- 40 hours
    true
  ),
  (
    'Construction Supervision',
    'On-site construction supervision and quality control. Daily site visits and progress reports included.',
    'Construction',
    800.00,
    480, -- 8 hours per day
    true
  ),
  (
    'Project Management',
    'Full project management services including planning, scheduling, budgeting, and coordination of all stakeholders.',
    'Management',
    1200.00,
    2400, -- 40 hours per week
    true
  ),
  (
    'Electrical Systems Design',
    'Complete electrical systems design for residential and commercial projects. Includes lighting, power distribution, and safety systems.',
    'Engineering',
    900.00,
    1600, -- ~27 hours
    true
  ),
  (
    'Plumbing Design',
    'Comprehensive plumbing design including water supply, drainage, and sewage systems. Meets all local building codes.',
    'Engineering',
    750.00,
    1200, -- 20 hours
    true
  ),
  (
    'HVAC Design',
    'Heating, ventilation, and air conditioning system design. Energy-efficient solutions with modern technology.',
    'Engineering',
    850.00,
    1400, -- ~23 hours
    true
  ),
  (
    'Building Permits Assistance',
    'Complete assistance with building permit applications, documentation, and approvals from local authorities.',
    'Administrative',
    400.00,
    240, -- 4 hours
    true
  ),
  (
    'Environmental Impact Assessment',
    'Comprehensive environmental impact assessment for construction projects. Includes reports and regulatory compliance.',
    'Engineering',
    1100.00,
    2000, -- ~33 hours
    true
  ),
  (
    'Cost Estimation',
    'Detailed cost estimation for construction projects. Includes material, labor, and equipment costs with breakdowns.',
    'Management',
    600.00,
    800, -- ~13 hours
    true
  )
ON CONFLICT DO NOTHING;

-- ============================================================================
-- SEED BOOKINGS (Sample Bookings)
-- ============================================================================
INSERT INTO bookings (serviceName, clientName, clientEmail, clientPhone, date, status, price, location, notes) VALUES
  (
    'Site Survey & Analysis',
    'John Doe',
    'john.doe@example.com',
    '+1234567890',
    NOW() + INTERVAL '7 days',
    'confirmed',
    500.00,
    '123 Main Street, City, State 12345',
    'Property is located on a hillside. Need slope analysis.'
  ),
  (
    'Structural Design',
    'Jane Smith',
    'jane.smith@example.com',
    '+1234567891',
    NOW() + INTERVAL '14 days',
    'pending',
    1500.00,
    '456 Oak Avenue, City, State 12346',
    'Residential building with 3 floors. Need complete structural design.'
  ),
  (
    'Construction Supervision',
    'Mike Johnson',
    'mike.johnson@example.com',
    '+1234567892',
    NOW() + INTERVAL '3 days',
    'inProgress',
    800.00,
    '789 Pine Road, City, State 12347',
    'Ongoing construction project. Daily supervision required.'
  ),
  (
    'Project Management',
    'Sarah Williams',
    'sarah.williams@example.com',
    '+1234567893',
    NOW() + INTERVAL '21 days',
    'pending',
    1200.00,
    '321 Elm Street, City, State 12348',
    'New commercial development. Full project management needed.'
  ),
  (
    'Electrical Systems Design',
    'David Brown',
    'david.brown@example.com',
    '+1234567894',
    NOW() + INTERVAL '10 days',
    'confirmed',
    900.00,
    '654 Maple Drive, City, State 12349',
    'Commercial building electrical design. Energy-efficient solutions preferred.'
  )
ON CONFLICT DO NOTHING;

-- ============================================================================
-- SEED PROJECTS (Sample Projects)
-- ============================================================================
INSERT INTO projects (title, description, clientName, clientEmail, clientPhone, location, size, status, progress) VALUES
  (
    'Residential Complex Development',
    'Development of a 50-unit residential complex with modern amenities and sustainable design.',
    'John Doe',
    'john.doe@example.com',
    '+1234567890',
    '123 Main Street, City, State 12345',
    '5 acres',
    'active',
    45.5
  ),
  (
    'Commercial Office Building',
    'Design and construction of a 10-story commercial office building in downtown area.',
    'Jane Smith',
    'jane.smith@example.com',
    '+1234567891',
    '456 Oak Avenue, City, State 12346',
    '10,000 sqm',
    'active',
    28.3
  ),
  (
    'Industrial Warehouse Facility',
    'Construction of a 20,000 sqm industrial warehouse with loading docks and office space.',
    'Mike Johnson',
    'mike.johnson@example.com',
    '+1234567892',
    '789 Pine Road, City, State 12347',
    '8 acres',
    'pending',
    0.0
  ),
  (
    'Shopping Mall Renovation',
    'Complete renovation and modernization of existing shopping mall infrastructure.',
    'Sarah Williams',
    'sarah.williams@example.com',
    '+1234567893',
    '321 Elm Street, City, State 12348',
    '15,000 sqm',
    'active',
    72.8
  ),
  (
    'Mixed-Use Development',
    'Mixed-use development combining retail, residential, and office spaces in urban setting.',
    'David Brown',
    'david.brown@example.com',
    '+1234567894',
    '654 Maple Drive, City, State 12349',
    '3 acres',
    'active',
    15.2
  )
ON CONFLICT DO NOTHING;

-- ============================================================================
-- SEED CHAT ROOMS (Sample Chat Rooms)
-- ============================================================================
-- Note: These will be created automatically when users start chatting
-- This is just sample data for testing
INSERT INTO chat_rooms (customerId, customerName, customerEmail, lastMessageAt)
SELECT 
  id::text,
  name,
  email,
  NOW()
FROM users
WHERE role = 'customer'
LIMIT 3
ON CONFLICT DO NOTHING;

-- ============================================================================
-- SEED CHAT MESSAGES (Sample Messages)
-- ============================================================================
INSERT INTO chat_messages (chatRoomId, senderId, senderName, senderType, message, timestamp)
SELECT 
  cr.id,
  cr.customerId,
  cr.customerName,
  'customer',
  'Hello, I need help with my project.',
  NOW() - INTERVAL '2 days'
FROM chat_rooms cr
LIMIT 3
ON CONFLICT DO NOTHING;

INSERT INTO chat_messages (chatRoomId, senderId, senderName, senderType, message, timestamp)
SELECT 
  cr.id,
  'admin-user-id', -- Replace with actual admin user ID
  'Admin User',
  'admin',
  'Hello! I am here to help you with your project. What would you like to know?',
  NOW() - INTERVAL '1 day'
FROM chat_rooms cr
LIMIT 3
ON CONFLICT DO NOTHING;

-- ============================================================================
-- UPDATE SERVICE IMAGES (After uploading images to storage)
-- ============================================================================
-- Note: Update these URLs after uploading actual images to Supabase Storage
-- Example:
-- UPDATE services SET imageUrl = 'https://your-project.supabase.co/storage/v1/object/public/public/service_images/service1.jpg' WHERE title = 'Site Survey & Analysis';

-- ============================================================================
-- END OF SEED DATA
-- ============================================================================

