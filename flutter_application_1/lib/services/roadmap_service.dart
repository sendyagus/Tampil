import 'package:cloud_firestore/cloud_firestore.dart';

// Model Modul Belajar (dulu bernama "unit")
class ModulModel {
  final String id;
  final String modulId;
  final String nama;
  final String konteks;
  final int urutan;
  final String status;

  ModulModel({
    required this.id,
    required this.modulId,
    required this.nama,
    required this.konteks,
    required this.urutan,
    required this.status,
  });

  factory ModulModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ModulModel(
      id: doc.id,
      modulId: (data['modul_id'] ?? data['unit_id'] ?? '').toString(),
      nama: data['nama'] ?? '',
      konteks: data['konteks'] ?? '',
      urutan: data['urutan'] is int ? data['urutan'] : 1,
      status: data['status'] ?? 'draft',
    );
  }
}

// Model Lesson Belajar
class LessonModel {
  final String id;
  final String lessonId;
  final String modulId;
  final String judul;
  final int urutan;
  final String targetAspek;
  final String unlockRule;
  final String status;
  final List<dynamic> blocks;

  LessonModel({
    required this.id,
    required this.lessonId,
    required this.modulId,
    required this.judul,
    required this.urutan,
    required this.targetAspek,
    required this.unlockRule,
    required this.status,
    this.blocks = const [],
  });

  factory LessonModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return LessonModel(
      id: doc.id,
      lessonId: data['lesson_id'] ?? '',
      modulId: (data['modul_id'] ?? data['unit_id'] ?? '').toString(),
      judul: data['judul'] ?? '',
      urutan: data['urutan'] is int ? data['urutan'] : 1,
      targetAspek: data['target_aspek'] ?? '',
      unlockRule: data['unlock_rule'] ?? 'prev_completed',
      status: data['status'] ?? 'draft',
      blocks: (data['blocks'] is List)
          ? List<dynamic>.from(data['blocks'] as List)
          : const [],
    );
  }

  /// Daftar blok konten lesson (materi/video/kuis) siap pakai.
  List<LessonBlock> get blockList =>
      blocks.map(LessonBlock.fromMap).where((b) => b.tipe.isNotEmpty).toList();
}

/// Satu blok konten lesson yang dibuat admin lewat dashboard CMS.
class LessonBlock {
  final String tipe; // teks | materi | video | gambar | kuis
  final Map<String, dynamic> data;

  LessonBlock(this.tipe, this.data);

  factory LessonBlock.fromMap(dynamic m) {
    final map = (m is Map)
        ? Map<String, dynamic>.from(m)
        : <String, dynamic>{};
    // Migrasi blok lama format kuis: opsiA/opsiB/opsiC -> list 'opsi'.
    if (map['tipe'] == 'kuis' &&
        map['opsi'] == null &&
        (map['opsiA'] != null || map['opsiB'] != null || map['opsiC'] != null)) {
      map['opsi'] = [
        map['opsiA'],
        map['opsiB'],
        map['opsiC'],
      ].where((o) => o != null && o.toString().isNotEmpty).join('\n');
    }
    return LessonBlock((map['tipe'] ?? '').toString(), map);
  }

  String str(String key) => (data[key] ?? '').toString();
  int get intVal => int.tryParse((data['jawaban'] ?? '0').toString()) ?? 0;

  /// Opsi kuis: dipisah baris; fallback ke list Firestore langsung.
  List<String> get opsiList {
    final raw = data['opsi'];
    List<String> list;
    if (raw is List) {
      list = raw.map((e) => e.toString().trim()).toList();
    } else {
      list = raw
          .toString()
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return list.length >= 2 ? list : const [];
  }
}

class RoadmapService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mengambil daftar Modul yang berstatus published (disortir di memori tanpa perlu index Firebase)
  Future<List<ModulModel>> getPublishedModuls() async {
    try {
      final snapshot = await _firestore
          .collection('modul')
          .where('status', isEqualTo: 'published')
          .get();

      final list = snapshot.docs
          .map((doc) => ModulModel.fromFirestore(doc))
          .toList();
      list.sort((a, b) => a.urutan.compareTo(b.urutan));
      return list;
    } catch (e) {
      print('Error get moduls: $e');
      return [];
    }
  }

  // Mengambil SEMUA lesson published lintas modul (untuk menghitung total
  // lesson & mengelompokkan lesson per modul di layar Roadmap).
  Future<List<LessonModel>> getPublishedLessons() async {
    try {
      final snapshot = await _firestore
          .collection('lessons')
          .where('status', isEqualTo: 'published')
          .get();

      final list = snapshot.docs
          .map((doc) => LessonModel.fromFirestore(doc))
          .toList();
      list.sort((a, b) {
        final byModul = a.modulId.compareTo(b.modulId);
        return byModul != 0 ? byModul : a.urutan.compareTo(b.urutan);
      });
      return list;
    } catch (e) {
      print('Error get all lessons: $e');
      return [];
    }
  }

