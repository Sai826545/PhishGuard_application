import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate, useLocation } from 'react-router-dom';
import { AuthProvider, useAuth } from './context/AuthContext';
import MainShell from './components/MainShell';

// Pages
import Onboarding from './pages/Onboarding';
import Login from './pages/Login';
import Signup from './pages/Signup';
import ForgotPassword from './pages/ForgotPassword';
import Dashboard from './pages/Dashboard';
import ScanUrl from './pages/ScanUrl';
import ScanQr from './pages/ScanQr';
import ScanSms from './pages/ScanSms';
import ScanEmail from './pages/ScanEmail';
import ScanResult from './pages/ScanResult';
import History from './pages/History';
import Alerts from './pages/Alerts';
import Profile from './pages/Profile';
import Settings from './pages/Settings';
import ReportScam from './pages/ReportScam';

// Route guard for authenticated pages
const PrivateRoute = ({ children }) => {
  const { user, loading } = useAuth();
  const location = useLocation();

  if (loading) {
    return (
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', minHeight: '100vh', backgroundColor: 'var(--background)' }}>
        <span
          style={{
            width: '32px',
            height: '32px',
            border: '2px solid var(--primary)',
            borderTopColor: 'transparent',
            borderRadius: '50%',
            animation: 'rotateSpinner 0.8s linear infinite',
          }}
        />
      </div>
    );
  }

  if (!user) {
    // Redirect to login but keep state of origin page
    return <Navigate to="/login" state={{ from: location }} replace />;
  }

  // Inject Main Navigation Shell around private pages
  return <MainShell>{children}</MainShell>;
};

// Route guard for public pages (Login/Signup should not be seen by logged in users)
const PublicRoute = ({ children }) => {
  const { user, loading } = useAuth();

  if (loading) return null;

  if (user) {
    return <Navigate to="/dashboard" replace />;
  }

  return children;
};

// Base redirect route checks onboarding state and auth state
const InitialRedirect = () => {
  const { user, loading } = useAuth();
  
  if (loading) return null;

  const hasSeenOnboarding = localStorage.getItem('hasSeenOnboarding') === 'true';

  if (!hasSeenOnboarding) {
    return <Navigate to="/onboarding" replace />;
  }

  return user ? <Navigate to="/dashboard" replace /> : <Navigate to="/login" replace />;
};

function App() {
  return (
    <AuthProvider>
      <Router>
        <Routes>
          {/* Base Redirect */}
          <Route path="/" element={<InitialRedirect />} />

          {/* Public Authentication routes */}
          <Route
            path="/onboarding"
            element={
              <PublicRoute>
                <Onboarding />
              </PublicRoute>
            }
          />
          <Route
            path="/login"
            element={
              <PublicRoute>
                <Login />
              </PublicRoute>
            }
          />
          <Route
            path="/signup"
            element={
              <PublicRoute>
                <Signup />
              </PublicRoute>
            }
          />
          <Route
            path="/forgot-password"
            element={
              <PublicRoute>
                <ForgotPassword />
              </PublicRoute>
            }
          />

          {/* Private Shell routes */}
          <Route
            path="/dashboard"
            element={
              <PrivateRoute>
                <Dashboard />
              </PrivateRoute>
            }
          />
          <Route
            path="/scan/url"
            element={
              <PrivateRoute>
                <ScanUrl />
              </PrivateRoute>
            }
          />
          <Route
            path="/scan/qr"
            element={
              <PrivateRoute>
                <ScanQr />
              </PrivateRoute>
            }
          />
          <Route
            path="/scan/sms"
            element={
              <PrivateRoute>
                <ScanSms />
              </PrivateRoute>
            }
          />
          <Route
            path="/scan/email"
            element={
              <PrivateRoute>
                <ScanEmail />
              </PrivateRoute>
            }
          />
          <Route
            path="/scan/result"
            element={
              <PrivateRoute>
                <ScanResult />
              </PrivateRoute>
            }
          />
          <Route
            path="/history"
            element={
              <PrivateRoute>
                <History />
              </PrivateRoute>
            }
          />
          <Route
            path="/alerts"
            element={
              <PrivateRoute>
                <Alerts />
              </PrivateRoute>
            }
          />
          <Route
            path="/profile"
            element={
              <PrivateRoute>
                <Profile />
              </PrivateRoute>
            }
          />
          <Route
            path="/settings"
            element={
              <PrivateRoute>
                <Settings />
              </PrivateRoute>
            }
          />
          <Route
            path="/report"
            element={
              <PrivateRoute>
                <ReportScam />
              </PrivateRoute>
            }
          />

          {/* Redirect all unmatched routes */}
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </Router>
    </AuthProvider>
  );
}

export default App;
