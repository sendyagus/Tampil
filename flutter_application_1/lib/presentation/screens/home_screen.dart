import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../services/home_service.dart';
import '../../services/roadmap_service.dart';
import '../widgets/home/header_widget.dart';
import '../widgets/home/hero_card_widget.dart';
import '../widgets/home/cms_banner_widget.dart';
import '../widgets/home/daily_challenge_widget.dart';
import '../widgets/home/modul_belajar_widget.dart';
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

  final HomeService _homeService = HomeService();
  // Dibuat sekali agar tidak berlangganan ulang tiap rebuild.
  late final Stream<HomeSnapshot> _homeStream;

  @override
  void initState() {
    super.initState();
    _homeStream = _homeService.watchHomeData();
  }

  void _openLesson(LessonModel lesson, {bool rewardAlreadyGiven = false}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LessonScreen(
          lesson: lesson,
          rewardAlreadyGiven: rewardAlreadyGiven,
        ),
      ),
    );
  }

  void _goToTab(int index) => setState(() => _currentNavIndex = index);

  Widget _buildHomeContent(HomeSnapshot data) {
    final authService = AuthService();

    final rawName = (data.profile['nama']?.toString().isNotEmpty ?? false)
        ? data.profile['nama'].toString()
        : (authService.currentUser != null
              ? authService.userDisplayName
              : 'User');
    final displayName = rawName.isNotEmpty
        ? '${rawName[0].toUpperCase()}${rawName.substring(1)}'
        : 'User';

    final modul = data.activeModul;
    final next = data.nextLesson;
    final last = data.lastCompletedLesson;
    final totalDalamModul = data.activeModulLessons.length;
    final selesai = data.completedInModul;

    // ---- Kartu Hero: selalu menunjukan lesson yang HARUS dilanjutkan ----
    String heroTitle;
    String heroSubtitle;
    String heroLabel;
    VoidCallback heroAction;

    if (modul == null || totalDalamModul == 0) {
      heroTitle = 'Belum ada lesson';
      heroSubtitle = 'Tambahkan lesson lewat dashboard CMS lalu Sync.';
      heroLabel = 'Buka Roadmap';
      heroAction = () => _goToTab(1);
    } else if (next == null) {
      // Semua lesson modul aktif sudah selesai -> tawarkan mengulang terakhir.
      heroTitle = last?.judul.isNotEmpty == true
          ? last!.judul
          : 'Modul selesai!';
      heroSubtitle = '${modul.nama} · semua lesson tuntas, siap Final Test';
      heroLabel = 'Ulangi';
      heroAction = last == null
          ? () => _goToTab(1)
          : () => _openLesson(last, rewardAlreadyGiven: true);
    } else {
      heroTitle = next.judul.isNotEmpty ? next.judul : 'Lesson ${next.urutan}';
      heroSubtitle = next.targetAspek.isNotEmpty
          ? '${modul.nama} · ${next.targetAspek}'
          : modul.nama;
      heroLabel = selesai == 0 ? 'Mulai' : 'Lanjut';
      heroAction = () => _openLesson(next);
    }

    // ---- Section "Modul belajar" ----
    final moduls = <ModulRingkasan>[
      for (final m in data.moduls.take(3))
        ModulRingkasan(
          title: m.nama.trim().isEmpty ? m.modulId : m.nama.split(' ').first,
          completed: data.lessonsOf(m).where((l) => data.completedIds.contains(l.lessonId)).length,
          total: data.lessonsOf(m).length,
          unlocked: data.isModulUnlocked(m),
        ),
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header (Avatar, Greeting, Bell)
          HeaderWidget(userName: displayName, greeting: 'Selamat datang'),
          const SizedBox(height: 20),

          // 2. Active Modul / Hero Card (progres & XP LIVE dari Firestore)
          HeroCardWidget(
            streakDays: data.streakDays,
            modulName: modul != null ? 'MODUL ${modul.urutan}' : 'MODUL 1',
            lessonTitle: heroTitle,
            lessonSubtitle: heroSubtitle,
            currentLesson: selesai,
            totalLessons: totalDalamModul,
            currentXp: data.xpToday,
            targetXp: HomeSnapshot.dailyXpTarget,
            continueLabel: heroLabel,
            onContinuePressed: heroAction,
          ),
          const SizedBox(height: 18),

          // 2b. CMS Banner (konten dikelola lewat dashboard admin)
          const CmsBannerWidget(),

          // 3. Daily Challenge Banner Card -> buka tab Test
          DailyChallengeWidget(
            challengeTitle: 'Ceritakan harimu dalam 30',
            rewardXp: 10,
            onTap: () => _goToTab(2),
          ),
          const SizedBox(height: 22),

          // 4. Modul Belajar Section (progress per modul, LIVE)
          ModulBelajarWidget(
            moduls: moduls,
            onViewRoadmapPressed: () => _goToTab(1),
            onModulPressed: () => _goToTab(1),
          ),
          const SizedBox(height: 22),

          // 5. Aktivitas Terbaru (lesson selesai + hasil tes, LIVE)
          AktivitasTerbaruWidget(
            items: data.activities,
            onItemTap: (item) {
              final lessonId = item.lessonId;
              if (lessonId == null) {
                // Aktivitas tes: buka tab Test.
                _goToTab(2);
                return;
              }
              final matches = data.lessons.where((l) => l.lessonId == lessonId);
              if (matches.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Lesson sudah tidak ada di roadmap.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }
              // Lesson sudah selesai -> dibuka untuk mengulang, XP tidak ganda.
              _openLesson(matches.first, rewardAlreadyGiven: true);
            },
            onViewAllPressed: () => _goToTab(3),
          ),
          const SizedBox(height: 90), // Spacing for floating bottom bar
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: StreamBuilder<HomeSnapshot>(
          stream: _homeStream,
          builder: (context, snapshot) {
            final data = snapshot.data;
            if (data == null || !data.ready) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 120),
                  child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
                ),
              );
            }

            // TabDissolve menjaga state seluruh tab (seperti IndexedStack)
            // namun menggantinya dengan efek smooth dissolve; Bottom Navigation
            // sengaja berada di luar sehingga tidak ikut memudar.
            return TabDissolve(
              currentIndex: _currentNavIndex,
              children: [
                _buildHomeContent(data),
                const RoadmapScreen(),
                const TestScreen(),
                const ProfileScreen(),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        selectedIndex: _currentNavIndex,
        onItemTapped: (index) => _goToTab(index),
      ),
    );
  }
}
