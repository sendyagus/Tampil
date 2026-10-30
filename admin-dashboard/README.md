# TAMPIL — Admin Dashboard CMS

Dashboard admin berbasis **React (Web)** untuk mengelola konten aplikasi Flutter
**TAMPIL**. Konten disimpan di **Google Spreadsheet**, gambar diunggah ke
**Google Drive**, lalu otomatis disinkronkan ke **Firebase Firestore** agar
tampil secara real-time di aplikasi.

```
Admin (React)  ──upload gambar──►  Google Drive  ──link──┐
      │                                                    │
      └─────────── CRUD konten ─────────────►  Google Spreadsheet
                                                   │  (baris + link gambar)
                                                   ▼
                                     Backend CMS (Node/Express)
                                                   │  sync otomatis
                                                   ▼
                                          Firestore  ──►  Aplikasi Flutter
```

- **Spreadsheet** = sumber data (teks + link gambar Drive).
- **Drive** = penyimpanan file gambar.
- **Firestore** = dibaca aplikasi Flutter (real-time `StreamBuilder`).
- **Backend** = menyimpan kredensial Google (service account) agar tidak
  bocor ke browser, dan melakukan upload/CRUD/sync.

## Struktur

```
admin-dashboard/
├── server/            # Backend Node.js (Express)
│   ├── src/
│   │   ├── index.js           # entry point + CORS
│   │   ├── config.js          # load service account, Drive/Sheets/Firebase
│   │   ├── contentTypes.js    # definisi tipe konten (kolom & collection)
│   │   ├── middleware/        # requireAdmin (verifikasi token + flag admin)
│   │   ├── routes/cms.js      # API: list, save, delete, sync, upload-image
│   │   └── services/          # drive.js, sheets.js, firestore.js
│   ├── credentials/          # taruh service-account.json di sini (git-ignored)
│   └── .env.example
└── client/            # React + Vite dashboard
    └── src/
        ├── components/        # Login, Dashboard, ContentManager, ImageUpload
        ├── api.js             # pemanggilan API + token Firebase
        ├── firebase.js        # init Firebase Web
        └── authContext.jsx
```

## Tipe konten yang dikelola

| Kunci | Label | Tab Spreadsheet | Collection Firestore |
|-------|-------|-----------------|----------------------|
| `hero` | Hero Card / Banner | Hero | `cms_hero` |
| `modul` | Modul Belajar | ModulBelajar | `modul` |
| `lesson` | Lesson / Langkah Roadmap | Lesson | `lessons` |
| `dailyChallenge` | Daily Challenge | DailyChallenge | `cms_daily_challenge` |
| `onboarding` | Onboarding / Roadmap | Onboarding | `cms_onboarding` |

> `modul` & `lesson` memakai collection `modul` dan `lessons` yang dibaca aplikasi
> (lihat `lib/services/roadmap_service.dart`). Dulu tipe ini bernama `unit`
> dengan collection `units` dan tab `UnitBelajar` — sudah diganti menjadi **MODUL**.

### Konfigurasi form di `contentTypes.js`

Field tambahan di bawah opsional; semuanya hanya memengaruhi **tampilan form**,
bukan urutan kolom Spreadsheet (header lama tetap harus cocok dengan `fields`).

| Kunci | Fungsi |
|-------|--------|
| `fieldLabels` | Label ramah pengganti nama kolom (`modul_id` → "Modul"). |
| `relationFields` | Kolom jadi dropdown yang isinya diambil dari tipe lain (`modul_id: 'modul'`). |
| `enumFields` | Kolom jadi dropdown dengan pilihan tetap (`unlock_rule`, `status`). |
| `jsonFields` | Kolom teks JSON, dibuka sebagai editor blok (`blocks`). |
| `formOrder` | Urutan tampil field di form. Lesson: **modul dipilih lebih dulu**, lalu `lesson_id`. |
| `autoId` | Isi ID otomatis dari template, mis. `{group}_lesson_{number}` → `modul_01_lesson_04`. Nomornya dihitung dari data yang sudah ada pada `groupField`. |
| `autoNumber` | Isi kolom angka otomatis (`urutan` = nomor terakhir + 1). |
| `autoDefaults` | Nilai default yang mengikuti jumlah data: lesson pertama `always_unlocked`, sisanya `prev_completed`. |

Saran otomatis bisa ditimpa manual — field-nya lalu menampilkan "Saran otomatis: …"
plus tombol **Pakai otomatis**. ID yang sudah dipakai akan menimpa baris lama, jadi
dashboard meminta konfirmasi lebih dulu.

