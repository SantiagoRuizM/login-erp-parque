# Getting Real Supabase Production Keys

## Method 1: From Your Working VPS
If you have other services already connected to basedatos.parque-e.co:

```bash
# SSH into your working VPS
ssh user@your-vps

# Find where the working keys are stored
grep -r "SUPABASE" /var/www/ 2>/dev/null
grep -r "basedatos.parque-e.co" /var/www/ 2>/dev/null

# Or check common config locations
cat /var/www/*/backend/.env 2>/dev/null | grep SUPABASE
cat /home/*/.env 2>/dev/null | grep SUPABASE
```

## Method 2: From Supabase Dashboard
1. Go to: https://supabase.com/dashboard
2. Find your "basedatos.parque-e.co" project
3. Settings → API
4. Copy:
   - anon/public key → SUPABASE_KEY
   - service_role/secret key → SUPABASE_SERVICE_KEY

## Method 3: Generate New Keys
If you can't find the original keys:
1. Go to Supabase Dashboard
2. Settings → API
3. Click "Reset API Key" for both keys
4. Copy the new keys

## Real Production Keys Should Look Like:
```
SUPABASE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS9wbGF0Zm9ybS...
```
When decoded, they should have:
- "iss": "supabase" (NOT "supabase-demo")
- Your project reference in the payload
- Much longer and more complex than demo keys

## How to Update on Droplet:
```bash
ssh root@159.203.109.216

# Edit the environment file
nano /var/www/login-app/backend/.env

# Replace the SUPABASE_KEY and SUPABASE_SERVICE_KEY with real ones
# Save the file

# Restart the API
pm2 restart login-api

# Test the connection
curl http://localhost:5000/health
```