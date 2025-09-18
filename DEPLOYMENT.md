# Deployment Instructions

## Server Configuration Updates

When deploying to server, ensure the following paths are updated:

### 1. Nginx Configuration
- File: `/etc/nginx/sites-available/login-app`
- Current working path: `root /var/www/login-app/frontend/dist;`
- Keep this path as-is on server

### 2. PM2 Configuration
- Use: `backend/ecosystem.config.js` (when running from project root)
- Or use: `ecosystem.config.js` in project root
- Current working config: Uses relative paths from current directory

### 3. Directory Structure on Server
```
/var/www/login-app/
├── backend/
├── frontend/
├── deployment/
└── ecosystem.config.js
```

### 4. Deployment Steps
1. Navigate to project directory: `cd /var/www/login-app`
2. Pull changes: `git pull origin main`
3. Install backend deps: `cd backend && pip install -r requirements.txt`
4. Install frontend deps: `cd ../frontend && npm install`
5. Build frontend: `npm run build`
6. Restart PM2: `pm2 restart login-api`
7. Reload nginx: `sudo nginx -t && sudo systemctl reload nginx`

### 5. Environment Variables
- Backend: `/var/www/login-app/backend/.env`
- Frontend: `/var/www/login-app/frontend/.env`
- Keep production values on server

## Local Development
- Run from project root
- Use `ecosystem.config.js` for PM2 (if needed locally)
- Frontend dev: `cd frontend && npm run dev`
- Backend dev: `cd backend && python app.py`