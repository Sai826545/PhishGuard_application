import React, { useState, useEffect } from 'react';
import { ShieldCheck, User, Mail, ShieldAlert, Award, Calendar, BarChart3, Lock } from 'lucide-react';
import api from '../services/api';
import { PGCard, PGEmptyState } from '../components/PGWidgets';

const Profile = () => {
  const [profile, setProfile] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const fetchProfile = async () => {
    setLoading(true);
    setError(null);
    try {
      const response = await api.get('/profile');
      setProfile(response.data.data);
    } catch (err) {
      setError('Failed to fetch user profile details.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchProfile();
  }, []);

  if (loading) {
    return (
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', minHeight: '300px' }}>
        <span
          style={{
            width: '28px',
            height: '28px',
            border: '2px solid var(--primary)',
            borderTopColor: 'transparent',
            borderRadius: '50%',
            animation: 'rotateSpinner 0.8s linear infinite',
          }}
        />
      </div>
    );
  }

  if (error) {
    return (
      <PGEmptyState
        title="Load Error"
        subtitle={error}
        icon={<User size={40} />}
        onAction={fetchProfile}
      />
    );
  }

  const score = profile.securityScore ?? 75;
  const scoreColor = score >= 70 ? 'var(--safe)' : score >= 40 ? 'var(--warning)' : 'var(--danger)';
  const scoreLabel = score >= 70 ? '🟢 Excellent Protection' : score >= 40 ? '🟡 Moderate Risk' : '🔴 High Risk';

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
      <div>
        <h2 style={{ fontSize: '24px', fontWeight: '700' }}>User Profile</h2>
        <p style={{ fontSize: '13px', color: 'var(--text-secondary)' }}>
          Manage your credentials and view your security statistics
        </p>
      </div>

      <div
        style={{
          display: 'grid',
          gridTemplateColumns: '1.2fr 1fr',
          gap: '24px',
        }}
        className="profile-responsive-columns"
      >
        {/* Left Side: Profile Summary & Stats */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
          {/* Main User Card */}
          <PGCard style={{ textAlign: 'center', padding: '36px 24px' }}>
            {/* Avatar */}
            <div
              style={{
                width: '80px',
                height: '80px',
                borderRadius: '50%',
                background: 'linear-gradient(135deg, var(--primary), var(--accent))',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                margin: '0 auto 20px',
                boxShadow: '0 0 20px rgba(0, 212, 170, 0.3)',
              }}
            >
              <span style={{ fontSize: '32px', fontWeight: '800', color: '#0A0E1A' }}>
                {(profile.username || 'U')[0].toUpperCase()}
              </span>
            </div>

            <h3 style={{ fontSize: '22px', fontWeight: '700' }}>{profile.username || 'User'}</h3>
            <p style={{ fontSize: '13px', color: 'var(--text-secondary)', marginBottom: '8px' }}>
              {profile.email}
            </p>
            {profile.joinedDate && (
              <p style={{ fontSize: '11px', color: 'var(--text-disabled)', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '6px' }}>
                <Calendar size={12} />
                Joined: {new Date(profile.joinedDate).toLocaleDateString(undefined, { year: 'numeric', month: 'long' })}
              </p>
            )}

            <div style={{ height: '1px', background: 'var(--border)', margin: '24px 0' }} />

            {/* Stat counts row */}
            <div style={{ display: 'flex', justifyContent: 'space-around' }}>
              <div>
                <BarChart3 size={18} style={{ color: 'var(--info)' }} />
                <h4 style={{ fontSize: '20px', fontWeight: '800', margin: '4px 0 2px', color: 'var(--info)' }}>
                  {profile.totalScans ?? 0}
                </h4>
                <p style={{ fontSize: '11px', color: 'var(--text-secondary)' }}>Scans Run</p>
              </div>
              <div style={{ width: '1px', background: 'var(--border)' }} />
              <div>
                <ShieldAlert size={18} style={{ color: 'var(--danger)' }} />
                <h4 style={{ fontSize: '20px', fontWeight: '800', margin: '4px 0 2px', color: 'var(--danger)' }}>
                  {profile.blockedThreats ?? 0}
                </h4>
                <p style={{ fontSize: '11px', color: 'var(--text-secondary)' }}>Blocked</p>
              </div>
              <div style={{ width: '1px', background: 'var(--border)' }} />
              <div>
                <ShieldCheck size={18} style={{ color: 'var(--safe)' }} />
                <h4 style={{ fontSize: '20px', fontWeight: '800', margin: '4px 0 2px', color: 'var(--safe)' }}>
                  {profile.securityScore ?? 100}%
                </h4>
                <p style={{ fontSize: '11px', color: 'var(--text-secondary)' }}>Score</p>
              </div>
            </div>
          </PGCard>

          {/* Security Score gauge */}
          <PGCard>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
              <h3 style={{ fontSize: '16px', fontWeight: '700' }}>Overall Protection Score</h3>
              <span style={{ fontSize: '12px', fontWeight: '700', color: scoreColor }}>{scoreLabel}</span>
            </div>

            <div
              style={{
                height: '10px',
                background: 'var(--border)',
                borderRadius: '6px',
                overflow: 'hidden',
                position: 'relative',
                marginBottom: '10px',
              }}
            >
              <div
                style={{
                  height: '100%',
                  width: `${score}%`,
                  background: scoreColor,
                  borderRadius: '6px',
                  transition: 'width 0.8s ease',
                }}
              />
            </div>

            <p style={{ fontSize: '13px', color: scoreColor, fontWeight: '700' }}>{score} / 100 Points</p>
          </PGCard>
        </div>

        {/* Right Side: Badges & Credentials */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
          <PGCard style={{ height: '100%' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '18px' }}>
              <Award size={18} style={{ color: 'var(--primary)' }} />
              <h3 style={{ fontSize: '16px', fontWeight: '700' }}>Achievements & Badges</h3>
            </div>

            {profile.achievementBadges && profile.achievementBadges.length > 0 ? (
              <div style={{ display: 'flex', flexWrap: 'wrap', gap: '10px' }}>
                {profile.achievementBadges.map((badge, idx) => (
                  <div
                    key={idx}
                    style={{
                      background: 'linear-gradient(135deg, rgba(0, 212, 170, 0.15), rgba(123, 97, 255, 0.08))',
                      border: '1px solid rgba(0, 212, 170, 0.3)',
                      borderRadius: '20px',
                      padding: '8px 16px',
                      color: 'var(--primary)',
                      fontSize: '13px',
                      fontWeight: '600',
                      display: 'flex',
                      alignItems: 'center',
                      gap: '6px',
                    }}
                  >
                    <span>🛡️</span>
                    <span>{badge}</span>
                  </div>
                ))}
              </div>
            ) : (
              <div style={{ textAlign: 'center', padding: '40px 0', color: 'var(--text-disabled)' }}>
                <Award size={32} style={{ marginBottom: '10px', opacity: 0.5 }} />
                <p style={{ fontSize: '13px' }}>Scan more suspect links and report scammers to earn badges.</p>
              </div>
            )}
          </PGCard>
        </div>
      </div>
      
      <style>{`
        @media (max-width: 768px) {
          .profile-responsive-columns {
            grid-template-columns: 1fr !important;
          }
        }
      `}</style>
    </div>
  );
};

export default Profile;
