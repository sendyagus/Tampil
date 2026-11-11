import 'dart:math' as math;
import '../../../services/ai_analysis_service.dart';
import 'ai_consent_screen.dart';
import 'score_detail_screen.dart';
import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final SpeechAnalysisResult? analysisResult;
  final String contextTitle;
  final int score;
  final String scoreLabel;
  final int pointsAdded;
  final int wordsPerMinute;
  final int fillerPerMinute;
  final String poinKunci;
  final String kekuatan;
  final String perluDiperbaiki;
  final int sisaFeedback;
  final int maxFeedback;

  const ResultScreen({
    super.key,
    this.analysisResult,
    this.contextTitle = 'PEER COMMUNICATION',
    this.score = 70,
    this.scoreLabel = 'Baik',
    this.pointsAdded = 6,
    this.wordsPerMinute = 142,
    this.fillerPerMinute = 6,
    this.poinKunci = '3/4',
    this.kekuatan = 'Tempo bicaramu sudah pas.',
    this.perluDiperbaiki = 'Kurangi filler words.',
    this.sisaFeedback = 3,
    this.maxFeedback = 3,
  });

  int get effectiveScore => analysisResult?.communicationIndex ?? score;
  String get effectiveScoreLabel => analysisResult?.scoreLabel ?? scoreLabel;
  int get effectiveWpm => analysisResult?.wordsPerMinute ?? wordsPerMinute;
  int get effectiveFiller => analysisResult?.fillerWordsCount ?? fillerPerMinute;
  String get effectivePoinKunci => analysisResult?.keyPointsRatio ?? poinKunci;
  String get effectiveKekuatan => analysisResult?.strengthText ?? kekuatan;
  String get effectivePerluDiperbaiki => analysisResult?.improvementText ?? perluDiperbaiki;

  static const Color _indigo = Color(0xFF5B50E8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      body: Stack(
        children: [
          // ── Seluruh konten ──
          Column(
            children: [
              // ── Header Ungu ──
              _buildHeader(context),

              // ── Konten Putih ──
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                    child: Column(
                      children: [
                        // Statistik 3 kolom
                        _buildStatsCard(),
                        const SizedBox(height: 12),

                        // Kekuatan
                        _buildInfoCard(
                          iconWidget: _buildIconBox(
                            Icons.thumb_up_rounded,
                            const Color(0xFF0D9488),
                            const Color(0xFFCCFBF1),
                          ),
                          title: 'Kekuatan',
                          subtitle: effectiveKekuatan,
                        ),
                        const SizedBox(height: 10),

                        // Perlu diperbaiki
                        _buildInfoCard(
                          iconWidget: _buildIconBox(
                            Icons.track_changes_rounded,
                            const Color(0xFF7C3AED),
                            const Color(0xFFEDE9FE),
                          ),
                          title: 'Perlu diperbaiki',
                          subtitle: effectivePerluDiperbaiki,
                        ),
                        const SizedBox(height: 10),

                        // Feedback AI
                        _buildFeedbackCard(),
                        const SizedBox(height: 28),

                        // Tombol Tampilkan Feedback AI
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => AiConsentScreen(analysisResult: analysisResult),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _indigo,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Tampilkan Feedback AI',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Link detail skor
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ScoreDetailScreen(
                                  score: effectiveScore,
                                  scoreLabel: effectiveScoreLabel,
                                  analysisResult: analysisResult,
                                ),
                              ),
                            );
                          },
                          child: const Text(
                            'Lihat detail skor',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _indigo,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF6C5FEC), Color(0xFF7B70F2)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          child: Column(
            children: [
              // Close button + Judul
              Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        contextTitle,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Communication Index',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Lingkaran Skor
              _buildScoreCircle(),
              const SizedBox(height: 20),

              // Badge Baik + +6 poin
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Badge "Baik"
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      effectiveScoreLabel,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Badge "+6 poin"
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.arrow_upward_rounded,
                          size: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '+$pointsAdded poin',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  Widget _buildScoreCircle() {
    return SizedBox(
      width: 140,
      height: 140,
      child: CustomPaint(
        painter: _ScoreCirclePainter(score: effectiveScore / 100),
        child: Center(
          child: Text(
            '$effectiveScore',
            style: const TextStyle(
              fontSize: 52,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.0,
              letterSpacing: -2,
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  Widget _buildStatsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          children: [
            _buildStatItem('$effectiveWpm', 'kata/menit'),
            _buildVerticalDivider(),
            _buildStatItem('$effectiveFiller', 'filler/menit'),
            _buildVerticalDivider(),
            _buildStatItem(effectivePoinKunci, 'poin kunci'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF94A3B8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 36,
      color: const Color(0xFFF1F5F9),
    );
  }

  // ─────────────────────────────────────────────
  Widget _buildInfoCard({
    required Widget iconWidget,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          iconWidget,
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    height: 1.35,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 10),
            trailing,
          ],
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  Widget _buildFeedbackCard() {
    return _buildInfoCard(
      iconWidget: _buildIconBox(
        Icons.auto_awesome_rounded,
        const Color(0xFF4F46E5),
        const Color(0xFFEEEDF9),
      ),
      title: 'Feedback AI personal',
      subtitle: 'Dapatkan contoh perbaikan\nkalimat.',
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFEEEDF9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Sisa $sisaFeedback/$maxFeedback hari ini',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4F46E5),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  Widget _buildIconBox(IconData icon, Color iconColor, Color bgColor) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: 22, color: iconColor),
    );
  }
}

// ─────────────────────────────────────────────
/// CustomPainter: Lingkaran skor putih di header ungu
class _ScoreCirclePainter extends CustomPainter {
  final double score; // 0.0 – 1.0

  const _ScoreCirclePainter({required this.score});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = (size.width / 2) - 8;
    const strokeW = 8.0;

    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);

    // Track abu putih transparan
    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(Offset(cx, cy), radius, trackPaint);

    // Arc putih menunjukkan nilai skor
    if (score > 0) {
      final sweepAngle = 2 * math.pi * score;
      final arcPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        rect,
        -math.pi / 2,
        sweepAngle,
        false,
        arcPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ScoreCirclePainter old) => old.score != score;
}
