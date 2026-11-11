import 'package:flutter/material.dart';

import '../../../services/roadmap_service.dart';

class UnitBelajarWidget extends StatelessWidget {
  final List<UnitModel> units;
  final List<LessonModel> lessons;
  final Set<String> completedIds;
  final VoidCallback? onViewRoadmapPressed;

  const UnitBelajarWidget({
    super.key,
    required this.units,
    required this.lessons,
    required this.completedIds,
    this.onViewRoadmapPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Unit belajar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            GestureDetector(
              onTap: onViewRoadmapPressed,
              child: const Row(
                children: [
                  Text(
                    'Lihat roadmap',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4F46E5),
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: Color(0xFF4F46E5),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        if (units.isEmpty)
          const Text(
            'Belum ada modul yang dipublikasikan.',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          )
        else
          Row(
            children: [
              for (var i = 0; i < units.length && i < 3; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                Expanded(child: _buildModuleCard(i)),
              ],
            ],
          ),
      ],
    );
  }

  Widget _buildModuleCard(int index) {
    const backgrounds = [
      Color(0xFFEEF2FF),
      Color(0xFFF5F3FF),
      Color(0xFFECFEFF),
    ];
    const borders = [Color(0xFFC7D2FE), Color(0xFFDDD6FE), Color(0xFFA5F3FC)];
    const icons = [
      Icons.chat_bubble_outline_rounded,
      Icons.groups_outlined,
      Icons.campaign_outlined,
    ];
    const iconColors = [
      Color(0xFF4F46E5),
      Color(0xFF8B5CF6),
      Color(0xFF06B6D4),
    ];
    final unit = units[index];
    final unitLessons = lessons
        .where((lesson) => lesson.unitId == unit.unitId)
        .toList();
    final completedCount = unitLessons
        .where((lesson) => completedIds.contains(lesson.lessonId))
        .length;

    return _buildUnitCard(
      backgroundColor: backgrounds[index],
      borderColor: borders[index],
      icon: icons[index],
      iconColor: iconColors[index],
      title: unit.nama,
      statusWidget: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '$completedCount/${unitLessons.length}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: iconColors[index],
          ),
        ),
      ),
    );
  }

  Widget _buildUnitCard({
    required Color backgroundColor,
    required Color borderColor,
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget statusWidget,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      height: 136,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Circle Icon Badge
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 21),
          ),
          const SizedBox(height: 8),

          // Title
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),

          // Status (Progress / Terkunci)
          Flexible(child: statusWidget),
        ],
      ),
    );
  }
}
