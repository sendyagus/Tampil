import 'package:flutter/material.dart';

class ProfileHeaderCard extends StatelessWidget {
  final String userName;
  final String userRoleGoal;
  final String levelLabel;
  final int currentXp;
  final int targetXp;
  final String nextRankTitle;
  final int streakDays;
  final int totalXp;
  final int completedTests;
  final VoidCallback? onSettingsPressed;
  final VoidCallback? onEditAvatarPressed;

  const ProfileHeaderCard({
    super.key,
    this.userName = 'Putri Anindya',
    this.userRoleGoal = 'Mahasiswa · Tujuan: Presentasi',
    this.levelLabel = 'Level Menengah',
    this.currentXp = 260,
    this.targetXp = 400,
    this.nextRankTitle = 'Profesional',
    this.streakDays = 5,
    this.totalXp = 260,
    this.completedTests = 12,
    this.onSettingsPressed,
    this.onEditAvatarPressed,
  });

  @override
  Widget build(BuildContext context) {
    final progressRatio = (currentXp / targetXp).clamp(0.0, 1.0);

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        // Main Purple Gradient Hero Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 60),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
            gradient: LinearGradient(
              colors: [
                Color(0xFF4F46E5),
                Color(0xFF7C3AED),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              // Top Bar: "Profil" Title & Settings Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Profil',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  InkWell(
                    onTap: onSettingsPressed,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.settings_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Profile Avatar with Edit Icon Badge
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 42,
                      backgroundColor: Color(0xFFE2E8F0),
                      backgroundImage: NetworkImage(
                        'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&q=80&w=200',
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: GestureDetector(
                      onTap: onEditAvatarPressed,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.edit_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // User Name
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),

              // Role & Goal
              Text(
                userRoleGoal,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: 10),

              // Level Pill Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: Color(0xFFFFD700),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      levelLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // XP Progress Section
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$currentXp / $targetXp XP',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        nextRankTitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progressRatio,
                      minHeight: 6,
                      backgroundColor: Colors.white.withValues(alpha: 0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Floating Stats Card (Positioned overlapping at the bottom)
        Positioned(
          bottom: -36,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Stat 1: Streak
                _buildStatColumn(
                  icon: Icons.local_fire_department_rounded,
                  iconColor: const Color(0xFFFF6B00),
                  value: '$streakDays',
                  label: 'Hari streak',
                ),
                Container(
                  height: 32,
                  width: 1,
                  color: const Color(0xFFF1F5F9),
                ),
                // Stat 2: Total XP
                _buildStatColumn(
                  icon: Icons.bolt_rounded,
                  iconColor: const Color(0xFFFFB800),
                  value: '$totalXp',
                  label: 'Total XP',
                ),
                Container(
                  height: 32,
                  width: 1,
                  color: const Color(0xFFF1F5F9),
                ),
                // Stat 3: Tes selesai
                _buildStatColumn(
                  icon: Icons.mic_rounded,
                  iconColor: const Color(0xFF6366F1),
                  value: '$completedTests',
                  label: 'Tes selesai',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatColumn({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 4),
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
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
