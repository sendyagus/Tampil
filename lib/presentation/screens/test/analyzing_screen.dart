import 'dart:async';
import 'result_screen.dart';
import '../../widgets/test/animated_thinking_mascot_widget.dart';
import '../../../services/ai_analysis_service.dart';
import '../../../services/test_session_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AnalyzingScreen extends StatefulWidget {
  /// Callback ketika analisis selesai
  final VoidCallback? onAnalysisComplete;
  final String caseId;
  final String? audioPath;

  const AnalyzingScreen({
    super.key,
    this.onAnalysisComplete,
    this.caseId = 'proyek_terlambat',
    this.audioPath,
  });

  @override
  State<AnalyzingScreen> createState() => _AnalyzingScreenState();
}

class _AnalyzingScreenState extends State<AnalyzingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinnerController;

  // Step state: 0 = step 1 selesai, step 2 berjalan (sesuai desain Figma)
  // Bisa bertahap maju
  int _currentStep = 1; // 0 = step 1 aktif, 1 = step 2 aktif (seperti gambar), 2 = step 3 aktif

  Timer? _stepTimer;

  @override
  void initState() {
    super.initState();
    _spinnerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();

    _startAnalysis();
  }

  Future<void> _startAnalysis() async {
    // Step 1: Ubah suara jadi teks
    if (mounted) setState(() => _currentStep = 1);

    debugPrint('[AnalyzingScreen] Memulai analisis dengan audioPath: ${widget.audioPath}');

    // Panggil mesin AI (Groq FastAPI / fallback cerdas)
    final result = await AiAnalysisService.instance.analyzeRecording(
      audioPath: widget.audioPath,
      caseId: widget.caseId,
    );

    if (!mounted) return;
    // Step 2: Hitung matrix bicara
    setState(() => _currentStep = 2);

    await Future.delayed(const Duration(milliseconds: 600));

    // Simpan hasil sesi test ke Firebase Firestore (jika user login)
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await TestSessionService().saveAnalysisResult(
          userId: user.uid,
          caseId: widget.caseId,
          tipe: 'test',
          result: result,
        );
      }
    } catch (_) {}

    if (!mounted) return;
    widget.onAnalysisComplete?.call();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ResultScreen(analysisResult: result),
      ),
    );
  }

  @override
  void dispose() {
    _spinnerController.dispose();
    _stepTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 1),

              // ── Maskot Robot Pikir Animasi Hidup ──
              const Center(
                child: AnimatedThinkingMascotWidget(
                  height: 215,
                ),
              ),
              const SizedBox(height: 20),

              // ── Judul ──
              const Text(
                'Menganalisis jawabanmu...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),

              // ── Subjudul ──
              const Text(
                'Biasanya hanya sekitar 20 detik',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 32),

              // ── Kartu Checklist Progres Analisis ──
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Step 1: Mengubah suara jadi teks (Sudah selesai / centang hijau-teal)
                    _buildStepItem(
                      index: 0,
                      title: 'Mengubah suara jadi teks',
                      status: _currentStep > 0
                          ? _StepStatus.completed
                          : _StepStatus.active,
                    ),

                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFF1F5F9),
                    ),

                    // Step 2: Menghitung matrix bicara (Sedang berjalan / spinner ungu)
                    _buildStepItem(
                      index: 1,
                      title: 'Menghitung matrix bicara',
                      status: _currentStep > 1
                          ? _StepStatus.completed
                          : (_currentStep == 1
                              ? _StepStatus.active
                              : _StepStatus.pending),
                    ),

                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFF1F5F9),
                    ),

                    // Step 3: Menyusun hasil (Pending / abu-abu)
                    _buildStepItem(
                      index: 2,
                      title: 'Menyusun hasil',
                      status: _currentStep >= 2
                          ? _StepStatus.active
                          : _StepStatus.pending,
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // ── Footer Privasi & Keamanan ──
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.lock_outline_rounded,
                        size: 15,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Rekamanmu aman dan dihapus otomatis setelah 30 hari',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.w400,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  Widget _buildStepItem({
    required int index,
    required String title,
    required _StepStatus status,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        children: [
          // Icon status (Centang teal, Spinner ungu, atau Lingkaran abu)
          _buildLeadingIcon(status),
          const SizedBox(width: 14),

          // Teks Judul
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: status == _StepStatus.active
                    ? FontWeight.w700
                    : (status == _StepStatus.completed
                        ? FontWeight.w600
                        : FontWeight.w500),
                color: status == _StepStatus.pending
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  Widget _buildLeadingIcon(_StepStatus status) {
    switch (status) {
      case _StepStatus.completed:
        // Lingkaran solid Teal dengan Centang Putih
        return Container(
          width: 26,
          height: 26,
          decoration: const BoxDecoration(
            color: Color(0xFF06B6D4), // Teal cerah sesuai desain
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.check_rounded,
              size: 16,
              color: Colors.white,
            ),
          ),
        );

      case _StepStatus.active:
        // Lingkaran Ungu solid dengan animasi busur loading putih
        return Container(
          width: 26,
          height: 26,
          decoration: const BoxDecoration(
            color: Color(0xFF4F46E5), // Indigo / Ungu Tampil
            shape: BoxShape.circle,
          ),
          child: Center(
            child: RotationTransition(
              turns: _spinnerController,
              child: SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  backgroundColor: Colors.white.withValues(alpha: 0.25),
                ),
              ),
            ),
          ),
        );

      case _StepStatus.pending:
        // Lingkaran border abu tipis, tengah kosong
        return Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFCBD5E1),
              width: 1.8,
            ),
          ),
        );
    }
  }
}

enum _StepStatus {
  completed,
  active,
  pending,
}
