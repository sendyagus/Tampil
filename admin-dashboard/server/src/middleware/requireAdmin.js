import { getFirebase, fireStore, ADMIN_COLLECTION } from '../config.js';

// Middleware: wajib login Firebase (ID token) + terdaftar sebagai admin.
export async function requireAdmin(req, res, next) {
  try {
    const header = req.headers.authorization || '';
    const token = header.startsWith('Bearer ') ? header.slice(7) : null;
    if (!token) return res.status(401).json({ error: 'Token tidak ada. Silakan login.' });

    const decoded = await getFirebase().auth().verifyIdToken(token);
    const adminDoc = await fireStore().collection(ADMIN_COLLECTION).doc(decoded.uid).get();
    if (!adminDoc.exists) {
      return res.status(403).json({ error: 'Akun ini bukan admin yang terdaftar.' });
    }
    req.user = decoded;
    next();
  } catch (e) {
    return res.status(401).json({ error: 'Token tidak valid: ' + e.message });
  }
}