## Persiapan (satu kali)

### 1. Kredensial Google — pilih SALAH SATU metode

**Metode A — Service Account** (default)
1. Google Cloud Console → project **tampilapp** → **IAM & Admin → Service Accounts** → buat akun.
2. **Keys → Add Key → JSON** → unduh, simpan sebagai `server/credentials/service-account.json`.
3. Firebase akan memakai service account yang sama untuk **Firebase Admin SDK**.

> ⚠️ Jika muncul error **"Service account key creation is disabled"**
> (`iam.disableServiceAccountKeyCreation` dari Organization Policy), pembuatan
> kunci diblokir. Gunakan **Metode B** di bawah — tidak butuh service account key.

**Metode B — OAuth akun Google (tanpa service account key)**
1. **APIs & Services → Credentials → Create Credentials → OAuth client ID** → tipe **Desktop app**.
2. Di **Authorized redirect URIs**, tambahkan `http://localhost:8080/`. Simpan & **unduh JSON**-nya.
3. Simpan hasil unduhan sebagai `server/credentials/oauth-client.json`.
4. Pastikan **OAuth consent screen** sudah diisi; saat masih mode *Testing*, tambahkan
   email Google-mu sebagai **Test users**.
5. Aktifkan **Drive API**, **Sheets API**, dan pastikan akun tersebut punya peran
   **Owner/Editor** di project (dipakai Firebase Admin via `cloud-platform` scope).
6. Otorisasi sekali: `cd server && npm run auth` → buka URL → **Allow** → token tersimpan
   di `server/credentials/oauth-token.json`. Backend otomatis memakai OAuth bila
   `service-account.json` tidak ada.

### 2. Aktifkan API (pada project yang sama)
- **Google Drive API**
- **Google Sheets API**

### 3. Spreadsheet
1. Buat Google Spreadsheet baru, beri judul mis. `TAMPIL CMS Data`.
2. **Metode A**: bagikan spreadsheet ke **email service account** (`...@...iam.gserviceaccount.com`) sebagai **Editor**. **Metode B**: tidak perlu — spreadsheet milik akun Google yang sama.
3. Salin **SPREADSHEET_ID** dari URL (`/d/<ID>/edit`) ke `server/.env`.
4. Tab akan dibuat otomatis oleh backend saat pertama kali menyimpan.


### 4. Gambar di Drive
Backend otomatis membuat gambar dapat diakses "siapa saja dengan link" dan
menyimpan link berformat `https://lh3.googleusercontent.com/d/<FILE_ID>` ke
Spreadsheet & Firestore, sehingga langsung bisa di-render aplikasi.

### 5. Akun Admin (Firebase Auth)
1. Firebase Console → **Authentication** → tambahkan user email/password admin.
2. Firestore → buat collection `cms_admins` → tambahkan **document ber-ID = UID** admin tersebut (isi bebas, mis. `{ role: "admin" }`).
3. Hanya login dengan UID yang ada di `cms_admins` yang boleh masuk dashboard.

## Menjalankan

### Backend
```bash
cd server
npm install
# buat .env dari contoh, isi SPREADSHEET_ID (opsional DRIVE_FOLDER_ID)
Copy-Item .env.example .env
npm run dev        # http://localhost:4000
```

### Frontend
```bash
cd client
npm install
Copy-Item .env.example .env   # konfigurasi Firebase Web sudah terisi
npm run dev        # http://localhost:5173
```

Buka `http://localhost:5173`, login dengan akun admin.

## Integrasi ke Aplikasi Flutter

Sudah disiapkan:
- `lib/services/cms_content_service.dart` — baca konten CMS dari Firestore.
- `lib/presentation/widgets/home/cms_banner_widget.dart` — banner hero dari CMS.
- Ditampilkan di beranda (`home_screen.dart`).

Cara memakai di tempat lain:
```dart
final cms = CmsContentService();

StreamBuilder<List<CmsContent>>(
  stream: cms.watchDailyChallenge(),
  builder: (context, snap) { /* render snap.data */ },
);
```

Gambar ditampilkan online via `Image.network(content.imageUrl)`.

## Catatan Keamanan
- Service account JSON & `.env` **tidak** di-commit (lihat `.gitignore`).
- Kredensial Google hanya ada di backend, tidak pernah ke browser.
- Endpoint CMS dilindungi Firebase ID Token + pengecekan collection `cms_admins`.
