import { useEffect, useState, useCallback } from 'react';
import { api } from '../api.js';
import ImageUpload from './ImageUpload.jsx';
import BlockEditor from './BlockEditor.jsx';

const TEXTAREA_FIELDS = ['deskripsi', 'pertanyaan', 'subtitle', 'konteks'];
const STATUS_OPTIONS = ['published', 'draft'];

function widgetFor(field, idField) {
  if (field.toLowerCase().includes('image') || field.endsWith('Url')) return 'image';
  if (field === 'status') return 'status';
  if (field === idField) return 'id';
  if (TEXTAREA_FIELDS.includes(field)) return 'textarea';
  return 'text';
}

export default function ContentManager({ type, types = [] }) {
  const [rows, setRows] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [form, setForm] = useState(null); // objek yg sedang diedit/dibuat
  const [saving, setSaving] = useState(false);
  const [relOptions, setRelOptions] = useState({}); // field -> [{value,label}]

  const reload = useCallback(async () => {
    setLoading(true);
    setError('');
    try {
      const data = await api.list(type.key);
      setRows(data);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }, [type.key]);

  useEffect(() => {
    reload();
  }, [reload]);

  function blankForm() {
    const o = {};
    type.fields.forEach((f) => {
      if (f === 'status') o[f] = 'published';
      else if (type.enumFields?.[f]) o[f] = type.enumFields[f][0];
      else o[f] = '';
    });
    return o;
  }

  // Bangun opsi dropdown untuk field relasi (mis. unit_id -> daftar Unit).
  async function ensureRelationOptions() {
    const rels = type.relationFields || {};
    const need = Object.entries(rels).filter(([f]) => !relOptions[f]);
    if (!need.length) return;
    const loaded = { ...relOptions };
    for (const [f, sourceKey] of need) {
      try {
        const srcRows = await api.list(sourceKey);
        const srcType = types.find((t) => t.key === sourceKey);
        const idF = srcType?.idField || 'id';
        const labelF = srcType?.labelField;
        loaded[f] = srcRows.map((r) => {
          const val = r[idF] ?? '';
          const label = (labelF && r[labelF]) || r.nama || r.judul || r.title || val;
          return { value: val, label: `${label} (${val})` };
        });
      } catch {
        loaded[f] = [];
      }
    }
    setRelOptions(loaded);
  }

  function openNew() {
    setForm({ _isNew: true, ...blankForm() });
    ensureRelationOptions();
  }
  function openEdit(row) {
    setForm({ _isNew: false, ...row });
    ensureRelationOptions();
  }

  function setField(field, val) {
    setForm((f) => ({ ...f, [field]: val }));
  }

  async function handleSave() {
    setSaving(true);
    setError('');
    try {
      const { _isNew, ...payload } = form;
      await api.save(type.key, payload);
      setForm(null);
      await reload();
    } catch (err) {
      setError(err.message);
    } finally {
      setSaving(false);
    }
  }

  async function handleDelete(row) {
    if (!confirm('Hapus baris ini dari Spreadsheet & Firestore?')) return;
    try {
      await api.remove(type.key, row[type.idField]);
      await reload();
    } catch (err) {
      setError(err.message);
    }
  }

  async function handleSync() {
    try {
      const res = await api.sync(type.key);
      alert(`Sinkron selesai. ${res.synced} baris dipaksa ulang ke Firestore.`);
    } catch (err) {
      setError(err.message);
    }
  }

  const jsonF = type.jsonFields || [];
  const gridFields = type.fields.filter((f) => !jsonF.includes(f));
  const blockFields = type.fields.filter((f) => jsonF.includes(f));

  return (
    <section className="content-area">
      <header className="content-head">
        <div>
          <h2>{type.label}</h2>
          <p className="muted">
            Tab Spreadsheet: <b>{type.sheet}</b> · Collection Firestore: <b>{type.collection}</b>
          </p>
        </div>
        <div className="head-actions">
          <button className="btn ghost" onClick={handleSync}>Sync ke Firestore</button>
          <button className="btn primary" onClick={openNew}>+ Tambah</button>
        </div>
      </header>

      {error && !form && <div className="alert">{error}</div>}

      {loading ? (
        <div className="muted">Memuat data...</div>
      ) : (
        <table className="grid-table">
          <thead>
            <tr>
              {gridFields.map((f) => (
                <th key={f}>{f}</th>
              ))}
              <th>Aksi</th>
            </tr>
          </thead>
          <tbody>
            {rows.length === 0 && (
              <tr>
                <td colSpan={gridFields.length + 1} className="muted center">
                  Belum ada data. Klik "+ Tambah".
                </td>
              </tr>
            )}
            {rows.map((row, i) => (
              <tr key={row[type.idField] || i}>
                {gridFields.map((f) => (
                  <td key={f}>
                    {f.toLowerCase().includes('image') || f.endsWith('Url') ? (
                      row[f] ? <img className="thumb" src={row[f]} alt="" /> : <span className="muted">-</span>
                    ) : (
                      String(row[f] ?? '')
                    )}
                  </td>
                ))}
                <td className="actions">
                  <button className="btn small" onClick={() => openEdit(row)}>Edit</button>
                  <button className="btn small danger" onClick={() => handleDelete(row)}>Hapus</button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}

      {form && (
        <div className="modal-backdrop" onClick={() => setForm(null)}>
          <div className="modal" onClick={(e) => e.stopPropagation()}>
            <h3>{form._isNew ? 'Tambah' : 'Edit'} {type.label}</h3>
            {error && <div className="alert">{error}</div>}
            <div className="form-grid">
              {gridFields.map((f) => {
                const w = type.relationFields?.[f]
                  ? 'relation'
                  : type.enumFields?.[f]
                    ? 'enum'
                    : widgetFor(f, type.idField);
                return (
                  <div className="field" key={f}>
                    <label>{f}</label>
                    {w === 'image' && (
                      <ImageUpload value={form[f]} onChange={(v) => setField(f, v)} />
                    )}
                    {w === 'status' && (
                      <select value={form[f] || ''} onChange={(e) => setField(f, e.target.value)}>
                        {STATUS_OPTIONS.map((s) => <option key={s} value={s}>{s}</option>)}
                      </select>
                    )}
                    {w === 'relation' && (
                      <select value={form[f] || ''} onChange={(e) => setField(f, e.target.value)}>
                        <option value="">— pilih —</option>
                        {(relOptions[f] || []).map((o) => (
                          <option key={o.value} value={o.value}>{o.label}</option>
                        ))}
                        {form[f] && !(relOptions[f] || []).some((o) => o.value === form[f]) && (
                          <option value={form[f]}>{form[f]} (di luar daftar)</option>
                        )}
                      </select>
                    )}
                    {w === 'enum' && (
                      <select value={form[f] || ''} onChange={(e) => setField(f, e.target.value)}>
                        {(type.enumFields[f] || []).map((o) => <option key={o} value={o}>{o}</option>)}
                      </select>
                    )}
                    {w === 'id' && (
                      <input
                        type="text"
                        value={form[f] || ''}
                        disabled={!form._isNew}
                        onChange={(e) => setField(f, e.target.value)}
                        placeholder="kosongkan = otomatis"
                      />
                    )}
                    {w === 'textarea' && (
                      <textarea rows={3} value={form[f] || ''} onChange={(e) => setField(f, e.target.value)} />
                    )}
                    {w === 'text' && (
                      <input
                        type="text"
                        value={form[f] ?? ''}
                        onChange={(e) => setField(f, e.target.value)}
                      />
                    )}
                  </div>
                );
              })}
            </div>
            {blockFields.map((f) => (
              <div className="field field-full" key={f}>
                <label>{f === 'blocks' ? 'Blok konten lesson (materi / video / kuis)' : f}</label>
                <BlockEditor
                  value={form[f]}
                  blockTypes={type.blockTypes || {}}
                  onChange={(v) => setField(f, v)}
                />
              </div>
            ))}
            <div className="modal-actions">
              <button className="btn ghost" onClick={() => setForm(null)}>Batal</button>
              <button className="btn primary" onClick={handleSave} disabled={saving}>
                {saving ? 'Menyimpan...' : 'Simpan & Sync'}
              </button>
            </div>
          </div>
        </div>
      )}
    </section>
  );
}
