import React from 'react';
import { useLocation, useNavigate } from 'react-router-dom';
import {
  ShieldCheck,
  ShieldAlert,
  AlertTriangle,
  Link as LinkIcon,
  Globe,
  Lock,
  ArrowRightLeft,
  Calendar,
  AlertCircle,
  Clock,
  ExternalLink,
  Copy,
  RefreshCw,
  History,
} from 'lucide-react';
import { PGCard, PGButton, StatusChip } from '../components/PGWidgets';

const ScanResult = () => {
  const location = useLocation();
  const navigate = useNavigate();

  // Retrieve result from Router state
  const result = location.state?.result;

  if (!result) {
    return (
      <div style={{ padding: '40px', textAlign: 'center' }}>
        <h3 style={{ fontSize: '18px', marginBottom: '8px' }}>No Scan Result</h3>
        <p style={{ fontSize: '14px', color: 'var(--text-secondary)', marginBottom: '20px' }}>
          No threat metrics are currently loaded for view.
        </p>
        <PGButton label="Go to Scanner" onClick={() => navigate('/scan/url')} className="w-auto" style={{ width: 'auto' }} />
      </div>
    );
  }

  const isSafe = result.resultStatus === 'SAFE';
  const isSuspicious = result.resultStatus === 'SUSPICIOUS';
  const statusColor = isSafe ? 'var(--safe)' : isSuspicious ? 'var(--warning)' : 'var(--danger)';
  const statusBg = isSafe ? 'var(--safe-bg)' : isSuspicious ? 'var(--warning-bg)' : 'var(--danger-bg)';

  const handleCopyResult = () => {
    const text = `PhishGuard Scan Result: ${result.resultStatus}\n` +
      `Risk Score: ${result.riskScore}/100\n` +
      `Scanned Content: ${result.scannedContent}\n` +
      `Details:\n` +
      `- SSL Certificate: ${result.sslStatus ? 'Valid HTTPS' : 'Missing/HTTP'}\n` +
      `- Domain Age: ${result.domainAgeDays >= 0 ? `${result.domainAgeDays} days` : 'N/A'}\n` +
      `- Redirects: ${result.redirectCount}\n` +
      `- Blacklist Status: ${result.blacklisted ? 'Listed' : 'Clean'}\n` +
      `Why: \n${(result.aiReasons || []).join('\n')}`;

    navigator.clipboard.writeText(text);
    alert('Scan results copied to clipboard.');
  };

  const handleOpenLink = () => {
    if (isSafe) {
      window.open(result.scannedContent, '_blank', 'noopener,noreferrer');
    } else {
      alert('⚠️ Security Block: This link is flagged as malicious. For your protection, redirecting is blocked.');
    }
  };

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '24px', maxWidth: '720px', margin: '0 auto' }}>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <div>
          <h2 style={{ fontSize: '24px', fontWeight: '700' }}>Scan Report</h2>
          <p style={{ fontSize: '13px', color: 'var(--text-secondary)' }}>
            Audit report for safety indicators and visual clones
          </p>
        </div>
        <button
          onClick={handleCopyResult}
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
          className="copy-btn-hover"
        >
          <Copy size={14} />
          <span>Share Audit</span>
        </button>
      </div>

      {/* Hero Status Card */}
      <div
        style={{
          background: statusBg,
          border: `1px solid ${statusColor}4D`,
          borderRadius: '16px',
          padding: '40px 24px',
          textAlign: 'center',
          boxShadow: `0 8px 32px rgba(0, 0, 0, 0.2)`,
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          animation: 'slideUp 0.3s ease-out',
        }}
      >
        <div
          style={{
            width: '80px',
            height: '80px',
            borderRadius: '50%',
            backgroundColor: `${statusColor}26`,
            color: statusColor,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            marginBottom: '20px',
          }}
        >
          {isSafe ? <ShieldCheck size={44} /> : isSuspicious ? <AlertTriangle size={44} /> : <ShieldAlert size={44} />}
        </div>

        <StatusChip status={result.resultStatus} />

        <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'center', margin: '20px 0 6px' }}>
          <span style={{ fontSize: '56px', fontWeight: '800', color: statusColor, lineHeight: 1 }}>
            {result.riskScore}
          </span>
          <span style={{ fontSize: '20px', fontWeight: '600', color: `${statusColor}99` }}>
            /100
          </span>
        </div>

        <p style={{ fontSize: '11px', color: 'var(--text-secondary)', fontWeight: '600', textTransform: 'uppercase', letterSpacing: '0.08em', marginBottom: '20px' }}>
          Threat Risk Level
        </p>

        {/* Custom Progress Bar */}
        <div style={{ width: '100%', maxWidth: '280px', height: '6px', background: 'var(--border)', borderRadius: '4px', overflow: 'hidden' }}>
          <div
            style={{
              height: '100%',
              width: `${result.riskScore}%`,
              background: statusColor,
              borderRadius: '4px',
            }}
          />
        </div>
      </div>

      {/* Scanned Content Details */}
      <PGCard>
        <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '14px' }}>
          <LinkIcon size={16} style={{ color: 'var(--info)' }} />
          <h3 style={{ fontSize: '15px', fontWeight: '700' }}>Analyzed Content Payload</h3>
        </div>
        <div style={{ height: '1px', background: 'var(--border)', marginBottom: '14px' }} />
        
        <p
          style={{
            fontFamily: 'var(--font-mono)',
            fontSize: '12px',
            color: 'var(--text-secondary)',
            wordBreak: 'break-all',
            lineHeight: '1.6',
            backgroundColor: 'var(--surface)',
            padding: '12px',
            borderRadius: '8px',
            border: '1px solid var(--border)',
          }}
        >
          {result.scannedContent}
        </p>

        {result.scannedContent && result.scannedContent.startsWith('http') && (
          <PGButton
            label={isSafe ? 'Visit Website' : 'Blocked (Malicious link)'}
            disabled={!isSafe}
            onClick={handleOpenLink}
            icon={<ExternalLink size={14} />}
            style={{ width: 'auto', marginTop: '16px' }}
            className={`w-auto ${!isSafe ? 'btn-danger-block' : ''}`}
          />
        )}
      </PGCard>

      {/* Domain Auditing Parameters Checklist */}
      <PGCard>
        <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '14px' }}>
          <Globe size={16} style={{ color: 'var(--accent)' }} />
          <h3 style={{ fontSize: '15px', fontWeight: '700' }}>Security Checks Summary</h3>
        </div>
        <div style={{ height: '1px', background: 'var(--border)', marginBottom: '14px' }} />

        <div style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
          {/* Domain name */}
          <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '13px' }}>
            <span style={{ color: 'var(--text-secondary)' }}>Domain Checked</span>
            <span style={{ fontWeight: '600', fontFamily: 'var(--font-mono)' }}>{result.domainName || 'N/A'}</span>
          </div>

          {/* SSL Status */}
          <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '13px' }}>
            <span style={{ color: 'var(--text-secondary)' }}>SSL Certificate</span>
            <span style={{ fontWeight: '600', color: result.sslStatus ? 'var(--safe)' : 'var(--danger)' }}>
              {result.sslStatus ? 'Valid HTTPS Secure' : 'Insecure Connection (No SSL)'}
            </span>
          </div>

          {/* Redirect Count */}
          <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '13px' }}>
            <span style={{ color: 'var(--text-secondary)' }}>Redirect Chains</span>
            <span style={{ fontWeight: '600', color: result.redirectCount > 2 ? 'var(--warning)' : 'var(--text-primary)' }}>
              {result.redirectCount} hops
            </span>
          </div>

          {/* Domain age */}
          <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '13px' }}>
            <span style={{ color: 'var(--text-secondary)' }}>Domain Age Registration</span>
            <span style={{ fontWeight: '600', color: (result.domainAgeDays >= 0 && result.domainAgeDays < 30) ? 'var(--warning)' : 'var(--text-primary)' }}>
              {result.domainAgeDays < 0
                ? 'Unknown Registry'
                : result.domainAgeDays < 30
                ? `${result.domainAgeDays} days old (Very New ⚠️)`
                : `${result.domainAgeDays} days active`}
            </span>
          </div>

          {/* Blacklisted */}
          <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '13px' }}>
            <span style={{ color: 'var(--text-secondary)' }}>Blacklist DB Status</span>
            <span style={{ fontWeight: '600', color: result.blacklisted ? 'var(--danger)' : 'var(--safe)' }}>
              {result.blacklisted ? 'Reported Phishing Portal' : 'Not Blacklisted'}
            </span>
          </div>

          {/* Whitelisted */}
          <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '13px' }}>
            <span style={{ color: 'var(--text-secondary)' }}>Trusted Domain list</span>
            <span style={{ fontWeight: '600', color: result.trusted ? 'var(--safe)' : 'var(--text-secondary)' }}>
              {result.trusted ? 'Whitelisted Safe Brand' : 'Not Whitelisted'}
            </span>
          </div>
        </div>
      </PGCard>

      {/* Security Analysis Explanations / Rules matches */}
      {result.aiReasons && result.aiReasons.length > 0 && (
        <PGCard>
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '14px' }}>
            <AlertCircle size={16} style={{ color: 'var(--primary)' }} />
            <h3 style={{ fontSize: '15px', fontWeight: '700' }}>Analysis Details</h3>
          </div>
          <div style={{ height: '1px', background: 'var(--border)', marginBottom: '14px' }} />

          <ul style={{ listStyleType: 'none', display: 'flex', flexDirection: 'column', gap: '10px' }}>
            {result.aiReasons.map((reason, idx) => (
              <li
                key={idx}
                style={{
                  fontSize: '13px',
                  lineHeight: '1.5',
                  color: 'var(--text-primary)',
                  display: 'flex',
                  alignItems: 'flex-start',
                  gap: '8px',
                }}
              >
                <span style={{ color: 'var(--primary)', flexShrink: 0 }}>✓</span>
                <span>{reason}</span>
              </li>
            ))}
          </ul>
        </PGCard>
      )}

      {/* Date */}
      {result.scannedAt && (
        <p style={{ textAlign: 'center', color: 'var(--text-disabled)', fontSize: '11px', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '4px' }}>
          <Clock size={11} />
          Scanned: {new Date(result.scannedAt).toLocaleString()}
        </p>
      )}

      {/* Navigation shortcuts */}
      <div style={{ display: 'flex', gap: '16px', marginTop: '10px' }}>
        <PGButton
          label="Scan Again"
          variant="secondary"
          onClick={() => navigate('/scan/url')}
          icon={<RefreshCw size={16} style={{ color: 'var(--primary)' }} />}
          style={{ flex: 1 }}
        />
        <PGButton
          label="View Logs"
          onClick={() => navigate('/history')}
          icon={<History size={16} />}
          style={{ flex: 1 }}
        />
      </div>

      <style>{`
        .copy-btn-hover:hover {
          border-color: var(--primary) !important;
          background-color: var(--surface) !important;
        }
        .btn-danger-block {
          border-color: var(--danger) !important;
          color: var(--danger) !important;
          cursor: not-allowed !important;
          opacity: 0.5;
        }
      `}</style>
    </div>
  );
};

export default ScanResult;
