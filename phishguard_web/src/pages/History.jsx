import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { Search, Trash2, ShieldAlert, ArrowUpDown, ChevronRight, ShieldCheck } from 'lucide-react';
import api from '../services/api';
import { PGCard, StatusChip, PGEmptyState } from '../components/PGWidgets';

const History = () => {
  const [history, setHistory] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [search, setSearch] = useState('');
  const [filterType, setFilterType] = useState('ALL');
  const navigate = useNavigate();

  const fetchHistory = async () => {
    setLoading(true);
    setError(null);
    try {
      const response = await api.get('/history', {
        params: filterType !== 'ALL' ? { type: filterType } : {},
      });
      setHistory(response.data.data.content || []);
    } catch (err) {
      setError('Could not retrieve scan history log.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchHistory();
  }, [filterType]);

  const handleDelete = async (id, e) => {
    e.stopPropagation(); // Avoid triggering card click
    if (!window.confirm('Are you sure you want to delete this scan record?')) return;
    try {
      await api.delete(`/history/${id}`);
      setHistory((prev) => prev.filter((item) => item.id !== id));
    } catch (err) {
      alert('Failed to delete scan record.');
    }
  };

  const handleCardClick = (item) => {
    navigate('/scan/result', { state: { result: item } });
  };

  const filteredHistory = history.filter((item) =>
    (item.scannedContent || '').toLowerCase().includes(search.toLowerCase()) ||
    (item.domainName || '').toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
      <div>
        <h2 style={{ fontSize: '24px', fontWeight: '700' }}>Scan History</h2>
        <p style={{ fontSize: '13px', color: 'var(--text-secondary)' }}>
          Review and audit your past security checks
        </p>
      </div>

      {/* Filter Options Row */}
      <PGCard style={{ padding: '16px' }}>
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: '16px',
            flexWrap: 'wrap',
          }}
        >
          {/* Search */}
          <div
            style={{
              display: 'flex',
              alignItems: 'center',
              background: 'var(--surface)',
              border: '1px solid var(--border)',
              borderRadius: '10px',
              padding: '0 12px',
              height: '42px',
              flex: 1,
              minWidth: '220px',
            }}
          >
            <Search size={16} style={{ color: 'var(--text-hint)', marginRight: '8px' }} />
            <input
              type="text"
              placeholder="Search content or domain..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              style={{
                background: 'transparent',
                border: 'none',
                outline: 'none',
                color: 'var(--text-primary)',
                fontSize: '13px',
                width: '100%',
              }}
            />
          </div>

          {/* Type Filters */}
          <div style={{ display: 'flex', gap: '8px', flexWrap: 'wrap' }}>
            {['ALL', 'URL', 'QR', 'SMS', 'EMAIL'].map((type) => (
              <button
                key={type}
                onClick={() => setFilterType(type)}
                style={{
                  height: '42px',
                  padding: '0 16px',
                  borderRadius: '10px',
                  border: filterType === type ? '1px solid var(--primary)' : '1px solid var(--border)',
                  background: filterType === type ? 'rgba(0, 212, 170, 0.08)' : 'var(--card)',
                  color: filterType === type ? 'var(--primary)' : 'var(--text-secondary)',
                  fontSize: '13px',
                  fontWeight: '600',
                  cursor: 'pointer',
                  transition: 'all 0.2s ease',
                }}
              >
                {type}
              </button>
            ))}
          </div>
        </div>
      </PGCard>

      {/* History List */}
      {loading ? (
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', minHeight: '200px' }}>
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
      ) : error ? (
        <PGEmptyState
          title="Error Loading History"
          subtitle={error}
          onAction={fetchHistory}
        />
      ) : filteredHistory.length === 0 ? (
        <PGEmptyState
          title="No Records Found"
          subtitle={search ? 'Try adjusting your search query.' : 'You have not scanned anything yet.'}
          icon={<ShieldCheck size={40} />}
        />
      ) : (
        <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
          {filteredHistory.map((item) => (
            <div
              key={item.id}
              onClick={() => handleCardClick(item)}
              style={{
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between',
                padding: '16px 20px',
                borderRadius: '12px',
                background: 'var(--card)',
                border: '1px solid var(--border)',
                cursor: 'pointer',
                transition: 'transform 0.2s ease, border-color 0.2s ease',
              }}
              className="pg-history-card-hover"
            >
              <div style={{ display: 'flex', alignItems: 'center', gap: '16px', minWidth: 0, flex: 1 }}>
                <div
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    width: '38px',
                    height: '38px',
                    borderRadius: '10px',
                    backgroundColor: 'var(--surface)',
                    border: '1px solid var(--border)',
                    flexShrink: 0,
                  }}
                >
                  <span style={{ fontSize: '10px', fontWeight: '700', color: 'var(--primary)' }}>
                    {item.scanType}
                  </span>
                </div>

                <div style={{ minWidth: 0, flex: 1, paddingRight: '16px' }}>
                  <h4
                    style={{
                      fontSize: '14px',
                      fontWeight: '600',
                      overflow: 'hidden',
                      textOverflow: 'ellipsis',
                      whiteSpace: 'nowrap',
                      fontFamily: item.scanType === 'URL' ? 'var(--font-mono)' : 'inherit',
                    }}
                  >
                    {item.scannedContent}
                  </h4>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginTop: '4px', flexWrap: 'wrap' }}>
                    <StatusChip status={item.resultStatus} />
                    <span style={{ fontSize: '11px', color: 'var(--text-disabled)' }}>
                      Risk Score: {item.riskScore}/100
                    </span>
                    {item.domainName && item.domainName !== 'N/A' && (
                      <span style={{ fontSize: '11px', color: 'var(--text-disabled)', fontFamily: 'var(--font-mono)' }}>
                        Domain: {item.domainName}
                      </span>
                    )}
                    <span style={{ fontSize: '11px', color: 'var(--text-disabled)' }}>
                      {new Date(item.scannedAt).toLocaleString()}
                    </span>
                  </div>
                </div>
              </div>

              <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
                <button
                  onClick={(e) => handleDelete(item.id, e)}
                  style={{
                    background: 'transparent',
                    border: 'none',
                    color: 'var(--text-secondary)',
                    cursor: 'pointer',
                    padding: '8px',
                    borderRadius: '8px',
                    transition: 'all 0.2s ease',
                  }}
                  className="trash-btn-hover"
                >
                  <Trash2 size={16} />
                </button>
                <ChevronRight size={18} style={{ color: 'var(--text-disabled)' }} />
              </div>
            </div>
          ))}
        </div>
      )}
      <style>{`
        .pg-history-card-hover:hover {
          border-color: rgba(0, 212, 170, 0.3) !important;
          transform: translateY(-1px);
        }
        .trash-btn-hover:hover {
          color: var(--danger) !important;
          background-color: var(--danger-bg) !important;
        }
      `}</style>
    </div>
  );
};

export default History;
