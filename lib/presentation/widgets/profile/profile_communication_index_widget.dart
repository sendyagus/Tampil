import 'package:flutter/material.dart';

class ProfileCommunicationIndexWidget extends StatefulWidget {
  final int score;
  final String statusLabel;
  final String pointsAdded;

  /// Skor communication index per tes, urut tertua -> terbaru (dari
  /// collection test_sessions). Dipakai untuk menggambar grafik tren nyata.
  final List<int> scoreHistory;

  const ProfileCommunicationIndexWidget({
    super.key,
    this.score = 0,
    this.statusLabel = 'Belum ada data',
    this.pointsAdded = '',
    this.scoreHistory = const [],
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
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
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
              // Badge selisih poin; disembunyikan bila belum ada data.
              if (widget.pointsAdded.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
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

          // Chart Section — grafik tren NYATA dari riwayat tes user
          _buildChart(),
          const SizedBox(height: 8),

          // X-Axis Labels Row — dibuat dinamis dari jumlah tes
          _buildAxisLabels(),
        ],
      ),
    );
  }

  Widget _buildChart() {
    final history = widget.scoreHistory;
    if (history.length < 2) {
      // Belum cukup data untuk tren; tampilkan placeholder netral.
      return Container(
        height: 70,
        alignment: Alignment.center,
        child: Text(
          history.isEmpty
              ? 'Belum ada riwayat tes.'
              : 'Grafik tren muncul setelah minimal 2 tes.',
          style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
        ),
      );
    }
    return SizedBox(
      height: 70,
      width: double.infinity,
      child: CustomPaint(painter: _ProfileChartPainter(history)),
    );
  }

  Widget _buildAxisLabels() {
    final history = widget.scoreHistory;
    if (history.length < 2) return const SizedBox.shrink();

    // Maksimal 6 label, disebar merata di sepanjang sumbu.
    final count = history.length <= 6 ? history.length : 6;
    final labels = <Widget>[];
    for (int i = 0; i < count; i++) {
      final idx = (i * (history.length - 1) / (count - 1)).round();
      final isLast = i == count - 1;
      labels.add(
        Text(
          isLast ? 'Terbaru' : 'Tes ${idx + 1}',
          style: TextStyle(
            fontSize: 11,
            fontWeight: isLast ? FontWeight.bold : FontWeight.w400,
            color: isLast ? const Color(0xFF6366F1) : const Color(0xFF94A3B8),
          ),
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: labels,
    );
  }
}

class _ProfileChartPainter extends CustomPainter {
  /// Skor communication index (0-100), urut tertua -> terbaru.
  final List<int> values;

  _ProfileChartPainter(this.values);

  @override
  void paint(Canvas canvas, Size size) {
    final n = values.length;
    // Titik grafik NYATA: X tersebar merata, Y dari skor (0-100) dipetakan
    // ke tinggi area dengan padding atas/bawah kecil.
    final points = <Offset>[
      for (int i = 0; i < n; i++)
        Offset(
          n == 1 ? size.width / 2 : size.width * i / (n - 1),
          size.height * 0.9 -
              (values[i].clamp(0, 100) / 100) * size.height * 0.8,
        ),
    ];

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final controlP1 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p1.dy);
      final controlP2 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p2.dy);
      path.cubicTo(
        controlP1.dx,
        controlP1.dy,
        controlP2.dx,
        controlP2.dy,
        p2.dx,
        p2.dy,
      );
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
      ..shader = fillGradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      )
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
  bool shouldRepaint(covariant _ProfileChartPainter oldDelegate) =>
      oldDelegate.values.length != values.length ||
      oldDelegate.values.join(',') != values.join(',');
}
