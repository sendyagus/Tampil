import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Maskot Robot Berpikir (Analyzing Screen) dengan:
/// 1. Konsep 1: Melayang & Menimbang-nimbang pelan (Deep Contemplative Float & Tilt)
/// 2. Konsep 2: Gelombang radar AI lembut di belakang kepala (Neural Pulse Wave & Data Orbit)
/// 3. Reaksi sentuh ringan: Dicolek saat menunggu memunculkan reaksi kaget ceria & balon pikiran AI
class AnimatedThinkingMascotWidget extends StatefulWidget {
  final double height;
  final String imageAsset;
  final VoidCallback? onTap;

  const AnimatedThinkingMascotWidget({
    super.key,
    this.height = 210,
    this.imageAsset = 'assets/images/Maskot Robot Pikir.png',
    this.onTap,
  });

  @override
  State<AnimatedThinkingMascotWidget> createState() =>
      _AnimatedThinkingMascotWidgetState();
}

class _AnimatedThinkingMascotWidgetState
    extends State<AnimatedThinkingMascotWidget> with TickerProviderStateMixin {
  // ── Controller 1: Melayang Berpikir & Goyang Miring Santai ──
  late final AnimationController _floatController;
  late final Animation<double> _bobAnimation;
  late final Animation<double> _tiltAnimation;
  late final Animation<double> _breatheAnimation;
  late final Animation<double> _shadowScaleAnimation;
  late final Animation<double> _shadowOpacityAnimation;

  // ── Controller 2: Gelombang Radar AI di Belakang Kepala ──
  late final AnimationController _radarController;

  // ── Controller 3: Reaksi Sentuh Ringan (Poke & Thought Pop) ──
  late final AnimationController _pokeController;
  late final Animation<double> _pokeHopAnimation;
  late final AnimationController _thoughtBubbleController;
  late final Animation<double> _thoughtBubbleScale;

  final List<String> _thinkingMessages = [
    'Lagi kudengarkan dengan seksama... 🎧',
    'Menghitung intonasi dan artikulasi! 💡',
    'Menyusun feedback AI terbaik untukmu... 📝',
    'Hampir selesai, santai sejenak ya! ✨',
  ];
  int _messageIndex = 0;
  bool _showThoughtBubble = false;

  @override
  void initState() {
    super.initState();

    // 1. Setup Melayang Berpikir (Durasi 3.4 detik, tenang dan stabil)
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    );

    final curvedFloat = CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOutSine,
    );

    _bobAnimation = Tween<double>(begin: -8.0, end: 8.0).animate(curvedFloat);
    // Miring menimbang-nimbang kepala (tilt ~3 derajat)
    _tiltAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(curvedFloat);
    _breatheAnimation = Tween<double>(begin: 0.985, end: 1.02).animate(curvedFloat);

    _shadowScaleAnimation = Tween<double>(begin: 0.88, end: 1.12).animate(curvedFloat);
    _shadowOpacityAnimation = Tween<double>(begin: 0.26, end: 0.14).animate(curvedFloat);

    _floatController.repeat(reverse: true);

    // 2. Setup Gelombang Radar AI di Belakang Kepala (Looping 2.4 detik)
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    // 3. Setup Reaksi Sentuh Ringan
    _pokeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _pokeHopAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: -16.0)
            .chain(CurveTween(curve: Curves.easeOutQuad)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -16.0, end: 0.0)
            .chain(CurveTween(curve: Curves.bounceOut)),
        weight: 60,
      ),
    ]).animate(_pokeController);

    _thoughtBubbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _thoughtBubbleScale = CurvedAnimation(
      parent: _thoughtBubbleController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _radarController.dispose();
    _pokeController.dispose();
    _thoughtBubbleController.dispose();
    super.dispose();
  }

  void _handleTap() {
    widget.onTap?.call();

    // Animasi lompatan kaget kecil
    _pokeController.forward(from: 0.0);

    // Tampilkan / ganti balon pikiran AI
    setState(() {
      _showThoughtBubble = true;
      _messageIndex = (_messageIndex + 1) % _thinkingMessages.length;
    });

    _thoughtBubbleController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final robotHeight = widget.height;
    final robotWidth = robotHeight * 0.92;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── 1. Balon Pikiran AI Interaktif saat Disentuh ──
        AnimatedOpacity(
          opacity: _showThoughtBubble ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: ScaleTransition(
            scale: _thoughtBubbleScale,
            child: _buildThoughtBubble(),
          ),
        ),

        const SizedBox(height: 6),

        // ── 2. Area Robot dengan Gelombang Radar AI di Belakangnya ──
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: _handleTap,
            child: SizedBox(
              width: robotWidth + 40,
              height: robotHeight + 20,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // ── LAYER 1 (PALING BELAKANG): Gelombang Radar AI ──
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _radarController,
                      _floatController,
                    ]),
                    builder: (context, child) {
                      final bobY = _bobAnimation.value;
                      return Transform.translate(
                        offset: Offset(0, bobY),
                        child: CustomPaint(
                          size: Size(robotWidth + 40, robotHeight + 20),
                          painter: _NeuralRadarPulsePainter(
                            progress: _radarController.value,
                          ),
                        ),
                      );
                    },
                  ),

                  // ── LAYER 2: Partikel Data Mengorbit Pelan di Belakang Kepala ──
                  _buildOrbitingDataParticles(robotWidth, robotHeight),

                  // ── LAYER 3 (DEPAN): Badan Robot Pikir ──
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _floatController,
                      _pokeController,
                    ]),
                    builder: (context, child) {
                      final bobY = _bobAnimation.value;
                      final hopY = _pokeHopAnimation.value;
                      final totalY = bobY + hopY;

                      final tilt = _tiltAnimation.value;
                      final breatheScale = _breatheAnimation.value;

                      return Transform.translate(
                        offset: Offset(0, totalY),
                        child: Transform.rotate(
                          angle: tilt,
                          child: Transform.scale(
                            scale: breatheScale,
                            child: Image.asset(
                              widget.imageAsset,
                              height: robotHeight,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.psychology_rounded,
                                  size: 110,
                                  color: Color(0xFF4F46E5),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 4),

        // ── 3. Dynamic 3D Ground Shadow di Lantai ──
        AnimatedBuilder(
          animation: Listenable.merge([
            _floatController,
            _pokeController,
          ]),
          builder: (context, child) {
            final hopRatio = (-_pokeHopAnimation.value / 16.0).clamp(0.0, 1.0);
            final scale = _shadowScaleAnimation.value * (1.0 + (hopRatio * 0.2));
            final baseOpacity = _shadowOpacityAnimation.value;
            final opacity = (baseOpacity * (1.0 - (hopRatio * 0.5))).clamp(0.05, 0.35);

            final shadowWidth = (robotHeight * 0.44) * scale;
            final shadowHeight = (robotHeight * 0.06) * scale;

            return Container(
              width: shadowWidth,
              height: shadowHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.elliptical(shadowWidth, shadowHeight),
                ),
                color: const Color(0xFF312E81).withValues(alpha: opacity),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4338CA).withValues(alpha: opacity * 0.8),
                    blurRadius: 14,
                    spreadRadius: 2,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Balon Pikiran AI (Thought Bubble 💭)
  // ─────────────────────────────────────────────
  Widget _buildThoughtBubble() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7.5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE0E7FF),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4338CA).withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.lightbulb_rounded,
            size: 16,
            color: Color(0xFFF59E0B),
          ),
          const SizedBox(width: 8),
          Text(
            _thinkingMessages[_messageIndex],
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Partikel Data Mengorbit Pelan di Belakang Kepala
  // ─────────────────────────────────────────────
  Widget _buildOrbitingDataParticles(double robotWidth, double robotHeight) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _radarController,
        _floatController,
      ]),
      builder: (context, child) {
        final t = _radarController.value * 2 * math.pi;
        final bobY = _bobAnimation.value;

        // Orbit elips mengelilingi area kepala robot (pusat di y = -35)
        final x1 = math.cos(t) * 78;
        final y1 = math.sin(t) * 36 - 35 + bobY;

        final x2 = math.cos(t + math.pi) * 78;
        final y2 = math.sin(t + math.pi) * 36 - 35 + bobY;

        final x3 = math.cos(t + math.pi * 0.5) * 65;
        final y3 = math.sin(t + math.pi * 0.5) * 30 - 35 + bobY;

        return Stack(
          alignment: Alignment.center,
          children: [
            // Data Dot 1 (Cyan)
            Transform.translate(
              offset: Offset(x1, y1),
              child: Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: const Color(0xFF00E5FF),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.8),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
            // Data Dot 2 (Gold)
            Transform.translate(
              offset: Offset(x2, y2),
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.8),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
            // Data Sparkle 3 (Indigo)
            Transform.translate(
              offset: Offset(x3, y3),
              child: const Icon(
                Icons.auto_awesome,
                size: 15,
                color: Color(0xFF818CF8),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// Painter Gelombang Radar AI di Belakang Kepala
// ─────────────────────────────────────────────
class _NeuralRadarPulsePainter extends CustomPainter {
  final double progress; // 0.0 - 1.0 repeating

  _NeuralRadarPulsePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // Pusat pancaran tepat di belakang kepala robot
    final center = Offset(size.width / 2, size.height / 2 - 38);
    final maxRadius = size.width * 0.48;

    // 3 Gelombang radar yang berdenyut membesar secara bergantian
    for (int i = 0; i < 3; i++) {
      final ringProgress = (progress + (i / 3.0)) % 1.0;
      final radius = 28.0 + (ringProgress * (maxRadius - 28.0));

      // Memudar lembut saat membesar
      final opacity = (1.0 - ringProgress).clamp(0.0, 1.0) * 0.38;

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0 * (1.0 - (ringProgress * 0.5))
        ..color = Color.lerp(
          const Color(0xFF6366F1), // Ungu / Indigo TAMPIL
          const Color(0xFF00E5FF), // Cyan Neon AI
          ringProgress,
        )!
            .withValues(alpha: opacity);

      canvas.drawCircle(center, radius, paint);

      // Pendaran lembut di lingkaran terdekat
      if (ringProgress < 0.35) {
        final fillOpacity = (0.35 - ringProgress) * 0.25;
        final fillPaint = Paint()
          ..style = PaintingStyle.fill
          ..color = const Color(0xFF00E5FF).withValues(alpha: fillOpacity);
        canvas.drawCircle(center, radius, fillPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _NeuralRadarPulsePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
