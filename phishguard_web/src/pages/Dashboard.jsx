import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Link,
  QrCode,
  MessageSquare,
  Mail,
  AlertOctagon,
  Shield,
  Activity,
  UserCheck,
  ChevronRight,
  Lightbulb,
} from 'lucide-react';
import api from '../services/api';
import { PGCard, SeverityChip, StatusChip } from '../components/PGWidgets';

const Dashboard = () => {
  const [stats, setStats] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const navigate = useNavigate();

  useEffect(() => {
    const fetchStats = async () => {
      try {
        const response = await api.get('/dashboard/stats');
        setStats(response.data.data);
      } catch (err) {
        setError('Failed to load dashboard metrics.');
      } finally {
        setLoading(false);
      }
    };
    fetchStats();
  }, []);

  const quickActions = [
    { label: 'URL Scanner', path: '/scan/url', icon: <Link size={24} style={{ color: 'var(--danger)' }} /> },
    { label: 'QR Scanner', path: '/scan/qr', icon: <QrCode size={24} style={{ color: 'var(--primary)' }} /> },
    { label: 'SMS Scanner', path: '/scan/sms', icon: <MessageSquare size={24} style={{ color: 'var(--accent)' }} /> },
    { label: 'Email Scanner', path: '/scan/email', icon: <Mail size={24} style={{ color: 'var(--info)' }} /> },
    { label: 'Report Scam', path: '/report', icon: <AlertOctagon size={24} style={{ color: 'var(--warning)' }} /> },
  ];

  const handleScanClick = (scan) => {
    navigate('/scan/result', { state: { result: scan } });
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

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '30px' }}>
      {/* Metrics Grid */}
      <div className="metrics-grid">
        <PGCard className="metric-card">
          <div className="metric-icon-box" style={{ background: 'var(--safe-bg)', color: 'var(--safe)' }}>
            <Shield size={24} />
          </div>
          <div className="metric-details">
            <h4>{stats.securityScore}%</h4>
            <p>Security Score</p>
          </div>
        </PGCard>

        <PGCard className="metric-card">
          <div className="metric-icon-box" style={{ background: 'var(--info-bg)', color: 'var(--info)' }}>
            <Activity size={24} />
          </div>
          <div className="metric-details">
            <h4>{stats.totalScans}</h4>
            <p>Total Scans</p>
          </div>
        </PGCard>

        <PGCard className="metric-card">
          <div className="metric-icon-box" style={{ background: 'var(--danger-bg)', color: 'var(--danger)' }}>
            <UserCheck size={24} />
          </div>
          <div className="metric-details">
            <h4>{stats.blockedThreats}</h4>
            <p>Threats Blocked</p>
          </div>
        </PGCard>
      </div>

      {/* Quick Actions */}
      <div>
        <h3 style={{ fontSize: '18px', fontWeight: '700', marginBottom: '16px' }}>Quick Actions</h3>
        <div className="quick-actions">
          {quickActions.map((action) => (
            <PGCard
              key={action.path}
              className="action-card interactive"
              onClick={() => navigate(action.path)}
            >
              {action.icon}
              <span>{action.label}</span>
            </PGCard>
          ))}
        </div>
      </div>

      {/* Daily Security Tip Banner */}
      {stats.dailyCybertip && (
        <PGCard
          style={{
            background: 'linear-gradient(135deg, var(--card), var(--surface))',
            borderLeft: '4px solid var(--primary)',
            display: 'flex',
            gap: '16px',
            alignItems: 'flex-start',
            marginBottom: '30px',
          }}
        >
          <Lightbulb size={24} style={{ color: 'var(--primary)', flexShrink: 0, marginTop: '2px' }} />
          <div>
            <h4 style={{ fontSize: '14px', fontWeight: '700', color: 'var(--primary)', marginBottom: '4px' }}>
              Daily Security Tip
            </h4>
            <p style={{ fontSize: '13px', color: 'var(--text-primary)', lineHeight: '1.5' }}>
              {stats.dailyCybertip.replace('💡', '').trim()}
            </p>
          </div>
        </PGCard>
      )}

      {/* Main Grid: Activity & Feeds */}
      <div
        style={{
          display: 'grid',
          gridTemplateColumns: 'minmax(0, 1fr) minmax(0, 1fr)',
          gap: '30px',
        }}
        className="dashboard-columns-responsive"
      >
        {/* Left Column: Recent Scans */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: '30px' }}>
          <PGCard>
            <h3 style={{ fontSize: '16px', fontWeight: '700', marginBottom: '16px' }}>Recent Scan Activity</h3>
            <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
              {stats.recentScans && stats.recentScans.length > 0 ? (
                stats.recentScans.map((scan) => (
                  <div
                    key={scan.id}
                    onClick={() => handleScanClick(scan)}
                    style={{
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'space-between',
                      padding: '12px',
                      borderRadius: '10px',
                      backgroundColor: 'var(--surface)',
                      border: '1px solid var(--border)',
                      cursor: 'pointer',
                      transition: 'border-color 0.2s ease',
                    }}
                    className="scan-item-hover"
                  >
                    <div style={{ display: 'flex', alignItems: 'center', gap: '12px', minWidth: 0 }}>
                      <div
                        style={{
                          width: '10px',
                          height: '10px',
                          borderRadius: '50%',
                          backgroundColor:
                            scan.resultStatus === 'SAFE'
                              ? 'var(--safe)'
                              : scan.resultStatus === 'SUSPICIOUS'
                              ? 'var(--warning)'
                              : 'var(--danger)',
                        }}
                      />
                      <div style={{ minWidth: 0 }}>
                        <h4
                          style={{
                            fontSize: '13px',
                            fontWeight: '600',
                            overflow: 'hidden',
                            textOverflow: 'ellipsis',
                            whiteSpace: 'nowrap',
                          }}
                        >
                          {scan.scannedContent}
                        </h4>
                        <p style={{ fontSize: '11px', color: 'var(--text-secondary)' }}>
                          {scan.scanType} Scan • {new Date(scan.scannedAt).toLocaleDateString()}
                        </p>
                      </div>
                    </div>
                    <ChevronRight size={16} style={{ color: 'var(--text-disabled)' }} />
                  </div>
                ))
              ) : (
                <p style={{ fontSize: '13px', color: 'var(--text-secondary)', textAlign: 'center', padding: '20px 0' }}>
                  No recent scans found.
                </p>
              )}
            </div>
          </PGCard>
        </div>

        {/* Right Column: Threat Advisories */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: '30px' }}>
          <PGCard>
            <h3 style={{ fontSize: '16px', fontWeight: '700', marginBottom: '16px' }}>Latest Security Feeds</h3>
            <div style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
              {stats.latestAlerts && stats.latestAlerts.length > 0 ? (
                stats.latestAlerts.map((alert) => (
                  <div
                    key={alert.id}
                    style={{
                      paddingBottom: '14px',
                      borderBottom: '1px solid var(--border)',
                      display: 'flex',
                      flexDirection: 'column',
                      gap: '6px',
                    }}
                    className="last-border-none"
                  >
                    <div style={{ display: 'flex', alignItems: 'center', gap: '8px', justifyContent: 'space-between' }}>
                      <h4
                        style={{
                          fontSize: '13px',
                          fontWeight: '600',
                          overflow: 'hidden',
                          textOverflow: 'ellipsis',
                          display: '-webkit-box',
                          WebkitLineClamp: 2,
                          WebkitBoxOrient: 'vertical',
                          lineHeight: '1.4',
                          flex: 1,
                        }}
                      >
                        {alert.title}
                      </h4>
                      <SeverityChip severity={alert.severity} />
                    </div>
                    <p
                      style={{
                        fontSize: '11px',
                        color: 'var(--text-secondary)',
                        overflow: 'hidden',
                        textOverflow: 'ellipsis',
                        display: '-webkit-box',
                        WebkitLineClamp: 2,
                        WebkitBoxOrient: 'vertical',
                        lineHeight: '1.5',
                      }}
                    >
                      {alert.description}
                    </p>
                  </div>
                ))
              ) : (
                <p style={{ fontSize: '13px', color: 'var(--text-secondary)', textAlign: 'center', padding: '20px 0' }}>
                  No threat advisories available.
                </p>
              )}
            </div>
          </PGCard>
        </div>
      </div>
      
      {/* Inline media responsiveness styles */}
      <style>{`
        @media (max-width: 992px) {
          .dashboard-columns-responsive {
            grid-template-columns: 1fr !important;
          }
        }
      `}</style>
    </div>
  );
};

export default Dashboard;
