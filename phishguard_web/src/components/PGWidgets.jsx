import React from 'react';
import { AlertTriangle, ShieldCheck, ShieldAlert, Info } from 'lucide-react';

export const PGCard = ({ children, className = '', interactive = false, onClick, style }) => {
  return (
    <div
      className={`pg-card ${interactive ? 'interactive' : ''} ${className}`}
      onClick={onClick}
      style={style}
    >
      {children}
    </div>
  );
};

export const PGButton = ({
  label,
  onClick,
  type = 'button',
  variant = 'primary',
  isLoading = false,
  disabled = false,
  icon,
  className = '',
}) => {
  return (
    <button
      type={type}
      onClick={onClick}
      disabled={disabled || isLoading}
      className={`pg-btn pg-btn-${variant} ${className}`}
      style={{ width: '100%' }}
    >
      {isLoading ? (
        <span
          style={{
            width: '18px',
            height: '18px',
            border: '2px solid currentColor',
            borderTopColor: 'transparent',
            borderRadius: '50%',
            animation: 'rotateSpinner 0.8s linear infinite',
            display: 'inline-block',
          }}
        />
      ) : (
        <>
          {icon && <span>{icon}</span>}
          <span>{label}</span>
        </>
      )}
    </button>
  );
};

export const SeverityChip = ({ severity }) => {
  const sev = (severity || 'MEDIUM').toUpperCase();
  let chipClass = 'info';
  
  if (sev === 'CRITICAL') chipClass = 'danger';
  else if (sev === 'HIGH') chipClass = 'warning';
  else if (sev === 'MEDIUM') chipClass = 'warning';
  else if (sev === 'LOW') chipClass = 'info';

  return (
    <span className={`chip ${chipClass}`} style={{ fontSize: '10px' }}>
      {sev}
    </span>
  );
};

export const StatusChip = ({ status }) => {
  const st = (status || 'SAFE').toUpperCase();
  let chipClass = 'safe';
  
  if (st === 'DANGEROUS') chipClass = 'danger';
  else if (st === 'SUSPICIOUS') chipClass = 'warning';

  return (
    <span className={`chip ${chipClass}`}>
      {st}
    </span>
  );
};

export const PGEmptyState = ({ title, subtitle, icon, onAction, actionLabel }) => {
  return (
    <div
      style={{
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        padding: '40px 20px',
        textAlign: 'center',
        color: 'var(--text-secondary)',
      }}
    >
      <div
        style={{
          color: 'var(--primary)',
          marginBottom: '16px',
          opacity: 0.8,
        }}
      >
        {icon || <Info size={40} />}
      </div>
      <h3 style={{ fontSize: '18px', marginBottom: '8px', color: 'var(--text-primary)' }}>
        {title}
      </h3>
      <p style={{ fontSize: '14px', maxWidth: '320px', marginBottom: '24px' }}>
        {subtitle}
      </p>
      {onAction && (
        <PGButton
          label={actionLabel || 'Retry'}
          onClick={onAction}
          variant="secondary"
          style={{ width: 'auto' }}
          className="w-auto"
        />
      )}
    </div>
  );
};
