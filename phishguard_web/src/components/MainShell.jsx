import React from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import {
  LayoutDashboard,
  ShieldAlert,
  History,
  Bell,
  User,
  Settings,
  LogOut,
  PlusCircle,
  Menu,
} from 'lucide-react';

const MainShell = ({ children }) => {
  const { user, logout } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();

  const menuItems = [
    { label: 'Dashboard', path: '/dashboard', icon: <LayoutDashboard size={20} /> },
    { label: 'Scanner Console', path: '/scan/url', icon: <ShieldAlert size={20} /> },
    { label: 'Scam History', path: '/history', icon: <History size={20} /> },
    { label: 'Scam Alerts', path: '/alerts', icon: <Bell size={20} /> },
    { label: 'Report Scam', path: '/report', icon: <PlusCircle size={20} /> },
    { label: 'Profile', path: '/profile', icon: <User size={20} /> },
    { label: 'Settings', path: '/settings', icon: <Settings size={20} /> },
  ];

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  const isActive = (path) => {
    if (path === '/scan/url') {
      return location.pathname.startsWith('/scan');
    }
    return location.pathname === path;
  };

  return (
    <div className="app-container">
      {/* Sidebar - Desktop */}
      <aside className="sidebar">
        <div>
          <div
            onClick={() => navigate('/dashboard')}
            style={{
              cursor: 'pointer',
              marginBottom: '40px',
            }}
          >
            <h2
              style={{
                fontFamily: 'var(--font-display)',
                color: 'var(--primary)',
                fontSize: '24px',
                fontWeight: '800',
                textShadow: '0 0 10px rgba(0, 212, 170, 0.3)',
              }}
            >
              🛡️ PhishGuard
            </h2>
            <p
              style={{
                fontSize: '11px',
                color: 'var(--text-secondary)',
                fontWeight: '500',
                letterSpacing: '0.05em',
                textTransform: 'uppercase',
                marginTop: '4px',
              }}
            >
              Protecting You From Scams
            </p>
          </div>

          <nav style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
            {menuItems.map((item) => {
              const active = isActive(item.path);
              return (
                <div
                  key={item.path}
                  onClick={() => navigate(item.path)}
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    gap: '12px',
                    padding: '12px 16px',
                    borderRadius: '10px',
                    cursor: 'pointer',
                    fontSize: '14px',
                    fontWeight: active ? '600' : '400',
                    color: active ? 'var(--primary)' : 'var(--text-secondary)',
                    background: active ? 'rgba(0, 212, 170, 0.08)' : 'transparent',
                    border: active ? '1px solid rgba(0, 212, 170, 0.15)' : '1px solid transparent',
                    transition: 'all 0.2s ease',
                  }}
                  className="nav-hover-effect"
                >
                  <span style={{ color: active ? 'var(--primary)' : 'inherit' }}>
                    {item.icon}
                  </span>
                  {item.label}
                </div>
              );
            })}
          </nav>
        </div>

        <button
          onClick={handleLogout}
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: '12px',
            padding: '12px 16px',
            borderRadius: '10px',
            cursor: 'pointer',
            fontSize: '14px',
            fontWeight: '500',
            color: 'var(--danger)',
            background: 'transparent',
            border: 'none',
            textAlign: 'left',
            width: '100%',
            transition: 'all 0.2s ease',
          }}
        >
          <LogOut size={20} />
          Logout
        </button>
      </aside>

      {/* Main Content Area */}
      <div className="main-content">
        {/* Header */}
        <header className="header">
          <div>
            <h3 style={{ fontSize: '18px', fontWeight: '600' }}>
              Welcome back,{' '}
              <span style={{ color: 'var(--primary)' }}>
                {user?.username || 'User'}
              </span>
            </h3>
            <p style={{ fontSize: '11px', color: 'var(--text-secondary)' }}>
              Scan Status: Active Protection
            </p>
          </div>

          <div style={{ display: 'flex', alignItems: 'center', gap: '20px' }}>
            <div
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: '8px',
                background: 'var(--card)',
                padding: '6px 14px',
                borderRadius: '20px',
                border: '1px solid var(--border)',
              }}
            >
              <span style={{ fontSize: '11px', color: 'var(--text-secondary)' }}>
                Security Score:
              </span>
              <span
                style={{
                  fontSize: '13px',
                  fontWeight: '700',
                  color: 'var(--safe)',
                }}
              >
                {user?.securityScore ?? 100}%
              </span>
            </div>
          </div>
        </header>

        {/* Dynamic Page Views */}
        <main className="page-container animate-fade">{children}</main>
      </div>

      {/* Mobile Sticky Tab Bar */}
      <nav className="mobile-nav">
        {menuItems.slice(0, 5).map((item) => {
          const active = isActive(item.path);
          return (
            <div
              key={item.path}
              onClick={() => navigate(item.path)}
              className={`mobile-nav-item ${active ? 'active' : ''}`}
              style={{ cursor: 'pointer' }}
            >
              {item.icon}
              <span style={{ fontSize: '9px', fontWeight: '500' }}>
                {item.label.split(' ')[0]}
              </span>
            </div>
          );
        })}
      </nav>
    </div>
  );
};

export default MainShell;
