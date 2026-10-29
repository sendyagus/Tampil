import { useEffect, useState } from 'react';
import { api } from '../api.js';
import { useAuth } from '../authContext.jsx';
import ContentManager from './ContentManager.jsx';
import Overview from './Overview.jsx';

export default function Dashboard() {
  const { user, logout } = useAuth();
  const [types, setTypes] = useState([]);
  const [active, setActive] = useState('overview');
  const [gate, setGate] = useState('checking'); // checking | ok | forbidden

  // Verifikasi status admin dengan memanggil endpoint terlindungi.
  useEffect(() => {
    (async () => {
      try {
        await api.whoami();
        setGate('ok');
      } catch (err) {
        setGate(err.message.includes('bukan admin') ? 'forbidden' : 'error');
      }
    })();
    api.getTypes().then((t) => {
      setTypes(t);
    }).catch(() => setGate('error'));
  }, []);

  const current = types.find((t) => t.key === active);

  if (gate === 'checking') return <div className="center-screen muted">Memverifikasi admin...</div>;
  if (gate === 'forbidden')
    return (
      <div className="center-screen">
        <div className="alert-card">
          <h2>Akses ditolak</h2>
          <p className="muted">
            Akun <b>{user?.email}</b> belum terdaftar sebagai admin. Tambahkan UID-nya ke
            collection Firestore <code>cms_admins</code>.
          </p>
          <button className="btn" onClick={logout}>Keluar</button>
        </div>
      </div>
    );

  return (
    <div className="layout">
      <aside className="sidebar">
        <div className="brand">
          <img src="/logo.jpeg" alt="Logo TAMPIL" />
          <span>
            TAMPIL
            <span className="brand-sub">AI Communication Coach</span>
          </span>
        </div>
        <nav>
          <button
            className={active === 'overview' ? 'nav-item active' : 'nav-item'}
            onClick={() => setActive('overview')}
          >
            Beranda
          </button>
          {types.map((t) => (
            <button
              key={t.key}
              className={t.key === active ? 'nav-item active' : 'nav-item'}
              onClick={() => setActive(t.key)}
            >
              {t.label}
            </button>
          ))}
        </nav>
        <div className="sidebar-foot">
          <span className="muted">{user?.email}</span>
          <button className="btn ghost small" onClick={logout}>Keluar</button>
        </div>
      </aside>

      <main className="main">
        {gate === 'error' && (
          <div className="alert">
            Tidak bisa terhubung ke server CMS. Pastikan server backend berjalan.
          </div>
        )}
        {active === 'overview' ? (
          <Overview types={types} onNavigate={setActive} />
        ) : current ? (
          <ContentManager key={current.key} type={current} types={types} />
        ) : (
          <div className="muted">Memuat...</div>
        )}
      </main>
    </div>
  );
}
