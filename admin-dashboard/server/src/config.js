import fs from 'node:fs';
import path from 'node:path';
import dotenv from 'dotenv';
import { google } from 'googleapis';
import admin from 'firebase-admin';

dotenv.config();

// ---------- Lokasi kredensial ----------
// Didukung DUA metode autentikasi (pilih salah satu):
//   A. Service Account JSON  -> credentials/service-account.json
//      (mungkin diblokir Organization Policy: "Disable service account key creation")
//   B. OAuth akun Google     -> credentials/oauth-client.json + credentials/oauth-token.json
//      (dibuat lewat `npm run auth`. TIDAK diblokir policy service account.)
// Jika keduanya ada, service account dipakai lebih dulu.
const CRED_DIR = path.join(process.cwd(), 'credentials');
const SA_PATH =
  process.env.GOOGLE_SERVICE_ACCOUNT_JSON || path.join(CRED_DIR, 'service-account.json');
const OAUTH_CLIENT_PATH =
  process.env.OAUTH_CLIENT_PATH || path.join(CRED_DIR, 'oauth-client.json');
const OAUTH_TOKEN_PATH =
  process.env.OAUTH_TOKEN_PATH || path.join(CRED_DIR, 'oauth-token.json');

export const SCOPES = [
  // Scope penuh agar bisa upload ke folder Drive yang sudah ada (metode OAuth user).
  'https://www.googleapis.com/auth/drive',
  'https://www.googleapis.com/auth/spreadsheets',
  // Dibutuhkan Firebase Admin (access token cloud-platform) saat memakai OAuth user.
  'https://www.googleapis.com/auth/cloud-platform',
  'https://www.googleapis.com/auth/userinfo.email',
];

function readJson(p) {
  return JSON.parse(fs.readFileSync(p, 'utf-8'));
}
const hasServiceAccount = () => fs.existsSync(SA_PATH);
const hasOAuth = () => fs.existsSync(OAUTH_CLIENT_PATH) && fs.existsSync(OAUTH_TOKEN_PATH);

function oauthClientCreds() {
  const raw = readJson(OAUTH_CLIENT_PATH);
  return raw.installed || raw.web || raw;
}

// ---------- Google (Drive + Sheets) ----------
let _auth;
export function getAuth() {
  if (_auth) return _auth;

  if (hasServiceAccount()) {
    const keys = readJson(SA_PATH);
    _auth = new google.auth.GoogleAuth({ credentials: keys, scopes: SCOPES });
    return _auth;
  }

  if (hasOAuth()) {
    const creds = oauthClientCreds();
    const client = new google.auth.OAuth2(
      creds.client_id,
      creds.client_secret,
      creds.redirect_uris?.[0]
    );
    client.setCredentials(readJson(OAUTH_TOKEN_PATH));
    _auth = client;
    return _auth;
  }

  throw new Error(
    'Belum ada kredensial Google. Jalankan `npm run auth` untuk otorisasi OAuth, ' +
      'atau taruh service-account.json di folder credentials/.'
  );
}

export async function getDrive() {
  const auth = getAuth();
  return google.drive({ version: 'v3', auth });
}

export async function getSheets() {
  const auth = getAuth();
  return google.sheets({ version: 'v4', auth });
}

// Folder Google Drive (ID) tempat gambar disimpan. Opsional.
export const DRIVE_FOLDER_ID = process.env.DRIVE_FOLDER_ID || '';

// ID Spreadsheet (bagian setelah /d/ pada URL spreadsheet).
export const SPREADSHEET_ID = process.env.SPREADSHEET_ID || '';

// ---------- Firebase Admin ----------
let _fbReady = false;
export function getFirebase() {
  if (_fbReady) return admin;
  if (admin.apps.length) {
    _fbReady = true;
    return admin;
  }

  if (hasServiceAccount()) {
    const keys = readJson(SA_PATH); // service account yg sama dipakai untuk Firebase Admin
    admin.initializeApp({
      credential: admin.credential.cert({
        projectId: keys.project_id,
        clientEmail: keys.client_email,
        privateKey: keys.private_key.replace(/\\n/g, '\n'),
      }),
    });
    _fbReady = true;
    return admin;
  }

  if (hasOAuth()) {
    // Pakai Application Default Credentials yang menunjuk ke oauth-token.json
    // (format authorized_user). Firestore menolak credential.refreshToken(),
    // tapi menerima ADC authorized_user — sama seperti `gcloud auth application-default login`.
    const token = readJson(OAUTH_TOKEN_PATH);
    const projectId =
      process.env.FIREBASE_PROJECT_ID || token.quota_project_id || undefined;
    process.env.GOOGLE_APPLICATION_CREDENTIALS = OAUTH_TOKEN_PATH;

    admin.initializeApp({
      credential: admin.credential.applicationDefault(),
      ...(projectId ? { projectId } : {}),
    });
    _fbReady = true;
    return admin;
  }

  throw new Error(
    'Belum ada kredensial untuk Firebase Admin. Jalankan `npm run auth` atau sediakan service-account.json.'
  );
}

export function fireStore() {
  return getFirebase().firestore();
}

// Collection penanda akun admin (dokumen per UID).
export const ADMIN_COLLECTION = process.env.ADMIN_COLLECTION || 'cms_admins';
