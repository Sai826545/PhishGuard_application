import React, { createContext, useState, useEffect, useContext } from 'react';
import api from '../services/api';

const AuthContext = createContext(null);

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    // Load user on startup
    const storedUser = localStorage.getItem('user');
    if (storedUser) {
      try {
        setUser(JSON.parse(storedUser));
      } catch (_) {
        localStorage.removeItem('user');
      }
    }
    setLoading(false);

    // Listen to token expiry event from api.js
    const handleAuthExpired = () => {
      setUser(null);
      setError('Session expired. Please login again.');
    };

    window.addEventListener('auth-expired', handleAuthExpired);
    return () => {
      window.removeEventListener('auth-expired', handleAuthExpired);
    };
  }, []);

  const login = async (email, password) => {
    setLoading(true);
    setError(null);
    try {
      const response = await api.post('/auth/login', { email, password });
      const userData = response.data.data;
      
      localStorage.setItem('accessToken', userData.accessToken);
      localStorage.setItem('refreshToken', userData.refreshToken);
      localStorage.setItem('user', JSON.stringify(userData));
      
      setUser(userData);
      setLoading(false);
      return userData;
    } catch (err) {
      setLoading(false);
      const msg = err.response?.data?.message || 'Login failed. Please check your credentials.';
      setError(msg);
      throw new Error(msg);
    }
  };

  const signup = async (username, email, password) => {
    setLoading(true);
    setError(null);
    try {
      const response = await api.post('/auth/signup', { username, email, password });
      const userData = response.data.data;
      
      localStorage.setItem('accessToken', userData.accessToken);
      localStorage.setItem('refreshToken', userData.refreshToken);
      localStorage.setItem('user', JSON.stringify(userData));
      
      setUser(userData);
      setLoading(false);
      return userData;
    } catch (err) {
      setLoading(false);
      const msg = err.response?.data?.message || 'Sign up failed. Email or username might be already taken.';
      setError(msg);
      throw new Error(msg);
    }
  };

  const logout = () => {
    localStorage.removeItem('accessToken');
    localStorage.removeItem('refreshToken');
    localStorage.removeItem('user');
    setUser(null);
    setError(null);
  };

  const forgotPassword = async (email) => {
    try {
      await api.post(`/auth/forgot-password?email=${encodeURIComponent(email)}`);
    } catch (err) {
      const msg = err.response?.data?.message || 'Failed to send OTP code.';
      throw new Error(msg);
    }
  };

  const resetPassword = async (email, otp, newPassword) => {
    try {
      await api.post('/auth/reset-password', { email, otp, newPassword });
    } catch (err) {
      const msg = err.response?.data?.message || 'Failed to reset password. Verify OTP.';
      throw new Error(msg);
    }
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        loading,
        error,
        login,
        signup,
        logout,
        forgotPassword,
        resetPassword,
        setError,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => useContext(AuthContext);
export default AuthContext;