  // ================= REALTIME (STREAM) =================
  // Versi stream dipakai layar Roadmap agar data baru dari dashboard CMS
  // (Sheet -> Sync -> Firestore) LANGSUNG tampil tanpa restart aplikasi.
  // Disortir di memori, tanpa orderBy, sehingga tidak butuh index Firebase.

  /// Stream daftar modul published, tersortir `urutan`.
  Stream<List<ModulModel>> watchPublishedModuls() {
    return _firestore
        .collection('modul')
        .where('status', isEqualTo: 'published')
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map((doc) => ModulModel.fromFirestore(doc))
              .toList();
          list.sort((a, b) => a.urutan.compareTo(b.urutan));
          return list;
        });
  }

  /// Stream SEMUA lesson published lintas modul, tersortir modul lalu urutan.
  Stream<List<LessonModel>> watchPublishedLessons() {
    return _firestore
        .collection('lessons')
        .where('status', isEqualTo: 'published')
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map((doc) => LessonModel.fromFirestore(doc))
              .toList();
          list.sort((a, b) {
            final byModul = a.modulId.compareTo(b.modulId);
            return byModul != 0 ? byModul : a.urutan.compareTo(b.urutan);
          });
          return list;
        });
  }

  // Mengambil daftar Lesson berdasarkan Modul (disortir di memori tanpa perlu index Firebase)
  Future<List<LessonModel>> getLessonsByModul(String modulId) async {
    try {
      final snapshot = await _firestore
          .collection('lessons')
          .where('modul_id', isEqualTo: modulId)
          .where('status', isEqualTo: 'published')
          .get();

      final list = snapshot.docs
          .map((doc) => LessonModel.fromFirestore(doc))
          .toList();
      list.sort((a, b) => a.urutan.compareTo(b.urutan));
      return list;
    } catch (e) {
      print('Error get lessons: $e');
      return [];
    }
  }

  // ==============================================================
  // SEEDER OTOMATIS: Mengisi 3 Modul & 15 Lesson Sesuai PRD ke Firestore
  // ==============================================================
  Future<void> seedInitialData() async {
    try {
      final modulCol = _firestore.collection('modul');
      final lessonCol = _firestore.collection('lessons');

      // 1. Cek jika data modul sudah ada agar tidak duplikat
      final existingModuls = await modulCol.limit(1).get();
      if (existingModuls.docs.isNotEmpty) {
        print('Database modul & lessons sudah terisi sebelumnya!');
        return;
      }

      print('Sedang mengisi database modul & lessons ke Firestore...');

      // 2. Daftar 3 Modul sesuai PRD Halaman 11
      final moduls = [
        {
          'modul_id': 'modul_01',
          'nama': 'Daily Communication',
          'konteks': 'Percakapan sehari-hari',
          'urutan': 1,
          'status': 'published',
        },
        {
          'modul_id': 'modul_02',
          'nama': 'Peer Communication',
          'konteks': 'Diskusi dan kerja kelompok',
          'urutan': 2,
          'status': 'published',
        },
        {
          'modul_id': 'modul_03',
          'nama': 'Public Speaking',
          'konteks': 'Presentasi kelas dan organisasi',
          'urutan': 3,
          'status': 'published',
        },
      ];

      for (var m in moduls) {
        await modulCol.doc(m['modul_id'] as String).set(m);
      }

      // 3. Daftar 5 Aspek Lesson sesuai PRD Halaman 11 & 14
      final aspekList = [
        {'judul': 'Kelancaran Jeda Berbicara', 'aspek': 'Kelancaran jeda'},
        {
          'judul': 'Kebersihan Ucapan (Minimalisir Filler Words)',
          'aspek': 'Kebersihan ucapan',
        },
        {'judul': 'Pengaturan Tempo Bicara (WPM)', 'aspek': 'Tempo'},
        {'judul': 'Penyampaian Cakupan Poin Penting', 'aspek': 'Cakupan isi'},
        {
          'judul': 'Struktur Komunikasi (Pembuka & Penutup)',
          'aspek': 'Struktur',
        },
      ];

      // Buat 5 lesson untuk masing-masing modul (total 15 lesson)
      for (var m in moduls) {
        final modulId = m['modul_id'] as String;
        for (int i = 0; i < aspekList.length; i++) {
          final lessonId = '${modulId}_lesson_0${i + 1}';
          await lessonCol.doc(lessonId).set({
            'lesson_id': lessonId,
            'modul_id': modulId,
            'judul': aspekList[i]['judul'],
            'urutan': i + 1,
            'target_aspek': aspekList[i]['aspek'],
            'unlock_rule': i == 0 ? 'always_unlocked' : 'prev_completed',
            'status': 'published',
          });
        }
      }

      print(
        '🎉 SUKSES! 3 Modul dan 15 Lesson berhasil masuk ke Cloud Firestore!',
      );
    } catch (e) {
      print('❌ Gagal seeder Firestore: $e');
    }
  }
}
