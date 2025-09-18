from supabase import create_client, Client
from config import Config
import logging
import requests

logger = logging.getLogger(__name__)

class SupabaseClient:
    _instance = None
    _client: Client = None
    
    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(SupabaseClient, cls).__new__(cls)
        return cls._instance
    
    def __init__(self):
        if self._client is None:
            try:
                Config.validate_config()
                
                # Log connection details (without sensitive keys)
                logger.info(f"Initializing Supabase client with URL: {Config.SUPABASE_URL}")
                
                self._client = create_client(
                    Config.SUPABASE_URL,
                    Config.SUPABASE_KEY
                )
                logger.info("Supabase client initialized successfully")
                
                # Test connection immediately
                if self.test_connection():
                    logger.info("Initial connection test passed")
                else:
                    logger.warning("Initial connection test failed")
                    
            except Exception as e:
                logger.error(f"Failed to initialize Supabase client: {str(e)}")
                raise
    
    @property
    def client(self) -> Client:
        if self._client is None:
            raise RuntimeError("Supabase client not initialized")
        return self._client
    
    def test_connection(self):
        """Test the Supabase connection with multiple methods"""
        try:
            # Method 1: Try a simple table count query
            logger.info(f"Testing connection to table: {Config.USERS_TABLE}")
            result = self._client.table(Config.USERS_TABLE).select("*", count="exact").limit(1).execute()
            logger.info(f"Connection test successful. Table query returned {len(result.data)} rows")
            return True
            
        except Exception as e:
            logger.error(f"Supabase table query failed: {str(e)}")
            
            # Method 2: Try direct HTTP request to test basic connectivity
            try:
                logger.info("Attempting direct HTTP test...")
                headers = {
                    'apikey': Config.SUPABASE_KEY,
                    'Authorization': f'Bearer {Config.SUPABASE_KEY}',
                    'Content-Type': 'application/json'
                }
                
                response = requests.get(
                    f"{Config.SUPABASE_URL}/{Config.USERS_TABLE}?limit=1",
                    headers=headers,
                    timeout=10
                )
                
                if response.status_code == 200:
                    logger.info(f"HTTP test successful. Status: {response.status_code}")
                    return True
                else:
                    logger.error(f"HTTP test failed. Status: {response.status_code}, Response: {response.text}")
                    return False
                    
            except Exception as http_e:
                logger.error(f"HTTP connection test also failed: {str(http_e)}")
                return False

# Global instance
supabase_client = SupabaseClient()