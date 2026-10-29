import { Router } from 'express';
import multer from 'multer';
import { contentTypes, typeKeys } from '../contentTypes.js';
import { readRows, upsertRow, deleteRow } from '../services/sheets.js';
import { syncDoc, deleteDoc, fullSync } from '../services/firestore.js';
import { uploadImage } from '../services/drive.js';
import { requireAdmin } from '../middleware/requireAdmin.js';

const router = Router();
const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 15 * 1024 * 1024 }, // 15MB
});

function genId(prefix) {
  return `${prefix}_${Date.now().toString(36)}${Math.random().toString(36).slice(2, 6)}`;
}

function validKey(key, res) {
  if (!contentTypes[key]) {
    res.status(404).json({ error: `Tipe konten tidak dikenal: ${key}` });
    return false;
  }
  return true;
}

// Daftar tipe + skema field untuk membangun form secara dinamis.
router.get('/types', (req, res) => {
  const list = typeKeys.map((k) => ({ key: k, ...contentTypes[k] }));
  res.json(list);
});

// Cek cepat status admin TANPA menyentuh Sheets (hemat kuota API).
router.get('/whoami', requireAdmin, (req, res) => {
  res.json({ ok: true, uid: req.user.uid, email: req.user.email || '' });
});

// Baca seluruh konten satu tipe (sumber kebenaran: Spreadsheet).
router.get('/content/:key', requireAdmin, async (req, res) => {
  const type = contentTypes[req.params.key];
  if (!validKey(req.params.key, res)) return;
  try {
    const rows = await readRows(type);
    res.json(rows);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Buat / ubah satu baris -> tulis ke Spreadsheet -> sinkron ke Firestore.
router.post('/content/:key', requireAdmin, async (req, res) => {
  const key = req.params.key;
  const type = contentTypes[key];
  if (!validKey(key, res)) return;
  try {
    const payload = { ...req.body };
    if (!payload[type.idField]) payload[type.idField] = genId(key);
    if (!payload.status) payload.status = 'published';
    const record = await upsertRow(type, payload);
    await syncDoc(type, record);
    res.json(record);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Hapus satu baris dari Spreadsheet + Firestore.
router.delete('/content/:key/:id', requireAdmin, async (req, res) => {
  const key = req.params.key;
  const type = contentTypes[key];
  if (!validKey(key, res)) return;
  try {
    await deleteRow(type, req.params.id);
    await deleteDoc(type, req.params.id);
    res.json({ ok: true });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Sinkron penuh Spreadsheet -> Firestore (semua baris).
router.post('/content/:key/sync', requireAdmin, async (req, res) => {
  const key = req.params.key;
  const type = contentTypes[key];
  if (!validKey(key, res)) return;
  try {
    const rows = await readRows(type);
    const count = await fullSync(type, rows);
    res.json({ ok: true, synced: count });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Upload gambar ke Drive -> return link untuk disimpan ke Spreadsheet/Firestore.
router.post('/upload-image', requireAdmin, upload.single('image'), async (req, res) => {
  try {
    if (!req.file) return res.status(400).json({ error: 'Tidak ada file gambar.' });
    const info = await uploadImage(req.file.buffer, req.file.mimetype, req.file.originalname);
    res.json(info);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

export default router;
