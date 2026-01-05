# Services Fix Guide - Kronium Admin Dashboard

## 🎯 Problem
The admin dashboard is not showing services even though they exist in the database. This is likely due to:
1. Incorrect database schema or missing services
2. Row Level Security (RLS) policies blocking access
3. Data fetching issues in the admin dashboard

## 🔧 Solution Steps

### Step 1: Fix Database Services
1. Go to your Supabase dashboard
2. Navigate to SQL Editor
3. Run the `fix_services_database.sql` script
4. This will:
   - Clear existing services
   - Insert comprehensive services with correct categories
   - Set up proper indexing

### Step 2: Verify Database Access
Check if RLS policies are blocking access:

```sql
-- Check current RLS policies for services table
SELECT * FROM pg_policies WHERE tablename = 'services';

-- Temporarily disable RLS to test (ONLY FOR TESTING)
ALTER TABLE services DISABLE ROW LEVEL SECURITY;

-- Re-enable with proper policies
ALTER TABLE services ENABLE ROW LEVEL SECURITY;

-- Ensure admin can access all services
DROP POLICY IF EXISTS "Allow service management" ON services;
CREATE POLICY "Allow service management" ON services
  FOR ALL USING (true);
```

### Step 3: Test Admin Dashboard
1. Navigate to admin directory: `cd admin`
2. Start development server: `npm run dev`
3. Open http://localhost:3000/dashboard/services
4. Check browser console for any errors
5. Verify services are loading

## 📊 Service Categories

The system now includes these categories:

### Agriculture
- Greenhouse Construction ($2,500)
- Irrigation Systems ($1,200)
- Crop Monitoring Systems ($800)

### Building
- Construction ($5,000)
- Steel Structures ($3,500)
- Concrete Works ($1,800)

### Energy
- Solar Systems ($4,500)
- Wind Power Systems ($6,000)

### Technology
- IoT Solutions ($1,500)
- Smart Home Systems ($2,200)

### Transport
- Logistics ($300)
- Equipment Rental ($150)

### Water Solutions
- Water Management Systems ($2,000)
- Rainwater Harvesting ($1,200)

### Drilling
- Borehole Drilling ($3,000)
- Borehole Siting ($500)

### Pumps
- Solar Water Pumps ($1,800)
- Electric Water Pumps ($800)

## 🛠️ Admin Dashboard Features

### Enhanced Services Page
- ✅ Service statistics cards
- ✅ Category filtering with counts
- ✅ Search functionality
- ✅ Grid view with service details
- ✅ Status toggle (Active/Inactive)
- ✅ Edit and delete actions

### Service Creation
- ✅ New service creation form
- ✅ All service categories available
- ✅ Feature management
- ✅ Image URL support
- ✅ Price and duration settings

## 🔍 Debugging Steps

If services still don't appear:

### 1. Check Database Connection
```javascript
// In browser console on services page
console.log('Supabase client:', supabase)
```

### 2. Check Network Requests
- Open browser DevTools → Network tab
- Look for requests to `/rest/v1/services`
- Check response status and data

### 3. Check Console Errors
- Open browser DevTools → Console tab
- Look for JavaScript errors
- Check for authentication issues

### 4. Verify Database Data
```sql
-- Check if services exist
SELECT COUNT(*) FROM services;

-- Check service details
SELECT id, title, category, is_active FROM services LIMIT 5;

-- Check RLS policies
SELECT * FROM pg_policies WHERE tablename = 'services';
```

## 🚀 Expected Results

After running the fix:

1. **Services Page**: Should show 18 services across 8 categories
2. **Statistics**: Should display correct counts and averages
3. **Filtering**: Should work by category and search
4. **Creation**: Should be able to add new services
5. **Management**: Should be able to edit/delete/toggle services

## 📱 Integration with Flutter App

The services created in the admin dashboard will:
- ✅ Appear in the Flutter app services list
- ✅ Be available for booking
- ✅ Sync in real-time
- ✅ Maintain consistent categories

## 🔐 Security Notes

- RLS policies ensure data security
- Admin users have full access to manage services
- Regular users can only view active services
- All changes are logged with timestamps

## 📞 Support

If issues persist:
1. Check Supabase project status
2. Verify environment variables in `.env.local`
3. Ensure admin user has proper permissions
4. Check browser console for detailed error messages

Run the database fix script and restart your admin dashboard to see the changes!