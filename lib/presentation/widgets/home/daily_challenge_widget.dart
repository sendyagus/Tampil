import 'package:flutter/material.dart';

class DailyChallengeWidget extends StatelessWidget {
  final String challengeTitle;
  final int rewardXp;
  final VoidCallback? onTap;

  const DailyChallengeWidget({
    super.key,
    this.challengeTitle = 'Ceritakan harimu dalam 30',
    this.rewardXp = 10,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left Challenge Icon Container
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFCCFBF1).withOpacity(0.6), // Light teal background
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Color(0xFF0D9488),
                size: 22,
              ),
            ),
            const SizedBox(width: 14),

            // Challenge Title & Category Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DAILY CHALLENGE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade500,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    challengeTitle,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // XP Badge Tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFCCFBF1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '+$rewardXp XP',
                style: const TextStyle(
                  color: Color(0xFF0D9488),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
