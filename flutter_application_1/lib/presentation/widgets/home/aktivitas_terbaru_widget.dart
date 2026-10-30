import 'package:flutter/material.dart';

import '../../../services/home_service.dart';

/// Daftar "Aktivitas terbaru" yang benar-benar dibaca dari Firestore:
/// lesson yang baru diselesaikan (users/{uid}/lesson_progress) dan hasil tes
/// (test_sessions). Baris lesson bisa diketuk untuk membuka lesson lagi.
class AktivitasTerbaruWidget extends StatelessWidget {
  final List<ActivityEntry> items;
  final void Function(ActivityEntry item)? onItemTap;
  final VoidCallback? onViewAllPressed;

  const AktivitasTerbaruWidget({
    super.key,
    this.items = const [],
    this.onItemTap,
    this.onViewAllPressed,
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
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: items.isEmpty
              ? const _EmptyActivity()
              : Column(
                  children: List.generate(items.length, (index) {
                    final item = items[index];
                    final isLast = index == items.length - 1;

                    return Column(
                      children: [
                        InkWell(
                          onTap: onItemTap == null ? null : () => onItemTap!(item),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              children: [
                                _LeadingIcon(kind: item.kind),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                      const SizedBox(height: 2),
                                      Text(
                                        '${item.subtitle} · ${waktuRelatif(item.time)}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _Badge(kind: item.kind, text: item.badge),
                              ],
                            ),
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

class _LeadingIcon extends StatelessWidget {
  final String kind;

  const _LeadingIcon({required this.kind});

  @override
  Widget build(BuildContext context) {
    final isLesson = kind == 'lesson';
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isLesson ? const Color(0xFFDCFCE7) : const Color(0xFFEEF2FF),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isLesson ? Icons.check_rounded : Icons.mic_none_rounded,
        color: isLesson ? const Color(0xFF16A34A) : const Color(0xFF4F46E5),
        size: 22,
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String kind;
  final String text;

  const _Badge({required this.kind, required this.text});

  @override
  Widget build(BuildContext context) {
    final isLesson = kind == 'lesson';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isLesson ? const Color(0xFFCCFBF1) : const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isLesson ? const Color(0xFF0D9488) : const Color(0xFF4F46E5),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _EmptyActivity extends StatelessWidget {
  const _EmptyActivity();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 22, horizontal: 8),
      child: Column(
        children: [
          Icon(
            Icons.history_rounded,
            size: 28,
            color: Color(0xFF94A3B8),
          ),
          SizedBox(height: 8),
          Text(
            'Belum ada aktivitas',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF475569),
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Selesaikan lesson pertama di Roadmap atau lakukan tes bicara, '
            'hasilnya akan muncul di sini.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }
}
