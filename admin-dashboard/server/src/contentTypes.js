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
  modul: {
    label: 'Modul Belajar',
    collection: 'modul',
    sheet: 'ModulBelajar',
    idField: 'modul_id',
    labelField: 'nama',
    fields: ['modul_id', 'nama', 'konteks', 'imageUrl', 'urutan', 'status'],
    numericFields: ['urutan'],
    fieldLabels: { modul_id: 'ID Modul', nama: 'Nama Modul', konteks: 'Konteks' },
    // modul_id berikutnya diisi otomatis: modul_01, modul_02, dst.
    autoId: { field: 'modul_id', template: 'modul_{number}', pad: 2 },
    // 'urutan' ikut terisi otomatis (tanpa grup: penomoran global).
    autoNumber: { field: 'urutan' },
  },
  lesson: {
    label: 'Lesson / Langkah Roadmap',
    collection: 'lessons',
    sheet: 'Lesson',
    idField: 'lesson_id',
    labelField: 'judul',
    fields: ['lesson_id', 'modul_id', 'judul', 'target_aspek', 'urutan', 'unlock_rule', 'status', 'blocks'],
    numericFields: ['urutan'],
    // Urutan kolom sheet TIDAK diubah (header lama harus tetap cocok), tapi di
    // form admin modul dipilih lebih dulu lalu lesson_id di bawahnya.
    formOrder: ['modul_id', 'lesson_id', 'judul', 'target_aspek', 'urutan', 'unlock_rule', 'status'],
    // modul_id diambil sebagai dropdown dari tipe 'modul'
    relationFields: { modul_id: 'modul' },
    // lesson_id otomatis: <modul_id>_lesson_<nomor>, nomornya dihitung dari
    // lesson yang sudah ada pada modul terpilih (modul_01 sudah 3 lesson -> 04).
    autoId: {
      field: 'lesson_id',
      groupField: 'modul_id',
      template: '{group}_lesson_{number}',
      pad: 2,
    },
    // 'urutan' ikut terisi: nomor terakhir di modul yang sama + 1.
    autoNumber: { field: 'urutan', groupField: 'modul_id' },
    // unlock_rule otomatis: lesson pertama di sebuah modul selalu terbuka,
    // lesson berikutnya menunggu lesson sebelumnya selesai.
    autoDefaults: {
      unlock_rule: {
        groupField: 'modul_id',
        first: 'always_unlocked',
        following: 'prev_completed',
      },
    },
    fieldLabels: {
      lesson_id: 'ID Lesson',
      modul_id: 'Modul',
      judul: 'Judul Lesson',
      target_aspek: 'Target Aspek',
      urutan: 'Urutan',
      unlock_rule: 'Aturan Buka',
    },
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
