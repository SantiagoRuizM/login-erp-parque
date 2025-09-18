# Security Notice

## Environment Variables

⚠️ **IMPORTANT**: Never commit real API keys, secrets, or environment files to version control.

### Setup Instructions:

1. Copy the example environment file:
   ```bash
   cp backend/.env.example backend/.env.development
   ```

2. Fill in your real values in the `.env.development` file:
   - Get your Supabase keys from: https://supabase.com/dashboard
   - Generate a strong JWT secret
   - Use your actual database URL

3. The `.env.development` file is gitignored and will not be committed

### Supabase Key Security:
- Use different keys for development and production
- Never share service role keys
- Rotate keys if they are ever exposed
- Monitor GitGuardian alerts for any accidental leaks

### File Structure:
```
backend/
├── .env.example          ✅ Safe to commit (template only)
├── .env.development      ❌ Local only (real keys)
└── .env.production       ❌ Server only (real keys)
```

## If Keys Are Compromised:
1. Immediately rotate them in Supabase dashboard
2. Update all environments with new keys
3. Remove from git history if accidentally committed