import 'package:flutter/material.dart';

class ActivityItem {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String tagText;
  final Color tagBgColor;
  final Color tagTextColor;

  ActivityItem({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.tagText,
    required this.tagBgColor,
    required this.tagTextColor,
  });
}

class AktivitasTerbaruWidget extends StatelessWidget {
  final VoidCallback? onViewAllPressed;

  const AktivitasTerbaruWidget({
    super.key,
    this.onViewAllPressed,
  });

  @override
  Widget build(BuildContext context) {
    final List<ActivityItem> activities = [
      ActivityItem(
        icon: Icons.mic_none_rounded,
        iconBgColor: const Color(0xFFEEF2FF),
        iconColor: const Color(0xFF4F46E5),
        title: 'Diskusi kelompok',
        subtitle: 'Tes · Hari ini',
        tagText: 'CI 72',
        tagBgColor: const Color(0xFFEEF2FF),
        tagTextColor: const Color(0xFF4F46E5),
      ),
      ActivityItem(
        icon: Icons.check_rounded,
        iconBgColor: const Color(0xFFDCFCE7),
        iconColor: const Color(0xFF16A34A),
        title: 'Lesson 2: Relevance',
        subtitle: 'Selesai · Kemarin',
        tagText: '+10 XP',
        tagBgColor: const Color(0xFFCCFBF1),
        tagTextColor: const Color(0xFF0D9488),
      ),
      ActivityItem(
        icon: Icons.campaign_outlined,
        iconBgColor: const Color(0xFFF5F3FF),
        iconColor: const Color(0xFF8B5CF6),
        title: 'Presentasi singkat',
        subtitle: 'Tes · 2 Okt',
        tagText: 'CI 66',
        tagBgColor: const Color(0xFFEEF2FF),
        tagTextColor: const Color(0xFF4F46E5),
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
              'Aktivitas terbaru',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            GestureDetector(
              onTap: onViewAllPressed,
              child: const Text(
                'Lihat semua',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4F46E5),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // White Container with Activity List
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.shade200, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: List.generate(activities.length, (index) {
              final item = activities[index];
              final isLast = index == activities.length - 1;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        // Left Icon Container
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: item.iconBgColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            item.icon,
                            color: item.iconColor,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Title & Subtitle Column
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
                              const SizedBox(height: 2),
                              Text(
                                item.subtitle,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Right Trailing Tag Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: item.tagBgColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            item.tagText,
                            style: TextStyle(
                              color: item.tagTextColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isLast)
                    Divider(
                      color: Colors.grey.shade100,
                      height: 1,
                      thickness: 1,
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}
