import 'package:flutter/material.dart';

import 'lesson_button.dart';

// ---------------------------------------------------------------------------
// Step 1 — Concept / material
// ---------------------------------------------------------------------------
class LessonConceptStep extends StatelessWidget {
  const LessonConceptStep({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Mic illustration badge.
          Center(
            child: Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFC7D2FE), width: 2),
              ),
              child: const Icon(
                Icons.mic_rounded,
                size: 40,
                color: Color(0xFF6366F1),
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Lavender content card.
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F3FF),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kurangi filler words',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 14),
                Text(
                  "Filler words seperti \"eee\" dan \"anu\" membuat jawabanmu "
                  "terdengar ragu. Ganti dengan jeda singkat. Jeda terdengar "
                  "lebih yakin dan memberi waktu untuk berpikir.",
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 2 — Video material
// ---------------------------------------------------------------------------
class LessonVideoStep extends StatelessWidget {
  const LessonVideoStep({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video player mock.
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 14,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.videocam_rounded,
                            size: 14, color: Colors.white),
                        SizedBox(width: 5),
                        Text(
                          'Video Materi',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  bottom: 14,
                  child: const Text(
                    '0:00 / 4:30',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Positioned(
                  right: 14,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'CC',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          const Text(
            'Kebersihan ucapan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Kenali dan kurangi filler words.',
            style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 20),

          // Optional article row.
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: const Row(
              children: [
                Icon(Icons.menu_book_rounded,
                    size: 22, color: Color(0xFF4F46E5)),
                SizedBox(width: 12),
                Text(
                  'Baca artikel',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                SizedBox(width: 6),
                Text(
                  '(opsional)',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 3 — Quiz
// ---------------------------------------------------------------------------
class LessonQuizStep extends StatelessWidget {
  final int? selectedOption;
  final bool isChecked;
  final int correctOption;
  final ValueChanged<int> onSelect;

  const LessonQuizStep({
    super.key,
    required this.selectedOption,
    required this.isChecked,
    required this.correctOption,
    required this.onSelect,
  });

  static const List<String> _options = [
    "Eee, jadi menurutku, eee, idenya bagus.",
    "Menurutku, idenya bagus karena hemat waktu.",
    "Jadi, ya, gtu, eee, pokonya bagus.",
  ];

  @override
  Widget build(BuildContext context) {
    final bool isCorrect = selectedOption == correctOption;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mana kalimat yang paling sedikit filler words?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Pilih satu jawaban',
            style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 22),

          for (int i = 0; i < _options.length; i++) ...[
            _buildOption(i, _options[i]),
            const SizedBox(height: 12),
          ],

          if (isChecked) ...[
            const SizedBox(height: 8),
            _buildFeedback(isCorrect),
          ],
        ],
      ),
    );
  }

  Widget _buildOption(int index, String text) {
    final bool isSelected = selectedOption == index;
    final bool showCorrect = isChecked && index == correctOption;
    final bool showWrong =
        isChecked && isSelected && index != correctOption;

    final Color borderColor = showCorrect
        ? const Color(0xFF4F46E5)
        : showWrong
            ? const Color(0xFFEF4444)
            : isSelected
                ? const Color(0xFF818CF8)
                : const Color(0xFFE2E8F0);

    final Color badgeColor = isSelected || showCorrect
        ? const Color(0xFF4F46E5)
        : const Color(0xFFF1F5F9);
    final Color badgeTextColor = isSelected || showCorrect
        ? Colors.white
        : const Color(0xFF64748B);

    return GestureDetector(
      onTap: isChecked ? null : () => onSelect(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: badgeColor,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                String.fromCharCode(65 + index),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: badgeTextColor,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
            if (showCorrect)
              const Icon(Icons.check_circle_rounded,
                  color: Color(0xFF4F46E5), size: 24),
            if (showWrong)
              const Icon(Icons.cancel_rounded,
                  color: Color(0xFFEF4444), size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedback(bool isCorrect) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isCorrect ? Icons.check_circle_rounded : Icons.error_rounded,
            color: isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCorrect ? 'Tepat!' : 'Belum tepat',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isCorrect
                        ? const Color(0xFF047857)
                        : const Color(0xFFB91C1C),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isCorrect
                      ? 'Jawaban B tidak memakai filler words dan langsung ke alasan.'
                      : 'Coba pilih kalimat yang paling bersih dari filler words.',
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 4 — Summary ("Intinya")
// ---------------------------------------------------------------------------
class LessonSummaryStep extends StatelessWidget {
  const LessonSummaryStep({super.key});

  static const List<String> _points = [
    'Filler words membuat jawabanmu terdengar ragu.',
    "Ganti \"eee\" dengan jeda singkat.",
    'Bicara pelan dan tarik napas sebelum menjawab.',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_rounded, color: Color(0xFFF59E0B), size: 26),
              SizedBox(width: 10),
              Text(
                'Intinya',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          for (int i = 0; i < _points.length; i++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEEF2FF),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4F46E5),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      _points[i],
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.4,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
          ],

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.fitness_center_rounded,
                    size: 20, color: Color(0xFF0EA5E9)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Latihan lagi di Final Test Unit 1',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0369A1),
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
}

// ---------------------------------------------------------------------------
// Step 5 — Completion ("Lesson selesai!")
// ---------------------------------------------------------------------------
class LessonCompleteStep extends StatelessWidget {
  final int lessonNumber;
  final VoidCallback onRestart;
  final VoidCallback onBackToRoadmap;

  const LessonCompleteStep({
    super.key,
    required this.lessonNumber,
    required this.onRestart,
    required this.onBackToRoadmap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          // Success badge.
          Center(
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(Icons.check_rounded,
                  size: 58, color: Colors.white),
            ),
          ),
          const SizedBox(height: 24),

          const Center(
            child: Text(
              'Lesson selesai!',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Speaking Pattern kini lebih terasa.',
              style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
          ),
          const SizedBox(height: 28),

          // Stat cards.
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.bolt_rounded,
                  iconColor: const Color(0xFFF59E0B),
                  value: '+10 XP',
                  label: 'Didapat',
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _StatCard(
                  icon: Icons.local_fire_department_rounded,
                  iconColor: const Color(0xFFEF4444),
                  value: '5 hari',
                  label: 'Streak',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Daily target card.
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Target harian',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      '10 · 20 XP',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6366F1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: const LinearProgressIndicator(
                    value: 0.5,
                    minHeight: 8,
                    backgroundColor: Color(0xFFE2E8F0),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          LessonButton(label: 'Lanjut ke Roadmap', onPressed: onBackToRoadmap),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onRestart,
            child: const Text(
              'Ulangi lesson',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 6),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}
