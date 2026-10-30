import 'package:flutter_test/flutter_test.dart';

import 'package:tampil/services/auth_service.dart';
import 'package:tampil/services/home_service.dart';
import 'package:tampil/services/roadmap_service.dart';
import 'package:tampil/services/test_session_service.dart';

ModulModel _modul(String id, int urutan) => ModulModel(
  id: id,
  modulId: id,
  nama: 'Modul $urutan',
  konteks: '',
  urutan: urutan,
  status: 'published',
);

LessonModel _lesson(String id, String modulId, int urutan, {String? judul}) =>
    LessonModel(
      id: id,
      lessonId: id,
      modulId: modulId,
      judul: judul ?? 'Lesson $urutan',
      urutan: urutan,
      targetAspek: 'Kelancaran jeda',
      unlockRule: urutan == 1 ? 'always_unlocked' : 'prev_completed',
      status: 'published',
    );

LessonProgress _progress(
  String lessonId,
  String modulId,
  DateTime at, {
  int xp = 10,
}) => LessonProgress(
  lessonId: lessonId,
  modulId: modulId,
  xp: xp,
  completedAt: at,
);

TestSessionModel _tes(String caseId, num ci, DateTime at) => TestSessionModel(
  id: at.millisecondsSinceEpoch.toString(),
  sessionId: 'ses_$caseId',
  userId: 'u1',
  caseId: caseId,
  tipe: 'test',
  durasiBicara: 45,
  communicationIndex: ci,
  kategoriSkor: 'Baik',
  transcript: '',
  status: 'completed',
  createdAt: at,
);

