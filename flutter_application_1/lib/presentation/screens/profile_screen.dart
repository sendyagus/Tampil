import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/auth_service.dart';
import '../../services/test_session_service.dart';
import 'auth/login_screen.dart';
import '../utils/transition_utils.dart';
import '../widgets/profile/profile_header_card.dart';
import '../widgets/profile/profile_communication_index_widget.dart';
import '../widgets/profile/pencapaian_widget.dart';
import '../widgets/profile/riwayat_tes_widget.dart';
import '../widgets/profile/pengaturan_widget.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    // LIVE STREAM REALTIME DARI FIRESTORE USERS
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: authService.userProfileStream,
      builder: (context, snapshot) {
        final userData = snapshot.data?.data();
        final user = authService.currentUser;
        final uid = user?.uid ?? '';

        // Ambil nama dari Firestore (Huruf kapital di awal: "arsyad" -> "Arsyad")
        final rawName = userData?['nama'] ??
            (user?.displayName != null && user!.displayName!.isNotEmpty
                ? user.displayName!
                : (user?.email != null
                    ? user!.email!.split('@').first
                    : 'User'));
        final displayName = rawName.isNotEmpty
            ? '${rawName[0].toUpperCase()}${rawName.substring(1)}'
            : 'User';

        final level = userData?['level'] ?? 'Pemula';
        final streakDays = (userData?['current_streak'] is int)
            ? userData!['current_streak'] as int
            : 5;
        final totalXp = (userData?['total_xp'] is int)
            ? userData!['total_xp'] as int
            : 20;

        final tujuanList = userData?['tujuan'] as List<dynamic>?;
        final userGoal = (tujuanList != null && tujuanList.isNotEmpty)
            ? tujuanList.first.toString()
            : 'Percakapan';
        final userRoleGoal = 'Mahasiswa · Tujuan: $userGoal';

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Profile Hero Card (DATA ASLI DARI FIRESTORE)
              ProfileHeaderCard(
                userName: displayName,
                userRoleGoal: userRoleGoal,
                levelLabel: 'Level $level',
                currentXp: totalXp,
                targetXp: 100,
                nextRankTitle: 'Menengah',
                streakDays: streakDays,
                totalXp: totalXp,
                completedTests: 1,
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
                    // 2. Communication Index Section (LIVE SKOR DARI test_sessions)
                    FutureBuilder<TestSessionModel?>(
                      future: uid.isNotEmpty
                          ? TestSessionService().getLatestTestSession(uid)
                          : null,
                      builder: (context, sessionSnap) {
                        final session = sessionSnap.data;
                        final score = session != null
                            ? session.communicationIndex.toInt()
                            : 70;
                        final status = session != null
                            ? session.kategoriSkor
                            : 'Baik';

                        return ProfileCommunicationIndexWidget(
                          score: score,
                          statusLabel: status,
                          pointsAdded: '↗ +6 poin',
                        );
                      },
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

                    // 4. Riwayat Tes Section (LIVE DARI FIRESTORE test_sessions)
                    FutureBuilder<List<TestSessionModel>>(
                      future: uid.isNotEmpty
                          ? TestSessionService().getUserHistory(uid)
                          : null,
                      builder: (context, historySnap) {
                        final historySessions = historySnap.data ?? [];
                        final historyItems = historySessions.map((s) {
                          final title = s.caseTitle;
                          return TestHistoryItem(
                            title: title,
                            categoryDate:
                                '${s.tipe.toUpperCase()} · ${s.createdAt.day}/${s.createdAt.month}',
                            score: s.communicationIndex.toInt(),
                            statusLabel: s.kategoriSkor,
                            icon: Icons.check_circle_outline_rounded,
                            iconBgColor: const Color(0xFFEEF2FF),
                            iconColor: const Color(0xFF6366F1),
                          );
                        }).toList();

                        return RiwayatTesWidget(
                          items: historyItems.isNotEmpty ? historyItems : null,
                          onViewAllPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Menampilkan seluruh riwayat tes'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
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
                      onKeluarPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            title: const Text('Keluar dari Akun?'),
                            content: const Text(
                              'Apakah kamu yakin ingin keluar? Kamu perlu masuk kembali untuk mengakses latihanmu.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: const Text('Batal'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.of(ctx).pop(true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFEF4444),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text('Keluar'),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true && context.mounted) {
                          await AuthService().signOut();
                          if (context.mounted) {
                            Navigator.of(context).pushAndRemoveUntil(
                              DissolvePageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                              (route) => false,
                            );
                          }
                        }
                      },
                    ),
                    const SizedBox(
                      height: 90,
                    ), // Spacing for floating bottom bar
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
