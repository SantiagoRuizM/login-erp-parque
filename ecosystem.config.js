module.exports = {
  apps: [{
    name: 'login-api',
    script: 'backend/app.py',
    interpreter: 'backend/venv/bin/python',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '512M',
    env: {
      FLASK_ENV: 'production'
    }
  }]
};