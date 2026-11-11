import 'package:flutter/material.dart';
import '../../../services/ai_analysis_service.dart';

class ScoreDetailScreen extends StatefulWidget {
  final int score;
  final String scoreLabel;
  final SpeechAnalysisResult? analysisResult;

  const ScoreDetailScreen({
    super.key,
    this.score = 70,
    this.scoreLabel = 'Baik',
    this.analysisResult,
  });

  @override
  State<ScoreDetailScreen> createState() => _ScoreDetailScreenState();
}

class _ScoreDetailScreenState extends State<ScoreDetailScreen> {
  bool _transcriptExpanded = false;

  static const Color _indigo = Color(0xFF4F46E5);
  static const Color _purple = Color(0xFF7C3AED);
  static const Color _teal = Color(0xFF06B6D4);
  static const Color _slate = Color(0xFF64748B);

  List<_ScoreItem> get _scoreItems {
    final b = widget.analysisResult?.breakdown ?? const ScoreBreakdown();
    return [
      _ScoreItem(label: 'Kelancaran jeda', weight: '30%', score: b.kelancaranJeda, isFocus: false),
      _ScoreItem(label: 'Kebersihan ucapan', weight: '25%', score: b.kebersihanUcapan, isFocus: true),
      _ScoreItem(label: 'Tempo', weight: '15%', score: b.tempo, isFocus: false),
      _ScoreItem(label: 'Cakupan isi', weight: '20%', score: b.cakupanIsi, isFocus: false),
      _ScoreItem(label: 'Struktur', weight: '10%', score: b.struktur, isFocus: false),
    ];
  }

  List<_KeyPoint> get _keyPoints {
    final kps = widget.analysisResult?.keyPoints;
    if (kps != null && kps.isNotEmpty) {
      return kps.map((k) => _KeyPoint(text: k.text, done: k.isCovered)).toList();
    }
    return const [
      _KeyPoint(text: 'Menyebutkan konteks masalah secara jelas', done: true),
      _KeyPoint(text: 'Memberikan argumen utama yang runtut', done: true),
      _KeyPoint(text: 'Mengajukan solusi alternatif untuk rekan tim', done: true),
      _KeyPoint(text: 'Menyimpulkan kesepakatan di akhir bicara', done: false),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Konten Scrollable ──
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),

                      // ── Top Bar ──
                      _buildAppBar(context),
                      const SizedBox(height: 20),

                      // ── Score Header ──
                      _buildScoreHeader(),
                      const SizedBox(height: 16),

                      // ── Breakdown Card ──
                      _buildBreakdownCard(),
                      const SizedBox(height: 14),

                      // ── Key Points Card ──
                      _buildKeyPointsCard(),
                      const SizedBox(height: 14),

                      // ── Transkrip ──
                      _buildTranscriptRow(),
                      const SizedBox(height: 14),

                      // ── Lesson Card ──
                      _buildLessonCard(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),

            // ── Tombol Lanjut Belajar ──
            _buildBottomButton(context),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  Widget _buildAppBar(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 1.2,
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 15,
                color: Color(0xFF334155),
              ),
            ),
          ),
        ),
        const Text(
          'Detail skor',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  Widget _buildScoreHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Angka Skor 70
        Text(
          '${widget.score}',
          style: const TextStyle(
            fontSize: 52,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
            letterSpacing: -2,
            height: 1.0,
          ),
        ),
        const SizedBox(width: 12),
        // Badge "Baik"
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFE6FFFA),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF99F6E4),
              width: 1,
            ),
          ),
          child: Text(
            widget.scoreLabel,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0D9488),
            ),
          ),
        ),
        const Spacer(),
        // Label "Communication Index"
        const Text(
          'Communication Index',
          style: TextStyle(
            fontSize: 13,
            color: _slate,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  Widget _buildBreakdownCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: List.generate(_scoreItems.length, (index) {
          final item = _scoreItems[index];
          return Padding(
            padding: EdgeInsets.only(
              top: index == 0 ? 0 : 8,
              bottom: index == _scoreItems.length - 1 ? 0 : 8,
            ),
            child: _buildScoreRow(item),
          );
        }),
      ),
    );
  }

  Widget _buildScoreRow(_ScoreItem item) {
    final fraction = item.score / 100.0;
    final color = item.isFocus ? _purple : _indigo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Label
            Text(
              item.label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(width: 6),
            // Bobot
            Text(
              '· ${item.weight}',
              style: const TextStyle(
                fontSize: 13,
                color: _slate,
                fontWeight: FontWeight.w400,
              ),
            ),
            if (item.isFocus) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Fokus',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _purple,
                  ),
                ),
              ),
            ],
            const Spacer(),
            // Angka skor
            Text(
              '${item.score}',
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                color: item.isFocus ? _purple : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        // Progress Bar
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 6,
            backgroundColor: const Color(0xFFEEF2FF),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  Widget _buildKeyPointsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: _keyPoints.map((kp) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon Centang Teal atau Lingkaran Kosong
                kp.done
                    ? Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: _teal,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 13,
                          color: Colors.white,
                        ),
                      )
                    : Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFCBD5E1),
                            width: 1.8,
                          ),
                        ),
                      ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    kp.text,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: kp.done ? FontWeight.w600 : FontWeight.w400,
                      color: kp.done
                          ? const Color(0xFF0F172A)
                          : const Color(0xFF64748B),
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─────────────────────────────────────────────
  Widget _buildTranscriptRow() {
    return GestureDetector(
      onTap: () => setState(() => _transcriptExpanded = !_transcriptExpanded),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.article_outlined,
                  size: 20,
                  color: _indigo,
                ),
                const SizedBox(width: 10),
                const Text(
                  'Lihat transkrip',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  '(hanya baca)',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: _slate,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Spacer(),
                AnimatedRotation(
                  turns: _transcriptExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 22,
                    color: _slate,
                  ),
                ),
              ],
            ),
            if (_transcriptExpanded) ...[
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 12),
              Text(
                '“${widget.analysisResult?.transcript ?? "Jadi menurut saya, kita bisa mulai membagi tugas lebih spesifik agar setiap orang punya tanggung jawab yang jelas. Bagaimana kalau kita diskusikan solusinya sekarang?"}”',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF475569),
                  height: 1.5,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  Widget _buildLessonCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEDF9),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          // Icon Box Ungu
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _indigo,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: _indigo.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.chrome_reader_mode_rounded,
              size: 22,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          // Info Lesson
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lesson 4: Kebersihan ucapan',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Video 3 menit',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: _slate,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            size: 22,
            color: _indigo,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  Widget _buildBottomButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: _indigo,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
            shadowColor: _indigo.withValues(alpha: 0.35),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                'Lanjut belajar',
                style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward_rounded, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
class _ScoreItem {
  final String label;
  final String weight;
  final int score;
  final bool isFocus;

  const _ScoreItem({
    required this.label,
    required this.weight,
    required this.score,
    required this.isFocus,
  });
}

class _KeyPoint {
  final String text;
  final bool done;

  const _KeyPoint({required this.text, required this.done});
}
