import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { Link, QrCode, MessageSquare, Mail, Clipboard, X, Shield, Clock, ArrowUpRight } from 'lucide-react';
import api from '../services/api';
import { PGCard, PGButton } from '../components/PGWidgets';

const ScanUrl = () => {
  const [url, setUrl] = useState('');
  const [loading, setLoading] = useState(false);
  const [recentLinks, setRecentLinks] = useState([]);
  const navigate = useNavigate();

  useEffect(() => {
    const stored = localStorage.getItem('recentUrls');
    if (stored) {
      try {
        setRecentLinks(JSON.parse(stored));
      } catch (_) {
        setRecentLinks([]);
      }
    }
  }, []);

  const handlePaste = async () => {
    try {
      const text = await navigator.clipboard.readText();
      if (text) setUrl(text);
    } catch (_) {
      alert('Failed to read from clipboard. Please paste manually.');
    }
  };

  const handleScan = async (scanUrl) => {
    const targetUrl = scanUrl || url.trim();
    if (!targetUrl) return;

    setLoading(true);
    try {
      const response = await api.post('/scan/url', { content: targetUrl });
      const result = response.data.data;

      // Update recent links in localStorage
      let updatedList = [targetUrl, ...recentLinks.filter((item) => item !== targetUrl)];
      updatedList = updatedList.slice(0, 5); // Limit to top 5
      setRecentLinks(updatedList);
      localStorage.setItem('recentUrls', JSON.stringify(updatedList));

      navigate('/scan/result', { state: { result } });
    } catch (err) {
      alert(err.response?.data?.message || 'Failed to complete scan. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const otherScanTypes = [
    { label: 'QR Code', path: '/scan/qr', icon: <QrCode size={14} style={{ color: 'var(--primary)' }} /> },
    { label: 'SMS Body', path: '/scan/sms', icon: <MessageSquare size={14} style={{ color: 'var(--accent)' }} /> },
    { label: 'Email Text', path: '/scan/email', icon: <Mail size={14} style={{ color: 'var(--info)' }} /> },
  ];

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '24px', maxWidth: '720px', margin: '0 auto' }}>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <div>
          <h2 style={{ fontSize: '24px', fontWeight: '700' }}>Scanner Console</h2>
          <p style={{ fontSize: '13px', color: 'var(--text-secondary)' }}>
            Select a target to run heuristics threat analysis
          </p>
        </div>
        <button
          onClick={() => navigate('/scan/qr')}
          style={{
            background: 'var(--card)',
            border: '1px solid var(--border)',
            borderRadius: '10px',
            padding: '8px 16px',
            fontSize: '13px',
            color: 'var(--primary)',
            fontWeight: '600',
            cursor: 'pointer',
            display: 'flex',
            alignItems: 'center',
            gap: '8px',
            transition: 'all 0.2s ease',
          }}
          className="scanner-switch-btn"
        >
          <QrCode size={16} />
          <span>QR Scanner</span>
        </button>
      </div>

      <PGCard>
        <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
          {/* Section info */}
          <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
            <div
              style={{
                width: '42px',
                height: '42px',
                borderRadius: '10px',
                backgroundColor: 'rgba(255, 76, 76, 0.12)',
                color: 'var(--danger)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
              }}
            >
              <Link size={20} />
            </div>
            <div>
              <h3 style={{ fontSize: '16px', fontWeight: '700' }}>URL Phishing Scanner</h3>
              <p style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>
                Analyze link structure, domain age, SSL security, and blacklists
              </p>
            </div>
          </div>

          {/* URL text input */}
          <div
            style={{
              background: 'var(--surface)',
              border: '1px solid rgba(0, 212, 170, 0.3)',
              borderRadius: '12px',
              padding: '16px',
              display: 'flex',
              flexDirection: 'column',
              gap: '12px',
            }}
          >
            <textarea
              placeholder="Paste suspicious link here (e.g. http://sbionline-kyc.com)..."
              value={url}
              onChange={(e) => setUrl(e.target.value)}
              style={{
                background: 'transparent',
                border: 'none',
                outline: 'none',
                color: 'var(--text-primary)',
                fontFamily: 'var(--font-mono)',
                fontSize: '13px',
                resize: 'none',
                minHeight: '72px',
                width: '100%',
              }}
            />

            {/* Input Action Controls */}
            <div style={{ display: 'flex', gap: '10px', alignSelf: 'flex-end' }}>
              <button
                type="button"
                onClick={handlePaste}
                style={{
                  background: 'transparent',
                  border: '1px solid var(--border)',
                  borderRadius: '8px',
                  color: 'var(--text-secondary)',
                  fontSize: '12px',
                  fontWeight: '600',
                  padding: '6px 12px',
                  display: 'flex',
                  alignItems: 'center',
                  gap: '6px',
                  cursor: 'pointer',
                }}
                className="input-btn-hover"
              >
                <Clipboard size={12} />
                <span>Paste</span>
              </button>
              <button
                type="button"
                onClick={() => setUrl('')}
                style={{
                  background: 'transparent',
                  border: '1px solid var(--border)',
                  borderRadius: '8px',
                  color: 'var(--text-secondary)',
                  fontSize: '12px',
                  fontWeight: '600',
                  padding: '6px 12px',
                  display: 'flex',
                  alignItems: 'center',
                  gap: '6px',
                  cursor: 'pointer',
                }}
                className="input-btn-hover"
              >
                <X size={12} />
                <span>Clear</span>
              </button>
            </div>
          </div>

          {/* Scan button */}
          <PGButton
            label={loading ? 'Analyzing domain credentials...' : 'Scan Now'}
            isLoading={loading}
            onClick={() => handleScan()}
            icon={<Shield size={16} style={{ color: '#0A0E1A' }} />}
          />
        </div>
      </PGCard>

      {/* Switch Other Scan Types */}
      <div>
        <h4
          style={{
            fontSize: '11px',
            color: 'var(--text-disabled)',
            textTransform: 'uppercase',
            fontWeight: '700',
            letterSpacing: '0.08em',
            marginBottom: '12px',
          }}
        >
          Other Scanner Suites
        </h4>
        <div style={{ display: 'flex', gap: '10px', flexWrap: 'wrap' }}>
          {otherScanTypes.map((type) => (
            <div
              key={type.path}
              onClick={() => navigate(type.path)}
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: '8px',
                padding: '10px 16px',
                borderRadius: '99px',
                background: 'var(--card)',
                border: '1px solid var(--border)',
                cursor: 'pointer',
                fontSize: '12px',
                fontWeight: '600',
                transition: 'all 0.2s ease',
              }}
              className="chip-hover-effect"
            >
              {type.icon}
              <span>{type.label}</span>
            </div>
          ))}
        </div>
      </div>

      {/* Recent Scans Links */}
      {recentLinks.length > 0 && (
        <div>
          <h4
            style={{
              fontSize: '11px',
              color: 'var(--text-disabled)',
              textTransform: 'uppercase',
              fontWeight: '700',
              letterSpacing: '0.08em',
              marginBottom: '12px',
            }}
          >
            Recent Scans
          </h4>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
            {recentLinks.map((linkItem, idx) => (
              <div
                key={idx}
                onClick={() => handleScan(linkItem)}
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'space-between',
                  padding: '12px 16px',
                  borderRadius: '10px',
                  background: 'var(--card)',
                  border: '1px solid var(--border)',
                  cursor: 'pointer',
                  transition: 'all 0.2s ease',
                }}
                className="chip-hover-effect"
              >
                <div style={{ display: 'flex', alignItems: 'center', gap: '10px', minWidth: 0, flex: 1 }}>
                  <Clock size={14} style={{ color: 'var(--text-disabled)', flexShrink: 0 }} />
                  <span
                    style={{
                      fontSize: '12px',
                      fontFamily: 'var(--font-mono)',
                      color: 'var(--text-secondary)',
                      whiteSpace: 'nowrap',
                      overflow: 'hidden',
                      textOverflow: 'ellipsis',
                    }}
                  >
                    {linkItem}
                  </span>
                </div>
                <ArrowUpRight size={14} style={{ color: 'var(--primary)', flexShrink: 0 }} />
              </div>
            ))}
          </div>
        </div>
      )}

      <style>{`
        .scanner-switch-btn:hover {
          background-color: var(--surface) !important;
          border-color: var(--primary) !important;
        }
        .input-btn-hover:hover {
          border-color: var(--text-secondary) !important;
          color: var(--text-primary) !important;
        }
        .chip-hover-effect:hover {
          border-color: rgba(0, 212, 170, 0.3) !important;
          background-color: rgba(0, 212, 170, 0.02) !important;
        }
      `}</style>
    </div>
  );
};

export default ScanUrl;
