# Professional Login Application

A contemporary login application with Flask backend, React frontend, and Supabase authentication integration.

## 🏗️ Architecture

```
login-app/
├── backend/                 # Flask API Server
│   ├── app.py              # Main application entry point
│   ├── config.py           # Configuration and environment variables
│   ├── routes/
│   │   └── auth.py         # Authentication endpoints
│   ├── models/
│   │   └── user.py         # User model and database queries
│   ├── utils/
│   │   └── supabase_client.py  # Supabase connection
│   └── requirements.txt    # Python dependencies
├── frontend/               # React Application
│   ├── src/
│   │   ├── components/
│   │   │   └── LoginForm.jsx   # Main login component
│   │   ├── services/
│   │   │   └── api.js       # API communication
│   │   ├── assets/         # Images and static files
│   │   └── App.jsx         # Main React component
│   ├── public/
│   └── package.json
└── deployment/
    ├── nginx.conf          # Nginx configuration
    └── deploy.sh           # Deployment script
```

## 🚀 Technology Stack

### Backend
- **Framework**: Flask (Python 3.9+)
- **Database**: Supabase PostgreSQL
- **Authentication**: JWT tokens
- **CORS**: Flask-CORS for frontend communication

### Frontend
- **Framework**: React 18 with Vite
- **Styling**: Tailwind CSS
- **HTTP Client**: Axios
- **State Management**: React Context/Hooks

### Infrastructure
- **Hosting**: Digital Ocean Droplet (Ubuntu 22.04)
- **Web Server**: Nginx (reverse proxy)
- **Process Manager**: PM2
- **SSL**: Let's Encrypt (Certbot)

## 📋 Development Plan

### Phase 1: Environment Setup
1. **Gather Requirements**
   - [ ] Supabase project URL and API keys
   - [ ] Database schema (`personas` table structure)
   - [ ] softR login design reference
   - [ ] Background image assets

2. **Local Development Setup**
   - [ ] Create Flask backend structure
   - [ ] Set up React frontend with Vite
   - [ ] Configure Supabase connection
   - [ ] Implement CORS and environment variables

### Phase 2: Backend Development
1. **Flask API Development**
   - [ ] Create authentication endpoints (`/api/login`, `/api/verify`)
   - [ ] Implement Supabase client integration
   - [ ] Add JWT token generation and validation
   - [ ] Create user model for `personas` table queries

2. **Security Implementation**
   - [ ] Password hashing/validation
   - [ ] JWT token expiration
   - [ ] Input validation and sanitization
   - [ ] Rate limiting for login attempts

### Phase 3: Frontend Development
1. **UI/UX Implementation**
   - [ ] Professional login form design
   - [ ] Orange color theme implementation
   - [ ] Contemporary styling with Tailwind CSS
   - [ ] Responsive design for all devices

2. **Authentication Flow**
   - [ ] Login form validation
   - [ ] API integration with Flask backend
   - [ ] Token storage and management
   - [ ] Success/error state handling

### Phase 4: Integration & Testing
1. **Full Stack Integration**
   - [ ] Connect React frontend to Flask API
   - [ ] Test complete authentication flow
   - [ ] Handle edge cases and error scenarios
   - [ ] Performance optimization

2. **Local Testing**
   - [ ] Unit tests for Flask endpoints
   - [ ] Frontend component testing
   - [ ] End-to-end authentication testing
   - [ ] Cross-browser compatibility

### Phase 5: Digital Ocean Deployment

#### 5.1 Droplet Setup
```bash
# Create Ubuntu 22.04 droplet (minimum 1GB RAM)
# SSH into droplet and update system
sudo apt update && sudo apt upgrade -y

# Install required packages
sudo apt install python3 python3-pip nodejs npm nginx certbot python3-certbot-nginx -y
npm install -g pm2
```

#### 5.2 Application Deployment
```bash
# Clone repository
git clone <repository-url>
cd login-app

# Backend setup
cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Frontend build
cd ../frontend
npm install
npm run build

# Configure environment variables
cp .env.example .env
# Edit .env with production values
```

#### 5.3 Nginx Configuration
```nginx
server {
    listen 80;
    server_name your-domain.com;

    # Serve React frontend
    location / {
        root /var/www/login-app/frontend/dist;
        try_files $uri $uri/ /index.html;
    }

    # Proxy API requests to Flask
    location /api {
        proxy_pass http://localhost:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

#### 5.4 Process Management
```bash
# Start Flask backend with PM2
pm2 start backend/app.py --name "login-api" --interpreter python3

# Configure PM2 to start on boot
pm2 startup
pm2 save
```

#### 5.5 SSL Configuration
```bash
# Generate SSL certificate
sudo certbot --nginx -d your-domain.com

# Auto-renewal
sudo systemctl enable certbot.timer
```

## 🔐 Environment Variables

### Backend (.env)
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your-anon-key
SUPABASE_SERVICE_KEY=your-service-role-key
JWT_SECRET=your-jwt-secret
FLASK_ENV=production
CORS_ORIGINS=https://your-domain.com
```

### Frontend (.env)
```env
VITE_API_URL=https://your-domain.com/api
VITE_APP_TITLE=Professional Login
```

## 📊 Database Schema

Expected `personas` table structure:
```sql
CREATE TABLE personas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(100),
    created_at TIMESTAMP DEFAULT NOW(),
    last_login TIMESTAMP
);
```

## 🚦 API Endpoints

### Authentication
- `POST /api/login` - User authentication
- `GET /api/verify` - Token verification
- `POST /api/logout` - User logout (optional)

### Request/Response Format
```javascript
// Login Request
{
  "username": "user@example.com",
  "password": "userpassword"
}

// Login Response
{
  "success": true,
  "token": "jwt-token-here",
  "user": {
    "id": "uuid",
    "username": "user@example.com"
  }
}
```

## 🎨 Design Specifications

### Color Palette
- **Primary**: Orange (#FF6B35)
- **Secondary**: Dark Orange (#E55A2B)
- **Background**: White (#FFFFFF)
- **Text**: Dark Gray (#2D3748)
- **Accent**: Light Orange (#FFF5F2)

### Typography
- **Font Family**: Inter, system-ui, sans-serif
- **Headings**: Bold, 24px-32px
- **Body**: Regular, 16px
- **Input Labels**: Medium, 14px

## 🔍 Information Required

Before starting development, please provide:

1. **Supabase Credentials**
   - Project URL (you mentioned: http://basedatos.parque-e.co/)
   - Anon/Public API Key
   - Service Role Key

2. **Database Schema**
   - Column names in `personas` table
   - Current password storage method
   - Any existing user data format

3. **Design Assets**
   - softR login page reference/screenshot
   - Background image file
   - Logo or brand assets (if any)

4. **Digital Ocean Setup**
   - Preferred droplet size
   - Domain name for deployment
   - SSH key for server access

## 🚀 Quick Start Commands

```bash
# Backend development
cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python app.py

# Frontend development
cd frontend
npm install
npm run dev

# Production build
npm run build
```

## 📝 Notes

- All passwords will be securely hashed using bcrypt
- JWT tokens expire after 24 hours (configurable)
- CORS is configured for secure cross-origin requests
- Rate limiting prevents brute force attacks
- All API responses include proper error handling
- Responsive design works on mobile and desktop

## 🤝 Next Steps

1. Provide the required information listed above
2. Review and approve the development plan
3. Begin Phase 1: Environment Setup
4. Iterate through each development phase
5. Deploy to Digital Ocean droplet