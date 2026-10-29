// Otorisasi sekali (OAuth "Desktop app") untuk backend CMS TAMPIL.
//
// Prasyarat:
//   1. Google Cloud Console -> APIs & Services -> Credentials
//      -> Create credentials -> OAuth client ID -> tipe "Desktop app".
//   2. Unduh JSON-nya, simpan sebagai credentials/oauth-client.json
//      (atau salin isinya ke file itu).
//   3. Jalankan:  npm run auth
//      Browser terbuka -> login akun Google pemilik project -> Allow.
//      Refresh token disimpan ke credentials/oauth-token.json.
import fs from 'node:fs';
import path from 'node:path';
import http from 'node:http';
import { google } from 'googleapis';
import dotenv from 'dotenv';

dotenv.config();

const CRED_DIR = path.join(process.cwd(), 'credentials');
const CLIENT_PATH = process.env.OAUTH_CLIENT_PATH || path.join(CRED_DIR, 'oauth-client.json');
const TOKEN_PATH = process.env.OAUTH_TOKEN_PATH || path.join(CRED_DIR, 'oauth-token.json');
const PORT = Number(process.env.OAUTH_REDIRECT_PORT || 8080);
const REDIRECT = `http://localhost:${PORT}`;

const SCOPES = [
  'https://www.googleapis.com/auth/drive',
  'https://www.googleapis.com/auth/spreadsheets',
  'https://www.googleapis.com/auth/cloud-platform',
  'https://www.googleapis.com/auth/userinfo.email',
];

if (!fs.existsSync(CLIENT_PATH)) {
  console.error(
    '\n❌ Tidak menemukan file client OAuth:\n   ' + CLIENT_PATH +
      '\n\nBuat OAuth Client "Desktop app" di Google Cloud, lalu simpan JSON unduhannya ke path di atas.'
  );
  process.exit(1);
}

const raw = JSON.parse(fs.readFileSync(CLIENT_PATH, 'utf-8'));
const creds = raw.installed || raw.web || raw;
if (!creds.client_id || !creds.client_secret) {
  console.error('\n❌ oauth-client.json tidak punya client_id/client_secret yang valid.');
  process.exit(1);
}

const oauth2 = new google.auth.OAuth2(creds.client_id, creds.client_secret, REDIRECT);

const authUrl = oauth2.generateAuthUrl({
  access_type: 'offline',
  prompt: 'consent', // paksakan refresh_token dikembalikan
  scope: SCOPES,
});

console.log('\n=== Otorisasi OAuth TAMPIL CMS ===');
console.log('Redirect URI yang HARUS terdaftar di client OAuth:\n   ' + REDIRECT);
console.log('\nBuka URL berikut di browser:\n\n' + authUrl + '\n');

const server = http.createServer(async (req, res) => {
  const u = new URL(req.url, REDIRECT);
  if (u.pathname !== '/') return;

  const err = u.searchParams.get('error');
  if (err) {
    res.writeHead(400, { 'content-type': 'text/plain; charset=utf-8' });
    res.end('Gagal: ' + err);
    console.error('\n❌ Otorisasi gagal:', err);
    server.close();
    process.exit(1);
  }

  const code = u.searchParams.get('code');
  if (!code) {
    res.writeHead(200, { 'content-type': 'text/plain; charset=utf-8' });
    res.end('Menunggu kode otorisasi...');
    return;
  }

  try {
    const { tokens } = await oauth2.getToken(code);
    const out = {
      type: 'authorized_user',
      client_id: creds.client_id,
      client_secret: creds.client_secret,
      refresh_token: tokens.refresh_token,
      scope: tokens.scope,
    };
    if (creds.project_id) out.quota_project_id = creds.project_id;

    fs.writeFileSync(TOKEN_PATH, JSON.stringify(out, null, 2));
    res.writeHead(200, { 'content-type': 'text/plain; charset=utf-8' });
    res.end('✅ Otorisasi berhasil! Token tersimpan. Tutup tab ini dan kembali ke terminal.');
    console.log('\n✅ Refresh token disimpan di:\n   ' + TOKEN_PATH);
    console.log('\nSekarang jalankan server:  npm run dev');
    server.close();
    setTimeout(() => process.exit(0), 500);
  } catch (e) {
    res.writeHead(500, { 'content-type': 'text/plain; charset=utf-8' });
    res.end('Gagal menukar kode: ' + e.message);
    console.error('\n❌ Gagal menukar kode ke token:', e.message);
  }
});

server.listen(PORT, () => {
  console.log('\nMenunggu callback di ' + REDIRECT + ' ... (tekan Ctrl+C untuk batal)');
});
