import React, { useState } from 'react';
import { ShieldAlert, Upload, Send, Trash2, Camera, AlertCircle } from 'lucide-react';
import api from '../services/api';
import { PGCard, PGButton } from '../components/PGWidgets';

const ReportScam = () => {
  const [category, setCategory] = useState('OTHER');
  const [content, setContent] = useState('');
  const [phoneNumber, setPhoneNumber] = useState('');
  const [description, setDescription] = useState('');
  const [file, setFile] = useState(null);
  const [filePreview, setFilePreview] = useState(null);
  const [uploadingFile, setUploadingFile] = useState(false);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');

  const categories = [
    { value: 'BANK_SCAM', label: '💳 Banking Phishing Portal' },
    { value: 'UPI_SCAM', label: '💸 UPI Cashback / QR Fraud' },
    { value: 'COURIER_SCAM', label: '📦 Fake Courier/Delivery fees' },
    { value: 'GOVT_SCAM', label: '🏛️ Impersonation of Government portal' },
    { value: 'SMS_SCAM', label: '💬 Phishing SMS Text message' },
    { value: 'EMAIL_SCAM', label: '📧 Malicious Impersonating Email' },
    { value: 'OTHER', label: '⚠️ Other Fraud / Security Threat' },
  ];

  const handleFileChange = (e) => {
    const selectedFile = e.target.files[0];
    if (selectedFile) {
      if (selectedFile.size > 5 * 1024 * 1024) {
        setError('File size must not exceed 5MB.');
        return;
      }
      setFile(selectedFile);
      setFilePreview(URL.createObjectURL(selectedFile));
      setError('');
    }
  };

  const handleRemoveFile = () => {
    setFile(null);
    setFilePreview(null);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!description.trim()) {
      setError('Please add a brief description of the scam.');
      return;
    }

    setSubmitting(true);
    setError('');
    setSuccess('');

    try {
      let screenshotUrl = '';

      // 1. Upload screenshot if selected
      if (file) {
        setUploadingFile(true);
        const formData = new FormData();
        formData.append('file', file);

        const uploadResponse = await api.post('/report/upload', formData, {
          headers: { 'Content-Type': 'multipart/form-data' },
        });
        screenshotUrl = uploadResponse.data.data.url;
        setUploadingFile(false);
      }

      // 2. Submit scam report JSON payload
      const reportPayload = {
        category,
        content: content.trim() || 'N/A',
        phoneNumber: phoneNumber.trim() || 'N/A',
        description: description.trim(),
        screenshotUrl,
      };

      await api.post('/report', reportPayload);
      setSuccess('Your scam report has been submitted. Thank you for protecting the community!');
      
      // Reset form
      setCategory('OTHER');
      setContent('');
      setPhoneNumber('');
      setDescription('');
      setFile(null);
      setFilePreview(null);
    } catch (err) {
      setError(err.response?.data?.message || 'Failed to submit report. Please try again.');
    } finally {
      setSubmitting(false);
      setUploadingFile(false);
    }
  };

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '24px', maxWidth: '720px', margin: '0 auto' }}>
      <div>
        <h2 style={{ fontSize: '24px', fontWeight: '700' }}>Report a Scam</h2>
        <p style={{ fontSize: '13px', color: 'var(--text-secondary)' }}>
          Crowdsource threat intelligence to help protect others from Indian cyber-frauds
        </p>
      </div>

      {error && (
        <div
          style={{
            background: 'var(--danger-bg)',
            color: 'var(--danger)',
            padding: '12px 16px',
            borderRadius: '10px',
            border: '1px solid rgba(255, 76, 76, 0.2)',
            fontSize: '13px',
            display: 'flex',
            alignItems: 'center',
            gap: '8px',
          }}
        >
          <AlertCircle size={16} />
          <span>{error}</span>
        </div>
      )}

      {success && (
        <div
          style={{
            background: 'var(--safe-bg)',
            color: 'var(--safe)',
            padding: '12px 16px',
            borderRadius: '10px',
            border: '1px solid rgba(0, 200, 150, 0.2)',
            fontSize: '13px',
          }}
        >
          {success}
        </div>
      )}

      <PGCard>
        <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '18px' }}>
          {/* Category */}
          <div className="pg-input-wrapper" style={{ margin: 0 }}>
            <label>Scam Category</label>
            <div className="pg-input-container">
              <ShieldAlert size={18} style={{ color: 'var(--text-hint)' }} />
              <select
                value={category}
                onChange={(e) => setCategory(e.target.value)}
                style={{
                  background: 'transparent',
                  border: 'none',
                  outline: 'none',
                  color: 'var(--text-primary)',
                  fontSize: '14px',
                  width: '100%',
                  cursor: 'pointer',
                }}
              >
                {categories.map((cat) => (
                  <option key={cat.value} value={cat.value} style={{ background: 'var(--card)', color: 'var(--text-primary)' }}>
                    {cat.label}
                  </option>
                ))}
              </select>
            </div>
          </div>

          {/* Scam content link */}
          <div className="pg-input-wrapper" style={{ margin: 0 }}>
            <label>Scam Content / URL (Optional)</label>
            <div className="pg-input-container">
              <input
                type="text"
                placeholder="Paste the phishing link or QR text if available..."
                value={content}
                onChange={(e) => setContent(e.target.value)}
              />
            </div>
          </div>

          {/* Phone number */}
          <div className="pg-input-wrapper" style={{ margin: 0 }}>
            <label>Scammer Phone Number (Optional)</label>
            <div className="pg-input-container">
              <input
                type="text"
                placeholder="Enter scam SMS sender or calling number if applicable..."
                value={phoneNumber}
                onChange={(e) => setPhoneNumber(e.target.value)}
              />
            </div>
          </div>

          {/* Description */}
          <div className="pg-input-wrapper" style={{ margin: 0 }}>
            <label>Description of the Scam</label>
            <div className="pg-input-container textarea">
              <textarea
                placeholder="Describe how the scam operates, what brand they impersonated, and what details they asked for..."
                value={description}
                onChange={(e) => setDescription(e.target.value)}
                required
              />
            </div>
          </div>

          {/* File Screenshot picker */}
          <div className="pg-input-wrapper" style={{ margin: 0 }}>
            <label>Upload Screenshot (Optional)</label>
            {!filePreview ? (
              <label
                style={{
                  border: '2px dashed var(--border)',
                  borderRadius: '12px',
                  padding: '24px',
                  display: 'flex',
                  flexDirection: 'column',
                  alignItems: 'center',
                  gap: '8px',
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
                <Upload size={24} style={{ color: 'var(--text-secondary)' }} />
                <span style={{ fontSize: '13px', fontWeight: '500', color: 'var(--text-primary)' }}>
                  Attach Screenshot
                </span>
                <span style={{ fontSize: '11px', color: 'var(--text-hint)' }}>
                  PNG, JPG or JPEG up to 5MB
                </span>
              </label>
            ) : (
              <div
                style={{
                  position: 'relative',
                  border: '1px solid var(--border)',
                  borderRadius: '12px',
                  padding: '16px',
                  display: 'flex',
                  alignItems: 'center',
                  gap: '16px',
                  backgroundColor: 'var(--surface)',
                }}
              >
                <img
                  src={filePreview}
                  alt="Screenshot preview"
                  style={{
                    width: '60px',
                    height: '60px',
                    objectFit: 'cover',
                    borderRadius: '8px',
                    border: '1px solid var(--border)',
                  }}
                />
                <div style={{ flex: 1, minWidth: 0 }}>
                  <h4 style={{ fontSize: '13px', fontWeight: '600', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
                    {file.name}
                  </h4>
                  <p style={{ fontSize: '11px', color: 'var(--text-secondary)' }}>
                    {(file.size / 1024).toFixed(1)} KB
                  </p>
                </div>
                <button
                  type="button"
                  onClick={handleRemoveFile}
                  style={{
                    background: 'transparent',
                    border: 'none',
                    color: 'var(--text-secondary)',
                    cursor: 'pointer',
                    padding: '8px',
                  }}
                  className="trash-btn-hover"
                >
                  <Trash2 size={16} />
                </button>
              </div>
            )}
          </div>

          <PGButton
            type="submit"
            label={submitting ? (uploadingFile ? 'Uploading screenshot...' : 'Submitting report...') : 'Submit Scam Report'}
            isLoading={submitting}
            icon={<Send size={16} />}
          />
        </form>
      </PGCard>
      <style>{`
        .upload-dropzone:hover {
          border-color: var(--primary) !important;
        }
      `}</style>
    </div>
  );
};

export default ReportScam;
