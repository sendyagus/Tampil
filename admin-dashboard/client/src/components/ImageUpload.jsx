import { useState } from 'react';
import { api } from '../api.js';

// Komponen unggah gambar: pilih file -> upload ke Drive via server ->
// otomatis mengisi field imageUrl dengan link Drive.
export default function ImageUpload({ value, onChange }) {
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');

  async function handleFile(e) {
    const file = e.target.files?.[0];
    if (!file) return;
    setError('');
    setBusy(true);
    try {
      const res = await api.uploadImage(file);
      onChange(res.imageUrl);
    } catch (err) {
      setError(err.message);
    } finally {
      setBusy(false);
      e.target.value = '';
    }
  }

  return (
    <div className="image-upload">
      <div className="image-preview">
        {value ? <img src={value} alt="preview" /> : <span className="muted">Belum ada gambar</span>}
      </div>
      <div className="image-actions">
        <label className="btn small">
          {busy ? 'Mengunggah...' : 'Unggah ke Drive'}
          <input type="file" accept="image/*" onChange={handleFile} hidden disabled={busy} />
        </label>
        {error && <span className="alert inline">{error}</span>}
      </div>
      <input
        className="link-input"
        type="text"
        value={value || ''}
        onChange={(e) => onChange(e.target.value)}
        placeholder="atau tempel link gambar Drive"
      />
    </div>
  );
}
