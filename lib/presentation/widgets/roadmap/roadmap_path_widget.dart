import 'package:flutter/material.dart';

import '../../../services/roadmap_service.dart';

/// Jalur belajar (zigzag) pada layar Roadmap.
///
/// Dulunya seluruh node di-hardcode. Sekarang node dibangun secara dinamis
/// dari [lessons] yang dibaca dari Firestore (collection `lessons`), sehingga
/// admin dapat menambahkan/mengubah langkah roadmap lewat dashboard CMS.
class RoadmapPathWidget extends StatelessWidget {
  final List<LessonModel> lessons;

  /// Lesson yang sudah diselesaikan user aktif (lesson_id), dipakai untuk
  /// membuka lesson berikutnya secara otomatis.
  final Set<String> completedIds;

  /// Dipanggil saat user mengetuk lesson yang tersedia (belum terkunci).
  final void Function(LessonModel lesson, int index)? onLessonTap;

  const RoadmapPathWidget({
    super.key,
    required this.lessons,
    this.completedIds = const {},
    this.onLessonTap,
  });

  // Kisi vertikal tetap agar garis putus-putus yang dilukis CustomPaint
  // tetap rata dengan pusat tiap node berapapun jumlah lesson.
  static const double _pitch = 104;
  static const double _startY = _pitch / 2;
  static const double _finalSlot = 132;

  @override
  Widget build(BuildContext context) {
    if (lessons.isEmpty) {
      return _buildEmptyState();
    }

    final double totalHeight = lessons.length * _pitch + _finalSlot;

    return SizedBox(
      width: double.infinity,
      height: totalHeight,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _ZigzagPainter(
                count: lessons.length,
                pitch: _pitch,
                startY: _startY,
                finalY: lessons.length * _pitch + _finalSlot / 2,
              ),
            ),
          ),
          Column(
            children: [
              for (int i = 0; i < lessons.length; i++)
                SizedBox(height: _pitch, child: _buildNode(context, i)),
              SizedBox(
                height: _finalSlot,
                child: const Center(child: _FinalTestNode()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Status satu node: 'selesai' | 'aktif' (bisa dimulai) | 'kunci'.
  String _statusAt(int i) {
    final l = lessons[i];
    if (completedIds.contains(l.lessonId)) return 'selesai';
    final prevSelesai =
        i == 0 || completedIds.contains(lessons[i - 1].lessonId);
    if (i == 0 || l.unlockRule == 'always_unlocked' || prevSelesai) {
      return 'aktif';
    }
    return 'kunci';
  }

  int get _firstActiveIndex {
    for (var i = 0; i < lessons.length; i++) {
      if (_statusAt(i) == 'aktif') return i;
    }
    return -1;
  }

  Widget _buildNode(BuildContext context, int i) {
    final lesson = lessons[i];
    final alignLeft = i % 2 == 0;
    final status = _statusAt(i);

    final Widget circle = switch (status) {
      'selesai' => _CompletedNodeCircle(
        // Lesson yang sudah selesai tetap bisa dibuka lagi untuk mengulang.
        onTap: () => onLessonTap?.call(lesson, i),
      ),
      'aktif' => _AvailableNodeCircle(
        lesson: lesson,
        index: i,
        showStartBadge: i == _firstActiveIndex,
        onTap: () => onLessonTap?.call(lesson, i),
      ),
      _ => _LockedNodeCircle(label: '${i + 1}'),
    };

    final info = _NodeInfo(
      lesson: lesson,
      index: i,
      status: status,
      alignRight: !alignLeft,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: alignLeft
            ? [circle, const SizedBox(width: 14), Expanded(child: info)]
            : [Expanded(child: info), const SizedBox(width: 14), circle],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: const Column(
        children: [
          Icon(Icons.account_tree_rounded, size: 32, color: Color(0xFF94A3B8)),
          SizedBox(height: 8),
          Text(
            'Belum ada lesson untuk unit ini.',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF475569),
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Tambahkan lewat menu "Lesson / Langkah Roadmap" di dashboard CMS, '
            'lalu tekan Sync agar muncul di sini.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }
}

/// Informasi teks di samping node lesson (tag LESSON n, judul, aspek).
class _NodeInfo extends StatelessWidget {
  final LessonModel lesson;
  final int index;
  final String status; // selesai | aktif | kunci
  final bool alignRight;

  const _NodeInfo({
    required this.lesson,
    required this.index,
    required this.status,
    required this.alignRight,
  });

  @override
  Widget build(BuildContext context) {
    final cross = alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final terbuka = status != 'kunci';

    final titleStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: terbuka ? const Color(0xFF0F172A) : const Color(0xFF64748B),
    );
    final tagStyle = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.5,
      color: status == 'kunci'
          ? const Color(0xFF94A3B8)
          : const Color(0xFF6366F1),
    );
    final subtitle = switch (status) {
      'selesai' => 'Selesai · +10 XP',
      'aktif' => lesson.targetAspek.isEmpty
          ? 'Mulai lesson ini'
          : lesson.targetAspek,
      _ => 'Selesaikan lesson sebelumnya',
    };

    return Column(
      crossAxisAlignment: cross,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('LESSON \${index + 1}', style: tagStyle),
        const SizedBox(height: 2),
        Text(
          lesson.judul.isEmpty ? 'Lesson \${index + 1}' : lesson.judul,
          style: titleStyle,
          textAlign: alignRight ? TextAlign.end : TextAlign.start,
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: status == 'selesai'
                ? const Color(0xFF06B6D4)
                : const Color(0xFF94A3B8),
          ),
          textAlign: alignRight ? TextAlign.end : TextAlign.start,
        ),
      ],
    );
  }
}

/// Node lesson telah selesai (lingkaran teal dengan checkmark, masih bisa
/// diketuk untuk membuka kembali lesson).
class _CompletedNodeCircle extends StatelessWidget {
  final VoidCallback onTap;

  const _CompletedNodeCircle({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: const Color(0xFF06B6D4),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF06B6D4).withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.check_rounded,
          color: Colors.white,
          size: 26,
        ),
      ),
    );
  }
}

/// Node aktif (lingkaran ungu dengan tombol play + badge MULAI opsional).
class _AvailableNodeCircle extends StatelessWidget {
  final LessonModel lesson;
  final int index;
  final bool showStartBadge;
  final VoidCallback onTap;

