import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/auth_service.dart';
import '../../services/roadmap_service.dart';
import '../widgets/home/header_widget.dart';
import '../widgets/home/hero_card_widget.dart';
import '../widgets/home/cms_banner_widget.dart';
import '../widgets/home/daily_challenge_widget.dart';
import '../widgets/home/unit_belajar_widget.dart';
import '../widgets/home/aktivitas_terbaru_widget.dart';
import '../widgets/home/custom_bottom_nav.dart';
import '../utils/transition_utils.dart';
import 'test_screen.dart';
import 'profile_screen.dart';
import 'roadmap_screen.dart';
import 'lesson_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0; // Default to Home tab (0)
  final AuthService _authService = AuthService();
  final RoadmapService _roadmapService = RoadmapService();
  late final Stream<DocumentSnapshot<Map<String, dynamic>>> _profileStream =
      _authService.userProfileStream;
  late final Stream<List<UnitModel>> _unitsStream = _roadmapService
      .watchPublishedUnits();
  late final Stream<List<LessonModel>> _lessonsStream = _roadmapService
      .watchPublishedLessons();
  late final Stream<Set<String>> _completedLessonsStream =
      _authService.completedLessonsStream;

  Widget _buildHomeContent() {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _profileStream,
      builder: (context, profileSnapshot) {
        if (profileSnapshot.hasError) {
          return _buildHomeError('profil', profileSnapshot.error);
        }
        final userData = profileSnapshot.data?.data() ?? {};

        return StreamBuilder<List<UnitModel>>(
          stream: _unitsStream,
          builder: (context, unitsSnapshot) {
            if (unitsSnapshot.hasError) {
              return _buildHomeError('modul', unitsSnapshot.error);
            }
            if (unitsSnapshot.connectionState == ConnectionState.waiting) {
              return _buildLoading();
            }

            return StreamBuilder<List<LessonModel>>(
              stream: _lessonsStream,
              builder: (context, lessonsSnapshot) {
                if (lessonsSnapshot.hasError) {
                  return _buildHomeError('lesson', lessonsSnapshot.error);
                }
                if (lessonsSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return _buildLoading();
                }

                return StreamBuilder<Set<String>>(
                  stream: _completedLessonsStream,
                  builder: (context, progressSnapshot) {
                    if (progressSnapshot.hasError) {
                      return _buildHomeError(
                        'progres belajar',
                        progressSnapshot.error,
                      );
                    }
                    return _buildHomeDashboard(
                      userData: userData,
                      units: unitsSnapshot.data ?? const [],
                      lessons: lessonsSnapshot.data ?? const [],
                      completedIds: progressSnapshot.data ?? const {},
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

  Widget _buildHomeDashboard({
    required Map<String, dynamic> userData,
    required List<UnitModel> units,
    required List<LessonModel> lessons,
    required Set<String> completedIds,
  }) {
    final userName = userData['nama'] is String
        ? userData['nama'] as String
        : _authService.userDisplayName;
    final displayName = userName.isNotEmpty
        ? '${userName[0].toUpperCase()}${userName.substring(1)}'
        : 'User';
    final streakDays = _readInt(userData['current_streak']);
    final currentXp = _readInt(userData['total_xp']);
    final activeUnit = units.isEmpty ? null : units.first;
    final unitLessons =
        activeUnit == null
              ? <LessonModel>[]
              : lessons
                    .where((lesson) => lesson.unitId == activeUnit.unitId)
                    .toList()
          ..sort((a, b) => a.urutan.compareTo(b.urutan));
    final completedCount = unitLessons
        .where((lesson) => completedIds.contains(lesson.lessonId))
        .length;
    final nextLesson = _roadmapService.getNextAvailableLesson(
      unitLessons,
      completedIds,
    );
    final photoUrl =
        userData['photo_url'] is String &&
            (userData['photo_url'] as String).isNotEmpty
        ? userData['photo_url'] as String
        : userData['foto_url'] is String &&
              (userData['foto_url'] as String).isNotEmpty
        ? userData['foto_url'] as String
        : _authService.currentUser?.photoURL;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeaderWidget(
            userName: displayName,
            greeting: 'Selamat datang',
            avatarUrl: photoUrl,
            onAvatarTap: () => setState(() => _currentNavIndex = 3),
          ),
          const SizedBox(height: 20),
          HeroCardWidget(
            streakDays: streakDays,
            unitName: activeUnit == null
                ? 'ROADMAP'
                : 'UNIT ${activeUnit.urutan}',
            lessonTitle: nextLesson == null
                ? (unitLessons.isEmpty
                      ? 'Belum ada lesson'
                      : 'Semua lesson selesai')
                : 'Lesson ${nextLesson.urutan}: ${nextLesson.judul}',
            lessonSubtitle: activeUnit?.nama ?? 'Tambahkan konten lewat CMS',
            currentLesson: completedCount,
            totalLessons: unitLessons.length,
            currentXp: currentXp,
            onContinuePressed: () {
              if (nextLesson == null) {
                setState(() => _currentNavIndex = 1);
                return;
              }
              context.pushDissolve(
                (_) => LessonScreen(
                  lesson: nextLesson,
                  rewardAlreadyGiven: completedIds.contains(
                    nextLesson.lessonId,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 18),
          const CmsBannerWidget(),
          DailyChallengeWidget(
            challengeTitle: 'Ceritakan harimu dalam 30',
            rewardXp: 10,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Membuka Daily Challenge'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          const SizedBox(height: 22),
          UnitBelajarWidget(
            units: units,
            lessons: lessons,
            completedIds: completedIds,
            onViewRoadmapPressed: () {
              setState(() => _currentNavIndex = 1);
            },
          ),
          const SizedBox(height: 22),
          AktivitasTerbaruWidget(
            onViewAllPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Menampilkan semua aktivitas'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          const SizedBox(height: 90),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
    );
  }

  Widget _buildHomeError(String dataType, Object? error) {
    debugPrint('Gagal memuat $dataType Home dari Firestore: $error');
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Gagal memuat $dataType dari Firebase. Periksa koneksi dan izin Firestore.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: TabDissolve(
        currentIndex: _currentNavIndex,
        children: [
          SafeArea(top: true, bottom: false, child: _buildHomeContent()),
          SafeArea(top: true, bottom: false, child: const RoadmapScreen()),
          const TestScreen(),
          SafeArea(top: true, bottom: false, child: const ProfileScreen()),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        selectedIndex: _currentNavIndex,
        onItemTapped: (index) {
          setState(() {
            _currentNavIndex = index;
          });
        },
      ),
    );
  }
}
