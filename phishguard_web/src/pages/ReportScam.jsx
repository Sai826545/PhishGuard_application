import React, { useState, useEffect } from 'react';
import { ShieldAlert, Upload, Send, Trash2, Camera, AlertCircle, Map, RefreshCw } from 'lucide-react';
import api from '../services/api';
import { PGCard, PGButton } from '../components/PGWidgets';

const ReportScam = () => {
  const [activeTab, setActiveTab] = useState('report');
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
  const [city, setCity] = useState('Delhi');

  // Community Feed State
  const [reports, setReports] = useState([]);
  const [loadingReports, setLoadingReports] = useState(false);
  const [reportsError, setReportsError] = useState('');

  const cities = [
    { name: 'Delhi', lat: 28.70, lng: 77.10 },
    { name: 'Mumbai', lat: 19.07, lng: 72.87 },
    { name: 'Jamtara', lat: 24.13, lng: 86.80 },
    { name: 'Bengaluru', lat: 12.97, lng: 77.59 },
    { name: 'Hyderabad', lat: 17.38, lng: 78.48 },
    { name: 'Chennai', lat: 13.08, lng: 80.27 },
    { name: 'Kolkata', lat: 22.57, lng: 88.36 },
    { name: 'Pune', lat: 18.52, lng: 73.85 },
    { name: 'Ahmedabad', lat: 23.02, lng: 72.57 },
  ];

  const categories = [
    { value: 'BANK_SCAM', label: '💳 Banking Phishing Portal' },
    { value: 'UPI_SCAM', label: '💸 UPI Cashback / QR Fraud' },
    { value: 'COURIER_SCAM', label: '📦 Fake Courier/Delivery fees' },
    { value: 'GOVT_SCAM', label: '🏛️ Impersonation of Government portal' },
    { value: 'SMS_SCAM', label: '💬 Phishing SMS Text message' },
    { value: 'EMAIL_SCAM', label: '📧 Malicious Impersonating Email' },
    { value: 'OTHER', label: '⚠️ Other Fraud / Security Threat' },
  ];

  const fetchCommunityReports = async () => {
    setLoadingReports(true);
    setReportsError('');
    try {
      const response = await api.get('/report/community');
      setReports(response.data.data);
    } catch (err) {
      setReportsError('Failed to fetch community scam reports.');
    } finally {
      setLoadingReports(false);
    }
  };

  useEffect(() => {
    if (activeTab === 'community') {
      fetchCommunityReports();
    }
  }, [activeTab]);

  const getCategoryLabel = (catKey) => {
    const cat = categories.find(c => c.value === catKey);
    return cat ? cat.label : '⚠️ Unknown Scam';
  };

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

      const selectedCityObj = cities.find(c => c.name === city) || { lat: null, lng: null };

      const reportPayload = {
        category,
        content: content.trim() || 'N/A',
        phoneNumber: phoneNumber.trim() || 'N/A',
        description: description.trim(),
        screenshotUrl,
        city: city,
        latitude: selectedCityObj.lat,
        longitude: selectedCityObj.lng,
      };

      await api.post('/report', reportPayload);
      setSuccess('Your scam report has been submitted. Thank you for protecting the community!');
      
      // Reset form
      setCategory('OTHER');
      setContent('');
      setPhoneNumber('');
      setDescription('');
      setCity('Delhi');
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
        <h2 style={{ fontSize: '24px', fontWeight: '700' }}>Scam Reporting</h2>
        <p style={{ fontSize: '13px', color: 'var(--text-secondary)' }}>
          Crowdsource threat intelligence to help protect others from regional cyber-frauds
        </p>
      </div>

      {/* Tabs */}
      <div style={{ display: 'flex', borderBottom: '1px solid var(--border)', marginBottom: '8px', gap: '8px' }}>
        <button
          onClick={() => setActiveTab('report')}
          style={{
            padding: '10px 20px',
            border: 'none',
            background: 'none',
            fontSize: '14px',
            fontWeight: '600',
            color: activeTab === 'report' ? 'var(--primary)' : 'var(--text-secondary)',
            borderBottom: activeTab === 'report' ? '2px solid var(--primary)' : '2px solid transparent',
            cursor: 'pointer',
            transition: 'all 0.2s ease',
          }}
        >
          Submit Report
        </button>
        <button
          onClick={() => setActiveTab('community')}
          style={{
            padding: '10px 20px',
            border: 'none',
            background: 'none',
            fontSize: '14px',
            fontWeight: '600',
            color: activeTab === 'community' ? 'var(--primary)' : 'var(--text-secondary)',
            borderBottom: activeTab === 'community' ? '2px solid var(--primary)' : '2px solid transparent',
            cursor: 'pointer',
            transition: 'all 0.2s ease',
          }}
        >
          Community Feed
        </button>
      </div>

      {activeTab === 'report' ? (
        <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
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

              {/* City */}
              <div className="pg-input-wrapper" style={{ margin: 0 }}>
                <label>Scam Location (City)</label>
                <div className="pg-input-container">
                  <Map size={18} style={{ color: 'var(--text-hint)' }} />
                  <select
                    value={city}
                    onChange={(e) => setCity(e.target.value)}
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
                    {cities.map((c) => (
                      <option key={c.name} value={c.name} style={{ background: 'var(--card)', color: 'var(--text-primary)' }}>
                        {c.name}
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
        </div>
      ) : (
        <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <h3 style={{ fontSize: '16px', fontWeight: '600' }}>Recent Community Scam Reports</h3>
            <button
              onClick={fetchCommunityReports}
              style={{
                background: 'none',
                border: 'none',
                color: 'var(--primary)',
                display: 'flex',
                alignItems: 'center',
                gap: '6px',
                fontSize: '13px',
                cursor: 'pointer',
                fontWeight: '600',
              }}
              disabled={loadingReports}
            >
              <RefreshCw size={14} className={loadingReports ? 'animate-spin' : ''} />
              Refresh Feed
            </button>
          </div>

          {reportsError && (
            <div style={{ background: 'var(--danger-bg)', color: 'var(--danger)', padding: '12px 16px', borderRadius: '10px', fontSize: '13px' }}>
              {reportsError}
            </div>
          )}

          {loadingReports ? (
            <div style={{ display: 'flex', justifyContent: 'center', padding: '40px' }}>
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
          ) : reports.length === 0 ? (
            <div style={{ textAlign: 'center', padding: '45px 0', color: 'var(--text-secondary)' }}>
              No community reports found. Start reporting scams to protect others!
            </div>
          ) : (
            <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
              {reports.map((report) => (
                <PGCard key={report.id} style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '8px' }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                      <span style={{ fontSize: '11px', fontWeight: '600', color: 'var(--primary)', background: 'rgba(0, 212, 170, 0.1)', padding: '3px 8px', borderRadius: '12px' }}>
                        👤 By: {report.reportedBy}
                      </span>
                      <span style={{ fontSize: '11px', fontWeight: '600', color: 'var(--accent)', background: 'rgba(0, 150, 255, 0.1)', padding: '3px 8px', borderRadius: '12px' }}>
                        📍 Location: {report.city}
                      </span>
                    </div>
                    <span style={{ fontSize: '11px', color: 'var(--text-hint)' }}>
                      {new Date(report.reportedAt).toLocaleString()}
                    </span>
                  </div>

                  <div>
                    <h4 style={{ fontSize: '13px', fontWeight: '700', color: 'var(--danger)', marginBottom: '6px' }}>
                      {getCategoryLabel(report.category)}
                    </h4>
                    <p style={{ fontSize: '13px', color: 'var(--text-primary)', lineHeight: '1.5', whiteSpace: 'pre-wrap' }}>
                      {report.description}
                    </p>
                  </div>

                  {report.content && report.content !== 'N/A' && (
                    <div style={{ background: 'var(--surface)', padding: '8px 12px', borderRadius: '8px', border: '1px solid var(--border)', fontSize: '12px' }}>
                      <strong>Payload / URL:</strong> <code style={{ color: 'var(--accent)', wordBreak: 'break-all' }}>{report.content}</code>
                    </div>
                  )}

                  {report.screenshotUrl && (
                    <div style={{ marginTop: '4px' }}>
                      <img
                        src={report.screenshotUrl}
                        alt="Evidence"
                        style={{
                          maxWidth: '100%',
                          maxHeight: '180px',
                          borderRadius: '8px',
                          border: '1px solid var(--border)',
                          objectFit: 'contain',
                        }}
                      />
                    </div>
                  )}
                </PGCard>
              ))}
            </div>
          )}
        </div>
      )}

      <style>{`
        .upload-dropzone:hover {
          border-color: var(--primary) !important;
        }
        @keyframes rotateSpinner {
          to { transform: rotate(360deg); }
        }
      `}</style>
    </div>
  );
};

export default ReportScam;
