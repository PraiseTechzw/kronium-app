const { createClient } = require('@supabase/supabase-js')

// Supabase configuration
const supabaseUrl = 'https://ebbrnljnmtoxnxiknfqp.supabase.co'
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImViYnJubGpubXRveG54aWtuZnFwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ2NjA2MTQsImV4cCI6MjA4MDIzNjYxNH0.28zGxQJP8ief88gSOzWpI6CZEvbumlSLHy3UT_hjdU0'

// Create Supabase client
const supabase = createClient(supabaseUrl, supabaseAnonKey)

async function createAdminUser() {
  console.log('🚀 Creating admin user for Kronium Dashboard...')
  
  const adminEmail = 'admin@kronium.com'
  const adminPassword = 'Admin123!'
  const adminName = 'Kronium Administrator'
  
  try {
    // Step 1: Sign up the user
    console.log('📝 Creating authentication account...')
    const { data: authData, error: authError } = await supabase.auth.signUp({
      email: adminEmail,
      password: adminPassword,
      options: {
        data: {
          name: adminName,
          role: 'admin'
        }
      }
    })

    if (authError) {
      if (authError.message.includes('already registered')) {
        console.log('ℹ️  User already exists, trying to sign in...')
        
        // Try to sign in
        const { data: signInData, error: signInError } = await supabase.auth.signInWithPassword({
          email: adminEmail,
          password: adminPassword
        })
        
        if (signInError) {
          console.log('❌ Sign in failed, user might exist with different password')
          console.log('🔑 Try logging in with:')
          console.log(`   Email: ${adminEmail}`)
          console.log(`   Password: ${adminPassword}`)
          return
        }
        
        console.log('✅ Successfully signed in existing user')
        authData.user = signInData.user
      } else {
        throw authError
      }
    }

    if (!authData.user) {
      throw new Error('Failed to create or sign in user')
    }

    console.log('👤 User ID:', authData.user.id)

    // Step 2: Create or update user profile in the users table
    console.log('📊 Creating user profile in database...')
    
    const { data: existingUser, error: fetchError } = await supabase
      .from('users')
      .select('*')
      .eq('id', authData.user.id)
      .single()

    if (fetchError && fetchError.code !== 'PGRST116') {
      console.log('⚠️  Error checking existing user:', fetchError.message)
    }

    if (existingUser) {
      // Update existing user to admin role
      console.log('🔄 Updating existing user to admin role...')
      const { error: updateError } = await supabase
        .from('users')
        .update({
          role: 'admin',
          name: adminName,
          is_active: true,
          updated_at: new Date().toISOString()
        })
        .eq('id', authData.user.id)

      if (updateError) {
        console.log('⚠️  Error updating user profile:', updateError.message)
      } else {
        console.log('✅ User profile updated successfully')
      }
    } else {
      // Create new user profile
      const { error: insertError } = await supabase
        .from('users')
        .insert([
          {
            id: authData.user.id,
            name: adminName,
            email: adminEmail,
            phone: '+1234567890',
            role: 'admin',
            is_active: true,
            created_at: new Date().toISOString(),
            updated_at: new Date().toISOString()
          }
        ])

      if (insertError) {
        console.log('⚠️  Error creating user profile:', insertError.message)
        console.log('📝 You may need to create the users table first')
      } else {
        console.log('✅ User profile created successfully')
      }
    }

    // Step 3: Verify the setup
    console.log('🔍 Verifying admin user setup...')
    const { data: verifyUser, error: verifyError } = await supabase
      .from('users')
      .select('*')
      .eq('id', authData.user.id)
      .single()

    if (verifyError) {
      console.log('⚠️  Could not verify user in database:', verifyError.message)
    } else {
      console.log('✅ Admin user verified in database')
      console.log('👤 User details:', {
        id: verifyUser.id,
        name: verifyUser.name,
        email: verifyUser.email,
        role: verifyUser.role,
        is_active: verifyUser.is_active
      })
    }

    console.log('\n🎉 Admin user setup complete!')
    console.log('🔑 Login credentials:')
    console.log(`   Email: ${adminEmail}`)
    console.log(`   Password: ${adminPassword}`)
    console.log('\n🌐 You can now login at: http://localhost:3003/login')

  } catch (error) {
    console.error('❌ Error creating admin user:', error.message)
    console.log('\n🔧 Troubleshooting:')
    console.log('1. Make sure your Supabase project is set up correctly')
    console.log('2. Ensure the users table exists with the correct schema')
    console.log('3. Check that RLS (Row Level Security) policies allow inserts')
    console.log('4. Verify your Supabase URL and anon key are correct')
  }
}

// Run the script
createAdminUser().then(() => {
  console.log('\n✨ Script completed')
  process.exit(0)
}).catch((error) => {
  console.error('💥 Script failed:', error)
  process.exit(1)
})