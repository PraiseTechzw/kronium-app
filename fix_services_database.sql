-- Fix Services Database and Add Proper Categories
-- This script ensures services are properly set up with correct categories

-- First, let's check what services currently exist
SELECT 'Current services in database:' as info;
SELECT id, title, category, price, is_active FROM services ORDER BY category, title;

-- Clear existing services and recreate with proper data
DELETE FROM services;

-- Insert comprehensive services with correct categories matching Flutter app
INSERT INTO services (id, title, description, price, category, is_active, features, duration, location, created_at, updated_at) VALUES

-- Agriculture Category
(
  gen_random_uuid(),
  'Greenhouse Construction',
  'Professional greenhouse design and construction for optimal plant growth. Modern climate-controlled structures for year-round farming.',
  2500.00,
  'Agriculture',
  true,
  ARRAY['Climate Control', 'Automated Irrigation', 'UV Protection', 'Ventilation Systems'],
  '2-4 weeks',
  'On-site',
  NOW(),
  NOW()
),
(
  gen_random_uuid(),
  'Irrigation Systems',
  'Efficient irrigation solutions for farms and gardens. Smart water management systems for optimal crop yield.',
  1200.00,
  'Agriculture',
  true,
  ARRAY['Drip Irrigation', 'Smart Controllers', 'Water Sensors', 'Remote Monitoring'],
  '1-2 weeks',
  'Farm/Garden',
  NOW(),
  NOW()
),
(
  gen_random_uuid(),
  'Crop Monitoring Systems',
  'IoT-based crop monitoring with sensors for soil moisture, temperature, and nutrient levels.',
  800.00,
  'Agriculture',
  true,
  ARRAY['Soil Sensors', 'Weather Monitoring', 'Mobile App', 'Data Analytics'],
  '3-5 days',
  'Farm',
  NOW(),
  NOW()
),

-- Building/Construction Category
(
  gen_random_uuid(),
  'Construction',
  'Professional construction services for residential and commercial buildings. Quality craftsmanship guaranteed.',
  5000.00,
  'Building',
  true,
  ARRAY['Foundation Work', 'Structural Design', 'Quality Materials', 'Project Management'],
  '4-12 weeks',
  'Construction Site',
  NOW(),
  NOW()
),
(
  gen_random_uuid(),
  'Steel Structures',
  'Design and construction of steel frame buildings, warehouses, and industrial structures.',
  3500.00,
  'Building',
  true,
  ARRAY['Steel Fabrication', 'Welding Services', 'Structural Engineering', 'Safety Compliance'],
  '3-8 weeks',
  'Industrial Site',
  NOW(),
  NOW()
),
(
  gen_random_uuid(),
  'Concrete Works',
  'Professional concrete pouring, finishing, and structural concrete services.',
  1800.00,
  'Building',
  true,
  ARRAY['Foundation Concrete', 'Decorative Finishes', 'Reinforcement', 'Quality Testing'],
  '1-3 weeks',
  'Construction Site',
  NOW(),
  NOW()
),

-- Energy Category
(
  gen_random_uuid(),
  'Solar Systems',
  'Solar power systems for homes, businesses, and farms. Clean, renewable energy solutions.',
  4500.00,
  'Energy',
  true,
  ARRAY['Solar Panels', 'Inverters', 'Battery Storage', 'Grid Connection'],
  '1-2 weeks',
  'Rooftop/Ground',
  NOW(),
  NOW()
),
(
  gen_random_uuid(),
  'Wind Power Systems',
  'Small to medium wind turbines for renewable energy generation.',
  6000.00,
  'Energy',
  true,
  ARRAY['Wind Turbines', 'Power Controllers', 'Battery Banks', 'Monitoring Systems'],
  '2-3 weeks',
  'Open Area',
  NOW(),
  NOW()
),

