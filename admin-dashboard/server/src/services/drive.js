import { Readable } from 'node:stream';
import { getDrive, DRIVE_FOLDER_ID } from '../config.js';

// Upload gambar ke Google Drive lewat service account, jadikan
// "siapa saja dengan link" bisa melihat, lalu kembalikan link yang
// bisa langsung dipakai <img>/NetworkImage di aplikasi.
export async function uploadImage(fileBuffer, mimeType, originalName = 'image') {
  const drive = await getDrive();

  const ext = (originalName.match(/\.[a-zA-Z0-9]+$/) || ['.jpg'])[0];
  const safe = originalName.replace(/\.[a-zA-Z0-9]+$/, '').replace(/[^\w-]+/g, '_');
  const name = `tampil-cms/${Date.now()}_${safe}${ext}`;

  const media = {
    mimeType: mimeType || 'image/jpeg',
    body: Readable.from(fileBuffer),
  };

  const body = { name };
  if (DRIVE_FOLDER_ID) body.parents = [DRIVE_FOLDER_ID];

  const res = await drive.files.create({
    requestBody: body,
    media,
    fields: 'id,webViewLink',
  });

  const fileId = res.data.id;

  // Beri akses publik lewat link agar gambar tampil online di aplikasi.
  try {
    await drive.permissions.create({
      fileId,
      requestBody: { role: 'reader', type: 'anyone' },
    });
  } catch (e) {
    console.warn('Gagal set permission publik:', e.message);
  }

  return {
    fileId,
    viewLink: res.data.webViewLink || `https://drive.google.com/file/d/${fileId}/view`,
    // Link ini me-render gambar secara langsung.
    imageUrl: `https://lh3.googleusercontent.com/d/${fileId}`,
  };
}
