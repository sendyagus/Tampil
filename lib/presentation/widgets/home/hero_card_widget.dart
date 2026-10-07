import 'package:flutter/material.dart';

class HeroCardWidget extends StatelessWidget {
  final int streakDays;
  final String unitName;
  final String lessonTitle;
  final String lessonSubtitle;
  final int currentLesson;
  final int totalLessons;
  final int currentXp;
  final int targetXp;
  final VoidCallback? onContinuePressed;

  const HeroCardWidget({
    super.key,
    this.streakDays = 5,
    this.unitName = 'UNIT 1',
    this.lessonTitle = 'Lesson 5: Speaking',
    this.lessonSubtitle = 'Daily Communication',
    this.currentLesson = 4,
    this.totalLessons = 5,
    this.currentXp = 20,
    this.targetXp = 40,
    this.onContinuePressed,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = (currentLesson / totalLessons).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF6366F1), // Bright Indigo
            Color(0xFF4F46E5), // Deep Indigo
            Color(0xFF3730A3), // Dark Purple Blue
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // Decorative background circle overlay
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            Positioned(
              left: -40,
              bottom: -40,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),

            // Card Content
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Tags Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Streak Tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.20),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Text('👏', style: TextStyle(fontSize: 13)),
                            const SizedBox(width: 6),
                            Text(
                              'Streak $streakDays hari',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Unit Tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.20),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          unitName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Lesson Titles
                  Text(
                    lessonTitle,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lessonSubtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.85),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Progress Row & Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progres',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.85),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '$currentLesson/$totalLessons lesson',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Custom Linear Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Colors.white.withOpacity(0.25),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Bottom Target & Continue Action
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // XP Target Pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.20),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.auto_awesome,
                              color: Color(0xFF38BDF8), // Cyan star icon
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Target harian $currentXp/$targetXp XP',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Continue Button
                      ElevatedButton(
                        onPressed: onContinuePressed ?? () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF4F46E5),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Lanjut',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.chevron_right_rounded,
                              size: 18,
                              color: Color(0xFF4F46E5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
