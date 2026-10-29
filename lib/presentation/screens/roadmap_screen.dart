import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/auth_service.dart';
import '../../services/roadmap_service.dart';
import '../widgets/roadmap/roadmap_header_widget.dart';
import '../widgets/roadmap/roadmap_unit_card.dart';
import '../widgets/roadmap/roadmap_path_widget.dart';
import '../widgets/roadmap/locked_unit_card.dart';
import 'lesson_screen.dart';

/// Layar Roadmap. Seluruh konten (unit & lesson) dibaca secara LIVE dari
/// Cloud Firestore collection `units` dan `lessons`, yang disinkronkan dari
/// dashboard CMS. Tidak ada lagi teks lesson yang di-hardcode.
class RoadmapScreen extends StatelessWidget {
  const RoadmapScreen({super.key});

  static List<LessonModel> _lessonsForUnit(
    List<LessonModel> all,
    UnitModel? unit,
  ) {
    if (unit == null) return const [];
    return all.where((l) => l.unitId == unit.unitId).toList()
      ..sort((a, b) => a.urutan.compareTo(b.urutan));
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: authService.userProfileStream,
      builder: (context, userSnap) {
        final userData = userSnap.data?.data();
        final streakDays = (userData?['current_streak'] is int)
            ? userData!['current_streak'] as int
            : 5;

        return FutureBuilder<List<UnitModel>>(
          future: RoadmapService().getPublishedUnits(),
          builder: (context, unitSnap) {
            if (unitSnap.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 120),
                  child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
                ),
              );
            }

            final units = unitSnap.data ?? const <UnitModel>[];
            final unit1 = units.isNotEmpty ? units[0] : null;
            final unit2 = units.length > 1 ? units[1] : null;
            final unit3 = units.length > 2 ? units[2] : null;
            final totalUnits = units.isNotEmpty ? units.length : 3;

            return FutureBuilder<List<LessonModel>>(
              future: RoadmapService().getPublishedLessons(),
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
                final unit1Lessons = _lessonsForUnit(allLessons, unit1);
                final unit2Lessons = _lessonsForUnit(allLessons, unit2);
                final unit3Lessons = _lessonsForUnit(allLessons, unit3);
                final totalLessons = allLessons.length;

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Header (jumlah unit & lesson LIVE dari Firestore)
                      RoadmapHeaderWidget(
                        totalUnits: totalUnits,
                        totalLessons: totalLessons,
                        streakDays: streakDays,
                      ),
                      const SizedBox(height: 20),

                      // 2. Unit aktif pertama (banner)
                      RoadmapUnitCard(
                        unitNumber: unit1 != null
                            ? 'UNIT ${unit1.urutan}'
                            : 'UNIT 1',
                        unitTitle: unit1?.nama ?? 'Daily Communication',
                        completedLessons: 0,
                        totalLessons: unit1Lessons.isEmpty
                            ? 1
                            : unit1Lessons.length,
                        percentage: 0,
                        onSkipUnitPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Uji tes kelulusan untuk melewati Unit 1',
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // 3. Jalur lesson DINAMIS dari Firestore (+ progres user)
                      StreamBuilder<Set<String>>(
                        stream: AuthService().completedLessonsStream,
                        builder: (context, progSnap) {
                          final completedIds =
                              progSnap.data ?? const <String>{};
                          return RoadmapPathWidget(
                            lessons: unit1Lessons,
                            completedIds: completedIds,
                            onLessonTap: (lesson, index) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => LessonScreen(
                                    lesson: lesson,
                                    // Buka ulang lesson selesai: boleh, tapi
                                    // XP tidak diberikan dua kali.
                                    rewardAlreadyGiven: completedIds
                                        .contains(lesson.lessonId),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 28),

                      // 4. Unit 2 (terkunci) — jumlah lesson dari Firestore
                      LockedUnitCard(
                        unitNumber: unit2 != null
                            ? 'UNIT ${unit2.urutan}'
                            : 'UNIT 2',
                        title: unit2?.nama ?? 'Peer Communication',
                        subtitle:
                            '${unit2Lessons.length} lesson · 1 Final Test',
                        onSkipPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Tes penempatan untuk melewati Unit 2',
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 14),

                      // 5. Unit 3 (terkunci)
                      LockedUnitCard(
                        unitNumber: unit3 != null
                            ? 'UNIT ${unit3.urutan}'
                            : 'UNIT 3',
                        title: unit3?.nama ?? 'Public Speaking',
                        subtitle:
                            '${unit3Lessons.length} lesson · 1 Final Test',
                        onSkipPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Tes penempatan untuk melewati Unit 3',
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
