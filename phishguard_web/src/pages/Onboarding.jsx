import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Shield, QrCode, Globe, ChevronRight } from 'lucide-react';
import { PGCard, PGButton } from '../components/PGWidgets';

const Onboarding = () => {
  const [slide, setSlide] = useState(0);
  const navigate = useNavigate();

  const slides = [
    {
      title: 'Detect Phishing Links',
      desc: 'Instantly scan suspicious URLs, emails, and SMS messages before you click. Our AI engine analyzes threats in real-time.',
      icon: <Shield size={64} style={{ color: 'var(--danger)' }} />,
    },
    {
      title: 'QR Code Scam Protection',
      desc: 'Protect yourself from fake UPI QR codes, payment scams, and malicious redirects hidden inside innocent-looking QR codes.',
      icon: <QrCode size={64} style={{ color: 'var(--primary)' }} />,
    },
    {
      title: 'India-Specific Fraud Guard',
      desc: 'Specialized protection against SBI/HDFC/ICICI fake portals, Aadhaar KYC scams, courier fraud, and government portal impersonation.',
      icon: <Globe size={64} style={{ color: 'var(--accent)' }} />,
    },
  ];

  const handleNext = () => {
    if (slide < slides.length - 1) {
      setSlide((s) => s + 1);
    } else {
      handleComplete();
    }
  };

  const handleComplete = () => {
    localStorage.setItem('hasSeenOnboarding', 'true');
    navigate('/login');
  };

  return (
    <div
      style={{
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        minHeight: '100vh',
        background: 'radial-gradient(circle at center, #111827 0%, #0A0E1A 100%)',
        padding: '20px',
      }}
    >
      <PGCard
        style={{
          maxWidth: '450px',
          width: '100%',
          textAlign: 'center',
          padding: '40px 30px',
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          animation: 'slideUp 0.4s cubic-bezier(0.16, 1, 0.3, 1) forwards',
        }}
      >
        <div style={{ marginBottom: '30px' }}>
          <h2 style={{ fontSize: '26px', fontWeight: '800', color: 'var(--primary)' }}>
            🛡️ PhishGuard
          </h2>
          <p style={{ fontSize: '12px', color: 'var(--text-secondary)', letterSpacing: '0.05em' }}>
            CYBER-SECURITY SHIELD
          </p>
        </div>

        <div style={{ marginBottom: '30px', height: '80px', display: 'flex', alignItems: 'center' }}>
          {slides[slide].icon}
        </div>

        <h3
          style={{
            fontSize: '20px',
            fontFamily: 'var(--font-display)',
            fontWeight: '700',
            marginBottom: '12px',
          }}
        >
          {slides[slide].title}
        </h3>

        <p
          style={{
            fontSize: '14px',
            color: 'var(--text-secondary)',
            marginBottom: '40px',
            minHeight: '84px',
          }}
        >
          {slides[slide].desc}
        </p>

        {/* Slide Indicators */}
        <div style={{ display: 'flex', gap: '8px', marginBottom: '40px' }}>
          {slides.map((_, i) => (
            <div
              key={i}
              style={{
                width: i === slide ? '20px' : '8px',
                height: '8px',
                borderRadius: '99px',
                backgroundColor: i === slide ? 'var(--primary)' : 'var(--border)',
                transition: 'all 0.3s ease',
              }}
            />
          ))}
        </div>

        <div style={{ display: 'flex', width: '100%', gap: '16px' }}>
          <PGButton
            label="Skip"
            onClick={handleComplete}
            variant="secondary"
            style={{ flex: 1 }}
          />
          <PGButton
            label={slide === slides.length - 1 ? 'Get Started' : 'Next'}
            onClick={handleNext}
            icon={slide < slides.length - 1 && <ChevronRight size={16} />}
            style={{ flex: 1 }}
          />
        </div>
      </PGCard>
    </div>
  );
};

export default Onboarding;
