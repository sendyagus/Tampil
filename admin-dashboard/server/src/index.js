import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import cmsRouter from './routes/cms.js';
import { SPREADSHEET_ID } from './config.js';

dotenv.config();

const app = express();

app.use(
  cors({
    origin: process.env.CLIENT_ORIGIN || 'http://localhost:5173',
  })
);
app.use(express.json({ limit: '2mb' }));

app.get('/api/health', (req, res) => {
  res.json({
    ok: true,
    service: 'tampil-cms-server',
    spreadsheetConfigured: Boolean(SPREADSHEET_ID),
  });
});

app.use('/api', cmsRouter);

// Penanganan error terpusat.
app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ error: err.message || 'Terjadi kesalahan' });
});

const PORT = process.env.PORT || 4000;
app.listen(PORT, () => {
  console.log(`🚀 CMS server berjalan di http://localhost:${PORT}`);
  if (!SPREADSHEET_ID) console.warn('⚠️  SPREADSHEET_ID belum diisi di .env');
});
