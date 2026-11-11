import 'package:flutter/material.dart';

class RoadmapHeaderWidget extends StatelessWidget {
  final int totalUnits;
  final int totalLessons;
  final int streakDays;

  const RoadmapHeaderWidget({
    super.key,
    this.totalUnits = 3,
    this.totalLessons = 15,
    this.streakDays = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Roadmap',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '$totalUnits unit · $totalLessons lesson',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),

        // Flame Streak Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFFEDD5), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.local_fire_department_rounded,
                size: 18,
                color: Color(0xFFEA580C),
              ),
              const SizedBox(width: 6),
              Text(
                '$streakDays',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFEA580C),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
