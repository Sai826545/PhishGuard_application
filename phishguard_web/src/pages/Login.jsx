import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { Mail, Lock, Shield } from 'lucide-react';
import { useAuth } from '../context/AuthContext';
import { PGCard, PGButton } from '../components/PGWidgets';

const Login = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [formError, setFormError] = useState('');

  const { login } = useAuth();
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!email.trim() || !password) {
      setFormError('Please enter both email and password.');
      return;
    }
    
    setLoading(true);
    setFormError('');

    try {
      await login(email.trim(), password);
      navigate('/dashboard');
    } catch (err) {
      setFormError(err.message || 'Login failed. Please verify credentials.');
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
          <h2 style={{ fontSize: '28px', fontWeight: '800', color: 'var(--primary)' }}>
            🛡️ PhishGuard
          </h2>
          <p style={{ fontSize: '13px', color: 'var(--text-secondary)', marginTop: '4px' }}>
            Protecting You From Scams
          </p>
        </div>

        {formError && (
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
            {formError}
          </div>
        )}

        <form onSubmit={handleSubmit}>
          <div className="pg-input-wrapper">
            <label>Email Address</label>
            <div className="pg-input-container">
              <Mail size={18} style={{ color: 'var(--text-hint)' }} />
              <input
                type="email"
                placeholder="Enter your email address"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
              />
            </div>
          </div>

          <div className="pg-input-wrapper" style={{ marginBottom: '10px' }}>
            <label>Password</label>
            <div className="pg-input-container">
              <Lock size={18} style={{ color: 'var(--text-hint)' }} />
              <input
                type="password"
                placeholder="Enter password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
              />
            </div>
          </div>

          <div style={{ textAlign: 'right', marginBottom: '24px' }}>
            <Link
              to="/forgot-password"
              style={{
                fontSize: '13px',
                color: 'var(--text-secondary)',
                fontWeight: '500',
              }}
              className="text-hover-primary"
            >
              Forgot Password?
            </Link>
          </div>

          <PGButton
            type="submit"
            label="Login"
            isLoading={loading}
            icon={<Shield size={16} />}
          />
        </form>

        <div style={{ textAlign: 'center', marginTop: '28px', fontSize: '13px', color: 'var(--text-secondary)' }}>
          Don't have an account?{' '}
          <Link
            to="/signup"
            style={{
              color: 'var(--primary)',
              fontWeight: '600',
            }}
          >
            Sign Up
          </Link>
        </div>
      </PGCard>
    </div>
  );
};

export default Login;
