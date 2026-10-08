import 'package:flutter/material.dart';

import '../widgets/profile/profile_header_card.dart';
import '../widgets/profile/profile_communication_index_widget.dart';
import '../widgets/profile/pencapaian_widget.dart';
import '../widgets/profile/riwayat_tes_widget.dart';
import '../widgets/profile/pengaturan_widget.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top Profile Hero Card with Floating Stats
          ProfileHeaderCard(
            userName: 'Putri Anindya',
            userRoleGoal: 'Mahasiswa · Tujuan: Presentasi',
            levelLabel: 'Level Menengah',
            currentXp: 260,
            targetXp: 400,
            nextRankTitle: 'Profesional',
            streakDays: 5,
            totalXp: 260,
            completedTests: 12,
            onSettingsPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Membuka Pengaturan Profil'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            onEditAvatarPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ubah Foto Profil'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),

          // Spacing to accommodate the floating stats card overlap
          const SizedBox(height: 52),

          // Content section with horizontal padding
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2. Communication Index Section
                const ProfileCommunicationIndexWidget(
                  score: 68,
                  statusLabel: 'Baik',
                  pointsAdded: '↗ +8 poin',
                ),
                const SizedBox(height: 22),

                // 3. Pencapaian Section
                PencapaianWidget(
                  onViewAllPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Menampilkan semua pencapaian'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 22),

                // 4. Riwayat Tes Section
                RiwayatTesWidget(
                  onViewAllPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Menampilkan seluruh riwayat tes'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 22),

                // 5. Pengaturan Section
                PengaturanWidget(
                  onTargetHarianPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pengaturan Target Harian'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  onPrivasiPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pengaturan Privasi & Data Suara'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 90), // Spacing for floating bottom bar
              ],
            ),
          ),
        ],
      ),
    );
  }
}
