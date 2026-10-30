import 'dart:async';

import 'auth_service.dart';
import 'roadmap_service.dart';
import 'test_session_service.dart';

/// Satu baris "Aktivitas terbaru" di beranda.
/// [kind] 'lesson' (lesson selesai) atau 'test' (hasil sesi tes).
class ActivityEntry {
  final String id;
  final String kind;
  final String title;
  final String subtitle;
  final String badge;
  final DateTime time;

  /// Terisi bila aktivitas berupa lesson, supaya baris bisa diketuk dan
  /// membuka kembali lesson tersebut.
  final String? lessonId;

  const ActivityEntry({
    required this.id,
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.time,
    this.lessonId,
  });

  bool get isLesson => kind == 'lesson';
}

/// Gabungan seluruh sumber data yang dibutuhkan halaman beranda:
/// profil (XP & streak), modul, lesson, progres lesson, dan riwayat tes.
/// Semua getter di bawah hanya menghitung di memori, jadi gratis dipanggil
/// setiap kali stream mengirim data baru.
class HomeSnapshot {
  final Map<String, dynamic> profile;
  final List<ModulModel> moduls;
  final List<LessonModel> lessons;
  final List<LessonProgress> progress;
  final List<TestSessionModel> tests;

  /// False sampai semua sumber pertama kali mengirim data (beranda menampilkan
  /// spinner selama ini).
  final bool ready;

  const HomeSnapshot({
    this.profile = const {},
    this.moduls = const [],
    this.lessons = const [],
    this.progress = const [],
    this.tests = const [],
    this.ready = false,
  });

  static int _int(dynamic v) =>
      v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;

  static String _norm(String s) => s.trim().toLowerCase().replaceAll(' ', '_');

  Set<String> get completedIds => progress.map((p) => p.lessonId).toSet();

  /// Lesson milik satu modul, tersortir `urutan`. Pencocokan toleran terhadap
  /// beda kapital/spasi dan ikut menerima doc id modul.
  List<LessonModel> lessonsOf(ModulModel? modul) {
    if (modul == null) return const [];
    final keys = _modulKeys(modul);
    return lessons.where((l) => keys.contains(_norm(l.modulId))).toList()
      ..sort((a, b) => a.urutan.compareTo(b.urutan));
  }

  /// Modul yang masih punya lesson belum diselesaikan; fallback modul pertama.
  ModulModel? get activeModul {
    final done = completedIds;
    for (final m in moduls) {
      if (lessonsOf(m).any((l) => !done.contains(l.lessonId))) return m;
    }
    return moduls.isNotEmpty ? moduls.first : null;
  }

  List<LessonModel> get activeModulLessons => lessonsOf(activeModul);

  int get completedInModul => activeModulLessons
      .where((l) => completedIds.contains(l.lessonId))
      .length;

  /// Lesson yang harus dilanjutkan: lesson pertama pada modul aktif yang belum
  /// selesai. Null bila semuanya sudah selesai / belum ada lesson.
  LessonModel? get nextLesson {
    final done = completedIds;
    for (final l in activeModulLessons) {
      if (!done.contains(l.lessonId)) return l;
    }
    return null;
  }

  /// Lesson terakhir yang diselesaikan user ([progress] sudah tersortir baru).
  LessonModel? get lastCompletedLesson {
    final byId = {for (final l in lessons) l.lessonId: l};
    for (final p in progress) {
      final found = byId[p.lessonId];
      if (found != null) return found;
    }
    return null;
  }

  bool get modulCompleted =>
      activeModul != null &&
      activeModulLessons.isNotEmpty &&
      nextLesson == null;

  /// Kunci unik modul: gabungan modul_id dan doc id, dinormalisasi.
  static Set<String> _modulKeys(ModulModel m) =>
      {_norm(m.modulId), _norm(m.id)};

  static bool _isSameModul(ModulModel a, ModulModel b) {
    final keys = _modulKeys(a);
    return keys.intersection(_modulKeys(b)).isNotEmpty;
  }

  /// Aturan buka modul: modul pertama selalu terbuka; modul berikutnya terbuka
  /// bila seluruh lesson modul sebelumnya sudah selesai (atau modul itu sendiri
  /// sudah punya lesson yang diselesaikan).
  bool isModulUnlocked(ModulModel modul) {
    final idx = moduls.indexWhere((m) => _isSameModul(m, modul));
    if (idx <= 0) return true;
    final done = completedIds;
    final prev = lessonsOf(moduls[idx - 1]);
    if (prev.isNotEmpty && prev.every((l) => done.contains(l.lessonId))) {
      return true;
    }
    return lessonsOf(modul).any((l) => done.contains(l.lessonId));
  }

  int get totalXp => _int(profile['total_xp']);
  int get streakDays => _int(profile['current_streak']);

  /// XP yang benar-benar didapat user hari ini (sumber: `xp_by_day`).
  int get xpToday {
    final map = profile['xp_by_day'];
    if (map is Map) {
      return _int(map[AuthService.dateKey(DateTime.now())]);
    }
    return 0;
  }

