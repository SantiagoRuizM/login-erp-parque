import { useState, useEffect } from 'react';
import LoginForm from './components/LoginForm';
import apiService from './services/api';
import backgroundImage from './assets/background_erp3.webp';
import iconImage from './assets/icon.png';

function App() {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Check if user is already authenticated
    const checkAuth = async () => {
      try {
        if (apiService.isAuthenticated()) {
          const userData = apiService.getUser();
          
          // Try to verify token is still valid
          try {
            await apiService.verifyToken();
            // Token is valid, set user as authenticated
            setUser(userData);
            setIsAuthenticated(true);
          } catch (tokenError) {
            // Token is invalid or expired, clear auth state
            console.log('Token invalid, clearing auth state');
            await handleLogout();
          }
        }
      } catch (error) {
        // General error, clear auth state
        console.log('Auth check error, clearing auth state');
        await handleLogout();
      } finally {
        setLoading(false);
      }
    };

    checkAuth();
  }, []);

  const handleLoginSuccess = (userData) => {
    setUser(userData);
    setIsAuthenticated(true);
    
    // Redirect to dynamic URL based on subdominio_redireccion
    setTimeout(() => {
      // Use the subdominio_redireccion field directly from user data
      const subdomain = userData.subdominio_redireccion;

      if (!subdomain) {
        console.error('No subdominio_redireccion found for user:', userData.username);
        // Fallback: go to login form
        setUser(null);
        setIsAuthenticated(false);
        return;
      }

      const redirectUrl = `https://${subdomain}.parque-e.co`;
      console.log('Redirecting to:', redirectUrl);
      
      // Clear authentication state immediately before redirect
      localStorage.removeItem('authToken');
      localStorage.removeItem('user');
      
      // Try to redirect, with fallback
      try {
        window.location.href = redirectUrl;
      } catch (error) {
        console.error('Redirect failed:', error);
        // Fallback: go to login form
        setUser(null);
        setIsAuthenticated(false);
      }
    }, 2000); // 2 second delay to show success message
  };

  const handleLogout = async () => {
    try {
      await apiService.logout();
    } catch (error) {
      console.error('Logout error:', error);
    } finally {
      setUser(null);
      setIsAuthenticated(false);
      setLoading(false); // Ensure loading is false
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center relative">
        <div 
          className="absolute inset-0 bg-cover bg-center bg-no-repeat"
          style={{ backgroundImage: `url(${backgroundImage})` }}
        >
          <div className="absolute inset-0 bg-black bg-opacity-20"></div>
        </div>
        <div className="relative z-10 animate-spin rounded-full h-12 w-12 border-b-2 border-primary"></div>
      </div>
    );
  }

  if (isAuthenticated && user) {
    return (
      <div className="min-h-screen flex items-center justify-center relative">
        <div 
          className="absolute inset-0 bg-cover bg-center bg-no-repeat"
          style={{ backgroundImage: `url(${backgroundImage})` }}
        >
          <div className="absolute inset-0 bg-black bg-opacity-20"></div>
        </div>
        
        <div className="relative z-10 w-full max-w-md mx-auto p-4">
          <div className="bg-white rounded-2xl shadow-2xl p-8 backdrop-blur-sm animate-fade-in">
            <div className="text-center mb-6">
              <div className="w-20 h-20 bg-login-gradient rounded-full mx-auto mb-4 flex items-center justify-center">
                <svg className="w-10 h-10 text-white" fill="currentColor" viewBox="0 0 20 20">
                  <path fillRule="evenodd" d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z" clipRule="evenodd" />
                </svg>
              </div>
              <h1 className="text-3xl font-bold text-gray-800 mb-2">
                ¡Acceso Exitoso!
              </h1>
              <p className="text-gray-600">
                Bienvenido, {user.username}
              </p>
              <p className="text-gray-500 text-sm mt-2">
                Redirigiendo en unos segundos...
              </p>
            </div>

            <div className="flex flex-col items-center space-y-4">
              <svg className="animate-spin h-8 w-8 text-primary" fill="none" viewBox="0 0 24 24">
                <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
              </svg>
              
              <button
                onClick={() => {
                  setUser(null);
                  setIsAuthenticated(false);
                  localStorage.removeItem('authToken');
                  localStorage.removeItem('user');
                }}
                className="mt-4 px-4 py-2 text-sm bg-gray-200 hover:bg-gray-300 text-gray-800 rounded-lg transition-colors duration-200"
              >
                Volver al Login
              </button>
            </div>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen flex items-center p-4 relative">
      {/* Background image */}
      <div 
        className="absolute inset-0 bg-cover bg-center bg-no-repeat"
        style={{ backgroundImage: `url(${backgroundImage})` }}
      >
        <div className="absolute inset-0 bg-black bg-opacity-20"></div>
      </div>
      
      {/* Main login container - positioned to the right on desktop, center on mobile */}
      <div className="relative z-10 w-full max-w-md ml-auto mr-36 md:mr-40 lg:mr-44 xl:mr-48 sm:mx-auto">
        <div className="bg-white rounded-2xl shadow-2xl p-8 backdrop-blur-sm animate-slide-up">
          {/* Logo or brand area */}
          <div className="text-center mb-8">
            <img src={iconImage} alt="Logo" className="w-16 h-16 mx-auto mb-4 object-contain" />
          </div>

          <LoginForm onLoginSuccess={handleLoginSuccess} />
        </div>
      </div>
    </div>
  );
}

export default App;