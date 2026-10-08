import 'package:flutter/material.dart';

class TestHeaderWidget extends StatelessWidget {
  final int completedTests;
  final int totalTests;

  const TestHeaderWidget({
    super.key,
    this.completedTests = 2,
    this.totalTests = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Test',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Latih bicaramu hari ini',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE0E7FF), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.mic_none_rounded,
                size: 16,
                color: Color(0xFF6366F1),
              ),
              const SizedBox(width: 6),
              Text(
                '$completedTests/$totalTests tes hari ini',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6366F1),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
