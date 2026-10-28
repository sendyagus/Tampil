import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/auth_service.dart';
import '../../services/roadmap_service.dart';
import '../widgets/roadmap/roadmap_header_widget.dart';
import '../widgets/roadmap/roadmap_unit_card.dart';
import '../widgets/roadmap/roadmap_path_widget.dart';
import '../widgets/roadmap/locked_unit_card.dart';
import '../utils/transition_utils.dart';
import 'lesson_screen.dart';

class RoadmapScreen extends StatelessWidget {
  const RoadmapScreen({super.key});

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
            final units = unitSnap.data ?? [];

            final unit1 = units.isNotEmpty ? units[0] : null;
            final unit2 = units.length > 1 ? units[1] : null;
            final unit3 = units.length > 2 ? units[2] : null;

            final totalUnits = units.isNotEmpty ? units.length : 3;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Header (Roadmap title, lesson count & flame streak LIVE DARI FIRESTORE)
                  RoadmapHeaderWidget(
                    totalUnits: totalUnits,
                    totalLessons: 15,
                    streakDays: streakDays,
                  ),
                  const SizedBox(height: 20),

                  // 2. Active Unit 1 Banner Card (DARI FIRESTORE)
                  RoadmapUnitCard(
                    unitNumber: unit1 != null ? 'UNIT ${unit1.urutan}' : 'UNIT 1',
                    unitTitle: unit1?.nama ?? 'Daily Communication',
                    completedLessons: 4,
                    totalLessons: 5,
                    percentage: 80,
                    onSkipUnitPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Uji tes kelulusan untuk melewati Unit 1'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // 3. Roadmap Learning Path (Dotted Zigzag Path)
                  RoadmapPathWidget(
                    onActiveLessonPressed: () {
                      context.pushDissolve(
                        (_) => const LessonScreen(
                          lessonNumber: 6,
                          lessonTag: 'Response',
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 28),

                  // 4. Locked Unit 2 Card (DARI FIRESTORE)
                  LockedUnitCard(
                    unitNumber: unit2 != null ? 'UNIT ${unit2.urutan}' : 'UNIT 2',
                    title: unit2?.nama ?? 'Peer Communication',
                    subtitle: '5 lesson · 1 Final Test',
                    onSkipPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tes penempatan untuk melewati Unit 2'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 14),

                  // 5. Locked Unit 3 Card (DARI FIRESTORE)
                  LockedUnitCard(
                    unitNumber: unit3 != null ? 'UNIT ${unit3.urutan}' : 'UNIT 3',
                    title: unit3?.nama ?? 'Public Speaking',
                    subtitle: '5 lesson · 1 Final Test',
                    onSkipPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tes penempatan untuk melewati Unit 3'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 90), // Bottom spacing for navigation bar
                ],
              ),
            );
          },
        );
      },
    );
  }
}
