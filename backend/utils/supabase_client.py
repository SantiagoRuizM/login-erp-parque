from supabase import create_client, Client
from config import Config
import logging

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
                self._client = create_client(
                    Config.SUPABASE_URL,
                    Config.SUPABASE_KEY
                )
                logger.info("Supabase client initialized successfully")
            except Exception as e:
                logger.error(f"Failed to initialize Supabase client: {str(e)}")
                raise
    
    @property
    def client(self) -> Client:
        if self._client is None:
            raise RuntimeError("Supabase client not initialized")
        return self._client
    
    def test_connection(self):
        """Test the Supabase connection"""
        try:
            # Try a simple query to test connection
            result = self._client.table(Config.USERS_TABLE).select("count", count="exact").execute()
            logger.info("Supabase connection test successful")
            return True
        except Exception as e:
            logger.error(f"Supabase connection test failed: {str(e)}")
            return False

# Global instance
supabase_client = SupabaseClient()