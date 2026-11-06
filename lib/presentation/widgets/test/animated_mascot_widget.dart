import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Maskot Robot Interaktif TAMPIL dengan:
/// 1. IDLE:
///    - Clean Organic Levitation & Calming Breathing Guide (melayang naik-turun halus 3.6s + goyangan miring 3D + nafas badan)
///    - Soft Cyan AI Aura (pendaran cahaya lembut di belakang punggung robot)
///    - 2 Ambient Twinkles (bintang cyan di dekat tangan & bintang emas di dahi)
///    - Dynamic 3D Ground Shadow (bayangan dinamis meregang-menyusut di lantai)
/// 2. TAP:
///    - Stage Spotlight (sorotan lampu panggung TED Talk dari atas)
///    - AI Sonic Shockwave (gelombang sonik tipis memancar dari belakang)
///    - Elastic Hop & Proud Bounce
///    - Balon kata penyemangat interaktif
class AnimatedMascotWidget extends StatefulWidget {
  final double height;
  final String imageAsset;
  final bool showSpeechBubble;
  final VoidCallback? onTap;

  const AnimatedMascotWidget({
    super.key,
    this.height = 200,
    this.imageAsset = 'assets/images/Maskot Robot Tampil Ceria.png',
    this.showSpeechBubble = true,
    this.onTap,
  });

  @override
  State<AnimatedMascotWidget> createState() => _AnimatedMascotWidgetState();
}

