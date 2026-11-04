import 'package:flutter/material.dart';

class AiFeedbackScreen extends StatefulWidget {
  final int remainingFeedback;
  final int maxFeedback;
  final String strengthText;
  final String improvementText;
  final String quoteSample;
  final String suggestionText;
  final String nextLessonTitle;

  const AiFeedbackScreen({
    super.key,
    this.remainingFeedback = 2,
    this.maxFeedback = 3,
    this.strengthText = 'Kamu langsung menyebut ide utama di awal.',
    this.improvementText = 'Kurangi filler saat berpikir.',
    this.quoteSample = '“eee, jadi menurutku, eee...”',
    this.suggestionText =
        '“Menurutku, idenya perlu diuji dulu karena waktunya terbatas.”',
    this.nextLessonTitle = 'Belajar Lesson 2',
  });

  @override
  State<AiFeedbackScreen> createState() => _AiFeedbackScreenState();
}

class _AiFeedbackScreenState extends State<AiFeedbackScreen> {
  int _selectedRating = 0; // 0 = belum rating, 1-5 bintang

  static const Color _indigo = Color(0xFF4F46E5);
  static const Color _indigoLight = Color(0xFFEEEDF9);
  static const Color _slate = Color(0xFF64748B);
  static const Color _teal = Color(0xFF0D9488);
  static const Color _purple = Color(0xFF7C3AED);

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
                      _buildTopBar(context),
                      const SizedBox(height: 24),

                      // ── Card 1: Kekuatan ──
                      _buildStrengthCard(),
                      const SizedBox(height: 14),

                      // ── Card 2: Area perbaikan ──
                      _buildImprovementCard(),
                      const SizedBox(height: 14),

                      // ── Card 3: Coba Ucapkan Seperti Ini ──
                      _buildSuggestionCard(),
                      const SizedBox(height: 28),

                      // ── Feedback ini membantu? (Star Rating) ──
                      _buildRatingSection(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),

            // ── Bagian Bawah: Tombol Belajar Lesson & Kembali ──
            _buildBottomButtons(context),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  Widget _buildTopBar(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Tombol Back lingkaran
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

        // Judul tengah
        const Text(
          'Feedback AI',
          style: TextStyle(
            fontSize: 17.5,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),

        // Badge Sisa 2/3 di kanan
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _indigoLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  size: 13,
                  color: _indigo,
                ),
                const SizedBox(width: 5),
                Text(
                  'Sisa ${widget.remainingFeedback}/${widget.maxFeedback}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _indigo,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  Widget _buildStrengthCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon jempol mint/teal
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFE6FFFA),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.thumb_up_alt_outlined,
              size: 21,
              color: _teal,
            ),
          ),
          const SizedBox(width: 14),
          // Teks
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kekuatan',
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.strengthText,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: _slate,
                    height: 1.35,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  Widget _buildImprovementCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon target ungu
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFF3E8FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.track_changes_rounded,
                  size: 22,
                  color: _purple,
                ),
              ),
              const SizedBox(width: 14),
              // Teks
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Area perbaikan',
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.improvementText,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: _slate,
                        height: 1.35,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Box kutipan filler
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0EEFF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.quoteSample,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  Widget _buildSuggestionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EEFF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Lampu Kuning + Judul
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF3C7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lightbulb_rounded,
                  size: 18,
                  color: Color(0xFFF59E0B),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'COBA UCAPKAN SEPERTI INI',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: _indigo,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Teks Saran
          Text(
            widget.suggestionText,
            style: const TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  Widget _buildRatingSection() {
    return Column(
      children: [
        // "Feedback ini membantu?" + Bintang
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Feedback ini membantu?',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF475569),
              ),
            ),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (index) {
                final starIndex = index + 1;
                final isFilled = starIndex <= _selectedRating;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedRating = starIndex;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Icon(
                      isFilled
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      size: 20,
                      color: isFilled
                          ? const Color(0xFFF59E0B)
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Catatan Info AI
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.info_outline_rounded,
                  size: 13.5,
                  color: Color(0xFF94A3B8),
                ),
              ),
              SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Dibuat oleh AI dari transkripmu. Skor tetap dihitung dengan rumus.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF94A3B8),
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  Widget _buildBottomButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tombol Belajar Lesson 2
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () {
                // Navigasi ke materi belajar
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _indigo,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 0,
                shadowColor: _indigo.withValues(alpha: 0.35),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.nextLessonTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Tombol Kembali ke hasil
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Kembali ke hasil',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _indigo,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
