import 'package:cloud_firestore/cloud_firestore.dart';

/// Model konten yang dikelola lewat dashboard CMS (React).
/// Data aslinya disimpan di Google Spreadsheet, lalu disinkronkan ke
/// Firestore oleh backend CMS. Aplikasi ini hanya membaca dari Firestore.
class CmsContent {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String ctaText;
  final int urutan;
  final String status;

  CmsContent({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.ctaText,
    required this.urutan,
    required this.status,
  });

  factory CmsContent.fromDoc(DocumentSnapshot doc) {
    final d = (doc.data() as Map<String, dynamic>?) ?? {};
    // Field judul bisa bernama 'title', 'nama', atau 'judul' tergantung tipe.
    final title = (d['title'] ?? d['nama'] ?? d['judul'] ?? d['pertanyaan'] ?? '')
        as String;
    final subtitle =
        (d['subtitle'] ?? d['konteks'] ?? d['deskripsi'] ?? '') as String;
    return CmsContent(
      id: doc.id,
      title: title,
      subtitle: subtitle,
      imageUrl: (d['imageUrl'] ?? '') as String,
      ctaText: (d['ctaText'] ?? '') as String,
      urutan: d['urutan'] is int ? d['urutan'] as int : int.tryParse('${d['urutan']}') ?? 0,
      status: (d['status'] ?? 'published') as String,
    );
  }
}

/// Layanan baca konten CMS dari Firestore (real-time stream).
class CmsContentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Collection Firestore per tipe konten (harus sama dengan backend CMS).
  static const heroCollection = 'cms_hero';
  static const dailyChallengeCollection = 'cms_daily_challenge';
  static const onboardingCollection = 'cms_onboarding';

  Stream<List<CmsContent>> _streamPublished(String collection) {
    return _firestore
        .collection(collection)
        .snapshots()
        .map((snap) {
          final list = snap.docs.map((d) => CmsContent.fromDoc(d)).toList();
          list.removeWhere((c) => c.status != 'published');
          list.sort((a, b) => a.urutan.compareTo(b.urutan));
          return list;
        });
  }

  /// Daftar banner/hero yang sudah publish, terurut.
  Stream<List<CmsContent>> watchHero() => _streamPublished(heroCollection);

  /// Banner hero pertama (untuk satu kartu di beranda). Null jika kosong.
  Future<CmsContent?> getFirstHero() async {
    try {
      final snap = await _firestore
          .collection(heroCollection)
          .where('status', isEqualTo: 'published')
          .limit(5)
          .get();
      if (snap.docs.isEmpty) return null;
      final list = snap.docs.map((d) => CmsContent.fromDoc(d)).toList();
      list.sort((a, b) => a.urutan.compareTo(b.urutan));
      return list.first;
    } catch (e) {
      return null;
    }
  }

  Stream<List<CmsContent>> watchDailyChallenge() =>
      _streamPublished(dailyChallengeCollection);

  Stream<List<CmsContent>> watchOnboarding() =>
      _streamPublished(onboardingCollection);
}