void main() {
  final hariIni = DateTime.now();
  final kemarin = hariIni.subtract(const Duration(days: 1));

  group('HomeSnapshot - lanjut lesson', () {
    test('nextLesson = lesson pertama yang belum selesai', () {
      final snapshot = HomeSnapshot(
        moduls: [_modul('modul_01', 1)],
        lessons: [
          _lesson('modul_01_lesson_01', 'modul_01', 1),
          _lesson('modul_01_lesson_02', 'modul_01', 2),
          _lesson('modul_01_lesson_03', 'modul_01', 3),
        ],
        progress: [_progress('modul_01_lesson_01', 'modul_01', kemarin)],
        ready: true,
      );

      expect(snapshot.completedInModul, 1);
      expect(snapshot.nextLesson?.lessonId, 'modul_01_lesson_02');
      expect(snapshot.lastCompletedLesson?.lessonId, 'modul_01_lesson_01');
      expect(snapshot.modulCompleted, isFalse);
    });

    test('semua lesson selesai -> nextLesson null & modulCompleted true', () {
      final snapshot = HomeSnapshot(
        moduls: [_modul('modul_01', 1)],
        lessons: [
          _lesson('modul_01_lesson_01', 'modul_01', 1),
          _lesson('modul_01_lesson_02', 'modul_01', 2),
        ],
        progress: [
          _progress('modul_01_lesson_02', 'modul_01', hariIni),
          _progress('modul_01_lesson_01', 'modul_01', kemarin),
        ],
        ready: true,
      );

      expect(snapshot.nextLesson, isNull);
      expect(snapshot.modulCompleted, isTrue);
      // Yang terakhir diselesaikan dipakai untuk tombol "Ulangi".
      expect(snapshot.lastCompletedLesson?.lessonId, 'modul_01_lesson_02');
    });

    test('activeModul pindah ke modul berikutnya bila modul 1 tamat', () {
      final snapshot = HomeSnapshot(
        moduls: [_modul('modul_01', 1), _modul('modul_02', 2)],
        lessons: [
          _lesson('modul_01_lesson_01', 'modul_01', 1),
          _lesson('modul_02_lesson_01', 'modul_02', 1),
        ],
        progress: [_progress('modul_01_lesson_01', 'modul_01', kemarin)],
        ready: true,
      );

      expect(snapshot.activeModul?.modulId, 'modul_02');
      expect(snapshot.isModulUnlocked(_modul('modul_02', 2)), isTrue);
    });

    test('modul 2 terkunci selama modul 1 belum tuntas', () {
      final snapshot = HomeSnapshot(
        moduls: [_modul('modul_01', 1), _modul('modul_02', 2)],
        lessons: [
          _lesson('modul_01_lesson_01', 'modul_01', 1),
          _lesson('modul_01_lesson_02', 'modul_01', 2),
          _lesson('modul_02_lesson_01', 'modul_02', 1),
        ],
        progress: [_progress('modul_01_lesson_01', 'modul_01', kemarin)],
        ready: true,
      );

      expect(snapshot.isModulUnlocked(_modul('modul_01', 1)), isTrue);
      expect(snapshot.isModulUnlocked(_modul('modul_02', 2)), isFalse);
    });
  });

  group('HomeSnapshot - XP & streak', () {
    test('xpToday hanya menghitung XP hari ini', () {
      final snapshot = HomeSnapshot(
        profile: {
          'total_xp': 70,
          'current_streak': 3,
          'xp_by_day': {
            AuthService.dateKey(kemarin): 20,
            AuthService.dateKey(hariIni): 30,
          },
        },
        ready: true,
      );

      expect(snapshot.totalXp, 70);
      expect(snapshot.streakDays, 3);
      expect(snapshot.xpToday, 30);
      expect(HomeSnapshot.dailyXpTarget, 40);
    });

    test('profil lama tanpa xp_by_day tidak error', () {
      final snapshot = HomeSnapshot(
        profile: {'total_xp': 20, 'current_streak': 5},
        ready: true,
      );

      expect(snapshot.xpToday, 0);
      expect(snapshot.totalXp, 20);
    });
  });

  group('HomeSnapshot - aktivitas terbaru', () {
    test('menggabungkan lesson & tes, terbaru di depan', () {
      final snapshot = HomeSnapshot(
        moduls: [_modul('modul_01', 1)],
        lessons: [_lesson('modul_01_lesson_01', 'modul_01', 1, judul: 'Kelancaran Jeda')],
        progress: [
          _progress('modul_01_lesson_01', 'modul_01', kemarin),
        ],
        tests: [_tes('case_001', 72, hariIni)],
        ready: true,
      );

      final items = snapshot.activities;
      expect(items.length, 2);
      expect(items.first.kind, 'test');
      expect(items.first.badge, 'CI 72');
      expect(items.first.title, 'Perkenalan Diri');
      expect(items.last.kind, 'lesson');
      expect(items.last.title, 'Kelancaran Jeda');
      expect(items.last.badge, '+10 XP');
      expect(items.last.lessonId, 'modul_01_lesson_01');
    });

    test('lesson yang sudah dihapus dari roadmap tetap tampil sebagai aktivitas', () {
      final snapshot = HomeSnapshot(
        moduls: [_modul('modul_01', 1)],
        progress: [_progress('modul_01_lesson_09', 'modul_01', kemarin)],
        ready: true,
      );

      final items = snapshot.activities;
      expect(items, hasLength(1));
      expect(items.first.title, 'Lesson');
      expect(items.first.lessonId, 'modul_01_lesson_09');
    });

    test('belum ada aktivitas sama sekali -> daftar kosong', () {
      expect(const HomeSnapshot(ready: true).activities, isEmpty);
    });
  });

  group('waktuRelatif', () {
    test('label hari ini, kemarin, dan tanggal', () {
      expect(waktuRelatif(hariIni, now: hariIni), 'Hari ini');
      expect(waktuRelatif(kemarin, now: hariIni), 'Kemarin');
      expect(
        waktuRelatif(DateTime(2026, 10, 5), now: DateTime(2026, 10, 28)),
        '5 Okt',
      );
    });
  });
}
