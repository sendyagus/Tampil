import 'package:flutter/material.dart';

class TestHistoryItem {
  final String title;
  final String categoryDate;
  final int score;
  final String statusLabel;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;

  TestHistoryItem({
    required this.title,
    required this.categoryDate,
    required this.score,
    required this.statusLabel,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
  });
}

class RiwayatTesWidget extends StatelessWidget {
  final VoidCallback? onViewAllPressed;

  const RiwayatTesWidget({
    super.key,
    this.onViewAllPressed,
  });

  @override
  Widget build(BuildContext context) {
    final List<TestHistoryItem> items = [
      TestHistoryItem(
        title: 'Final Test Unit 1',
        categoryDate: 'Daily · hari ini',
        score: 68,
        statusLabel: 'Baik',
        icon: Icons.check_circle_outline_rounded,
        iconBgColor: const Color(0xFFEEF2FF),
        iconColor: const Color(0xFF6366F1),
      ),
      TestHistoryItem(
        title: 'Menyela diskusi dengan sopan',
        categoryDate: 'Peer · kemarin',
        score: 61,
        statusLabel: 'Baik',
        icon: Icons.chat_bubble_outline_rounded,
        iconBgColor: const Color(0xFFF3E8FF),
        iconColor: const Color(0xFF9333EA),
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
              'Riwayat Tes',
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

        // White Container holding test history list
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              color: Color(0xFFF1F5F9),
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    // Icon Circle
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: item.iconBgColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        item.icon,
                        color: item.iconColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Title & Subtitle
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
                          const SizedBox(height: 3),
                          Text(
                            item.categoryDate,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Score & Status Badge
                    Row(
                      children: [
                        Text(
                          '${item.score}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F7FA),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.statusLabel,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00ACC1),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