  const _AvailableNodeCircle({
    required this.lesson,
    required this.index,
    required this.showStartBadge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showStartBadge) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFC7D2FE), width: 1),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'MULAI',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6366F1),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
        ],
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.4),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      ],
    );
  }
}

/// Node terkunci (lingkaran abu-abu bernomor).
class _LockedNodeCircle extends StatelessWidget {
  final String label;

  const _LockedNodeCircle({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }
}

/// Node FINAL TEST di ujung jalur (masih terkunci).
class _FinalTestNode extends StatelessWidget {
  const _FinalTestNode();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                color: Color(0xFF94A3B8),
                size: 30,
              ),
            ),
            Positioned(
              right: 2,
              bottom: 2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  size: 11,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'FINAL TEST',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF64748B),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

/// Melukis garis putus-putus zigzag antar pusat node.
class _ZigzagPainter extends CustomPainter {
  final int count;
  final double pitch;
  final double startY;
  final double finalY;

  _ZigzagPainter({
    required this.count,
    required this.pitch,
    required this.startY,
    required this.finalY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final leftX = size.width * 0.13;
    final rightX = size.width * 0.87;
    final centerX = size.width * 0.5;

    double nodeX(int i) => i % 2 == 0 ? leftX : rightX;
    double nodeY(int i) => startY + i * pitch;

    for (int i = 0; i < count - 1; i++) {
      _drawDottedLine(
        canvas,
        Offset(nodeX(i), nodeY(i)),
        Offset(nodeX(i + 1), nodeY(i + 1)),
        paint,
      );
    }

    // Sambungkan node lesson terakhir ke FINAL TEST di tengah.
    if (count > 0) {
      _drawDottedLine(
        canvas,
        Offset(nodeX(count - 1), nodeY(count - 1)),
        Offset(centerX, finalY),
        paint,
      );
    }
  }

  void _drawDottedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const dashWidth = 6.0;
    const dashSpace = 4.0;
    final dx = p2.dx - p1.dx;
    final dy = p2.dy - p1.dy;
    final distance = Offset(dx, dy).distance;
    if (distance <= 0) return;
    final count = (distance / (dashWidth + dashSpace)).floor();

    for (int i = 0; i < count; i++) {
      final startRatio = (i * (dashWidth + dashSpace)) / distance;
      final endRatio = (startRatio * distance + dashWidth) / distance;
      final start = Offset(p1.dx + dx * startRatio, p1.dy + dy * startRatio);
      final end = Offset(p1.dx + dx * endRatio, p1.dy + dy * endRatio);
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ZigzagPainter oldDelegate) =>
      oldDelegate.count != count ||
      oldDelegate.pitch != pitch ||
      oldDelegate.startY != startY ||
      oldDelegate.finalY != finalY;
}
