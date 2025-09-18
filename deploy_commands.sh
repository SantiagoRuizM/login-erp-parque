#!/bin/bash
set -e

echo "🚀 Starting deployment of Professional Login App..."

# Update system
echo "📦 Updating system packages..."
apt update && apt upgrade -y

# Install required packages
echo "🔧 Installing required packages..."
apt install -y python3 python3-pip python3-venv nodejs npm nginx git curl ufw

# Install PM2 globally
echo "📦 Installing PM2..."
npm install -g pm2

# Clone the repository
echo "📥 Cloning application repository..."
cd /var/www
git clone https://github.com/SantiagoRuizM/professional-login-app.git login-app
cd login-app

# Set up backend
echo "🐍 Setting up Flask backend..."
cd backend

# Create Python virtual environment
python3 -m venv venv
source venv/bin/activate

# Install Python dependencies
pip install -r requirements.txt

# Create production environment file
echo "⚙️ Creating production environment..."
cat > .env << 'ENVEOF'
# Supabase Configuration
SUPABASE_URL=https://basedatos.parque-e.co
SUPABASE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyAgCiAgICAicm9sZSI6ICJhbm9uIiwKICAgICJpc3MiOiAic3VwYWJhc2UtZGVtbyIsCiAgICAiaWF0IjogMTY0MTc2OTIwMCwKICAgICJleHAiOiAxNzk5NTM1NjAwCn0.dc_X5iR_VP_qT0zsiyj_I_OZ2T9FtRU2BBNWN8Bu4GE
SUPABASE_SERVICE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyAgCiAgICAicm9sZSI6ICJzZXJ2aWNlX3JvbGUiLAogICAgImlzcyI6ICJzdXBhYmFzZS1kZW1vIiwKICAgICJpYXQiOiAxNjQxNzY5MjAwLAogICAgImV4cCI6IDE3OTk1MzU2MDAKfQ.DaYlNEoUrrEn2Ig7tqibS-PHK5vgusbcbo7X36XVt4Q
JWT_SECRET=production-jwt-secret-key-very-secure-change-this-in-production-environment-2024
FLASK_ENV=production
USERS_TABLE=cuenta
CORS_ORIGINS=http://159.203.109.216,https://159.203.109.216
ENVEOF

# Set up frontend
echo "⚛️ Setting up React frontend..."
cd ../frontend

# Install Node.js dependencies
npm install

# Create production environment
cat > .env << 'ENVEOF'
VITE_API_URL=http://159.203.109.216:5000/api
VITE_APP_TITLE=ERP Parque E
ENVEOF

# Build frontend for production
echo "🔨 Building React application..."
npm run build

# Rest of the deployment script continues...
echo "✅ Deployment completed successfully!"
