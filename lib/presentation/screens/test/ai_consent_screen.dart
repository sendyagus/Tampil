import 'package:flutter/material.dart';
import '../../../services/ai_analysis_service.dart';
import 'ai_feedback_screen.dart';

/// Screen consent pemrosesan AI pihak ketiga (Groq).
/// Muncul setelah MicrophonePermissionScreen, sebelum RecordingScreen.
class AiConsentScreen extends StatefulWidget {
  final SpeechAnalysisResult? analysisResult;

  const AiConsentScreen({
    super.key,
    this.analysisResult,
  });

  @override
  State<AiConsentScreen> createState() => _AiConsentScreenState();
}

class _AiConsentScreenState extends State<AiConsentScreen> {
  bool _isChecked = false;

  static const Color _indigo = Color(0xFF4F46E5);
  static const Color _indigoLight = Color(0xFFEEEDF9);
  static const Color _slate = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Konten utama (scrollable) ──
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // ── Tombol Back ──
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Icon Sparkle ──
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: _indigoLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.auto_awesome_rounded,
                          size: 28,
                          color: _indigo,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Judul ──
                    const Text(
                      'Pemrosesan AI pihak\nketiga',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        height: 1.2,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ── Subtitle ──
                    const Text(
                      'Agar suaramu bisa diubah jadi teks dan feedback.',
                      style: TextStyle(
                        fontSize: 14.5,
                        color: _slate,
                        height: 1.45,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Card Info ──
                    _buildInfoCard(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // ── Bottom Section: Checkbox + Tombol Lanjut ──
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Row 1: Audio + Groq
          _buildInfoRow(
            icon: Icons.cloud_outlined,
            content: RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF334155),
                  height: 1.45,
                  fontWeight: FontWeight.w400,
                ),
                children: [
                  TextSpan(text: 'Audio dan transkrip diproses oleh\npenyedia AI bernama '),
                  TextSpan(
                    text: 'Groq',
                    style: TextStyle(
                      color: Color(0xFF4F46E5),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Divider
          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

          // Row 2: Globe
          _buildInfoRow(
            icon: Icons.language_rounded,
            content: const Text(
              'Data bisa dikirim ke server di luar negeri',
              style: TextStyle(
                fontSize: 13.5,
                color: Color(0xFF334155),
                height: 1.45,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),

          // Divider
          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

          // Row 3: Person-off
          _buildInfoRow(
            icon: Icons.person_off_outlined,
            content: const Text(
              'Nama dan emailmu tidak ikut dikirim',
              style: TextStyle(
                fontSize: 13.5,
                color: Color(0xFF334155),
                height: 1.45,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  Widget _buildInfoRow({
    required IconData icon,
    required Widget content,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: const Color(0xFF94A3B8),
          ),
          const SizedBox(width: 14),
          Expanded(child: content),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        children: [
          // ── Checkbox Row ──
          GestureDetector(
            onTap: () => setState(() => _isChecked = !_isChecked),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _isChecked
                      ? _indigo.withValues(alpha: 0.4)
                      : const Color(0xFFE2E8F0),
                  width: 1.3,
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
                children: [
                  // Custom Checkbox
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: _isChecked ? _indigo : Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _isChecked ? _indigo : const Color(0xFFCBD5E1),
                        width: 1.8,
                      ),
                    ),
                    child: _isChecked
                        ? const Icon(
                            Icons.check_rounded,
                            size: 14,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'Saya mengizinkan pemrosesan AI pihak ketiga',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // ── Tombol Lanjut ──
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _isChecked
                  ? () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => AiFeedbackScreen(
                            strengthText: widget.analysisResult?.strengthText ?? 'Kamu langsung menyebut ide utama di awal.',
                            improvementText: widget.analysisResult?.improvementText ?? 'Kurangi filler saat berpikir.',
                            quoteSample: widget.analysisResult?.quoteSample ?? '“eee, jadi menurutku, eee...”',
                            suggestionText: widget.analysisResult?.suggestionText ?? '“Menurutku, idenya perlu diuji dulu karena waktunya terbatas.”',
                            nextLessonTitle: widget.analysisResult?.nextLessonTitle ?? 'Belajar Lesson 2',
                          ),
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _indigo,
                disabledBackgroundColor: const Color(0xFFCBD5E1),
                foregroundColor: Colors.white,
                disabledForegroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Lanjut',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
