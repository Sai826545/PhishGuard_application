import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Settings,
  Moon,
  Fingerprint,
  MessageSquare,
  Bell,
  Globe,
  Trash2,
  HelpCircle,
  ShieldAlert,
  LogOut,
  ChevronRight,
  Info,
} from 'lucide-react';
import api from '../services/api';
import { PGCard, PGButton } from '../components/PGWidgets';
import { useAuth } from '../context/AuthContext';

const SettingsPage = () => {
  const [settings, setSettings] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const { logout } = useAuth();
  const navigate = useNavigate();

  const fetchSettings = async () => {
    try {
      const response = await api.get('/settings');
      setSettings(response.data.data);
    } catch (err) {
      setError('Failed to fetch settings config.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchSettings();
  }, []);

  const handleUpdate = async (key, value) => {
    // Optimistic UI update
    setSettings((prev) => ({ ...prev, [key]: value }));
    try {
      await api.put('/settings/update', { [key]: value });
    } catch (err) {
      alert('Failed to update setting.');
      // Rollback
      fetchSettings();
    }
  };

  const handleLogout = () => {
    if (window.confirm('Are you sure you want to logout?')) {
      logout();
      navigate('/login');
    }
  };

  if (loading) {
    return (
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', minHeight: '300px' }}>
        <span
          style={{
            width: '28px',
            height: '28px',
            border: '2px solid var(--primary)',
            borderTopColor: 'transparent',
            borderRadius: '50%',
            animation: 'rotateSpinner 0.8s linear infinite',
          }}
        />
      </div>
    );
  }

  if (error) {
    return (
      <div style={{ padding: '40px', textAlign: 'center', color: 'var(--text-disabled)' }}>
        {error}
      </div>
    );
  }

  const sections = [
    {
      title: 'Appearance',
      items: [
        {
          label: 'Dark Mode',
          desc: 'Use the cybersecurity neon theme',
          icon: <Moon size={18} style={{ color: 'var(--accent)' }} />,
          control: (
            <input
              type="checkbox"
              className="pg-switch"
              checked={settings.darkMode ?? true}
              onChange={(e) => handleUpdate('darkMode', e.target.checked)}
            />
          ),
        },
      ],
    },
    {
      title: 'Security',
      items: [
        {
          label: 'Biometric Login',
          desc: 'Simulate fingerprint recognition verification',
          icon: <Fingerprint size={18} style={{ color: 'var(--primary)' }} />,
          control: (
            <input
              type="checkbox"
              className="pg-switch"
              checked={settings.biometricLogin ?? false}
              onChange={(e) => handleUpdate('biometricLogin', e.target.checked)}
            />
          ),
        },
        {
          label: 'Auto-scan SMS',
          desc: 'Analyze incoming texts dynamically',
          icon: <MessageSquare size={18} style={{ color: 'var(--warning)' }} />,
          control: (
            <input
              type="checkbox"
              className="pg-switch"
              checked={settings.autoScanSms ?? false}
              onChange={(e) => handleUpdate('autoScanSms', e.target.checked)}
            />
          ),
        },
      ],
    },
    {
      title: 'Notifications',
      items: [
        {
          label: 'Push Notifications',
          desc: 'Alert warnings & security tips',
          icon: <Bell size={18} style={{ color: 'var(--info)' }} />,
          control: (
            <input
              type="checkbox"
              className="pg-switch"
              checked={settings.notificationsEnabled ?? true}
              onChange={(e) => handleUpdate('notificationsEnabled', e.target.checked)}
            />
          ),
        },
      ],
    },
    {
      title: 'Language',
      items: [
        {
          label: 'Preferred Language',
          desc: 'Set app text translations locale',
          icon: <Globe size={18} style={{ color: 'var(--primary)' }} />,
          control: (
            <select
              value={settings.language ?? 'en'}
              onChange={(e) => handleUpdate('language', e.target.value)}
              style={{
                background: 'var(--card-elevated)',
                border: '1px solid var(--border)',
                borderRadius: '8px',
                color: 'var(--text-primary)',
                padding: '4px 8px',
                fontSize: '13px',
                outline: 'none',
                cursor: 'pointer',
              }}
            >
              <option value="en">English</option>
              <option value="hi">हिंदी (Hindi)</option>
              <option value="ta">தமிழ் (Tamil)</option>
              <option value="te">తెలుగు (Telugu)</option>
              <option value="bn">বাংলা (Bengali)</option>
              <option value="mr">मराठी (Marathi)</option>
            </select>
          ),
        },
      ],
    },
    {
      title: 'Privacy & Data',
      items: [
        {
          label: 'Share Anonymous Data',
          desc: 'Transmit telemetry metadata to improve threat heuristics',
          icon: <Settings size={18} style={{ color: 'var(--text-secondary)' }} />,
          control: (
            <input
              type="checkbox"
              className="pg-switch"
              checked={settings.shareAnonymousData ?? false}
              onChange={(e) => handleUpdate('shareAnonymousData', e.target.checked)}
            />
          ),
        },
        {
          label: 'Clear Scan History',
          desc: 'Remove past records stored on local servers',
          icon: <Trash2 size={18} style={{ color: 'var(--danger)' }} />,
          control: <ChevronRight size={18} style={{ color: 'var(--text-disabled)' }} />,
          action: () => alert('Feature coming soon.'),
        },
      ],
    },
    {
      title: 'System & Info',
      items: [
        {
          label: 'Help & About',
          desc: 'PhishGuard Web Client v1.0.0',
          icon: <HelpCircle size={18} style={{ color: 'var(--info)' }} />,
          control: <ChevronRight size={18} style={{ color: 'var(--text-disabled)' }} />,
          action: () => alert('PhishGuard Web client is built using React.js and interacts with the Spring Boot Security backend.'),
        },
        {
          label: 'Privacy Policy',
          desc: 'Review terms & credentials details',
          icon: <Info size={18} style={{ color: 'var(--primary)' }} />,
          control: <ChevronRight size={18} style={{ color: 'var(--text-disabled)' }} />,
          action: () => alert('Privacy policy is loaded dynamically on request.'),
        },
      ],
    },
  ];

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '24px', maxWidth: '800px', margin: '0 auto' }}>
      <div>
        <h2 style={{ fontSize: '24px', fontWeight: '700' }}>App Settings</h2>
        <p style={{ fontSize: '13px', color: 'var(--text-secondary)' }}>
          Manage your application preferences and local permissions
        </p>
      </div>

      <div style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
        {sections.map((section, idx) => (
          <div key={idx}>
            <h4
              style={{
                fontSize: '11px',
                fontWeight: '700',
                color: 'var(--text-disabled)',
                textTransform: 'uppercase',
                letterSpacing: '0.08em',
                marginBottom: '10px',
                paddingLeft: '4px',
              }}
            >
              {section.title}
            </h4>

            <PGCard style={{ padding: '0px', overflow: 'hidden' }}>
              <div style={{ display: 'flex', flexDirection: 'column' }}>
                {section.items.map((item, itemIdx) => (
                  <div
                    key={itemIdx}
                    onClick={item.action}
                    style={{
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'space-between',
                      padding: '16px 20px',
                      borderBottom: itemIdx === section.items.length - 1 ? 'none' : '1px solid var(--border)',
                      cursor: item.action ? 'pointer' : 'default',
                    }}
                    className={item.action ? 'settings-tile-hover' : ''}
                  >
                    <div style={{ display: 'flex', alignItems: 'center', gap: '14px' }}>
                      <div
                        style={{
                          width: '36px',
                          height: '36px',
                          borderRadius: '8px',
                          display: 'flex',
                          alignItems: 'center',
                          justifyContent: 'center',
                          background: 'rgba(255,255,255,0.02)',
                          border: '1px solid var(--border)',
                        }}
                      >
                        {item.icon}
                      </div>
                      <div>
                        <h4 style={{ fontSize: '14px', fontWeight: '600' }}>{item.label}</h4>
                        <p style={{ fontSize: '11px', color: 'var(--text-secondary)' }}>{item.desc}</p>
                      </div>
                    </div>

                    <div>{item.control}</div>
                  </div>
                ))}
              </div>
            </PGCard>
          </div>
        ))}
      </div>

      <PGButton
        label="Logout Account"
        onClick={handleLogout}
        variant="secondary"
        icon={<LogOut size={16} />}
        style={{ borderColor: 'var(--danger)', color: 'var(--danger)', marginTop: '12px' }}
        className="logout-btn-border"
      />

      <style>{`
        .settings-tile-hover:hover {
          background-color: rgba(255, 255, 255, 0.01) !important;
        }
        .logout-btn-border {
          border-color: var(--danger) !important;
          color: var(--danger) !important;
        }
        .logout-btn-border:hover {
          background-color: var(--danger-bg) !important;
        }
        /* Custom toggle switches styling */
        .pg-switch {
          appearance: none;
          width: 38px;
          height: 20px;
          border-radius: 99px;
          background-color: var(--border);
          position: relative;
          cursor: pointer;
          outline: none;
          transition: background-color 0.2s ease;
        }
        .pg-switch:checked {
          background-color: var(--primary);
        }
        .pg-switch::before {
          content: "";
          position: absolute;
          width: 14px;
          height: 14px;
          border-radius: 50%;
          background-color: #fff;
          top: 3px;
          left: 3px;
          transition: transform 0.2s ease;
        }
        .pg-switch:checked::before {
          transform: translateX(18px);
          background-color: #0A0E1A;
        }
      `}</style>
    </div>
  );
};

export default SettingsPage;
