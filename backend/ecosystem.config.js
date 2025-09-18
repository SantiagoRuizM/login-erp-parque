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
    }
  }]
};