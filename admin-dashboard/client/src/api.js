import { auth } from './firebase.js';

const BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:4000/api';

// Ambil ID token Firebase terbaru untuk otorisasi ke server.
async function authToken() {
  const user = auth.currentUser;
  if (!user) throw new Error('Belum login.');
  return user.getIdToken(true);
}

async function request(path, options = {}) {
  const token = await authToken();
  const headers = { Authorization: `Bearer ${token}`, ...(options.headers || {}) };
  const res = await fetch(`${BASE_URL}${path}`, { ...options, headers });
  const data = await res.json().catch(() => ({}));
  if (!res.ok) throw new Error(data.error || `HTTP ${res.status}`);
  return data;
}

export const api = {
  getTypes: () => fetch(`${BASE_URL}/types`).then((r) => r.json()),
  whoami: () => request('/whoami'),
  list: (key) => request(`/content/${key}`),
  save: (key, payload) =>
    request(`/content/${key}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
    }),
  remove: (key, id) => request(`/content/${key}/${encodeURIComponent(id)}`, { method: 'DELETE' }),
  sync: (key) => request(`/content/${key}/sync`, { method: 'POST' }),
  uploadImage: async (file) => {
    const form = new FormData();
    form.append('image', file);
    return request('/upload-image', { method: 'POST', body: form });
  },
};
