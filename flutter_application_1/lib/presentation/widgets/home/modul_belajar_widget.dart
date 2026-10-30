import 'package:flutter/material.dart';

/// Ringkasan satu modul untuk kartu di beranda.
class ModulRingkasan {
  final String title;
  final int completed;
  final int total;
  final bool unlocked;

  const ModulRingkasan({
    required this.title,
    required this.completed,
    required this.total,
    this.unlocked = true,
  });
}

/// Palet warna & ikon tetap per posisi kartu (sama seperti desain awal).
const List<Color> _bg = [Color(0xFFEEF2FF), Color(0xFFF5F3FF), Color(0xFFECFEFF)];
const List<Color> _border = [Color(0xFFC7D2FE), Color(0xFFDDD6FE), Color(0xFFA5F3FC)];
const List<Color> _accent = [Color(0xFF4F46E5), Color(0xFF8B5CF6), Color(0xFF06B6D4)];
const List<IconData> _icons = [
  Icons.chat_bubble_outline_rounded,
  Icons.groups_outlined,
  Icons.campaign_outlined,
];

/// Section "Modul belajar" di beranda. Angka progres dan status terkunci
/// dibaca dari Firestore (lesson_progress user aktif), bukan teks tetap.
class ModulBelajarWidget extends StatelessWidget {
  final List<ModulRingkasan> moduls;
  final VoidCallback? onViewRoadmapPressed;
  final VoidCallback? onModulPressed;

  const ModulBelajarWidget({
    super.key,
    this.moduls = const [],
    this.onViewRoadmapPressed,
    this.onModulPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Selalu tampilkan 3 slot agar tata letak tidak berubah saat data sedikit.
    final cards = <ModulRingkasan>[
      ...moduls.take(3),
      for (var i = moduls.length; i < 3; i++)
        const ModulRingkasan(title: '—', completed: 0, total: 0, unlocked: false),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Modul belajar',
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

        // Horizontal Row of Modul Cards
        Row(
          children: [
            for (int i = 0; i < cards.length; i++) ...[
              if (i > 0) const SizedBox(width: 12),
              Expanded(
                child: _buildModulCard(
                  context: context,
                  index: i,
                  data: cards[i],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildModulCard({
    required BuildContext context,
    required int index,
    required ModulRingkasan data,
  }) {
    final slot = index % _bg.length;
    final Widget status = data.unlocked
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${data.completed}/${data.total}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _accent[slot],
              ),
            ),
          )
        : Text(
            'Terkunci',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade500,
            ),
          );

    return InkWell(
      onTap: onModulPressed,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(12),
        height: 136,
        decoration: BoxDecoration(
          color: _bg[slot],
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _border[slot], width: 1.2),
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
              child: Icon(
                data.unlocked ? _icons[slot] : Icons.lock_outline_rounded,
                color: _accent[slot],
                size: 21,
              ),
            ),
            const SizedBox(height: 8),

            // Title
            Text(
              data.title,
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
            Flexible(child: status),
          ],
        ),
      ),
    );
  }
}
