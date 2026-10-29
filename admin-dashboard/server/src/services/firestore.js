import { fireStore } from '../config.js';

// Siapkan record untuk Firestore: ubah field bertipe jsonFields (mis. 'blocks')
// dari teks JSON (di Spreadsheet) menjadi array/object sungguhan di Firestore,
// supaya aplikasi mobile bisa membacanya sebagai List.
function toFirestore(type, record) {
  const out = { ...record };
  for (const f of type.jsonFields || []) {
    const v = out[f];
    if (typeof v === 'string') {
      const s = v.trim();
      if (!s) {
        out[f] = [];
      } else {
        try {
          out[f] = JSON.parse(s);
        } catch {
          // JSON tidak valid -> simpan array kosong agar tidak merusak sync
          out[f] = [];
        }
      }
    }
  }
  return out;
}

// Tulis/ubah satu dokumen Firestore memakai idField sebagai doc id,
// supaya konsisten dengan baris Spreadsheet.
export async function syncDoc(type, record) {
  const db = fireStore();
  const id = record[type.idField];
  await db.collection(type.collection).doc(id).set(toFirestore(type, record));
  return id;
}

export async function deleteDoc(type, id) {
  const db = fireStore();
  await db.collection(type.collection).doc(id).delete();
}

// Sinkron penuh Spreadsheet -> Firestore (semua baris).
export async function fullSync(type, rows) {
  const db = fireStore();
  const batch = db.batch();
  for (const r of rows) {
    const ref = db.collection(type.collection).doc(r[type.idField]);
    batch.set(ref, toFirestore(type, r));
  }
  await batch.commit();
  return rows.length;
}
