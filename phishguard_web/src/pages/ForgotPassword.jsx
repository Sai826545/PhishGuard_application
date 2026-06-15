import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { Mail, Lock, ShieldCheck, Key } from 'lucide-react';
import { useAuth } from '../context/AuthContext';
import { PGCard, PGButton } from '../components/PGWidgets';

const ForgotPassword = () => {
  const [step, setStep] = useState(1); // 1: Email Request, 2: Verification & Reset
  const [email, setEmail] = useState('');
  const [otp, setOtp] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [errorMsg, setErrorMsg] = useState('');
  const [successMsg, setSuccessMsg] = useState('');

  const { forgotPassword, resetPassword } = useAuth();
  const navigate = useNavigate();

  const handleRequestOtp = async (e) => {
    e.preventDefault();
    if (!email.trim()) {
      setErrorMsg('Please enter your email address.');
      return;
    }

    setLoading(true);
    setErrorMsg('');
    setSuccessMsg('');

    try {
      await forgotPassword(email.trim());
      setSuccessMsg('A 6-digit verification code has been printed to the server console log.');
      setStep(2);
    } catch (err) {
      setErrorMsg(err.message || 'Failed to send verification code.');
    } finally {
      setLoading(false);
    }
  };

  const handleResetPassword = async (e) => {
    e.preventDefault();
    if (!otp.trim() || !newPassword || !confirmPassword) {
      setErrorMsg('All fields are required.');
      return;
    }
    if (newPassword !== confirmPassword) {
      setErrorMsg('Passwords do not match.');
      return;
    }
    if (newPassword.length < 6) {
      setErrorMsg('Password must be at least 6 characters.');
      return;
    }

    setLoading(true);
    setErrorMsg('');

    try {
      await resetPassword(email.trim(), otp.trim(), newPassword);
      setSuccessMsg('Password has been reset successfully. Redirecting to Login...');
      setTimeout(() => {
        navigate('/login');
      }, 2000);
    } catch (err) {
      setErrorMsg(err.message || 'Verification failed. Please check the code.');
    } finally {
      setLoading(false);
    }
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
          maxWidth: '420px',
          width: '100%',
          padding: '40px 30px',
          animation: 'slideUp 0.4s cubic-bezier(0.16, 1, 0.3, 1) forwards',
        }}
      >
        <div style={{ textAlign: 'center', marginBottom: '32px' }}>
          <h2 style={{ fontSize: '26px', fontWeight: '800', color: 'var(--primary)' }}>
            🔑 Password Recovery
          </h2>
          <p style={{ fontSize: '13px', color: 'var(--text-secondary)', marginTop: '4px' }}>
            {step === 1 ? 'Enter email to receive OTP code' : 'Verify OTP and set new password'}
          </p>
        </div>

        {errorMsg && (
          <div
            style={{
              background: 'var(--danger-bg)',
              color: 'var(--danger)',
              padding: '12px 16px',
              borderRadius: '10px',
              border: '1px solid rgba(255, 76, 76, 0.2)',
              fontSize: '13px',
              marginBottom: '20px',
            }}
          >
            {errorMsg}
          </div>
        )}

        {successMsg && (
          <div
            style={{
              background: 'var(--safe-bg)',
              color: 'var(--safe)',
              padding: '12px 16px',
              borderRadius: '10px',
              border: '1px solid rgba(0, 200, 150, 0.2)',
              fontSize: '13px',
              marginBottom: '20px',
            }}
          >
            {successMsg}
          </div>
        )}

        {step === 1 ? (
          <form onSubmit={handleRequestOtp}>
            <div className="pg-input-wrapper" style={{ marginBottom: '24px' }}>
              <label>Email Address</label>
              <div className="pg-input-container">
                <Mail size={18} style={{ color: 'var(--text-hint)' }} />
                <input
                  type="email"
                  placeholder="Enter registered email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  required
                />
              </div>
            </div>

            <PGButton
              type="submit"
              label="Request OTP Code"
              isLoading={loading}
              icon={<ShieldCheck size={16} />}
            />
          </form>
        ) : (
          <form onSubmit={handleResetPassword}>
            <div className="pg-input-wrapper">
              <label>6-Digit verification Code</label>
              <div className="pg-input-container">
                <Key size={18} style={{ color: 'var(--text-hint)' }} />
                <input
                  type="text"
                  placeholder="Enter OTP code"
                  value={otp}
                  onChange={(e) => setOtp(e.target.value)}
                  required
                />
              </div>
            </div>

            <div className="pg-input-wrapper">
              <label>New Password</label>
              <div className="pg-input-container">
                <Lock size={18} style={{ color: 'var(--text-hint)' }} />
                <input
                  type="password"
                  placeholder="Enter new password"
                  value={newPassword}
                  onChange={(e) => setNewPassword(e.target.value)}
                  required
                />
              </div>
            </div>

            <div className="pg-input-wrapper" style={{ marginBottom: '24px' }}>
              <label>Confirm Password</label>
              <div className="pg-input-container">
                <Lock size={18} style={{ color: 'var(--text-hint)' }} />
                <input
                  type="password"
                  placeholder="Confirm new password"
                  value={confirmPassword}
                  onChange={(e) => setConfirmPassword(e.target.value)}
                  required
                />
              </div>
            </div>

            <PGButton
              type="submit"
              label="Reset Password"
              isLoading={loading}
            />
          </form>
        )}

        <div style={{ textAlign: 'center', marginTop: '28px', fontSize: '13px', color: 'var(--text-secondary)' }}>
          Remember your password?{' '}
          <Link
            to="/login"
            style={{
              color: 'var(--primary)',
              fontWeight: '600',
            }}
          >
            Sign In
          </Link>
        </div>
      </PGCard>
    </div>
  );
};

export default ForgotPassword;
