#!/bin/bash

# Professional Login Application Deployment Script for Digital Ocean
# This script automates the deployment process

set -e  # Exit on any error

# Configuration
APP_NAME="login-app"
APP_DIR="/var/www/$APP_NAME"
BACKEND_DIR="$APP_DIR/backend"
FRONTEND_DIR="$APP_DIR/frontend"
NGINX_CONF="/etc/nginx/sites-available/$APP_NAME"
NGINX_ENABLED="/etc/nginx/sites-enabled/$APP_NAME"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

echo_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

echo_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo_error "This script must be run as root (use sudo)"
   exit 1
fi

echo_info "Starting deployment of Professional Login Application..."

# Update system packages
echo_info "Updating system packages..."
apt update && apt upgrade -y

# Install required packages
echo_info "Installing required packages..."
apt install -y python3 python3-pip python3-venv nodejs npm nginx certbot python3-certbot-nginx git curl

# Install PM2 globally
echo_info "Installing PM2 process manager..."
npm install -g pm2

# Create application directory
echo_info "Creating application directory..."
mkdir -p $APP_DIR
cd $APP_DIR

# Clone or copy application files
if [ -d ".git" ]; then
    echo_info "Updating existing repository..."
    git pull origin main
else
    echo_info "Please ensure application files are copied to $APP_DIR"
fi

# Backend setup
echo_info "Setting up Flask backend..."
cd $BACKEND_DIR

# Create Python virtual environment
python3 -m venv venv
source venv/bin/activate

# Install Python dependencies
pip install -r requirements.txt

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo_warn ".env file not found in backend directory"
    echo_info "Please copy .env.example to .env and configure it with your Supabase credentials"
    cp .env.example .env
    echo_error "Please edit $BACKEND_DIR/.env with your configuration and run this script again"
    exit 1
fi

echo_info "Testing Flask application..."
python -c "
import sys
sys.path.insert(0, '.')
try:
    from app import create_app
    app = create_app()
    print('Flask app created successfully')
except Exception as e:
    print(f'Error creating Flask app: {e}')
    sys.exit(1)
"

# Frontend setup
echo_info "Setting up React frontend..."
cd $FRONTEND_DIR

# Install Node.js dependencies
npm install

# Build frontend for production
echo_info "Building React application..."
npm run build

# Configure Nginx
echo_info "Configuring Nginx..."
cp ../deployment/nginx.conf $NGINX_CONF

# Update domain name in nginx config
read -p "Enter your domain name (e.g., yourdomain.com): " DOMAIN_NAME
if [ -n "$DOMAIN_NAME" ]; then
    sed -i "s/your-domain.com/$DOMAIN_NAME/g" $NGINX_CONF
    echo_info "Updated Nginx configuration with domain: $DOMAIN_NAME"
fi

# Enable Nginx site
ln -sf $NGINX_CONF $NGINX_ENABLED

# Test Nginx configuration
nginx -t
if [ $? -eq 0 ]; then
    echo_info "Nginx configuration is valid"
else
    echo_error "Nginx configuration is invalid"
    exit 1
fi

# Start/restart Nginx
systemctl restart nginx
systemctl enable nginx

# Set up PM2 for Flask backend
echo_info "Setting up PM2 for Flask backend..."
cd $BACKEND_DIR
source venv/bin/activate

# Create PM2 ecosystem file
cat > ecosystem.config.js << EOF
module.exports = {
  apps: [{
    name: 'login-api',
    script: 'app.py',
    interpreter: './venv/bin/python',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    env: {
      FLASK_ENV: 'production'
    }
  }]
};
EOF

# Start application with PM2
pm2 start ecosystem.config.js
pm2 save
pm2 startup

echo_info "Setting up SSL certificate..."
if [ -n "$DOMAIN_NAME" ]; then
    # Get SSL certificate
    certbot --nginx -d $DOMAIN_NAME --non-interactive --agree-tos --email admin@$DOMAIN_NAME
    
    if [ $? -eq 0 ]; then
        echo_info "SSL certificate installed successfully"
    else
        echo_warn "SSL certificate installation failed. You can run it manually later:"
        echo "sudo certbot --nginx -d $DOMAIN_NAME"
    fi
else
    echo_warn "Skipping SSL setup (no domain provided)"
fi

# Set up firewall
echo_info "Configuring firewall..."
ufw allow ssh
ufw allow 'Nginx Full'
ufw --force enable

# Set correct permissions
echo_info "Setting file permissions..."
chown -R www-data:www-data $APP_DIR
chmod -R 755 $APP_DIR

# Final status check
echo_info "Checking application status..."
pm2 list
systemctl status nginx --no-pager -l

echo_info "Testing endpoints..."
curl -f http://localhost:5000/health || echo_warn "Backend health check failed"
curl -f http://localhost/ || echo_warn "Frontend check failed"

echo_info "Deployment completed successfully!"
echo_info "Your application should be accessible at:"
if [ -n "$DOMAIN_NAME" ]; then
    echo_info "  https://$DOMAIN_NAME"
else
    echo_info "  http://your-server-ip"
fi

echo_info "Management commands:"
echo_info "  View logs: pm2 logs login-api"
echo_info "  Restart backend: pm2 restart login-api"
echo_info "  Check status: pm2 status"
echo_info "  Nginx reload: sudo systemctl reload nginx"

echo_warn "Don't forget to:"
echo_warn "  1. Configure your .env file with actual Supabase credentials"
echo_warn "  2. Set up your DNS to point to this server"
echo_warn "  3. Test the complete authentication flow"