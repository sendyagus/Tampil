import 'package:flutter/material.dart';

/// Shared full-width gradient action button used at the bottom of every
/// lesson step (Mengerti / Periksa / Lanjut / Selesai).
class LessonButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  /// When true the button renders a lighter, secondary style.
  final bool secondary;

  const LessonButton({
    super.key,
    required this.label,
    this.onPressed,
    this.secondary = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null;
    final double opacity = enabled ? 1 : 0.5;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: secondary
              ? null
              : LinearGradient(
                  colors: [
                    const Color(0xFF4F46E5).withValues(alpha: opacity),
                    const Color(0xFF7C3AED).withValues(alpha: opacity),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
          color: secondary
              ? const Color(0xFFEEF2FF).withValues(alpha: opacity)
              : null,
          boxShadow: secondary || !enabled
              ? null
              : [
                  BoxShadow(
                    color: const Color(0xFF4F46E5).withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: secondary
                      ? const Color(0xFF4F46E5).withValues(alpha: opacity)
                      : Colors.white.withValues(alpha: opacity),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
