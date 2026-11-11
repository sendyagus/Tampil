import 'package:flutter/material.dart';

class ProfileCommunicationIndexWidget extends StatefulWidget {
  final int score;
  final String statusLabel;
  final String pointsAdded;

  const ProfileCommunicationIndexWidget({
    super.key,
    this.score = 68,
    this.statusLabel = 'Baik',
    this.pointsAdded = '↗ +8 poin',
  });

  @override
  State<ProfileCommunicationIndexWidget> createState() =>
      _ProfileCommunicationIndexWidgetState();
}

class _ProfileCommunicationIndexWidgetState
    extends State<ProfileCommunicationIndexWidget> {
  String _selectedTab = 'Total';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Bar: Title & Filter Tabs
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'COMMUNICATION INDEX',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF94A3B8),
                  letterSpacing: 0.5,
                ),
              ),
              Row(
                children: ['Total', 'Clarity', 'Flow'].map((tab) {
                  final isSelected = tab == _selectedTab;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedTab = tab),
                    child: Container(
                      margin: const EdgeInsets.only(left: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF6366F1)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tab,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Score & Improvement Tag Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${widget.score}',
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                      height: 1.0,
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
                      widget.statusLabel,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00ACC1),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F7FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.pointsAdded,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00ACC1),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Chart Section
          SizedBox(
            height: 70,
            width: double.infinity,
            child: CustomPaint(
              painter: _ProfileChartPainter(),
            ),
          ),
          const SizedBox(height: 8),

          // X-Axis Labels Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Tes 1', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
              Text('Tes 3', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
              Text('Tes 5', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
              Text('Tes 8', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
              Text('Tes 10', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
              Text(
                'Terbaru',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6366F1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final points = [
      Offset(0, size.height * 0.75),
      Offset(size.width * 0.2, size.height * 0.65),
      Offset(size.width * 0.4, size.height * 0.55),
      Offset(size.width * 0.6, size.height * 0.50),
      Offset(size.width * 0.8, size.height * 0.40),
      Offset(size.width, size.height * 0.20),
    ];

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final controlP1 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p1.dy);
      final controlP2 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p2.dy);
      path.cubicTo(controlP1.dx, controlP1.dy, controlP2.dx, controlP2.dy, p2.dx, p2.dy);
    }

    // Fill path below
    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    final fillGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF6366F1).withValues(alpha: 0.2),
        const Color(0xFF6366F1).withValues(alpha: 0.0),
      ],
    );

    final fillPaint = Paint()
      ..shader = fillGradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Line paint
    final linePaint = Paint()
      ..color = const Color(0xFF6366F1)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);

    // Draw dots at each point
    final dotPaint = Paint()
      ..color = const Color(0xFF6366F1)
      ..style = PaintingStyle.fill;

    final innerDotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      final isLast = i == points.length - 1;
      final radius = isLast ? 4.5 : 3.0;
      canvas.drawCircle(p, radius, dotPaint);
      canvas.drawCircle(p, radius * 0.5, innerDotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
