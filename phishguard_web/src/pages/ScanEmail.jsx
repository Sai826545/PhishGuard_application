import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Mail, Shield, X, Clipboard } from 'lucide-react';
import api from '../services/api';
import { PGCard, PGButton } from '../components/PGWidgets';

const ScanEmail = () => {
  const [content, setContent] = useState('');
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  const handlePaste = async () => {
    try {
      const text = await navigator.clipboard.readText();
      if (text) setContent(text);
    } catch (_) {
      alert('Failed to read from clipboard.');
    }
  };

  const handleScan = async () => {
    const finalContent = content.trim();
    if (!finalContent) return;

    setLoading(true);
    try {
      const response = await api.post('/scan/email', { content: finalContent });
      const result = response.data.data;
      navigate('/scan/result', { state: { result } });
    } catch (err) {
      alert(err.response?.data?.message || 'Failed to analyze email content.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '24px', maxWidth: '720px', margin: '0 auto' }}>
      <div style={{ display: 'flex', alignItems: 'center', justifyBetween: 'space-between' }}>
        <div>
          <h2 style={{ fontSize: '24px', fontWeight: '700' }}>Email Scanner</h2>
          <p style={{ fontSize: '13px', color: 'var(--text-secondary)' }}>
            Analyze suspect emails, fake sender headers, and bank phishing templates
          </p>
        </div>
        <button
          onClick={() => navigate('/scan/url')}
          style={{
            background: 'var(--card)',
            border: '1px solid var(--border)',
            borderRadius: '10px',
            padding: '8px 16px',
            fontSize: '13px',
            color: 'var(--primary)',
            fontWeight: '600',
            cursor: 'pointer',
            transition: 'all 0.2s ease',
          }}
          className="scanner-switch-btn"
        >
          URL Scanner
        </button>
      </div>

      <PGCard>
        <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
          {/* Header */}
          <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
            <div
              style={{
                width: '42px',
                height: '42px',
                borderRadius: '10px',
                backgroundColor: 'rgba(76, 154, 255, 0.12)',
                color: 'var(--info)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
              }}
            >
              <Mail size={20} />
            </div>
            <div>
              <h3 style={{ fontSize: '16px', fontWeight: '700' }}>Email Impersonation Filter</h3>
              <p style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>
                Inspect header keywords, detect cloned templates, and uncover fake brand requests
              </p>
            </div>
          </div>

          {/* Textarea */}
          <div
            style={{
              background: 'var(--surface)',
              border: '1px solid rgba(76, 154, 255, 0.3)',
              borderRadius: '12px',
              padding: '16px',
              display: 'flex',
              flexDirection: 'column',
              gap: '12px',
            }}
          >
            <textarea
              placeholder="Paste email sender info, headers, or the full message content here..."
              value={content}
              onChange={(e) => setContent(e.target.value)}
              style={{
                background: 'transparent',
                border: 'none',
                outline: 'none',
                color: 'var(--text-primary)',
                fontSize: '13px',
                resize: 'none',
                minHeight: '150px',
                width: '100%',
                lineHeight: '1.6',
              }}
            />

            {/* Input actions */}
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
                onClick={() => setContent('')}
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

          <PGButton
            label={loading ? 'Scanning message details...' : 'Scan Email Content'}
            isLoading={loading}
            onClick={handleScan}
            disabled={!content.trim()}
            icon={<Shield size={16} style={{ color: '#0A0E1A' }} />}
            style={{ background: 'linear-gradient(135deg, var(--info), var(--primary))' }}
          />
        </div>
      </PGCard>
      
      <style>{`
        .scanner-switch-btn:hover {
          background-color: var(--surface) !important;
          border-color: var(--primary) !important;
        }
        .input-btn-hover:hover {
          border-color: var(--text-secondary) !important;
          color: var(--text-primary) !important;
        }
      `}</style>
    </div>
  );
};

export default ScanEmail;
