import 'package:flutter/material.dart';

class StudiKasusItem {
  final String title;
  final String categoryDuration;
  final String difficulty;
  final Color difficultyBgColor;
  final Color difficultyTextColor;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;

  StudiKasusItem({
    required this.title,
    required this.categoryDuration,
    required this.difficulty,
    required this.difficultyBgColor,
    required this.difficultyTextColor,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
  });
}

class StudiKasusWidget extends StatelessWidget {
  final VoidCallback? onViewAllPressed;
  final ValueChanged<StudiKasusItem>? onItemPressed;

  const StudiKasusWidget({
    super.key,
    this.onViewAllPressed,
    this.onItemPressed,
  });

  @override
  Widget build(BuildContext context) {
    final List<StudiKasusItem> items = [
      StudiKasusItem(
        title: 'Minta perpanjangan tugas',
        categoryDuration: 'Daily · 60 dtk',
        difficulty: 'Mudah',
        difficultyBgColor: const Color(0xFFE0F7FA),
        difficultyTextColor: const Color(0xFF00ACC1),
        icon: Icons.description_outlined,
        iconBgColor: const Color(0xFFE0F7FA),
        iconColor: const Color(0xFF00ACC1),
      ),
      StudiKasusItem(
        title: 'Menyela diskusi sopan',
        categoryDuration: 'Peer · 90 dtk',
        difficulty: 'Sedang',
        difficultyBgColor: const Color(0xFFF3E8FF),
        difficultyTextColor: const Color(0xFF9333EA),
        icon: Icons.people_outline_rounded,
        iconBgColor: const Color(0xFFF3E8FF),
        iconColor: const Color(0xFF9333EA),
      ),
      StudiKasusItem(
        title: 'Presentasi ide di kelas',
        categoryDuration: 'Public Speaking · 120 dtk',
        difficulty: 'Sulit',
        difficultyBgColor: const Color(0xFFEEF2FF),
        difficultyTextColor: const Color(0xFF4F46E5),
        icon: Icons.mic_none_rounded,
        iconBgColor: const Color(0xFFEEF2FF),
        iconColor: const Color(0xFF4F46E5),
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
              'Studi kasus',
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

        // List of Case Items
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = items[index];
            return InkWell(
              onTap: () {
                if (onItemPressed != null) {
                  onItemPressed!(item);
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Icon Box
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: item.iconBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        item.icon,
                        color: item.iconColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Title and Subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.categoryDuration,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Difficulty Tag
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: item.difficultyBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item.difficulty,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: item.difficultyTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
