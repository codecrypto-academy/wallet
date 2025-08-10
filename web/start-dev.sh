#!/bin/bash

echo "🚀 Starting Ethereum Login App Development Environment"

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

# Start MongoDB
echo "📦 Starting MongoDB..."
docker-compose up -d mongodb

# Wait for MongoDB to be ready
echo "⏳ Waiting for MongoDB to be ready..."
sleep 5

# Check if MongoDB is running
if ! docker exec ethereum-login-mongodb mongosh --eval "db.runCommand('ping')" > /dev/null 2>&1; then
    echo "❌ MongoDB failed to start. Please check Docker logs."
    exit 1
fi

echo "✅ MongoDB is running on localhost:27017"

# Create .env.local if it doesn't exist
if [ ! -f .env.local ]; then
    echo "📝 Creating .env.local file..."
    cat > .env.local << EOF
# MongoDB Configuration
MONGODB_URI=mongodb://localhost:27017

# JWT Secret (change this in production!)
JWT_SECRET=your-super-secret-jwt-key-change-in-production

# Server Configuration
NODE_ENV=development
EOF
    echo "✅ .env.local created"
else
    echo "✅ .env.local already exists"
fi

# Install dependencies if node_modules doesn't exist
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm install
fi

# Start the development server
echo "🌐 Starting Next.js development server..."
echo "📱 Open http://localhost:3000 in your browser"
echo "🔑 Use the test program with: npm run test:login"
echo ""
echo "Press Ctrl+C to stop all services"

# Start the app
npm run dev
