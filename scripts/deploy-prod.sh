#!/bin/bash
# Production deployment script

echo "🚀 Deploying to Production..."

# Set environment for production
export FLASK_ENV=production

# Build frontend
echo "🏗️ Building frontend for production..."
cd frontend
npm install
npm run build

# Backend setup
echo "📦 Setting up backend..."
cd ../backend
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python -m venv venv
fi

source venv/bin/activate
pip install -r requirements.txt

# Start with PM2
echo "🔧 Starting with PM2..."
cd ..
pm2 start ecosystem.config.js

echo "✅ Production deployment complete!"
echo "Application running on PM2"
echo "Check status: pm2 status"