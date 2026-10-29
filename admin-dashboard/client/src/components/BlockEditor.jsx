import { useState } from 'react';

// Label ramah untuk tiap field blok.
const FIELD_LABEL = {
  judul: 'Judul',
  isi: 'Isi (teks materi)',
  url: 'Link video (YouTube)',
  gambar: 'URL gambar',
  pertanyaan: 'Pertanyaan',
  opsi: 'Opsi jawaban (1 baris = 1 opsi)',
  jawaban: 'Jawaban benar',
};
const TEXTAREA_FIELDS = ['isi', 'pertanyaan', 'opsi'];

function parseBlocks(value) {
  if (!value) return [];
  if (Array.isArray(value)) return value;
  try {
    const arr = JSON.parse(value);
    return Array.isArray(arr) ? arr : [];
  } catch {
    return [];
  }
}

// migrasi blok lama (opsiA/opsiB/opsiC) -> format 'opsi' satu baris per opsi
function normalizeBlock(b) {
  if (b.tipe === 'kuis' && (b.opsiA !== undefined || b.opsiB !== undefined || b.opsiC !== undefined)) {
    const opsi = [b.opsiA, b.opsiB, b.opsiC].filter((x) => x !== undefined && x !== null && x !== '');
    const { opsiA, opsiB, opsiC, ...rest } = b;
    return { ...rest, opsi: opsi.join('\n') };
  }
  return b;
}

function emptyBlock(tipe, fields) {
  const b = { tipe };
  fields.forEach((f) => (b[f] = f === 'jawaban' ? '0' : ''));
  if (tipe === 'kuis' && !b.opsi) b.opsi = '';
  return b;
}

const HURUF = ['A', 'B', 'C', 'D', 'E', 'F'];

/**
 * Editor blok konten untuk satu lesson.
 * value = teks JSON (daftar blok); onChange mengirim teks JSON terbaru.
 * blockTypes = peta tipe blok -> daftar field (dari contentTypes server).
 * Setiap blok ditampilkan sebagai "Halaman N" di app.
 */
export default function BlockEditor({ value, blockTypes = {}, onChange }) {
  const blocks = parseBlocks(value).map(normalizeBlock);
  const tipeOptions = Object.keys(blockTypes);
  const [pilihTipe, setPilihTipe] = useState(tipeOptions[0] || 'materi');

  function emit(next) {
    onChange(JSON.stringify(next));
  }

  function addBlock() {
    const fields = blockTypes[pilihTipe] || [];
    emit([...blocks, emptyBlock(pilihTipe, fields)]);
  }

  function updateBlock(i, field, val) {
    const next = blocks.map((b, idx) => (idx === i ? { ...b, [field]: val } : b));
    emit(next);
  }

  function removeBlock(i) {
    emit(blocks.filter((_, idx) => idx !== i));
  }

  function move(i, dir) {
    const j = i + dir;
    if (j < 0 || j >= blocks.length) return;
    const next = [...blocks];
    [next[i], next[j]] = [next[j], next[i]];
    emit(next);
  }

  // jumlah opsi kuis pada blok i ( utk pilihan jawaban A..F )
  function opsiCount(b) {
    const n = String(b.opsi || '').split('\n').filter((x) => x.trim()).length;
    return Math.max(n, 2);
  }

  return (
    <div className="block-editor">
      <div className="block-add-row">
        <label className="muted">Mau tambah apa?</label>
        <select value={pilihTipe} onChange={(e) => setPilihTipe(e.target.value)}>
          {tipeOptions.map((t) => (
            <option key={t} value={t}>{t}</option>
          ))}
        </select>
        <button type="button" className="btn small primary" onClick={addBlock}>
          + Tambah halaman
        </button>
      </div>
      <p className="muted">
        Setiap blok = satu halaman di app. Jumlah, urutan, dan isinya bebas kamu atur.
      </p>

      {blocks.length === 0 && (
        <p className="muted">Belum ada halaman. Pilih tipe lalu klik "+ Tambah halaman".</p>
      )}

      {blocks.map((b, i) => (
        <div className="block-card" key={i}>
          <div className="block-card-head">
            <span className="block-badge">Halaman {i + 1} · {b.tipe}</span>
            <div className="block-card-actions">
              <button type="button" className="btn tiny" onClick={() => move(i, -1)} disabled={i === 0} title="Naik">▲</button>
              <button type="button" className="btn tiny" onClick={() => move(i, 1)} disabled={i === blocks.length - 1} title="Turun">▼</button>
              <button type="button" className="btn tiny danger" onClick={() => removeBlock(i)} title="Hapus halaman">✕</button>
            </div>
          </div>

          <div className="block-fields">
            {(blockTypes[b.tipe] || Object.keys(b).filter((k) => k !== 'tipe')).map((f) => (
              <div className="field" key={f}>
                <label>{FIELD_LABEL[f] || f}</label>
                {f === 'jawaban' ? (
                  <select
                    value={String(b[f] ?? '0')}
                    onChange={(e) => updateBlock(i, f, e.target.value)}
                  >
                    {HURUF.slice(0, opsiCount(b)).map((h, idx) => (
                      <option key={h} value={String(idx)}>{h}</option>
                    ))}
                  </select>
                ) : f === 'gambar' ? (
                  <>
                    <input
                      type="text"
                      placeholder="https://.../gambar.jpg"
                      value={b[f] ?? ''}
                      onChange={(e) => updateBlock(i, f, e.target.value)}
                    />
                    {b['gambar'] ? (
                      <img className="block-img-preview" src={b['gambar']} alt="preview"
                        onError={(e) => { e.target.style.display = 'none'; }} />
                    ) : null}
                  </>
                ) : TEXTAREA_FIELDS.includes(f) ? (
                  <textarea
                    rows={f === 'isi' ? 4 : (f === 'opsi' ? 4 : 2)}
                    placeholder={f === 'opsi' ? 'Opsi A...\nOpsi B...\nOpsi C...' : undefined}
                    value={b[f] ?? ''}
                    onChange={(e) => updateBlock(i, f, e.target.value)}
                  />
                ) : (
                  <input
                    type="text"
                    value={b[f] ?? ''}
                    onChange={(e) => updateBlock(i, f, e.target.value)}
                  />
                )}
              </div>
            ))}
          </div>
        </div>
      ))}
    </div>
  );
}
