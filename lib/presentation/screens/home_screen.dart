import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/auth_service.dart';
import '../widgets/home/header_widget.dart';
import '../widgets/home/hero_card_widget.dart';
import '../widgets/home/daily_challenge_widget.dart';
import '../widgets/home/unit_belajar_widget.dart';
import '../widgets/home/aktivitas_terbaru_widget.dart';
import '../widgets/home/custom_bottom_nav.dart';
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

  Widget _buildHomeContent() {
    final authService = AuthService();

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: authService.userProfileStream,
      builder: (context, snapshot) {
        final userData = snapshot.data?.data();

        final rawName = userData?['nama'] ??
            (authService.currentUser != null
                ? authService.userDisplayName
                : 'User');

        final displayName = rawName.isNotEmpty
            ? '${rawName[0].toUpperCase()}${rawName.substring(1)}'
            : 'User';

        final streakDays = (userData?['current_streak'] is int)
            ? userData!['current_streak'] as int
            : 5;

        final currentXp = (userData?['total_xp'] is int)
            ? userData!['total_xp'] as int
            : 20;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header (Avatar, Greeting, Bell)
              HeaderWidget(userName: displayName, greeting: 'Selamat datang'),
              const SizedBox(height: 20),

              // 2. Active Unit / Hero Card
              HeroCardWidget(
                streakDays: streakDays,
                unitName: 'UNIT 1',
                lessonTitle: 'Lesson 5: Speaking',
                lessonSubtitle: 'Daily Communication',
                currentLesson: 4,
                totalLessons: 5,
                currentXp: currentXp,
                targetXp: 40,
                onContinuePressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const LessonScreen(
                        lessonNumber: 6,
                        lessonTag: 'Response',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),

              // 3. Daily Challenge Banner Card
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

              // 4. Unit Belajar Section
              UnitBelajarWidget(
                onViewRoadmapPressed: () {
                  setState(() => _currentNavIndex = 1);
                },
              ),
              const SizedBox(height: 22),

              // 5. Aktivitas Terbaru Section
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
              const SizedBox(height: 90), // Spacing for floating bottom bar
            ],
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: IndexedStack(
          index: _currentNavIndex,
          children: [
            _buildHomeContent(),
            const RoadmapScreen(),
            const TestScreen(),
            const ProfileScreen(),
          ],
        ),
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
