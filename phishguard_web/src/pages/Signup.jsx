import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { Mail, Lock, User, ShieldCheck } from 'lucide-react';
import { useAuth } from '../context/AuthContext';
import { PGCard, PGButton } from '../components/PGWidgets';

const Signup = () => {
  const [username, setUsername] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [formError, setFormError] = useState('');

  const { signup } = useAuth();
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!username.trim() || !email.trim() || !password) {
      setFormError('All fields are required.');
      return;
    }
    if (password.length < 6) {
      setFormError('Password must be at least 6 characters.');
      return;
    }

    setLoading(true);
    setFormError('');

    try {
      await signup(username.trim(), email.trim(), password);
      navigate('/dashboard');
    } catch (err) {
      setFormError(err.message || 'Sign up failed. Please check inputs.');
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
            Create Your Security Account
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
            <label>Username</label>
            <div className="pg-input-container">
              <User size={18} style={{ color: 'var(--text-hint)' }} />
              <input
                type="text"
                placeholder="Choose a username"
                value={username}
                onChange={(e) => setUsername(e.target.value)}
                required
              />
            </div>
          </div>

          <div className="pg-input-wrapper">
            <label>Email Address</label>
            <div className="pg-input-container">
              <Mail size={18} style={{ color: 'var(--text-hint)' }} />
              <input
                type="email"
                placeholder="Enter your email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
              />
            </div>
          </div>

          <div className="pg-input-wrapper" style={{ marginBottom: '24px' }}>
            <label>Password</label>
            <div className="pg-input-container">
              <Lock size={18} style={{ color: 'var(--text-hint)' }} />
              <input
                type="password"
                placeholder="Create secure password (min 6 chars)"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
              />
            </div>
          </div>

          <PGButton
            type="submit"
            label="Create Account"
            isLoading={loading}
            icon={<ShieldCheck size={16} />}
          />
        </form>

        <div style={{ textAlign: 'center', marginTop: '28px', fontSize: '13px', color: 'var(--text-secondary)' }}>
          Already have an account?{' '}
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

export default Signup;
