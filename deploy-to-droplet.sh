#!/bin/bash
# Professional Login App Deployment Script for Digital Ocean
# Run this script on the droplet: ssh root@159.203.109.216 'bash -s' < deploy-to-droplet.sh

set -e  # Exit on any error

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
git clone https://github.com/SantiagoRuizM/login-erp-parque.git login-app
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
cat > .env << EOF
# Supabase Configuration
SUPABASE_URL=https://basedatos.parque-e.co
SUPABASE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyAgCiAgICAicm9sZSI6ICJhbm9uIiwKICAgICJpc3MiOiAic3VwYWJhc2UtZGVtbyIsCiAgICAiaWF0IjogMTY0MTc2OTIwMCwKICAgICJleHAiOiAxNzk5NTM1NjAwCn0.dc_X5iR_VP_qT0zsiyj_I_OZ2T9FtRU2BBNWN8Bu4GE
SUPABASE_SERVICE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyAgCiAgICAicm9sZSI6ICJzZXJ2aWNlX3JvbGUiLAogICAgImlzcyI6ICJzdXBhYmFzZS1kZW1vIiwKICAgICJpYXQiOiAxNjQxNzY5MjAwLAogICAgImV4cCI6IDE3OTk1MzU2MDAKfQ.DaYlNEoUrrEn2Ig7tqibS-PHK5vgusbcbo7X36XVt4Q
JWT_SECRET=production-jwt-secret-key-very-secure-change-this-in-production-environment-2024
FLASK_ENV=production
USERS_TABLE=cuenta
CORS_ORIGINS=http://159.203.109.216,https://159.203.109.216
EOF

# Set up frontend
echo "⚛️ Setting up React frontend..."
cd ../frontend

# Install Node.js dependencies
npm install

# Create production environment
cat > .env << EOF
VITE_API_URL=http://159.203.109.216:5000/api
VITE_APP_TITLE=ERP Parque E
EOF

# Build frontend for production
echo "🔨 Building React application..."
npm run build

# Configure Nginx
echo "🌐 Configuring Nginx..."
cat > /etc/nginx/sites-available/login-app << 'EOF'
server {
    listen 80;
    server_name 159.203.109.216;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

    # Serve React frontend
    location / {
        root /var/www/login-app/frontend/dist;
        index index.html index.htm;
        try_files $uri $uri/ /index.html;
    }

    # Static files caching
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|webp)$ {
        root /var/www/login-app/frontend/dist;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Proxy API requests to Flask backend
    location /api {
        proxy_pass http://127.0.0.1:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # Health check endpoint
    location /health {
        proxy_pass http://127.0.0.1:5000/health;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

# Enable Nginx site
ln -sf /etc/nginx/sites-available/login-app /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Test Nginx configuration
nginx -t

# Start Flask backend with PM2
echo "🚀 Starting Flask backend with PM2..."
cd /var/www/login-app/backend

# Create PM2 ecosystem file
cat > ecosystem.config.js << 'EOF'
module.exports = {
  apps: [{
    name: 'login-api',
    script: 'app.py',
    interpreter: './venv/bin/python',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '512M',
    env: {
      FLASK_ENV: 'production'
    },
    error_file: '/var/log/pm2/login-api-error.log',
    out_file: '/var/log/pm2/login-api-out.log',
    log_file: '/var/log/pm2/login-api.log'
  }]
};
EOF

# Create PM2 log directory
mkdir -p /var/log/pm2

# Start application with PM2
pm2 start ecosystem.config.js
pm2 save
pm2 startup systemd -u root --hp /root

# Restart and enable Nginx
systemctl restart nginx
systemctl enable nginx

# Configure firewall
echo "🔐 Configuring firewall..."
ufw --force enable
ufw allow ssh
ufw allow 'Nginx Full'
ufw allow 5000  # Flask API port

# Set correct permissions
echo "🔒 Setting file permissions..."
chown -R www-data:www-data /var/www/login-app
chmod -R 755 /var/www/login-app

# Final status check
echo "✅ Checking application status..."
sleep 5
pm2 list
systemctl status nginx --no-pager -l

echo "🎉 Deployment completed successfully!"
echo ""
echo "🌐 Your application is now available at:"
echo "   http://159.203.109.216"
echo ""
echo "📊 Management commands:"
echo "   View backend logs: pm2 logs login-api"
echo "   Restart backend: pm2 restart login-api"
echo "   Check PM2 status: pm2 status"
echo "   Nginx status: systemctl status nginx"
echo "   View Nginx logs: tail -f /var/log/nginx/access.log"
echo ""
echo "🔗 API Health Check:"
echo "   http://159.203.109.216/health"
echo ""
echo "✨ Professional Login App is ready!"
EOF