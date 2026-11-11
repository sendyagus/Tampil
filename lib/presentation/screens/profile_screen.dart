import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/auth_service.dart';
import '../../services/test_session_service.dart';
import 'auth/login_screen.dart';
import '../utils/transition_utils.dart';
import '../widgets/profile/profile_header_card.dart';
import 'edit_profile_screen.dart';
import '../widgets/profile/profile_communication_index_widget.dart';
import '../widgets/profile/pencapaian_widget.dart';
import '../widgets/profile/riwayat_tes_widget.dart';
import 'test/result_screen.dart';
import '../widgets/profile/pengaturan_widget.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  /// Foto profil asli user: prioritas field Firestore 'photo_url'/'foto_url'
  /// (disimpan halaman edit profil), lalu photoURL dari Auth. Null bila kosong.
  static String? _resolvePhotoUrl(
    Map<String, dynamic>? userData,
    String? authPhotoUrl,
  ) {
    for (final key in const ['photo_url', 'foto_url']) {
      final v = userData?[key];
      if (v is String && v.isNotEmpty) return v;
    }
    return (authPhotoUrl != null && authPhotoUrl.isNotEmpty)
        ? authPhotoUrl
        : null;
  }

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
        final rawName =
            userData?['nama'] ??
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
            : 0;
        final totalXp = (userData?['total_xp'] is int)
            ? userData!['total_xp'] as int
            : 0;
        final completedTests = (userData?['completed_tests'] is int)
            ? userData!['completed_tests'] as int
            : 0;

        final targetXp = level == 'Pemula'
            ? 100
            : (level == 'Menengah' ? 300 : 500);
        final nextRankTitle = level == 'Pemula'
            ? 'Menengah'
            : (level == 'Menengah' ? 'Mahir' : 'Master');

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
                targetXp: targetXp,
                nextRankTitle: nextRankTitle,
                streakDays: streakDays,
                totalXp: totalXp,
                completedTests: completedTests,
                onSettingsPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => EditProfileScreen(initialData: userData),
                    ),
                  );
                },
                // Foto asli user: field photo_url/foto_url (hasil edit profil),
                // fallback foto Auth. Bila kosong, header menampilkan inisial.
                avatarUrl: _resolvePhotoUrl(userData, user?.photoURL),
                onEditAvatarPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => EditProfileScreen(initialData: userData),
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
                    // 2. Communication Index Section (LIVE DARI riwayat
                    // test_sessions user: skor terbaru, selisih poin, dan
                    // grafik tren nyata — bukan angka/histogram dummy)
                    FutureBuilder<List<TestSessionModel>>(
                      future: uid.isNotEmpty
                          ? TestSessionService().getUserHistory(uid)
                          : null,
                      builder: (context, historyIdxSnap) {
                        final history =
                            historyIdxSnap.data ?? const <TestSessionModel>[];
                        final newest = history.isNotEmpty
                            ? history.first
                            : null;
                        final previous = history.length > 1 ? history[1] : null;

                        final score = newest != null
                            ? newest.communicationIndex.toInt()
                            : 0;
                        final status = newest != null
                            ? newest.kategoriSkor
                            : 'Belum ada data';

                        final String pointsLabel;
                        if (newest != null && previous != null) {
                          final diff =
                              newest.communicationIndex.toInt() -
                              previous.communicationIndex.toInt();
                          pointsLabel = diff >= 0
                              ? '↗ +$diff poin'
                              : '↘ $diff poin';
                        } else if (newest != null) {
                          pointsLabel = '↗ Tes pertama';
                        } else {
                          pointsLabel = 'Belum ada tes';
                        }

                        // Grafik butuh urutan tertua -> terbaru.
                        final scoreSeries = history.reversed
                            .map((s) => s.communicationIndex.toInt())
                            .toList();

                        return ProfileCommunicationIndexWidget(
                          score: score,
                          statusLabel: status,
                          pointsAdded: pointsLabel,
                          scoreHistory: scoreSeries,
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
                          String title = s.caseTitle.trim();
                          if (title.isEmpty) {
                            if (s.caseId == 'case_001' ||
                                s.caseId == 'perkenalan_diri') {
                              title = 'Perkenalan Diri';
                            } else if (s.caseId == 'case_002' ||
                                s.caseId == 'proyek_terlambat') {
                              title = 'Menghadapi Proyek Terlambat';
                            } else if (s.caseId == 'case_003' ||
                                s.caseId == 'presentasi_kelas') {
                              title = 'Presentasi Ide di Kelas';
                            } else {
                              title = 'Latihan Komunikasi';
                            }
                          }

                          final now = DateTime.now();
                          final isToday =
                              s.createdAt.year == now.year &&
                              s.createdAt.month == now.month &&
                              s.createdAt.day == now.day;
                          final dateStr = isToday
                              ? 'Hari ini, ${s.createdAt.hour.toString().padLeft(2, '0')}:${s.createdAt.minute.toString().padLeft(2, '0')}'
                              : '${s.createdAt.day}/${s.createdAt.month}/${s.createdAt.year}';

                          return TestHistoryItem(
                            title: title,
                            categoryDate: '${s.tipe.toUpperCase()} · $dateStr',
                            score: s.communicationIndex.toInt(),
                            statusLabel: s.kategoriSkor,
                            icon: Icons.check_circle_outline_rounded,
                            iconBgColor: const Color(0xFFEEF2FF),
                            iconColor: const Color(0xFF6366F1),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ResultScreen(
                                    analysisResult: s.toSpeechAnalysisResult(),
                                    contextTitle: s.tipe.toUpperCase(),
                                  ),
                                ),
                              );
                            },
                          );
                        }).toList();

                        return RiwayatTesWidget(
                          items: historyItems.isNotEmpty ? historyItems : null,
                          onViewAllPressed: () {
                            if (historySessions.isNotEmpty) {
                              _showAllHistorySheet(context, historySessions);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Belum ada riwayat tes'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
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

  void _showAllHistorySheet(
    BuildContext context,
    List<TestSessionModel> sessions,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.92,
          expand: false,
          builder: (_, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Semua Riwayat Tes (${sessions.length})',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        icon: const Icon(Icons.close_rounded, size: 22),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    itemCount: sessions.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    itemBuilder: (_, index) {
                      final s = sessions[index];
                      String title = s.caseTitle.trim();
                      if (title.isEmpty) {
                        if (s.caseId == 'case_001' ||
                            s.caseId == 'perkenalan_diri') {
                          title = 'Perkenalan Diri';
                        } else if (s.caseId == 'case_002' ||
                            s.caseId == 'proyek_terlambat') {
                          title = 'Menghadapi Proyek Terlambat';
                        } else if (s.caseId == 'case_003' ||
                            s.caseId == 'presentasi_kelas') {
                          title = 'Presentasi Ide di Kelas';
                        } else {
                          title = 'Latihan Komunikasi';
                        }
                      }
                      final now = DateTime.now();
                      final isToday =
                          s.createdAt.year == now.year &&
                          s.createdAt.month == now.month &&
                          s.createdAt.day == now.day;
                      final dateStr = isToday
                          ? 'Hari ini, ${s.createdAt.hour.toString().padLeft(2, '0')}:${s.createdAt.minute.toString().padLeft(2, '0')}'
                          : '${s.createdAt.day}/${s.createdAt.month}/${s.createdAt.year}';

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 4),
                        leading: Container(
                          width: 42,
                          height: 42,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEEF2FF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle_outline_rounded,
                            color: Color(0xFF6366F1),
                            size: 22,
                          ),
                        ),
                        title: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        subtitle: Text(
                          '${s.tipe.toUpperCase()} · $dateStr',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              s.communicationIndex.toInt().toString(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0F7FA),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                s.kategoriSkor,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF00ACC1),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.chevron_right_rounded,
                              size: 18,
                              color: Color(0xFF94A3B8),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.of(ctx).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ResultScreen(
                                analysisResult: s.toSpeechAnalysisResult(),
                                contextTitle: s.tipe.toUpperCase(),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
