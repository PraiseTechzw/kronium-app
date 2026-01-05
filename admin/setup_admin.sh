#!/bin/bash

# Kronium Admin Dashboard Setup Script
# This script ensures the admin dashboard is properly configured and working

echo "🚀 Setting up Kronium Admin Dashboard..."

# Check if we're in the admin directory
if [ ! -f "package.json" ]; then
    echo "❌ Error: Please run this script from the admin directory"
    exit 1
fi

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Error: Node.js is not installed. Please install Node.js 18+ first."
    exit 1
fi

# Check Node.js version
NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    echo "❌ Error: Node.js version 18+ is required. Current version: $(node -v)"
    exit 1
fi

echo "✅ Node.js version: $(node -v)"

# Install dependencies
echo "📦 Installing dependencies..."
npm install

# Check if .env.local exists
if [ ! -f ".env.local" ]; then
    echo "⚠️  Warning: .env.local file not found. Creating from example..."
    if [ -f ".env.example" ]; then
        cp .env.example .env.local
        echo "📝 Please update .env.local with your Supabase credentials"
    else
        echo "❌ Error: .env.example file not found. Please create .env.local manually."
        exit 1
    fi
fi

# Validate environment variables
echo "🔍 Checking environment variables..."
source .env.local

if [ -z "$NEXT_PUBLIC_SUPABASE_URL" ] || [ -z "$NEXT_PUBLIC_SUPABASE_ANON_KEY" ]; then
    echo "❌ Error: Supabase environment variables are not set properly in .env.local"
    echo "Please set:"
    echo "  NEXT_PUBLIC_SUPABASE_URL=your_supabase_project_url"
    echo "  NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key"
    exit 1
fi

echo "✅ Environment variables configured"

# Build the project to check for errors
echo "🔨 Building project to check for errors..."
npm run build

if [ $? -ne 0 ]; then
    echo "❌ Error: Build failed. Please fix the errors above."
    exit 1
fi

echo "✅ Build successful"

# Check TypeScript
echo "🔍 Running TypeScript check..."
npm run type-check

if [ $? -ne 0 ]; then
    echo "❌ Error: TypeScript errors found. Please fix them."
    exit 1
fi

echo "✅ TypeScript check passed"

echo ""
echo "🎉 Admin Dashboard Setup Complete!"
echo ""
echo "Next steps:"
echo "1. Run the admin_database_fix.sql script in your Supabase SQL Editor"
echo "2. Start the development server: npm run dev"
echo "3. Open http://localhost:3000 in your browser"
echo "4. Login with your admin credentials"
echo ""
echo "📚 Available commands:"
echo "  npm run dev     - Start development server"
echo "  npm run build   - Build for production"
echo "  npm run start   - Start production server"
echo "  npm run lint    - Run ESLint"
echo ""