from flask import Flask, jsonify
from flask_cors import CORS
from routes.auth import auth_bp
from config import Config
from utils.supabase_client import supabase_client
import logging
from datetime import datetime

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

def create_app():
    """Application factory"""
    app = Flask(__name__)
    
    # Load configuration
    try:
        Config.validate_config()
        logger.info("Configuration validated successfully")
    except ValueError as e:
        logger.error(f"Configuration error: {str(e)}")
        raise
    
    # Configure CORS
    CORS(app, origins=Config.CORS_ORIGINS, supports_credentials=True)
    
    # Register blueprints
    app.register_blueprint(auth_bp, url_prefix='/api/auth')
    
    # Root endpoint
    @app.route('/')
    def root():
        return jsonify({
            'message': 'API ERP Odoo Parque E',
            'version': '1.0.0',
            'status': 'running',
            'timestamp': datetime.utcnow().isoformat()
        })
    
    # Health check endpoint
    @app.route('/health')
    def health():
        try:
            # Test Supabase connection
            db_status = supabase_client.test_connection()
            
            return jsonify({
                'status': 'healthy' if db_status else 'degraded',
                'database': 'connected' if db_status else 'disconnected',
                'timestamp': datetime.utcnow().isoformat()
            }), 200 if db_status else 503
            
        except Exception as e:
            logger.error(f"Health check error: {str(e)}")
            return jsonify({
                'status': 'unhealthy',
                'error': str(e),
                'timestamp': datetime.utcnow().isoformat()
            }), 503
    
    # Error handlers
    @app.errorhandler(404)
    def not_found(error):
        return jsonify({
            'success': False,
            'message': 'Endpoint not found'
        }), 404
    
    @app.errorhandler(500)
    def internal_error(error):
        logger.error(f"Internal server error: {str(error)}")
        return jsonify({
            'success': False,
            'message': 'Internal server error'
        }), 500
    
    return app

if __name__ == '__main__':
    try:
        app = create_app()
        logger.info("Starting Flask application...")
        
        # Development server
        if Config.FLASK_ENV == 'development':
            app.run(debug=True, host='0.0.0.0', port=5000)
        else:
            # Production server (use gunicorn in production)
            app.run(host='0.0.0.0', port=5000)
            
    except Exception as e:
        logger.error(f"Failed to start application: {str(e)}")
        raise