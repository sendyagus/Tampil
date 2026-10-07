import 'package:flutter/material.dart';

import '../widgets/home/header_widget.dart';
import '../widgets/home/hero_card_widget.dart';
import '../widgets/home/daily_challenge_widget.dart';
import '../widgets/home/unit_belajar_widget.dart';
import '../widgets/home/aktivitas_terbaru_widget.dart';
import '../widgets/home/custom_bottom_nav.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header (Avatar, Greeting, Bell)
              const HeaderWidget(userName: 'Sendy', greeting: 'Selamat pagi'),
              const SizedBox(height: 20),

              // 2. Active Unit / Hero Card
              HeroCardWidget(
                streakDays: 5,
                unitName: 'UNIT 1',
                lessonTitle: 'Lesson 5: Speaking',
                lessonSubtitle: 'Daily Communication',
                currentLesson: 4,
                totalLessons: 5,
                currentXp: 20,
                targetXp: 40,
                onContinuePressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lanjut ke Lesson 5: Speaking'),
                      behavior: SnackBarBehavior.floating,
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