class _AnimatedMascotWidgetState extends State<AnimatedMascotWidget>
    with TickerProviderStateMixin {
  // ── Controller 1: Irama Napas Relaksasi & Melayang Halus (IDLE) ──
  late final AnimationController _levitationController;
  late final Animation<double> _bobAnimation;
  late final Animation<double> _tiltAnimation;
  late final Animation<double> _breatheAnimation;
  late final Animation<double> _shadowScaleAnimation;
  late final Animation<double> _shadowOpacityAnimation;

  // ── Controller 2: Interactive Hop & Proud Bounce saat Dicolek ──
  late final AnimationController _pokeController;
  late final Animation<double> _pokeHopAnimation;
  late final Animation<double> _pokeSquashAnimation;

  // ── Controller 3: Stage Spotlight & Sonic Shockwave (saat Dicolek) ──
  late final AnimationController _stageEffectController;

  // ── Controller 4: Balon Kata Pop ──
  late final AnimationController _bubbleController;
  late final Animation<double> _bubbleScaleAnimation;

  // Dialog Tips Coaching yang berganti saat dicolek
  final List<String> _coachingTips = [
    'Panggung ini milikmu, kamu pasti bisa! ✨',
    'Bicara santai, aku siap mendengarkan! 🎙️',
    'Fokus pada ide utamamu, artikulasi tenang 💡',
    'Tarik napas dalam-dalam, rileks ya! 🧘',
    'Sentuh aku lagi untuk tips panggung! 🤖',
  ];
  int _currentTipIndex = 0;

  @override
  void initState() {
    super.initState();

    // 1. Setup Irama Napas Relaksasi (3.6 detik per siklus)
    _levitationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    );

    final curvedLevitation = CurvedAnimation(
      parent: _levitationController,
      curve: Curves.easeInOutSine,
    );

    // Gerakan naik turun melayang
    _bobAnimation = Tween<double>(begin: -12.0, end: 12.0).animate(curvedLevitation);
    // Goyangan miring organik (~3 derajat)
    _tiltAnimation = Tween<double>(begin: -0.045, end: 0.045).animate(curvedLevitation);
    // Efek tubuh bernapas
    _breatheAnimation = Tween<double>(begin: 0.98, end: 1.025).animate(curvedLevitation);

    _shadowScaleAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(curvedLevitation);
    _shadowOpacityAnimation = Tween<double>(begin: 0.30, end: 0.12).animate(curvedLevitation);

    _levitationController.repeat(reverse: true);

    // 2. Setup Lompatan Kenyal saat Dicolek
    _pokeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _pokeHopAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: -24.0)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -24.0, end: 0.0)
            .chain(CurveTween(curve: Curves.bounceOut)),
        weight: 65,
      ),
    ]).animate(_pokeController);

    _pokeSquashAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.10)
            .chain(CurveTween(curve: Curves.easeOutQuad)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.10, end: 0.96)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.96, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 40,
      ),
    ]).animate(_pokeController);

    // 3. Setup Stage Spotlight & Sonic Shockwave saat Dicolek
    _stageEffectController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );

    // 4. Setup Balon Kata Pop
    _bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      value: 1.0,
    );
    _bubbleScaleAnimation = CurvedAnimation(
      parent: _bubbleController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _levitationController.dispose();
    _pokeController.dispose();
    _stageEffectController.dispose();
    _bubbleController.dispose();
    super.dispose();
  }

  void _handleTap() {
    widget.onTap?.call();

    // Jalankan lompatan ceria
    _pokeController.forward(from: 0.0);

    // Jalankan efek panggung + shockwave
    _stageEffectController.forward(from: 0.0);

    // Ganti tips balon kata dengan animasi pop
    if (widget.showSpeechBubble) {
      _bubbleController.reverse().then((_) {
        if (mounted) {
          setState(() {
            _currentTipIndex = (_currentTipIndex + 1) % _coachingTips.length;
          });
          _bubbleController.forward();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final robotHeight = widget.height;
    final robotWidth = robotHeight * 0.92;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── 1. Balon Kata Interaktif (Speech Bubble) ──
        if (widget.showSpeechBubble) ...[
          ScaleTransition(
            scale: _bubbleScaleAnimation,
            child: _buildSpeechBubble(),
          ),
          const SizedBox(height: 10),
        ],

        // ── 2. Area Robot dengan Efek Panggung & Propulsi di Belakangnya ──
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: _handleTap,
            child: SizedBox(
              width: robotWidth + 80,
              height: robotHeight + 30,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // ── LAYER 1: Sorotan Lampu Panggung (saat dicolek) ──
                  AnimatedBuilder(
                    animation: _stageEffectController,
                    builder: (context, child) {
                      return CustomPaint(
                        size: Size(robotWidth + 80, robotHeight + 30),
                        painter: _StageSpotlightPainter(
                          progress: _stageEffectController.value,
                        ),
                      );
                    },
                  ),

                  // ── LAYER 2: Aura Cahaya Lembut di Belakang Badan Robot (IDLE) ──
                  AnimatedBuilder(
                    animation: _levitationController,
                    builder: (context, child) {
                      final val = _levitationController.value;
                      final bobY = _bobAnimation.value;
                      // Pendaran bernapas cyan lembut di belakang robot
                      final auraOpacity = (0.16 + (val * 0.16)).clamp(0.0, 0.35);
                      final auraRadius = 88.0 + (val * 24.0);

                      return Transform.translate(
                        offset: Offset(0, -10 + bobY),
                        child: Container(
                          width: auraRadius * 2,
                          height: auraRadius * 2,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFF00E5FF).withValues(alpha: auraOpacity),
                                const Color(0xFF6366F1).withValues(alpha: auraOpacity * 0.5),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.55, 1.0],
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  // ── LAYER 3: Gelombang Sonik AI (saat dicolek) ──
                  AnimatedBuilder(
                    animation: _stageEffectController,
                    builder: (context, child) {
                      return CustomPaint(
                        size: Size(robotWidth + 80, robotHeight + 30),
                        painter: _SonicShockwavePainter(
                          progress: _stageEffectController.value,
                        ),
                      );
                    },
                  ),

                  // ── LAYER 4: Dua Bintang Ambient Berkedip Halus (IDLE) ──
                  AnimatedBuilder(
                    animation: _levitationController,
                    builder: (context, child) {
                      final val = _levitationController.value;
                      final bobY = _bobAnimation.value;
                      final twinkle1 = (math.sin(val * math.pi * 2) * 0.5 + 0.5).clamp(0.2, 1.0);
                      final twinkle2 = (math.cos(val * math.pi * 2) * 0.5 + 0.5).clamp(0.2, 1.0);

                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Bintang Cyan dekat tangan kanan melambai
                          Transform.translate(
                            offset: Offset(82, -25 + (bobY * 0.8)),
                            child: Opacity(
                              opacity: twinkle1,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF00E5FF).withValues(alpha: 0.7 * twinkle1),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.auto_awesome,
                                  size: 19,
                                  color: Color(0xFF00E5FF),
                                ),
                              ),
                            ),
                          ),
                          // Bintang Emas dekat dahi / kepala robot
                          Transform.translate(
                            offset: Offset(-75, -65 + (bobY * 0.8)),
                            child: Opacity(
                              opacity: twinkle2,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFFD700).withValues(alpha: 0.75 * twinkle2),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.star_rounded,
                                  size: 18,
                                  color: Color(0xFFFFD700),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  // ── LAYER 5 (DEPAN): Badan Robot TAMPIL ──
                  // Badan robot berada di atas panggung dan gelombang, wajah & fisiknya 100% bersih dan tajam!
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _levitationController,
                      _pokeController,
                    ]),
                    builder: (context, child) {
                      final bobY = _bobAnimation.value;
                      final hopY = _pokeHopAnimation.value;
                      final totalY = bobY + hopY;

                      final tilt = _tiltAnimation.value;
                      final breatheScale = _breatheAnimation.value;
                      final squashScale = _pokeSquashAnimation.value;
                      final totalScale = breatheScale * squashScale;

                      return Transform.translate(
                        offset: Offset(0, totalY),
                        child: Transform.rotate(
                          angle: tilt,
                          child: Transform.scale(
                            scale: totalScale,
                            child: Image.asset(
                              widget.imageAsset,
                              height: robotHeight,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.smart_toy_rounded,
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

        // ── 3. Dynamic 3D Ground Shadow (Bayangan di Lantai) ──
        AnimatedBuilder(
          animation: Listenable.merge([
            _levitationController,
            _pokeController,
            _stageEffectController,
          ]),
          builder: (context, child) {
            final hopRatio = (-_pokeHopAnimation.value / 22.0).clamp(0.0, 1.0);
            final stageProg = _stageEffectController.value;
            final stageBoost = stageProg > 0 && stageProg < 1.0
                ? (stageProg < 0.5 ? stageProg * 2 : (1.0 - stageProg) * 2) * 0.15
                : 0.0;

            final scale = _shadowScaleAnimation.value * (1.0 + (hopRatio * 0.22));
            final baseOpacity = _shadowOpacityAnimation.value + stageBoost;
            final opacity = (baseOpacity * (1.0 - (hopRatio * 0.55))).clamp(0.06, 0.40);

            final shadowWidth = (robotHeight * 0.45) * scale;
            final shadowHeight = (robotHeight * 0.065) * scale;

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
  // Balon Kata (Speech Bubble) Elegan
  // ─────────────────────────────────────────────
  Widget _buildSpeechBubble() {
    return GestureDetector(
      onTap: _handleTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _coachingTips[_currentTipIndex],
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
          ),
          CustomPaint(
            size: const Size(12, 6),
            painter: _BubbleTrianglePainter(
              color: Colors.white,
              strokeColor: const Color(0xFFE0E7FF),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Painter 1: Sorotan Lampu Panggung (Stage Spotlight)
// ─────────────────────────────────────────────
class _StageSpotlightPainter extends CustomPainter {
  final double progress; // 0.0 - 1.0

  _StageSpotlightPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0 || progress >= 1.0) return;

    final double opacity;
    if (progress < 0.22) {
      opacity = progress / 0.22;
    } else if (progress < 0.60) {
      opacity = 1.0;
    } else {
      opacity = 1.0 - ((progress - 0.60) / 0.40);
    }

    final double effectiveOpacity = (opacity * 0.20).clamp(0.0, 0.22);

    final topWidth = size.width * 0.22;
    final bottomWidth = size.width * 0.90;
    final centerX = size.width / 2;
    const topY = -25.0;
    final bottomY = size.height + 10.0;

    final path = Path()
      ..moveTo(centerX - topWidth / 2, topY)
      ..lineTo(centerX + topWidth / 2, topY)
      ..lineTo(centerX + bottomWidth / 2, bottomY)
      ..lineTo(centerX - bottomWidth / 2, bottomY)
      ..close();

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF00E5FF).withValues(alpha: effectiveOpacity * 1.1),
          const Color(0xFF818CF8).withValues(alpha: effectiveOpacity * 0.7),
          const Color(0xFF4F46E5).withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.60, 1.0],
      ).createShader(Rect.fromLTWH(0, topY, size.width, bottomY - topY));

    canvas.drawPath(path, paint);

    final floorRect = Rect.fromCenter(
      center: Offset(centerX, size.height + 2),
      width: bottomWidth * 0.70,
      height: 22.0,
    );

    final floorPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF00E5FF).withValues(alpha: effectiveOpacity * 0.85),
          const Color(0xFF6366F1).withValues(alpha: 0.0),
        ],
      ).createShader(floorRect);

    canvas.drawOval(floorRect, floorPaint);
  }

  @override
  bool shouldRepaint(covariant _StageSpotlightPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// ─────────────────────────────────────────────
// Painter 2: Gelombang Sonik AI (Sonic Shockwave)
// ─────────────────────────────────────────────
class _SonicShockwavePainter extends CustomPainter {
  final double progress; // 0.0 - 1.0

  _SonicShockwavePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0 || progress >= 1.0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width * 0.58;

    for (int i = 0; i < 2; i++) {
      final waveProgress = (progress - (i * 0.16)).clamp(0.0, 1.0);
      if (waveProgress <= 0.0 || waveProgress >= 1.0) continue;

      final curveRadius = Curves.easeOutCubic.transform(waveProgress);
      final radius = 28.0 + (curveRadius * (maxRadius - 28.0));
      final opacity = (1.0 - waveProgress).clamp(0.0, 1.0) * 0.65;

      final strokePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6 * (1.0 - (waveProgress * 0.4))
        ..color = Color.lerp(
          const Color(0xFF00E5FF),
          const Color(0xFF818CF8),
          waveProgress,
        )!
            .withValues(alpha: opacity);

      canvas.drawCircle(center, radius, strokePaint);

      final glowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..color = const Color(0xFF00E5FF).withValues(alpha: opacity * 0.22);

      canvas.drawCircle(center, radius, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SonicShockwavePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// ─────────────────────────────────────────────
// Painter Segitiga Balon Kata
// ─────────────────────────────────────────────
class _BubbleTrianglePainter extends CustomPainter {
  final Color color;
  final Color strokeColor;

  _BubbleTrianglePainter({
    required this.color,
    required this.strokeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawPath(path, fillPaint);
    canvas.drawLine(
      Offset.zero,
      Offset(size.width / 2, size.height),
      strokePaint,
    );
    canvas.drawLine(
      Offset(size.width / 2, size.height),
      Offset(size.width, 0),
      strokePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _BubbleTrianglePainter oldDelegate) => false;
}
