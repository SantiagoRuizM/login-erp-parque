from flask import Blueprint, request, jsonify
from models.user import User
from functools import wraps
import logging

logger = logging.getLogger(__name__)

auth_bp = Blueprint('auth', __name__)

def token_required(f):
    """Decorator to require valid JWT token"""
    @wraps(f)
    def decorated_function(*args, **kwargs):
        token = request.headers.get('Authorization')
        
        if not token:
            return jsonify({
                'success': False,
                'message': 'Token is missing'
            }), 401
        
        # Remove 'Bearer ' prefix if present
        if token.startswith('Bearer '):
            token = token[7:]
        
        payload = User.verify_token(token)
        if not payload:
            return jsonify({
                'success': False,
                'message': 'Token is invalid or expired'
            }), 401
        
        request.user = payload
        return f(*args, **kwargs)
    
    return decorated_function

@auth_bp.route('/login', methods=['POST'])
def login():
    """User login endpoint"""
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({
                'success': False,
                'message': 'No data provided'
            }), 400
        
        username = data.get('username', '').strip()
        password = data.get('password', '')
        
        # Validate input
        if not username or not password:
            return jsonify({
                'success': False,
                'message': 'Username and password are required'
            }), 400
        
        # Authenticate user
        user = User.authenticate(username, password)
        
        if user:
            # Generate token
            token = user.generate_token()
            
            logger.info(f"Successful login for user: {username}")
            
            return jsonify({
                'success': True,
                'message': 'Login successful',
                'token': token,
                'user': user.to_dict()
            }), 200
        else:
            logger.warning(f"Failed login attempt for user: {username}")
            
            return jsonify({
                'success': False,
                'message': 'Invalid username or password'
            }), 401
            
    except Exception as e:
        logger.error(f"Login error: {str(e)}")
        return jsonify({
            'success': False,
            'message': 'Internal server error'
        }), 500

@auth_bp.route('/verify', methods=['GET'])
@token_required
def verify_token():
    """Verify token endpoint"""
    try:
        return jsonify({
            'success': True,
            'message': 'Token is valid',
            'user': {
                'id': request.user.get('user_id'),
                'username': request.user.get('username')
            }
        }), 200
        
    except Exception as e:
        logger.error(f"Token verification error: {str(e)}")
        return jsonify({
            'success': False,
            'message': 'Internal server error'
        }), 500

@auth_bp.route('/logout', methods=['POST'])
@token_required
def logout():
    """User logout endpoint"""
    try:
        # In a stateless JWT system, logout is handled on the frontend
        # by removing the token from storage
        logger.info(f"User logged out: {request.user.get('username')}")
        
        return jsonify({
            'success': True,
            'message': 'Logout successful'
        }), 200
        
    except Exception as e:
        logger.error(f"Logout error: {str(e)}")
        return jsonify({
            'success': False,
            'message': 'Internal server error'
        }), 500

@auth_bp.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'success': True,
        'message': 'Auth service is running',
        'timestamp': str(datetime.utcnow())
    }), 200