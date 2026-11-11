import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../services/roadmap_service.dart';
import '../widgets/roadmap/locked_unit_card.dart';
import '../widgets/roadmap/roadmap_header_widget.dart';
import '../widgets/roadmap/roadmap_path_widget.dart';
import '../widgets/roadmap/roadmap_unit_card.dart';
import 'lesson_screen.dart';

/// Layar Roadmap membaca modul dan lesson yang dipublikasikan di Firestore.
class RoadmapScreen extends StatefulWidget {
  const RoadmapScreen({super.key});

  @override
  State<RoadmapScreen> createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends State<RoadmapScreen> {
  final RoadmapService _roadmapService = RoadmapService();
  final AuthService _authService = AuthService();

  late Stream<DocumentSnapshot<Map<String, dynamic>>> _profileStream;
  late Stream<List<UnitModel>> _unitsStream;
  late Stream<List<LessonModel>> _lessonsStream;
  late Stream<Set<String>> _completedLessonsStream;

  @override
  void initState() {
    super.initState();
    _refreshStreams();
  }

  void _refreshStreams() {
    _profileStream = _authService.userProfileStream;
    _unitsStream = _roadmapService.watchPublishedUnits();
    _lessonsStream = _roadmapService.watchPublishedLessons();
    _completedLessonsStream = _authService.completedLessonsStream;
  }

  static List<LessonModel> _lessonsForUnit(
    List<LessonModel> all,
    UnitModel unit,
  ) {
    return all.where((lesson) => lesson.unitId == unit.unitId).toList()
      ..sort((a, b) => a.urutan.compareTo(b.urutan));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _profileStream,
      builder: (context, profileSnap) {
        final profile = profileSnap.data?.data();
        final streakDays = profile?['current_streak'] is num
            ? (profile!['current_streak'] as num).toInt()
            : 0;

        return StreamBuilder<List<UnitModel>>(
          stream: _unitsStream,
          builder: (context, unitSnap) {
            if (unitSnap.hasError) {
              return _buildError('modul', unitSnap.error);
            }
            if (unitSnap.connectionState == ConnectionState.waiting) {
              return _buildLoading();
            }

            final units = unitSnap.data ?? const <UnitModel>[];
            return StreamBuilder<List<LessonModel>>(
              stream: _lessonsStream,
              builder: (context, lessonSnap) {
                if (lessonSnap.hasError) {
                  return _buildError('lesson', lessonSnap.error);
                }
                if (lessonSnap.connectionState == ConnectionState.waiting) {
                  return _buildLoading();
                }

                final lessons = lessonSnap.data ?? const <LessonModel>[];
                return StreamBuilder<Set<String>>(
                  stream: _completedLessonsStream,
                  builder: (context, progressSnap) {
                    if (progressSnap.hasError) {
                      return _buildError('progres belajar', progressSnap.error);
                    }
                    return _buildRoadmap(
                      units: units,
                      lessons: lessons,
                      completedIds: progressSnap.data ?? const <String>{},
                      streakDays: streakDays,
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildRoadmap({
    required List<UnitModel> units,
    required List<LessonModel> lessons,
    required Set<String> completedIds,
    required int streakDays,
  }) {
    final totalLessons = lessons.length;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RoadmapHeaderWidget(
            totalUnits: units.length,
            totalLessons: totalLessons,
            streakDays: streakDays,
          ),
          const SizedBox(height: 20),
          if (units.isEmpty)
            _buildEmptyState()
          else ...[
            _buildActiveUnit(
              context,
              unit: units.first,
              lessons: _lessonsForUnit(lessons, units.first),
              completedIds: completedIds,
            ),
            for (final unit in units.skip(1)) ...[
              const SizedBox(height: 14),
              LockedUnitCard(
                unitNumber: 'UNIT ${unit.urutan}',
                title: unit.nama,
                subtitle:
                    '${_lessonsForUnit(lessons, unit).length} lesson · 1 Final Test',
                onSkipPressed: () => _showSkipMessage(context, unit.urutan),
              ),
            ],
          ],
          const SizedBox(height: 90),
        ],
      ),
    );
  }

  Widget _buildActiveUnit(
    BuildContext context, {
    required UnitModel unit,
    required List<LessonModel> lessons,
    required Set<String> completedIds,
  }) {
    final completedCount = lessons
        .where((lesson) => completedIds.contains(lesson.lessonId))
        .length;
    final percentage = lessons.isEmpty
        ? 0
        : (completedCount * 100 / lessons.length).round();

    return Column(
      children: [
        RoadmapUnitCard(
          unitNumber: 'UNIT ${unit.urutan}',
          unitTitle: unit.nama,
          completedLessons: completedCount,
          totalLessons: lessons.length,
          percentage: percentage,
          onSkipUnitPressed: () => _showSkipMessage(context, unit.urutan),
        ),
        const SizedBox(height: 16),
        RoadmapPathWidget(
          lessons: lessons,
          completedIds: completedIds,
          onLessonTap: (lesson, _) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => LessonScreen(
                  lesson: lesson,
                  rewardAlreadyGiven: completedIds.contains(lesson.lessonId),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Text(
        'Belum ada modul yang dipublikasikan. Tambahkan modul dan lesson '
        'di CMS, lalu sinkronkan ke Firestore.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Color(0xFF64748B)),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.only(top: 120),
        child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
      ),
    );
  }

  Widget _buildError(String dataType, Object? error) {
    debugPrint('Gagal memuat $dataType Roadmap dari Firestore: $error');
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, color: Color(0xFFEF4444)),
            const SizedBox(height: 8),
            Text(
              'Gagal memuat $dataType dari Firebase. Periksa koneksi dan izin Firestore.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => setState(_refreshStreams),
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSkipMessage(BuildContext context, int unitNumber) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Uji tes kelulusan untuk melewati Unit $unitNumber'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
