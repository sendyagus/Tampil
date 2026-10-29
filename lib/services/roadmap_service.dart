import 'package:cloud_firestore/cloud_firestore.dart';

// Model Unit Belajar
class UnitModel {
  final String id;
  final String unitId;
  final String nama;
  final String konteks;
  final int urutan;
  final String status;

  UnitModel({
    required this.id,
    required this.unitId,
    required this.nama,
    required this.konteks,
    required this.urutan,
    required this.status,
  });

  factory UnitModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UnitModel(
      id: doc.id,
      unitId: data['unit_id'] ?? '',
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
  final String unitId;
  final String judul;
  final int urutan;
  final String targetAspek;
  final String unlockRule;
  final String status;
  final List<dynamic> blocks;

  LessonModel({
    required this.id,
    required this.lessonId,
    required this.unitId,
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
      unitId: data['unit_id'] ?? '',
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

  // Mengambil daftar Unit yang berstatus published (disortir di memori tanpa perlu index Firebase)
  Future<List<UnitModel>> getPublishedUnits() async {
    try {
      final snapshot = await _firestore
          .collection('units')
          .where('status', isEqualTo: 'published')
          .get();

      final list = snapshot.docs
          .map((doc) => UnitModel.fromFirestore(doc))
          .toList();
      list.sort((a, b) => a.urutan.compareTo(b.urutan));
      return list;
    } catch (e) {
      print('Error get units: $e');
      return [];
    }
  }

  // Mengambil SEMUA lesson published lintas unit (untuk menghitung total
  // lesson & mengelompokkan lesson per unit di layar Roadmap).
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
        final byUnit = a.unitId.compareTo(b.unitId);
        return byUnit != 0 ? byUnit : a.urutan.compareTo(b.urutan);
      });
      return list;
    } catch (e) {
      print('Error get all lessons: $e');
      return [];
    }
  }

  // Mengambil daftar Lesson berdasarkan Unit (disortir di memori tanpa perlu index Firebase)
  Future<List<LessonModel>> getLessonsByUnit(String unitId) async {
    try {
      final snapshot = await _firestore
          .collection('lessons')
          .where('unit_id', isEqualTo: unitId)
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
  // SEEDER OTOMATIS: Mengisi 3 Unit & 5 Lesson Sesuai PRD ke Firestore
  // ==============================================================
  Future<void> seedInitialData() async {
    try {
      final unitCol = _firestore.collection('units');
      final lessonCol = _firestore.collection('lessons');

      // 1. Cek jika data unit sudah ada agar tidak duplikat
      final existingUnits = await unitCol.limit(1).get();
      if (existingUnits.docs.isNotEmpty) {
        print('Database units & lessons sudah terisi sebelumnya!');
        return;
      }

      print('Sedang mengisi database units & lessons ke Firestore...');

      // 2. Daftar 3 Unit sesuai PRD Halaman 11
      final units = [
        {
          'unit_id': 'unit_01',
          'nama': 'Daily Communication',
          'konteks': 'Percakapan sehari-hari',
          'urutan': 1,
          'status': 'published',
        },
        {
          'unit_id': 'unit_02',
          'nama': 'Peer Communication',
          'konteks': 'Diskusi dan kerja kelompok',
          'urutan': 2,
          'status': 'published',
        },
        {
          'unit_id': 'unit_03',
          'nama': 'Public Speaking',
          'konteks': 'Presentasi kelas dan organisasi',
          'urutan': 3,
          'status': 'published',
        },
      ];

      for (var u in units) {
        await unitCol.doc(u['unit_id'] as String).set(u);
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

      // Buat 5 lesson untuk masing-masing unit (total 15 lesson)
      for (var u in units) {
        final unitId = u['unit_id'] as String;
        for (int i = 0; i < aspekList.length; i++) {
          final lessonId = '${unitId}_lesson_0${i + 1}';
          await lessonCol.doc(lessonId).set({
            'lesson_id': lessonId,
            'unit_id': unitId,
            'judul': aspekList[i]['judul'],
            'urutan': i + 1,
            'target_aspek': aspekList[i]['aspek'],
            'unlock_rule': i == 0 ? 'always_unlocked' : 'prev_completed',
            'status': 'published',
          });
        }
      }

      print(
        '🎉 SUKSES! 3 Unit dan 15 Lesson berhasil masuk ke Cloud Firestore!',
      );
    } catch (e) {
      print('❌ Gagal seeder Firestore: $e');
    }
  }
}
