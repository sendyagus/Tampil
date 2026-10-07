import 'package:flutter/material.dart';

class UnitBelajarWidget extends StatelessWidget {
  final VoidCallback? onViewRoadmapPressed;

  const UnitBelajarWidget({
    super.key,
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

        // Horizontal Row of 3 Unit Cards
        Row(
          children: [
            // Unit 1: Daily (Active)
            Expanded(
              child: _buildUnitCard(
                backgroundColor: const Color(0xFFEEF2FF),
                borderColor: const Color(0xFFC7D2FE),
                icon: Icons.chat_bubble_outline_rounded,
                iconColor: const Color(0xFF4F46E5),
                title: 'Daily',
                statusWidget: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '2/5',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4F46E5),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Unit 2: Peer (Locked)
            Expanded(
              child: _buildUnitCard(
                backgroundColor: const Color(0xFFF5F3FF),
                borderColor: const Color(0xFFDDD6FE),
                icon: Icons.groups_outlined,
                iconColor: const Color(0xFF8B5CF6),
                title: 'Peer',
                statusWidget: Text(
                  'Terkunci',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Unit 3: Public (Locked)
            Expanded(
              child: _buildUnitCard(
                backgroundColor: const Color(0xFFECFEFF),
                borderColor: const Color(0xFFA5F3FC),
                icon: Icons.campaign_outlined,
                iconColor: const Color(0xFF06B6D4),
                title: 'Public',
                statusWidget: Text(
                  'Terkunci',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
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
      padding: const EdgeInsets.all(14),
      height: 130,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Circle Icon Badge
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 22,
            ),
          ),
          const SizedBox(height: 10),

          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),

          // Status (Progress / Terkunci)
          statusWidget,
        ],
      ),
    );
  }
}
