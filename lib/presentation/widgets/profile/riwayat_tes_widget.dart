import 'package:flutter/material.dart';

class TestHistoryItem {
  final String title;
  final String categoryDate;
  final int score;
  final String statusLabel;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final VoidCallback? onTap;

  TestHistoryItem({
    required this.title,
    required this.categoryDate,
    required this.score,
    required this.statusLabel,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    this.onTap,
  });
}

class RiwayatTesWidget extends StatelessWidget {
  final List<TestHistoryItem>? items;
  final VoidCallback? onViewAllPressed;

  const RiwayatTesWidget({
    super.key,
    this.items,
    this.onViewAllPressed,
  });

  @override
  Widget build(BuildContext context) {
    final hasItems = items != null && items!.isNotEmpty;
    final displayItems = items ?? const <TestHistoryItem>[];

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
            if (hasItems)
              GestureDetector(
                onTap: onViewAllPressed,
                child: const Row(
                  children: [
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

        // Test history list or Empty State
        if (hasItems)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
              itemCount: displayItems.length,
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                color: Color(0xFFF1F5F9),
              ),
              itemBuilder: (context, index) {
                final item = displayItems[index];

                return InkWell(
                  onTap: item.onTap,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
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
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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

                        // Score & Status Badge & Chevron
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
                            if (item.onTap != null) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.chevron_right_rounded,
                                size: 18,
                                color: Color(0xFF94A3B8),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEEF2FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.history_toggle_off_rounded,
                    color: Color(0xFF6366F1),
                    size: 28,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Belum ada riwayat tes',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Hasil latihan bicaramu akan tercatat di sini setelah kamu menyelesaikan tes pertamamu.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
