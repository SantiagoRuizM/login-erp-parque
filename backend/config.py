import os
from dotenv import load_dotenv

# Load environment variables - check for environment-specific files first
env_file = '.env.development' if os.getenv('FLASK_ENV') == 'development' else '.env'
load_dotenv(env_file)

class Config:
    SUPABASE_URL = os.getenv('SUPABASE_URL')
    SUPABASE_KEY = os.getenv('SUPABASE_KEY')
    SUPABASE_SERVICE_KEY = os.getenv('SUPABASE_SERVICE_KEY')
    JWT_SECRET = os.getenv('JWT_SECRET', 'your-secret-key-change-in-production')
    FLASK_ENV = os.getenv('FLASK_ENV', 'development')
    DEBUG = os.getenv('DEBUG', 'False').lower() == 'true'
    CORS_ORIGINS = os.getenv('CORS_ORIGINS', 'http://localhost:3000').split(',')

    # Database table configuration
    USERS_TABLE = os.getenv('USERS_TABLE', 'cuenta')

    # JWT Configuration
    JWT_EXPIRATION_DELTA = 24 * 60 * 60  # 24 hours in seconds
    
    @staticmethod
    def validate_config():
        required_vars = ['SUPABASE_URL', 'SUPABASE_KEY']
        missing_vars = [var for var in required_vars if not os.getenv(var)]
        
        if missing_vars:
            raise ValueError(f"Missing required environment variables: {', '.join(missing_vars)}")
        
        return True