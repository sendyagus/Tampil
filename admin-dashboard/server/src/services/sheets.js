import { getSheets, SPREADSHEET_ID } from '../config.js';

// Nilai sel Spreadsheet selalu string. Konversi kembali ke number untuk
// kolom numerik supaya konsisten saat masuk Firestore.
function coerce(type, row) {
  const out = {};
  for (const f of type.fields) {
    let v = row[f];
    if (v === undefined || v === null) v = '';
    if (type.numericFields.includes(f)) {
      const n = parseInt(String(v), 10);
      out[f] = Number.isNaN(n) ? 0 : n;
    } else {
      out[f] = String(v);
    }
  }
  return out;
}

async function getSheetId(title) {
  if (sheetIdCache.has(title)) return sheetIdCache.get(title);
  const sheets = await getSheets();
  const meta = await sheets.spreadsheets.get({
    spreadsheetId: SPREADSHEET_ID,
    fields: 'sheets.properties',
  });
  const found = meta.data.sheets.find((s) => s.properties.title === title);
  const id = found ? found.properties.sheetId : null;
  if (id !== null) sheetIdCache.set(title, id);
  return id;
}

// Cache in-memory agar tidak menembak kuota Sheets API tiap kali baca.
const sheetIdCache = new Map(); // title -> sheetId
const ensuredTitles = new Set(); // title yang header-nya sudah dipastikan

// Pastikan tab ada + punya header baris pertama.
export async function ensureSheet(type) {
  if (ensuredTitles.has(type.sheet)) return sheetIdCache.get(type.sheet);
  const sheets = await getSheets();
  let sheetId = await getSheetId(type.sheet);
  if (sheetId === null) {
    await sheets.spreadsheets.batchUpdate({
      spreadsheetId: SPREADSHEET_ID,
      requestBody: {
        requests: [{ addSheet: { properties: { title: type.sheet } } }],
      },
    });
    sheetId = await getSheetId(type.sheet);
  }
  // Tulis header bila masih kosong.
  const values = await sheets.spreadsheets.values.get({
    spreadsheetId: SPREADSHEET_ID,
    range: `${type.sheet}!A1:1`,
  });
  const first = values.data.values?.[0];
  if (!first || first.length === 0) {
    await sheets.spreadsheets.values.update({
      spreadsheetId: SPREADSHEET_ID,
      range: `${type.sheet}!A1`,
      valueInputOption: 'RAW',
      requestBody: { values: [type.fields] },
    });
  }
  ensuredTitles.add(type.sheet);
  return sheetId;
}

// Baca seluruh baris (tanpa header) menjadi array objek.
export async function readRows(type) {
  const sheets = await getSheets();
  await ensureSheet(type);
  const res = await sheets.spreadsheets.values.get({
    spreadsheetId: SPREADSHEET_ID,
    range: `${type.sheet}!A1:Z1000`,
  });
  const values = res.data.values || [];
  if (values.length <= 1) return [];
  const header = values[0];
  return values
    .slice(1)
    .map((r) => {
      const obj = {};
      header.forEach((h, i) => (obj[h] = r[i] ?? ''));
      return coerce(type, obj);
    })
    .filter((o) => o[type.idField]);
}

// Tulis ulang seluruh baris (header + data).
export async function writeRows(type, rows) {
  const sheets = await getSheets();
  await ensureSheet(type);
  // Bersihkan isi lama dulu: values.update tidak menghapus baris sisa, sehingga
  // saat jumlah baris berkurang (mis. setelah hapus) data lama tertinggal.
  await sheets.spreadsheets.values.clear({
    spreadsheetId: SPREADSHEET_ID,
    range: `${type.sheet}!A1:Z1000`,
    requestBody: {},
  });
  const body = [type.fields, ...rows.map((r) => type.fields.map((f) => r[f] ?? ''))];
  await sheets.spreadsheets.values.update({
    spreadsheetId: SPREADSHEET_ID,
    range: `${type.sheet}!A1`,
    valueInputOption: 'RAW',
    requestBody: { values: body },
  });
}

// Insert / update satu objek berdasarkan idField. Mengembalikan objek final.
export async function upsertRow(type, payload) {
  const rows = await readRows(type);
  const record = coerce(type, payload);
  const id = record[type.idField];
  const idx = rows.findIndex((r) => r[type.idField] === id);
  if (idx >= 0) rows[idx] = record;
  else rows.push(record);
  await writeRows(type, rows);
  return record;
}

// Hapus satu baris berdasarkan id.
export async function deleteRow(type, id) {
  const rows = await readRows(type);
  const next = rows.filter((r) => r[type.idField] !== id);
  await writeRows(type, next);
}
