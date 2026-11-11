import 'package:flutter/material.dart';

/// Top bar for the lesson flow: close button, a segmented progress bar with
/// the "step / total" label, and a lesson tag chip underneath.
class LessonAppBar extends StatelessWidget {
  final int lessonNumber;
  final String lessonTag;
  final int step;
  final int totalSteps;
  final VoidCallback onClose;

  const LessonAppBar({
    super.key,
    required this.lessonNumber,
    required this.lessonTag,
    required this.step,
    required this.totalSteps,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onClose,
                icon: const Icon(
                  Icons.close_rounded,
                  color: Color(0xFF0F172A),
                  size: 26,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: step / totalSteps,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF4F46E5),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$step/$totalSteps',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Lesson tag chip.
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Lesson $lessonNumber · $lessonTag',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4F46E5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
