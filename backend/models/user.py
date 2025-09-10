import bcrypt
import jwt
from datetime import datetime, timedelta
from typing import Optional, Dict, Any
from utils.supabase_client import supabase_client
from config import Config
import logging

logger = logging.getLogger(__name__)

class User:
    def __init__(self, user_data: Dict[str, Any]):
        self.id = user_data.get('id')
        self.username = user_data.get('nombre_usuario')
        self.email = user_data.get('email')  # Not in your table, but keeping for compatibility
        self.created_at = user_data.get('fecha_creacion')
        self.last_login = user_data.get('ultimo_acceso')
        self.active = user_data.get('activa')
        self.account_type = user_data.get('tipo_cuenta')
    
    @staticmethod
    def hash_password(password: str) -> str:
        """Hash a password using bcrypt"""
        salt = bcrypt.gensalt()
        return bcrypt.hashpw(password.encode('utf-8'), salt).decode('utf-8')
    
    @staticmethod
    def verify_password(password: str, hashed_password: str) -> bool:
        """Verify a password against its hash"""
        try:
            return bcrypt.checkpw(password.encode('utf-8'), hashed_password.encode('utf-8'))
        except Exception as e:
            logger.error(f"Password verification error: {str(e)}")
            return False
    
    @staticmethod
    def authenticate(username: str, password: str) -> Optional['User']:
        """Authenticate a user with username and password"""
        try:
            # Query user from Supabase
            result = supabase_client.client.table(Config.USERS_TABLE)\
                .select("*")\
                .eq("nombre_usuario", username)\
                .execute()
            
            if not result.data:
                logger.warning(f"Empresa no encontrada: {username}")
                return None
            
            user_data = result.data[0]
            
            # Verify password
            if User.verify_password(password, user_data.get('contrasena_hash', '')):
                # Update last login
                User.update_last_login(user_data['id'])
                return User(user_data)
            else:
                logger.warning(f"Contraseña invalida: {username}")
                return None
                
        except Exception as e:
            logger.error(f"Error de Autenticacion: {str(e)}")
            return None
    
    @staticmethod
    def update_last_login(user_id: str) -> bool:
        """Update user's last login timestamp"""
        try:
            supabase_client.client.table(Config.USERS_TABLE)\
                .update({"ultimo_acceso": datetime.utcnow().isoformat()})\
                .eq("id", user_id)\
                .execute()
            return True
        except Exception as e:
            logger.error(f"Failed to update last login: {str(e)}")
            return False
    
    def generate_token(self) -> str:
        """Generate JWT token for the user"""
        try:
            payload = {
                'user_id': self.id,
                'username': self.username,
                'exp': datetime.utcnow() + timedelta(seconds=Config.JWT_EXPIRATION_DELTA),
                'iat': datetime.utcnow()
            }
            
            token = jwt.encode(payload, Config.JWT_SECRET, algorithm='HS256')
            return token
        except Exception as e:
            logger.error(f"Token generation error: {str(e)}")
            raise
    
    @staticmethod
    def verify_token(token: str) -> Optional[Dict[str, Any]]:
        """Verify and decode JWT token"""
        try:
            payload = jwt.decode(token, Config.JWT_SECRET, algorithms=['HS256'])
            return payload
        except jwt.ExpiredSignatureError:
            logger.warning("Token has expired")
            return None
        except jwt.InvalidTokenError as e:
            logger.warning(f"Invalid token: {str(e)}")
            return None
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert user object to dictionary (excluding sensitive data)"""
        return {
            'id': self.id,
            'username': self.username,
            'email': self.email,  # May be None since it's not in your table
            'created_at': self.created_at,
            'last_login': self.last_login,
            'active': self.active,
            'account_type': self.account_type
        }