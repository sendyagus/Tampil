# flutter_application_1

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)   

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Alur Autentikasi

1. **Daftar email & kata sandi** → Register → Consent (Terms & Privacy) → akun
   dibuat, sesi langsung ditutup, lalu diarahkan ke **halaman Login** dengan
   email sudah terisi. User masuk sendiri untuk ke beranda.
2. **Daftar / login dengan Google** (pengecualian) → begitu akun Google terpilih
   dan token valid, user **langsung masuk ke halaman Beranda**. Username di
   Firestore (`users/{uid}.nama`) diambil dari nama akun Google.

### Login Google per platform

- **Web**: memakai popup Firebase (`signInWithPopup`).
- **Android / iOS / macOS**: memakai plugin `google_sign_in` (popup Firebase
  tidak didukung native), ID token-nya ditukar ke
  `GoogleAuthProvider.credential`.

Konfigurasi Firebase/GCP Console (proyek `tampil-a0b91`) - status saat ini:

1. Authentication -> **Sign-in method** -> provider **Google**: sudah **Enabled**.
2. Android: SHA-1 debug sudah didaftarkan di Project settings -> Your apps ->
   `flutter_application_1` (package `com.example.flutter_application_1`), sehingga
   `android/app/google-services.json` kini memuat `oauth_client` (tipe Android +
   Web). Build release memakai signing config debug, jadi satu SHA-1 ini cukup.
   SHA-1 baru didapat dari:
   `keytool -list -v -alias androiddebugkey -keystore %USERPROFILE%\.android\debug.keystore -storepass android`
   (keytool ada di `C:\Program Files\Android\Android Studio\jbr\bin`).
3. Android: **OAuth client ID "Web application"** project `886237187383`
   (`client_type: 3` di google-services.json) sudah diisi ke
   `GOOGLE_SERVER_CLIENT_ID` di file `.env`.
4. iOS: BELUM dikonfigurasi. `firebase_options.dart` blok `ios` masih menunjuk
   project lain, jadi login Google di iOS perlu `flutterfire configure` ulang
   plus `GIDClientID` dan `CFBundleURLTypes` di `ios/Runner/Info.plist`.

Ganti fingerprint/keystore = ulangi langkah 2 dan 3, lalu **full rebuild**
(`flutter clean` lalu `flutter run`), karena `google-services.json` dan aset `.env`
 dibaca saat build, bukan saat hot reload.

