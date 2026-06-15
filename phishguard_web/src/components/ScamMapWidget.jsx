import React, { useState, useEffect } from 'react';
import { Map, X } from 'lucide-react';
import api from '../services/api';
import { PGCard, SeverityChip } from './PGWidgets';

const ScamMapWidget = () => {
  const [hotspots, setHotspots] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [selectedHotspot, setSelectedHotspot] = useState(null);

  useEffect(() => {
    const fetchHotspots = async () => {
      try {
        const response = await api.get('/dashboard/map-hotspots');
        setHotspots(response.data.data);
      } catch (err) {
        setError('Failed to fetch Live Threat Radar data.');
      } finally {
        setLoading(false);
      }
    };
    fetchHotspots();
  }, []);

  // Visual layout dimensions
  const mapHeight = 320;

  const getVisualCoords = (city) => {
    switch (city.toUpperCase()) {
      case 'DELHI': return { x: '46%', y: '28%' };
      case 'MUMBAI': return { x: '35%', y: '56%' };
      case 'JAMTARA': return { x: '72%', y: '44%' };
      case 'BENGALURU': return { x: '45%', y: '75%' };
      case 'HYDERABAD': return { x: '48%', y: '61%' };
      default: return { x: '50%', y: '50%' };
    }
  };

  const getSeverityClass = (sev) => {
    const s = (sev || 'MEDIUM').toUpperCase();
    if (s === 'CRITICAL') return 'critical';
    if (s === 'HIGH') return 'high';
    return 'medium';
  };

  if (loading) {
    return (
      <PGCard>
        <div style={{ height: '320px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
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
      </PGCard>
    );
  }

  if (error) {
    return (
      <PGCard>
        <div style={{ height: '320px', display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'var(--text-disabled)', fontSize: '13px' }}>
          {error}
        </div>
      </PGCard>
    );
  }

  return (
    <PGCard style={{ position: 'relative', overflow: 'hidden' }}>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '16px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
          <Map size={18} style={{ color: 'var(--primary)' }} />
          <h3 style={{ fontSize: '16px', fontWeight: '700' }}>Live Threat Radar (India)</h3>
        </div>
        <div
          style={{
            background: 'var(--danger-bg)',
            padding: '3px 8px',
            borderRadius: '8px',
            display: 'flex',
            alignItems: 'center',
            gap: '6px',
          }}
        >
          <span
            style={{
              width: '6px',
              height: '6px',
              backgroundColor: 'var(--danger)',
              borderRadius: '50%',
              display: 'inline-block',
            }}
          />
          <span style={{ color: 'var(--danger)', fontSize: '9px', fontWeight: '800', letterSpacing: '0.05em' }}>
            LIVE FEED
          </span>
        </div>
      </div>

      <div
        style={{
          position: 'relative',
          height: `${mapHeight}px`,
          backgroundColor: '#070B14',
          borderRadius: '12px',
          border: '1px solid var(--border)',
        }}
      >
        {/* SVG background grid and India outline map */}
        <svg
          width="100%"
          height="100%"
          style={{ position: 'absolute', top: 0, left: 0, pointerEvents: 'none' }}
        >
          {/* Coordinate grid lines */}
          <defs>
            <pattern id="grid" width="30" height="30" patternUnits="userSpaceOnUse">
              <path d="M 30 0 L 0 0 0 30" fill="none" stroke="var(--border)" strokeWidth="0.5" opacity="0.12" />
            </pattern>
          </defs>
          <rect width="100%" height="100%" fill="url(#grid)" />

          {/* India abstract geographic outline paths */}
          <path
            d="
              M 180 30
              L 184 90
              L 96 153
              L 140 179
              L 180 240
              L 188 288
              L 288 140
              L 352 121
              L 184 90
              Z
            "
            fill="none"
            stroke="var(--border)"
            strokeWidth="1.2"
            opacity="0.35"
            style={{
              transform: 'scale(1.1) translate(-20px, 0px)',
            }}
          />

          {/* Glowing communication vector trunks connecting points */}
          <g opacity="0.2">
            <line x1="46%" y1="28%" x2="48%" y2="61%" stroke="var(--primary)" strokeWidth="1" />
            <line x1="35%" y1="56%" x2="48%" y2="61%" stroke="var(--primary)" strokeWidth="1" />
            <line x1="45%" y1="75%" x2="48%" y2="61%" stroke="var(--primary)" strokeWidth="1" />
            <line x1="72%" y1="44%" x2="48%" y2="61%" stroke="var(--primary)" strokeWidth="1" />
            <line x1="46%" y1="28%" x2="72%" y2="44%" stroke="var(--primary)" strokeWidth="1" />
            <line x1="35%" y1="56%" x2="45%" y2="75%" stroke="var(--primary)" strokeWidth="1" />
          </g>
        </svg>

        {/* Pulsing Radar Nodes */}
        {hotspots.map((hotspot) => {
          const coords = getVisualCoords(hotspot.city);
          const severityClass = getSeverityClass(hotspot.severity);

          return (
            <div
              key={hotspot.city}
              className={`radar-node ${severityClass}`}
              style={{
                left: `calc(${coords.x} - 7px)`,
                top: `calc(${coords.y} - 7px)`,
              }}
              onClick={() => setSelectedHotspot(hotspot)}
            >
              <div className="ring" />
              <div className="core" />
            </div>
          );
        })}

        {/* Detail Overlay Card */}
        {selectedHotspot && (
          <div
            style={{
              position: 'absolute',
              left: '12px',
              right: '12px',
              bottom: '12px',
              background: '#0E162AE0',
              border: '1px solid var(--border)',
              borderRadius: '12px',
              padding: '12px 16px',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'between',
              boxShadow: '0 8px 24px rgba(0, 0, 0, 0.4)',
              backdropFilter: 'blur(8px)',
              zIndex: 20,
              animation: 'slideUp 0.2s cubic-bezier(0.16, 1, 0.3, 1) forwards',
            }}
          >
            <div style={{ flex: 1 }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '4px' }}>
                <span style={{ fontSize: '13px', fontWeight: '700', color: '#FFF' }}>
                  📍 {selectedHotspot.city}
                </span>
                <SeverityChip severity={selectedHotspot.severity} />
              </div>
              <p style={{ fontSize: '11px', color: 'var(--text-primary)', fontWeight: '500' }}>
                Top Threat: <span style={{ color: 'var(--primary)' }}>{selectedHotspot.topScam}</span>
              </p>
              <p style={{ fontSize: '10px', color: 'var(--text-secondary)', marginTop: '2px' }}>
                Active Threat Volume: {selectedHotspot.threatCount} reported cases
              </p>
            </div>
            <button
              onClick={() => setSelectedHotspot(null)}
              style={{
                background: 'transparent',
                border: 'none',
                color: 'var(--text-secondary)',
                cursor: 'pointer',
                padding: '4px',
              }}
            >
              <X size={16} />
            </button>
          </div>
        )}
      </div>
    </PGCard>
  );
};

export default ScamMapWidget;
