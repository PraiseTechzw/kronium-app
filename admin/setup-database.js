const { createClient } = require('@supabase/supabase-js')

// Supabase configuration
const supabaseUrl = 'https://ebbrnljnmtoxnxiknfqp.supabase.co'
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImViYnJubGpubXRveG54aWtuZnFwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ2NjA2MTQsImV4cCI6MjA4MDIzNjYxNH0.28zGxQJP8ief88gSOzWpI6CZEvbumlSLHy3UT_hjdU0'

// Create Supabase client
const supabase = createClient(supabaseUrl, supabaseAnonKey)

async function setupDatabase() {
  console.log('🚀 Setting up Kronium database and admin user...')
  
  try {
    // Step 1: Check if users table exists and create if needed
    console.log('📊 Checking users table...')
    
    // Try to query the users table to see if it exists
    const { data: existingUsers, error: tableError } = await supabase
      .from('users')
      .select('id')
      .limit(1)

    if (tableError && tableError.code === '42P01') {
      console.log('❌ Users table does not exist')
      console.log('📝 Please create the users table in Supabase with this SQL:')
      console.log(`
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  phone TEXT,
  profile_image TEXT,
  address TEXT,
  role TEXT DEFAULT 'customer' CHECK (role IN ('customer', 'admin', 'manager', 'technician')),
  is_active BOOLEAN DEFAULT true,
  favorite_services TEXT[] DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can view their own profile" ON users
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON users
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Allow insert for authenticated users" ON users
  FOR INSERT WITH CHECK (auth.uid() = id);
      `)
      return
    }

    console.log('✅ Users table exists')

    // Step 2: Create or update admin user
    const adminEmail = 'admin@kronium.com'
    const adminPassword = 'Admin123!'
    
    console.log('👤 Setting up admin user...')
    
    // First, try to sign up the admin user
    const { data: authData, error: authError } = await supabase.auth.signUp({
      email: adminEmail,
      password: adminPassword,
    })

    let userId = null

    if (authError) {
      if (authError.message.includes('already registered')) {
        console.log('ℹ️  Admin user already exists in auth, getting user ID...')
        
        // Sign in to get the user ID
        const { data: signInData, error: signInError } = await supabase.auth.signInWithPassword({
          email: adminEmail,
          password: adminPassword
        })
        
        if (signInError) {
          console.log('❌ Could not sign in admin user:', signInError.message)
          console.log('🔄 Trying to create new admin user with different email...')
          
          // Try with a different email
          const altEmail = 'admin@kronium.local'
          const { data: newAuthData, error: newAuthError } = await supabase.auth.signUp({
            email: altEmail,
            password: adminPassword,
          })
          
          if (newAuthError) {
            throw new Error(`Failed to create admin user: ${newAuthError.message}`)
          }
          
          userId = newAuthData.user?.id
          console.log(`✅ Created new admin user with email: ${altEmail}`)
        } else {
          userId = signInData.user?.id
        }
      } else {
        throw authError
      }
    } else {
      userId = authData.user?.id
      console.log('✅ Admin user created in auth')
    }

    if (!userId) {
      throw new Error('Failed to get admin user ID')
    }

    console.log('👤 Admin User ID:', userId)

    // Step 3: Create or update user profile with admin role
    console.log('📝 Creating/updating admin profile in users table...')
    
    // First, let's see what users exist
    console.log('🔍 Checking existing users...')
    const { data: allUsers, error: listError } = await supabase
      .from('users')
      .select('id, email, role, name')
      .limit(10)

    if (listError) {
      console.log('⚠️  Could not list users:', listError.message)
    } else {
      console.log('👥 Existing users:', allUsers)
    }
    
    // Try to find admin user by email
    const { data: existingAdmin, error: findError } = await supabase
      .from('users')
      .select('*')
      .eq('email', adminEmail)
      .single()

    if (findError && findError.code !== 'PGRST116') {
      console.log('⚠️  Error finding admin user:', findError.message)
    }

    if (existingAdmin) {
      console.log('👤 Found existing admin user:', existingAdmin)
      
      // Update existing user to admin role
      const { data: updateData, error: updateError } = await supabase
        .from('users')
        .update({
          role: 'admin',
          name: 'Kronium Administrator'
        })
        .eq('email', adminEmail)
        .select()

      if (updateError) {
        throw new Error(`Failed to update admin profile: ${updateError.message}`)
      }
      
      console.log('✅ Admin profile updated successfully')
      userId = existingAdmin.id // Use the actual user ID from database
    } else {
      console.log('📝 No existing admin user found, creating new one...')
      
      const { error: insertError } = await supabase
        .from('users')
        .insert([
          {
            id: userId,
            name: 'Kronium Administrator',
            email: adminEmail,
            role: 'admin'
          }
        ])

      if (insertError) {
        throw new Error(`Failed to create admin profile: ${insertError.message}`)
      }
      
      console.log('✅ Admin profile created successfully')
    }

    // Step 4: Verify admin setup
    console.log('🔍 Verifying admin setup...')
    const { data: adminProfile, error: verifyError } = await supabase
      .from('users')
      .select('*')
      .eq('email', adminEmail)
      .single()

    if (verifyError) {
      throw new Error(`Failed to verify admin profile: ${verifyError.message}`)
    }

    console.log('✅ Admin verification successful!')
    console.log('👤 Admin Profile:', {
      id: adminProfile.id,
      name: adminProfile.name,
      email: adminProfile.email,
      role: adminProfile.role,
      is_active: adminProfile.is_active
    })

    // Step 5: Test admin login
    console.log('🔐 Testing admin login...')
    const { data: loginTest, error: loginError } = await supabase.auth.signInWithPassword({
      email: adminProfile.email,
      password: adminPassword
    })

    if (loginError) {
      throw new Error(`Admin login test failed: ${loginError.message}`)
    }

    console.log('✅ Admin login test successful!')

    console.log('\n🎉 Database setup complete!')
    console.log('🔑 Admin Login Credentials:')
    console.log(`   Email: ${adminProfile.email}`)
    console.log(`   Password: ${adminPassword}`)
    console.log('\n🌐 Admin Dashboard: http://localhost:3003/login')
    console.log('\n✨ You can now login to the admin dashboard!')

  } catch (error) {
    console.error('❌ Database setup failed:', error.message)
    console.log('\n🔧 Troubleshooting Steps:')
    console.log('1. Make sure Supabase project is accessible')
    console.log('2. Check that RLS policies allow the operations')
    console.log('3. Verify the users table exists with correct schema')
    console.log('4. Ensure your Supabase URL and anon key are correct')
  }
}

// Run the setup
setupDatabase().then(() => {
  console.log('\n✨ Setup script completed')
  process.exit(0)
}).catch((error) => {
  console.error('💥 Setup script failed:', error)
  process.exit(1)
})