  /// Target harian XP (PRD); bisa diubah di satu tempat bila perlu.
  static const int dailyXpTarget = 40;

  /// Aktivitas gabungan lesson selesai + hasil tes, terbaru di depan.
  List<ActivityEntry> get activities {
    final byId = {for (final l in lessons) l.lessonId: l};
    final modulName = {for (final m in moduls) m.modulId: m.nama};
    final list = <ActivityEntry>[];

    for (final p in progress) {
      final l = byId[p.lessonId];
      final aspek = l?.targetAspek ?? '';
      list.add(
        ActivityEntry(
          id: 'lesson_${p.lessonId}',
          kind: 'lesson',
          title: (l != null && l.judul.isNotEmpty) ? l.judul : 'Lesson',
          subtitle: aspek.isNotEmpty
              ? 'Lesson · $aspek'
              : 'Lesson · ${modulName[p.modulId] ?? p.modulId}',
          badge: '+${p.xp} XP',
          time: p.completedAt,
          lessonId: p.lessonId,
        ),
      );
    }

    for (final t in tests) {
      list.add(
        ActivityEntry(
          id: 'test_${t.sessionId}',
          kind: 'test',
          title: t.caseTitle,
          subtitle: 'Tes · ${t.kategoriSkor}',
          badge: 'CI ${t.communicationIndex.toInt()}',
          time: t.createdAt,
        ),
      );
    }

    list.sort((a, b) => b.time.compareTo(a.time));
    return list.take(6).toList();
  }
}

/// Menggabungkan 5 stream Firestore menjadi SATU stream [HomeSnapshot] agar
/// beranda cukup memakai satu StreamBuilder dan tetap realtime.
/// Stream-nya broadcast + ref-count: boleh dilanggan ulang (mis. saat elemen
/// pindah posisi) tanpa error "already listened to".
class HomeService {
  final AuthService _auth = AuthService();
  final RoadmapService _roadmap = RoadmapService();
  final TestSessionService _testSession = TestSessionService();

  Stream<HomeSnapshot> watchHomeData() {
    late final StreamController<HomeSnapshot> controller;
    var profile = <String, dynamic>{};
    var moduls = <ModulModel>[];
    var lessons = <LessonModel>[];
    var progress = <LessonProgress>[];
    var tests = <TestSessionModel>[];
    final done = <String>{};
    final subs = <StreamSubscription<dynamic>>[];
    HomeSnapshot? last;
    var listeners = 0;

    void emit() {
      if (controller.isClosed) return;
      last = HomeSnapshot(
        profile: profile,
        moduls: moduls,
        lessons: lessons,
        progress: progress,
        tests: tests,
        ready: done.length >= 5,
      );
      controller.add(last!);
    }

    void start() {
      if (subs.isNotEmpty) return;
      // Beranda hanya bisa dibuka setelah login, jadi uid sudah tersedia.
      final uid = _auth.currentUser?.uid ?? '';
      if (uid.isEmpty) {
        done.addAll({'profile', 'modul', 'lesson', 'progress', 'test'});
        emit();
        return;
      }
      subs.add(
        _auth.userProfileStream.listen((doc) {
          profile = doc.data() ?? <String, dynamic>{};
          done.add('profile');
          emit();
        }),
      );
      subs.add(
        _roadmap.watchPublishedModuls().listen((value) {
          moduls = value;
          done.add('modul');
          emit();
        }),
      );
      subs.add(
        _roadmap.watchPublishedLessons().listen((value) {
          lessons = value;
          done.add('lesson');
          emit();
        }),
      );
      subs.add(
        _auth.lessonProgressStream.listen((value) {
          progress = value;
          done.add('progress');
          emit();
        }),
      );
      subs.add(
        _testSession.watchUserHistory(uid).listen((value) {
          tests = value;
          done.add('test');
          emit();
        }),
      );
    }

    void stop() {
      for (final s in subs) {
        s.cancel();
      }
      subs.clear();
      last = null;
    }

    controller = StreamController<HomeSnapshot>.broadcast(
      sync: true,
      onListen: () {
        listeners++;
        // Sudah ada data di memori: kirim langsung, tidak perlu berlangganan
        // ulang ke Firestore.
        if (last != null) controller.add(last!);
        start();
      },
      onCancel: () {
        listeners--;
        if (listeners <= 0) {
          listeners = 0;
          stop();
        }
      },
    );

    return controller.stream;
  }
}

const List<String> _bulanSingkat = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

/// Label tanggal ramah: 'Hari ini', 'Kemarin', atau '12 Okt'.
String waktuRelatif(DateTime d, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  final hariIni = DateTime(reference.year, reference.month, reference.day);
  final target = DateTime(d.year, d.month, d.day);
  final selisih = hariIni.difference(target).inDays;
  if (selisih <= 0) return 'Hari ini';
  if (selisih == 1) return 'Kemarin';
  return '${target.day} ${_bulanSingkat[target.month - 1]}';
}
