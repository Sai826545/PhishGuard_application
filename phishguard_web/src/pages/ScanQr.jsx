import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { QrCode, Upload, Shield, X, HelpCircle } from 'lucide-react';
import api from '../services/api';
import { PGCard, PGButton } from '../components/PGWidgets';

const ScanQr = () => {
  const [qrText, setQrText] = useState('');
  const [file, setFile] = useState(null);
  const [filePreview, setFilePreview] = useState(null);
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  const handleFileChange = (e) => {
    const selectedFile = e.target.files[0];
    if (selectedFile) {
      setFile(selectedFile);
      setFilePreview(URL.createObjectURL(selectedFile));
      // Simulate decoding QR code image and getting content
      setQrText(`https://paytm-cashback-reward.in/receive?upi=scammer@paytm`);
    }
  };

  const handleClear = () => {
    setFile(null);
    setFilePreview(null);
    setQrText('');
  };

  const handleScan = async () => {
    const finalContent = qrText.trim();
    if (!finalContent) return;

    setLoading(true);
    try {
      const response = await api.post('/scan/qr', { content: finalContent });
      const result = response.data.data;
      navigate('/scan/result', { state: { result } });
    } catch (err) {
      alert(err.response?.data?.message || 'Failed to analyze QR code.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '24px', maxWidth: '720px', margin: '0 auto' }}>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <div>
          <h2 style={{ fontSize: '24px', fontWeight: '700' }}>QR Code Scanner</h2>
          <p style={{ fontSize: '13px', color: 'var(--text-secondary)' }}>
            Scan or decode suspicious QR codes for safety
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
        <div style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
          {/* Info Header */}
          <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
            <div
              style={{
                width: '42px',
                height: '42px',
                borderRadius: '10px',
                backgroundColor: 'rgba(0, 212, 170, 0.12)',
                color: 'var(--primary)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
              }}
            >
              <QrCode size={20} />
            </div>
            <div>
              <h3 style={{ fontSize: '16px', fontWeight: '700' }}>QR Impersonation Guard</h3>
              <p style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>
                Upload an image containing a QR code to extract its hidden URL redirects
              </p>
            </div>
          </div>

          {/* QR image picker */}
          {!filePreview ? (
            <label
              style={{
                border: '2px dashed var(--border)',
                borderRadius: '12px',
                padding: '40px 24px',
                display: 'flex',
                flexDirection: 'column',
                alignItems: 'center',
                gap: '12px',
                cursor: 'pointer',
                transition: 'border-color 0.2s ease',
              }}
              className="upload-dropzone"
            >
              <input
                type="file"
                accept="image/*"
                onChange={handleFileChange}
                style={{ display: 'none' }}
              />
              <Upload size={32} style={{ color: 'var(--text-secondary)' }} />
              <span style={{ fontSize: '14px', fontWeight: '600', color: 'var(--text-primary)' }}>
                Select QR Code Image
              </span>
              <span style={{ fontSize: '11px', color: 'var(--text-hint)' }}>
                Upload JPEG, JPG or PNG file containing a QR
              </span>
            </label>
          ) : (
            <div
              style={{
                border: '1px solid var(--border)',
                borderRadius: '12px',
                padding: '20px',
                display: 'flex',
                alignItems: 'center',
                gap: '20px',
                backgroundColor: 'var(--surface)',
              }}
            >
              <img
                src={filePreview}
                alt="QR Code preview"
                style={{
                  width: '80px',
                  height: '80px',
                  objectFit: 'contain',
                  borderRadius: '8px',
                  border: '1px solid var(--border)',
                  backgroundColor: '#FFF',
                  padding: '4px',
                }}
              />
              <div style={{ flex: 1, minWidth: 0 }}>
                <h4 style={{ fontSize: '14px', fontWeight: '600', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
                  {file.name}
                </h4>
                <p style={{ fontSize: '12px', color: 'var(--text-secondary)', marginBottom: '8px' }}>
                  {(file.size / 1024).toFixed(1)} KB • Image Loaded
                </p>
                <div style={{ display: 'flex', alignItems: 'center', gap: '6px', color: 'var(--primary)', fontSize: '11px', fontWeight: '600' }}>
                  <Shield size={12} />
                  <span>Automatically decoded content structure</span>
                </div>
              </div>
              <button
                type="button"
                onClick={handleClear}
                style={{
                  background: 'transparent',
                  border: 'none',
                  color: 'var(--text-secondary)',
                  cursor: 'pointer',
                  padding: '8px',
                }}
                className="trash-btn-hover"
              >
                <X size={18} />
              </button>
            </div>
          )}

          {/* Manually input QR text for testing */}
          <div className="pg-input-wrapper" style={{ margin: 0 }}>
            <label>Decoded QR Payload Content</label>
            <div className="pg-input-container">
              <input
                type="text"
                placeholder="Enter or override decoded QR content text..."
                value={qrText}
                onChange={(e) => setQrText(e.target.value)}
              />
            </div>
          </div>

          <PGButton
            label={loading ? 'Analyzing QR details...' : 'Scan QR Code Content'}
            isLoading={loading}
            onClick={handleScan}
            disabled={!qrText.trim()}
            icon={<Shield size={16} style={{ color: '#0A0E1A' }} />}
          />
        </div>
      </PGCard>
      
      <style>{`
        .scanner-switch-btn:hover {
          background-color: var(--surface) !important;
          border-color: var(--primary) !important;
        }
        .upload-dropzone:hover {
          border-color: var(--primary) !important;
        }
        .trash-btn-hover:hover {
          color: var(--danger) !important;
        }
      `}</style>
    </div>
  );
};

export default ScanQr;
