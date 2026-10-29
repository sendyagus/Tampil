import { AuthProvider, useAuth } from './authContext.jsx';
import Login from './components/Login.jsx';
import Dashboard from './components/Dashboard.jsx';

function Gate() {
  const { user, loading } = useAuth();
  if (loading) return <div className="center-screen muted">Memuat...</div>;
  return user ? <Dashboard /> : <Login />;
}

export default function App() {
  return (
    <AuthProvider>
      <Gate />
    </AuthProvider>
  );
}
