import axios from 'axios';

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:5000/api';

class ApiService {
  constructor() {
    this.api = axios.create({
      baseURL: API_URL,
      headers: {
        'Content-Type': 'application/json',
      },
      timeout: 10000, // 10 seconds timeout
    });

    // Add request interceptor to include auth token
    this.api.interceptors.request.use(
      (config) => {
        const token = localStorage.getItem('authToken');
        if (token) {
          config.headers.Authorization = `Bearer ${token}`;
        }
        return config;
      },
      (error) => {
        return Promise.reject(error);
      }
    );

    // Add response interceptor to handle errors
    this.api.interceptors.response.use(
      (response) => response,
      (error) => {
        if (error.response?.status === 401) {
          // Token expired or invalid
          this.logout();
          window.location.reload();
        }
        return Promise.reject(error);
      }
    );
  }

  // Authentication methods
  async login(credentials) {
    try {
      const response = await this.api.post('/auth/login', credentials);
      
      if (response.data.success && response.data.token) {
        localStorage.setItem('authToken', response.data.token);
        localStorage.setItem('user', JSON.stringify(response.data.user));
      }
      
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  async verifyToken() {
    try {
      const response = await this.api.get('/auth/verify', {
        timeout: 5000 // 5 second timeout
      });
      return response.data;
    } catch (error) {
      // If token verification fails, clear local storage
      this.logout();
      throw this.handleError(error);
    }
  }

  async logout() {
    try {
      await this.api.post('/auth/logout');
    } catch (error) {
      console.error('Logout error:', error);
    } finally {
      localStorage.removeItem('authToken');
      localStorage.removeItem('user');
    }
  }

  // Utility methods
  isAuthenticated() {
    const token = localStorage.getItem('authToken');
    const user = localStorage.getItem('user');
    return !!(token && user);
  }

  getUser() {
    try {
      const user = localStorage.getItem('user');
      return user ? JSON.parse(user) : null;
    } catch {
      return null;
    }
  }

  getToken() {
    return localStorage.getItem('authToken');
  }

  // Error handling
  handleError(error) {
    const message = error.response?.data?.message || 
                   error.message || 
                   'An unexpected error occurred';
    
    return {
      message,
      status: error.response?.status,
      data: error.response?.data
    };
  }

  // Health check
  async healthCheck() {
    try {
      const response = await this.api.get('/health');
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }
}

export default new ApiService();