-- Technology Category
(
  gen_random_uuid(),
  'IoT Solutions',
  'Internet of Things solutions for smart farming, building automation, and monitoring systems.',
  1500.00,
  'Technology',
  true,
  ARRAY['Sensor Networks', 'Data Analytics', 'Mobile Apps', 'Cloud Integration'],
  '1-2 weeks',
  'Various',
  NOW(),
  NOW()
),
(
  gen_random_uuid(),
  'Smart Home Systems',
  'Home automation systems for lighting, security, climate control, and entertainment.',
  2200.00,
  'Technology',
  true,
  ARRAY['Smart Lighting', 'Security Systems', 'Climate Control', 'Voice Control'],
  '3-5 days',
  'Residential',
  NOW(),
  NOW()
),

-- Transport Category
(
  gen_random_uuid(),
  'Logistics',
  'Transportation and logistics services for construction materials and agricultural products.',
  300.00,
  'Transport',
  true,
  ARRAY['Heavy Transport', 'Material Handling', 'Delivery Scheduling', 'GPS Tracking'],
  '1-3 days',
  'Various Locations',
  NOW(),
  NOW()
),
(
  gen_random_uuid(),
  'Equipment Rental',
  'Construction and agricultural equipment rental services.',
  150.00,
  'Transport',
  true,
  ARRAY['Construction Equipment', 'Farm Machinery', 'Delivery Service', 'Maintenance Support'],
  'Daily/Weekly',
  'On-site',
  NOW(),
  NOW()
),

-- Water Solutions Category
(
  gen_random_uuid(),
  'Water Management Systems',
  'Comprehensive water management solutions for agriculture and industrial use.',
  2000.00,
  'Water Solutions',
  true,
  ARRAY['Water Storage', 'Filtration Systems', 'Pump Installation', 'Quality Testing'],
  '1-3 weeks',
  'Various',
  NOW(),
  NOW()
),
(
  gen_random_uuid(),
  'Rainwater Harvesting',
  'Rainwater collection and storage systems for sustainable water use.',
  1200.00,
  'Water Solutions',
  true,
  ARRAY['Collection Systems', 'Storage Tanks', 'Filtration', 'Distribution'],
  '1-2 weeks',
  'Residential/Commercial',
  NOW(),
  NOW()
),

-- Drilling Category
(
  gen_random_uuid(),
  'Borehole Drilling',
  'Professional borehole drilling services for water access in rural and urban areas.',
  3000.00,
  'Drilling',
  true,
  ARRAY['Site Survey', 'Professional Drilling', 'Water Testing', 'Pump Installation'],
  '3-7 days',
  'Various Locations',
  NOW(),
  NOW()
),
(
  gen_random_uuid(),
  'Borehole Siting',
  'Professional siting services for optimal borehole placement using geological surveys.',
  500.00,
  'Drilling',
  true,
  ARRAY['Geological Survey', 'Water Table Analysis', 'Site Mapping', 'Success Guarantee'],
  '1-2 days',
  'Survey Location',
  NOW(),
  NOW()
),

-- Pumps Category
(
  gen_random_uuid(),
  'Solar Water Pumps',
  'Solar-powered water pumping systems for irrigation and domestic use.',
  1800.00,
  'Pumps',
  true,
  ARRAY['Solar Panels', 'Submersible Pumps', 'Controller Systems', 'Remote Monitoring'],
  '3-5 days',
  'Borehole/Well',
  NOW(),
  NOW()
),
(
  gen_random_uuid(),
  'Electric Water Pumps',
  'Installation of AC and DC pumps for various water applications.',
  800.00,
  'Pumps',
  true,
  ARRAY['AC/DC Pumps', 'Control Panels', 'Pressure Systems', 'Maintenance Service'],
  '1-2 days',
  'Water Source',
  NOW(),
  NOW()
);

-- Update the services table to ensure proper indexing
REINDEX TABLE services;

-- Show the inserted services
SELECT 'Services successfully inserted:' as status;
SELECT 
  category,
  COUNT(*) as service_count,
  ARRAY_AGG(title ORDER BY title) as services
FROM services 
WHERE is_active = true
GROUP BY category 
ORDER BY category;

-- Show total count
SELECT 
  COUNT(*) as total_services,
  COUNT(CASE WHEN is_active THEN 1 END) as active_services,
  COUNT(CASE WHEN NOT is_active THEN 1 END) as inactive_services
FROM services;

SELECT 'Services database updated successfully!' as message;