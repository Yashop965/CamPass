#!/bin/bash

# CAMPASS Production Deployment Script
# This script helps set up the CAMPASS application for production deployment

set -e

echo "🚀 CAMPASS Production Deployment Setup"
echo "====================================="

# Check if we're in the right directory
if [ ! -f "backend/package.json" ] || [ ! -f "frontend/campass_app/pubspec.yaml" ]; then
    echo "❌ Error: Please run this script from the root campass directory"
    exit 1
fi

# Backend setup
echo "📦 Setting up Backend..."
cd backend

# Check if .env exists
if [ ! -f ".env" ]; then
    echo "⚠️  .env file not found. Creating from template..."
    if [ -f ".env.production.example" ]; then
        cp .env.production.example .env
        echo "✅ Created .env from template. Please edit it with your production values."
    else
        echo "❌ .env.production.example not found. Please create .env manually."
        exit 1
    fi
fi

# Install dependencies
echo "📦 Installing backend dependencies..."
npm install

# Check database connection
echo "🗄️  Checking database connection..."
node -e "
require('dotenv').config();
const { Sequelize } = require('sequelize');
const sequelize = new Sequelize(process.env.DB_NAME, process.env.DB_USER, process.env.DB_PASS, {
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  dialect: 'postgres',
  logging: false
});
sequelize.authenticate().then(() => {
  console.log('✅ Database connection successful');
  process.exit(0);
}).catch(err => {
  console.error('❌ Database connection failed:', err.message);
  process.exit(1);
});
"

# Run migrations
echo "🗄️  Running database migrations..."
npx sequelize-cli db:migrate

echo "✅ Backend setup complete!"
cd ..

# Frontend setup
echo "📱 Setting up Frontend..."
cd frontend/campass_app

# Install Flutter dependencies
echo "📦 Installing Flutter dependencies..."
flutter pub get

# Check for Firebase configuration
if [ ! -f "android/app/google-services.json" ]; then
    echo "⚠️  google-services.json not found in android/app/"
    echo "   Please add your Firebase Android configuration file."
fi

if [ ! -f "ios/Runner/GoogleService-Info.plist" ]; then
    echo "⚠️  GoogleService-Info.plist not found in ios/Runner/"
    echo "   Please add your Firebase iOS configuration file."
fi

echo "✅ Frontend setup complete!"
cd ../..

echo ""
echo "🎉 Setup Complete!"
echo "=================="
echo ""
echo "Next steps:"
echo "1. Edit backend/.env with your production configuration"
echo "2. Add Firebase configuration files to frontend/campass_app/"
echo "3. Run database migrations: cd backend && npx sequelize-cli db:migrate"
echo "4. Test the backend: cd backend && npm start"
echo "5. Build the app: cd frontend/campass_app && flutter build apk --release"
echo "6. Deploy to your hosting platform"
echo ""
echo "For detailed instructions, see DEPLOYMENT_GUIDE.md"