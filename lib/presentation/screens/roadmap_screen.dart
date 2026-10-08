import 'package:flutter/material.dart';

import '../widgets/roadmap/roadmap_header_widget.dart';
import '../widgets/roadmap/roadmap_unit_card.dart';
import '../widgets/roadmap/roadmap_path_widget.dart';
import '../widgets/roadmap/locked_unit_card.dart';

class RoadmapScreen extends StatelessWidget {
  const RoadmapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header (Roadmap title, lesson count & flame streak)
          const RoadmapHeaderWidget(
            totalUnits: 3,
            totalLessons: 15,
            streakDays: 5,
          ),
          const SizedBox(height: 20),

          // 2. Active Unit 1 Banner Card
          RoadmapUnitCard(
            unitNumber: 'UNIT 1',
            unitTitle: 'Daily Communication',
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Membuka Lesson 5: Speaking'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          const SizedBox(height: 28),

          // 4. Locked Unit 2 Card
          LockedUnitCard(
            unitNumber: 'UNIT 2',
            title: 'Peer Communication',
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

          // 5. Locked Unit 3 Card
          LockedUnitCard(
            unitNumber: 'UNIT 3',
            title: 'Public Speaking',
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
  }
}
