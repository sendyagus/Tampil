import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/auth_service.dart';
import '../../services/roadmap_service.dart';
import '../widgets/roadmap/roadmap_header_widget.dart';
import '../widgets/roadmap/roadmap_modul_card.dart';
import '../widgets/roadmap/roadmap_path_widget.dart';
import '../widgets/roadmap/locked_modul_card.dart';
import 'lesson_screen.dart';

/// Layar Roadmap. Seluruh konten (modul & lesson) dibaca secara LIVE dari
/// Cloud Firestore collection `modul` dan `lessons`, yang disinkronkan dari
/// dashboard CMS. Tidak ada lagi teks lesson yang di-hardcode.
class RoadmapScreen extends StatefulWidget {
  const RoadmapScreen({super.key});

  @override
  State<RoadmapScreen> createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends State<RoadmapScreen> {
  final RoadmapService _roadmap = RoadmapService();
  final AuthService _auth = AuthService();

  // Stream dibuat sekali saja agar tidak berlangganan ulang tiap rebuild.
  late final Stream<List<ModulModel>> _modulsStream;
  late final Stream<List<LessonModel>> _lessonsStream;
  late final Stream<Set<String>> _progressStream;
  late final Stream<DocumentSnapshot<Map<String, dynamic>>> _profileStream;

  @override
  void initState() {
    super.initState();
    _modulsStream = _roadmap.watchPublishedModuls();
    _lessonsStream = _roadmap.watchPublishedLessons();
    _progressStream = _auth.completedLessonsStream;
    _profileStream = _auth.userProfileStream;
  }

  /// Lesson milik satu modul. Pencocokan toleran terhadap beda kapital/spasi dan
  /// ikut menerima doc id modul, supaya data dari CMS tetap muncul meski
  /// penulisan `modul_id` sedikit berbeda.
  List<LessonModel> _lessonsForModul(
    List<LessonModel> all,
    ModulModel? modul,
  ) {
    if (modul == null) return const [];
    String norm(String s) => s.trim().toLowerCase().replaceAll(' ', '_');
    final keys = {norm(modul.modulId), norm(modul.id)};
    return all.where((l) => keys.contains(norm(l.modulId))).toList()
      ..sort((a, b) => a.urutan.compareTo(b.urutan));
  }

  int _unassignedCount(List<LessonModel> all, List<ModulModel> moduls) {
    String norm(String s) => s.trim().toLowerCase().replaceAll(' ', '_');
    final keys = <String>{
      for (final m in moduls) ...[norm(m.modulId), norm(m.id)],
    };
    return all.where((l) => !keys.contains(norm(l.modulId))).length;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _profileStream,
      builder: (context, userSnap) {
        final userData = userSnap.data?.data();
        final streakDays = (userData?['current_streak'] is int)
            ? userData!['current_streak'] as int
            : 5;

        return StreamBuilder<List<ModulModel>>(
          stream: _modulsStream,
          builder: (context, modulSnap) {
            if (modulSnap.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 120),
                  child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
                ),
              );
            }

            final moduls = modulSnap.data ?? const <ModulModel>[];
            final modul1 = moduls.isNotEmpty ? moduls[0] : null;
            final modul2 = moduls.length > 1 ? moduls[1] : null;
            final modul3 = moduls.length > 2 ? moduls[2] : null;
            final totalModuls = moduls.isNotEmpty ? moduls.length : 3;

            return StreamBuilder<List<LessonModel>>(
              stream: _lessonsStream,
              builder: (context, lessonSnap) {
                if (lessonSnap.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 120),
                      child: CircularProgressIndicator(
                        color: Color(0xFF4F46E5),
                      ),
                    ),
                  );
                }

                final allLessons = lessonSnap.data ?? const <LessonModel>[];
                final modul1Lessons = _lessonsForModul(allLessons, modul1);
                final modul2Lessons = _lessonsForModul(allLessons, modul2);
                final modul3Lessons = _lessonsForModul(allLessons, modul3);
                final totalLessons = allLessons.length;
                final unassigned = _unassignedCount(allLessons, moduls);

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Header (jumlah modul & lesson LIVE dari Firestore)
                      RoadmapHeaderWidget(
                        totalModuls: totalModuls,
                        totalLessons: totalLessons,
                        streakDays: streakDays,
                      ),
                      const SizedBox(height: 20),

                      // 2-4. Banner progres + peringatan + jalur lesson.
                      // Satu StreamBuilder progres supaya angka banner dan node
                      // selalu berasal dari data yang sama.
                      StreamBuilder<Set<String>>(
                        stream: _progressStream,
                        builder: (context, progSnap) {
                          final completedIds =
                              progSnap.data ?? const <String>{};
                          final selesai = modul1Lessons
                              .where((l) => completedIds.contains(l.lessonId))
                              .length;
                          final totalModul1 = modul1Lessons.length;
                          final persen = totalModul1 == 0
                              ? 0
                              : ((selesai / totalModul1) * 100).round();

                          return Column(
                            children: [
                              RoadmapModulCard(
                                modulNumber: modul1 != null
                                    ? 'MODUL ${modul1.urutan}'
                                    : 'MODUL 1',
                                modulTitle: modul1?.nama ?? 'Daily Communication',
                                completedLessons: selesai,
                                totalLessons: totalModul1 == 0 ? 1 : totalModul1,
                                percentage: persen,
                                onSkipModulPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Uji tes kelulusan untuk melewati Modul 1',
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 16),

                              // Peringatan bila ada lesson belum terhubung
                              if (unassigned > 0) ...[
                                UnassignedLessonNotice(count: unassigned),
                                const SizedBox(height: 16),
                              ],

                              // Jalur lesson DINAMIS dari Firestore + progres user
                              RoadmapPathWidget(
                                lessons: modul1Lessons,
                                completedIds: completedIds,
                                onLessonTap: (lesson, index) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => LessonScreen(
                                        lesson: lesson,
                                        // Buka ulang lesson selesai: boleh, tapi
                                        // XP tidak diberikan dua kali.
                                        rewardAlreadyGiven: completedIds.contains(
                                          lesson.lessonId,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 28),

                      // 5. Modul 2 (terkunci) — jumlah lesson dari Firestore
                      LockedModulCard(
                        modulNumber: modul2 != null
                            ? 'MODUL ${modul2.urutan}'
                            : 'MODUL 2',
                        title: modul2?.nama ?? 'Peer Communication',
                        subtitle:
                            '${modul2Lessons.length} lesson · 1 Final Test',
                        onSkipPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Tes penempatan untuk melewati Modul 2',
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 14),

                      // 6. Modul 3 (terkunci)
                      LockedModulCard(
                        modulNumber: modul3 != null
                            ? 'MODUL ${modul3.urutan}'
                            : 'MODUL 3',
                        title: modul3?.nama ?? 'Public Speaking',
                        subtitle:
                            '${modul3Lessons.length} lesson · 1 Final Test',
                        onSkipPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Tes penempatan untuk melewati Modul 3',
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 90), // ruang untuk nav bar bawah
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

/// Kartu peringatan kecil: ada lesson published yang `modul_id`-nya belum cocok
/// dengan modul mana pun, sehingga tidak tampil di jalur roadmap.
class UnassignedLessonNotice extends StatelessWidget {
  final int count;

  const UnassignedLessonNotice({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFCD34D)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFFB45309),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$count lesson belum terhubung ke modul mana pun. Buka dashboard '
              'CMS -> Lesson / Langkah Roadmap -> Edit -> isi "Modul" -> Simpan '
              '& Sync agar muncul di sini.',
              style: const TextStyle(
                fontSize: 12.5,
                height: 1.4,
                color: Color(0xFF92400E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
