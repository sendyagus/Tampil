import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'analyzing_screen.dart';
import '../../widgets/test/animated_mascot_widget.dart';

class RecordingScreen extends StatefulWidget {
  final String contextTitle;
  final String caseTitle;
  final String caseDescription;
  final String casePrompt;
  final String caseNumber;
  final String caseId;
  final String caseBadge;
  final int maxDurationSeconds;
  final int maxRetakes;

  const RecordingScreen({
    super.key,
    this.caseId = 'proyek_terlambat',
    this.contextTitle = 'PEER COMMUNICATION',
    this.caseTitle = 'Menyela diskusi dengan sopan',
    this.caseDescription =
        'Kamu di diskusi kelompok. Temanmu terus bicara,\npadahal kamu punya ide penting.',
    this.casePrompt = 'Sampaikan idemu dengan sopan dan jelas.',
    this.caseNumber = 'Kasus #02',
    this.caseBadge = 'Studi kasus',
    this.maxDurationSeconds = 120,
    this.maxRetakes = 2,
  });

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen>
    with TickerProviderStateMixin {
  static const Color _primaryIndigo = Color(0xFF4F46E5);

  // ── State ──
  bool _hasStarted = false; // false = maskot, true = timer & waveform
  bool _isRecording = false;
  bool _isPaused = false;
  int _elapsedSeconds = 0;
  int _retakeCount = 0;

  Timer? _timer;
  late AnimationController _waveController;
  late final AudioRecorder _audioRecorder;
  StreamSubscription<Amplitude>? _amplitudeSub;
  double _currentVolume = 0.0; // 0.0 (diam/hening/datar) sampai 1.0 (bicara lantang)
  double _noiseFloor = -42.0; // Baseline desis suara ruangan dinamis
  int _initSampleCount = 0; // Sampel awal untuk kalibrasi hening awal
  int _silenceFrames = 0; // Penghitung frame berturut-turut saat tidak bersuara
  int _logTick = 0;
  String? _recordedAudioPath;

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _amplitudeSub?.cancel();
    _waveController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  // ── Logic ──
  Future<void> _startRecording() async {
    setState(() {
      _hasStarted = true;
      _isRecording = true;
      _isPaused = false;
      _currentVolume = 0.0;
      _noiseFloor = -42.0;
      _initSampleCount = 0;
      _silenceFrames = 0;
      _logTick = 0;
    });
    _waveController.repeat();

    try {
      if (await _audioRecorder.hasPermission()) {
        String path = '';
        if (!kIsWeb) {
          final tempDir = await getTemporaryDirectory();
          path = '${tempDir.path}/rekaman_${DateTime.now().millisecondsSinceEpoch}.wav';
        }
        final encoder = kIsWeb ? AudioEncoder.opus : AudioEncoder.wav;
        await _audioRecorder.start(
          RecordConfig(
            encoder: encoder,
            numChannels: 1,
            autoGain: true,
            echoCancel: true,
            noiseSuppress: true,
          ),
          path: path,
        );

        // Pantau volume mikrofon secara real-time setiap 50ms
        _amplitudeSub?.cancel();
        _amplitudeSub = _audioRecorder
            .onAmplitudeChanged(const Duration(milliseconds: 50))
            .listen((amp) {
          if (!mounted || _isPaused || !_isRecording) return;
          final db = amp.current; // dBFS: -160 s/d 0
          if (db < -120.0 || db.isNaN || db.isInfinite) return;

          // 1. Kalibrasi desis awal ruangan (~400ms pertama saat mulai di 2:00)
          // Menjaga gelombang tetap 100% rata tanpa false trigger
          if (_initSampleCount < 8) {
            _initSampleCount++;
            if (_initSampleCount == 1) {
              _noiseFloor = db;
            } else {
              _noiseFloor = _noiseFloor * 0.6 + db * 0.4;
            }
            if (_currentVolume != 0.0) {
              setState(() => _currentVolume = 0.0);
            }
            return;
          }

          // 2. Adaptive Noise Floor Tracking (mengikuti kipas/desis ruangan & AGC)
          if (db < _noiseFloor) {
            _noiseFloor = _noiseFloor * 0.5 + db * 0.5;
          } else {
            _noiseFloor = _noiseFloor * 0.99 + db * 0.01;
          }
          _noiseFloor = _noiseFloor.clamp(-55.0, -22.0);

          // 3. Deteksi Suara Vokal Manusia Nyata (VAD)
          // a. Delta suara harus minimal 7.0 dB lebih tinggi dari noise floor berjalan
          // b. Level mutlak minimal -27.0 dBFS (mencegah desis fan/nafas mikrofon dianggap vokal)
          final delta = db - _noiseFloor;
          final bool isVoice = (delta >= 7.0) && (db >= -27.0);

          double target = 0.0;
          if (isVoice) {
            _silenceFrames = 0;
            // Skala kekuatan vokal mulus (delta 7 dB s/d 21 dB -> 0.3 s/d 1.0)
            final vocalPower = ((delta - 7.0) / 14.0).clamp(0.0, 1.0);
            target = 0.3 + (0.7 * vocalPower);
          } else {
            _silenceFrames++;
            // Jika hening >= 2 frame (~100ms), target langsung 0.0 mutlak
            if (_silenceFrames >= 2) {
              target = 0.0;
            }
          }

          if (++_logTick % 20 == 0) {
            debugPrint('[MIC] dB: ${db.toStringAsFixed(1)}, floor: ${_noiseFloor.toStringAsFixed(1)}, isVoice: $isVoice, vol: ${_currentVolume.toStringAsFixed(2)}');
          }

          setState(() {
            if (target > 0.0) {
              // Bicara: Gelombang melompat responsif (attack 50ms)
              _currentVolume = _currentVolume * 0.25 + target * 0.75;
            } else {
              // Berhenti bicara / Diam: Gelombang rontok seketika (decay cepat ~100ms)
              _currentVolume = _currentVolume * 0.2;
              if (_currentVolume < 0.05) _currentVolume = 0.0;
            }
          });
        });
      }
    } catch (e) {
      debugPrint('[RecordingScreen] Error start audio recording: $e');
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_elapsedSeconds < widget.maxDurationSeconds) {
        setState(() => _elapsedSeconds++);
      } else {
        _stopRecording();
      }
    });
  }

  Future<void> _pauseRecording() async {
    _timer?.cancel();
    _waveController.stop();
    _amplitudeSub?.pause();
    try {
      await _audioRecorder.pause();
    } catch (_) {}
    setState(() {
      _isPaused = true;
      _currentVolume = 0.0;
    });
  }

  Future<void> _resumeRecording() async {
    _waveController.repeat();
    _amplitudeSub?.resume();
    try {
      await _audioRecorder.resume();
    } catch (_) {}
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_elapsedSeconds < widget.maxDurationSeconds) {
        setState(() => _elapsedSeconds++);
      } else {
        _stopRecording();
      }
    });
    setState(() => _isPaused = false);
  }

  Future<String?> _stopRecording() async {
    _timer?.cancel();
    _waveController.stop();
    _amplitudeSub?.cancel();
    _amplitudeSub = null;
    String? path;
    try {
      path = await _audioRecorder.stop();
      _recordedAudioPath = path;
      debugPrint('[RecordingScreen] Rekaman selesai disimpan ke: $path');
    } catch (e) {
      debugPrint('[RecordingScreen] Error stop audio recording: $e');
    }
    setState(() {
      _isRecording = false;
      _isPaused = false;
      _currentVolume = 0.0;
    });
    return path;
  }

  Future<void> _retake() async {
    if (_retakeCount >= widget.maxRetakes) return;
    _timer?.cancel();
    _waveController.stop();
    _amplitudeSub?.cancel();
    _amplitudeSub = null;
    try {
      await _audioRecorder.cancel();
    } catch (_) {}
    setState(() {
      _elapsedSeconds = 0;
      _retakeCount++;
      _isRecording = false;
      _isPaused = false;
      _hasStarted = false;
      _recordedAudioPath = null;
      _currentVolume = 0.0;
      _noiseFloor = -42.0;
      _initSampleCount = 0;
      _silenceFrames = 0;
    });
  }

  Future<void> _selesai() async {
    final path = await _stopRecording();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => AnalyzingScreen(
          caseId: widget.caseId,
          audioPath: path ?? _recordedAudioPath,
        ),
      ),
    );
  }

  // ── Helpers ──
  String _formatElapsed(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final sec = (s % 60).toString().padLeft(2, '0');
    return '$m:$sec';
  }

  String _formatRemaining(int s) {
    final rem = widget.maxDurationSeconds - s;
    final m = rem ~/ 60;
    final sec = (rem % 60).toString().padLeft(2, '0');
    return '$m:$sec';
  }

  double get _progressFraction =>
      _elapsedSeconds / widget.maxDurationSeconds;

  double get _remainingFraction => 1.0 - _progressFraction;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar ──
            _buildTopBar(),

            // ── Progress Bar ──
            _buildProgressBar(),

            // ── Konten Utama ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _hasStarted
                    ? LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            physics: const ClampingScrollPhysics(),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight,
                              ),
                              child: IntrinsicHeight(
                                child: Column(
                                  children: [
                                    const SizedBox(height: 6),
                                    _buildCaseCard(),
                                    const SizedBox(height: 12),
                                    const Spacer(flex: 3),

                                    // Countdown Timer Lingkaran
                                    _buildCircularTimer(
                                        key: const ValueKey('timer')),
                                    const SizedBox(height: 12),

                                    // Badge "Merekam"
                                    _buildRecordingBadge(),
                                    const SizedBox(height: 12),

                                    // Waveform Audio Ramping Sesuai Gambar 1
                                    _buildWaveform(),
                                    const SizedBox(height: 8),

                                    // Hint text
                                    _buildHintRow(),

                                    // Spacer fleksibel: Mendorong tombol ke posisi paling bawah
                                    const Spacer(flex: 4),

                                    // Tombol Kontrol (Jeda, Selesai, Ulang)
                                    _buildRecordingControls(),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : Column(
                        children: [
                          const SizedBox(height: 6),
                          _buildCaseCard(),

                          // Robot di tengah-tengah ruang kosong
                          Expanded(
                            child: Center(
                              child:
                                  _buildMascot(key: const ValueKey('mascot')),
                            ),
                          ),

                          // Tombol Mulai di bagian bawah
                          _buildStartButton(),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 1.2,
                ),
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 18,
                color: Color(0xFF475569),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.contextTitle,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF475569),
                letterSpacing: 0.8,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEEEDF9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.refresh_rounded,
                  size: 14,
                  color: Color(0xFF4F46E5),
                ),
                const SizedBox(width: 4),
                Text(
                  'Rekam ulang: ${widget.maxRetakes - _retakeCount}×',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4F46E5),
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
  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 2),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _progressFraction,
              minHeight: 4.5,
              backgroundColor: const Color(0xFFEEF2FF),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(_primaryIndigo),
            ),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatElapsed(_elapsedSeconds),
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: _primaryIndigo,
                ),
              ),
              Text(
                'Maks ${_formatElapsed(widget.maxDurationSeconds)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  Widget _buildCaseCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8E6FF), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEEDF9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  widget.caseBadge,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: _primaryIndigo,
                  ),
                ),
              ),
              Text(
                widget.caseNumber,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.caseTitle,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              height: 1.25,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.caseDescription,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF64748B),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F7FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🤖', style: TextStyle(fontSize: 15)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.casePrompt,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF334155),
                      fontWeight: FontWeight.w500,
                      height: 1.35,
                    ),
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
  /// STATE 1 — Maskot (sebelum tekan Mulai)
  Widget _buildMascot({Key? key}) {
    return AnimatedMascotWidget(
      key: key,
      height: 200,
      showSpeechBubble: true,
    );
  }

  // ─────────────────────────────────────────────
  /// STATE 2 — Countdown Timer Lingkaran (diameter 165px proporsional)
  Widget _buildCircularTimer({Key? key}) {
    return SizedBox(
      key: key,
      height: 165,
      width: 165,
      child: CustomPaint(
        painter: _CircleTimerPainter(
          fraction: _remainingFraction,
          isPaused: _isPaused,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatRemaining(_elapsedSeconds),
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  height: 1.0,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                'sisa waktu',
                style: TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  /// Badge "Merekam" dengan tema Mint/Teal
  Widget _buildRecordingBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: _isRecording && !_isPaused
            ? const Color(0xFFE6FFFA)
            : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: _isRecording && !_isPaused
              ? const Color(0xFF99F6E4)
              : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _isRecording && !_isPaused
                  ? const Color(0xFF0D9488)
                  : const Color(0xFF94A3B8),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            _isPaused ? 'Dijeda' : 'Merekam',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _isRecording && !_isPaused
                  ? const Color(0xFF0F766E)
                  : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  /// Waveform Audio Dinamis (15 Bar, Lebar total ~90px, sama persis Gambar 1)
  /// - Saat diam / hening: gelombang datar (idle min 4px)
  /// - Saat bicara: gelombang naik-turun sesuai volume suara mikrofon real-time
  Widget _buildWaveform() {
    const int barCount = 15;
    const double centerIndex = (barCount - 1) / 2; // 7.0

    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, _) {
        final active = _isRecording && !_isPaused;
        final phase = _waveController.value * 2 * math.pi;
        // Hanya dianggap bicara jika suara vokal aktif dan volume >= 0.06
        final isSpeaking = active && _currentVolume >= 0.06;

        return SizedBox(
          height: 34,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(barCount, (i) {
              final distFromCenter = (i - centerIndex).abs(); // 0 to 7

              // Bentuk kurva amplop melandai indah
              final envelope =
                  math.cos((distFromCenter / centerIndex) * (math.pi / 2.2));

              double barHeight;
              Color barColor;

              if (!active || !isSpeaking) {
                // Berhenti / belum merekam / dijeda / USER DIAM: garis benar-benar datar (idle 4.0px)
                barHeight = 4.0;
                barColor = const Color(0xFFCBD5E1);
              } else {
                // USER SEDANG BICARA: gelombang naik dinamis sesuai kekuatan vokal
                final dynamicMotion =
                    0.65 + 0.35 * math.sin(phase * 1.8 + i * 0.7).abs();
                barHeight = math.min(
                  34.0,
                  4.0 + (30.0 * envelope * _currentVolume * dynamicMotion),
                );

                // Gradasi warna: tengah ungu pekat (#5B4FEB), tepi lavender lembut (#C7D2FE)
                if (distFromCenter <= 1) {
                  barColor = const Color(0xFF5B4FEB);
                } else if (distFromCenter <= 3) {
                  barColor = const Color(0xFF818CF8);
                } else if (distFromCenter <= 5) {
                  barColor = const Color(0xFFA5B4FC);
                } else {
                  barColor = const Color(0xFFC7D2FE);
                }
              }

              return AnimatedContainer(
                duration: const Duration(milliseconds: 60),
                curve: Curves.easeOutQuad,
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                width: 3.0,
                height: barHeight,
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  Widget _buildHintRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(
          Icons.schedule_rounded,
          size: 14,
          color: Color(0xFF94A3B8),
        ),
        SizedBox(width: 5),
        Text(
          'Bicara santai, minimal 10 detik',
          style: TextStyle(
            fontSize: 12.5,
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  /// Tombol MULAI — sebelum rekaman dimulai
  Widget _buildStartButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 10, 4, 24),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _startRecording,
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryIndigo,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Mulai Rekam',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  /// Kontrol Jeda / Selesai / Ulang — saat merekam (Diposisikan pas di bawah)
  Widget _buildRecordingControls() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24, top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _ControlButton(
            icon: _isPaused
                ? Icons.play_arrow_rounded
                : Icons.pause_rounded,
            label: _isPaused ? 'Lanjut' : 'Jeda',
            onTap: _isRecording
                ? (_isPaused ? _resumeRecording : _pauseRecording)
                : null,
          ),
          _MainActionButton(onTap: _selesai),
          _ControlButton(
            icon: Icons.refresh_rounded,
            label: 'Ulang',
            onTap: _retakeCount < widget.maxRetakes ? _retake : null,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
/// CustomPainter: lingkaran countdown bergradasi biru-ungu
class _CircleTimerPainter extends CustomPainter {
  final double fraction; // 1.0 = penuh, 0.0 = habis
  final bool isPaused;

  _CircleTimerPainter({required this.fraction, required this.isPaused});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = (size.width / 2) - 8;
    const strokeW = 7.5;

    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);

    // Track abu tipis (latar)
    final trackPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(Offset(cx, cy), radius, trackPaint);

    // Arc gradient (memutar searah jarum jam dari atas -pi/2)
    if (fraction > 0) {
      final sweepAngle = 2 * math.pi * fraction;

      final gradient = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: -math.pi / 2 + sweepAngle,
        colors: isPaused
            ? [const Color(0xFF94A3B8), const Color(0xFF94A3B8)]
            : [const Color(0xFF2563EB), const Color(0xFF6366F1)],
        stops: const [0.0, 1.0],
        tileMode: TileMode.clamp,
      );

      final arcPaint = Paint()
        ..shader = gradient.createShader(rect)
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
  bool shouldRepaint(_CircleTimerPainter old) =>
      old.fraction != fraction || old.isPaused != isPaused;
}

// ─────────────────────────────────────────────
class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ControlButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1.5,
              ),
            ),
            child: Icon(
              icon,
              size: 24,
              color: disabled
                  ? const Color(0xFFCBD5E1)
                  : const Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: disabled
                  ? const Color(0xFFCBD5E1)
                  : const Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
class _MainActionButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _MainActionButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF4F46E5),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4F46E5).withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.stop_rounded,
              size: 30,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Selesai',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}
