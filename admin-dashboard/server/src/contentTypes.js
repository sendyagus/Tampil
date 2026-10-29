// Definisi tipe konten yang dikelola CMS.
// Setiap tipe dipetakan ke satu tab (worksheet) di Spreadsheet
// dan satu collection di Firestore. Kolom Spreadsheet = header = fields.
// `image` menyimpan LINK gambar dari Google Drive (bukan file-nya).

export const contentTypes = {
  hero: {
    label: 'Hero Card / Banner',
    collection: 'cms_hero',
    sheet: 'Hero',
    idField: 'id',
    fields: ['id', 'title', 'subtitle', 'imageUrl', 'ctaText', 'urutan', 'status'],
    numericFields: ['urutan'],
  },
  unit: {
    label: 'Unit Belajar',
    collection: 'units',
    sheet: 'UnitBelajar',
    idField: 'unit_id',
    labelField: 'nama',
    fields: ['unit_id', 'nama', 'konteks', 'imageUrl', 'urutan', 'status'],
    numericFields: ['urutan'],
  },
  lesson: {
    label: 'Lesson / Langkah Roadmap',
    collection: 'lessons',
    sheet: 'Lesson',
    idField: 'lesson_id',
    labelField: 'judul',
    fields: ['lesson_id', 'unit_id', 'judul', 'target_aspek', 'urutan', 'unlock_rule', 'status', 'blocks'],
    numericFields: ['urutan'],
    // unit_id diambil sebagai dropdown dari tipe 'unit'
    relationFields: { unit_id: 'unit' },
    // unlock_rule & status ditampilkan sebagai dropdown pilihan tetap
    enumFields: { unlock_rule: ['always_unlocked', 'prev_completed'] },
    // 'blocks' disimpan sebagai teks JSON di sheet, diurai jadi array saat sync ke Firestore
    jsonFields: ['blocks'],
    // skema blok konten: tipe -> daftar field (dipakai editor blok di dashboard)
    // Tiap blok = satu halaman di app; jumlah & urutan blok bebas.
    // 'opsi' kuis: tulis opsi dipisah baris (Enter); jawaban = indeks (0=A).
    // Blok kuis ganda: tambahkan lebih dari satu blok kuis (masing-masing 1 halaman).
    blockTypes: {
      teks: ['judul', 'isi'],
      materi: ['judul', 'isi'],
      video: ['judul', 'url'],
      gambar: ['judul', 'gambar'],
      kuis: ['pertanyaan', 'opsi', 'jawaban'],
    },
  },
  dailyChallenge: {
    label: 'Daily Challenge',
    collection: 'cms_daily_challenge',
    sheet: 'DailyChallenge',
    idField: 'id',
    fields: ['id', 'pertanyaan', 'opsiA', 'opsiB', 'opsiC', 'jawaban', 'imageUrl', 'status'],
    numericFields: [],
  },
  onboarding: {
    label: 'Onboarding / Roadmap',
    collection: 'cms_onboarding',
    sheet: 'Onboarding',
    idField: 'id',
    fields: ['id', 'judul', 'deskripsi', 'imageUrl', 'urutan', 'status'],
    numericFields: ['urutan'],
  },
};

export const typeKeys = Object.keys(contentTypes);

export function getType(key) {
  return contentTypes[key];
}
