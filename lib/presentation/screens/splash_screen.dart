import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _logoOpacity;
  late final Animation<Offset> _logoOffset;
  late final Animation<double> _logoScale;
  late final Animation<double> _ringOpacity;
  late final Animation<double> _ringScale;
  late final Animation<double> _taglineOpacity;
  late final Animation<Offset> _taglineOffset;
  late final Animation<double> _screenFadeOut;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );

    _logoOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.06, 0.22, curve: Curves.easeOutCubic),
    );
    _logoOffset = Tween<Offset>(begin: const Offset(0, 0.18), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.06, 0.22, curve: Curves.easeOutCubic),
          ),
        );
    _logoScale = Tween<double>(begin: 0.92, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.06, 0.24, curve: Curves.easeOutBack),
      ),
    );
    _ringOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.18, 0.46, curve: Curves.easeOut),
    );
    _ringScale = Tween<double>(begin: 0.72, end: 1.08).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.18, 0.62, curve: Curves.easeOutCubic),
      ),
    );
    _taglineOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.42, 0.62, curve: Curves.easeOutCubic),
    );
    _taglineOffset =
        Tween<Offset>(begin: const Offset(0, 0.16), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.42, 0.62, curve: Curves.easeOutCubic),
          ),
        );
    _screenFadeOut = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.90, 1.00, curve: Curves.easeInOut),
    );

    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final double fadeOpacity = 1 - _screenFadeOut.value;
        final double pulse = 0.5 + 0.5 * sin(_controller.value * pi * 4);

        return Opacity(
          opacity: fadeOpacity.clamp(0.0, 1.0),
          child: Scaffold(
            body: Stack(
              fit: StackFit.expand,
              children: [
                _GradientBackground(pulse: pulse),
                CustomPaint(
                  painter: _SplashDecorationPainter(
                    progress: _controller.value,
                  ),
                ),
                Align(
                  alignment: const Alignment(0, -0.13),
                  child: Transform.scale(
                    scale: _ringScale.value,
                    child: Opacity(
                      opacity: _ringOpacity.value,
                      child: CustomPaint(
                        size: _responsiveRingSize(context),
                        painter: _RingPainter(progress: _controller.value),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: const Alignment(0, -0.13),
                  child: SlideTransition(
                    position: _logoOffset,
                    child: FadeTransition(
                      opacity: _logoOpacity,
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: const _LogoCard(),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: const Alignment(0, 0.34),
                  child: SlideTransition(
                    position: _taglineOffset,
                    child: FadeTransition(
                      opacity: _taglineOpacity,
                      child: const _Tagline(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Size _responsiveRingSize(BuildContext context) {
    final Size screen = MediaQuery.sizeOf(context);
    final double width = min(screen.width * 0.72, 280);
    return Size.square(width);
  }
}

class _GradientBackground extends StatelessWidget {
  const _GradientBackground({required this.pulse});

  final double pulse;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(
              const Color(0xFF2437A8),
              const Color(0xFF3049C9),
              pulse,
            )!,
            Color.lerp(
              const Color(0xFF4F2BC2),
              const Color(0xFF5F35DA),
              pulse,
            )!,
            Color.lerp(
              const Color(0xFF28106F),
              const Color(0xFF35158E),
              pulse,
            )!,
          ],
        ),
      ),
    );
  }
}

class _LogoCard extends StatelessWidget {
  const _LogoCard();

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double cardWidth = min(screenWidth * 0.50, 190);

    return Container(
      width: cardWidth * 1,
      height: cardWidth * 1,
      padding: EdgeInsets.symmetric(horizontal: cardWidth * 0.12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.16 * 255).toInt()),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Image.asset(
        'assets/images/logoo.jpeg',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Text(
              'TAMPIL',
              style: TextStyle(
                color: Color(0xFF3E2BC8),
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Tagline extends StatelessWidget {
  const _Tagline();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Text(
        'Latih Komunikasimu, Raih Potensimu',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: min(MediaQuery.sizeOf(context).width * 0.052, 22),
          fontWeight: FontWeight.w800,
          height: 1.25,
          letterSpacing: 0.2,
          shadows: [
            Shadow(
              color: Colors.black.withAlpha((0.18 * 255).toInt()),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double shortest = size.shortestSide;
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final double shimmer = 0.65 + 0.35 * sin(progress * pi * 6);
    final List<double> radii = [0.27, 0.39, 0.51];
    final List<double> opacities = [0.36, 0.23, 0.15];

    for (int i = 0; i < radii.length; i++) {
      paint
        ..strokeWidth = i == 0 ? 1.6 : 1.2
        ..color = Colors.white.withOpacity(opacities[i] * shimmer);
      canvas.drawCircle(center, shortest * radii[i], paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _SplashDecorationPainter extends CustomPainter {
  const _SplashDecorationPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint strokePaint = Paint()
      ..color = Colors.white.withOpacity(0.22)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final Paint fillPaint = Paint()
      ..color = Colors.white.withOpacity(0.28)
      ..style = PaintingStyle.fill;

    _drawTopLeftDashedCorner(canvas, strokePaint);
    _drawDashedCircle(canvas, Offset(size.width - 40, 40), 28, strokePaint);
    _drawDashedCircle(canvas, Offset(36, size.height - 42), 20, strokePaint);
    _drawSpeechBubble(canvas, size, strokePaint);
    _drawFloatingStars(canvas, size, fillPaint);
  }

  void _drawTopLeftDashedCorner(Canvas canvas, Paint paint) {
    const double radius = 76;
    final Path path = Path()
      ..moveTo(0, radius)
      ..quadraticBezierTo(0, 0, radius, 0);
    _drawDashedPath(canvas, path, paint, dashLength: 5, gapLength: 5);
  }

  void _drawSpeechBubble(Canvas canvas, Size size, Paint paint) {
    final Rect rect = Rect.fromLTWH(size.width - 122, size.height - 92, 96, 58);
    final RRect bubble = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(18),
    );
    canvas.drawRRect(bubble, paint);

    final Path tail = Path()
      ..moveTo(rect.left + 24, rect.bottom)
      ..lineTo(rect.left + 18, rect.bottom + 13)
      ..lineTo(rect.left + 40, rect.bottom)
      ..close();
    canvas.drawPath(tail, paint);
  }

  void _drawFloatingStars(Canvas canvas, Size size, Paint paint) {
    final List<Offset> stars = [
      Offset(size.width * 0.22, size.height * 0.18),
      Offset(size.width * 0.78, size.height * 0.25),
      Offset(size.width * 0.32, size.height * 0.77),
      Offset(size.width * 0.68, size.height * 0.70),
    ];

    for (int i = 0; i < stars.length; i++) {
      final double pulse = 0.75 + 0.25 * sin((progress * pi * 4) + i);
      _drawStar(canvas, stars[i], 3.5 + (i % 2) + pulse, paint);
    }
  }

  void _drawDashedCircle(
    Canvas canvas,
    Offset center,
    double radius,
    Paint paint,
  ) {
    final Path circle = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));
    _drawDashedPath(canvas, circle, paint, dashLength: 4, gapLength: 5);
  }

  void _drawDashedPath(
    Canvas canvas,
    Path path,
    Paint paint, {
    required double dashLength,
    required double gapLength,
  }) {
    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final double end = min(distance + dashLength, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance = end + gapLength;
      }
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    const int points = 5;
    final Path path = Path();
    for (int i = 0; i < points * 2; i++) {
      final double angle = -pi / 2 + (pi / points) * i;
      final double currentRadius = i.isEven ? radius : radius * 0.45;
      final Offset point = Offset(
        center.dx + cos(angle) * currentRadius,
        center.dy + sin(angle) * currentRadius,
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SplashDecorationPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
