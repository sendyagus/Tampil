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

// Nomor berikutnya untuk field yang diisi otomatis: angka terakhir pada baris
// yang sudah ada + 1, mis. modul_01_lesson_03 -> 4.
function nextNumber(list, digitField) {
  let max = 0;
  for (const r of list) {
    const m = /(\d+)\s*$/.exec(String(r[digitField] ?? ''));
    if (m) max = Math.max(max, parseInt(m[1], 10));
  }
  return Math.max(max, list.length) + 1;
}

function applyTemplate(template, group, number, pad) {
  const num = pad ? String(number).padStart(pad, '0') : String(number);
  return template.replace('{group}', group ?? '').replace('{number}', num);
}

export default function ContentManager({ type, types = [] }) {
  const [rows, setRows] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [form, setForm] = useState(null); // objek yg sedang diedit/dibuat
  const [saving, setSaving] = useState(false);
  const [relOptions, setRelOptions] = useState({}); // field -> [{value,label}]
  const [relError, setRelError] = useState('');
  // Sedang memuat daftar sumber relasi (mencegah pesan "masih kosong" bohong).
  const [relLoading, setRelLoading] = useState(false);
  // Field otomatis yang sudah diketik manual, supaya tidak ditimpa lagi.
  const [autoOverridden, setAutoOverridden] = useState({});

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

  // Bangun opsi dropdown untuk field relasi (mis. modul_id -> daftar Modul).
  // Daftar yang kosong ikut dimuat ulang: dulu pernah gagal (server belum
  // menyala) tidak boleh membuat dropdown selamanya kosong.
  async function ensureRelationOptions(force = false) {
    const rels = type.relationFields || {};
    const need = Object.entries(rels).filter(
      ([f]) => force || !relOptions[f] || relOptions[f].length === 0,
    );
    if (!need.length) return;
    const loaded = { ...relOptions };
    setRelLoading(true);
    for (const [f, sourceKey] of need) {
      try {
        const srcRows = await api.list(sourceKey);
        const srcType = types.find((t) => t.key === sourceKey);
        const idF = srcType?.idField || 'id';
        const labelF = srcType?.labelField;
        loaded[f] = srcRows
          .map((r) => {
            const val = r[idF] ?? '';
            const label = (labelF && r[labelF]) || r.nama || r.judul || r.title || val;
            return { value: val, label: `${label} (${val})`, urutan: Number(r.urutan) || 0 };
          })
          .filter((o) => o.value)
          .sort((a, b) => a.urutan - b.urutan || a.value.localeCompare(b.value));
        setRelError('');
      } catch (err) {
        loaded[f] = [];
        setRelError(err.message);
      }
    }
    setRelOptions(loaded);
    setRelLoading(false);
  }

  function openNew() {
    setForm({ _isNew: true, ...blankForm() });
    setAutoOverridden({});
    ensureRelationOptions();
  }
  function openEdit(row) {
    setForm({ _isNew: false, ...row });
    setAutoOverridden({});
    ensureRelationOptions();
  }

  function setField(field, val) {
    setForm((f) => ({ ...f, [field]: val }));
    // Field otomatis: selama nilainya sama dengan saran, biarkan ikut berubah.
    const suggestion = autoSuggestions[field];
    if (suggestion !== undefined) {
      const manual = String(val).trim() !== '' && String(val) !== String(suggestion);
      setAutoOverridden((t) => ({ ...t, [field]: manual }));
    }
  }

  // ---- Pengisian otomatis untuk form baru ---------------------------------
  // Acuan perhitungan adalah baris yang sudah ada (`rows`) + grup terpilih,
  // jadi lesson ke-4 modul_01 otomatis bernama modul_01_lesson_04.
  const autoId = type.autoId || null;
  const autoNumber = type.autoNumber || null;
  const groupId = autoId?.groupField
    ? String(form?.[autoId.groupField] ?? '').trim()
    : '';

  // Baris milik satu grup. Grup kosong (modul belum dipilih) = tidak ada acuan.
  function rowsInGroup(groupField, id) {
    if (!groupField) return rows;
    if (!id) return [];
    return rows.filter((r) => String(r[groupField] ?? '').trim() === id);
  }

  // Saran hanya ada bila grup (modul) sudah dipilih.
  const groupReady = Boolean(form?._isNew) && (!autoId?.groupField || Boolean(groupId));
  const groupRowCount = rowsInGroup(autoId?.groupField, groupId).length;

  const autoSuggestions = {};
  if (groupReady) {
    if (autoId) {
      const n = nextNumber(rowsInGroup(autoId.groupField, groupId), type.idField);
      autoSuggestions[autoId.field] = applyTemplate(
        autoId.template,
        autoId.groupField ? groupId : '',
        n,
        autoId.pad,
      );
    }
    if (autoNumber) {
      autoSuggestions[autoNumber.field] = String(
        nextNumber(rowsInGroup(autoNumber.groupField, groupId), autoNumber.field),
      );
    }
    // Aturan buka ikut menyesuaikan: lesson pertama modul selalu terbuka,
    // lesson berikutnya menunggu lesson sebelumnya selesai.
    for (const [f, rule] of Object.entries(type.autoDefaults || {})) {
      const count = rowsInGroup(rule.groupField || autoId?.groupField, groupId).length;
      autoSuggestions[f] = count === 0 ? rule.first : rule.following;
    }
  }

  const suggestedId = autoId ? autoSuggestions[autoId.field] : undefined;
  const suggestedNumber = autoNumber ? autoSuggestions[autoNumber.field] : undefined;

  // Terapkan saran selama admin belum mengetik manual.
  useEffect(() => {
    if (!form || !form._isNew) return;
    const patch = {};
    for (const [f, suggestion] of Object.entries(autoSuggestions)) {
      if (autoOverridden[f]) continue;
      if (String(form[f] ?? '') !== String(suggestion)) patch[f] = String(suggestion);
    }
    if (Object.keys(patch).length) setForm((prev) => ({ ...prev, ...patch }));
  }, [form, autoSuggestions, autoOverridden]);

  // Otomatis isi nilai pertama untuk field relasi pada form baru, supaya data
  // tidak tersimpan tanpa hubungan (mis. lesson tanpa modul_id -> hilang di app).
  useEffect(() => {
    if (!form || !form._isNew) return;
    const patch = {};
    for (const f of Object.keys(type.relationFields || {})) {
      const opts = relOptions[f];
      if (!String(form[f] || '').trim() && opts && opts.length) {
        patch[f] = opts[0].value;
      }
    }
    if (Object.keys(patch).length) setForm((prev) => ({ ...prev, ...patch }));
  }, [relOptions, form, type]);

  async function handleSave() {
    // Cegah simpan data tanpa field relasi: data semacam ini tersimpan di
    // Firestore tapi tidak muncul di aplikasi.
    const missing = Object.keys(type.relationFields || {}).filter(
      (f) => !String(form[f] || '').trim(),
    );
    if (missing.length) {
      setError(`Wajib diisi: ${missing.join(', ')} — pilih nilainya dulu.`);
      return;
    }
    // ID yang sama akan MENIMPA baris lama, jadi minta konfirmasi.
    const idVal = String(form[type.idField] || '').trim();
    if (form._isNew && idVal && rows.some((r) => String(r[type.idField] ?? '') === idVal)) {
      if (!confirm(`ID "${idVal}" sudah dipakai. Timpa data yang lama?`)) return;
    }
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
  // Urutan field di form boleh beda dari urutan kolom sheet (formOrder), mis.
  // modul_id didahulukan lalu lesson_id. Field yang tidak disebut tetap tampil.
  const order = type.formOrder || [];
  const formFields = [
    ...order.filter((f) => gridFields.includes(f)),
    ...gridFields.filter((f) => !order.includes(f)),
  ];

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
              {formFields.map((f) => {
                const w = type.relationFields?.[f]
                  ? 'relation'
                  : type.enumFields?.[f]
                    ? 'enum'
                    : widgetFor(f, type.idField);
                const isAutoId = Boolean(autoId) && f === autoId.field;
                const isAutoNumber = Boolean(autoNumber) && f === autoNumber.field;
                const srcKey = type.relationFields?.[f];
                const srcLabel = types.find((t) => t.key === srcKey)?.label || srcKey || '';
                return (
                  <div className="field" key={f}>
                    <label>{type.fieldLabels?.[f] || f}</label>
                    {w === 'image' && (
                      <ImageUpload value={form[f]} onChange={(v) => setField(f, v)} />
                    )}
                    {w === 'status' && (
                      <select value={form[f] || ''} onChange={(e) => setField(f, e.target.value)}>
                        {STATUS_OPTIONS.map((s) => <option key={s} value={s}>{s}</option>)}
                      </select>
                    )}
                    {w === 'relation' && (
                      <>
                        <select value={form[f] || ''} onChange={(e) => setField(f, e.target.value)}>
                          <option value="">— pilih —</option>
                          {(relOptions[f] || []).map((o) => (
                            <option key={o.value} value={o.value}>{o.label}</option>
                          ))}
                          {form[f] && !(relOptions[f] || []).some((o) => o.value === form[f]) && (
                            <option value={form[f]}>{form[f]} (di luar daftar)</option>
                          )}
                        </select>
                        {(relOptions[f] || []).length === 0 ? (
                          relLoading ? (
                            <small className="muted">Memuat daftar {srcLabel}...</small>
                          ) : (
                          <small className="muted">
                            {relError
                              ? `Daftar ${srcLabel} gagal dimuat: ${relError}.`
                              : `Belum ada data di menu ${srcLabel}. Tambahkan lebih dulu, lalu muat ulang.`}
                            {' '}
                            <button
                              type="button"
                              className="btn tiny ghost"
                              onClick={() => ensureRelationOptions(true)}
                            >
                              Muat ulang
                            </button>
                          </small>
                          )
                        ) : (
                          <small className="muted">
                            {relOptions[f].length} pilihan dari menu {srcLabel}.
                            {form._isNew && autoId?.groupField === f && groupId ? (
                              <>{' '}
                              {groupRowCount === 0
                                ? 'Modul ini belum punya lesson, jadi ID mulai dari 01.'
                                : `Sudah ada ${groupRowCount} lesson di modul ini.`}
                            </>
                            ) : null}
                          </small>
                        )}
                      </>
                    )}
                    {w === 'enum' && (
                      <>
                        <select value={form[f] || ''} onChange={(e) => setField(f, e.target.value)}>
                          {(type.enumFields[f] || []).map((o) => <option key={o} value={o}>{o}</option>)}
                        </select>
                        {form._isNew && autoSuggestions[f] && !autoOverridden[f] ? (
                          <small className="muted">
                            Terisi otomatis: <b>{autoSuggestions[f]}</b> — mengikuti jumlah lesson
                            di modul terpilih.
                          </small>
                        ) : null}
                      </>
                    )}
                    {w === 'id' && (
                      <>
                        <input
                          type="text"
                          value={form[f] || ''}
                          disabled={!form._isNew}
                          onChange={(e) => setField(f, e.target.value)}
                          placeholder="kosongkan = otomatis"
                        />
                        {form._isNew && isAutoId && (
                          <small className="muted">
                            {suggestedId ? (
                              <>
                                {autoOverridden[f] ? 'Saran otomatis: ' : 'Terisi otomatis: '}
                                <b>{suggestedId}</b> — melanjutkan nomor terakhir yang sudah ada.
                                {autoOverridden[f] && (
                                  <>
                                    {' '}
                                    <button
                                      type="button"
                                      className="btn tiny ghost"
                                      onClick={() => setField(f, suggestedId)}
                                    >
                                      Pakai otomatis
                                    </button>
                                  </>
                                )}
                              </>
                            ) : (
                              <>Pilih modul lebih dulu, lalu ID lesson terisi sendiri.</>
                            )}
                          </small>
                        )}
                      </>
                    )}
                    {w === 'textarea' && (
                      <textarea rows={3} value={form[f] || ''} onChange={(e) => setField(f, e.target.value)} />
                    )}
                    {w === 'text' && (
                      <>
                        <input
                          type="text"
                          value={form[f] ?? ''}
                          onChange={(e) => setField(f, e.target.value)}
                        />
                        {form._isNew && isAutoNumber && suggestedNumber ? (
                          <small className="muted">
                            {autoOverridden[f] ? 'Saran otomatis: ' : 'Terisi otomatis: '}{' '}
                            <b>{suggestedNumber}</b>
                            {autoNumber.groupField
                              ? ' — nomor terakhir pada modul ini + 1.'
                              : ' — nomor terakhir + 1.'}
                          </small>
                        ) : null}
                      </>
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
