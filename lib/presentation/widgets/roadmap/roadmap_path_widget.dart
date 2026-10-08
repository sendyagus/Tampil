import 'package:flutter/material.dart';

class RoadmapPathWidget extends StatelessWidget {
  final VoidCallback? onActiveLessonPressed;

  const RoadmapPathWidget({
    super.key,
    this.onActiveLessonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Stack(
        children: [
          // Background Dotted Zigzag Line Painter
          Positioned.fill(
            child: CustomPaint(
              painter: _DottedPathPainter(),
            ),
          ),

          // Foreground Path Nodes Column
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                // 1. LESSON 1 (Left circle, text on right)
                _buildCompletedNode(
                  alignLeft: true,
                  lessonTag: 'LESSON 1',
                  title: 'Clarity',
                  subtitle: 'Selesai · +10 XP',
                ),
                const SizedBox(height: 36),

                // 2. LESSON 2 (Right circle, text on left)
                _buildCompletedNode(
                  alignLeft: false,
                  lessonTag: 'LESSON 2',
                  title: 'Relevance',
                  subtitle: 'Selesai · +10 XP',
                ),
                const SizedBox(height: 36),

                // 3. LESSON 3 (Left circle, text on right)
                _buildCompletedNode(
                  alignLeft: true,
                  lessonTag: 'LESSON 3',
                  title: 'Response',
                  subtitle: 'Selesai · +10 XP',
                ),
                const SizedBox(height: 36),

                // 4. LESSON 4 (Right circle, text on left)
                _buildCompletedNode(
                  alignLeft: false,
                  lessonTag: 'LESSON 4',
                  title: 'Flow',
                  subtitle: 'Selesai · +10 XP',
                ),
                const SizedBox(height: 36),

                // 5. LESSON 5 (Active Step: Left circle with MULAI & Fokus tag)
                _buildActiveNode(
                  onTap: onActiveLessonPressed,
                  lessonTag: 'LESSON 5',
                  title: 'Speaking',
                  subtitle: 'Mengungkapkan ekspresi',
                ),
                const SizedBox(height: 48),

                // 6. FINAL TEST (Center node locked)
                _buildFinalTestNode(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Completed Lesson Node (Teal circle with checkmark)
  Widget _buildCompletedNode({
    required bool alignLeft,
    required String lessonTag,
    required String title,
    required String subtitle,
  }) {
    final circleWidget = Container(
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
    );

    final textWidget = Column(
      crossAxisAlignment:
          alignLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          lessonTag,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Color(0xFF06B6D4),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF94A3B8),
          ),
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: alignLeft
            ? [
                circleWidget,
                const SizedBox(width: 16),
                Expanded(child: textWidget),
              ]
            : [
                Expanded(child: textWidget),
                const SizedBox(width: 16),
                circleWidget,
              ],
      ),
    );
  }

  // Active Lesson Node (Purple play button with MULAI badge and Fokus tag)
  Widget _buildActiveNode({
    VoidCallback? onTap,
    required String lessonTag,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active Node Stack (MULAI badge + Play Circle)
          Column(
            children: [
              // ● MULAI Badge above active node
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFC7D2FE), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF6366F1),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
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

              // Active Node Play Circle
              GestureDetector(
                onTap: onTap,
                child: Container(
                  width: 56,
                  height: 56,
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
                    size: 32,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),

          // Active Lesson Info & Fokus Tag
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        lessonTag,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6366F1),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Fokus',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD97706),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Final Test Center Locked Node
  Widget _buildFinalTestNode() {
    return Column(
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
        const SizedBox(height: 10),
        const Text(
          'FINAL TEST',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF64748B),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Syarat lulus CI ≥ 60',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }
}

// Custom Painter for drawing the Dotted Connecting Line between nodes
class _DottedPathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    // Approximated center points of each node along the zigzag path
    final leftX = size.width * 0.12;
    final rightX = size.width * 0.88;
    final centerX = size.width * 0.5;

    final y1 = 43.0; // Lesson 1 center
    final y2 = 125.0; // Lesson 2 center
    final y3 = 207.0; // Lesson 3 center
    final y4 = 289.0; // Lesson 4 center
    final y5 = 390.0; // Lesson 5 center
    final y6 = 510.0; // Final test center

    // Segment 1: Left to Right
    _drawDottedLine(canvas, Offset(leftX, y1), Offset(rightX, y2), paint);
    // Segment 2: Right to Left
    _drawDottedLine(canvas, Offset(rightX, y2), Offset(leftX, y3), paint);
    // Segment 3: Left to Right
    _drawDottedLine(canvas, Offset(leftX, y3), Offset(rightX, y4), paint);
    // Segment 4: Right to Left
    _drawDottedLine(canvas, Offset(rightX, y4), Offset(leftX, y5), paint);
    // Segment 5: Left to Center (Final Test)
    _drawDottedLine(canvas, Offset(leftX, y5), Offset(centerX, y6), paint);
  }

  void _drawDottedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const dashWidth = 6.0;
    const dashSpace = 4.0;
    final dx = p2.dx - p1.dx;
    final dy = p2.dy - p1.dy;
    final distance = (Offset(dx, dy)).distance;
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
