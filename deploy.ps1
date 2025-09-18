# PowerShell script to deploy via SSH
$username = "root"
$password = ConvertTo-SecureString "dato_Parque" -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($username, $password)

# Read the deployment script
$deployScript = Get-Content "deploy-to-droplet.sh" -Raw

# Create SSH session (requires PowerShell 7+ with SSH module or Posh-SSH)
try {
    # Try using native SSH command with password authentication
    Write-Host "Attempting to deploy via SSH..."
    
    # Create a temporary expect-like script for Windows
    $deployCommands = @"
#!/bin/bash
set -e
echo "🚀 Starting deployment of Professional Login App..."
apt update && apt upgrade -y
apt install -y python3 python3-pip python3-venv nodejs npm nginx git curl ufw
npm install -g pm2
cd /var/www
git clone https://github.com/SantiagoRuizM/professional-login-app.git login-app
cd login-app/backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
cat > .env << 'EOF'
SUPABASE_URL=https://basedatos.parque-e.co
SUPABASE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyAgCiAgICAicm9sZSI6ICJhbm9uIiwKICAgICJpc3MiOiAic3VwYWJhc2UtZGVtbyIsCiAgICAiaWF0IjogMTY0MTc2OTIwMCwKICAgICJleHAiOiAxNzk5NTM1NjAwCn0.dc_X5iR_VP_qT0zsiyj_I_OZ2T9FtRU2BBNWN8Bu4GE
SUPABASE_SERVICE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyAgCiAgICAicm9sZSI6ICJzZXJ2aWNlX3JvbGUiLAogICAgImlzcyI6ICJzdXBhYmFzZS1kZW1vIiwKICAgICJpYXQiOiAxNjQxNzY5MjAwLAogICAgImV4cCI6IDE3OTk1MzU2MDAKfQ.DaYlNEoUrrEn2Ig7tqibS-PHK5vgusbcbo7X36XVt4Q
JWT_SECRET=production-jwt-secret-key-very-secure-change-this-in-production-environment-2024
FLASK_ENV=production
USERS_TABLE=cuenta
CORS_ORIGINS=http://159.203.109.216,https://159.203.109.216
EOF
cd ../frontend
npm install
cat > .env << 'EOF'
VITE_API_URL=http://159.203.109.216:5000/api
VITE_APP_TITLE=ERP Parque E
EOF
npm run build
echo "✅ Basic setup completed!"
"@
    
    # Save commands to temp file
    $deployCommands | Out-File -FilePath "deploy_temp.sh" -Encoding UTF8
    
    Write-Host "Created deployment script. Manual SSH connection required."
    
} catch {
    Write-Error "Deployment failed: $_"
}