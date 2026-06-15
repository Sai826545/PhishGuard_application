import React, { useState, useEffect } from 'react';
import {
  Bell,
  RefreshCw,
  Landmark,
  CreditCard,
  Truck,
  Building2,
  ShieldCheck,
  ShieldAlert,
  AlertTriangle,
  MessageSquare,
  Calendar,
} from 'lucide-react';
import api from '../services/api';
import { PGCard, SeverityChip, PGEmptyState } from '../components/PGWidgets';

const Alerts = () => {
  const [alerts, setAlerts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [selectedSeverity, setSelectedSeverity] = useState('ALL');

  const fetchAlerts = async () => {
    setLoading(true);
    setError(null);
    try {
      const response = await api.get('/alerts');
      setAlerts(response.data.data);
    } catch (err) {
      setError('Failed to fetch threat alerts.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchAlerts();
  }, []);

  const getCategoryIcon = (category) => {
    switch (category?.toUpperCase()) {
      case 'BANKING':
        return <Landmark size={18} />;
      case 'UPI_PAYMENT':
        return <CreditCard size={18} />;
      case 'COURIER':
        return <Truck size={18} />;
      case 'GOVT_SCHEME':
        return <Building2 size={18} />;
      case 'KYC':
        return <ShieldCheck size={18} />;
      case 'PHISHING':
        return <ShieldAlert size={18} />;
      case 'SMS_SCAM':
        return <MessageSquare size={18} />;
      default:
        return <AlertTriangle size={18} />;
    }
  };

  const getSeverityColor = (sev) => {
    switch (sev?.toUpperCase()) {
      case 'CRITICAL':
        return 'var(--danger)';
      case 'HIGH':
        return '#FF7043';
      case 'MEDIUM':
        return 'var(--warning)';
      case 'LOW':
        return 'var(--info)';
      default:
        return 'var(--text-secondary)';
    }
  };

  const filteredAlerts = selectedSeverity === 'ALL'
    ? alerts
    : alerts.filter((a) => (a.severity || 'MEDIUM').toUpperCase() === selectedSeverity);

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <div>
          <h2 style={{ fontSize: '24px', fontWeight: '700' }}>Threat Advisories</h2>
          <p style={{ fontSize: '13px', color: 'var(--text-secondary)' }}>
            Real-time cybersecurity & scam threat warning reports
          </p>
        </div>

        <button
          onClick={fetchAlerts}
          disabled={loading}
          style={{
            background: 'var(--card)',
            border: '1px solid var(--border)',
            borderRadius: '10px',
            width: '40px',
            height: '40px',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            cursor: 'pointer',
            color: 'var(--primary)',
            transition: 'all 0.2s ease',
          }}
          className="refresh-btn-hover"
        >
          <RefreshCw size={16} className={loading ? 'spin-anim' : ''} />
        </button>
      </div>

      {/* Severity Filter Chips */}
      <PGCard style={{ padding: '16px' }}>
        <div style={{ display: 'flex', gap: '8px', flexWrap: 'wrap' }}>
          {['ALL', 'CRITICAL', 'HIGH', 'MEDIUM', 'LOW'].map((sev) => {
            const active = selectedSeverity === sev;
            const color = sev === 'ALL' ? 'var(--primary)' : getSeverityColor(sev);
            
            return (
              <button
                key={sev}
                onClick={() => setSelectedSeverity(sev)}
                style={{
                  height: '38px',
                  padding: '0 16px',
                  borderRadius: '99px',
                  border: active ? `1px solid ${color}` : '1px solid var(--border)',
                  background: active ? `${color}1A` : 'var(--card)',
                  color: active ? color : 'var(--text-secondary)',
                  fontSize: '12px',
                  fontWeight: '700',
                  cursor: 'pointer',
                  transition: 'all 0.2s ease',
                }}
              >
                {sev}
              </button>
            );
          })}
        </div>
      </PGCard>

      {/* Alerts List */}
      {loading ? (
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', minHeight: '200px' }}>
          <span
            style={{
              width: '24px',
              height: '24px',
              border: '2px solid var(--primary)',
              borderTopColor: 'transparent',
              borderRadius: '50%',
              animation: 'rotateSpinner 0.8s linear infinite',
            }}
          />
        </div>
      ) : error ? (
        <PGEmptyState
          title="Connection Error"
          subtitle="Failed to pull live cyber threat warnings."
          onAction={fetchAlerts}
        />
      ) : filteredAlerts.length === 0 ? (
        <PGEmptyState
          title="No Alerts Found"
          subtitle="No current threats identified in this classification."
          icon={<Bell size={40} />}
        />
      ) : (
        <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
          {filteredAlerts.map((alert, i) => {
            const severityColor = getSeverityColor(alert.severity);
            return (
              <PGCard
                key={alert.id || i}
                style={{
                  animation: `slideUp 0.3s cubic-bezier(0.16, 1, 0.3, 1) ${i * 50}ms forwards`,
                  opacity: 0,
                }}
              >
                <div style={{ display: 'flex', alignItems: 'flex-start', gap: '16px' }}>
                  {/* Category icon */}
                  <div
                    style={{
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      width: '42px',
                      height: '42px',
                      borderRadius: '50%',
                      backgroundColor: `${severityColor}12`,
                      color: severityColor,
                      flexShrink: 0,
                    }}
                  >
                    {getCategoryIcon(alert.category)}
                  </div>

                  {/* Text details */}
                  <div style={{ flex: 1 }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '10px', flexWrap: 'wrap', marginBottom: '6px' }}>
                      <h3 style={{ fontSize: '15px', fontWeight: '600', color: 'var(--text-primary)', flex: 1, minWidth: '200px' }}>
                        {alert.title}
                      </h3>
                      <div style={{ display: 'flex', gap: '8px', alignItems: 'center' }}>
                        <SeverityChip severity={alert.severity} />
                        <span
                          style={{
                            fontSize: '9px',
                            fontWeight: '600',
                            backgroundColor: 'var(--surface)',
                            color: 'var(--text-disabled)',
                            padding: '3px 8px',
                            borderRadius: '99px',
                            textTransform: 'uppercase',
                          }}
                        >
                          {(alert.category || 'scam').replace('_', ' ')}
                        </span>
                      </div>
                    </div>

                    <p style={{ fontSize: '13px', color: 'var(--text-secondary)', lineHeight: '1.6', marginBottom: '12px' }}>
                      {alert.description}
                    </p>

                    {alert.publishedAt && (
                      <div style={{ display: 'flex', alignItems: 'center', gap: '6px', color: 'var(--text-disabled)', fontSize: '11px' }}>
                        <Calendar size={12} />
                        <span>Published: {new Date(alert.publishedAt).toLocaleDateString()}</span>
                      </div>
                    )}
                  </div>
                </div>
              </PGCard>
            );
          })}
        </div>
      )}
      <style>{`
        .spin-anim {
          animation: rotateSpinner 1s linear infinite;
        }
        .refresh-btn-hover:hover {
          background-color: var(--surface) !important;
          border-color: var(--primary) !important;
        }
      `}</style>
    </div>
  );
};

export default Alerts;
