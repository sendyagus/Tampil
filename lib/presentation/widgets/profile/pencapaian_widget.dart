import 'package:flutter/material.dart';

class AchievementItem {
  final String title;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final bool isLocked;

  AchievementItem({
    required this.title,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    this.isLocked = false,
  });
}

class PencapaianWidget extends StatelessWidget {
  final VoidCallback? onViewAllPressed;

  const PencapaianWidget({
    super.key,
    this.onViewAllPressed,
  });

  @override
  Widget build(BuildContext context) {
    final List<AchievementItem> items = [
      AchievementItem(
        title: 'Tes Pertama',
        icon: Icons.track_changes_rounded,
        iconBgColor: const Color(0xFFEEF2FF),
        iconColor: const Color(0xFF6366F1),
      ),
      AchievementItem(
        title: 'Streak 7 Hari',
        icon: Icons.bolt_rounded,
        iconBgColor: const Color(0xFFE0F7FA),
        iconColor: const Color(0xFF00ACC1),
      ),
      AchievementItem(
        title: 'Unit Selesai',
        icon: Icons.hourglass_empty_rounded,
        iconBgColor: const Color(0xFFF3E8FF),
        iconColor: const Color(0xFF9333EA),
      ),
      AchievementItem(
        title: 'Lompat Unit',
        icon: Icons.rocket_launch_outlined,
        iconBgColor: const Color(0xFFF1F5F9),
        iconColor: const Color(0xFF94A3B8),
        isLocked: true,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Pencapaian',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            GestureDetector(
              onTap: onViewAllPressed,
              child: Row(
                children: const [
                  Text(
                    'Lihat semua',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6366F1),
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: Color(0xFF6366F1),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // White Card Container holding 4 items
        Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items.map((item) {
              return Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: item.iconBgColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            item.icon,
                            color: item.iconColor,
                            size: 24,
                          ),
                        ),
                        if (item.isLocked)
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF475569),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                            child: const Icon(
                              Icons.lock_rounded,
                              size: 10,
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: item.isLocked
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
