import 'package:flutter/material.dart';

class HasilTerakhirWidget extends StatelessWidget {
  final int score;
  final int maxScore;
  final String statusLabel;
  final String pointsAdded;
  final VoidCallback? onRetestPressed;

  const HasilTerakhirWidget({
    super.key,
    this.score = 68,
    this.maxScore = 100,
    this.statusLabel = 'Baik',
    this.pointsAdded = '+6 poin ↑',
    this.onRetestPressed,
  });

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
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Header: HASIL TERAKHIR + +6 poin tag
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'HASIL TERAKHIR',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF94A3B8),
                  letterSpacing: 0.8,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F7FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  pointsAdded,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00ACC1),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Middle Section: Score + Sparkline Chart
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Left: Score & Label
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$score',
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                            height: 1.0,
                          ),
                        ),
                        Text(
                          ' /$maxScore',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF94A3B8),
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
                            statusLabel,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00ACC1),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Communication Index',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              // Right: Sparkline Line Graph
              Expanded(
                flex: 4,
                child: SizedBox(
                  height: 48,
                  child: CustomPaint(
                    painter: _SparklinePainter(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Bottom Button: Tes Ulang
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onRetestPressed,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.autorenew_rounded,
                    size: 18,
                    color: Color(0xFF6366F1),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Tes ulang',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6366F1),
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
}

class _SparklinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final fillPath = Path();

    // Line curve points matching the screenshot sparkline curve
    final p0 = Offset(0, size.height * 0.85);
    final p1 = Offset(size.width * 0.35, size.height * 0.65);
    final p2 = Offset(size.width * 0.7, size.height * 0.35);
    final p3 = Offset(size.width * 0.85, size.height * 0.45);
    final p4 = Offset(size.width, size.height * 0.15);

    path.moveTo(p0.dx, p0.dy);
    path.quadraticBezierTo(p1.dx, p1.dy, size.width * 0.5, size.height * 0.5);
    path.cubicTo(
      p2.dx,
      p2.dy,
      p3.dx,
      p3.dy,
      p4.dx,
      p4.dy,
    );

    // Fill area below curve
    fillPath.addPath(path, Offset.zero);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    final fillGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF6366F1).withOpacity(0.2),
        const Color(0xFF6366F1).withOpacity(0.0),
      ],
    );

    final fillPaint = Paint()
      ..shader = fillGradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Stroke line paint
    final linePaint = Paint()
      ..color = const Color(0xFF6366F1)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);

    // End point circle dot
    final dotPaint = Paint()
      ..color = const Color(0xFF6366F1)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(p4, 4.0, dotPaint);

    final innerDotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(p4, 1.8, innerDotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
