import { useEffect, useState, useCallback } from 'react';
import { api } from '../api.js';

// Halaman Beranda/Overview: ringkasan jumlah konten per tipe + aksi cepat.
export default function Overview({ types, onNavigate }) {
  const [stats, setStats] = useState({}); // key -> { total, published }
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [syncing, setSyncing] = useState(false);

  const load = useCallback(async () => {
    if (!types?.length) return;
    setLoading(true);
    setError('');
    try {
      const entries = await Promise.all(
        types.map(async (t) => {
          const rows = await api.list(t.key);
          const published = rows.filter(
            (r) => (r.status || 'published') === 'published',
          ).length;
          return [t.key, { total: rows.length, published }];
        }),
      );
      setStats(Object.fromEntries(entries));
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }, [types]);

  useEffect(() => {
    load();
  }, [load]);

  async function syncAll() {
    setSyncing(true);
    setError('');
    try {
      for (const t of types) await api.sync(t.key);
      await load();
    } catch (err) {
      setError(err.message);
    } finally {
      setSyncing(false);
    }
  }

  const totalAll = Object.values(stats).reduce((a, s) => a + (s.total || 0), 0);

  return (
    <section className="content-area overview">
      <header className="content-head">
        <div>
          <h2>Beranda</h2>
          <p className="muted">Ringkasan konten yang dikelola lewat CMS TAMPIL.</p>
        </div>
        <div className="head-actions">
          <button className="btn ghost" onClick={load} disabled={loading}>
            ↻ Muat ulang
          </button>
          <button className="btn primary" onClick={syncAll} disabled={syncing}>
            {syncing ? 'Syncing...' : 'Sync semua ke Firestore'}
          </button>
        </div>
      </header>

      {error && <div className="alert">{error}</div>}

      <div className="stat-cards">
        {types.map((t) => {
          const s = stats[t.key] || { total: 0, published: 0 };
          return (
            <button
              className="stat-card"
              key={t.key}
              onClick={() => onNavigate(t.key)}
            >
              <span className="stat-label">{t.label}</span>
              <span className="stat-total">{loading ? '–' : s.total}</span>
              <span className="stat-sub">
                {s.published} published · <code>{t.collection}</code>
              </span>
            </button>
          );
        })}
      </div>

      <div className="panel overview-note">
        <h3>Alur konten</h3>
        <ol className="flow">
          <li>Kelola konten di menu kiri (tersimpan ke <b>Google Spreadsheet</b>).</li>
          <li>Gambar diunggah ke <b>Google Drive</b>, link tersimpan otomatis.</li>
          <li>Konten disinkronkan ke <b>Firestore</b>.</li>
          <li>Aplikasi Flutter menampilkannya secara <b>real-time</b>.</li>
        </ol>
        <p className="muted">Total <b>{totalAll}</b> item konten terdaftar.</p>
      </div>
    </section>
  );
}
