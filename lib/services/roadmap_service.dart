import 'package:cloud_firestore/cloud_firestore.dart';

int _readInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

String _readString(dynamic value, {String fallback = ''}) =>
    value is String ? value : fallback;

// Model modul belajar yang dikelola lewat CMS.
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
      unitId: _readString(
        data['modul_id'],
        fallback: _readString(data['unit_id'], fallback: doc.id),
      ),
      nama: _readString(data['nama']),
      konteks: _readString(data['konteks']),
      urutan: _readInt(data['urutan'], fallback: 1),
      status: _readString(data['status'], fallback: 'draft'),
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
      lessonId: _readString(data['lesson_id'], fallback: doc.id),
      unitId: _readString(
        data['modul_id'],
        fallback: _readString(data['unit_id']),
      ),
      judul: _readString(data['judul']),
      urutan: _readInt(data['urutan'], fallback: 1),
      targetAspek: _readString(data['target_aspek']),
      unlockRule: _readString(data['unlock_rule'], fallback: 'prev_completed'),
      status: _readString(data['status'], fallback: 'draft'),
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
    final map = (m is Map) ? Map<String, dynamic>.from(m) : <String, dynamic>{};
    // Migrasi blok lama format kuis: opsiA/opsiB/opsiC -> list 'opsi'.
    if (map['tipe'] == 'kuis' &&
        map['opsi'] == null &&
        (map['opsiA'] != null ||
            map['opsiB'] != null ||
            map['opsiC'] != null)) {
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

  Stream<List<UnitModel>> watchPublishedUnits() {
    return _firestore.collection('modul').snapshots().map((snapshot) {
      final units = snapshot.docs
          .map(UnitModel.fromFirestore)
          .where((unit) => unit.status == 'published')
          .toList();
      units.sort((a, b) => a.urutan.compareTo(b.urutan));
      return units;
    });
  }

  Stream<List<LessonModel>> watchPublishedLessons() {
    return _firestore.collection('lessons').snapshots().map((snapshot) {
      final lessons = snapshot.docs
          .map(LessonModel.fromFirestore)
          .where((lesson) => lesson.status == 'published')
          .toList();
      lessons.sort((a, b) {
        final byUnit = a.unitId.compareTo(b.unitId);
        return byUnit != 0 ? byUnit : a.urutan.compareTo(b.urutan);
      });
      return lessons;
    });
  }

  Future<List<UnitModel>> getPublishedUnits() => watchPublishedUnits().first;

  Future<List<LessonModel>> getPublishedLessons() =>
      watchPublishedLessons().first;

  Future<List<LessonModel>> getLessonsByUnit(String unitId) async {
    final lessons = await getPublishedLessons();
    return lessons.where((lesson) => lesson.unitId == unitId).toList()
      ..sort((a, b) => a.urutan.compareTo(b.urutan));
  }

  LessonModel? getNextAvailableLesson(
    List<LessonModel> lessons,
    Set<String> completedIds,
  ) {
    for (var i = 0; i < lessons.length; i++) {
      final lesson = lessons[i];
      if (completedIds.contains(lesson.lessonId)) continue;

      final previousCompleted =
          i == 0 || completedIds.contains(lessons[i - 1].lessonId);
      if (i == 0 ||
          lesson.unlockRule == 'always_unlocked' ||
          previousCompleted) {
        return lesson;
      }
    }
    return null;
  }
}
