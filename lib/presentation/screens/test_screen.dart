import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../services/test_session_service.dart';
import '../widgets/test/test_header_widget.dart';
import '../widgets/test/test_daily_challenge_widget.dart';
import '../widgets/test/context_selector_widget.dart';
import '../widgets/test/studi_kasus_widget.dart';
import '../widgets/test/hasil_terakhir_widget.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final userId = authService.currentUser?.uid ?? '';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header
          const TestHeaderWidget(completedTests: 2, totalTests: 3),
          const SizedBox(height: 20),

          // 2. Daily Challenge Card
          TestDailyChallengeWidget(
            onStartPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Memulai Daily Challenge: Ceritakan harimu dalam 60 detik',
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          const SizedBox(height: 22),

          // 3. Context Selector
          ContextSelectorWidget(
            onContextSelected: (contextId) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Konteks dipilih: ${contextId.toUpperCase()}'),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(milliseconds: 1200),
                ),
              );
            },
          ),
          const SizedBox(height: 22),

          // 4. Studi Kasus Section (Membaca CaseStudies dari Firestore)
          StudiKasusWidget(
            onViewAllPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Menampilkan semua studi kasus'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            onItemPressed: (item) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Membuka studi kasus: ${item.title}'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          const SizedBox(height: 22),

          // 5. Hasil Terakhir Card (LIVE DARI FIRESTORE test_sessions)
          FutureBuilder<TestSessionModel?>(
            future: userId.isNotEmpty
                ? TestSessionService().getLatestTestSession(userId)
                : null,
            builder: (context, snapshot) {
              final session = snapshot.data;
              final score = session != null
                  ? session.communicationIndex.toInt()
                  : 70;
              final status = session != null ? session.kategoriSkor : 'Baik';

              return HasilTerakhirWidget(
                score: score,
                maxScore: 100,
                statusLabel: status,
                pointsAdded: '+6 poin ↑',
                onRetestPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Memulai tes ulang Communication Index'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 90), // Bottom spacing for navigation bar
        ],
      ),
    );
  }
}
